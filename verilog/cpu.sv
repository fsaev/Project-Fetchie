/* verilator lint_off UNUSED */
/* verilator lint_off UNDRIVEN*/

module cpu(input bit clk, input bit reset, input logic [31:0] data_in, output logic [31:0] data_out, output logic [31:0] addr, output bit m_req, input bit m_ack, output bit m_wr);

/* Not all of these are connected yet, it's just so that I can start writing the code */
// logic [7:0] reg_sel_rd = 14;
// logic [7:0] reg_sel_wr = 15;
// logic [24:0] operation;
// wire load, enable, cnt_up, instr_out;
// wire inval_cache, instr_in, trg_next_instr;

logic [31:0] internal_data_in, internal_data_out;

wire increment_pc, pc_load;
wire [31:0] pc_data_out, reg_data_out;


wire icache_empty, icache_full, inval_cache;


logic [31:0] fetch_data_in, dcache_data_in, execute_data_in;
wire [31:0] fetch_data_out, dcache_data_out, execute_data_out;
wire [31:0] fetch_addr, dcache_addr, execute_addr;
logic fetch_m_ack, dcache_m_ack, execute_m_ack;

cpu_bus_ctl #(.LINES(1)) ext_bus_ctl(.bus_req(ext_bus_req), .bus_grant(ext_bus_grant));

wire [0:0] ext_bus_req, ext_bus_grant;

always_comb begin
    if (ext_bus_grant[0]) begin
        fetch_data_in = data_in;
        data_out = fetch_data_out;
        addr = fetch_addr;
        m_req = 1;
        m_wr = 0;
        fetch_m_ack = 1;
    end else begin
        fetch_data_in = 32'bZ;
        data_out = 32'bZ;
        addr = 32'bZ;
        m_req = 0;
        m_wr = 0;
        fetch_m_ack = 0;
    end
end


counter pc(.clk(increment_pc), .reset(reset), .load(pc_load), .enable(1), .cnt_up(1), .data_in(internal_data_in), .data_out(pc_data_out));
registers registers_inst(.clk(clk), .reset(reset), .src_addr(1), .dest_msk(2), .data_in(internal_data_in), .data_out(reg_data_out));

fetch fetch_inst(.clk(clk), .reset(reset), .pc(pc_data_out), .data_in(fetch_data_in), .m_req(ext_bus_req[0]), .m_req_addr(fetch_addr), .m_ack(ext_bus_grant[0]),
                    .trg_next_instr(0), .instr_out(fetch_data_out), .ic_empty(icache_empty), .ic_full(icache_full), .inval_cache(inval_cache));

// fetch fetch_inst(.clk(clk), .reset(reset), .pc(pc_data_out), .inval_cache(inval_cache), .data_in(data_in), .m_req(fetch_m_req), .m_req_addr(fetch_addr), .m_ack(fetch_m_ack),
//                     .trg_next_instr(trg_next_instr), .instr_out(instr_out));
// decode decode_inst(.clk(clk), .reset(reset), .instr_in(instr_out), .operation(operation));

endmodule
