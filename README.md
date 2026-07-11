Complete Single-Cycle RISC-V (RV32I) CPU Core
--------------------------------------------
This repository contains a complete, synthesizable, single-cycle implementation of a 32-bit RISC-V (RV32I) processor core written from scratch in Verilog HDL.
The primary architecture goal of this iteration was transitioning from a Partial RV32I core to a Complete Base Integer RV32I design by closing major execution coverage gaps. This includes incorporating immediate shifting mechanics and unsigned/signed set-less-than evaluation architectures.

Architecture Highlights
----------------------
Single-Cycle Datapath:Executes exactly one instruction per clock cycle, maximizing clock execution clarity.
Full Base ISA Support: Full functional coverage for standard base RISC-V software binaries compiled directly from C or assembly environments.
Hazard-Free Execution: Bypasses pipelined stalling complexities, relying on a purely combinational decoding bus matched with edge-triggered registers.
Deterministic Registers: Features hardwired zero handling on register x0 and full initialization matrices for error-free simulation baselines.

Complete Instruction Set Coverage
--------------------------------
The processor fully decodes and handles instructions across the foundational five ISA formats: R-Type, I-Type, S-Type, B-Type, U-Type, and J-Type.
<img width="1402" height="292" alt="image" src="https://github.com/user-attachments/assets/7d23837e-a796-4101-98b0-e46d00402fd5" />

Architectural Enhancements
-------------------------
1. Immediate Shift Datapath Pipeline (SLLI, SRLI, SRAI)
2. Dual-Register Comparison Subsystems (SLT, SLTU)
3. Synthesis Safety Defaulting

<img width="1572" height="812" alt="image" src="https://github.com/user-attachments/assets/c2d506ca-57af-46b8-825f-599cd566f807" />

