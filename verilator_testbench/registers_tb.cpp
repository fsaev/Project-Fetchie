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
#include "Vregisters_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

uint32_t fifo_payload[16] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
uint32_t read_word;
uint32_t idx = 0;

enum Registers {
    X0 = 0,
    X1 = 1,
    X2 = 2,
    X3 = 3,
    X4 = 4,
    X5 = 5,
    X6 = 6,
    X7 = 7,
    X8 = 8,
    X9 = 9,
    X10 = 10,
    X11 = 11,
    X12 = 12,
    X13 = 13,
    X14 = 14,
    X15 = 15,
    X16 = 16,
    X17 = 17,
    X18 = 18,
    X19 = 19,
    X20 = 20,
    X21 = 21,
    X22 = 22,
    X23 = 23,
    X24 = 24,
    X25 = 25,
    X26 = 26,
    X27 = 27,
    X28 = 28,
    X29 = 29,
    X30 = 30,
    X31 = 31,
    DATA_IO = 32
};;

enum State {
    IDLE,
    WRITE_X1,
    WRITE_X2,
    WRITE_X2_TO_X3_AND_X4,
    WRITE_X0,

    READ_X3,
    TEST_X3,
    READ_X0,
    TEST_X0,
};

State state = IDLE;

bool tick(int tickcount, Vregisters_tb *vregisters_tb, VerilatedVcdC* tfp) {
    uint32_t read_word;
    vregisters_tb->clk = tickcount % 2;
    vregisters_tb->reset = 0;

    if(vregisters_tb->clk == 0){
    switch(state){
        case IDLE:
            vregisters_tb->src_addr = 0;
            vregisters_tb->dest_msk = 0;
            //vregisters_tb->load = 0;
            vregisters_tb->data_in = 0;

            state = WRITE_X1;
            break;
        case WRITE_X1:
            vregisters_tb->data_in = 0xFACEBEEF;
            vregisters_tb->src_addr = DATA_IO;
            vregisters_tb->dest_msk = 1 << X1;
            //vregisters_tb->load = 1;

            state = WRITE_X2;
            break;
        case WRITE_X2:
            vregisters_tb->data_in = 0xBEEFCAFE;
            vregisters_tb->src_addr = DATA_IO;
            vregisters_tb->dest_msk = 1 << X2;
            //vregisters_tb->load = 1;

            state = WRITE_X2_TO_X3_AND_X4;
            break;
        case WRITE_X2_TO_X3_AND_X4:
            vregisters_tb->src_addr = X2;
            vregisters_tb->dest_msk = 1 << X3 | 1 << X4;
            //vregisters_tb->load = 1;

            state = WRITE_X0;
            break;
        case WRITE_X0:
            vregisters_tb->data_in = 0xDEADDEAD;
            vregisters_tb->src_addr = DATA_IO;
            vregisters_tb->dest_msk = 1 << X0;
            //vregisters_tb->load = 1;

            state = READ_X3;
            break;

        /* Tests */
        case READ_X3:
            vregisters_tb->src_addr = X3;
            vregisters_tb->dest_msk = (uint64_t) 1 << DATA_IO;
            //vregisters_tb->load = 0;

            state = TEST_X3;
            break;
        case TEST_X3:
            read_word = vregisters_tb->data_out;
            if(read_word == 0xBEEFCAFE){
                printf("Write and read X3: Test passed\n");
            } else {
                printf("Write and read X3: Test failed\n");
            }
            state = READ_X0;
            break;
        case READ_X0:
            vregisters_tb->src_addr = X0;
            vregisters_tb->dest_msk = (uint64_t) 1 << DATA_IO;
            //vregisters_tb->load = 0;

            state = TEST_X0;
            break;
        case TEST_X0:
            read_word = vregisters_tb->data_out;
            if(read_word == 0x00){
                printf("Write and read X0: Test passed\n");
            } else {
                printf("Write and read X0: Test failed\n");
            }
            return true;
            break;
        }
    }

    vregisters_tb->eval(); //Run module

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
    Vregisters_tb* vregisters_tb = new Vregisters_tb{contextp};

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	vregisters_tb->trace(tfp, 00);
	tfp->open("registerstrace.vcd");

    while (!contextp->gotFinish() && running) {
        if(tick(++counter, vregisters_tb, tfp)){
            running = false;
        }
    }
    tfp->flush();
    delete vregisters_tb;
    delete contextp;
    delete tfp;
    return 0;
}
