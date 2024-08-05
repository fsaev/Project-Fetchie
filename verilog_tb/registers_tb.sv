module registers_tb(input bit clk, input bit reset, input logic [5:0] src_addr, input logic [32:0] dest_msk, 
                    input logic [31:0] data_in, output logic [31:0] data_out);

    registers registers_inst(.clk(clk), .reset(reset), .src_addr(src_addr), .dest_msk(dest_msk),
                            .data_in(data_in), .data_out(data_out));
endmodule
