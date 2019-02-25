vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 -incr \
"../../../../TopLevel.srcs/sources_1/ip/floating_point_0_1/floating_point_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

