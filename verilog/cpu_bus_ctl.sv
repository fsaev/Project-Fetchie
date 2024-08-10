module cpu_bus_ctl #(parameter LINES = 3) (
    input bit [LINES-1:0] bus_req,
    output bit [LINES-1:0] bus_grant
);

always_ff @(bus_req) begin
    for (int i = 0; i < LINES; i++) begin
        if ((bus_req[i] == 1) && (bus_grant == 0)) begin
            bus_grant[i] <= 1;
        end else begin
            bus_grant[i] <= 0;
        end
    end
end
endmodule
