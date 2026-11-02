#!/usr/bin/env bash
# Runs every unit testbench with Icarus Verilog (free alternative to ModelSim).
# Usage: ./sim/run_all.sh   (from the repo root)
set -e
mkdir -p build
for m in alu regfile immgen; do
  iverilog -o build/$m.vvp rtl/$m.v tb/tb_$m.v
  printf '%-8s ' "$m"; vvp -n build/$m.vvp | grep -E "Done|FAIL"
done
