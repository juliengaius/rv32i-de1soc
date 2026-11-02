# RV32I RISC-V Processor on the DE1-SoC

A 32-bit RISC-V (RV32I) processor written from scratch in Verilog, targeting the Intel Cyclone V FPGA on the Terasic DE1-SoC board. The core is being built as a multi-cycle design (a control FSM driving a datapath) and will connect through memory-mapped I/O to a VGA display and PS/2 keyboard, so it can run a small game compiled for it with the RISC-V GCC toolchain.

Built for ECE241 (Digital Systems) at the University of Toronto, Fall 2026. **Work in progress:** the repo is updated as each module is completed and verified.

## Status

| Module | File | What it does | Verified |
| --- | --- | --- | --- |
| ALU | `rtl/alu.v` | All 10 RV32I operations: add, sub, and, or, xor, sll, srl, sra, slt, sltu | 15 self-checking tests, 0 errors |
| Register file | `rtl/regfile.v` | 32 × 32-bit registers, 2 combinational read ports, 1 synchronous write port, x0 hard-wired to zero | 35 self-checking tests, 0 errors |
| Immediate generator | `rtl/immgen.v` | Extracts and sign-extends the immediate for all five formats (I, S, B, U, J) | 14 hand-encoded instructions, 0 errors |
| Decoder | | Instruction-type flags and ALU operation select | In progress |
| Branch comparator | | beq, bne, blt, bge, bltu, bgeu | Planned |
| Control FSM + datapath | | Multi-cycle fetch / decode / execute / memory / writeback | Planned |
| Load/store alignment | | Byte and halfword loads/stores with sign/zero extension | Planned |
| VGA, PS/2, memory-mapped I/O | | Peripherals for the demo game | Planned |

## Verification

Every module gets a self-checking testbench before it is integrated. Each testbench drives the inputs, compares every output against an expected value, and prints PASS/FAIL with a final error count; nothing relies on reading waveforms by eye.

Test cases target the places these modules usually break:

- **ALU:** signed vs. unsigned comparison (`0xFFFFFFFF < 1` is true for SLT, false for SLTU), arithmetic vs. logical right shift (`0x80000000 >>> 4` must sign-fill), shift amounts of 0, 31 and 32 (only `b[4:0]` counts), and an unused opcode falling through to the default case.
- **Register file:** writes to x0 are ignored and x0 always reads 0, no write happens while write-enable is low, overwrites, and all 31 writable registers filled with distinct patterns and read back to prove addressing.
- **Immediate generator:** real RV32I instructions encoded by hand, including negative offsets in every format and cases that isolate each scrambled B-type and J-type bit field (for example `beq … 2048`, which only sets the bit stored in `instr[7]`).

Tests were run in ModelSim (Intel FPGA Starter Edition) during development and also pass under Icarus Verilog.

## Running the tests

**ModelSim**, from the repo root:

```
do sim/run_alu.do
do sim/run_regfile.do
do sim/run_immgen.do
```

**Icarus Verilog** (free, any OS):

```
./sim/run_all.sh
```

## Repository layout

```
rtl/       synthesizable Verilog (plain Verilog-2001)
tb/        self-checking testbenches
sim/       ModelSim .do scripts and an Icarus runner
quartus/   Quartus Prime Lite 18.1 project files (device 5CSEMA5F31C6)
```

## Tools

Quartus Prime Lite 18.1, ModelSim – Intel FPGA Starter Edition, Icarus Verilog. Target board: Terasic DE1-SoC (Cyclone V 5CSEMA5F31C6).

## Roadmap

1. Decoder and branch comparator
2. Multi-cycle control FSM and datapath; run test programs from block RAM, results on the HEX displays
3. Memory-mapped VGA framebuffer and PS/2 keyboard
4. A small game compiled with `riscv32-unknown-elf-gcc`, running on the core
5. Later: 5-stage pipeline, M extension, and a UVM-based verification environment

## References

- [The RISC-V Instruction Set Manual, Volume I: Unprivileged ISA](https://riscv.org/technical/specifications/)
