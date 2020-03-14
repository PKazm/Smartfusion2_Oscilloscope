--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_Sample_Loader.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- FFT_Sample_Loader takes data write requests from outside the FFT and writes
-- them into a RAM block. 1 sample per write request. The configuration of the
-- RAM block (uSRAM, LSRAM, fabric FF, etc.) is unknown to FFT_Sample_Loader.
--
-- The Only assumption is that the data is being stored in the RAM with a depth
-- of SAMPLE_WIDTH * 2. The REAL value in the LSB and the IMAGINARY in the MSB.
-- This FFT design also assumes the IMAGINARY values are initially zero.
-- This version does not allow the option to start the imaginary values at
-- anything other than zero.
--
-- The parent entity will connect the appropriate RAM blocks to the FFT_Sample_Loader
-- ports and indicate when writing is ready.
--
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FFT_package.all;

entity FFT_Sample_Loader is
generic (
    --g_data_width : natural := 8;
    --g_samples_exp : natural := 5
    g_sync_input : natural := 0
);
port (
    PCLK : in std_logic;
    RSTn : in std_logic;

    -- connections to sample generator
    input_w_en : in std_logic;
    input_w_dat_real : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    input_w_dat_imag : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    input_done : in std_logic;

    input_w_ready : out std_logic;
    input_full : out std_logic;
    -- connections to sample generator


    -- connections to FFT RAM block
    ram_stable : in std_logic;
    ram_ready : in std_logic;

    ram_valid : out std_logic;
    ram_done : out std_logic;

    ram_w_en : out w_en_array_type;
    ram_adr : out adr_array_type;
    ram_dat_w : out ram_dat_array_type;
    ram_dat_r : in ram_dat_array_type;
    -- connections to FFT RAM block

    ram_adr_start : out std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0)
);
end FFT_Sample_Loader;
architecture architecture_FFT_Sample_Loader of FFT_Sample_Loader is

    type load_states is (sreset, paused, ready, writing);
    signal load_state : load_states;
    signal load_state_last : load_states;
    type input_data_type is array(1 downto 0) of std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);

    signal input_w_en_sync : std_logic_vector(1 downto 0);
    signal input_w_dat_real_sync : input_data_type;
    signal input_w_dat_imag_sync : input_data_type;
    signal input_done_sync : std_logic_vector(1 downto 0);

    signal input_w_en_sig : std_logic;
    signal input_w_en_last : std_logic;
    signal input_w_dat_real_sig : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal input_w_dat_imag_sig : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal input_done_sig : std_logic;
    signal input_w_ready_sig : std_logic;
    signal input_full_sig : std_logic;


    signal ram_stable_sig : std_logic;
    signal ram_ready_sig : std_logic;
    signal ram_valid_sig : std_logic;
    signal ram_done_sig : std_logic;
    signal ram_w_en_sig : w_en_array_type;
    --signal ram_r_en : r_en_array_type;
    signal ram_adr_sig : adr_array_type;
    signal ram_dat_w_sig : ram_dat_array_type;
    signal ram_dat_r_sig : ram_dat_array_type;

    signal ram_adr_start_sig : unsigned(SAMPLE_CNT_EXP - 1 downto 0);

    --signal r_en : std_logic;
    --signal data_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    --signal data_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal mem_adr : unsigned(SAMPLE_CNT_EXP - 1 downto 0);
    signal mem_adr_bitrev : unsigned(SAMPLE_CNT_EXP - 1 downto 0);
    signal data_in_full : std_logic;

begin

    ram_stable_sig <= ram_stable;
    ram_ready_sig <= ram_ready;

    ram_valid <= ram_valid_sig;
    ram_done <= ram_done_sig;

    ram_w_en <= ram_w_en_sig;
    ram_adr <= ram_adr_sig;
    ram_dat_w <= ram_dat_w_sig;

    ram_dat_r_sig <= ram_dat_r;

    ram_adr_start <= std_logic_vector(ram_adr_start_sig);

    -- load_sample process will be reset on RSTn = '0' and when mem_block_state changes
    -- mem_adr will increment and overflow to create a circular memory block
    -- when mem_adr = SAMPLE_CNT - 1 for the first time, data_in_full will be set to 1
    -- when mem_block_state changes, the last mem_adr will be stored for reference by other processes
    --      and data_in_full will be set to 0

    --=========================================================================


    gen_input_nosync : if(g_sync_input = 0) generate
        p_input_sync : process(PCLK, RSTn)
        begin
            if(RSTn = '0') then
                input_w_en_last <= '0';
            elsif(rising_edge(PCLK)) then
                input_w_en_last <= input_w_en_sig;
            end if;
        end process;

        input_w_en_sig <= input_w_en;
        input_w_dat_real_sig <= input_w_dat_real;
        input_w_dat_imag_sig <= input_w_dat_imag;
        input_done_sig <= input_done;
    end generate gen_input_nosync;

    gen_input_sync : if(g_sync_input /= 0) generate
        p_input_sync : process(PCLK, RSTn)
        begin
            if(RSTn = '0') then
                input_w_en_sync <= (others => '0');
                input_w_dat_real_sync <= (others => (others => '0'));
                input_w_dat_imag_sync <= (others => (others => '0'));
                input_done_sync <= (others => '0');
                input_w_en_last <= '0';
            elsif(rising_edge(PCLK)) then
                input_w_en_sync(0) <= input_w_en;
                input_w_dat_real_sync(0) <= input_w_dat_real;
                input_w_dat_imag_sync(0) <= input_w_dat_imag;
                input_done_sync(0) <= input_done;
                input_w_en_sync(1) <= input_w_en_sync(0);
                input_w_dat_real_sync(1) <= input_w_dat_real_sync(0);
                input_w_dat_imag_sync(1) <= input_w_dat_imag_sync(0);
                input_done_sync(1) <= input_done_sync(0);

                input_w_en_last <= input_w_en_sig;
            end if;
        end process;

        input_w_en_sig <= input_w_en_sync(1);
        input_w_dat_real_sig <= input_w_dat_real_sync(1);
        input_w_dat_imag_sig <= input_w_dat_imag_sync(1);
        input_done_sig <= input_done_sync(1);
    end generate gen_input_sync;

    input_w_ready <= input_w_ready_sig;
    input_full <= input_full_sig;

    --=========================================================================

    -- I should make this a FSM
    -- RAM not ready, RAM ready, Writing, write finished, memory increment

    p_load_state_manager : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            load_state <= sreset;
            load_state_last <= sreset;
            data_in_full <= '0';
            mem_adr <= (others => '0');
            ram_adr_start_sig <= (others => '0');
            input_w_ready_sig <= '0';
            ram_w_en_sig <= (others => '0');
        elsif(rising_edge(PCLK)) then
            case load_state is
                when sreset =>
                    if((ram_stable_sig = '1') and (ram_ready_sig = '1')) then
                        load_state <= ready;
                    end if;
                    data_in_full <= '0';
                    mem_adr <= (others => '0');
                    ram_adr_start_sig <= (others => '0');
                    input_w_ready_sig <= '0';
                    ram_w_en_sig <= (others => '0');
                when paused =>
                    if((ram_stable_sig = '1') and (ram_ready_sig = '1')) then
                        load_state <= ready;
                    end if;
                    input_w_ready_sig <= '0';
                    ram_w_en_sig(0) <= '0';
                when ready =>
                    if(input_w_en_last = '0' and input_w_en_sig = '1') then
                        load_state <= writing;
                    end if;

                    input_w_ready_sig <= '1';
                    ram_w_en_sig(0) <= '0';

                    if(load_state_last = writing) then
                        if(mem_adr /= SAMPLE_CNT - 1) then
                            mem_adr <= mem_adr + 1;
                            if(data_in_full = '1') then
                                ram_adr_start_sig <= ram_adr_start_sig + 1;
                            end if;
                        else
                            mem_adr <= (others => '0');
                            ram_adr_start_sig <= (others => '0');
                            data_in_full <= '1';
                        end if;
                    end if;
                when writing =>
                    load_state <= ready;
                    input_w_ready_sig <= '0';
                    ram_w_en_sig(0) <= '1';
                when others =>
                    load_state <= sreset;
            end case;
            
            load_state_last <= load_state;

            if(ram_stable_sig = '0') then
                load_state <= sreset;
            elsif((ram_stable_sig = '1') and (ram_ready_sig = '0')) then
                load_state <= paused;
            end if;
            
        end if;
    end process;

    ram_adr_sig(0) <= std_logic_vector(mem_adr);--std_logic_vector(in_mem_adr_bitrev);
    ram_adr_sig(1) <= (others => '0');
    ram_dat_w_sig(0) <= input_w_dat_imag_sig & input_w_dat_real_sig when load_state /= sreset and load_state /= paused else (others => '0');
    ram_dat_w_sig(1) <= (others => '0');
    ram_valid_sig <= data_in_full;
    ram_done_sig <= input_done_sig;
    input_full_sig <= data_in_full;
    -- architecture body
end architecture_FFT_Sample_Loader;
