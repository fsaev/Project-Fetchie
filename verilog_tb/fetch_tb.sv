module fetch_tb(input bit clk, input bit reset, input logic [31:0] pc, input logic [31:0] data_in, 
                output bit m_req, output logic [31:0] m_req_addr, input bit m_ack,
                input logic trg_next_instr, output logic [31:0] instr_out,
                output bit ic_empty, output bit ic_full, input bit inval_cache, input bit debug);

/* verilator lint_off UNUSEDSIGNAL */
    wire dbg = debug;
/* verilator lint_on UNUSEDSIGNAL */

    fetch fetch_inst(.clk(clk), .reset(reset), .pc(pc), .data_in(data_in), .m_req(m_req), .m_req_addr(m_req_addr), .m_ack(m_ack),
                    .trg_next_instr(trg_next_instr), .instr_out(instr_out), .ic_empty(ic_empty), .ic_full(ic_full), .inval_cache(inval_cache));

endmodule
