-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Wed Jul  4 10:36:28 2018
-- Host        : lap-laptop-3 running 64-bit Ubuntu 18.04 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/asiatici/epfl/memory-coalescer/vivado/spmv/spmv-hls/TopLevel/TopLevel.srcs/sources_1/ip/spmv_mult_axis_0_2/spmv_mult_axis_0_stub.vhdl
-- Design      : spmv_mult_axis_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity spmv_mult_axis_0 is
  Port ( 
    output_size_loopback_ap_vld : out STD_LOGIC;
    s_axi_AXILiteS_AWADDR : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_AXILiteS_AWVALID : in STD_LOGIC;
    s_axi_AXILiteS_AWREADY : out STD_LOGIC;
    s_axi_AXILiteS_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_AXILiteS_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_AXILiteS_WVALID : in STD_LOGIC;
    s_axi_AXILiteS_WREADY : out STD_LOGIC;
    s_axi_AXILiteS_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_AXILiteS_BVALID : out STD_LOGIC;
    s_axi_AXILiteS_BREADY : in STD_LOGIC;
    s_axi_AXILiteS_ARADDR : in STD_LOGIC_VECTOR ( 5 downto 0 );
    s_axi_AXILiteS_ARVALID : in STD_LOGIC;
    s_axi_AXILiteS_ARREADY : out STD_LOGIC;
    s_axi_AXILiteS_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_AXILiteS_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_AXILiteS_RVALID : out STD_LOGIC;
    s_axi_AXILiteS_RREADY : in STD_LOGIC;
    ap_clk : in STD_LOGIC;
    ap_rst_n : in STD_LOGIC;
    interrupt : out STD_LOGIC;
    m_axi_vect_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_vect_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_vect_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_vect_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_AWLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_AWREGION : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_vect_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_AWVALID : out STD_LOGIC;
    m_axi_vect_AWREADY : in STD_LOGIC;
    m_axi_vect_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_vect_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_WLAST : out STD_LOGIC;
    m_axi_vect_WVALID : out STD_LOGIC;
    m_axi_vect_WREADY : in STD_LOGIC;
    m_axi_vect_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_BVALID : in STD_LOGIC;
    m_axi_vect_BREADY : out STD_LOGIC;
    m_axi_vect_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_vect_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axi_vect_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_vect_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_ARLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_ARREGION : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    m_axi_vect_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axi_vect_ARVALID : out STD_LOGIC;
    m_axi_vect_ARREADY : in STD_LOGIC;
    m_axi_vect_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axi_vect_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    m_axi_vect_RLAST : in STD_LOGIC;
    m_axi_vect_RVALID : in STD_LOGIC;
    m_axi_vect_RREADY : out STD_LOGIC;
    val_col_ind_stream_TVALID : in STD_LOGIC;
    val_col_ind_stream_TREADY : out STD_LOGIC;
    val_col_ind_stream_TDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    val_col_ind_stream_TKEEP : in STD_LOGIC_VECTOR ( 3 downto 0 );
    val_col_ind_stream_TLAST : in STD_LOGIC_VECTOR ( 0 to 0 );
    rowptr_stream_TVALID : in STD_LOGIC;
    rowptr_stream_TREADY : out STD_LOGIC;
    rowptr_stream_TDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    rowptr_stream_TKEEP : in STD_LOGIC_VECTOR ( 3 downto 0 );
    rowptr_stream_TLAST : in STD_LOGIC_VECTOR ( 0 to 0 );
    output_stream_V_TVALID : out STD_LOGIC;
    output_stream_V_TREADY : in STD_LOGIC;
    output_stream_V_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    row_size_stream_V_TVALID : out STD_LOGIC;
    row_size_stream_V_TREADY : in STD_LOGIC;
    row_size_stream_V_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    output_size_loopback : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end spmv_mult_axis_0;

architecture stub of spmv_mult_axis_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "output_size_loopback_ap_vld,s_axi_AXILiteS_AWADDR[5:0],s_axi_AXILiteS_AWVALID,s_axi_AXILiteS_AWREADY,s_axi_AXILiteS_WDATA[31:0],s_axi_AXILiteS_WSTRB[3:0],s_axi_AXILiteS_WVALID,s_axi_AXILiteS_WREADY,s_axi_AXILiteS_BRESP[1:0],s_axi_AXILiteS_BVALID,s_axi_AXILiteS_BREADY,s_axi_AXILiteS_ARADDR[5:0],s_axi_AXILiteS_ARVALID,s_axi_AXILiteS_ARREADY,s_axi_AXILiteS_RDATA[31:0],s_axi_AXILiteS_RRESP[1:0],s_axi_AXILiteS_RVALID,s_axi_AXILiteS_RREADY,ap_clk,ap_rst_n,interrupt,m_axi_vect_AWADDR[31:0],m_axi_vect_AWLEN[7:0],m_axi_vect_AWSIZE[2:0],m_axi_vect_AWBURST[1:0],m_axi_vect_AWLOCK[1:0],m_axi_vect_AWREGION[3:0],m_axi_vect_AWCACHE[3:0],m_axi_vect_AWPROT[2:0],m_axi_vect_AWQOS[3:0],m_axi_vect_AWVALID,m_axi_vect_AWREADY,m_axi_vect_WDATA[31:0],m_axi_vect_WSTRB[3:0],m_axi_vect_WLAST,m_axi_vect_WVALID,m_axi_vect_WREADY,m_axi_vect_BRESP[1:0],m_axi_vect_BVALID,m_axi_vect_BREADY,m_axi_vect_ARADDR[31:0],m_axi_vect_ARLEN[7:0],m_axi_vect_ARSIZE[2:0],m_axi_vect_ARBURST[1:0],m_axi_vect_ARLOCK[1:0],m_axi_vect_ARREGION[3:0],m_axi_vect_ARCACHE[3:0],m_axi_vect_ARPROT[2:0],m_axi_vect_ARQOS[3:0],m_axi_vect_ARVALID,m_axi_vect_ARREADY,m_axi_vect_RDATA[31:0],m_axi_vect_RRESP[1:0],m_axi_vect_RLAST,m_axi_vect_RVALID,m_axi_vect_RREADY,val_col_ind_stream_TVALID,val_col_ind_stream_TREADY,val_col_ind_stream_TDATA[63:0],val_col_ind_stream_TKEEP[3:0],val_col_ind_stream_TLAST[0:0],rowptr_stream_TVALID,rowptr_stream_TREADY,rowptr_stream_TDATA[31:0],rowptr_stream_TKEEP[3:0],rowptr_stream_TLAST[0:0],output_stream_V_TVALID,output_stream_V_TREADY,output_stream_V_TDATA[31:0],row_size_stream_V_TVALID,row_size_stream_V_TREADY,row_size_stream_V_TDATA[31:0],output_size_loopback[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "spmv_mult_axis,Vivado 2017.4";
begin
end;
