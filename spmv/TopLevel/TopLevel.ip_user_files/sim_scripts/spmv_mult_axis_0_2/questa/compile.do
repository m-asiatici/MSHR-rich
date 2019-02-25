vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xbip_utils_v3_0_8
vlib questa_lib/msim/axi_utils_v2_0_4
vlib questa_lib/msim/xbip_pipe_v3_0_4
vlib questa_lib/msim/xbip_dsp48_wrapper_v3_0_4
vlib questa_lib/msim/xbip_dsp48_addsub_v3_0_4
vlib questa_lib/msim/xbip_dsp48_multadd_v3_0_4
vlib questa_lib/msim/xbip_bram18k_v3_0_4
vlib questa_lib/msim/mult_gen_v12_0_13
vlib questa_lib/msim/floating_point_v7_1_5
vlib questa_lib/msim/xil_defaultlib

vmap xbip_utils_v3_0_8 questa_lib/msim/xbip_utils_v3_0_8
vmap axi_utils_v2_0_4 questa_lib/msim/axi_utils_v2_0_4
vmap xbip_pipe_v3_0_4 questa_lib/msim/xbip_pipe_v3_0_4
vmap xbip_dsp48_wrapper_v3_0_4 questa_lib/msim/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_4 questa_lib/msim/xbip_dsp48_addsub_v3_0_4
vmap xbip_dsp48_multadd_v3_0_4 questa_lib/msim/xbip_dsp48_multadd_v3_0_4
vmap xbip_bram18k_v3_0_4 questa_lib/msim/xbip_bram18k_v3_0_4
vmap mult_gen_v12_0_13 questa_lib/msim/mult_gen_v12_0_13
vmap floating_point_v7_1_5 questa_lib/msim/floating_point_v7_1_5
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work xbip_utils_v3_0_8 -64 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_4 -64 -93 \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_4 -64 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -64 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_4 -64 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_4 -64 -93 \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_4 -64 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_13 -64 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_5 -64 -93 \
"../../../ipstatic/hdl/floating_point_v7_1_vh_rfs.vhd" \

vlog -work xil_defaultlib -64 "+incdir+../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/drivers/spmv_mult_axis_v1_0/src" "+incdir+../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/drivers/spmv_mult_axis_v1_0/src" \
"../../../ipstatic/hdl/verilog/spmv_mult_axis_AXILiteS_s_axi.v" \
"../../../ipstatic/hdl/verilog/start_for_Loop_4_dEe.v" \
"../../../ipstatic/hdl/verilog/spmv_mult_axis.v" \
"../../../ipstatic/hdl/verilog/Loop_1_proc18.v" \
"../../../ipstatic/hdl/verilog/spmv_mult_axis_entry.v" \
"../../../ipstatic/hdl/verilog/Block_proc.v" \
"../../../ipstatic/hdl/verilog/spmv_mult_axis_fmbkb.v" \
"../../../ipstatic/hdl/verilog/fifo_w32_d2_A.v" \
"../../../ipstatic/hdl/verilog/fifo_w32_d1_A.v" \
"../../../ipstatic/hdl/verilog/start_for_Block_pcud.v" \
"../../../ipstatic/hdl/verilog/Loop_3_proc20.v" \
"../../../ipstatic/hdl/verilog/Loop_2_proc19.v" \
"../../../ipstatic/hdl/verilog/Loop_4_proc21.v" \
"../../../ipstatic/hdl/verilog/spmv_mult_axis_vect_m_axi.v" \

vcom -work xil_defaultlib -64 -93 \
"../../../ipstatic/hdl/ip/spmv_mult_axis_ap_fmul_3_max_dsp_32.vhd" \
"../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/sim/spmv_mult_axis_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

