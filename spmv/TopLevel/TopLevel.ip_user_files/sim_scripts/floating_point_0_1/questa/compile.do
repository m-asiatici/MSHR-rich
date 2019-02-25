vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 \
"../../../../TopLevel.srcs/sources_1/ip/floating_point_0_1/floating_point_0_sim_netlist.v" \


vlog -work xil_defaultlib \
"glbl.v"

