// RV32G/RV64G Base Instruction Defines
// This is a merge of [6:5][4:2] of the full length instruction
// First two bits indicate instruction type
`define LOAD        5'b00000
`define LOAD_FP     5'b00001
`define CUSTOM_0    5'b00010
`define MISC_MEM    5'b00011
`define OP_IMM      5'b00100
`define AUIPC       5'b00101
`define OP_IMM_32   5'b00110
`define STORE       5'b01000
`define STORE_FP    5'b01001
`define CUSTOM_1    5'b01010
`define AMO         5'b01011
`define OP          5'b01100
`define LUI         5'b01101
`define OP_32       5'b01110
`define MADD        5'b10000
`define MSUB        5'b10001
`define NMSUB       5'b10010
`define NMADD       5'b10011
`define OP_FP       5'b10100
`define RESERVED_1  5'b10101
`define CUSTOM_2    5'b10110
`define BRANCH      5'b11000
`define JALR        5'b11001
`define RESERVED_2  5'b11010
`define JAL         5'b11011
`define SYSTEM      5'b11100
`define RESERVED_3  5'b11101
`define CUSTOM_3    5'b11110