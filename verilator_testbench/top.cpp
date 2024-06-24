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
#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

enum opcodes {
    NOP = 0x00,
    HALT = 0x01,
    LDAim = 0x02,
    LDA = 0x03,
    STA = 0x04
};

uint8_t program[] = {
    NOP, LDAim, 0xde, STA, 0xfe, 0xed,
    0x01
};

uint16_t prog_idx = 0;

enum class tb_states {
    START,
    PROG,
    RUN,
    HALT
};

tb_states state = tb_states::START;

bool tick(int tickcount, Vtop *top, VerilatedVcdC* tfp) {
    top->clk_in = tickcount % 2;
    top->eval(); //Run module

    // switch(state){
    //     case tb_states::START:
    //         top->reset_in = 1;
    //         if(tickcount > 10){
    //             printf("Program load\n");
    //             state = tb_states::PROG;
    //         }
    //         break;
    //     case tb_states::PROG:
    //         // top->reset_in = 0;
    //         // top->prog_in = 1;
            
    //         // top->data_in = program[prog_idx++];
    //         // top->addr_in = prog_idx;

    //         if(prog_idx >= sizeof(program)){
    //             printf("Program loaded\n");
    //             top->prog_in = 0;
    //             state = tb_states::RUN;
    //         }
    //         break;
    //     case tb_states::RUN:

    //         break;
    //     case tb_states::HALT:
    //         return true;
    // }
    // if (top->irq)
    // {
    //     std::cout << "Got IRQ, acking" << std::endl;
    //     top->irq_ack = 1;
    // }else{
    //     top->irq_ack = 0;
    // }
    if(tickcount > 10000000){
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
    Vtop* top = new Vtop{contextp};

	// Generate a trace
	Verilated::traceEverOn(true);
	VerilatedVcdC* tfp = new VerilatedVcdC;
	top->trace(tfp, 00);
	tfp->open("toptrace.vcd");
    top->reset_in = 1;

    while (!contextp->gotFinish() && running) {
        if(tick(++counter, top, tfp)){
            running = false;
        }
    }
    tfp->flush();
    delete top;
    delete contextp;
    delete tfp;
    return 0;
}
