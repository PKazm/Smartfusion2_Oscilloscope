--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Spectrum_Analyzer_tb.vhd
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
use ieee.numeric_std.all;

use work.FFT_package.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    constant CON_DATA_BITS : natural := 8;
    constant CON_SAMPLE_DIV : natural := 2;

    signal smpl_cnt : natural range 0 to 2**7-1 := 0;

    signal FCCC_C0_0_GL0 : std_logic;
    signal Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N : std_logic;
    signal LVDS_PADN_feedback : std_logic;
    signal test_samples_signal : std_logic_vector(7 downto 0);
    signal Sigma_Delta_LVDS_ADC_0_Data_Ready : std_logic;
    signal Sigma_Delta_LVDS_ADC_0_Data_out : std_logic_vector(7 downto 0);
    signal avg_filt_data_in : std_logic_vector(7 downto 0);
    signal Averaging_Filter_0_Data_out_ready : std_logic;
    signal Averaging_Filter_0_Data_out : std_logic_vector(7 downto 0);
    signal FFT_0_in_full : std_logic;
    type DPSRAM_type is array (0 to 1023) of std_logic_vector(17 downto 0);
    signal FFT_mem_0 : DPSRAM_type;
    signal FFT_mem_1 : DPSRAM_type;
    signal FFT_mem_2 : DPSRAM_type;
    signal FFT_mem_3 : DPSRAM_type;
    signal i_comp_ram_index : natural range 0 to 3;
    signal tf_comp_ram_index_0 : natural range 0 to 3;
    signal tf_comp_ram_index_1 : natural range 0 to 3;
    signal o_comp_ram_index : natural range 0 to 3;
    signal FFT_Result_to_Pixel_Bar_0_fft_read_done : std_logic;
    signal FFT_0_out_data_ready : std_logic;
    signal FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_0 : std_logic_vector(7 downto 0);
    signal FFT_0_out_valid : std_logic;
    signal FFT_0_out_dat_real : std_logic_vector(8 downto 0);
    signal FFT_0_out_dat_imag : std_logic_vector(8 downto 0);
    signal pixel_bar : std_logic_vector(31 downto 0);

    component Spectrum_Analyzer
        -- ports
        port( 
            -- Inputs
            DEVRST_N : in std_logic;
            PADP : in std_logic;
            PADN : in std_logic;
            Data_in : in std_logic_vector(7 downto 0);

            -- Outputs
            LVDS_PADN_feedback : out std_logic;
            Board_J7 : out std_logic_vector(4 downto 0);
            feedback2 : out std_logic

            -- Inouts

        );
    end component;

    type test_sample_mem is array (0 to (2**7) - 1) of std_logic_vector(7 downto 0);
    constant TEST_SAMPLES : test_sample_mem := (
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(250, 8)),
        std_logic_vector(to_unsigned(239, 8)),
        std_logic_vector(to_unsigned(221, 8)),
        std_logic_vector(to_unsigned(198, 8)),
        std_logic_vector(to_unsigned(170, 8)),
        std_logic_vector(to_unsigned(139, 8)),
        std_logic_vector(to_unsigned(108, 8)),
        std_logic_vector(to_unsigned(78, 8)),
        std_logic_vector(to_unsigned(51, 8)),
        std_logic_vector(to_unsigned(29, 8)),
        std_logic_vector(to_unsigned(12, 8)),
        std_logic_vector(to_unsigned(2, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(5, 8)),
        std_logic_vector(to_unsigned(18, 8)),
        std_logic_vector(to_unsigned(37, 8)),
        std_logic_vector(to_unsigned(62, 8)),
        std_logic_vector(to_unsigned(90, 8)),
        std_logic_vector(to_unsigned(121, 8)),
        std_logic_vector(to_unsigned(152, 8)),
        std_logic_vector(to_unsigned(181, 8)),
        std_logic_vector(to_unsigned(208, 8)),
        std_logic_vector(to_unsigned(229, 8)),
        std_logic_vector(to_unsigned(244, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(253, 8)),
        std_logic_vector(to_unsigned(247, 8)),
        std_logic_vector(to_unsigned(233, 8)),
        std_logic_vector(to_unsigned(212, 8)),
        std_logic_vector(to_unsigned(187, 8)),
        std_logic_vector(to_unsigned(158, 8)),
        std_logic_vector(to_unsigned(127, 8)),
        std_logic_vector(to_unsigned(96, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(0, 8)),
        std_logic_vector(to_unsigned(4, 8)),
        std_logic_vector(to_unsigned(15, 8)),
        std_logic_vector(to_unsigned(33, 8)),
        std_logic_vector(to_unsigned(56, 8)),
        std_logic_vector(to_unsigned(84, 8)),
        std_logic_vector(to_unsigned(115, 8)),
        std_logic_vector(to_unsigned(146, 8)),
        std_logic_vector(to_unsigned(176, 8)),
        std_logic_vector(to_unsigned(203, 8)),
        std_logic_vector(to_unsigned(225, 8)),
        std_logic_vector(to_unsigned(242, 8)),
        std_logic_vector(to_unsigned(252, 8)),
        std_logic_vector(to_unsigned(254, 8)),
        std_logic_vector(to_unsigned(249, 8)),
        std_logic_vector(to_unsigned(236, 8)),
        std_logic_vector(to_unsigned(217, 8)),
        std_logic_vector(to_unsigned(192, 8)),
        std_logic_vector(to_unsigned(164, 8)),
        std_logic_vector(to_unsigned(133, 8)),
        std_logic_vector(to_unsigned(102, 8)),
        std_logic_vector(to_unsigned(73, 8)),
        std_logic_vector(to_unsigned(46, 8)),
        std_logic_vector(to_unsigned(25, 8)),
        std_logic_vector(to_unsigned(10, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(1, 8)),
        std_logic_vector(to_unsigned(7, 8)),
        std_logic_vector(to_unsigned(21, 8)),
        std_logic_vector(to_unsigned(42, 8)),
        std_logic_vector(to_unsigned(67, 8)),
        std_logic_vector(to_unsigned(96, 8))
    );

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

    -- Instantiate Unit Under Test:  Spectrum_Analyzer
    Spectrum_Analyzer_0 : Spectrum_Analyzer
        -- port map
        port map( 
            -- Inputs
            DEVRST_N => NSYSRESET,
            PADP => '0',
            PADN => '0',
            Data_in => test_samples_signal,

            -- Outputs
            LVDS_PADN_feedback =>  open,
            Board_J7 => open,
            feedback2 =>  open

            -- Inouts

        );

    spy_process : process
    begin
        init_signal_spy("Spectrum_Analyzer_0/FCCC_C0_0_GL0", "FCCC_C0_0_GL0", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N", "Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/LVDS_PADN_feedback", "LVDS_PADN_feedback", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_Ready", "Sigma_Delta_LVDS_ADC_0_Data_Ready", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out", "Sigma_Delta_LVDS_ADC_0_Data_out", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Averaging_Filter_0/Data_in", "avg_filt_data_in", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Averaging_Filter_0_Data_out_ready", "Averaging_Filter_0_Data_out_ready", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/Averaging_Filter_0_Data_out", "Averaging_Filter_0_Data_out", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0_in_full", "FFT_0_in_full", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_Result_to_Pixel_Bar_0_fft_read_done", "FFT_Result_to_Pixel_Bar_0_fft_read_done", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/DPSRAM_0/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_0", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/DPSRAM_1/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_1", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/DPSRAM_2/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_2", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/DPSRAM_3/DPSRAM_C0_0/DPSRAM_C0_DPSRAM_C0_0_DPSRAM_R0C0/MEM_1024_18", "FFT_mem_3", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/i_comp_ram_index", "i_comp_ram_index", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/tf_comp_ram_index_0", "tf_comp_ram_index_0", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/tf_comp_ram_index_1", "tf_comp_ram_index_1", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0/o_comp_ram_index", "o_comp_ram_index", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0_out_data_ready", "FFT_0_out_data_ready", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_0", "FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_0", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0_out_valid", "FFT_0_out_valid", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0_out_dat_real", "FFT_0_out_dat_real", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_0_out_dat_imag", "FFT_0_out_dat_imag", 1, -1);
        init_signal_spy("Spectrum_Analyzer_0/FFT_Result_to_Pixel_Bar_0/PbCr_0_Pixel_bar_out", "pixel_bar", 1, -1);

        wait;
    end process;

    --LVDS_randomizer : process
    --begin
    --    -- this should give a frequency that is out of phase with the sample frequency
    --    -- negative CON_SAMPLE_DIV * 50 gives shorter period. positive gives longer period
    --    -- the pwm values will change "randomly" over time as a result. (its good enough for now)
    --    signal_force("Spectrum_Analyzer_0/INBUF_DIFF_0_Y", "0", 0 ns, freeze, -1 ns, 1);
    --    wait for ( SYSCLK_PERIOD * (CON_SAMPLE_DIV * (2 ** CON_DATA_BITS) - (CON_SAMPLE_DIV * 50)));
    --    signal_force("Spectrum_Analyzer_0/INBUF_DIFF_0_Y", "1", 0 ns, freeze, -1 ns, 1);
    --    wait for ( SYSCLK_PERIOD * (CON_SAMPLE_DIV * (2 ** CON_DATA_BITS) - (CON_SAMPLE_DIV * 50)));
    --end process;

    SD_ADC_output_override : process
    begin

        test_samples_signal <= "00110101";--(others => '1');
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[0]", "1", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[1]", "0", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[2]", "1", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[3]", "0", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[4]", "1", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[5]", "1", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[6]", "0", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[7]", "0", 0, freeze, -1, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out", test_samples_signal, open, open, open, 1);
        --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out", "00110101", open, open, open, 1);

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;
        
        if(Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N /= '1') then
            wait until (Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N = '1');
        end if;
            
        for i in 0 to TEST_SAMPLES'high loop
            wait until (Sigma_Delta_LVDS_ADC_0_Data_Ready = '0');
            test_samples_signal <= TEST_SAMPLES(i);
            --signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out", test_samples_signal, open, open, open, 1);
            --if(TEST_SAMPLES(i)(0) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[0]", "1", open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[0]", "0", open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(1) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[1]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[1]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(2) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[2]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[2]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(3) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[3]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[3]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(4) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[4]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[4]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(5) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[5]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[5]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(6) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[6]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[6]", 0, open, open, open, 1);
            --end if;
            --if(TEST_SAMPLES(i)(7) = '1') then
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[7]", 1, open, open, open, 1);
            --else
            --    signal_force("Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out[7]", 0, open, open, open, 1);
            --end if;
        end loop;
    end process;


    THE_STUFF : process
    begin
        wait until (NSYSRESET = '1');
        wait for (SYSCLK_PERIOD * 2);
        wait;
    end process;

    driver_process : process
    begin
        --init_signal_driver("test_samples_signal", "Spectrum_Analyzer_0/Sigma_Delta_LVDS_ADC_0_Data_out", open, open, 1);
        --init_signal_driver("test_samples_signal", "Spectrum_Analyzer_0/Averaging_Filter_0/Data_in", open, open, 1);
        wait;
    end process;

end behavioral;

