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
#include "uart_emu.h"

static UartEmu uart_emu{9600};

bool tick(int tickcount, Vtop *top, VerilatedVcdC* tfp) {
    top->CLK = tickcount % 2;
    if (tickcount % 10 == 0) {
        uart_emu.tick(tickcount, top);
    }
    top->eval(); //Run module

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
    top->RESET_N = 0;

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
