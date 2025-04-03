cmake_minimum_required(VERSION 3.10)
project(fetchie)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Set build directory
set(BUILD_DIR ${CMAKE_BINARY_DIR}/build)
file(MAKE_DIRECTORY ${BUILD_DIR})

# Define paths
set(TARGET_VERILOG_FOLDER ${CMAKE_SOURCE_DIR}/verilog)
set(TARGET_VERILOG_TB_FOLDER ${CMAKE_SOURCE_DIR}/verilog_tb)
set(TARGET_VERILATOR_FOLDER ${CMAKE_SOURCE_DIR}/verilator_testbench)

# Verilator settings
set(VERILATOR_ROOT /usr/share/verilator)
set(VINC ${VERILATOR_ROOT}/include)

message(STATUS "Verilator root: ${VERILATOR_ROOT}")

set(VERILATOR_FLAGS "-cc --exe -trace --build -j 12 -Wall")

message(STATUS "Building with: ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS}")

# Source files
set(CXX_SOURCES
    ${TARGET_VERILATOR_FOLDER}/top.cpp
    ${TARGET_VERILATOR_FOLDER}/uart_emu.cpp
)

add_executable(fetchie
    ${CXX_SOURCES}
    ${TARGET_VERILOG_FOLDER}/top.sv
)

# Add custom targets
add_custom_target(top_verilator
    COMMAND ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS} -I"${TARGET_VERILOG_FOLDER}" --top-module top ${CXX_SOURCES} ${TARGET_VERILOG_FOLDER}/top.sv
)

add_custom_target(queue_tb
    COMMAND ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS} -I"${TARGET_VERILOG_FOLDER}" --top-module queue_tb
            ${TARGET_VERILATOR_FOLDER}/queue_tb.cpp ${TARGET_VERILOG_FOLDER}/queue.sv ${TARGET_VERILOG_TB_FOLDER}/queue_tb.sv
)

add_custom_target(registers_tb
    COMMAND ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS} -I"${TARGET_VERILOG_FOLDER}" --top-module registers_tb
            ${TARGET_VERILATOR_FOLDER}/registers_tb.cpp ${TARGET_VERILOG_FOLDER}/registers.sv ${TARGET_VERILOG_TB_FOLDER}/registers_tb.sv
)

add_custom_target(fetch_tb
    COMMAND ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS} -I"${TARGET_VERILOG_FOLDER}" --top-module fetch_tb
            ${TARGET_VERILATOR_FOLDER}/fetch_tb.cpp ${TARGET_VERILOG_FOLDER}/fetch.sv ${TARGET_VERILOG_TB_FOLDER}/fetch_tb.sv
)

add_custom_target(decode_tb
    COMMAND ${VERILATOR_EXECUTABLE} ${VERILATOR_FLAGS} -I"${TARGET_VERILOG_FOLDER}" --top-module decode_tb
            ${TARGET_VERILATOR_FOLDER}/decode_tb.cpp ${TARGET_VERILOG_FOLDER}/decode.sv ${TARGET_VERILOG_TB_FOLDER}/decode_tb.sv
)

# Yosys synthesis
file(GLOB V_FILES ${TARGET_VERILOG_FOLDER}/*.v)
file(GLOB SV_FILES ${TARGET_VERILOG_FOLDER}/*.sv)
set(V_SV_FILES ${V_FILES} ${SV_FILES})

add_custom_target(yosys_synthesis
    COMMAND yosys -DYOSYS -p "synth_ice40 -top top -json ${BUILD_DIR}/${PROJECT_NAME}_up5k.json" ${V_SV_FILES}
)

add_custom_target(nextpnr
    COMMAND nextpnr-ice40 --up5k --package sg48 --top top --asc ${BUILD_DIR}/${PROJECT_NAME}_up5k.asc --pcf icebreaker.pcf --json ${BUILD_DIR}/${PROJECT_NAME}_up5k.json
)

add_custom_target(icepack
    COMMAND icepack ${BUILD_DIR}/${PROJECT_NAME}_up5k.asc ${BUILD_DIR}/${PROJECT_NAME}_up5k.bin
)

add_custom_target(icetime
    COMMAND icetime -d up5k -mtr ${BUILD_DIR}/${PROJECT_NAME}_up5k.rpt ${BUILD_DIR}/${PROJECT_NAME}_up5k.asc
)

add_custom_target(ice40_bin DEPENDS yosys_synthesis nextpnr icepack icetime)

add_custom_target(ice40_prog
    COMMAND iceprog ${BUILD_DIR}/${PROJECT_NAME}_up5k.bin
)