module decode_tb(input logic clk, input logic reset, input logic [31:0] instr_in, output logic [24:0] operation);

    decode decode_inst(.clk(clk), .reset(reset), .instr_in(instr_in), .operation(operation));

endmodule
