module register(input bit clk, input bit reset, input bit load, input bit out, input logic [31:0] data_in, output logic [31:0] data_out);

    reg [31:0] data;

    assign data_out = (out) ? data : 32'hZZZZZZZZ;

    always @(posedge clk)
    begin
        if (reset)
            data <= 32'h00000000;
        else if (load)
            data <= data_in;
    end

endmodule
