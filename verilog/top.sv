/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN*/
/* verilator lint_off DECLFILENAME*/
/* verilator lint_off PINMISSING */
/* verilator lint_off WIDTHTRUNC */
/* verilator lint_off WIDTHEXPAND */

module top(input CLK, input RESET_N, input RX, output TX, output reg LEDR_N, output reg LEDG_N, output reg LED1, 
            output reg P1B1, output reg P1B2, output reg P1B3, output reg P1B4, output reg P1B7, output reg P1B8, output reg P1B9, output reg P1B10);

parameter DIVIDER_VALUE = 270000;

reg [31:0] counter = 0;
reg clk_divided = 0;

assign LEDG_N = clk_divided;


always @(posedge CLK) begin
    if (~RESET_N) begin
        counter <= 0;
        clk_divided <= 0;
    end else begin
        counter <= counter + 1;
        if (counter == DIVIDER_VALUE) begin
            counter <= 0;
            clk_divided <= ~clk_divided;
        end
    end
end

wire [31:0] data_in;
wire [31:0] data_out;
wire [31:0] addr;
wire cpu_m_req, cpu_m_ack, cpu_m_wr;

wire [3:0] ram_w_en, ram_data_out, ram_data_in;

assign ram_w_en = cpu_m_wr ? 4'b1111 : 4'b0000;

assign data_in = cpu_m_req ? ram_data_in : 32'bZ;
assign data_out = cpu_m_req ? ram_data_out : 32'bZ;

assign P1B1 = data_out[0];
assign P1B2 = data_out[1];
assign P1B3 = data_out[2];
assign P1B4 = data_out[3];
assign P1B7 = data_out[4];
assign P1B8 = data_out[5];
assign P1B9 = data_out[6];
assign P1B10 = data_out[7];

cpu cpu_inst(.clk(CLK), .reset(RESET_N), .data_in(data_in), .data_out(data_out), .addr(addr), .m_req(cpu_m_req), .m_ack(1), .m_wr(cpu_m_wr));

ice40up5k_spram ram (
    .clk(CLK),
    .wen(ram_w_en),
    .addr(addr),
    .wdata(ram_data_out),
    .rdata(ram_data_in)
    );


endmodule
