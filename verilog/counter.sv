/* Simple counter module with load, enable, and up/down control.
 * The counter is 32 bits wide.
 * The counter is synchronous with the clock.
 * The counter is reset to 0 when load is asserted.
 * The counter increments by 1 when enable and cnt_up are asserted.
 * The counter decrements by 1 when enable and cnt_up are deasserted.
 */

module counter(input bit clk, input bit reset, input bit load, input bit enable, input bit cnt_up, input logic [31:0] data_in, output logic [31:0] data_out);
    always @(posedge clk) begin
        if (reset) begin
            data_out <= 32'h00000000;
        end else if (load) begin
            data_out <= data_in;
        end else if (enable) begin
            if (cnt_up)
                data_out <= data_out + 32'h00000001;
            else
                data_out <= data_out - 32'h00000001;
        end
    end

endmodule
