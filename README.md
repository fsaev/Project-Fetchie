# Project-Fetchie
Small 3-stage superscalar RV32I CPU. 

**As of now this is nothing more than a personal pet project. 
I'm learning as I go, so things might not be right, convensional, clear or efficient to begin with.**

Progress (Checkmark means I have something working, not that it's done):
* Registers ✅
* I-Cache ✅
* Fetch ✅
* Decode
* Execute
* D-Cache
* Microcode + Compiler

Future extensions:
* Two-level branch prediction
* Debug interface
* Instruction merging (e.g. LUI + ADDI)
* RV32M instructions for multiplication and division
* RV32C instructions for compressed instructions
* RV32E variant of Fetchie for embedded applications
