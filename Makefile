PROJ = fetchie

PIN_DEF = icebreaker.pcf
DEVICE = up5k
PACKAGE = sg48

BUILD_DIR = ./build

VERILATOR=verilator
VERILATOR_ROOT ?= $(shell bash -c 'verilator -V|grep VERILATOR_ROOT | head -1 | sed -e "s/^.*=\s*//"')
VINC := $(VERILATOR_ROOT)/include
TARGET_VERILOG_FOLDER=./verilog
TARGET_VERILOG_TB_FOLDER=./verilog_tb
TARGET_VERILATOR_FOLDER=./verilator_testbench

######################################
# source
######################################
# CXX sources
CXX_SOURCES =  \
$(TARGET_VERILATOR_FOLDER)/top.cpp \
$(TARGET_VERILATOR_FOLDER)/uart_emu.cpp \

.PHONY: all
all: toptrace.vcd ice40_bin

# Ideally, we'd want -GWIDTH=12
# This requires a newer version of Verilator than I have with my distro
# Hence we have the `ifdef inside gpu.v
top_verilator: $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/top.sv
		$(VERILATOR) -cc --exe -trace --build -j 12 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module top $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/top.sv

queue_tb: $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/queue.sv
		$(VERILATOR) -cc --exe -trace --build -j 12 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module queue_tb $(TARGET_VERILATOR_FOLDER)/queue_tb.cpp $(TARGET_VERILOG_FOLDER)/queue.sv $(TARGET_VERILOG_TB_FOLDER)/queue_tb.sv

registers_tb: $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/registers.sv
		$(VERILATOR) -cc --exe -trace --build -j 12 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module registers_tb $(TARGET_VERILATOR_FOLDER)/registers_tb.cpp $(TARGET_VERILOG_FOLDER)/registers.sv $(TARGET_VERILOG_TB_FOLDER)/registers_tb.sv

fetch_tb: $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/fetch.sv
		$(VERILATOR) -cc --exe -trace --build -j 12 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module fetch_tb $(TARGET_VERILATOR_FOLDER)/fetch_tb.cpp $(TARGET_VERILOG_FOLDER)/fetch.sv $(TARGET_VERILOG_TB_FOLDER)/fetch_tb.sv

decode_tb: $(CXX_SOURCES) $(TARGET_VERILOG_FOLDER)/decode.sv
		$(VERILATOR) -cc --exe -trace --build -j 12 -Wall -I"$(TARGET_VERILOG_FOLDER)" --top-module decode_tb $(TARGET_VERILATOR_FOLDER)/decode_tb.cpp $(TARGET_VERILOG_FOLDER)/decode.sv $(TARGET_VERILOG_TB_FOLDER)/decode_tb.sv

toptrace.vcd: top_verilator obj_dir/Vtop
	obj_dir/Vtop

view: toptrace.vcd
	gtkwave toptrace.vcd

V_FILES := $(wildcard $(TARGET_VERILOG_FOLDER)/*.v)
SV_FILES := $(wildcard $(TARGET_VERILOG_FOLDER)/*.sv)

V_SV_FILES := $(V_FILES) $(SV_FILES)

# For Yosys
$(BUILD_DIR)/$(PROJ)_$(DEVICE).json: $(BUILD_DIR)
	yosys -DYOSYS -p 'synth_ice40 -top top -json $@' $(V_SV_FILES)

$(BUILD_DIR)/$(PROJ)_$(DEVICE).asc: $(PIN_DEF) $(BUILD_DIR)/$(PROJ)_$(DEVICE).json | $(BUILD_DIR)
		nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --top top --asc $@ --pcf $< --json $(BUILD_DIR)/$(PROJ)_$(DEVICE).json

$(BUILD_DIR)/%.bin: $(BUILD_DIR)/$(PROJ)_$(DEVICE).asc $(BUILD_DIR)
	icepack $< $@

$(BUILD_DIR)/$(PROJ)_$(DEVICE).rpt: $(BUILD_DIR)/$(PROJ)_$(DEVICE).asc $(BUILD_DIR)
	icetime -d $(DEVICE) -mtr $@ $<

ice40_bin: $(BUILD_DIR)/$(PROJ)_$(DEVICE).rpt $(BUILD_DIR)/$(PROJ)_$(DEVICE).bin $(BUILD_DIR)

ice40_prog: $(BUILD_DIR)/$(PROJ)_$(DEVICE).bin $(BUILD_DIR)
	iceprog $<

$(BUILD_DIR):
	mkdir "$@"

# Generics
.PHONY: clean
clean:
	rm -rf obj_dir/ build/ top toptrace.vcd
