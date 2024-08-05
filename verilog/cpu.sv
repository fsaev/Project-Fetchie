/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN*/

module cpu(input bit clk, input bit reset, input logic [31:0] data_in, output logic [31:0] data_out, output logic [31:0] addr);

/* Not all of these are connected yet, it's just so that I can start writing the code */
// logic [7:0] reg_sel_rd = 14;
// logic [7:0] reg_sel_wr = 15;
// logic [24:0] operation;
// wire load, enable, cnt_up, instr_out;
// wire inval_cache, instr_in, trg_next_instr;

logic [31:0] internal_data_in, internal_data_out;

wire increment_pc, pc_load;
wire [31:0] pc_data_out, reg_data_out;
wire fetch_m_req, dcache_m_req, execute_m_req;
logic fetch_m_ack, dcache_m_ack, execute_m_ack;
wire [31:0] fetch_data_in, dcache_data_in, execute_data_in;
wire [31:0] fetch_data_out, dcache_data_out, execute_data_out;
wire [31:0] fetch_addr, dcache_addr, execute_addr;

logic [5:0] reg_src_addr = 0;
logic [32:0] reg_dest_msk = 0;

/* Memory access priority, maybe do round-robin in the future */
assign data_out =   (execute_m_req) ? execute_data_out :
                    (dcache_m_req) ? dcache_data_out :
                    (fetch_m_req) ? fetch_data_out : 32'bZ;


counter pc(.clk(increment_pc), .reset(reset), .load(pc_load), .enable(1), .cnt_up(1), .data_in(internal_data_in), .data_out(pc_data_out));
registers registers_inst(.clk(clk), .reset(reset), .src_addr(reg_src_addr), .dest_msk(reg_dest_msk), .data_in(internal_data_in), .data_out(reg_data_out));

fetch fetch_inst(.clk(clk), .reset(reset), .pc(pc_data_out), .data_in(fetch_data_in), .m_req(fetch_m_req), .m_req_addr(fetch_addr), .m_ack(fetch_m_ack),
                    .increment_pc(increment_pc), .trg_next_instr(trg_next_instr), .instr_out(fetch_data_out));

// fetch fetch_inst(.clk(clk), .reset(reset), .pc(pc_data_out), .inval_cache(inval_cache), .data_in(data_in), .m_req(fetch_m_req), .m_req_addr(fetch_addr), .m_ack(fetch_m_ack),
//                     .trg_next_instr(trg_next_instr), .instr_out(instr_out));
// decode decode_inst(.clk(clk), .reset(reset), .instr_in(instr_out), .operation(operation));

endmodule
