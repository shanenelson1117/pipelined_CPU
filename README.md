# pipelined_CPU
This project is a 5-stage pipelined CPU with forwarding and hazard detection. The CPU is based on the LEGv8 ISA, a subset of the ARM ISA. The CPU does not need delay slots in the compiled programs it runs (although they are included in the benchmarks), and predicts branch not taken. All branch operations have a branch penalty of 1 cycle if the branch is taken. 

## Instructions
The CPU is capable of running `addi, adds, b, b.lt, br, bl, cbz, ldur, stur, subs`.

## Benchmarks
Included in the /benchmarks folder are two sample assembly programs designed to run on the CPU, bubble sort and recursive fibonacci. Credit to the UW CSE 469 teaching team for the development of these benchmarks.


