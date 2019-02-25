vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib -64 "+incdir+../../../../RTLFullyPipelinedSpMV.srcs/sources_1/ip/len_stream_0/drivers/len_stream_v1_0/src" "+incdir+../../../../RTLFullyPipelinedSpMV.srcs/sources_1/ip/len_stream_0/drivers/len_stream_v1_0/src" \
"../../../ipstatic/hdl/verilog/len_stream_AXILiteS_s_axi.v" \
"../../../ipstatic/hdl/verilog/Loop_1_proc.v" \
"../../../ipstatic/hdl/verilog/len_stream.v" \
"../../../ipstatic/hdl/verilog/Block_proc.v" \
"../../../ipstatic/hdl/verilog/fifo_w32_d2_A.v" \
"../../../../RTLFullyPipelinedSpMV.srcs/sources_1/ip/len_stream_0/sim/len_stream_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

