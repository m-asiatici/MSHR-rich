-- (c) Copyright 1995-2018 Xilinx, Inc. All rights reserved.
-- 
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
-- 
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
-- 
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
-- 
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
-- 
-- DO NOT MODIFY THIS FILE.

-- IP VLNV: xilinx.com:hls:spmv_mult_axis:1.0
-- IP Revision: 1806261708

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY spmv_mult_axis_0 IS
  PORT (
    s_axi_AXILiteS_AWADDR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s_axi_AXILiteS_AWVALID : IN STD_LOGIC;
    s_axi_AXILiteS_AWREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_AXILiteS_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    s_axi_AXILiteS_WVALID : IN STD_LOGIC;
    s_axi_AXILiteS_WREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_AXILiteS_BVALID : OUT STD_LOGIC;
    s_axi_AXILiteS_BREADY : IN STD_LOGIC;
    s_axi_AXILiteS_ARADDR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
    s_axi_AXILiteS_ARVALID : IN STD_LOGIC;
    s_axi_AXILiteS_ARREADY : OUT STD_LOGIC;
    s_axi_AXILiteS_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axi_AXILiteS_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    s_axi_AXILiteS_RVALID : OUT STD_LOGIC;
    s_axi_AXILiteS_RREADY : IN STD_LOGIC;
    ap_clk : IN STD_LOGIC;
    ap_rst_n : IN STD_LOGIC;
    interrupt : OUT STD_LOGIC;
    m_axi_vect_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_vect_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_vect_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_vect_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_AWREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_vect_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_AWVALID : OUT STD_LOGIC;
    m_axi_vect_AWREADY : IN STD_LOGIC;
    m_axi_vect_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_vect_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_WLAST : OUT STD_LOGIC;
    m_axi_vect_WVALID : OUT STD_LOGIC;
    m_axi_vect_WREADY : IN STD_LOGIC;
    m_axi_vect_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_BVALID : IN STD_LOGIC;
    m_axi_vect_BREADY : OUT STD_LOGIC;
    m_axi_vect_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_vect_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axi_vect_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_vect_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_ARREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    m_axi_vect_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    m_axi_vect_ARVALID : OUT STD_LOGIC;
    m_axi_vect_ARREADY : IN STD_LOGIC;
    m_axi_vect_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axi_vect_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    m_axi_vect_RLAST : IN STD_LOGIC;
    m_axi_vect_RVALID : IN STD_LOGIC;
    m_axi_vect_RREADY : OUT STD_LOGIC;
    val_col_ind_stream_TVALID : IN STD_LOGIC;
    val_col_ind_stream_TREADY : OUT STD_LOGIC;
    val_col_ind_stream_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    val_col_ind_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    val_col_ind_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    rowptr_stream_TVALID : IN STD_LOGIC;
    rowptr_stream_TREADY : OUT STD_LOGIC;
    rowptr_stream_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    rowptr_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    rowptr_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    output_stream_TVALID : OUT STD_LOGIC;
    output_stream_TREADY : IN STD_LOGIC;
    output_stream_TDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    output_stream_TKEEP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    output_stream_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END spmv_mult_axis_0;

ARCHITECTURE spmv_mult_axis_0_arch OF spmv_mult_axis_0 IS
  ATTRIBUTE DowngradeIPIdentifiedWarnings : STRING;
  ATTRIBUTE DowngradeIPIdentifiedWarnings OF spmv_mult_axis_0_arch: ARCHITECTURE IS "yes";
  COMPONENT spmv_mult_axis IS
    GENERIC (
      C_S_AXI_AXILITES_ADDR_WIDTH : INTEGER;
      C_S_AXI_AXILITES_DATA_WIDTH : INTEGER;
      C_M_AXI_VECT_ID_WIDTH : INTEGER;
      C_M_AXI_VECT_ADDR_WIDTH : INTEGER;
      C_M_AXI_VECT_DATA_WIDTH : INTEGER;
      C_M_AXI_VECT_AWUSER_WIDTH : INTEGER;
      C_M_AXI_VECT_ARUSER_WIDTH : INTEGER;
      C_M_AXI_VECT_WUSER_WIDTH : INTEGER;
      C_M_AXI_VECT_RUSER_WIDTH : INTEGER;
      C_M_AXI_VECT_BUSER_WIDTH : INTEGER;
      C_M_AXI_VECT_USER_VALUE : INTEGER;
      C_M_AXI_VECT_PROT_VALUE : INTEGER;
      C_M_AXI_VECT_CACHE_VALUE : INTEGER
    );
    PORT (
      s_axi_AXILiteS_AWADDR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s_axi_AXILiteS_AWVALID : IN STD_LOGIC;
      s_axi_AXILiteS_AWREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_AXILiteS_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_AXILiteS_WVALID : IN STD_LOGIC;
      s_axi_AXILiteS_WREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_AXILiteS_BVALID : OUT STD_LOGIC;
      s_axi_AXILiteS_BREADY : IN STD_LOGIC;
      s_axi_AXILiteS_ARADDR : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
      s_axi_AXILiteS_ARVALID : IN STD_LOGIC;
      s_axi_AXILiteS_ARREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_AXILiteS_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_AXILiteS_RVALID : OUT STD_LOGIC;
      s_axi_AXILiteS_RREADY : IN STD_LOGIC;
      ap_clk : IN STD_LOGIC;
      ap_rst_n : IN STD_LOGIC;
      interrupt : OUT STD_LOGIC;
      m_axi_vect_AWID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_vect_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_AWLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_AWREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_AWUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_AWVALID : OUT STD_LOGIC;
      m_axi_vect_AWREADY : IN STD_LOGIC;
      m_axi_vect_WID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_WDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_WSTRB : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_WLAST : OUT STD_LOGIC;
      m_axi_vect_WUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_WVALID : OUT STD_LOGIC;
      m_axi_vect_WREADY : IN STD_LOGIC;
      m_axi_vect_BID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_BUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_BVALID : IN STD_LOGIC;
      m_axi_vect_BREADY : OUT STD_LOGIC;
      m_axi_vect_ARID : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_vect_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_ARREGION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_ARUSER : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_ARVALID : OUT STD_LOGIC;
      m_axi_vect_ARREADY : IN STD_LOGIC;
      m_axi_vect_RID : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_RLAST : IN STD_LOGIC;
      m_axi_vect_RUSER : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      m_axi_vect_RVALID : IN STD_LOGIC;
      m_axi_vect_RREADY : OUT STD_LOGIC;
      val_col_ind_stream_TVALID : IN STD_LOGIC;
      val_col_ind_stream_TREADY : OUT STD_LOGIC;
      val_col_ind_stream_TDATA : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
      val_col_ind_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      val_col_ind_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      rowptr_stream_TVALID : IN STD_LOGIC;
      rowptr_stream_TREADY : OUT STD_LOGIC;
      rowptr_stream_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      rowptr_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      rowptr_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      output_stream_TVALID : OUT STD_LOGIC;
      output_stream_TREADY : IN STD_LOGIC;
      output_stream_TDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      output_stream_TKEEP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      output_stream_TLAST : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
  END COMPONENT spmv_mult_axis;
  ATTRIBUTE X_INTERFACE_INFO : STRING;
  ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TKEEP: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TREADY";
  ATTRIBUTE X_INTERFACE_PARAMETER OF output_stream_TVALID: SIGNAL IS "XIL_INTERFACENAME output_stream, TDATA_NUM_BYTES 4, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {float {sigwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 24}}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000";
  ATTRIBUTE X_INTERFACE_INFO OF output_stream_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 output_stream TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF rowptr_stream_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 rowptr_stream TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF rowptr_stream_TKEEP: SIGNAL IS "xilinx.com:interface:axis:1.0 rowptr_stream TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF rowptr_stream_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 rowptr_stream TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF rowptr_stream_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 rowptr_stream TREADY";
  ATTRIBUTE X_INTERFACE_PARAMETER OF rowptr_stream_TVALID: SIGNAL IS "XIL_INTERFACENAME rowptr_stream, TDATA_NUM_BYTES 4, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000";
  ATTRIBUTE X_INTERFACE_INFO OF rowptr_stream_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 rowptr_stream TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF val_col_ind_stream_TLAST: SIGNAL IS "xilinx.com:interface:axis:1.0 val_col_ind_stream TLAST";
  ATTRIBUTE X_INTERFACE_INFO OF val_col_ind_stream_TKEEP: SIGNAL IS "xilinx.com:interface:axis:1.0 val_col_ind_stream TKEEP";
  ATTRIBUTE X_INTERFACE_INFO OF val_col_ind_stream_TDATA: SIGNAL IS "xilinx.com:interface:axis:1.0 val_col_ind_stream TDATA";
  ATTRIBUTE X_INTERFACE_INFO OF val_col_ind_stream_TREADY: SIGNAL IS "xilinx.com:interface:axis:1.0 val_col_ind_stream TREADY";
  ATTRIBUTE X_INTERFACE_PARAMETER OF val_col_ind_stream_TVALID: SIGNAL IS "XIL_INTERFACENAME val_col_ind_stream, TDATA_NUM_BYTES 8, TUSER_WIDTH 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_val {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value val} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {float {sigwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 24}}}}} field_col_ind {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value col_ind} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}}}}, TDEST_WIDTH 0, TID_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000";
  ATTRIBUTE X_INTERFACE_INFO OF val_col_ind_stream_TVALID: SIGNAL IS "xilinx.com:interface:axis:1.0 val_col_ind_stream TVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_RREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_RVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_RLAST: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect RLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_RRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_RDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARQOS: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARQOS";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARPROT: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARCACHE: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARREGION: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARREGION";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARLOCK: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARBURST: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARSIZE: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARLEN: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARLEN";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_ARADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_BREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_BVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_BRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_WREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_WVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_WLAST: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect WLAST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_WSTRB: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_WDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWVALID";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWQOS: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWQOS";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWPROT: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWPROT";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWCACHE: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWCACHE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWREGION: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWREGION";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWLOCK: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWLOCK";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWBURST: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWBURST";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWSIZE: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWSIZE";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWLEN: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWLEN";
  ATTRIBUTE X_INTERFACE_PARAMETER OF m_axi_vect_AWADDR: SIGNAL IS "XIL_INTERFACENAME m_axi_vect, ADDR_WIDTH 32, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2048, NUM_WRITE_OUTSTANDING 16, MAX_READ_BURST_LENGTH 16, MAX_WRITE_BURST_LENGTH 16, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, SUPPORTS_NARROW_BURST 0, DATA_WIDTH 32, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  ATTRIBUTE X_INTERFACE_INFO OF m_axi_vect_AWADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 m_axi_vect AWADDR";
  ATTRIBUTE X_INTERFACE_PARAMETER OF interrupt: SIGNAL IS "XIL_INTERFACENAME interrupt, SENSITIVITY LEVEL_HIGH, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {INTERRUPT {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, PortWidth 1";
  ATTRIBUTE X_INTERFACE_INFO OF interrupt: SIGNAL IS "xilinx.com:signal:interrupt:1.0 interrupt INTERRUPT";
  ATTRIBUTE X_INTERFACE_PARAMETER OF ap_rst_n: SIGNAL IS "XIL_INTERFACENAME ap_rst_n, POLARITY ACTIVE_LOW, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {RST {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}";
  ATTRIBUTE X_INTERFACE_INFO OF ap_rst_n: SIGNAL IS "xilinx.com:signal:reset:1.0 ap_rst_n RST";
  ATTRIBUTE X_INTERFACE_PARAMETER OF ap_clk: SIGNAL IS "XIL_INTERFACENAME ap_clk, ASSOCIATED_BUSIF s_axi_AXILiteS:m_axi_vect:val_col_ind_stream:rowptr_stream:output_stream, ASSOCIATED_RESET ap_rst_n, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {CLK {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, PHASE 0.000";
  ATTRIBUTE X_INTERFACE_INFO OF ap_clk: SIGNAL IS "xilinx.com:signal:clock:1.0 ap_clk CLK";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_RREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_RVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_RRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_RDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS RDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_ARREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_ARVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_ARADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS ARADDR";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_BREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_BVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_BRESP: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS BRESP";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_WREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_WVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WVALID";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_WSTRB: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WSTRB";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_WDATA: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS WDATA";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_AWREADY: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWREADY";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_AWVALID: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWVALID";
  ATTRIBUTE X_INTERFACE_PARAMETER OF s_axi_AXILiteS_AWADDR: SIGNAL IS "XIL_INTERFACENAME s_axi_AXILiteS, ADDR_WIDTH 6, DATA_WIDTH 32, PROTOCOL AXI4LITE, READ_WRITE_MODE READ_WRITE, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {AWVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} AWREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} BRESP {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 2} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} ARVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} ARREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RVALID {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RREADY {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} RRESP {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 2} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} AWADDR {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 6} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} WDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} WSTRB {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 4} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} ARADDR {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 6} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} RDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}}}, FREQ_HZ 100000000, ID_WIDTH 0, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0";
  ATTRIBUTE X_INTERFACE_INFO OF s_axi_AXILiteS_AWADDR: SIGNAL IS "xilinx.com:interface:aximm:1.0 s_axi_AXILiteS AWADDR";
BEGIN
  U0 : spmv_mult_axis
    GENERIC MAP (
      C_S_AXI_AXILITES_ADDR_WIDTH => 6,
      C_S_AXI_AXILITES_DATA_WIDTH => 32,
      C_M_AXI_VECT_ID_WIDTH => 1,
      C_M_AXI_VECT_ADDR_WIDTH => 32,
      C_M_AXI_VECT_DATA_WIDTH => 32,
      C_M_AXI_VECT_AWUSER_WIDTH => 1,
      C_M_AXI_VECT_ARUSER_WIDTH => 1,
      C_M_AXI_VECT_WUSER_WIDTH => 1,
      C_M_AXI_VECT_RUSER_WIDTH => 1,
      C_M_AXI_VECT_BUSER_WIDTH => 1,
      C_M_AXI_VECT_USER_VALUE => 0,
      C_M_AXI_VECT_PROT_VALUE => 0,
      C_M_AXI_VECT_CACHE_VALUE => 3
    )
    PORT MAP (
      s_axi_AXILiteS_AWADDR => s_axi_AXILiteS_AWADDR,
      s_axi_AXILiteS_AWVALID => s_axi_AXILiteS_AWVALID,
      s_axi_AXILiteS_AWREADY => s_axi_AXILiteS_AWREADY,
      s_axi_AXILiteS_WDATA => s_axi_AXILiteS_WDATA,
      s_axi_AXILiteS_WSTRB => s_axi_AXILiteS_WSTRB,
      s_axi_AXILiteS_WVALID => s_axi_AXILiteS_WVALID,
      s_axi_AXILiteS_WREADY => s_axi_AXILiteS_WREADY,
      s_axi_AXILiteS_BRESP => s_axi_AXILiteS_BRESP,
      s_axi_AXILiteS_BVALID => s_axi_AXILiteS_BVALID,
      s_axi_AXILiteS_BREADY => s_axi_AXILiteS_BREADY,
      s_axi_AXILiteS_ARADDR => s_axi_AXILiteS_ARADDR,
      s_axi_AXILiteS_ARVALID => s_axi_AXILiteS_ARVALID,
      s_axi_AXILiteS_ARREADY => s_axi_AXILiteS_ARREADY,
      s_axi_AXILiteS_RDATA => s_axi_AXILiteS_RDATA,
      s_axi_AXILiteS_RRESP => s_axi_AXILiteS_RRESP,
      s_axi_AXILiteS_RVALID => s_axi_AXILiteS_RVALID,
      s_axi_AXILiteS_RREADY => s_axi_AXILiteS_RREADY,
      ap_clk => ap_clk,
      ap_rst_n => ap_rst_n,
      interrupt => interrupt,
      m_axi_vect_AWADDR => m_axi_vect_AWADDR,
      m_axi_vect_AWLEN => m_axi_vect_AWLEN,
      m_axi_vect_AWSIZE => m_axi_vect_AWSIZE,
      m_axi_vect_AWBURST => m_axi_vect_AWBURST,
      m_axi_vect_AWLOCK => m_axi_vect_AWLOCK,
      m_axi_vect_AWREGION => m_axi_vect_AWREGION,
      m_axi_vect_AWCACHE => m_axi_vect_AWCACHE,
      m_axi_vect_AWPROT => m_axi_vect_AWPROT,
      m_axi_vect_AWQOS => m_axi_vect_AWQOS,
      m_axi_vect_AWVALID => m_axi_vect_AWVALID,
      m_axi_vect_AWREADY => m_axi_vect_AWREADY,
      m_axi_vect_WDATA => m_axi_vect_WDATA,
      m_axi_vect_WSTRB => m_axi_vect_WSTRB,
      m_axi_vect_WLAST => m_axi_vect_WLAST,
      m_axi_vect_WVALID => m_axi_vect_WVALID,
      m_axi_vect_WREADY => m_axi_vect_WREADY,
      m_axi_vect_BID => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m_axi_vect_BRESP => m_axi_vect_BRESP,
      m_axi_vect_BUSER => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m_axi_vect_BVALID => m_axi_vect_BVALID,
      m_axi_vect_BREADY => m_axi_vect_BREADY,
      m_axi_vect_ARADDR => m_axi_vect_ARADDR,
      m_axi_vect_ARLEN => m_axi_vect_ARLEN,
      m_axi_vect_ARSIZE => m_axi_vect_ARSIZE,
      m_axi_vect_ARBURST => m_axi_vect_ARBURST,
      m_axi_vect_ARLOCK => m_axi_vect_ARLOCK,
      m_axi_vect_ARREGION => m_axi_vect_ARREGION,
      m_axi_vect_ARCACHE => m_axi_vect_ARCACHE,
      m_axi_vect_ARPROT => m_axi_vect_ARPROT,
      m_axi_vect_ARQOS => m_axi_vect_ARQOS,
      m_axi_vect_ARVALID => m_axi_vect_ARVALID,
      m_axi_vect_ARREADY => m_axi_vect_ARREADY,
      m_axi_vect_RID => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m_axi_vect_RDATA => m_axi_vect_RDATA,
      m_axi_vect_RRESP => m_axi_vect_RRESP,
      m_axi_vect_RLAST => m_axi_vect_RLAST,
      m_axi_vect_RUSER => STD_LOGIC_VECTOR(TO_UNSIGNED(0, 1)),
      m_axi_vect_RVALID => m_axi_vect_RVALID,
      m_axi_vect_RREADY => m_axi_vect_RREADY,
      val_col_ind_stream_TVALID => val_col_ind_stream_TVALID,
      val_col_ind_stream_TREADY => val_col_ind_stream_TREADY,
      val_col_ind_stream_TDATA => val_col_ind_stream_TDATA,
      val_col_ind_stream_TKEEP => val_col_ind_stream_TKEEP,
      val_col_ind_stream_TLAST => val_col_ind_stream_TLAST,
      rowptr_stream_TVALID => rowptr_stream_TVALID,
      rowptr_stream_TREADY => rowptr_stream_TREADY,
      rowptr_stream_TDATA => rowptr_stream_TDATA,
      rowptr_stream_TKEEP => rowptr_stream_TKEEP,
      rowptr_stream_TLAST => rowptr_stream_TLAST,
      output_stream_TVALID => output_stream_TVALID,
      output_stream_TREADY => output_stream_TREADY,
      output_stream_TDATA => output_stream_TDATA,
      output_stream_TKEEP => output_stream_TKEEP,
      output_stream_TLAST => output_stream_TLAST
    );
END spmv_mult_axis_0_arch;
