vlib work
vlog rtl/alu.v tb/tb_alu.v
vsim tb_alu
add wave -radix hex /tb_alu/*
run -all
