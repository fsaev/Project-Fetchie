
.PHONY: all
all: top


VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include
TARGET_VERILOG_FOLDER=./verilog
TARGET_VERILATOR_FOLDER=./verilator_testbench

# Ideally, we'd want -GWIDTH=12
# This requires a newer version of Verilator than I have with my distro
# Hence we have the `ifdef inside gpu.v
top: $(TARGET_VERILATOR_FOLDER)/top.cpp $(TARGET_VERILOG_FOLDER)/top.sv
		$(VERILATOR) -cc --exe -trace --build -j 0 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module top $(TARGET_VERILATOR_FOLDER)/top.cpp $(TARGET_VERILOG_FOLDER)/top.sv

toptrace.vcd: top obj_dir/Vtop
	obj_dir/Vtop

view: toptrace.vcd
	gtkwave toptrace.vcd

.PHONY: clean
clean:
	rm -rf obj_dir/ top toptrace.vcd
