--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT.vhd
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

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.FFT_package.all;

entity FFT is
--generic (
    --g_data_width : natural := 8;
    --g_samples_exp : natural := 5
    --g_sync_smpl_load_input : natural := 0;
    --g_sync_smpl_outp_input : natural := 0;
    --g_buffer_sample_output : natural := 0
--);
port (
    PCLK : in std_logic;
    RSTn : in std_logic;

    -- ports related to writing samples into the FFT
    in_w_en : in std_logic;        -- risinge edge: write data into current mem_loc, falling_edge: increment mem_adr
    in_w_data_real : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    in_w_data_imag : in std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    in_w_done : in std_logic;
    in_w_ready : out std_logic;      -- FFT memory is ready for sample data
    in_full : out std_logic;       -- FFT memory is full and is now overwriting older samples circularly
    -- ports related to writing samples into the FFT

    -- ports related to reading results of FFT
    out_r_en : in std_logic;           -- sets when to output data based on address
    out_data_adr : in std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);     -- asynchronous memory address
    out_read_done : in std_logic;   -- external device has read all the data it needed
    out_dat_real : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    out_dat_imag : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    out_data_ready : out std_logic;     -- indicates when output data is ready to be read
    out_valid : out std_logic        -- indicates when output data is accurate to input address
    -- ports related to reading results of FFT
);
end FFT;
architecture architecture_FFT of FFT is

    signal port_in_w_data_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal port_in_w_data_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal port_in_w_en : std_logic;
    signal port_in_w_done : std_logic;
    signal port_in_w_ready : std_logic;
    signal port_in_full : std_logic;

    signal port_out_r_en : std_logic;
    signal port_out_data_adr : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal port_out_read_done : std_logic;
    signal port_out_dat_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal port_out_dat_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal port_out_data_ready : std_logic;
    signal port_out_valid : std_logic;

    --=========================================================================
    component FFT_Sample_Loader
        generic (
            --g_data_width : natural := 8;
            --g_samples_exp : natural := 5
            g_sync_input : natural
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
    end component;

    signal i_comp_input_w_en : std_logic;
    signal i_comp_input_w_dat_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal i_comp_input_w_dat_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal i_comp_input_done : std_logic;
    signal i_comp_input_w_ready : std_logic;
    signal i_comp_input_full : std_logic;
    signal i_comp_ram_stable : std_logic;
    signal i_comp_ram_ready : std_logic;
    signal i_comp_ram_valid : std_logic;
    signal i_comp_ram_done : std_logic;
    signal i_comp_ram_w_en : w_en_array_type;
    signal i_comp_ram_adr : adr_array_type;
    signal i_comp_ram_dat_w : ram_dat_array_type;
    signal i_comp_ram_dat_r : ram_dat_array_type;
    signal i_comp_ram_adr_start : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);

    --=========================================================================
    component FFT_Sample_Outputer
        generic (
            --g_data_width : natural := 8;
            --g_samples_exp : natural := 5
            g_sync_input : natural;
            g_buffer_output : natural
        );
        port (
            PCLK : in std_logic;
            RSTn : in std_logic;

            -- connections to sample generator
            output_en : in std_logic;
            output_adr : in std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
            output_done : in std_logic;
            output_real : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            output_imag : out std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
            output_ready : out std_logic;
            output_valid : out std_logic;
            -- connections to sample generator


            -- connections to FFT RAM block
            ram_stable : in std_logic;
            ram_ready : in std_logic;
            ram_valid : out std_logic;
            ram_done : out std_logic;
            ram_w_en : out w_en_array_type;
            ram_adr : out adr_array_type;
            ram_dat_w : out ram_dat_array_type;
            ram_dat_r : in ram_dat_array_type
            -- connections to FFT RAM block
        );
    end component;

    signal o_comp_output_en : std_logic;
    signal o_comp_output_adr : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal o_comp_output_done : std_logic;
    signal o_comp_output_real : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal o_comp_output_imag : std_logic_vector(SAMPLE_WIDTH_INT - 1 downto 0);
    signal o_comp_output_ready : std_logic;
    signal o_comp_output_valid : std_logic;
    signal o_comp_ram_stable : std_logic;
    signal o_comp_ram_ready : std_logic;
    signal o_comp_ram_valid : std_logic;
    signal o_comp_ram_done : std_logic;
    signal o_comp_ram_w_en : w_en_array_type;
    signal o_comp_ram_adr : adr_array_type;
    signal o_comp_ram_dat_w : ram_dat_array_type;
    signal o_comp_ram_dat_r : ram_dat_array_type;

    --=========================================================================
    component FFT_Transformer
        port (
            PCLK : in std_logic;
            RSTn : in std_logic;

            -- connections to FFT RAM block
            ram_stable : in std_logic;
            ram_ready : in std_logic;

            ram_assigned : in std_logic;
            ram_returned : out std_logic;

            ram_valid : out std_logic;
            ram_done : out std_logic;

            ram_adr_start : in std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);

            ram_w_en_0 : out w_en_array_type;
            ram_adr_0 : out adr_array_type;
            ram_dat_w_0 : out ram_dat_array_type;
            ram_dat_r_0 : in ram_dat_array_type;
            ram_w_en_1 : out w_en_array_type;
            ram_adr_1 : out adr_array_type;
            ram_dat_w_1 : out ram_dat_array_type;
            ram_dat_r_1 : in ram_dat_array_type
            -- connections to FFT RAM block
        );
    end component;

    signal tf_comp_ram_stable : std_logic;
    signal tf_comp_ram_ready : std_logic;
    signal tf_comp_ram_assigned : std_logic;
    signal tf_comp_ram_returned : std_logic;
    signal tf_comp_ram_valid : std_logic;
    signal tf_comp_ram_done : std_logic;
    signal tf_comp_ram_adr_start : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal tf_comp_ram_w_en_0 : w_en_array_type;
    signal tf_comp_ram_adr_0 : adr_array_type;
    signal tf_comp_ram_dat_w_0 : ram_dat_array_type;
    signal tf_comp_ram_dat_r_0 : ram_dat_array_type;
    signal tf_comp_ram_w_en_1 : w_en_array_type;
    signal tf_comp_ram_adr_1 : adr_array_type;
    signal tf_comp_ram_dat_w_1 : ram_dat_array_type;
    signal tf_comp_ram_dat_r_1 : ram_dat_array_type;
    --=========================================================================

    component DPSRAM_C0
        port (
            CLK : in std_logic;
            A_WEN : in std_logic;
            A_ADDR : in std_logic_vector(9 downto 0);
            A_DIN : in std_logic_vector(17 downto 0);
            A_DOUT : out std_logic_vector(17 downto 0);
            B_WEN : in std_logic;
            B_ADDR : in std_logic_vector(9 downto 0);
            B_DIN : in std_logic_vector(17 downto 0);
            B_DOUT : out std_logic_vector(17 downto 0)
        );
    end component;

    signal A_WEN_0 : std_logic;
    signal A_ADDR_0 : std_logic_vector(9 downto 0);
    signal A_ADDR_0_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal A_DIN_0 : std_logic_vector(17 downto 0);
    signal A_DOUT_0 : std_logic_vector(17 downto 0);
    signal B_WEN_0 : std_logic;
    signal B_ADDR_0 : std_logic_vector(9 downto 0);
    signal B_ADDR_0_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal B_DIN_0 : std_logic_vector(17 downto 0);
    signal B_DOUT_0 : std_logic_vector(17 downto 0);

    signal A_WEN_1 : std_logic;
    signal A_ADDR_1 : std_logic_vector(9 downto 0);
    signal A_ADDR_1_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal A_DIN_1 : std_logic_vector(17 downto 0);
    signal A_DOUT_1 : std_logic_vector(17 downto 0);
    signal B_WEN_1 : std_logic;
    signal B_ADDR_1 : std_logic_vector(9 downto 0);
    signal B_ADDR_1_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal B_DIN_1 : std_logic_vector(17 downto 0);
    signal B_DOUT_1 : std_logic_vector(17 downto 0);

    signal A_WEN_2 : std_logic;
    signal A_ADDR_2 : std_logic_vector(9 downto 0);
    signal A_ADDR_2_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal A_DIN_2 : std_logic_vector(17 downto 0);
    signal A_DOUT_2 : std_logic_vector(17 downto 0);
    signal B_WEN_2 : std_logic;
    signal B_ADDR_2 : std_logic_vector(9 downto 0);
    signal B_ADDR_2_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal B_DIN_2 : std_logic_vector(17 downto 0);
    signal B_DOUT_2 : std_logic_vector(17 downto 0);

    signal A_WEN_3 : std_logic;
    signal A_ADDR_3 : std_logic_vector(9 downto 0);
    signal A_ADDR_3_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal A_DIN_3 : std_logic_vector(17 downto 0);
    signal A_DOUT_3 : std_logic_vector(17 downto 0);
    signal B_WEN_3 : std_logic;
    signal B_ADDR_3 : std_logic_vector(9 downto 0);
    signal B_ADDR_3_temp : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);
    signal B_DIN_3 : std_logic_vector(17 downto 0);
    signal B_DOUT_3 : std_logic_vector(17 downto 0);


    --=========================================================================

    type hot_potato_states is(idle, unstable);
    signal hot_potato_state : hot_potato_states;
    --signal ram_blocks : ram_block_mem;
    signal i_comp_ram_index : natural range 0 to SAMPLE_BLOCKS -1;
    signal tf_comp_ram_index_0 : natural range 0 to SAMPLE_BLOCKS -1;
    signal tf_comp_ram_index_1 : natural range 0 to SAMPLE_BLOCKS -1;
    signal o_comp_ram_index : natural range 0 to SAMPLE_BLOCKS -1;
    signal ram_valid : std_logic_vector(SAMPLE_BLOCKS -1 downto 0);
    signal ram_adr_start : std_logic_vector(SAMPLE_CNT_EXP - 1 downto 0);

    signal DPSRAM_0_assoc : natural range 0 to 3;
    signal DPSRAM_1_assoc : natural range 0 to 3;
    signal DPSRAM_2_assoc : natural range 0 to 3;
    signal DPSRAM_3_assoc : natural range 0 to 3;


begin

    port_in_w_en <= in_w_en;
    port_in_w_data_real <= in_w_data_real;
    port_in_w_data_imag <= in_w_data_imag;
    port_in_w_done <= in_w_done;
    in_w_ready <= port_in_w_ready;
    in_full <= port_in_full;

    port_out_r_en <= out_r_en;
    port_out_data_adr <= out_data_adr;
    port_out_read_done <= out_read_done;
    out_dat_real <= port_out_dat_real;
    out_dat_imag <= port_out_dat_imag;
    out_data_ready <= port_out_data_ready;
    out_valid <= port_out_valid;

--=========================================================================

    p_ram_hot_potato : process(PCLK, RSTn)
        variable rotate_done : std_logic;
    begin
        if(RSTn = '0') then
            hot_potato_state <= idle;
            i_comp_ram_index <= 0;
            tf_comp_ram_index_0 <= 1;
            tf_comp_ram_index_1 <= 2;
            o_comp_ram_index <= 3;
            i_comp_ram_stable <= '0';
            o_comp_ram_stable <= '0';
            tf_comp_ram_stable <= '0';
            ram_valid <= (others => '0');
            ram_adr_start <= (others => '0');
            tf_comp_ram_assigned <= '0';
            rotate_done := '0';
        elsif(rising_edge(PCLK)) then
            case hot_potato_state is
                when idle =>
                    if(i_comp_ram_done = '1' and tf_comp_ram_done = '1' and o_comp_ram_done = '1') then
                        if(rotate_done = '0') then
                            hot_potato_state <= unstable;
                            i_comp_ram_stable <= '0';
                            i_comp_ram_ready <= '0';
                            o_comp_ram_stable <= '0';
                            --o_comp_ram_ready <= '0';
                            tf_comp_ram_stable <= '0';
                            --tf_comp_ram_ready <= '0';
                        end if;
                    else
                        rotate_done := '0';
                        i_comp_ram_stable <= '1';
                        i_comp_ram_ready <= '1';
                        o_comp_ram_stable <= '1';
                        --o_comp_ram_ready <= '1';
                        tf_comp_ram_stable <= '1';
                        --tf_comp_ram_ready <= '1';
                    end if;
                when unstable =>
                    hot_potato_state <= idle;
                    rotate_done := '1';
                    -- all components are finished with their RAM blocks, do rotation
                    ram_valid(i_comp_ram_index) <= i_comp_ram_valid;

                    -- send input block to TF
                    tf_comp_ram_assigned <= tf_comp_ram_returned;
                    if(tf_comp_ram_returned = '0') then
                        tf_comp_ram_index_0 <= i_comp_ram_index;
                    else
                        tf_comp_ram_index_1 <= i_comp_ram_index;
                    end if;
                    ram_adr_start <= i_comp_ram_adr_start;

                    -- send TF block to output
                    if(tf_comp_ram_returned = '0') then
                        o_comp_ram_index <= tf_comp_ram_index_0;
                        ram_valid(tf_comp_ram_index_0) <= tf_comp_ram_valid;
                    else
                        o_comp_ram_index <= tf_comp_ram_index_1;
                        ram_valid(tf_comp_ram_index_1) <= tf_comp_ram_valid;
                    end if;
                    
                    -- send output block to input
                    i_comp_ram_index <= o_comp_ram_index;
                    ram_valid(o_comp_ram_index) <= '0';

                    -- general toggle off, toggle on stuff here
                when others =>
                    hot_potato_state <= idle;
            end case;
        end if;
    end process;

    tf_comp_ram_adr_start <= ram_adr_start;
    tf_comp_ram_ready <= ram_valid(tf_comp_ram_index_0) when tf_comp_ram_assigned = '0' else ram_valid(tf_comp_ram_index_1);
    o_comp_ram_ready <= ram_valid(o_comp_ram_index);

--=========================================================================

    -- if component indexes are not all different [0,1,2,3], you're in trouble
    -- this generates latches... fixing it is like a bajillion lines of repetitive code so lets see...
    process(PCLK, RSTn)--i_comp_ram_index, o_comp_ram_index, tf_comp_ram_index_0, tf_comp_ram_index_1)
    begin
        if(RSTn = '0') then
            DPSRAM_0_assoc <= 0;
            DPSRAM_1_assoc <= 1;
            DPSRAM_2_assoc <= 2;
            DPSRAM_3_assoc <= 3;
        elsif(rising_edge(PCLK)) then
            case i_comp_ram_index is
                when 0 =>
                    DPSRAM_0_assoc <= 0;
                when 1 =>
                    DPSRAM_1_assoc <= 0;
                when 2 =>
                    DPSRAM_2_assoc <= 0;
                when 3 =>
                    DPSRAM_3_assoc <= 0;
                when others =>
            end case;

            case tf_comp_ram_index_0 is
                when 0 =>
                    DPSRAM_0_assoc <= 1;
                when 1 =>
                    DPSRAM_1_assoc <= 1;
                when 2 =>
                    DPSRAM_2_assoc <= 1;
                when 3 =>
                    DPSRAM_3_assoc <= 1;
                when others =>
            end case;

            case tf_comp_ram_index_1 is
                when 0 =>
                    DPSRAM_0_assoc <= 2;
                when 1 =>
                    DPSRAM_1_assoc <= 2;
                when 2 =>
                    DPSRAM_2_assoc <= 2;
                when 3 =>
                    DPSRAM_3_assoc <= 2;
                when others =>
            end case;

            case o_comp_ram_index is
                when 0 =>
                    DPSRAM_0_assoc <= 3;
                when 1 =>
                    DPSRAM_1_assoc <= 3;
                when 2 =>
                    DPSRAM_2_assoc <= 3;
                when 3 =>
                    DPSRAM_3_assoc <= 3;
                when others =>
            end case;
        end if;
    end process;

    A_WEN_0 <= i_comp_ram_w_en(0) when DPSRAM_0_assoc = 0 else
                tf_comp_ram_w_en_0(0) when DPSRAM_0_assoc = 1 else
                tf_comp_ram_w_en_1(0) when DPSRAM_0_assoc = 2 else
                o_comp_ram_w_en(0) when DPSRAM_0_assoc = 3;
    A_ADDR_0_temp <= i_comp_ram_adr(0) when DPSRAM_0_assoc = 0 else
                    tf_comp_ram_adr_0(0) when DPSRAM_0_assoc = 1 else
                    tf_comp_ram_adr_1(0) when DPSRAM_0_assoc = 2 else
                    o_comp_ram_adr(0) when DPSRAM_0_assoc = 3;
    A_ADDR_0 <= (A_ADDR_0_temp'high downto 0 => A_ADDR_0_temp, others => '0');
    A_DIN_0 <= i_comp_ram_dat_w(0) when DPSRAM_0_assoc = 0 else
                tf_comp_ram_dat_w_0(0) when DPSRAM_0_assoc = 1 else
                tf_comp_ram_dat_w_1(0) when DPSRAM_0_assoc = 2 else
                o_comp_ram_dat_w(0) when DPSRAM_0_assoc = 3;
    --<= A_DOUT_0;
    B_WEN_0 <= i_comp_ram_w_en(1) when DPSRAM_0_assoc = 0 else
                tf_comp_ram_w_en_0(1) when DPSRAM_0_assoc = 1 else
                tf_comp_ram_w_en_1(1) when DPSRAM_0_assoc = 2 else
                o_comp_ram_w_en(1) when DPSRAM_0_assoc = 3;
    B_ADDR_0_temp <= i_comp_ram_adr(1) when DPSRAM_0_assoc = 0 else
                    tf_comp_ram_adr_0(1) when DPSRAM_0_assoc = 1 else
                    tf_comp_ram_adr_1(1) when DPSRAM_0_assoc = 2 else
                    o_comp_ram_adr(1) when DPSRAM_0_assoc = 3;
    B_ADDR_0 <= (B_ADDR_0_temp'high downto 0 => B_ADDR_0_temp, others => '0');
    B_DIN_0 <= i_comp_ram_dat_w(1) when DPSRAM_0_assoc = 0 else
                tf_comp_ram_dat_w_0(1) when DPSRAM_0_assoc = 1 else
                tf_comp_ram_dat_w_1(1) when DPSRAM_0_assoc = 2 else
                o_comp_ram_dat_w(1) when DPSRAM_0_assoc = 3;
    --<= B_DOUT_0;

    A_WEN_1 <= i_comp_ram_w_en(0) when DPSRAM_1_assoc = 0 else
                tf_comp_ram_w_en_0(0) when DPSRAM_1_assoc = 1 else
                tf_comp_ram_w_en_1(0) when DPSRAM_1_assoc = 2 else
                o_comp_ram_w_en(0) when DPSRAM_1_assoc = 3;
    A_ADDR_1_temp <= i_comp_ram_adr(0) when DPSRAM_1_assoc = 0 else
                    tf_comp_ram_adr_0(0) when DPSRAM_1_assoc = 1 else
                    tf_comp_ram_adr_1(0) when DPSRAM_1_assoc = 2 else
                    o_comp_ram_adr(0) when DPSRAM_1_assoc = 3;
    A_ADDR_1 <= (A_ADDR_1_temp'high downto 0 => A_ADDR_1_temp, others => '0');
    A_DIN_1 <= i_comp_ram_dat_w(0) when DPSRAM_1_assoc = 0 else
                tf_comp_ram_dat_w_0(0) when DPSRAM_1_assoc = 1 else
                tf_comp_ram_dat_w_1(0) when DPSRAM_1_assoc = 2 else
                o_comp_ram_dat_w(0) when DPSRAM_1_assoc = 3;
    --<= A_DOUT_1;
    B_WEN_1 <= i_comp_ram_w_en(1) when DPSRAM_1_assoc = 0 else
                tf_comp_ram_w_en_0(1) when DPSRAM_1_assoc = 1 else
                tf_comp_ram_w_en_1(1) when DPSRAM_1_assoc = 2 else
                o_comp_ram_w_en(1) when DPSRAM_1_assoc = 3;
    B_ADDR_1_temp <= i_comp_ram_adr(1) when DPSRAM_1_assoc = 0 else
                tf_comp_ram_adr_0(1) when DPSRAM_1_assoc = 1 else
                tf_comp_ram_adr_1(1) when DPSRAM_1_assoc = 2 else
                o_comp_ram_adr(1) when DPSRAM_1_assoc = 3;
    B_ADDR_1 <= (B_ADDR_1_temp'high downto 0 => B_ADDR_1_temp, others => '0');
    B_DIN_1 <= i_comp_ram_dat_w(1) when DPSRAM_1_assoc = 0 else
                tf_comp_ram_dat_w_0(1) when DPSRAM_1_assoc = 1 else
                tf_comp_ram_dat_w_1(1) when DPSRAM_1_assoc = 2 else
                o_comp_ram_dat_w(1) when DPSRAM_1_assoc = 3;
    --<= B_DOUT_1;

    A_WEN_2 <= i_comp_ram_w_en(0) when DPSRAM_2_assoc = 0 else
                tf_comp_ram_w_en_0(0) when DPSRAM_2_assoc = 1 else
                tf_comp_ram_w_en_1(0) when DPSRAM_2_assoc = 2 else
                o_comp_ram_w_en(0) when DPSRAM_2_assoc = 3;
    A_ADDR_2_temp <= i_comp_ram_adr(0) when DPSRAM_2_assoc = 0 else
                    tf_comp_ram_adr_0(0) when DPSRAM_2_assoc = 1 else
                    tf_comp_ram_adr_1(0) when DPSRAM_2_assoc = 2 else
                    o_comp_ram_adr(0) when DPSRAM_2_assoc = 3;
    A_ADDR_2 <= (A_ADDR_2_temp'high downto 0 => A_ADDR_2_temp, others => '0');
    A_DIN_2 <= i_comp_ram_dat_w(0) when DPSRAM_2_assoc = 0 else
                tf_comp_ram_dat_w_0(0) when DPSRAM_2_assoc = 1 else
                tf_comp_ram_dat_w_1(0) when DPSRAM_2_assoc = 2 else
                o_comp_ram_dat_w(0) when DPSRAM_2_assoc = 3;
    --<= A_DOUT_2;
    B_WEN_2 <= i_comp_ram_w_en(1) when DPSRAM_2_assoc = 0 else
                tf_comp_ram_w_en_0(1) when DPSRAM_2_assoc = 1 else
                tf_comp_ram_w_en_1(1) when DPSRAM_2_assoc = 2 else
                o_comp_ram_w_en(1) when DPSRAM_2_assoc = 3;
    B_ADDR_2_temp <= i_comp_ram_adr(1) when DPSRAM_2_assoc = 0 else
                    tf_comp_ram_adr_0(1) when DPSRAM_2_assoc = 1 else
                    tf_comp_ram_adr_1(1) when DPSRAM_2_assoc = 2 else
                    o_comp_ram_adr(1) when DPSRAM_2_assoc = 3;
    B_ADDR_2 <= (B_ADDR_2_temp'high downto 0 => B_ADDR_2_temp, others => '0');
    B_DIN_2 <= i_comp_ram_dat_w(1) when DPSRAM_2_assoc = 0 else
                tf_comp_ram_dat_w_0(1) when DPSRAM_2_assoc = 1 else
                tf_comp_ram_dat_w_1(1) when DPSRAM_2_assoc = 2 else
                o_comp_ram_dat_w(1) when DPSRAM_2_assoc = 3;
    --<= B_DOUT_2;

    A_WEN_3 <= i_comp_ram_w_en(0) when DPSRAM_3_assoc = 0 else
                tf_comp_ram_w_en_0(0) when DPSRAM_3_assoc = 1 else
                tf_comp_ram_w_en_1(0) when DPSRAM_3_assoc = 2 else
                o_comp_ram_w_en(0) when DPSRAM_3_assoc = 3;
    A_ADDR_3_temp <= i_comp_ram_adr(0) when DPSRAM_3_assoc = 0 else
                    tf_comp_ram_adr_0(0) when DPSRAM_3_assoc = 1 else
                    tf_comp_ram_adr_1(0) when DPSRAM_3_assoc = 2 else
                    o_comp_ram_adr(0) when DPSRAM_3_assoc = 3;
    A_ADDR_3 <= (A_ADDR_3_temp'high downto 0 => A_ADDR_3_temp, others => '0');
    A_DIN_3 <= i_comp_ram_dat_w(0) when DPSRAM_3_assoc = 0 else
                tf_comp_ram_dat_w_0(0) when DPSRAM_3_assoc = 1 else
                tf_comp_ram_dat_w_1(0) when DPSRAM_3_assoc = 2 else
                o_comp_ram_dat_w(0) when DPSRAM_3_assoc = 3;
    --<= A_DOUT_3;
    B_WEN_3 <= i_comp_ram_w_en(1) when DPSRAM_3_assoc = 0 else
                tf_comp_ram_w_en_0(1) when DPSRAM_3_assoc = 1 else
                tf_comp_ram_w_en_1(1) when DPSRAM_3_assoc = 2 else
                o_comp_ram_w_en(1) when DPSRAM_3_assoc = 3;
    B_ADDR_3_temp <= i_comp_ram_adr(1) when DPSRAM_3_assoc = 0 else
                tf_comp_ram_adr_0(1) when DPSRAM_3_assoc = 1 else
                tf_comp_ram_adr_1(1) when DPSRAM_3_assoc = 2 else
                o_comp_ram_adr(1) when DPSRAM_3_assoc = 3;
    B_ADDR_3 <= (B_ADDR_3_temp'high downto 0 => B_ADDR_3_temp, others => '0');
    B_DIN_3 <= i_comp_ram_dat_w(1) when DPSRAM_3_assoc = 0 else
                tf_comp_ram_dat_w_0(1) when DPSRAM_3_assoc = 1 else
                tf_comp_ram_dat_w_1(1) when DPSRAM_3_assoc = 2 else
                o_comp_ram_dat_w(1) when DPSRAM_3_assoc = 3;
    --<= B_DOUT_3;

    i_comp_ram_dat_r(0) <= A_DOUT_0 when i_comp_ram_index = 0 else
                            A_DOUT_1 when i_comp_ram_index = 1 else
                            A_DOUT_2 when i_comp_ram_index = 2 else
                            A_DOUT_3 when i_comp_ram_index = 3;
    i_comp_ram_dat_r(1) <= B_DOUT_0 when i_comp_ram_index = 0 else
                            B_DOUT_1 when i_comp_ram_index = 1 else
                            B_DOUT_2 when i_comp_ram_index = 2 else
                            B_DOUT_3 when i_comp_ram_index = 3;

    o_comp_ram_dat_r(0) <= A_DOUT_0 when o_comp_ram_index = 0 else
                            A_DOUT_1 when o_comp_ram_index = 1 else
                            A_DOUT_2 when o_comp_ram_index = 2 else
                            A_DOUT_3 when o_comp_ram_index = 3;
    o_comp_ram_dat_r(1) <= B_DOUT_0 when o_comp_ram_index = 0 else
                            B_DOUT_1 when o_comp_ram_index = 1 else
                            B_DOUT_2 when o_comp_ram_index = 2 else
                            B_DOUT_3 when o_comp_ram_index = 3;

    tf_comp_ram_dat_r_0(0) <= A_DOUT_0 when tf_comp_ram_index_0 = 0 else
                                A_DOUT_1 when tf_comp_ram_index_0 = 1 else
                                A_DOUT_2 when tf_comp_ram_index_0 = 2 else
                                A_DOUT_3 when tf_comp_ram_index_0 = 3;
    tf_comp_ram_dat_r_0(1) <= B_DOUT_0 when tf_comp_ram_index_0 = 0 else
                                B_DOUT_1 when tf_comp_ram_index_0 = 1 else
                                B_DOUT_2 when tf_comp_ram_index_0 = 2 else
                                B_DOUT_3 when tf_comp_ram_index_0 = 3;

    tf_comp_ram_dat_r_1(0) <= A_DOUT_0 when tf_comp_ram_index_1 = 0 else
                                A_DOUT_1 when tf_comp_ram_index_1 = 1 else
                                A_DOUT_2 when tf_comp_ram_index_1 = 2 else
                                A_DOUT_3 when tf_comp_ram_index_1 = 3;
    tf_comp_ram_dat_r_1(1) <= B_DOUT_0 when tf_comp_ram_index_1 = 0 else
                                B_DOUT_1 when tf_comp_ram_index_1 = 1 else
                                B_DOUT_2 when tf_comp_ram_index_1 = 2 else
                                B_DOUT_3 when tf_comp_ram_index_1 = 3;


--=========================================================================



--=========================================================================

    i_comp_input_w_dat_real <= port_in_w_data_real;
    i_comp_input_w_dat_imag <= port_in_w_data_imag;
    i_comp_input_w_en <= port_in_w_en;
    i_comp_input_done <= port_in_w_done;
    port_in_w_ready <= i_comp_input_w_ready;
    port_in_full <= i_comp_input_full;

    o_comp_output_en <= port_out_r_en;
    o_comp_output_adr <= port_out_data_adr;
    o_comp_output_done <= port_out_read_done;
    port_out_dat_real <= o_comp_output_real;
    port_out_dat_imag <= o_comp_output_imag;
    port_out_data_ready <= o_comp_output_ready;
    port_out_valid <= o_comp_output_valid;

--=========================================================================

    FFT_Sample_Loader_0 : FFT_Sample_Loader
        generic map(
            g_sync_input => SYNC_SAMPLE_LOAD
        )
        -- port map
        port map( 
            PCLK => PCLK,
            RSTn => RSTn,
            -- connections to sample generator
            input_w_en => i_comp_input_w_en,
            input_w_dat_real => i_comp_input_w_dat_real,
            input_w_dat_imag => i_comp_input_w_dat_imag,
            input_done => i_comp_input_done,

            input_w_ready => i_comp_input_w_ready,
            input_full => i_comp_input_full,
            -- connections to sample generator


            -- connections to FFT RAM block
            ram_stable => i_comp_ram_stable,
            ram_ready => i_comp_ram_ready,
            ram_valid => i_comp_ram_valid,
            ram_done => i_comp_ram_done,
            ram_w_en => i_comp_ram_w_en,
            ram_adr => i_comp_ram_adr,
            ram_dat_w => i_comp_ram_dat_w,
            ram_dat_r => i_comp_ram_dat_r,
            ram_adr_start => i_comp_ram_adr_start

        );

    FFT_Sample_Outputer_0 : FFT_Sample_Outputer
        generic map(
            g_sync_input => SYNC_SAMPLE_OUTPUT,
            g_buffer_output => BUFF_SAMPLE_OUTPUT
        )
        -- port map
        port map( 
            PCLK => PCLK,
            RSTn => RSTn,
            -- connections to outside perif
            output_en => o_comp_output_en,
            output_adr => o_comp_output_adr,
            output_done => o_comp_output_done,
            output_real => o_comp_output_real,
            output_imag => o_comp_output_imag,
            output_ready => o_comp_output_ready,
            output_valid => o_comp_output_valid,
            -- connections to outside perif


            -- connections to FFT RAM block
            ram_stable => o_comp_ram_stable,
            ram_ready => o_comp_ram_ready,
            ram_valid => o_comp_ram_valid,
            ram_done => o_comp_ram_done,
            ram_w_en => o_comp_ram_w_en,
            ram_adr => o_comp_ram_adr,
            ram_dat_w => o_comp_ram_dat_w,
            ram_dat_r => o_comp_ram_dat_r
        );

    FFT_Transformer_0 : FFT_Transformer
        port map( 
            -- Inputs
            PCLK             => PCLK,
            RSTn             => RSTn,
            ram_stable       => tf_comp_ram_stable,
            ram_ready        => tf_comp_ram_ready,
            ram_assigned     => tf_comp_ram_assigned,
            ram_adr_start   => tf_comp_ram_adr_start,
            ram_dat_r_0     => tf_comp_ram_dat_r_0,
            ram_dat_r_1     => tf_comp_ram_dat_r_1,
            -- Outputs
            ram_returned     => tf_comp_ram_returned,
            ram_valid        => tf_comp_ram_valid,
            ram_done        => tf_comp_ram_done,
            ram_w_en_0       => tf_comp_ram_w_en_0,
            ram_adr_0       => tf_comp_ram_adr_0,
            ram_dat_w_0     => tf_comp_ram_dat_w_0,
            ram_w_en_1       => tf_comp_ram_w_en_1,
            ram_adr_1       => tf_comp_ram_adr_1,
            ram_dat_w_1     => tf_comp_ram_dat_w_1
        );

    DPSRAM_0 : DPSRAM_C0
        port map(
            CLK => PCLK,
            A_WEN => A_WEN_0,
            A_ADDR => A_ADDR_0,
            A_DIN => A_DIN_0,
            A_DOUT => A_DOUT_0,
            B_WEN => B_WEN_0,
            B_ADDR => B_ADDR_0,
            B_DIN => B_DIN_0,
            B_DOUT => B_DOUT_0
        );

    DPSRAM_1 : DPSRAM_C0
        port map(
            CLK => PCLK,
            A_WEN => A_WEN_1,
            A_ADDR => A_ADDR_1,
            A_DIN => A_DIN_1,
            A_DOUT => A_DOUT_1,
            B_WEN => B_WEN_1,
            B_ADDR => B_ADDR_1,
            B_DIN => B_DIN_1,
            B_DOUT => B_DOUT_1
        );
    DPSRAM_2 : DPSRAM_C0
        port map(
            CLK => PCLK,
            A_WEN => A_WEN_2,
            A_ADDR => A_ADDR_2,
            A_DIN => A_DIN_2,
            A_DOUT => A_DOUT_2,
            B_WEN => B_WEN_2,
            B_ADDR => B_ADDR_2,
            B_DIN => B_DIN_2,
            B_DOUT => B_DOUT_2
        );

    DPSRAM_3 : DPSRAM_C0
        port map(
            CLK => PCLK,
            A_WEN => A_WEN_3,
            A_ADDR => A_ADDR_3,
            A_DIN => A_DIN_3,
            A_DOUT => A_DOUT_3,
            B_WEN => B_WEN_3,
            B_ADDR => B_ADDR_3,
            B_DIN => B_DIN_3,
            B_DOUT => B_DOUT_3
        );
    

   -- architecture body
end architecture_FFT;
