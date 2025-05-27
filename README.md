# pipelined_CPU
This project is a 5-stage pipelined CPU with forwarding and hazard detection. The CPU is based on the LEGv8 ISA, a subset of the ARM ISA.

## Instructions
The CPU is capable of running `addi, adds, b, b.lt, br, bl, cbz, ldur, stur, subs`.

## Benchmarks
Included in the /benchmarks folder are two sample assembly programs designed to run on the CPU, bubble sort and recursive fibonacci. Credit to the UW CSE 469 teaching team for the development of these benchmarks.

## Assumptions
This CPU assumes that all branch and load instructions are followed by a NOP (`ADDI X31, X31, #0`). 

## Running, Testing, Debugging
Once the source files are downloaded, open the modelsim executable. Into the console type `do runlab.do`. To change which benchmark is run, open `scstim.sv` and uncomment/comment the appropriate sections according to the comments in the file, then open `instructmem.sv` and change which benchmark is included.
