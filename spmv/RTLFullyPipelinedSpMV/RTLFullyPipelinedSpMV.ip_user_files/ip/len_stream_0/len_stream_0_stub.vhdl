-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (lin64) Build 2086221 Fri Dec 15 20:54:30 MST 2017
-- Date        : Fri Aug 31 18:37:42 2018
-- Host        : lap-laptop-3 running 64-bit Ubuntu 18.04.1 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /home/asiatici/epfl/memory-coalescer/vivado/spmv/spmv-hls/RTLFullyPipelinedSpMV/RTLFullyPipelinedSpMV.srcs/sources_1/ip/len_stream_0/len_stream_0_stub.vhdl
-- Design      : len_stream_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg900-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity len_stream_0 is
  Port ( 
    output_size_loopback_ap_vld : out STD_LOGIC;
    offset_loopback_ap_vld : out STD_LOGIC;
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
    output_size_loopback : out STD_LOGIC_VECTOR ( 31 downto 0 );
    offset_loopback : out STD_LOGIC_VECTOR ( 31 downto 0 );
    rowptr_stream_TVALID : in STD_LOGIC;
    rowptr_stream_TREADY : out STD_LOGIC;
    rowptr_stream_TDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    rowptr_stream_TKEEP : in STD_LOGIC_VECTOR ( 3 downto 0 );
    rowptr_stream_TLAST : in STD_LOGIC_VECTOR ( 0 to 0 );
    output_stream_V_TVALID : out STD_LOGIC;
    output_stream_V_TREADY : in STD_LOGIC;
    output_stream_V_TDATA : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end len_stream_0;

architecture stub of len_stream_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "output_size_loopback_ap_vld,offset_loopback_ap_vld,s_axi_AXILiteS_AWADDR[5:0],s_axi_AXILiteS_AWVALID,s_axi_AXILiteS_AWREADY,s_axi_AXILiteS_WDATA[31:0],s_axi_AXILiteS_WSTRB[3:0],s_axi_AXILiteS_WVALID,s_axi_AXILiteS_WREADY,s_axi_AXILiteS_BRESP[1:0],s_axi_AXILiteS_BVALID,s_axi_AXILiteS_BREADY,s_axi_AXILiteS_ARADDR[5:0],s_axi_AXILiteS_ARVALID,s_axi_AXILiteS_ARREADY,s_axi_AXILiteS_RDATA[31:0],s_axi_AXILiteS_RRESP[1:0],s_axi_AXILiteS_RVALID,s_axi_AXILiteS_RREADY,ap_clk,ap_rst_n,interrupt,output_size_loopback[31:0],offset_loopback[31:0],rowptr_stream_TVALID,rowptr_stream_TREADY,rowptr_stream_TDATA[31:0],rowptr_stream_TKEEP[3:0],rowptr_stream_TLAST[0:0],output_stream_V_TVALID,output_stream_V_TREADY,output_stream_V_TDATA[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "len_stream,Vivado 2017.4";
begin
end;
