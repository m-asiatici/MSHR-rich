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
    s_axi_AXILiteS_AWADDR : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_AXILiteS_AWVALID : IN STD_LOGIC;
      s_axi_AXILiteS_AWREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_WDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_AXILiteS_WSTRB : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_AXILiteS_WVALID : IN STD_LOGIC;
      s_axi_AXILiteS_WREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_AXILiteS_BVALID : OUT STD_LOGIC;
      s_axi_AXILiteS_BREADY : IN STD_LOGIC;
      s_axi_AXILiteS_ARADDR : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      s_axi_AXILiteS_ARVALID : IN STD_LOGIC;
      s_axi_AXILiteS_ARREADY : OUT STD_LOGIC;
      s_axi_AXILiteS_RDATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      s_axi_AXILiteS_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      s_axi_AXILiteS_RVALID : OUT STD_LOGIC;
      s_axi_AXILiteS_RREADY : IN STD_LOGIC;
      ap_clk : IN STD_LOGIC;
      ap_rst_n : IN STD_LOGIC;
      interrupt : OUT STD_LOGIC;
      m_axi_vect_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      m_axi_vect_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_ARLOCK : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      m_axi_vect_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      m_axi_vect_ARVALID : OUT STD_LOGIC;
      m_axi_vect_ARREADY : IN STD_LOGIC;
      m_axi_vect_RDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      m_axi_vect_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
      m_axi_vect_RLAST : IN STD_LOGIC;
      m_axi_vect_RVALID : IN STD_LOGIC;
      m_axi_vect_RREADY : OUT STD_LOGIC;
      val_stream_TVALID : IN STD_LOGIC;
      val_stream_TREADY : OUT STD_LOGIC;
      val_stream_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      val_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      val_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      col_ind_stream_TVALID : IN STD_LOGIC;
      col_ind_stream_TREADY : OUT STD_LOGIC;
      col_ind_stream_TDATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      col_ind_stream_TKEEP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      col_ind_stream_TLAST : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
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

    -- len_stream
    signal io_rdAddr_bits: std_logic_vector(1 downto 0);
    signal io_wrAddr_bits: std_logic_vector(1 downto 0);
    signal io_offset_valid: std_logic;
    signal io_offset_bits: std_logic_vector(31 downto 0);
    signal io_nnz_valid: std_logic;
    signal io_nnz_bits: std_logic_vector(31 downto 0);
    signal io_outputSize_valid: std_logic;
    signal io_outputSize_bits: std_logic_vector(31 downto 0);
    signal io_row_len_ready_internal: std_logic; -- as produced by len_stream, they will be gated by io_running before sending them to the TLAST generator
    signal io_row_len_valid_internal: std_logic;
    signal io_running: std_logic;
    signal io_done: std_logic;

    -- FP multiplier
    signal fp_mul_aclk : STD_LOGIC;
    signal fp_mul_s_axis_a_tvalid : STD_LOGIC;
    signal fp_mul_s_axis_a_tready : STD_LOGIC;
    signal fp_mul_s_axis_a_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fp_mul_s_axis_b_tvalid : STD_LOGIC;
    signal fp_mul_s_axis_b_tready : STD_LOGIC;
    signal fp_mul_s_axis_b_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fp_mul_m_axis_result_tvalid : STD_LOGIC;
    signal fp_mul_m_axis_result_tready : STD_LOGIC;
    signal fp_mul_m_axis_result_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fp_mul_m_axis_result_tuser : STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- FP accumulator
    signal fp_acc_aclk: STD_LOGIC;
    signal fp_acc_aresetn: STD_LOGIC;
    signal fp_acc_s_axis_a_tvalid: STD_LOGIC;
    signal fp_acc_s_axis_a_tready: STD_LOGIC;
    signal fp_acc_s_axis_a_tdata: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal fp_acc_s_axis_a_tlast: STD_LOGIC;

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
    signal offset_reg: std_logic_vector(31 downto 0);

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

    component AXISAndLenStream port (
    clock: in std_logic;
      reset: in std_logic;
      io_rdAddr_ready: out std_logic;
      io_rdAddr_valid: in std_logic;
      io_rdAddr_bits: in std_logic_vector(1 downto 0);
      io_rdData_ready: in std_logic;
      io_rdData_valid: out std_logic;
      io_rdData_bits: out std_logic_vector(31 downto 0);
      io_wrAddr_ready: out std_logic;
      io_wrAddr_valid: in std_logic;
      io_wrAddr_bits: in std_logic_vector(1 downto 0);
      io_wrData_ready: out std_logic;
      io_wrData_valid: in std_logic;
      io_wrData_bits: in std_logic_vector(31 downto 0);
      io_wrAck: out std_logic;
      io_offset_valid: out std_logic;
      io_offset_bits: out std_logic_vector(31 downto 0);
      io_nnz_valid: out std_logic;
      io_nnz_bits: out std_logic_vector(31 downto 0);
      io_outputSize_valid: out std_logic;
      io_outputSize_bits: out std_logic_vector(31 downto 0);
      io_running: out std_logic;
      io_done: in std_logic;
      io_rowPtrStream_ready: out std_logic;
      io_rowPtrStream_valid: in std_logic;
      io_rowPtrStream_bits: in std_logic_vector(31 downto 0);
      io_lenStream_ready: in std_logic;
      io_lenStream_valid: out std_logic;
      io_lenStream_bits: out std_logic_vector(31 downto 0)
    );
    end component;

    COMPONENT fpmul
      PORT (
        aclk : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_b_tvalid : IN STD_LOGIC;
        s_axis_b_tready : OUT STD_LOGIC;
        s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tuser : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
      );
    END COMPONENT;

    COMPONENT fpacc
      PORT (
        aclk : IN STD_LOGIC;
        aresetn : IN STD_LOGIC;
        s_axis_a_tvalid : IN STD_LOGIC;
        s_axis_a_tready : OUT STD_LOGIC;
        s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        s_axis_a_tlast : IN STD_LOGIC;
        m_axis_result_tvalid : OUT STD_LOGIC;
        m_axis_result_tready : IN STD_LOGIC;
        m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        m_axis_result_tuser : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        m_axis_result_tlast : OUT STD_LOGIC
      );
    END COMPONENT;
begin

  io_rdAddr_bits <= s_axi_AXILiteS_ARADDR(3 downto 2);
  io_wrAddr_bits <= s_axi_AXILiteS_AWADDR(3 downto 2);
  axis: AXISAndLenStream port map(
  clock => clock,
  reset => reset,
  io_rdAddr_ready => s_axi_AXILiteS_ARREADY,
  io_rdAddr_valid => s_axi_AXILiteS_ARVALID,
  io_rdAddr_bits  => io_rdAddr_bits,
  io_rdData_ready => s_axi_AXILiteS_RREADY,
  io_rdData_valid => s_axi_AXILiteS_RVALID,
  io_rdData_bits  => s_axi_AXILiteS_RDATA,
  io_wrAddr_ready => s_axi_AXILiteS_AWREADY,
  io_wrAddr_valid => s_axi_AXILiteS_AWVALID,
  io_wrAddr_bits  => io_wrAddr_bits,
  io_wrData_ready => s_axi_AXILiteS_WREADY,
  io_wrData_valid => s_axi_AXILiteS_WVALID,
  io_wrData_bits  => s_axi_AXILiteS_WDATA,
  io_wrAck        => s_axi_AXILiteS_BVALID,
  io_offset_valid => io_offset_valid,
  io_offset_bits  => io_offset_bits,
  io_nnz_valid    => io_nnz_valid,
  io_nnz_bits     => io_nnz_bits,
  io_outputSize_valid => io_outputSize_valid,
  io_outputSize_bits => io_outputSize_bits,
  io_running => io_running,
  io_done => io_done,
  io_rowPtrStream_ready => rowptr_stream_TREADY,
  io_rowPtrStream_valid => rowptr_stream_TVALID,
  io_rowPtrStream_bits  => rowptr_stream_TDATA,
  io_lenStream_ready    => io_row_len_ready_internal,
  io_lenStream_valid    => io_row_len_valid_internal,
  io_lenStream_bits     => io_row_len_bits
  );

  s_axi_AXILiteS_BRESP <= "00";
  s_axi_AXILiteS_RRESP <= "00";
  
  io_row_len_ready_internal <= io_row_len_ready and io_running;
  io_row_len_valid <= io_row_len_valid_internal and io_running;

  offset_reg_proc: process (ap_rst_n, ap_clk)
  begin
    if ap_rst_n = '0' then
        offset_reg <= (others => '0');
     elsif rising_edge(ap_clk) then
        if io_offset_valid = '1' then
            offset_reg <= io_offset_bits;
        end if;
     end if;
  end process offset_reg_proc;

  tlast_counter_proc: process(ap_rst_n, ap_clk)
  begin
    if ap_rst_n = '0' then
        tlast_counter <= (others => '0');
        dma_tx_size_counter <= (others => '0');
    elsif rising_edge(ap_clK) then
        if io_outputSize_valid = '1' then
            tlast_counter <= io_outputSize_bits;
            dma_tx_size_counter <= MAX_DMA_TX_SIZE(22 downto 0);
        elsif output_stream_tvalid_internal = '1' and output_stream_tlast_internal = '1' and output_stream_tready = '1' then
            tlast_counter <= std_logic_vector(unsigned(tlast_counter) - 1);
            if dma_tx_size_counter = "00000000000000000000001" then
              dma_tx_size_counter <= MAX_DMA_TX_SIZE(22 downto 0);
            else
              dma_tx_size_counter <= std_logic_vector(unsigned(dma_tx_size_counter) - 1);
            end if;
        end if;

    end if;
  end process tlast_counter_proc;

  fp_mul_aclk <= ap_clk;
  m_axi_vect_ARVALID <= col_ind_stream_TVALID and io_running;
  m_axi_vect_ARADDR <= std_logic_vector(unsigned(col_ind_stream_TDATA(29 downto 0) & "00") + unsigned(offset_reg));
  col_ind_stream_TREADY <= m_axi_vect_ARREADY and io_running;

  fp_mul_s_axis_a_tvalid <= m_axi_vect_RVALID;
  fp_mul_s_axis_a_tdata <= m_axi_vect_RDATA;
  m_axi_vect_RREADY <= fp_mul_s_axis_a_tready;

  fp_mul_s_axis_b_tvalid <= val_stream_TVALID;
  fp_mul_s_axis_b_tdata <= val_stream_TDATA;
  val_stream_TREADY <= fp_mul_s_axis_b_tready;

  m_axi_vect_ARLEN  <= (others => '0');
  m_axi_vect_ARSIZE <= "010"; -- 32 bit transfers, not bursted
  m_axi_vect_ARBURST <= "01"; -- INCR burst
  m_axi_vect_ARLOCK <= "00";
  m_axi_vect_ARCACHE <= "0000";
  m_axi_vect_ARPROT <= "000";

  fp_mul: fpmul
    PORT MAP (
      aclk => fp_mul_aclk,
      s_axis_a_tvalid => fp_mul_s_axis_a_tvalid,
      s_axis_a_tready => fp_mul_s_axis_a_tready,
      s_axis_a_tdata => fp_mul_s_axis_a_tdata,
      s_axis_b_tvalid => fp_mul_s_axis_b_tvalid,
      s_axis_b_tready => fp_mul_s_axis_b_tready,
      s_axis_b_tdata => fp_mul_s_axis_b_tdata,
      m_axis_result_tvalid => fp_mul_m_axis_result_tvalid,
      m_axis_result_tready => fp_mul_m_axis_result_tready,
      m_axis_result_tdata => fp_mul_m_axis_result_tdata,
      m_axis_result_tuser => fp_mul_m_axis_result_tuser
    );

    clock <= ap_clk;
    reset <= not ap_rst_n;
    io_mult_res_valid <= fp_mul_m_axis_result_tvalid;
    io_mult_res_bits <= fp_mul_m_axis_result_tdata;
    fp_mul_m_axis_result_tready <= io_mult_res_ready;

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

    fp_acc_aclk <= ap_clk;
    fp_acc_aresetn <= ap_rst_n;
    fp_acc_s_axis_a_tvalid <= io_out_valid;
    fp_acc_s_axis_a_tdata <= io_out_bits_data;
    fp_acc_s_axis_a_tlast <= io_out_bits_last;
    io_out_ready <= fp_acc_s_axis_a_tready;

    fp_acc: fpacc
    PORT MAP (
      aclk => fp_acc_aclk,
      aresetn => fp_acc_aresetn,
      s_axis_a_tvalid => fp_acc_s_axis_a_tvalid,
      s_axis_a_tready => fp_acc_s_axis_a_tready,
      s_axis_a_tdata => fp_acc_s_axis_a_tdata,
      s_axis_a_tlast => fp_acc_s_axis_a_tlast,
      m_axis_result_tvalid => output_stream_tvalid_internal,
      m_axis_result_tready => output_stream_tready,
      m_axis_result_tdata => output_stream_tdata,
      m_axis_result_tuser => output_stream_tuser,
      m_axis_result_tlast => output_stream_tlast_internal
    );

    output_stream_tvalid <= output_stream_tvalid_internal and output_stream_tlast_internal;
    output_stream_tlast <= '1' when tlast_counter = x"00000001" or dma_tx_size_counter = "00000000000000000000001" else '0';
    io_done <= '1' when tlast_counter = x"00000001" and output_stream_tvalid_internal = '1' and output_stream_tlast_internal = '1' and output_stream_tready = '1' else '0';

end Behavioral;
