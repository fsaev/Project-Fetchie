/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN*/

module queue_tb(input bit clk, input bit reset, input logic [31:0] data_in, output logic [31:0] data_out, 
                input logic wr_en, input logic shift_out);

    wire empty, full;

    queue #(.SIZE(10), .WIDTH(32)) fifo_inst(.clk(clk), .reset(reset), .wr_en(wr_en), .shift_out(shift_out), 
            .data_in(data_in), .data_out(data_out), .empty(empty), .full(full));

endmodule
