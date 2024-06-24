/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN*/
/* verilator lint_off DECLFILENAME*/
/* verilator lint_off PINMISSING */

module cache(
    input clk,
    input [31:0] addr_in,
    input [31:0] data_in
);

    fifo #(.SIZE(1024)) fifo_inst(.clk(clk), .reset(0), .wr_en(1), .rd_en(0), .data_in(data_in), .data_out(0), .empty(0), .full(0));

endmodule