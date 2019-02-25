// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Fri Aug 31 18:37:42 2018
// Host        : lap-laptop-3 running 64-bit Ubuntu 18.04.1 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/asiatici/epfl/memory-coalescer/vivado/spmv/spmv-hls/RTLFullyPipelinedSpMV/RTLFullyPipelinedSpMV.srcs/sources_1/ip/len_stream_0/len_stream_0_stub.v
// Design      : len_stream_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "len_stream,Vivado 2017.4" *)
module len_stream_0(output_size_loopback_ap_vld, 
  offset_loopback_ap_vld, s_axi_AXILiteS_AWADDR, s_axi_AXILiteS_AWVALID, 
  s_axi_AXILiteS_AWREADY, s_axi_AXILiteS_WDATA, s_axi_AXILiteS_WSTRB, 
  s_axi_AXILiteS_WVALID, s_axi_AXILiteS_WREADY, s_axi_AXILiteS_BRESP, 
  s_axi_AXILiteS_BVALID, s_axi_AXILiteS_BREADY, s_axi_AXILiteS_ARADDR, 
  s_axi_AXILiteS_ARVALID, s_axi_AXILiteS_ARREADY, s_axi_AXILiteS_RDATA, 
  s_axi_AXILiteS_RRESP, s_axi_AXILiteS_RVALID, s_axi_AXILiteS_RREADY, ap_clk, ap_rst_n, 
  interrupt, output_size_loopback, offset_loopback, rowptr_stream_TVALID, 
  rowptr_stream_TREADY, rowptr_stream_TDATA, rowptr_stream_TKEEP, rowptr_stream_TLAST, 
  output_stream_V_TVALID, output_stream_V_TREADY, output_stream_V_TDATA)
/* synthesis syn_black_box black_box_pad_pin="output_size_loopback_ap_vld,offset_loopback_ap_vld,s_axi_AXILiteS_AWADDR[5:0],s_axi_AXILiteS_AWVALID,s_axi_AXILiteS_AWREADY,s_axi_AXILiteS_WDATA[31:0],s_axi_AXILiteS_WSTRB[3:0],s_axi_AXILiteS_WVALID,s_axi_AXILiteS_WREADY,s_axi_AXILiteS_BRESP[1:0],s_axi_AXILiteS_BVALID,s_axi_AXILiteS_BREADY,s_axi_AXILiteS_ARADDR[5:0],s_axi_AXILiteS_ARVALID,s_axi_AXILiteS_ARREADY,s_axi_AXILiteS_RDATA[31:0],s_axi_AXILiteS_RRESP[1:0],s_axi_AXILiteS_RVALID,s_axi_AXILiteS_RREADY,ap_clk,ap_rst_n,interrupt,output_size_loopback[31:0],offset_loopback[31:0],rowptr_stream_TVALID,rowptr_stream_TREADY,rowptr_stream_TDATA[31:0],rowptr_stream_TKEEP[3:0],rowptr_stream_TLAST[0:0],output_stream_V_TVALID,output_stream_V_TREADY,output_stream_V_TDATA[31:0]" */;
  output output_size_loopback_ap_vld;
  output offset_loopback_ap_vld;
  input [5:0]s_axi_AXILiteS_AWADDR;
  input s_axi_AXILiteS_AWVALID;
  output s_axi_AXILiteS_AWREADY;
  input [31:0]s_axi_AXILiteS_WDATA;
  input [3:0]s_axi_AXILiteS_WSTRB;
  input s_axi_AXILiteS_WVALID;
  output s_axi_AXILiteS_WREADY;
  output [1:0]s_axi_AXILiteS_BRESP;
  output s_axi_AXILiteS_BVALID;
  input s_axi_AXILiteS_BREADY;
  input [5:0]s_axi_AXILiteS_ARADDR;
  input s_axi_AXILiteS_ARVALID;
  output s_axi_AXILiteS_ARREADY;
  output [31:0]s_axi_AXILiteS_RDATA;
  output [1:0]s_axi_AXILiteS_RRESP;
  output s_axi_AXILiteS_RVALID;
  input s_axi_AXILiteS_RREADY;
  input ap_clk;
  input ap_rst_n;
  output interrupt;
  output [31:0]output_size_loopback;
  output [31:0]offset_loopback;
  input rowptr_stream_TVALID;
  output rowptr_stream_TREADY;
  input [31:0]rowptr_stream_TDATA;
  input [3:0]rowptr_stream_TKEEP;
  input [0:0]rowptr_stream_TLAST;
  output output_stream_V_TVALID;
  input output_stream_V_TREADY;
  output [31:0]output_stream_V_TDATA;
endmodule
