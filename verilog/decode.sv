/*
* decode.sv
* 
* Decode module
*
* Decode will take instructions from the fetch module, look up what instruction type it is, send the
* index to the microcode, which will then return the operation that will be executed.
*/

module decode(input logic clk, input logic reset, input logic [31:0] instr_in, 
                output logic [23:0] microcode_addr, input logic [31:0] microcode_data,
                output logic [24:0] operation);

endmodule
