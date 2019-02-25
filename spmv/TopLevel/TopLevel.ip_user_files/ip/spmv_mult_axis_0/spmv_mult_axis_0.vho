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
-- IP Revision: 1807032102

-- The following code must appear in the VHDL architecture header.

------------- Begin Cut here for COMPONENT Declaration ------ COMP_TAG
COMPONENT spmv_mult_axis_0
  PORT (
    output_size_loopback_ap_vld : OUT STD_LOGIC;
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
    output_stream_V_TVALID : OUT STD_LOGIC;
    output_stream_V_TREADY : IN STD_LOGIC;
    output_stream_V_TDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    row_size_stream_V_TVALID : OUT STD_LOGIC;
    row_size_stream_V_TREADY : IN STD_LOGIC;
    row_size_stream_V_TDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    output_size_loopback : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
-- COMP_TAG_END ------ End COMPONENT Declaration ------------

-- The following code must appear in the VHDL architecture
-- body. Substitute your own instance name and net names.

------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
your_instance_name : spmv_mult_axis_0
  PORT MAP (
    output_size_loopback_ap_vld => output_size_loopback_ap_vld,
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
    m_axi_vect_BRESP => m_axi_vect_BRESP,
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
    m_axi_vect_RDATA => m_axi_vect_RDATA,
    m_axi_vect_RRESP => m_axi_vect_RRESP,
    m_axi_vect_RLAST => m_axi_vect_RLAST,
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
    output_stream_V_TVALID => output_stream_V_TVALID,
    output_stream_V_TREADY => output_stream_V_TREADY,
    output_stream_V_TDATA => output_stream_V_TDATA,
    row_size_stream_V_TVALID => row_size_stream_V_TVALID,
    row_size_stream_V_TREADY => row_size_stream_V_TREADY,
    row_size_stream_V_TDATA => row_size_stream_V_TDATA,
    output_size_loopback => output_size_loopback
  );
-- INST_TAG_END ------ End INSTANTIATION Template ---------

-- You must compile the wrapper file spmv_mult_axis_0.vhd when simulating
-- the core, spmv_mult_axis_0. When compiling the wrapper file, be sure to
-- reference the VHDL simulation library.

