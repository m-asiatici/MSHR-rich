vlib work
vlib riviera

vlib riviera/xbip_utils_v3_0_8
vlib riviera/axi_utils_v2_0_4
vlib riviera/xbip_pipe_v3_0_4
vlib riviera/xbip_dsp48_wrapper_v3_0_4
vlib riviera/xbip_dsp48_addsub_v3_0_4
vlib riviera/xbip_dsp48_multadd_v3_0_4
vlib riviera/xbip_bram18k_v3_0_4
vlib riviera/mult_gen_v12_0_13
vlib riviera/floating_point_v7_1_5
vlib riviera/xil_defaultlib

vmap xbip_utils_v3_0_8 riviera/xbip_utils_v3_0_8
vmap axi_utils_v2_0_4 riviera/axi_utils_v2_0_4
vmap xbip_pipe_v3_0_4 riviera/xbip_pipe_v3_0_4
vmap xbip_dsp48_wrapper_v3_0_4 riviera/xbip_dsp48_wrapper_v3_0_4
vmap xbip_dsp48_addsub_v3_0_4 riviera/xbip_dsp48_addsub_v3_0_4
vmap xbip_dsp48_multadd_v3_0_4 riviera/xbip_dsp48_multadd_v3_0_4
vmap xbip_bram18k_v3_0_4 riviera/xbip_bram18k_v3_0_4
vmap mult_gen_v12_0_13 riviera/mult_gen_v12_0_13
vmap floating_point_v7_1_5 riviera/floating_point_v7_1_5
vmap xil_defaultlib riviera/xil_defaultlib

vcom -work xbip_utils_v3_0_8 -93 \
"../../../ipstatic/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_4 -93 \
"../../../ipstatic/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_multadd_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_dsp48_multadd_v3_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_4 -93 \
"../../../ipstatic/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_13 -93 \
"../../../ipstatic/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_5 -93 \
"../../../ipstatic/hdl/floating_point_v7_1_vh_rfs.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/drivers/spmv_mult_axis_v1_0/src" "+incdir+../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/drivers/spmv_mult_axis_v1_0/src" \
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

vcom -work xil_defaultlib -93 \
"../../../ipstatic/hdl/ip/spmv_mult_axis_ap_fmul_3_max_dsp_32.vhd" \
"../../../../TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/sim/spmv_mult_axis_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

