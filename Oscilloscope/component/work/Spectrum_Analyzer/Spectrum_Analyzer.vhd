----------------------------------------------------------------------
-- Created by SmartDesign Sat Mar 14 02:07:37 2020
-- Version: v12.1 12.600.0.14
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- Spectrum_Analyzer entity declaration
----------------------------------------------------------------------
entity Spectrum_Analyzer is
    -- Port list
    port(
        -- Inputs
        DEVRST_N           : in  std_logic;
        PADN               : in  std_logic;
        PADP               : in  std_logic;
        -- Outputs
        Board_J7           : out std_logic_vector(4 downto 0);
        Board_J8           : out std_logic;
        LVDS_PADN_feedback : out std_logic;
        feedback2          : out std_logic
        );
end Spectrum_Analyzer;
----------------------------------------------------------------------
-- Spectrum_Analyzer architecture body
----------------------------------------------------------------------
architecture RTL of Spectrum_Analyzer is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- Averaging_Filter
-- using entity instantiation for component Averaging_Filter
-- COREABC_C0
component COREABC_C0
    -- Port list
    port(
        -- Inputs
        INTREQ    : in  std_logic;
        IO_IN     : in  std_logic_vector(1 downto 0);
        NSYSRESET : in  std_logic;
        PCLK      : in  std_logic;
        PRDATA_M  : in  std_logic_vector(7 downto 0);
        PREADY_M  : in  std_logic;
        PSLVERR_M : in  std_logic;
        -- Outputs
        INTACT    : out std_logic;
        IO_OUT    : out std_logic_vector(0 to 0);
        PADDR_M   : out std_logic_vector(19 downto 0);
        PENABLE_M : out std_logic;
        PRESETN   : out std_logic;
        PSEL_M    : out std_logic;
        PWDATA_M  : out std_logic_vector(7 downto 0);
        PWRITE_M  : out std_logic
        );
end component;
-- CoreAPB3_C0
component CoreAPB3_C0
    -- Port list
    port(
        -- Inputs
        PADDR     : in  std_logic_vector(31 downto 0);
        PENABLE   : in  std_logic;
        PRDATAS0  : in  std_logic_vector(31 downto 0);
        PRDATAS1  : in  std_logic_vector(31 downto 0);
        PREADYS0  : in  std_logic;
        PREADYS1  : in  std_logic;
        PSEL      : in  std_logic;
        PSLVERRS0 : in  std_logic;
        PSLVERRS1 : in  std_logic;
        PWDATA    : in  std_logic_vector(31 downto 0);
        PWRITE    : in  std_logic;
        -- Outputs
        PADDRS    : out std_logic_vector(31 downto 0);
        PENABLES  : out std_logic;
        PRDATA    : out std_logic_vector(31 downto 0);
        PREADY    : out std_logic;
        PSELS0    : out std_logic;
        PSELS1    : out std_logic;
        PSLVERR   : out std_logic;
        PWDATAS   : out std_logic_vector(31 downto 0);
        PWRITES   : out std_logic
        );
end component;
-- FCCC_C0
component FCCC_C0
    -- Port list
    port(
        -- Inputs
        RCOSC_25_50MHZ : in  std_logic;
        -- Outputs
        GL0            : out std_logic;
        LOCK           : out std_logic
        );
end component;
-- FFT
component FFT
    -- Port list
    port(
        -- Inputs
        PCLK           : in  std_logic;
        RSTn           : in  std_logic;
        in_w_data_imag : in  std_logic_vector(8 downto 0);
        in_w_data_real : in  std_logic_vector(8 downto 0);
        in_w_done      : in  std_logic;
        in_w_en        : in  std_logic;
        out_data_adr   : in  std_logic_vector(7 downto 0);
        out_r_en       : in  std_logic;
        out_read_done  : in  std_logic;
        -- Outputs
        in_full        : out std_logic;
        in_w_ready     : out std_logic;
        out_dat_imag   : out std_logic_vector(8 downto 0);
        out_dat_real   : out std_logic_vector(8 downto 0);
        out_data_ready : out std_logic;
        out_valid      : out std_logic
        );
end component;
-- FFT_Result_to_Pixel_Bar
-- using entity instantiation for component FFT_Result_to_Pixel_Bar
-- INBUF_DIFF
component INBUF_DIFF
    generic( 
        IOSTD : string := "" 
        );
    -- Port list
    port(
        -- Inputs
        PADN : in  std_logic;
        PADP : in  std_logic;
        -- Outputs
        Y    : out std_logic
        );
end component;
-- Nokia5110_Driver
-- using entity instantiation for component Nokia5110_Driver
-- OSC_C0
component OSC_C0
    -- Port list
    port(
        -- Outputs
        RCOSC_25_50MHZ_CCC : out std_logic
        );
end component;
-- Power_On_Reset_Delay
-- using entity instantiation for component Power_On_Reset_Delay
-- Sigma_Delta_LVDS_ADC
-- using entity instantiation for component Sigma_Delta_LVDS_ADC
-- SYSRESET
component SYSRESET
    -- Port list
    port(
        -- Inputs
        DEVRST_N         : in  std_logic;
        -- Outputs
        POWER_ON_RESET_N : out std_logic
        );
end component;
-- timer
-- using entity instantiation for component timer
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal Averaging_Filter_0_Data_out                        : std_logic_vector(7 downto 0);
signal Averaging_Filter_0_Data_out_ready                  : std_logic;
signal Board_J7_net_0                                     : std_logic;
signal Board_J7_0                                         : std_logic;
signal Board_J7_1                                         : std_logic;
signal Board_J7_2                                         : std_logic;
signal Board_J7_3                                         : std_logic;
signal Board_J8_net_0                                     : std_logic;
signal COREABC_C0_0_APB3master_PENABLE                    : std_logic;
signal COREABC_C0_0_APB3master_PREADY                     : std_logic;
signal COREABC_C0_0_APB3master_PSELx                      : std_logic;
signal COREABC_C0_0_APB3master_PSLVERR                    : std_logic;
signal COREABC_C0_0_APB3master_PWRITE                     : std_logic;
signal COREABC_C0_0_PRESETN                               : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PENABLE                   : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PREADY                    : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PSELx                     : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PSLVERR                   : std_logic;
signal CoreAPB3_C0_0_APBmslave0_PWRITE                    : std_logic;
signal CoreAPB3_C0_0_APBmslave1_PREADY                    : std_logic;
signal CoreAPB3_C0_0_APBmslave1_PSELx                     : std_logic;
signal CoreAPB3_C0_0_APBmslave1_PSLVERR                   : std_logic;
signal FCCC_C0_0_GL0                                      : std_logic;
signal FCCC_C0_0_LOCK                                     : std_logic;
signal FFT_0_in_full                                      : std_logic;
signal FFT_0_out_dat_imag                                 : std_logic_vector(8 downto 0);
signal FFT_0_out_dat_real                                 : std_logic_vector(8 downto 0);
signal FFT_0_out_data_ready                               : std_logic;
signal FFT_0_out_valid                                    : std_logic;
signal FFT_Result_to_Pixel_Bar_0_fft_r_en                 : std_logic;
signal FFT_Result_to_Pixel_Bar_0_fft_read_done            : std_logic;
signal FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_1           : std_logic_vector(7 downto 0);
signal FFT_Result_to_Pixel_Bar_0_INT                      : std_logic;
signal INBUF_DIFF_0_Y                                     : std_logic;
signal LVDS_PADN_feedback_net_0                           : std_logic;
signal Nokia5110_Driver_0_driver_busy                     : std_logic;
signal OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC : std_logic;
signal Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N        : std_logic;
signal Sigma_Delta_LVDS_ADC_0_Data_out                    : std_logic_vector(7 downto 0);
signal Sigma_Delta_LVDS_ADC_0_Data_Ready                  : std_logic;
signal SYSRESET_0_POWER_ON_RESET_N                        : std_logic;
signal LVDS_PADN_feedback_net_1                           : std_logic;
signal LVDS_PADN_feedback_net_2                           : std_logic;
signal Board_J7_0_net_0                                   : std_logic_vector(0 to 0);
signal Board_J7_net_1                                     : std_logic_vector(1 to 1);
signal Board_J7_1_net_0                                   : std_logic_vector(2 to 2);
signal Board_J7_3_net_0                                   : std_logic_vector(3 to 3);
signal Board_J7_2_net_0                                   : std_logic_vector(4 to 4);
signal Board_J8_net_1                                     : std_logic;
signal IO_IN_net_0                                        : std_logic_vector(1 downto 0);
signal in_w_data_real_net_0                               : std_logic_vector(8 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net                                            : std_logic;
signal in_w_data_imag_const_net_0                         : std_logic_vector(8 downto 0);
signal VCC_net                                            : std_logic;
----------------------------------------------------------------------
-- Bus Interface Nets Declarations - Unequal Pin Widths
----------------------------------------------------------------------
signal COREABC_C0_0_APB3master_PADDR_0_31to20             : std_logic_vector(31 downto 20);
signal COREABC_C0_0_APB3master_PADDR_0_19to0              : std_logic_vector(19 downto 0);
signal COREABC_C0_0_APB3master_PADDR_0                    : std_logic_vector(31 downto 0);
signal COREABC_C0_0_APB3master_PADDR                      : std_logic_vector(19 downto 0);

signal COREABC_C0_0_APB3master_PRDATA                     : std_logic_vector(31 downto 0);
signal COREABC_C0_0_APB3master_PRDATA_0_7to0              : std_logic_vector(7 downto 0);
signal COREABC_C0_0_APB3master_PRDATA_0                   : std_logic_vector(7 downto 0);

signal COREABC_C0_0_APB3master_PWDATA_0_31to8             : std_logic_vector(31 downto 8);
signal COREABC_C0_0_APB3master_PWDATA_0_7to0              : std_logic_vector(7 downto 0);
signal COREABC_C0_0_APB3master_PWDATA_0                   : std_logic_vector(31 downto 0);
signal COREABC_C0_0_APB3master_PWDATA                     : std_logic_vector(7 downto 0);

signal CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0              : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR_0                   : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR                     : std_logic_vector(31 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR_1_7to0              : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PADDR_1                   : std_logic_vector(7 downto 0);

signal CoreAPB3_C0_0_APBmslave0_PRDATA                    : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to8            : std_logic_vector(31 downto 8);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0_7to0             : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PRDATA_0                  : std_logic_vector(31 downto 0);

signal CoreAPB3_C0_0_APBmslave0_PWDATA_0_7to0             : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA_0                  : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA                    : std_logic_vector(31 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA_1_7to0             : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave0_PWDATA_1                  : std_logic_vector(7 downto 0);

signal CoreAPB3_C0_0_APBmslave1_PRDATA_0_31to8            : std_logic_vector(31 downto 8);
signal CoreAPB3_C0_0_APBmslave1_PRDATA_0_7to0             : std_logic_vector(7 downto 0);
signal CoreAPB3_C0_0_APBmslave1_PRDATA_0                  : std_logic_vector(31 downto 0);
signal CoreAPB3_C0_0_APBmslave1_PRDATA                    : std_logic_vector(7 downto 0);


begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net                    <= '0';
 in_w_data_imag_const_net_0 <= B"000000000";
 VCC_net                    <= '1';
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 LVDS_PADN_feedback_net_1 <= LVDS_PADN_feedback_net_0;
 LVDS_PADN_feedback       <= LVDS_PADN_feedback_net_1;
 LVDS_PADN_feedback_net_2 <= LVDS_PADN_feedback_net_0;
 feedback2                <= LVDS_PADN_feedback_net_2;
 Board_J7_0_net_0(0)      <= Board_J7_0;
 Board_J7(0)              <= Board_J7_0_net_0(0);
 Board_J7_net_1(1)        <= Board_J7_net_0;
 Board_J7(1)              <= Board_J7_net_1(1);
 Board_J7_1_net_0(2)      <= Board_J7_1;
 Board_J7(2)              <= Board_J7_1_net_0(2);
 Board_J7_3_net_0(3)      <= Board_J7_3;
 Board_J7(3)              <= Board_J7_3_net_0(3);
 Board_J7_2_net_0(4)      <= Board_J7_2;
 Board_J7(4)              <= Board_J7_2_net_0(4);
 Board_J8_net_1           <= Board_J8_net_0;
 Board_J8                 <= Board_J8_net_1;
----------------------------------------------------------------------
-- Concatenation assignments
----------------------------------------------------------------------
 IO_IN_net_0          <= ( Nokia5110_Driver_0_driver_busy & FFT_Result_to_Pixel_Bar_0_INT );
 in_w_data_real_net_0 <= ( '0' & Averaging_Filter_0_Data_out );
----------------------------------------------------------------------
-- Bus Interface Nets Assignments - Unequal Pin Widths
----------------------------------------------------------------------
 COREABC_C0_0_APB3master_PADDR_0_31to20(31 downto 20) <= B"000000000000";
 COREABC_C0_0_APB3master_PADDR_0_19to0(19 downto 0) <= COREABC_C0_0_APB3master_PADDR(19 downto 0);
 COREABC_C0_0_APB3master_PADDR_0 <= ( COREABC_C0_0_APB3master_PADDR_0_31to20(31 downto 20) & COREABC_C0_0_APB3master_PADDR_0_19to0(19 downto 0) );

 COREABC_C0_0_APB3master_PRDATA_0_7to0(7 downto 0) <= COREABC_C0_0_APB3master_PRDATA(7 downto 0);
 COREABC_C0_0_APB3master_PRDATA_0 <= ( COREABC_C0_0_APB3master_PRDATA_0_7to0(7 downto 0) );

 COREABC_C0_0_APB3master_PWDATA_0_31to8(31 downto 8) <= B"000000000000000000000000";
 COREABC_C0_0_APB3master_PWDATA_0_7to0(7 downto 0) <= COREABC_C0_0_APB3master_PWDATA(7 downto 0);
 COREABC_C0_0_APB3master_PWDATA_0 <= ( COREABC_C0_0_APB3master_PWDATA_0_31to8(31 downto 8) & COREABC_C0_0_APB3master_PWDATA_0_7to0(7 downto 0) );

 CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PADDR(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PADDR_0 <= ( CoreAPB3_C0_0_APBmslave0_PADDR_0_7to0(7 downto 0) );
 CoreAPB3_C0_0_APBmslave0_PADDR_1_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PADDR(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PADDR_1 <= ( CoreAPB3_C0_0_APBmslave0_PADDR_1_7to0(7 downto 0) );

 CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to8(31 downto 8) <= B"000000000000000000000000";
 CoreAPB3_C0_0_APBmslave0_PRDATA_0_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PRDATA(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PRDATA_0 <= ( CoreAPB3_C0_0_APBmslave0_PRDATA_0_31to8(31 downto 8) & CoreAPB3_C0_0_APBmslave0_PRDATA_0_7to0(7 downto 0) );

 CoreAPB3_C0_0_APBmslave0_PWDATA_0_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PWDATA(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PWDATA_0 <= ( CoreAPB3_C0_0_APBmslave0_PWDATA_0_7to0(7 downto 0) );
 CoreAPB3_C0_0_APBmslave0_PWDATA_1_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave0_PWDATA(7 downto 0);
 CoreAPB3_C0_0_APBmslave0_PWDATA_1 <= ( CoreAPB3_C0_0_APBmslave0_PWDATA_1_7to0(7 downto 0) );

 CoreAPB3_C0_0_APBmslave1_PRDATA_0_31to8(31 downto 8) <= B"000000000000000000000000";
 CoreAPB3_C0_0_APBmslave1_PRDATA_0_7to0(7 downto 0) <= CoreAPB3_C0_0_APBmslave1_PRDATA(7 downto 0);
 CoreAPB3_C0_0_APBmslave1_PRDATA_0 <= ( CoreAPB3_C0_0_APBmslave1_PRDATA_0_31to8(31 downto 8) & CoreAPB3_C0_0_APBmslave1_PRDATA_0_7to0(7 downto 0) );

----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- Averaging_Filter_0
Averaging_Filter_0 : entity work.Averaging_Filter
    generic map( 
        g_data_bits         => ( 8 ),
        g_enable_data_out   => ( 1 ),
        g_sample_window_exp => ( 2 )
        )
    port map( 
        -- Inputs
        PCLK           => FCCC_C0_0_GL0,
        RSTn           => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N,
        Data_in_ready  => Sigma_Delta_LVDS_ADC_0_Data_Ready,
        Data_in        => Sigma_Delta_LVDS_ADC_0_Data_out,
        -- Outputs
        Data_out       => Averaging_Filter_0_Data_out,
        Data_out_ready => Averaging_Filter_0_Data_out_ready 
        );
-- COREABC_C0_0
COREABC_C0_0 : COREABC_C0
    port map( 
        -- Inputs
        NSYSRESET => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N,
        PCLK      => FCCC_C0_0_GL0,
        INTREQ    => FFT_Result_to_Pixel_Bar_0_INT,
        PREADY_M  => COREABC_C0_0_APB3master_PREADY,
        PSLVERR_M => COREABC_C0_0_APB3master_PSLVERR,
        PRDATA_M  => COREABC_C0_0_APB3master_PRDATA_0,
        IO_IN     => IO_IN_net_0,
        -- Outputs
        PRESETN   => COREABC_C0_0_PRESETN,
        INTACT    => OPEN,
        PSEL_M    => COREABC_C0_0_APB3master_PSELx,
        PENABLE_M => COREABC_C0_0_APB3master_PENABLE,
        PWRITE_M  => COREABC_C0_0_APB3master_PWRITE,
        PADDR_M   => COREABC_C0_0_APB3master_PADDR,
        PWDATA_M  => COREABC_C0_0_APB3master_PWDATA,
        IO_OUT    => OPEN 
        );
-- CoreAPB3_C0_0
CoreAPB3_C0_0 : CoreAPB3_C0
    port map( 
        -- Inputs
        PSEL      => COREABC_C0_0_APB3master_PSELx,
        PENABLE   => COREABC_C0_0_APB3master_PENABLE,
        PWRITE    => COREABC_C0_0_APB3master_PWRITE,
        PREADYS0  => CoreAPB3_C0_0_APBmslave0_PREADY,
        PSLVERRS0 => CoreAPB3_C0_0_APBmslave0_PSLVERR,
        PREADYS1  => CoreAPB3_C0_0_APBmslave1_PREADY,
        PSLVERRS1 => CoreAPB3_C0_0_APBmslave1_PSLVERR,
        PADDR     => COREABC_C0_0_APB3master_PADDR_0,
        PWDATA    => COREABC_C0_0_APB3master_PWDATA_0,
        PRDATAS0  => CoreAPB3_C0_0_APBmslave0_PRDATA_0,
        PRDATAS1  => CoreAPB3_C0_0_APBmslave1_PRDATA_0,
        -- Outputs
        PREADY    => COREABC_C0_0_APB3master_PREADY,
        PSLVERR   => COREABC_C0_0_APB3master_PSLVERR,
        PSELS0    => CoreAPB3_C0_0_APBmslave0_PSELx,
        PENABLES  => CoreAPB3_C0_0_APBmslave0_PENABLE,
        PWRITES   => CoreAPB3_C0_0_APBmslave0_PWRITE,
        PSELS1    => CoreAPB3_C0_0_APBmslave1_PSELx,
        PRDATA    => COREABC_C0_0_APB3master_PRDATA,
        PADDRS    => CoreAPB3_C0_0_APBmslave0_PADDR,
        PWDATAS   => CoreAPB3_C0_0_APBmslave0_PWDATA 
        );
-- FCCC_C0_0
FCCC_C0_0 : FCCC_C0
    port map( 
        -- Inputs
        RCOSC_25_50MHZ => OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC,
        -- Outputs
        GL0            => FCCC_C0_0_GL0,
        LOCK           => FCCC_C0_0_LOCK 
        );
-- FFT_0
FFT_0 : FFT
    port map( 
        -- Inputs
        PCLK           => FCCC_C0_0_GL0,
        RSTn           => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N,
        in_w_en        => Averaging_Filter_0_Data_out_ready,
        in_w_data_real => in_w_data_real_net_0,
        in_w_data_imag => in_w_data_imag_const_net_0,
        in_w_done      => FFT_0_in_full,
        out_r_en       => FFT_Result_to_Pixel_Bar_0_fft_r_en,
        out_data_adr   => FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_1,
        out_read_done  => FFT_Result_to_Pixel_Bar_0_fft_read_done,
        -- Outputs
        in_w_ready     => OPEN,
        in_full        => FFT_0_in_full,
        out_dat_real   => FFT_0_out_dat_real,
        out_dat_imag   => FFT_0_out_dat_imag,
        out_data_ready => FFT_0_out_data_ready,
        out_valid      => FFT_0_out_valid 
        );
-- FFT_Result_to_Pixel_Bar_0
FFT_Result_to_Pixel_Bar_0 : entity work.FFT_Result_to_Pixel_Bar
    generic map( 
        g_adr_width => ( 8 ),
        g_dat_width => ( 9 )
        )
    port map( 
        -- Inputs
        PCLK          => FCCC_C0_0_GL0,
        RSTn          => COREABC_C0_0_PRESETN,
        fft_dat_ready => FFT_0_out_data_ready,
        fft_dat_valid => FFT_0_out_valid,
        PSEL          => CoreAPB3_C0_0_APBmslave0_PSELx,
        PENABLE       => CoreAPB3_C0_0_APBmslave0_PENABLE,
        PWRITE        => CoreAPB3_C0_0_APBmslave0_PWRITE,
        fft_val_real  => FFT_0_out_dat_real,
        fft_val_imag  => FFT_0_out_dat_imag,
        PADDR         => CoreAPB3_C0_0_APBmslave0_PADDR_0,
        PWDATA        => CoreAPB3_C0_0_APBmslave0_PWDATA_0,
        -- Outputs
        fft_r_en      => FFT_Result_to_Pixel_Bar_0_fft_r_en,
        fft_read_done => FFT_Result_to_Pixel_Bar_0_fft_read_done,
        PREADY        => CoreAPB3_C0_0_APBmslave0_PREADY,
        PSLVERR       => CoreAPB3_C0_0_APBmslave0_PSLVERR,
        INT           => FFT_Result_to_Pixel_Bar_0_INT,
        fft_smpl_adr  => FFT_Result_to_Pixel_Bar_0_fft_smpl_adr_1,
        PRDATA        => CoreAPB3_C0_0_APBmslave0_PRDATA 
        );
-- INBUF_DIFF_0
INBUF_DIFF_0 : INBUF_DIFF
    port map( 
        -- Inputs
        PADP => PADP,
        PADN => PADN,
        -- Outputs
        Y    => INBUF_DIFF_0_Y 
        );
-- Nokia5110_Driver_0
Nokia5110_Driver_0 : entity work.Nokia5110_Driver
    generic map( 
        g_clk_period   => ( 10 ),
        g_clk_spi_div  => ( 50 ),
        g_frame_buffer => ( 1 ),
        g_frame_size   => ( 8 ),
        g_update_rate  => ( 4 )
        )
    port map( 
        -- Inputs
        CLK          => FCCC_C0_0_GL0,
        RSTn         => COREABC_C0_0_PRESETN,
        PADDR        => CoreAPB3_C0_0_APBmslave0_PADDR_1,
        PSEL         => CoreAPB3_C0_0_APBmslave1_PSELx,
        PENABLE      => CoreAPB3_C0_0_APBmslave0_PENABLE,
        PWRITE       => CoreAPB3_C0_0_APBmslave0_PWRITE,
        PWDATA       => CoreAPB3_C0_0_APBmslave0_PWDATA_1,
        -- Outputs
        driver_busy  => Nokia5110_Driver_0_driver_busy,
        SPIDO        => Board_J7_net_0,
        SPICLK       => Board_J7_0,
        data_command => Board_J7_1,
        chip_enable  => Board_J7_2,
        RSTout       => Board_J7_3,
        PREADY       => CoreAPB3_C0_0_APBmslave1_PREADY,
        PRDATA       => CoreAPB3_C0_0_APBmslave1_PRDATA,
        PSLVERR      => CoreAPB3_C0_0_APBmslave1_PSLVERR 
        );
-- OSC_C0_0
OSC_C0_0 : OSC_C0
    port map( 
        -- Outputs
        RCOSC_25_50MHZ_CCC => OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC 
        );
-- Power_On_Reset_Delay_0
Power_On_Reset_Delay_0 : entity work.Power_On_Reset_Delay
    generic map( 
        g_clk_cnt => ( 16384 )
        )
    port map( 
        -- Inputs
        CLK                  => FCCC_C0_0_GL0,
        POWER_ON_RESET_N     => SYSRESET_0_POWER_ON_RESET_N,
        EXT_RESET_IN_N       => VCC_net,
        FCCC_LOCK            => FCCC_C0_0_LOCK,
        USER_FAB_RESET_IN_N  => VCC_net,
        -- Outputs
        USER_FAB_RESET_OUT_N => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N 
        );
-- Sigma_Delta_LVDS_ADC_0
Sigma_Delta_LVDS_ADC_0 : entity work.Sigma_Delta_LVDS_ADC
    generic map( 
        g_data_bits    => ( 8 ),
        g_invert_count => ( 0 ),
        g_pclk_period  => ( 10 ),
        g_sample_div   => ( 2 )
        )
    port map( 
        -- Inputs
        PCLK               => FCCC_C0_0_GL0,
        RSTn               => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N,
        LVDS_in            => INBUF_DIFF_0_Y,
        -- Outputs
        LVDS_PADN_feedback => LVDS_PADN_feedback_net_0,
        Data_out           => Sigma_Delta_LVDS_ADC_0_Data_out,
        Data_Ready         => Sigma_Delta_LVDS_ADC_0_Data_Ready 
        );
-- SYSRESET_0
SYSRESET_0 : SYSRESET
    port map( 
        -- Inputs
        DEVRST_N         => DEVRST_N,
        -- Outputs
        POWER_ON_RESET_N => SYSRESET_0_POWER_ON_RESET_N 
        );
-- timer_0
timer_0 : entity work.timer
    generic map( 
        g_timer_count => ( 500000 )
        )
    port map( 
        -- Inputs
        CLK                   => FCCC_C0_0_GL0,
        PRESETN               => Power_On_Reset_Delay_0_USER_FAB_RESET_OUT_N,
        -- Outputs
        timer_clock_out       => Board_J8_net_0,
        timer_interrupt_pulse => OPEN 
        );

end RTL;
