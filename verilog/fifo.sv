/*
 * FIFO module
 * Generated by Copilot. Don't sue me if this is stolen from somewhere.
 */

module fifo #(parameter SIZE = 8) (
    input logic clk,
    input logic reset,
    input logic wr_en,
    input logic rd_en,
    input logic [31:0] data_in,
    output logic [31:0] data_out,
    output logic empty,
    output logic full
);

    logic [31:0] buffer [SIZE-1:0];
    logic [SIZE-1:0] wr_ptr;
    logic [SIZE-1:0] rd_ptr;
    logic [SIZE-1:0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
        end else begin
            if (wr_en && !full) begin
                buffer[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1;
                count <= count + 1;
            end
            if (rd_en && !empty) begin
                data_out <= buffer[rd_ptr];
                rd_ptr <= rd_ptr + 1;
                count <= count - 1;
            end
        end
    end

    assign empty = (count == 0);
    assign full = (count == SIZE);

endmodule