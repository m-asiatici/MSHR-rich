----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.06.2018 14:16:43
-- Design Name: 
-- Module Name: TopLevelTB - Behavioral
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
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.txt_util.all;
use std.textio.all;
use ieee.STD_LOGIC_TEXTIO.all;

entity TopLevelTB is
--  Port ( );
end TopLevelTB;

architecture Behavioral of TopLevelTB is
    -- Simulation parameters
    constant CLK_PERIOD: time := 5 ns;
    constant MEM_LATENCY: integer := 200;
    constant MAX_MEM_INFLIGHT_REQUESTS: integer := 128;
    constant P_MEM_READY: real := 1.0;
    constant P_RESP_READY: real := 1.0;
    
    -- SpMV constants
    constant NUM_ROWS: integer := 100;
    constant NUM_COLS: integer := 100;
    constant NNZ: integer := 200;
    constant VAL_DATA_WIDTH: integer := 32;
    constant COL_DATA_WIDTH: integer := 32;
    constant SPMV_REG_DATA_WIDTH: integer := 32;
    constant SPMV_REG_ADDR_WIDTH: integer := 6;
    constant VAL_SIZE_REG_ADDR: integer := 16;
    constant OUTPUT_SIZE_REG_ADDR: integer := 24;
    constant VECT_BASE_PTR_REG_ADDR: integer := 32;
    constant VECT_BASE_PTR: integer := 0;
    constant STATUS_REG_ADDR: integer := 0;
    
    -- Control booleans
    signal done: boolean := false;
    
    -- Derived constants - DON'T TOUCH
    constant INPUT_FILE_SUFFIX: string := integer'image(NUM_ROWS) & "_" & integer'image(NUM_COLS) & "_" & integer'image(NNZ);

    signal s_axi_AXILiteS_AWADDR: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal s_axi_AXILiteS_AWVALID: STD_LOGIC;
    signal s_axi_AXILiteS_AWREADY: STD_LOGIC;
    signal s_axi_AXILiteS_WDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi_AXILiteS_WSTRB: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal s_axi_AXILiteS_WVALID: STD_LOGIC;
    signal s_axi_AXILiteS_WREADY: STD_LOGIC;
    signal s_axi_AXILiteS_BRESP: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi_AXILiteS_BVALID: STD_LOGIC;
    signal s_axi_AXILiteS_BREADY: STD_LOGIC;
    signal s_axi_AXILiteS_ARADDR: STD_LOGIC_VECTOR(5 DOWNTO 0);
    signal s_axi_AXILiteS_ARVALID: STD_LOGIC;
    signal s_axi_AXILiteS_ARREADY: STD_LOGIC;
    signal s_axi_AXILiteS_RDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal s_axi_AXILiteS_RRESP: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal s_axi_AXILiteS_RVALID: STD_LOGIC;
    signal s_axi_AXILiteS_RREADY: STD_LOGIC;
    signal ap_clk: STD_LOGIC;
    signal ap_rst_n: STD_LOGIC;
    signal interrupt: STD_LOGIC;
    signal m_axi_vect_AWADDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axi_vect_AWLEN: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal m_axi_vect_AWSIZE: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal m_axi_vect_AWBURST: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_AWLOCK: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_AWREGION: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_AWCACHE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_AWPROT: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal m_axi_vect_AWQOS: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_AWVALID: STD_LOGIC;
    signal m_axi_vect_AWREADY: STD_LOGIC;
    signal m_axi_vect_WDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axi_vect_WSTRB: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_WLAST: STD_LOGIC;
    signal m_axi_vect_WVALID: STD_LOGIC;
    signal m_axi_vect_WREADY: STD_LOGIC;
    signal m_axi_vect_BRESP: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_BVALID: STD_LOGIC;
    signal m_axi_vect_BREADY: STD_LOGIC;
    signal m_axi_vect_ARADDR: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axi_vect_ARLEN: STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal m_axi_vect_ARSIZE: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal m_axi_vect_ARBURST: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_ARLOCK: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_ARREGION: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_ARCACHE: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_ARPROT: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal m_axi_vect_ARQOS: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal m_axi_vect_ARVALID: STD_LOGIC;
    signal m_axi_vect_ARREADY: STD_LOGIC;
    signal m_axi_vect_RDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal m_axi_vect_RRESP: STD_LOGIC_VECTOR(1 DOWNTO 0);
    signal m_axi_vect_RLAST: STD_LOGIC;
    signal m_axi_vect_RVALID: STD_LOGIC;
    signal m_axi_vect_RREADY: STD_LOGIC;
    signal val_col_ind_stream_TVALID: STD_LOGIC;
    signal val_col_ind_stream_TREADY: STD_LOGIC;
    signal val_col_ind_stream_TDATA: STD_LOGIC_VECTOR(63 DOWNTO 0);
    signal val_col_ind_stream_TKEEP: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal val_col_ind_stream_TLAST: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal rowptr_stream_TVALID: STD_LOGIC;
    signal rowptr_stream_TREADY: STD_LOGIC;
    signal rowptr_stream_TDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal rowptr_stream_TKEEP: STD_LOGIC_VECTOR(3 DOWNTO 0);
    signal rowptr_stream_TLAST: STD_LOGIC_VECTOR(0 DOWNTO 0);
    signal output_stream_TVALID: STD_LOGIC;
    signal output_stream_TREADY: STD_LOGIC;
    signal output_stream_TDATA: STD_LOGIC_VECTOR(31 DOWNTO 0);
    signal output_stream_TUSER: STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal output_stream_TLAST: STD_LOGIC;
    
    signal reset: STD_LOGIC;
    
    -- Procedures
    procedure sync_wait_until_value (
       signal sig: in std_logic;
       constant val: in std_logic;
       signal clk: in std_logic) is
    begin
       while sig /= val loop
           wait until rising_edge(clk);
       end loop;
    end sync_wait_until_value;
    
    procedure sync_wait_until_value (
       signal sig: in boolean;
       constant val: in boolean;
       signal clk: in std_logic) is
    begin
       while sig /= val loop
           wait until rising_edge(clk);
       end loop;
    end sync_wait_until_value;
    
    
    procedure expect (
       sl: in std_logic;
       constant sig_name: in string;
       constant expected: in std_logic) is
    begin
       assert sl = expected
       report sig_name & " = " & str(sl) &
                      ", expected " & str(sl)
       severity error;
    end expect;
    
    procedure expect (
       slv: in std_logic_vector;
       constant sig_name: in string;
       constant expected: in std_logic_vector) is
    begin
       assert slv = expected
       report sig_name & " = " & str(slv) &
              ", expected " & str(expected)
       severity error;
    end expect;
    
    procedure expect (
       int: in integer;
       constant sig_name: in string;
       constant expected: in integer) is
    begin
       assert int = expected
       report sig_name & " = " & str(int) &
              ", expected " & str(expected)
       severity error;
    end expect;
    
    procedure expect (
       bool: in boolean;
       constant sig_name: in string;
       constant expected: in boolean) is
    begin
       assert bool = expected
       report sig_name & " = " & str(bool) &
              ", expected " & str(expected)
       severity error;
    end expect;
    
    procedure axi_write (
        constant addr: in std_logic_vector;
        constant data: in std_logic_vector;
        signal clock: in std_logic;
        signal AWADDR: out std_logic_vector;
        signal AWVALID: out std_logic;
        signal AWREADY: in std_logic;
        signal WDATA: out std_logic_vector;
        signal WSTRB: out std_logic_vector;
        signal WVALID: out std_logic;
        signal WREADY: in std_logic) is
    begin
        AWADDR <= addr;
        AWVALID <= '1';
        wait until rising_edge(clock);
        sync_wait_until_value(AWREADY, '1', clock);
        AWVALID <= '0';
        wait until rising_edge(clock);
        WVALID <= '1';
        WSTRB <= (others => '1');
        WDATA <= data;
        wait until rising_edge(clock);
        sync_wait_until_value(WREADY, '1', clock);
        WVALID <= '0';
        wait until rising_edge(clock);
        wait until rising_edge(clock);
    end axi_write;
    
begin

    dut: entity work.TopLevel
    port map(
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
        output_stream_TVALID => output_stream_TVALID,
        output_stream_TREADY => output_stream_TREADY,
        output_stream_TDATA => output_stream_TDATA,
        output_stream_TUSER => output_stream_TUSER,
        output_stream_TLAST => output_stream_TLAST
    );
    
    clk_generation: process
    begin
        if not done then
            ap_clk <= '1', '0' after CLK_PERIOD / 2;
            wait for CLK_PERIOD;
        else
            wait;
        end if;
    end process clk_generation;
    
    
    
    reset <= '1', '0' after 3 * CLK_PERIOD;
    ap_rst_n <= not reset;
    
    val_col_ind_stream_0: process
            constant file_name: string := "/home/asiatici/epfl/memory-coalescer/vivado/spmv/input_files/val_col_ind_" & INPUT_FILE_SUFFIX & "_0.txt";
            file text_input : text is in file_name;
            variable line_input  : line;
            variable col_tmp: integer;
            variable val_tmp: std_logic_vector(VAL_DATA_WIDTH-1 downto 0);
        begin
            val_col_ind_stream_TVALID <= '0';
            val_col_ind_stream_TKEEP <= (others => '1');
            val_col_ind_stream_TLAST <= (others => '0');
            sync_wait_until_value(reset, '0', ap_clk);
            wait until rising_edge(ap_clk);
            for i in 0 to NNZ-1 loop
            --while not endfile(text_input) loop
                readline(text_input, line_input);
                hread(line_input, val_tmp);
                read(line_input, col_tmp);
                val_col_ind_stream_TDATA <= std_logic_vector(to_unsigned(col_tmp, COL_DATA_WIDTH)) & val_tmp;
                val_col_ind_stream_TVALID <= '1';
                if i = NNZ-1 then
                    val_col_ind_stream_TLAST(0) <= '1';
                else
                    val_col_ind_stream_TLAST(0) <= '0';
                end if;
                wait until rising_edge(ap_clk);
                sync_wait_until_value(val_col_ind_stream_TREADY, '1', ap_clk);
            end loop;
            wait;
        end process val_col_ind_stream_0;
        
    start_spmv_0: process
    begin
        s_axi_AXILiteS_AWVALID <= '0';
        s_axi_AXILiteS_WVALID <= '0';
        s_axi_AXILiteS_ARVALID <= '0';
        s_axi_AXILiteS_BREADY <= '1';
        s_axi_AXILiteS_RREADY <= '1';
        sync_wait_until_value(reset, '0', ap_clk);
        wait until rising_edge(ap_clk);
    
        axi_write(std_logic_vector(to_unsigned(VAL_SIZE_REG_ADDR, SPMV_REG_ADDR_WIDTH)),
                  std_logic_vector(to_unsigned(NNZ, SPMV_REG_DATA_WIDTH)),
                  ap_clk,
                  s_axi_AXILiteS_AWADDR,
                  s_axi_AXILiteS_AWVALID,
                  s_axi_AXILiteS_AWREADY,
                  s_axi_AXILiteS_WDATA,
                  s_axi_AXILiteS_WSTRB,
                  s_axi_AXILiteS_WVALID,
                  s_axi_AXILiteS_WREADY);
    
        axi_write(std_logic_vector(to_unsigned(OUTPUT_SIZE_REG_ADDR, SPMV_REG_ADDR_WIDTH)),
                  std_logic_vector(to_unsigned(NUM_ROWS, SPMV_REG_DATA_WIDTH)),
                  ap_clk,
                  s_axi_AXILiteS_AWADDR,
                  s_axi_AXILiteS_AWVALID,
                  s_axi_AXILiteS_AWREADY,
                  s_axi_AXILiteS_WDATA,
                  s_axi_AXILiteS_WSTRB,
                  s_axi_AXILiteS_WVALID,
                  s_axi_AXILiteS_WREADY);
    
        axi_write(std_logic_vector(to_unsigned(VECT_BASE_PTR_REG_ADDR, SPMV_REG_ADDR_WIDTH)),
                  std_logic_vector(to_unsigned(VECT_BASE_PTR, SPMV_REG_DATA_WIDTH)),
                  ap_clk,
                  s_axi_AXILiteS_AWADDR,
                  s_axi_AXILiteS_AWVALID,
                  s_axi_AXILiteS_AWREADY,
                  s_axi_AXILiteS_WDATA,
                  s_axi_AXILiteS_WSTRB,
                  s_axi_AXILiteS_WVALID,
                  s_axi_AXILiteS_WREADY);   
        
        axi_write(std_logic_vector(to_unsigned(STATUS_REG_ADDR, SPMV_REG_ADDR_WIDTH)),
                  std_logic_vector(to_unsigned(1, SPMV_REG_DATA_WIDTH)),
                  ap_clk,
                  s_axi_AXILiteS_AWADDR,
                  s_axi_AXILiteS_AWVALID,
                  s_axi_AXILiteS_AWREADY,
                  s_axi_AXILiteS_WDATA,
                  s_axi_AXILiteS_WSTRB,
                  s_axi_AXILiteS_WVALID,
                  s_axi_AXILiteS_WREADY);  
        
        wait until rising_edge(ap_clk);
        wait until rising_edge(ap_clk);
        while true loop
            s_axi_AXILiteS_ARADDR <= std_logic_vector(to_unsigned(STATUS_REG_ADDR, SPMV_REG_ADDR_WIDTH));
            s_axi_AXILiteS_ARVALID <= '1';
            wait until rising_edge(ap_clk);
            sync_wait_until_value(s_axi_AXILiteS_ARREADY, '1', ap_clk);
            s_axi_AXILiteS_ARVALID <= '0';
            sync_wait_until_value(s_axi_AXILiteS_RVALID, '1', ap_clk);
            if s_axi_AXILiteS_RDATA(1) = '1' then
                -- wait for the TLAST generator to finish
                for i in 0 to 100 loop
                    wait until rising_edge(ap_clk);
                end loop;
                done <= true;
                wait;
            end if;
            wait until rising_edge(ap_clk);
        end loop;
    end process start_spmv_0;
        
    row_ptr_stream_0: process
        constant file_name: string := "/home/asiatici/epfl/memory-coalescer/vivado/spmv/input_files/row_ptr_" & INPUT_FILE_SUFFIX & "_0.txt";
        file text_input : text is in file_name;
        variable line_input  : line;
        variable row_ptr_tmp: integer;
        variable count: integer;
    begin
        rowptr_stream_TVALID <= '0';
        rowptr_stream_TKEEP <= (others => '1');
        rowptr_stream_TLAST <= (others => '0');
        sync_wait_until_value(reset, '0', ap_clk);
        wait until rising_edge(ap_clk);
        for i in 0 to NUM_ROWS loop
        --while not endfile(text_input) loop
            readline(text_input, line_input);
            read(line_input, row_ptr_tmp);
            rowptr_stream_TDATA <= std_logic_vector(to_unsigned(row_ptr_tmp, VAL_DATA_WIDTH));
            rowptr_stream_TVALID <= '1';
            if i = NUM_ROWS then
                rowptr_stream_TLAST(0) <= '1';
            else
                rowptr_stream_TLAST(0) <= '0';
            end if;
            wait until rising_edge(ap_clk);
            sync_wait_until_value(rowptr_stream_TREADY, '1', ap_clk);
        end loop;
        wait;
    end process row_ptr_stream_0;
    
    resp_collector_0: process
        constant exp_file_name: string := "/home/asiatici/epfl/memory-coalescer/vivado/spmv/spmv-hls/TopLevel/received_data_0.txt";
        file text_output : text is out exp_file_name;
        variable line_output  : line;
        
        variable seed1: positive;
        variable seed2: positive;
        variable rand: real;
        
        variable total_entries_found: integer := 0;
    begin
        output_stream_TREADY <= '0';
        sync_wait_until_value(reset, '0', ap_clk);
        wait until rising_edge(ap_clk);
        resp_collector_loop: loop
            uniform(seed1, seed2, rand);
            if rand < P_RESP_READY then
                output_stream_TREADY <= '1';
            else
                output_stream_TREADY <= '0';
            end if;
            if (output_stream_TREADY = '1') and (output_stream_TVALID = '1') then
                total_entries_found := total_entries_found + 1;
                write(line_output, hstr(output_stream_TDATA), right, 15);
                write(line_output, time'image(now), right, 15);
                writeline(text_output, line_output);
            end if;
            exit resp_collector_loop when total_entries_found >= NUM_ROWS;
            wait until rising_edge(ap_clk);
        end loop;
        wait;
    end process resp_collector_0;
    
    
    mem_emulator: process
        constant file_name: string := "/home/asiatici/epfl/memory-coalescer/vivado/spmv/input_files/vect_" & INPUT_FILE_SUFFIX & ".txt";
        file text_input : text is in file_name;
        variable line_input  : line;
        variable int_tmp: integer;
        variable data_tmp: std_logic_vector(31 downto 0);
        
        variable seed1: positive;
        variable seed2: positive;
        variable rand: real;
        
        type tag_in_flight_array is array(0 to MAX_MEM_INFLIGHT_REQUESTS-1) of std_logic_vector(29 downto 0);
        variable tags_in_flight: tag_in_flight_array;
        type data_array is array(0 to NUM_COLS-1) of std_logic_vector(31 downto 0);
        variable data: data_array;
        type int_array is array(0 to MAX_MEM_INFLIGHT_REQUESTS-1) of integer;
        variable expiration_times: int_array;
        variable tail_ptr: integer := 0;
        variable head_ptr: integer := 0;
        variable num_requests_in_flight: integer := 0;
        variable advance_to_next_response: boolean := true;
        variable found: boolean;
        variable i: integer := 0;
        variable curr_offset: integer := 0;
        variable curr_mem_line: integer := 0;
        
    begin
        for j in 0 to NUM_COLS-1 loop
            readline(text_input, line_input);
            hread(line_input, data_tmp);
            data(j) := data_tmp;
        end loop;
        for j in 0 to MAX_MEM_INFLIGHT_REQUESTS-1 loop
            expiration_times(j) := -1;
        end loop;
        i := 0;
        m_axi_vect_ARREADY <= '0';
        m_axi_vect_RVALID <= '0';
        sync_wait_until_value(reset, '0', ap_clk);
        wait until rising_edge(ap_clk);
        external_memory_loop: loop
            uniform(seed1, seed2, rand);
            if rand < P_MEM_READY and num_requests_in_flight < MAX_MEM_INFLIGHT_REQUESTS - 1 then
                m_axi_vect_ARREADY <= '1';
            else
                m_axi_vect_ARREADY <= '0';
            end if;
            -- Accept a new request
            if m_axi_vect_ARREADY = '1' and m_axi_vect_ARVALID = '1' then
                tags_in_flight(head_ptr) := m_axi_vect_ARADDR(31 downto 2);
                uniform(seed1, seed2, rand);
                expiration_times(head_ptr) := i + MEM_LATENCY;
                head_ptr := head_ptr + 1;
                if head_ptr = MAX_MEM_INFLIGHT_REQUESTS then
                    head_ptr := 0;
                end if;
                num_requests_in_flight := num_requests_in_flight + 1;
            end if;
            if advance_to_next_response then
                m_axi_vect_RVALID <= '0';
            end if;
            if ((expiration_times(tail_ptr) /= -1) and (i >= expiration_times(tail_ptr)) and advance_to_next_response) then
                m_axi_vect_RVALID <= '1';
                found := false;
                -- Retrieve the respective data
                m_axi_vect_RDATA <= data(to_integer(unsigned(tags_in_flight(tail_ptr))));
                expiration_times(tail_ptr) := -1;
                tail_ptr := tail_ptr + 1;
                if tail_ptr = MAX_MEM_INFLIGHT_REQUESTS then
                    tail_ptr := 0;
                end if;
            end if;
            wait until rising_edge(ap_clk);
            if m_axi_vect_RVALID = '1' then
                if m_axi_vect_RREADY = '1' then
                    advance_to_next_response := true;
                    num_requests_in_flight := num_requests_in_flight - 1;
                else
                    advance_to_next_response := false;
                end if;
            end if;
            i := i + 1;
            exit external_memory_loop when done;
        end loop;
        m_axi_vect_RVALID <= '0';
        wait;
    end process mem_emulator;

end Behavioral;
