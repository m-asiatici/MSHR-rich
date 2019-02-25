// (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:hls:spmv_mult_axis:1.0
// IP Revision: 1807032102

(* X_CORE_INFO = "spmv_mult_axis,Vivado 2017.4" *)
(* CHECK_LICENSE_TYPE = "spmv_mult_axis_0,spmv_mult_axis,{}" *)
(* CORE_GENERATION_INFO = "spmv_mult_axis_0,spmv_mult_axis,{x_ipProduct=Vivado 2017.4,x_ipVendor=xilinx.com,x_ipLibrary=hls,x_ipName=spmv_mult_axis,x_ipVersion=1.0,x_ipCoreRevision=1807032102,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,C_S_AXI_AXILITES_ADDR_WIDTH=6,C_S_AXI_AXILITES_DATA_WIDTH=32,C_M_AXI_VECT_ID_WIDTH=1,C_M_AXI_VECT_ADDR_WIDTH=32,C_M_AXI_VECT_DATA_WIDTH=32,C_M_AXI_VECT_AWUSER_WIDTH=1,C_M_AXI_VECT_ARUSER_WIDTH=1,C_M_AXI_VECT_WUSER_WIDTH=1,C_M_AXI_VECT_RUSER_WIDTH=1,C_M_AXI_VECT_BUSER_WIDTH=1,C_M_AXI_VECT_USE\
R_VALUE=0x00000000,C_M_AXI_VECT_PROT_VALUE=000,C_M_AXI_VECT_CACHE_VALUE=0011}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module spmv_mult_axis_0 (
  output_size_loopback_ap_vld,
  s_axi_AXILiteS_AWADDR,
  s_axi_AXILiteS_AWVALID,
  s_axi_AXILiteS_AWREADY,
  s_axi_AXILiteS_WDATA,
  s_axi_AXILiteS_WSTRB,
  s_axi_AXILiteS_WVALID,
  s_axi_AXILiteS_WREADY,
  s_axi_AXILiteS_BRESP,
  s_axi_AXILiteS_BVALID,
  s_axi_AXILiteS_BREADY,
  s_axi_AXILiteS_ARADDR,
  s_axi_AXILiteS_ARVALID,
  s_axi_AXILiteS_ARREADY,
  s_axi_AXILiteS_RDATA,
  s_axi_AXILiteS_RRESP,
  s_axi_AXILiteS_RVALID,
  s_axi_AXILiteS_RREADY,
  ap_clk,
  ap_rst_n,
  interrupt,
  m_axi_vect_AWADDR,
  m_axi_vect_AWLEN,
  m_axi_vect_AWSIZE,
  m_axi_vect_AWBURST,
  m_axi_vect_AWLOCK,
  m_axi_vect_AWREGION,
  m_axi_vect_AWCACHE,
  m_axi_vect_AWPROT,
  m_axi_vect_AWQOS,
  m_axi_vect_AWVALID,
  m_axi_vect_AWREADY,
  m_axi_vect_WDATA,
  m_axi_vect_WSTRB,
  m_axi_vect_WLAST,
  m_axi_vect_WVALID,
  m_axi_vect_WREADY,
  m_axi_vect_BRESP,
  m_axi_vect_BVALID,
  m_axi_vect_BREADY,
  m_axi_vect_ARADDR,
  m_axi_vect_ARLEN,
  m_axi_vect_ARSIZE,
  m_axi_vect_ARBURST,
  m_axi_vect_ARLOCK,
  m_axi_vect_ARREGION,
  m_axi_vect_ARCACHE,
  m_axi_vect_ARPROT,
  m_axi_vect_ARQOS,
  m_axi_vect_ARVALID,
  m_axi_vect_ARREADY,
  m_axi_vect_RDATA,
  m_axi_vect_RRESP,
  m_axi_vect_RLAST,
  m_axi_vect_RVALID,
  m_axi_vect_RREADY,
  val_col_ind_stream_TVALID,
  val_col_ind_stream_TREADY,
  val_col_ind_stream_TDATA,
  val_col_ind_stream_TKEEP,
  val_col_ind_stream_TLAST,
  rowptr_stream_TVALID,
  rowptr_stream_TREADY,
  rowptr_stream_TDATA,
  rowptr_stream_TKEEP,
  rowptr_stream_TLAST,
  output_stream_V_TVALID,
  output_stream_V_TREADY,
  output_stream_V_TDATA,
  row_size_stream_V_TVALID,
  row_size_stream_V_TREADY,
  row_size_stream_V_TDATA,
  output_size_loopback
);

output wire output_size_loopback_ap_vld;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWADDR" *)
input wire [5 : 0] s_axi_AXILiteS_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWVALID" *)
input wire s_axi_AXILiteS_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWREADY" *)
output wire s_axi_AXILiteS_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WDATA" *)
input wire [31 : 0] s_axi_AXILiteS_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WSTRB" *)
input wire [3 : 0] s_axi_AXILiteS_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WVALID" *)
input wire s_axi_AXILiteS_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WREADY" *)
output wire s_axi_AXILiteS_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BRESP" *)
output wire [1 : 0] s_axi_AXILiteS_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BVALID" *)
output wire s_axi_AXILiteS_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BREADY" *)
input wire s_axi_AXILiteS_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARADDR" *)
input wire [5 : 0] s_axi_AXILiteS_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARVALID" *)
input wire s_axi_AXILiteS_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARREADY" *)
output wire s_axi_AXILiteS_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RDATA" *)
output wire [31 : 0] s_axi_AXILiteS_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RRESP" *)
output wire [1 : 0] s_axi_AXILiteS_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RVALID" *)
output wire s_axi_AXILiteS_RVALID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axi_AXILiteS, ADDR_WIDTH 6, DATA_WIDTH 32, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {AWVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} AWREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BRESP {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 2} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} ARVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} ARREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RRESP {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 2} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} AWADDR {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 6} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} WDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WSTRB {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 4} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} ARADDR {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 6} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} RDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RREADY" *)
input wire s_axi_AXILiteS_RREADY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_clk, ASSOCIATED_BUSIF s_axi_AXILiteS:m_axi_vect:val_col_ind_stream:rowptr_stream:output_stream_V:row_size_stream_V, ASSOCIATED_RESET ap_rst_n, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ap_clk CLK" *)
input wire ap_clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ap_rst_n, POLARITY ACTIVE_LOW, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {RST {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ap_rst_n RST" *)
input wire ap_rst_n;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME interrupt, SENSITIVITY LEVEL_HIGH, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {INTERRUPT {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, PortWidth 1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT" *)
output wire interrupt;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWADDR" *)
output wire [31 : 0] m_axi_vect_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWLEN" *)
output wire [7 : 0] m_axi_vect_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWSIZE" *)
output wire [2 : 0] m_axi_vect_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWBURST" *)
output wire [1 : 0] m_axi_vect_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWLOCK" *)
output wire [1 : 0] m_axi_vect_AWLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWREGION" *)
output wire [3 : 0] m_axi_vect_AWREGION;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWCACHE" *)
output wire [3 : 0] m_axi_vect_AWCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWPROT" *)
output wire [2 : 0] m_axi_vect_AWPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWQOS" *)
output wire [3 : 0] m_axi_vect_AWQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWVALID" *)
output wire m_axi_vect_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect AWREADY" *)
input wire m_axi_vect_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect WDATA" *)
output wire [31 : 0] m_axi_vect_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect WSTRB" *)
output wire [3 : 0] m_axi_vect_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect WLAST" *)
output wire m_axi_vect_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect WVALID" *)
output wire m_axi_vect_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect WREADY" *)
input wire m_axi_vect_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect BRESP" *)
input wire [1 : 0] m_axi_vect_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect BVALID" *)
input wire m_axi_vect_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect BREADY" *)
output wire m_axi_vect_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARADDR" *)
output wire [31 : 0] m_axi_vect_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARLEN" *)
output wire [7 : 0] m_axi_vect_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARSIZE" *)
output wire [2 : 0] m_axi_vect_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARBURST" *)
output wire [1 : 0] m_axi_vect_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARLOCK" *)
output wire [1 : 0] m_axi_vect_ARLOCK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARREGION" *)
output wire [3 : 0] m_axi_vect_ARREGION;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARCACHE" *)
output wire [3 : 0] m_axi_vect_ARCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARPROT" *)
output wire [2 : 0] m_axi_vect_ARPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARQOS" *)
output wire [3 : 0] m_axi_vect_ARQOS;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARVALID" *)
output wire m_axi_vect_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect ARREADY" *)
input wire m_axi_vect_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect RDATA" *)
input wire [31 : 0] m_axi_vect_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect RRESP" *)
input wire [1 : 0] m_axi_vect_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect RLAST" *)
input wire m_axi_vect_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect RVALID" *)
input wire m_axi_vect_RVALID;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axi_vect, ADDR_WIDTH 32, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2048, NUM_WRITE_OUTSTANDING 16, MAX_READ_BURST_LENGTH 16, MAX_WRITE_BURST_LENGTH 16, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 m_axi_vect RREADY" *)
output wire m_axi_vect_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 val_col_ind_stream TVALID" *)
input wire val_col_ind_stream_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 val_col_ind_stream TREADY" *)
output wire val_col_ind_stream_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 val_col_ind_stream TDATA" *)
input wire [63 : 0] val_col_ind_stream_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 val_col_ind_stream TKEEP" *)
input wire [3 : 0] val_col_ind_stream_TKEEP;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME val_col_ind_stream, TDATA_NUM_BYTES 8, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_val {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value val} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {float {sigwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 24}}}}} field_col_ind {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value col_ind} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 val_col_ind_stream TLAST" *)
input wire [0 : 0] val_col_ind_stream_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 rowptr_stream TVALID" *)
input wire rowptr_stream_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 rowptr_stream TREADY" *)
output wire rowptr_stream_TREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 rowptr_stream TDATA" *)
input wire [31 : 0] rowptr_stream_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 rowptr_stream TKEEP" *)
input wire [3 : 0] rowptr_stream_TKEEP;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rowptr_stream, TDATA_NUM_BYTES 4, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 rowptr_stream TLAST" *)
input wire [0 : 0] rowptr_stream_TLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 output_stream_V TVALID" *)
output wire output_stream_V_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 output_stream_V TREADY" *)
input wire output_stream_V_TREADY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME output_stream_V, TDATA_NUM_BYTES 4, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {float {sigwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 24}}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 output_stream_V TDATA" *)
output wire [31 : 0] output_stream_V_TDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 row_size_stream_V TVALID" *)
output wire row_size_stream_V_TVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 row_size_stream_V TREADY" *)
input wire row_size_stream_V_TREADY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME row_size_stream_V, TDATA_NUM_BYTES 4, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 row_size_stream_V TDATA" *)
output wire [31 : 0] row_size_stream_V_TDATA;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME output_size_loopback, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {DATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 output_size_loopback DATA" *)
output wire [31 : 0] output_size_loopback;

  spmv_mult_axis #(
    .C_S_AXI_AXILITES_ADDR_WIDTH(6),
    .C_S_AXI_AXILITES_DATA_WIDTH(32),
    .C_M_AXI_VECT_ID_WIDTH(1),
    .C_M_AXI_VECT_ADDR_WIDTH(32),
    .C_M_AXI_VECT_DATA_WIDTH(32),
    .C_M_AXI_VECT_AWUSER_WIDTH(1),
    .C_M_AXI_VECT_ARUSER_WIDTH(1),
    .C_M_AXI_VECT_WUSER_WIDTH(1),
    .C_M_AXI_VECT_RUSER_WIDTH(1),
    .C_M_AXI_VECT_BUSER_WIDTH(1),
    .C_M_AXI_VECT_USER_VALUE('H00000000),
    .C_M_AXI_VECT_PROT_VALUE('B000),
    .C_M_AXI_VECT_CACHE_VALUE('B0011)
  ) inst (
    .output_size_loopback_ap_vld(output_size_loopback_ap_vld),
    .s_axi_AXILiteS_AWADDR(s_axi_AXILiteS_AWADDR),
    .s_axi_AXILiteS_AWVALID(s_axi_AXILiteS_AWVALID),
    .s_axi_AXILiteS_AWREADY(s_axi_AXILiteS_AWREADY),
    .s_axi_AXILiteS_WDATA(s_axi_AXILiteS_WDATA),
    .s_axi_AXILiteS_WSTRB(s_axi_AXILiteS_WSTRB),
    .s_axi_AXILiteS_WVALID(s_axi_AXILiteS_WVALID),
    .s_axi_AXILiteS_WREADY(s_axi_AXILiteS_WREADY),
    .s_axi_AXILiteS_BRESP(s_axi_AXILiteS_BRESP),
    .s_axi_AXILiteS_BVALID(s_axi_AXILiteS_BVALID),
    .s_axi_AXILiteS_BREADY(s_axi_AXILiteS_BREADY),
    .s_axi_AXILiteS_ARADDR(s_axi_AXILiteS_ARADDR),
    .s_axi_AXILiteS_ARVALID(s_axi_AXILiteS_ARVALID),
    .s_axi_AXILiteS_ARREADY(s_axi_AXILiteS_ARREADY),
    .s_axi_AXILiteS_RDATA(s_axi_AXILiteS_RDATA),
    .s_axi_AXILiteS_RRESP(s_axi_AXILiteS_RRESP),
    .s_axi_AXILiteS_RVALID(s_axi_AXILiteS_RVALID),
    .s_axi_AXILiteS_RREADY(s_axi_AXILiteS_RREADY),
    .ap_clk(ap_clk),
    .ap_rst_n(ap_rst_n),
    .interrupt(interrupt),
    .m_axi_vect_AWID(),
    .m_axi_vect_AWADDR(m_axi_vect_AWADDR),
    .m_axi_vect_AWLEN(m_axi_vect_AWLEN),
    .m_axi_vect_AWSIZE(m_axi_vect_AWSIZE),
    .m_axi_vect_AWBURST(m_axi_vect_AWBURST),
    .m_axi_vect_AWLOCK(m_axi_vect_AWLOCK),
    .m_axi_vect_AWREGION(m_axi_vect_AWREGION),
    .m_axi_vect_AWCACHE(m_axi_vect_AWCACHE),
    .m_axi_vect_AWPROT(m_axi_vect_AWPROT),
    .m_axi_vect_AWQOS(m_axi_vect_AWQOS),
    .m_axi_vect_AWUSER(),
    .m_axi_vect_AWVALID(m_axi_vect_AWVALID),
    .m_axi_vect_AWREADY(m_axi_vect_AWREADY),
    .m_axi_vect_WID(),
    .m_axi_vect_WDATA(m_axi_vect_WDATA),
    .m_axi_vect_WSTRB(m_axi_vect_WSTRB),
    .m_axi_vect_WLAST(m_axi_vect_WLAST),
    .m_axi_vect_WUSER(),
    .m_axi_vect_WVALID(m_axi_vect_WVALID),
    .m_axi_vect_WREADY(m_axi_vect_WREADY),
    .m_axi_vect_BID(1'B0),
    .m_axi_vect_BRESP(m_axi_vect_BRESP),
    .m_axi_vect_BUSER(1'B0),
    .m_axi_vect_BVALID(m_axi_vect_BVALID),
    .m_axi_vect_BREADY(m_axi_vect_BREADY),
    .m_axi_vect_ARID(),
    .m_axi_vect_ARADDR(m_axi_vect_ARADDR),
    .m_axi_vect_ARLEN(m_axi_vect_ARLEN),
    .m_axi_vect_ARSIZE(m_axi_vect_ARSIZE),
    .m_axi_vect_ARBURST(m_axi_vect_ARBURST),
    .m_axi_vect_ARLOCK(m_axi_vect_ARLOCK),
    .m_axi_vect_ARREGION(m_axi_vect_ARREGION),
    .m_axi_vect_ARCACHE(m_axi_vect_ARCACHE),
    .m_axi_vect_ARPROT(m_axi_vect_ARPROT),
    .m_axi_vect_ARQOS(m_axi_vect_ARQOS),
    .m_axi_vect_ARUSER(),
    .m_axi_vect_ARVALID(m_axi_vect_ARVALID),
    .m_axi_vect_ARREADY(m_axi_vect_ARREADY),
    .m_axi_vect_RID(1'B0),
    .m_axi_vect_RDATA(m_axi_vect_RDATA),
    .m_axi_vect_RRESP(m_axi_vect_RRESP),
    .m_axi_vect_RLAST(m_axi_vect_RLAST),
    .m_axi_vect_RUSER(1'B0),
    .m_axi_vect_RVALID(m_axi_vect_RVALID),
    .m_axi_vect_RREADY(m_axi_vect_RREADY),
    .val_col_ind_stream_TVALID(val_col_ind_stream_TVALID),
    .val_col_ind_stream_TREADY(val_col_ind_stream_TREADY),
    .val_col_ind_stream_TDATA(val_col_ind_stream_TDATA),
    .val_col_ind_stream_TKEEP(val_col_ind_stream_TKEEP),
    .val_col_ind_stream_TLAST(val_col_ind_stream_TLAST),
    .rowptr_stream_TVALID(rowptr_stream_TVALID),
    .rowptr_stream_TREADY(rowptr_stream_TREADY),
    .rowptr_stream_TDATA(rowptr_stream_TDATA),
    .rowptr_stream_TKEEP(rowptr_stream_TKEEP),
    .rowptr_stream_TLAST(rowptr_stream_TLAST),
    .output_stream_V_TVALID(output_stream_V_TVALID),
    .output_stream_V_TREADY(output_stream_V_TREADY),
    .output_stream_V_TDATA(output_stream_V_TDATA),
    .row_size_stream_V_TVALID(row_size_stream_V_TVALID),
    .row_size_stream_V_TREADY(row_size_stream_V_TREADY),
    .row_size_stream_V_TDATA(row_size_stream_V_TDATA),
    .output_size_loopback(output_size_loopback)
  );
endmodule
