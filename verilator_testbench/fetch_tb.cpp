////////////////////////////////////////////////////////////////////////////////
//
// Filename: 	blinky.cpp
//
// Project:	Verilog Tutorial Example file
//
// Purpose:	Drives the LED blinking design Verilator simulation
//
// Creator:	Dan Gisselquist, Ph.D.
//		Gisselquist Technology, LLC
//
////////////////////////////////////////////////////////////////////////////////
//
// Written and distributed by Gisselquist Technology, LLC
//
// This program is hereby granted to the public domain.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTIBILITY or
// FITNESS FOR A PARTICULAR PURPOSE.
//
////////////////////////////////////////////////////////////////////////////////
//
//
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "Vfetch_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define fetch_cycles 40

uint32_t dummy_memory[128];
uint32_t readback_memory[128];
uint32_t fetch_cycle_count;
uint32_t memory_fetched = 0;
uint32_t readback_memory_idx = 0;


enum State {
    IDLE,
    FETCH,
    REQUEST_BACK,
    FETCH_MORE,
    INVALIDATE_CACHE,
    CHECK_IF_EMPTY,
    RUN_FOR_TWO_CYCLES
};

State state = IDLE;

bool tick(int tickcount, Vfetch_tb *vfetch_tb, VerilatedVcdC* tfp) {
    uint32_t read_word;
    vfetch_tb->clk = tickcount % 2;

    if(vfetch_tb->clk == 0){
        switch(state){
            case IDLE:
                vfetch_tb->reset = 1;
                vfetch_tb->trg_next_instr = 0;
                vfetch_tb->pc = 0x00000000;
                vfetch_tb->m_ack = 0;
                vfetch_tb->m_req_addr = 0;
                vfetch_tb->data_in = 0;
                if(fetch_cycle_count == 2){ // Hold in reset for 2 cycles
                    state = FETCH;
                }else{
                    fetch_cycle_count++;
                }
                break;
            case FETCH:
                printf("Cycle %d : ", fetch_cycle_count);
                vfetch_tb->reset = 0;
                vfetch_tb->trg_next_instr = 0;
                if(vfetch_tb->m_req){
                    vfetch_tb->m_ack = 1;
                    vfetch_tb->data_in = dummy_memory[vfetch_tb->m_req_addr/4];
                    printf("Fetching instruction at address 0x%08x (Word: %d) : 0x%08x\n", vfetch_tb->m_req_addr, vfetch_tb->m_req_addr/4, vfetch_tb->data_in);
                    memory_fetched++;
                }else{
                    vfetch_tb->data_in = dummy_memory[vfetch_tb->m_req_addr/4];
                    vfetch_tb->m_ack = 0;
                    printf("No memory requested\n");
                }
                
                if(fetch_cycle_count == fetch_cycles){
                    //vfetch_tb->trg_next_instr = 1; // Get next instruction
                    state = REQUEST_BACK;
                    fetch_cycle_count = 0;
                } else {
                    fetch_cycle_count++;
                }
                break;
            case REQUEST_BACK:
                if(!vfetch_tb->ic_empty){
                    //if(readback_memory_idx > 0){ // Only start triggering new instructions after first one is read
                        vfetch_tb->trg_next_instr = 1; // Get next instruction
                    //}
                    vfetch_tb->debug = !vfetch_tb->debug;
                    readback_memory[readback_memory_idx] = vfetch_tb->instr_out;
                    printf("Readback instruction: 0x%08x\n", vfetch_tb->instr_out);

                    readback_memory_idx++;
                }else{
                    for(int i = 0; i < readback_memory_idx; i++){
                        if(readback_memory[i] != dummy_memory[i]){
                            printf("Failed: Readback memory does not match dummy memory\n");
                            return true;
                        }
                    }
                    printf("Success: Readback memory matches dummy memory\n");
                    printf("Invalidate cache test\n");
                    state = FETCH_MORE;
                }
                break;
            case FETCH_MORE:
                printf("Cycle %d : ", fetch_cycle_count);
                vfetch_tb->reset = 0;
                vfetch_tb->trg_next_instr = 0;
                if(vfetch_tb->m_req){
                    vfetch_tb->m_ack = 1;
                    vfetch_tb->data_in = dummy_memory[vfetch_tb->m_req_addr/4];
                    printf("Fetching instruction at address 0x%08x (Word: %d) : 0x%08x\n", vfetch_tb->m_req_addr, vfetch_tb->m_req_addr/4, vfetch_tb->data_in);
                    memory_fetched++;
                }else{
                    vfetch_tb->data_in = dummy_memory[vfetch_tb->m_req_addr/4];
                    vfetch_tb->m_ack = 0;
                    printf("No memory requested\n");
                }
                
                if(fetch_cycle_count == fetch_cycles){
                    //vfetch_tb->trg_next_instr = 1; // Get next instruction
                    state = INVALIDATE_CACHE;
                    fetch_cycle_count = 0;
                } else {
                    fetch_cycle_count++;
                }
                break;
            case INVALIDATE_CACHE:
                vfetch_tb->inval_cache = 1;
                vfetch_tb->pc = 0x0000002F;
                state = CHECK_IF_EMPTY;
                break;
            case CHECK_IF_EMPTY:
                if(vfetch_tb->ic_empty){
                    printf("Passed: Cache invalidated\n");
                }else{
                    printf("Failed: Cache not empty\n");
                }
                state = RUN_FOR_TWO_CYCLES;
                break;
            case RUN_FOR_TWO_CYCLES:
                if(fetch_cycle_count >= 2){
                    return true;
                }else{
                    fetch_cycle_count++;
                }
                break;
        }
    }

    vfetch_tb->eval(); //Run module

    if(tickcount > 1000){
        printf("Exceeded simulation limit, halting\n");
        return true;
    }
    if (tfp){ //If dumpfile
        tfp->dump(tickcount * 25);
    }
    return false;
}

int main(int argc, char** argv) {
    int counter = 0;
    bool running = true;
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);
    Vfetch_tb* vfetch_tb = new Vfetch_tb{contextp};

    // Initialize memory
    for(int i = 0; i < 128; i++){
        dummy_memory[i] = i;
    }

    dummy_memory[0] = 0xBEEFFACE;

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	vfetch_tb->trace(tfp, 00);
	tfp->open("fetchtrace.vcd");

    while (!contextp->gotFinish() && running) {
        if(tick(++counter, vfetch_tb, tfp)){
            running = false;
        }
    }
    tfp->flush();
    delete vfetch_tb;
    delete contextp;
    delete tfp;
    return 0;
}
