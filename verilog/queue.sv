/*
 * queue module
 */

module queue #(parameter SIZE = 8, parameter WIDTH = 32)  (
    input logic clk,
    input logic reset,
    input logic wr_en,
    input logic shift_out,
    input logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out,
    output logic empty,
    output logic full
);

    logic [WIDTH-1:0] buffer [SIZE-1:0];
    logic [31:0] count;

    function void shift_left_by_byte();
        for (int i = 0; i < SIZE-1; i++) begin
            buffer[i] <= buffer[i+1];
        end
    endfunction

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
        end else begin
            if (wr_en && !full) begin
                buffer[count] <= data_in;
                count <= count + 1;
            end
            if (shift_out && !empty) begin
                shift_left_by_byte();
                count <= count - 1;
            end
        end
    end

    assign data_out = buffer[0];

    assign empty = (count == 0);

    assign full = (count == SIZE);
endmodule
