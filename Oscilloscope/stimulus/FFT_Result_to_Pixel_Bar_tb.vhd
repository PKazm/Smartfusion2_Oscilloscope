----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Mar 12 21:23:26 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_Result_to_Pixel_Bar_tb.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FFT_package.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    component FFT_Result_to_Pixel_Bar
        generic (
            g_adr_width : natural;
            g_dat_width : natural
        );
        -- ports
        port( 
            PCLK : in std_logic;
            RSTn : in std_logic;

            fft_r_en : out std_logic;
            fft_read_done : out std_logic;
            fft_smpl_adr : out std_logic_vector(g_adr_width - 1 downto 0);
            fft_val_real : in std_logic_vector(g_dat_width - 1 downto 0);
            fft_val_imag : in std_logic_vector(g_dat_width - 1 downto 0);
            fft_dat_ready : in std_logic;
            fft_dat_valid : in std_logic;

            -- APB connections
            PADDR : in std_logic_vector(7 downto 0);
            PSEL : in std_logic;
            PENABLE : in std_logic;
            PWRITE : in std_logic;
            PWDATA : in std_logic_vector(7 downto 0);
            PREADY : out std_logic;
            PRDATA : out std_logic_vector(7 downto 0);
            PSLVERR : out std_logic;

            INT : out std_logic
            -- APB connections
        );
    end component;

    signal fft_r_en : std_logic;
    signal fft_read_done : std_logic;
    signal fft_smpl_adr : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal fft_val_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal fft_val_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal fft_dat_ready : std_logic;
    signal fft_dat_valid : std_logic;

    -- APB connections
    signal PADDR : std_logic_vector(7 downto 0);
    signal PSEL : std_logic;
    signal PENABLE : std_logic;
    signal PWRITE : std_logic;
    signal PWDATA : std_logic_vector(7 downto 0);
    signal PREADY : std_logic;
    signal PRDATA : std_logic_vector(7 downto 0);
    signal PSLVERR : std_logic;

    signal INT : std_logic;
    -- APB connections

    constant DAT_WIDTH : natural := 9;

    signal PbCr_0_Pixel_bar_out_spy : std_logic_vector(4 * 8 - 1 downto 0);
    signal AMpBM_0_o_flow_sig_spy : std_logic;
    signal AMpBM_0_result_sig_spy : std_logic_vector(DAT_WIDTH - 1 downto 0);

    --constant 

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  FFT_Result_to_Pixel_Bar
    FFT_Result_to_Pixel_Bar_0 : FFT_Result_to_Pixel_Bar
        generic map(
            g_adr_width => SAMPLE_CNT_EXP,
            g_dat_width => SAMPLE_WIDTH_INT
        )
        -- port map
        port map( 
            PCLK => SYSCLK,
            RSTn => NSYSRESET,

            fft_r_en => fft_r_en,
            fft_read_done => fft_read_done,
            fft_smpl_adr => fft_smpl_adr,
            fft_val_real => fft_val_real,
            fft_val_imag => fft_val_imag,
            fft_dat_ready => fft_dat_ready,
            fft_dat_valid => fft_dat_valid,

            -- APB connections
            PADDR => PADDR,
            PSEL => PSEL,
            PENABLE => PENABLE,
            PWRITE => PWRITE,
            PWDATA => PWDATA,
            PREADY => PREADY,
            PRDATA => PRDATA,
            PSLVERR => PSLVERR,

            INT => INT
            -- APB connections
        );

    spy_process : process
    begin
        init_signal_spy("FFT_Result_to_Pixel_Bar_0/PbCr_0_Pixel_bar_out", "PbCr_0_Pixel_bar_out_spy", 1, -1);
        init_signal_spy("FFT_Result_to_Pixel_Bar_0/AMpBM_0_o_flow_sig", "AMpBM_0_o_flow_sig_spy", 1, -1);
        init_signal_spy("FFT_Result_to_Pixel_Bar_0/AMpBM_0_result_sig", "AMpBM_0_result_sig_spy", 1, -1);
        wait;
    end process;

    THE_STUFF : process
    begin

        fft_val_real <= (others => '0');
        fft_val_imag <= (others => '0');
        fft_dat_ready <= '0';
        fft_dat_valid <= '0';

        PADDR <= (others => '0');
        PSEL <= '0';
        PENABLE <= '0';
        PWRITE <= '0';
        PWDATA <= (others => '0');

        wait until (NSYSRESET = '1');

        wait for (SYSCLK_PERIOD * 1);

        PADDR <= X"00";
        PSEL <= '1';
        PENABLE <= '1';
        PWRITE <= '0';
        PWDATA <= (others => '0');

        fft_val_real <= "0" & X"E0";
        fft_val_imag <= "0" & X"5A";
        fft_dat_ready <= '1';
        fft_dat_valid <= '1';

        wait for (SYSCLK_PERIOD * 1);

        wait;
    end process;

end behavioral;

