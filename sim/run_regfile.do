vlib work
vlog rtl/regfile.v tb/tb_regfile.v
vsim tb_regfile
add wave -radix hex /tb_regfile/*
run -all
