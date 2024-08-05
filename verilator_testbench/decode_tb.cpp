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
#include "Vdecode_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


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

bool tick(int tickcount, Vdecode_tb *vdecode_tb, VerilatedVcdC* tfp) {
    uint32_t read_word;
    vdecode_tb->clk = tickcount % 2;

    if(vdecode_tb->clk == 0){

    }

    vdecode_tb->eval(); //Run module

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
    Vdecode_tb* vdecode_tb = new Vdecode_tb{contextp};

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	vdecode_tb->trace(tfp, 00);
	tfp->open("decodetrace.vcd");

    while (!contextp->gotFinish() && running) {
        if(tick(++counter, vdecode_tb, tfp)){
            running = false;
        }
    }
    tfp->flush();
    delete vdecode_tb;
    delete contextp;
    delete tfp;
    return 0;
}
