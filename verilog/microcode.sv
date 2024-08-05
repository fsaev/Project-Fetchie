module microcode(input bit clk, input bit reset, input logic [24:0] microcode_addr, output logic [32:0] microcode_data);
    // This is the microcode memory
    reg [32:0] microcode [0:255];

endmodule
