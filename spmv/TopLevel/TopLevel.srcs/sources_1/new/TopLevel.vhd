----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 29.06.2018 11:39:42
-- Design Name:
-- Module Name: TopLevel - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TopLevel is
    port(
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
      output_stream_tvalid: OUT STD_LOGIC;
      output_stream_tready: IN STD_LOGIC;
      output_stream_tdata: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      output_stream_tuser: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      output_stream_tlast: OUT STD_LOGIC
    );
end TopLevel;

architecture Behavioral of TopLevel is

    -- SpMV
    signal output_stream_V_TDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal output_stream_V_TREADY: STD_LOGIC;
    signal output_stream_V_TVALID: STD_LOGIC;
    signal row_size_stream_V_TDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal row_size_stream_V_TREADY: STD_LOGIC;
    signal row_size_stream_V_TVALID: STD_LOGIC;
    signal output_size_loopback: STD_LOGIC_VECTOR(31 downto 0);
    signal output_size_loopback_ap_vld : STD_LOGIC;

    -- FP accumulator
    signal aclk: STD_LOGIC;
    signal aresetn: STD_LOGIC;
    signal s_axis_a_tvalid: STD_LOGIC;
    signal s_axis_a_tready: STD_LOGIC;
    signal s_axis_a_tdata: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axis_a_tlast: STD_LOGIC;
    signal output_stream_tvalid_internal: STD_LOGIC;
    signal output_stream_tlast_internal: STD_LOGIC;

    -- TLAST Generator
    signal clock: std_logic;
    signal reset: std_logic;
    signal io_mult_res_ready: std_logic;
    signal io_mult_res_valid: std_logic;
    signal io_mult_res_bits: std_logic_vector(31 downto 0);
    signal io_row_len_ready: std_logic;
    signal io_row_len_valid: std_logic;
    signal io_row_len_bits: std_logic_vector(31 downto 0);
    signal io_out_ready: std_logic;
    signal io_out_valid: std_logic;
    signal io_out_bits_data: std_logic_vector(31 downto 0);
    signal io_out_bits_last: std_logic;

    constant MAX_DMA_TX_SIZE: std_logic_vector(23 downto 0) := x"1FFFFE";
    signal tlast_counter: std_logic_vector(31 downto 0);
    signal dma_tx_size_counter: std_logic_vector(22 downto 0);

    component tlastgenerator port (
        clock: in std_logic;
        reset:   in std_logic;
        io_mult_res_ready:   out std_logic;
        io_mult_res_valid:   in std_logic;
        io_mult_res_bits:   in std_logic_vector(31 downto 0);
        io_row_len_ready:   out std_logic;
        io_row_len_valid:   in std_logic;
        io_row_len_bits:   in std_logic_vector(31 downto 0);
        io_out_ready:   in std_logic;
        io_out_valid:   out std_logic;
        io_out_bits_data:   out std_logic_vector(31 downto 0);
        io_out_bits_last:   out std_logic
    );
    end component;

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

    component floating_point_0
    Port (
        aclk : in STD_LOGIC;
        aresetn : in STD_LOGIC;
        s_axis_a_tvalid : in STD_LOGIC;
        s_axis_a_tready : out STD_LOGIC;
        s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
        s_axis_a_tlast : in STD_LOGIC;
        m_axis_result_tvalid : out STD_LOGIC;
        m_axis_result_tready : in STD_LOGIC;
        m_axis_result_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
        m_axis_result_tuser : out STD_LOGIC_VECTOR ( 2 downto 0 );
        m_axis_result_tlast : out STD_LOGIC
      );
      end component;
begin
    spmv: spmv_mult_axis_0
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

  tlast_counter_proc: process(ap_rst_n, ap_clk)
  begin
    if ap_rst_n = '0' then
        tlast_counter <= (others => '0');
        dma_tx_size_counter <= (others => '0');
    elsif rising_edge(ap_clK) then
        if output_size_loopback_ap_vld = '1' then
            tlast_counter <= output_size_loopback;
            dma_tx_size_counter <= MAX_DMA_TX_SIZE(22 downto 0);
        elsif output_stream_tvalid_internal = '1' and output_stream_tlast_internal = '1' and output_stream_tready = '1' then
            tlast_counter <= std_logic_vector(unsigned(tlast_counter) - 1);
            if dma_tx_size_counter = x"0000001" then
              dma_tx_size_counter <= MAX_DMA_TX_SIZE(22 downto 0);
            else
              dma_tx_size_counter <= std_logic_vector(unsigned(dma_tx_size_counter) - 1);
            end if;
        end if;

    end if;
  end process tlast_counter_proc;

    clock <= ap_clk;
    reset <= not ap_rst_n;
    io_mult_res_valid <= output_stream_V_TVALID;
    io_mult_res_bits <= output_stream_V_TDATA;
    output_stream_V_TREADY <= io_mult_res_ready;
    io_row_len_valid <= row_size_stream_V_TVALID;
    io_row_len_bits <= row_size_stream_V_TDATA;
    row_size_stream_V_TREADY <= io_row_len_ready;

    tlast_gen: tlastgenerator
        port map(
            clock => clock,
            reset => reset,
            io_mult_res_ready => io_mult_res_ready,
            io_mult_res_valid => io_mult_res_valid,
            io_mult_res_bits => io_mult_res_bits,
            io_row_len_ready => io_row_len_ready,
            io_row_len_valid => io_row_len_valid,
            io_row_len_bits => io_row_len_bits,
            io_out_ready => io_out_ready,
            io_out_valid => io_out_valid,
            io_out_bits_data => io_out_bits_data,
            io_out_bits_last => io_out_bits_last
        );

    aclk <= ap_clk;
    aresetn <= ap_rst_n;
    s_axis_a_tvalid <= io_out_valid;
    s_axis_a_tdata <= io_out_bits_data;
    s_axis_a_tlast <= io_out_bits_last;
    io_out_ready <= s_axis_a_tready;

    fp_acc: floating_point_0
    port map(
        aclk => aclk,
        aresetn => aresetn,
        s_axis_a_tvalid => s_axis_a_tvalid,
        s_axis_a_tready => s_axis_a_tready,
        s_axis_a_tdata => s_axis_a_tdata,
        s_axis_a_tlast => s_axis_a_tlast,
        m_axis_result_tvalid => output_stream_tvalid_internal,
        m_axis_result_tready => output_stream_tready,
        m_axis_result_tdata => output_stream_tdata,
        m_axis_result_tuser => output_stream_tuser,
        m_axis_result_tlast => output_stream_tlast_internal
    );

    output_stream_tvalid <= output_stream_tvalid_internal and output_stream_tlast_internal;
    output_stream_tlast <= '1' when tlast_counter = x"00000001" or dma_tx_size_counter = x"0000001" else '0';

end Behavioral;
