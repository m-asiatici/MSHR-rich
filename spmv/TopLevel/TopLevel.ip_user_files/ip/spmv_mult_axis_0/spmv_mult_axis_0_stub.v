// Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
// Date        : Wed Jul  4 10:36:28 2018
// Host        : lap-laptop-3 running 64-bit Ubuntu 18.04 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/asiatici/epfl/memory-coalescer/vivado/spmv/spmv-hls/TopLevel/TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/spmv_mult_axis_0_stub.v
// Design      : spmv_mult_axis_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "spmv_mult_axis,Vivado 2017.4" *)
module spmv_mult_axis_0(output_size_loopback_ap_vld, 
  s_axi_AXILiteS_AWADDR, s_axi_AXILiteS_AWVALID, s_axi_AXILiteS_AWREADY, 
  s_axi_AXILiteS_WDATA, s_axi_AXILiteS_WSTRB, s_axi_AXILiteS_WVALID, 
  s_axi_AXILiteS_WREADY, s_axi_AXILiteS_BRESP, s_axi_AXILiteS_BVALID, 
  s_axi_AXILiteS_BREADY, s_axi_AXILiteS_ARADDR, s_axi_AXILiteS_ARVALID, 
  s_axi_AXILiteS_ARREADY, s_axi_AXILiteS_RDATA, s_axi_AXILiteS_RRESP, 
  s_axi_AXILiteS_RVALID, s_axi_AXILiteS_RREADY, ap_clk, ap_rst_n, interrupt, 
  m_axi_vect_AWADDR, m_axi_vect_AWLEN, m_axi_vect_AWSIZE, m_axi_vect_AWBURST, 
  m_axi_vect_AWLOCK, m_axi_vect_AWREGION, m_axi_vect_AWCACHE, m_axi_vect_AWPROT, 
  m_axi_vect_AWQOS, m_axi_vect_AWVALID, m_axi_vect_AWREADY, m_axi_vect_WDATA, 
  m_axi_vect_WSTRB, m_axi_vect_WLAST, m_axi_vect_WVALID, m_axi_vect_WREADY, 
  m_axi_vect_BRESP, m_axi_vect_BVALID, m_axi_vect_BREADY, m_axi_vect_ARADDR, 
  m_axi_vect_ARLEN, m_axi_vect_ARSIZE, m_axi_vect_ARBURST, m_axi_vect_ARLOCK, 
  m_axi_vect_ARREGION, m_axi_vect_ARCACHE, m_axi_vect_ARPROT, m_axi_vect_ARQOS, 
  m_axi_vect_ARVALID, m_axi_vect_ARREADY, m_axi_vect_RDATA, m_axi_vect_RRESP, 
  m_axi_vect_RLAST, m_axi_vect_RVALID, m_axi_vect_RREADY, val_col_ind_stream_TVALID, 
  val_col_ind_stream_TREADY, val_col_ind_stream_TDATA, val_col_ind_stream_TKEEP, 
  val_col_ind_stream_TLAST, rowptr_stream_TVALID, rowptr_stream_TREADY, 
  rowptr_stream_TDATA, rowptr_stream_TKEEP, rowptr_stream_TLAST, output_stream_V_TVALID, 
  output_stream_V_TREADY, output_stream_V_TDATA, row_size_stream_V_TVALID, 
  row_size_stream_V_TREADY, row_size_stream_V_TDATA, output_size_loopback)
/* synthesis syn_black_box black_box_pad_pin="output_size_loopback_ap_vld,s_axi_AXILiteS_AWADDR[5:0],s_axi_AXILiteS_AWVALID,s_axi_AXILiteS_AWREADY,s_axi_AXILiteS_WDATA[31:0],s_axi_AXILiteS_WSTRB[3:0],s_axi_AXILiteS_WVALID,s_axi_AXILiteS_WREADY,s_axi_AXILiteS_BRESP[1:0],s_axi_AXILiteS_BVALID,s_axi_AXILiteS_BREADY,s_axi_AXILiteS_ARADDR[5:0],s_axi_AXILiteS_ARVALID,s_axi_AXILiteS_ARREADY,s_axi_AXILiteS_RDATA[31:0],s_axi_AXILiteS_RRESP[1:0],s_axi_AXILiteS_RVALID,s_axi_AXILiteS_RREADY,ap_clk,ap_rst_n,interrupt,m_axi_vect_AWADDR[31:0],m_axi_vect_AWLEN[7:0],m_axi_vect_AWSIZE[2:0],m_axi_vect_AWBURST[1:0],m_axi_vect_AWLOCK[1:0],m_axi_vect_AWREGION[3:0],m_axi_vect_AWCACHE[3:0],m_axi_vect_AWPROT[2:0],m_axi_vect_AWQOS[3:0],m_axi_vect_AWVALID,m_axi_vect_AWREADY,m_axi_vect_WDATA[31:0],m_axi_vect_WSTRB[3:0],m_axi_vect_WLAST,m_axi_vect_WVALID,m_axi_vect_WREADY,m_axi_vect_BRESP[1:0],m_axi_vect_BVALID,m_axi_vect_BREADY,m_axi_vect_ARADDR[31:0],m_axi_vect_ARLEN[7:0],m_axi_vect_ARSIZE[2:0],m_axi_vect_ARBURST[1:0],m_axi_vect_ARLOCK[1:0],m_axi_vect_ARREGION[3:0],m_axi_vect_ARCACHE[3:0],m_axi_vect_ARPROT[2:0],m_axi_vect_ARQOS[3:0],m_axi_vect_ARVALID,m_axi_vect_ARREADY,m_axi_vect_RDATA[31:0],m_axi_vect_RRESP[1:0],m_axi_vect_RLAST,m_axi_vect_RVALID,m_axi_vect_RREADY,val_col_ind_stream_TVALID,val_col_ind_stream_TREADY,val_col_ind_stream_TDATA[63:0],val_col_ind_stream_TKEEP[3:0],val_col_ind_stream_TLAST[0:0],rowptr_stream_TVALID,rowptr_stream_TREADY,rowptr_stream_TDATA[31:0],rowptr_stream_TKEEP[3:0],rowptr_stream_TLAST[0:0],output_stream_V_TVALID,output_stream_V_TREADY,output_stream_V_TDATA[31:0],row_size_stream_V_TVALID,row_size_stream_V_TREADY,row_size_stream_V_TDATA[31:0],output_size_loopback[31:0]" */;
  output output_size_loopback_ap_vld;
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
  output [31:0]m_axi_vect_AWADDR;
  output [7:0]m_axi_vect_AWLEN;
  output [2:0]m_axi_vect_AWSIZE;
  output [1:0]m_axi_vect_AWBURST;
  output [1:0]m_axi_vect_AWLOCK;
  output [3:0]m_axi_vect_AWREGION;
  output [3:0]m_axi_vect_AWCACHE;
  output [2:0]m_axi_vect_AWPROT;
  output [3:0]m_axi_vect_AWQOS;
  output m_axi_vect_AWVALID;
  input m_axi_vect_AWREADY;
  output [31:0]m_axi_vect_WDATA;
  output [3:0]m_axi_vect_WSTRB;
  output m_axi_vect_WLAST;
  output m_axi_vect_WVALID;
  input m_axi_vect_WREADY;
  input [1:0]m_axi_vect_BRESP;
  input m_axi_vect_BVALID;
  output m_axi_vect_BREADY;
  output [31:0]m_axi_vect_ARADDR;
  output [7:0]m_axi_vect_ARLEN;
  output [2:0]m_axi_vect_ARSIZE;
  output [1:0]m_axi_vect_ARBURST;
  output [1:0]m_axi_vect_ARLOCK;
  output [3:0]m_axi_vect_ARREGION;
  output [3:0]m_axi_vect_ARCACHE;
  output [2:0]m_axi_vect_ARPROT;
  output [3:0]m_axi_vect_ARQOS;
  output m_axi_vect_ARVALID;
  input m_axi_vect_ARREADY;
  input [31:0]m_axi_vect_RDATA;
  input [1:0]m_axi_vect_RRESP;
  input m_axi_vect_RLAST;
  input m_axi_vect_RVALID;
  output m_axi_vect_RREADY;
  input val_col_ind_stream_TVALID;
  output val_col_ind_stream_TREADY;
  input [63:0]val_col_ind_stream_TDATA;
  input [3:0]val_col_ind_stream_TKEEP;
  input [0:0]val_col_ind_stream_TLAST;
  input rowptr_stream_TVALID;
  output rowptr_stream_TREADY;
  input [31:0]rowptr_stream_TDATA;
  input [3:0]rowptr_stream_TKEEP;
  input [0:0]rowptr_stream_TLAST;
  output output_stream_V_TVALID;
  input output_stream_V_TREADY;
  output [31:0]output_stream_V_TDATA;
  output row_size_stream_V_TVALID;
  input row_size_stream_V_TREADY;
  output [31:0]row_size_stream_V_TDATA;
  output [31:0]output_size_loopback;
endmodule
