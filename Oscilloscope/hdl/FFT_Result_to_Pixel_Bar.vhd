--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FFT_Result_to_Pixel_Bar.vhd
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

entity FFT_Result_to_Pixel_Bar is
generic (
    g_adr_width : natural := 8;
    g_dat_width : natural := 9
);
port (
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
end FFT_Result_to_Pixel_Bar;
architecture architecture_FFT_Result_to_Pixel_Bar of FFT_Result_to_Pixel_Bar is
    constant DAT_WIDTH : natural := g_dat_width;
    constant ADR_MAX : natural := 2**g_adr_width - 1;

    signal fft_r_en_sig : std_logic;
    signal fft_read_done_sig : std_logic;
    signal fft_smpl_adr_sig : std_logic_vector(g_adr_width - 1 downto 0);
    signal fft_val_real_sig : std_logic_vector(DAT_WIDTH - 1 downto 0);
    signal fft_val_imag_sig : std_logic_vector(DAT_WIDTH - 1 downto 0);
    signal fft_dat_ready_sig : std_logic;
    signal fft_dat_valid_sig : std_logic;

    signal fft_dat_ready_last : std_logic;


    -- BEGIN APB signals
    --signal PADDR_sig : std_logic_vector(7 downto 0);
    --signal PSEL_sig : std_logic;
    --signal PENABLE_sig : std_logic;
    --signal PWRITE_sig : std_logic;
    --signal PWDATA_sig : std_logic_vector(7 downto 0);
    --signal PREADY_sig : std_logic;
    signal PRDATA_sig : std_logic_vector(7 downto 0);
    --signal PSLVERR_sig : std_logic;
    -- END APB signals

    -- APB registers and sub signals
    constant CTRL_REG_ADR : std_logic_vector(7 downto 0) := X"00";
    constant SMPL_ADR_ADR : std_logic_vector(7 downto 0) := X"01";
    constant SMPL_MAG_ADR : std_logic_vector(7 downto 0) := X"10";
    constant SMPL_PB0_ADR : std_logic_vector(7 downto 0) := X"11";
    constant SMPL_PB1_ADR : std_logic_vector(7 downto 0) := X"12";
    constant SMPL_PB2_ADR : std_logic_vector(7 downto 0) := X"13";
    constant SMPL_PB3_ADR : std_logic_vector(7 downto 0) := X"14";

    signal ctrl_reg : std_logic_vector(7 downto 0);
    signal smpl_adr_reg : std_logic_vector(7 downto 0);
    signal smpl_mag_reg : std_logic_vector(7 downto 0);
    signal smpl_pb0_reg : std_logic_vector(7 downto 0);
    signal smpl_pb1_reg : std_logic_vector(7 downto 0);
    signal smpl_pb2_reg : std_logic_vector(7 downto 0);
    signal smpl_pb3_reg : std_logic_vector(7 downto 0);
    -- APB registers and sub signals

    signal smpl_read : std_logic;
    signal smpl_data_stable : std_logic;

    constant DELAY : natural := 5;
    signal delay_cnt : natural range 0 to DELAY - 1 := 0;

    signal comp_rstn : std_logic;

--=========================================================================

    component Alpha_Max_plus_Beta_Min
    generic (
        g_data_width : natural;
        g_adr_width : natural;
        g_adr_pipe : natural
    );
    port( 
        -- Inputs
        PCLK : in std_logic;
        RSTn : in std_logic;
        assoc_adr_in : in std_logic_vector(g_adr_width - 1 downto 0);
        val_A : in std_logic_vector(g_data_width - 1 downto 0);
        val_B : in std_logic_vector(g_data_width - 1 downto 0);
        in_valid : in std_logic;

        -- Outputs
        assoc_adr_out : out std_logic_vector(g_adr_width - 1 downto 0);
        o_flow : out std_logic;
        out_valid : out std_logic;
        result : out std_logic_vector(g_data_width - 1 downto 0)

        -- Inouts

    );
    end component;

    signal AMpBM_0_assoc_adr_in_sig : std_logic_vector(g_adr_width - 1 downto 0);
    signal AMpBM_0_val_A_sig : std_logic_vector(DAT_WIDTH - 1 downto 0);
    signal AMpBM_0_val_B_sig : std_logic_vector(DAT_WIDTH - 1 downto 0);
    signal AMpBM_0_in_valid_sig : std_logic;
    signal AMpBM_0_out_valid_sig : std_logic;
    signal AMpBM_0_assoc_adr_out_sig : std_logic_vector(g_adr_width - 1 downto 0);
    signal AMpBM_0_o_flow_sig : std_logic;
    signal AMpBM_0_result_sig : std_logic_vector(DAT_WIDTH - 1 downto 0);
    signal mag_result_corrected : std_logic_vector(7 downto 0);

    constant PIXEL_REG_CNT : natural := 4;
    constant PIXEL_REG_WID : natural := 8;

    component Pixelbar_Creator
    generic (
        g_pixel_registers : natural;
        g_pixel_register_size : natural;
        g_data_in_bits : natural;
        g_invert_bars : natural
    );
    port (
        PCLK : in std_logic;      -- 100Mhz
        RSTn : in std_logic;

        Data_in_ready : in std_logic;
        Data_in : in std_logic_vector(g_data_in_bits - 1 downto 0);
        Pixel_bar_out : out std_logic_vector((g_pixel_registers * g_pixel_register_size) - 1 downto 0);
        Data_out_ready : out std_logic
    );
    end component;

    signal PbCr_0_Data_in_ready : std_logic;
    signal PbCr_0_Data_in : std_logic_vector(DAT_WIDTH - 2 downto 0);
    signal PbCr_0_Pixel_bar_out : std_logic_vector((PIXEL_REG_CNT * PIXEL_REG_WID) - 1 downto 0);
    signal PbCr_0_Data_out_ready : std_logic;

begin

    --PADDR_sig <= PADDR;
    --PSEL_sig <= PSEL;
    --PENABLE_sig <= PENABLE;
    --PWRITE_sig <= PWRITE;
    --PWDATA_sig <= PWDATA;
    --PREADY <= PREADY_sig;
    --PRDATA <= PRDATA_sig;
    --PSLVERR <= PSLVERR_sig;

    -- BEGIN APB Register Read logic
    p_APB_Reg_Read : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            PRDATA_sig <= (others => '0');
            smpl_read <= '0';
        elsif(rising_edge(PCLK)) then
            if(PWRITE = '0' and PSEL = '1') then
                case PADDR is
                    when CTRL_REG_ADR =>
                        PRDATA_sig <= ctrl_reg;
                    when SMPL_ADR_ADR =>
                        PRDATA_sig <= smpl_adr_reg;
                    when SMPL_MAG_ADR =>
                        PRDATA_sig <= smpl_mag_reg;
                        smpl_read <= '1';
                    when SMPL_PB0_ADR =>
                        PRDATA_sig <= smpl_pb0_reg;
                        smpl_read <= '1';
                    when SMPL_PB1_ADR =>
                        PRDATA_sig <= smpl_pb1_reg;
                        smpl_read <= '1';
                    when SMPL_PB2_ADR =>
                        PRDATA_sig <= smpl_pb2_reg;
                        smpl_read <= '1';
                    when SMPL_PB3_ADR =>
                        PRDATA_sig <= smpl_pb3_reg;
                        smpl_read <= '1';
                    when others =>
                        PRDATA_sig <= (others => '0');
                end case;
            else
                PRDATA_sig <= (others => '0');
                smpl_read <= '0';
            end if;
        end if;
    end process;
    
    -- BEGIN APB Return wires
    PRDATA <= PRDATA_sig;
    PREADY <= smpl_data_stable when smpl_read = '1' else '1';
    PSLVERR <= '0';
    -- END APB Return wires

    -- END APB Register Read logic

--=========================================================================

    fft_r_en <= fft_r_en_sig;
    fft_read_done <= fft_read_done_sig;
    fft_smpl_adr <= fft_smpl_adr_sig;

    fft_val_real_sig <= fft_val_real;
    fft_val_imag_sig <= fft_val_imag;
    fft_dat_ready_sig <= fft_dat_ready;
    fft_dat_valid_sig <= fft_dat_valid;

--=========================================================================

    p_reg_ctrl : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            ctrl_reg <= "00000000";
            fft_dat_ready_last <= '0';
        elsif(rising_edge(PCLK)) then
            fft_dat_ready_last <= fft_dat_ready_sig;
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR = CTRL_REG_ADR) then
                -- 0b & INT & XXX_XX & fft_dat_valid & fft_read_done
                ctrl_reg <= PWDATA;
            else
                if(fft_dat_ready_last = '0' and fft_dat_ready_sig = '1') then
                    ctrl_reg(7) <= '1';
                    ctrl_reg(0) <= '0';
                end if;
                ctrl_reg(1) <= fft_dat_valid_sig;
            end if;
        end if;
    end process;

    INT <= ctrl_reg(7);
    fft_read_done_sig <= ctrl_reg(0);

    p_reg_smpl_adr : process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            smpl_adr_reg <= "00000000";
            smpl_data_stable <= '0';
            comp_rstn <= '0';
            delay_cnt <= 0;
            fft_r_en_sig <= '0';
        elsif(rising_edge(PCLK)) then
            if(PSEL = '1' and PENABLE = '1' and PWRITE = '1' and PADDR = SMPL_ADR_ADR) then
                -- 0bXXXX_XXXX
                smpl_adr_reg <= PWDATA;
                smpl_data_stable <= '0';
                comp_rstn <= '0';       -- components are pipelined, this clears the pipe so no invalid data
                delay_cnt <= 0;
                fft_r_en_sig <= '1';
            else
                comp_rstn <= '1';
                fft_r_en_sig <= '0';
            end if;

            if(smpl_data_stable = '0') then
                if(delay_cnt /= DELAY - 1) then
                    delay_cnt <= delay_cnt + 1;
                else
                    smpl_data_stable <= '1';
                end if;
            end if;
        end if;
    end process;
    
    fft_smpl_adr_sig <= smpl_adr_reg(g_adr_width - 1 downto 0);

    smpl_mag_reg <= mag_result_corrected when AMpBM_0_o_flow_sig = '0' else (others => '1');
    smpl_pb0_reg <= PbCr_0_Pixel_bar_out(7 downto 0);
    smpl_pb1_reg <= PbCr_0_Pixel_bar_out(15 downto 8);
    smpl_pb2_reg <= PbCr_0_Pixel_bar_out(23 downto 16);
    smpl_pb3_reg <= PbCr_0_Pixel_bar_out(31 downto 24);

--=========================================================================


    AMpBM_0_in_valid_sig <= fft_dat_valid_sig;
    AMpBM_0_assoc_adr_in_sig <= (others => '0');
    AMpBM_0_val_A_sig <= fft_val_real_sig;
    AMpBM_0_val_B_sig <= fft_val_imag_sig;

    Alpha_Max_plus_Beta_Min_0 : Alpha_Max_plus_Beta_Min
    generic map(
        g_data_width => DAT_WIDTH,
        g_adr_width => g_adr_width,
        g_adr_pipe => 1
    )
    -- port map
    port map( 
        -- Inputs
        PCLK => PCLK,
        RSTn => comp_rstn,
        in_valid => AMpBM_0_in_valid_sig,
        assoc_adr_in => AMpBM_0_assoc_adr_in_sig,
        val_A => AMpBM_0_val_A_sig,
        val_B => AMpBM_0_val_B_sig,

        -- Outputs
        assoc_adr_out => open,--AMpBM_0_assoc_adr_out_sig,
        o_flow => AMpBM_0_o_flow_sig,
        out_valid => AMpBM_0_out_valid_sig,
        result => AMpBM_0_result_sig

        -- Inouts

    );

    mag_result_corrected <= AMpBM_0_result_sig(7 downto 0) when smpl_adr_reg = "00000000" or smpl_adr_reg = "11111111" else
                            AMpBM_0_result_sig(6 downto 0) & '0';
    --AMpBM_0_assoc_adr_out_sig
    --AMpBM_0_o_flow_sig
    PbCr_0_Data_in_ready <= AMpBM_0_out_valid_sig;
    PbCr_0_Data_in <= mag_result_corrected when AMpBM_0_o_flow_sig = '0' else (others => '1');

    Pixelbar_Creator_0 : Pixelbar_Creator
    generic map(
        g_pixel_registers => PIXEL_REG_CNT,
        g_pixel_register_size => PIXEL_REG_WID,
        g_data_in_bits => DAT_WIDTH - 1,
        g_invert_bars => 1
    )
    port map(
        PCLK => PCLK,
        RSTn => comp_rstn,

        Data_in_ready => PbCr_0_Data_in_ready,
        Data_in => PbCr_0_Data_in,
        Pixel_bar_out => PbCr_0_Pixel_bar_out,
        Data_out_ready => PbCr_0_Data_out_ready
    );

   -- architecture body
end architecture_FFT_Result_to_Pixel_Bar;
