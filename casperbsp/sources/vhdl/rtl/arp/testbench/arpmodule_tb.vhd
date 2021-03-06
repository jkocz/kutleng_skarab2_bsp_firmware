--------------------------------------------------------------------------------
-- Company          : Kutleng Dynamic Electronics Systems (Pty) Ltd            -
-- Engineer         : Benjamin Hector Hlophe                                   -
--                                                                             -
-- Design Name      : CASPER BSP                                               -
-- Module Name      : arpreceiver - rtl                                        -
-- Project Name     : SKARAB2                                                  -
-- Target Devices   : N/A                                                      -
-- Tool Versions    : N/A                                                      -
-- Description      : This module tests the arpmodule by stimulating it with   -
--                    data obtained from Wireshark to simulate real traffic    -
--                    conditions.                                              -
--                    TODO                                                     -
--                    The ARP module has only been tested for ARP, RARP data is-
--                    to be collected and used to test RARP.                   -
--                    Test packets longer than 64 bytes with wait states.      -
-- Dependencies     : arpmodule                                                -
-- Revision History : V1.0 - Initial design                                    -
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity arpmodule_tb is
end entity arpmodule_tb;

architecture behavorial of arpmodule_tb is
    component arpmodule is
        generic(
            G_SLOT_WIDTH : natural := 4
        );
        port(
            axis_clk          : in  STD_LOGIC;
            axis_reset        : in  STD_LOGIC;
            -- Setup information
            ARPMACAddress     : in  STD_LOGIC_VECTOR(47 downto 0);
            ARPIPAddress      : in  STD_LOGIC_VECTOR(31 downto 0);
            --Inputs from AXIS bus 
            axis_rx_tdata     : in  STD_LOGIC_VECTOR(511 downto 0);
            axis_rx_tvalid    : in  STD_LOGIC;
            axis_rx_tuser     : in  STD_LOGIC;
            axis_rx_tkeep     : in  STD_LOGIC_VECTOR(63 downto 0);
            axis_rx_tlast     : in  STD_LOGIC;
            --Outputs to AXIS bus 
            axis_tx_tpriority : out STD_LOGIC_VECTOR(G_SLOT_WIDTH - 1 downto 0);
            axis_tx_tdata     : out STD_LOGIC_VECTOR(511 downto 0);
            axis_tx_tvalid    : out STD_LOGIC;
            axis_tx_tready    : in  STD_LOGIC;
            axis_tx_tkeep     : out STD_LOGIC_VECTOR(63 downto 0);
            axis_tx_tlast     : out STD_LOGIC
        );
    end component arpmodule;

    signal axis_clk            : STD_LOGIC                      := '1';
    signal axis_reset          : STD_LOGIC                      := '1';
    constant C_SLOT_WIDTH      : natural                        := 4;
    constant C_ARP_MAC_ADDRESS : STD_LOGIC_VECTOR(47 downto 0)  := X"00_0A_35_02_41_92";
    constant C_ARP_IP_ADDRESS  : STD_LOGIC_VECTOR(31 downto 0)  := X"C0_A8_0A_0A";
    --Inputs from AXIS bus 
    signal axis_rx_tdata       : STD_LOGIC_VECTOR(511 downto 0) := (others => '0');
    signal axis_rx_tvalid      : STD_LOGIC                      := '0';
    signal axis_rx_tuser       : STD_LOGIC                      := '0';
    signal axis_rx_tkeep       : STD_LOGIC_VECTOR(63 downto 0)  := (others => '0');
    signal axis_rx_tlast       : STD_LOGIC                      := '0';
    --Outputs to AXIS bus 
    signal axis_tx_tpriority   : STD_LOGIC_VECTOR(C_SLOT_WIDTH - 1 downto 0);
    signal axis_tx_tdata       : STD_LOGIC_VECTOR(511 downto 0);
    signal axis_tx_tvalid      : STD_LOGIC;
    signal axis_tx_tready      : STD_LOGIC                      := '0';
    signal axis_tx_tkeep       : STD_LOGIC_VECTOR(63 downto 0);
    signal axis_tx_tlast       : STD_LOGIC;
    constant C_CLK_PERIOD      : time                           := 10 ns;
begin
    axis_clk   <= not axis_clk after C_CLK_PERIOD / 2;
    axis_reset <= '1', '0' after C_CLK_PERIOD * 20;

    UUT_i : arpmodule
        generic map(
            G_SLOT_WIDTH => C_SLOT_WIDTH
        )
        port map(
            axis_clk          => axis_clk,
            axis_reset        => axis_reset,
            ARPMACAddress     => C_ARP_MAC_ADDRESS,
            ARPIPAddress      => C_ARP_IP_ADDRESS,
            axis_tx_tpriority => axis_tx_tpriority,
            axis_tx_tdata     => axis_tx_tdata,
            axis_tx_tvalid    => axis_tx_tvalid,
            axis_tx_tready    => axis_tx_tready,
            axis_tx_tkeep     => axis_tx_tkeep,
            axis_tx_tlast     => axis_tx_tlast,
            axis_rx_tdata     => axis_rx_tdata,
            axis_rx_tvalid    => axis_rx_tvalid,
            axis_rx_tuser     => axis_rx_tuser,
            axis_rx_tkeep     => axis_rx_tkeep,
            axis_rx_tlast     => axis_rx_tlast
        );

    StimProc : process
    begin
        wait for C_CLK_PERIOD * 40;
        axis_tx_tready <= '1';
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"9ffdf0d5000000000000000000000000000000000000_0a0aa8c0_000000000000_960aa8c0_c6de9c9a0dec_0100_04_06_0008_0100_0608_c6de9c9a0dec_ffffffffffff";
        --expectaxis_tx_tdata <= X"00000000000000000000000000000000000000000000_960AA8C0_C6DE9C9A0DEC_0A0AA8C0_924102350A00_0200_04_06_0008_0100_0608_924102350A00C6DE9C9A0DEC";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD * 32;
        axis_rx_tvalid <= '0';
        axis_rx_tdata  <= (others => '0');
        axis_rx_tlast  <= '0';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= (others => '0');
        wait for C_CLK_PERIOD * 10;
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000_5001a8c0_000000000000_1001a8c0_70fe8e6acc4c_0100_04_06_0008_0100_0608_70fe8e6acc4c_ffffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000_5001a8c0_000000000000_1001a8c0_70fe8e6acc4c_0100_04_06_0008_0100_0608_70fe8e6acc4c_ffffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '0';
        axis_rx_tdata  <= (others => '0');
        axis_rx_tlast  <= '0';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= (others => '0');
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000_5501a8c0_000000000000_1001a8c0_70fe8e6acc4c_0100_04_06_0008_0100_0608_70fe8e6acc4c_ffffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '0';
        axis_rx_tdata  <= (others => '0');
        axis_rx_tlast  <= '0';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= (others => '0');
        wait for C_CLK_PERIOD * 10;
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000_5001a8c0_000000000000_1001a8c0_70fe8e6acc4c_0100_04_06_0008_0100_0608_70fe8e6acc4c_ffffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '1';
        axis_rx_tdata  <= X"00000000000000000000000000000000000000000000_5001a8c0_000000000000_1001a8c0_70fe8e6acc4c_0100_04_06_0008_0100_0608_70fe8e6acc4c_00ffffffffff";
        axis_rx_tlast  <= '1';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= X"0fffffffffffffff";
        wait for C_CLK_PERIOD;
        axis_rx_tvalid <= '0';
        axis_rx_tdata  <= (others => '0');
        axis_rx_tlast  <= '0';
        axis_rx_tuser  <= '0';
        axis_rx_tkeep  <= (others => '0');
        wait for C_CLK_PERIOD;

        wait;
    end process StimProc;

end architecture behavorial;
