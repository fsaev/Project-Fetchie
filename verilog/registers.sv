`define x0 6'd0
`define x1 6'd1
`define x2 6'd2
`define x3 6'd3
`define x4 6'd4
`define x5 6'd5
`define x6 6'd6
`define x7 6'd7
`define x8 6'd8
`define x9 6'd9
`define x10 6'd10
`define x11 6'd11
`define x12 6'd12
`define x13 6'd13
`define x14 6'd14
`define x15 6'd15
`define x16 6'd16
`define x17 6'd17
`define x18 6'd18
`define x19 6'd19
`define x20 6'd20
`define x21 6'd21
`define x22 6'd22
`define x23 6'd23
`define x24 6'd24
`define x25 6'd25
`define x26 6'd26
`define x27 6'd27
`define x28 6'd28
`define x29 6'd29
`define x30 6'd30
`define x31 6'd31
`define DATA_IO 6'd32

module registers(input bit clk, input bit reset, input logic [5:0] src_addr, input logic [32:0] dest_msk, 
                    input logic [31:0] data_in, output logic [31:0] data_out);

    const reg [31:0] null_reg = 32'b0;
    wire unused;
    wire [31:0] reg_data_out;
    wire [31:0] data;

    assign unused = dest_msk[0]; // X0 can't be written, so we simply ignore dest_msk[0] 
    wire [30:0] reg_dest_msk = dest_msk[31:1]; // Filter away x0
    wire data_io_dest = dest_msk[`DATA_IO]; // Data IO

    // x1 - x31 registers
    genvar i;
    generate
        for (i = 0; i < 31; i++) begin : register_gen
            register reg_inst (
                .clk(clk),
                .reset(reset),
                .load(reg_dest_msk[i]), // Load data if dest_msk bit is set, multiple destinations can be selected
                .out((src_addr - 1) == i), // Output if src_addr matches register number
                .data_in(data),
                .data_out(reg_data_out)
            );
        end
    endgenerate

    assign data = (src_addr == `x0) ? null_reg :
                  (src_addr == `DATA_IO) ? data_in :
                  reg_data_out;

    assign data_out = (data_io_dest == 1) ? data : null_reg ; // If data_io_dest is set, output data, else 0

endmodule
