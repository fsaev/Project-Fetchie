module fetch(input bit clk, input bit reset, input logic [31:0] pc, input logic [31:0] data_in, 
                output bit m_req, output logic [31:0] m_req_addr, input bit m_ack,
                input logic trg_next_instr, output logic [31:0] instr_out,
                output bit ic_empty, output bit ic_full,
                input bit inval_cache);

    logic ic_reset;

    assign m_req = (~reset && ~ic_full) ? 1 : 0;

    assign ic_reset = (reset || inval_cache) ? 1 : 0;

    queue #(.SIZE(32), .WIDTH(32)) icache(.clk(clk), .reset(ic_reset), .wr_en(m_ack), .shift_out(trg_next_instr), 
            .data_in(data_in), .data_out(instr_out), .empty(ic_empty), .full(ic_full));

    wire unused;
    assign unused = ic_empty;

    always_ff @(posedge clk) begin
        if(reset || inval_cache) begin
            m_req_addr <= pc;
        end else if (~ic_full) begin
            if(m_ack) begin
                m_req_addr <= m_req_addr + 4;
            end
        end
    end

endmodule
