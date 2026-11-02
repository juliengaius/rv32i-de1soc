vlib work
vlog rtl/immgen.v tb/tb_immgen.v
vsim tb_immgen
add wave -radix hex /tb_immgen/*
run -all
