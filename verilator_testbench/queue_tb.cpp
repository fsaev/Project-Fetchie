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
#include "Vqueue_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

uint32_t fifo_payload[16] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
uint32_t read_word;
uint32_t idx = 0;

enum State {
    IDLE,
    WRITING,
    READING
};

State state = WRITING;

bool tick(int tickcount, Vqueue_tb *vqueue_tb, VerilatedVcdC* tfp) {
    vqueue_tb->clk = tickcount % 2;
    vqueue_tb->reset = 0;

    if(vqueue_tb->clk == 0){
    switch(state){
        case IDLE:
            vqueue_tb->wr_en = 0;
            vqueue_tb->shift_out = 0;
            break;
        case WRITING:
            vqueue_tb->wr_en = 1;
            vqueue_tb->shift_out = 0;
            vqueue_tb->data_in = fifo_payload[idx];
            printf("Clocking in %d\n", fifo_payload[idx]);
            idx++;
            if(idx == 15){
                printf("Finished writing\n");
                state = READING;
            }
            break;
        case READING:
            vqueue_tb->wr_en = 0;
            vqueue_tb->shift_out = 1;
            read_word = vqueue_tb->data_out;
            printf("Read out %d\n", read_word);
            idx--;
            if(idx == 0){
                state = WRITING;
            }
            break;
        }
    }

    vqueue_tb->eval(); //Run module

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
    Vqueue_tb* vqueue_tb = new Vqueue_tb{contextp};

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	vqueue_tb->trace(tfp, 00);
	tfp->open("fifotrace.vcd");

    while (!contextp->gotFinish() && running) {
        if(tick(++counter, vqueue_tb, tfp)){
            running = false;
        }
    }
    tfp->flush();
    delete vqueue_tb;
    delete contextp;
    delete tfp;
    return 0;
}
