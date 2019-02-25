vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../TopLevel.srcs/sources_1/ip/floating_point_0_1/floating_point_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

