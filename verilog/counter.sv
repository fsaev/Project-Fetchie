module counter(input clk, input load, input enable, input cnt_up, input [31:0] data_in, output reg [31:0] data_out);

    always @(posedge clk)
    begin
        if (load) begin
            data_out <= data_in;
        end
        else if (enable) begin
            if (cnt_up)
                data_out <= data_out + 32'h00000001;
            else
                data_out <= data_out - 32'h00000001;
        end
    end
endmodule
