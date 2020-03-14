--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Abs_Val_Cmplx.vhd
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

entity Abs_Val_Cmplx is
generic (
    g_adr_width : natural := 8
);
port (
    PCLK : in std_logic;
    RSTn : in std_logic;

    in_ready : in std_logic;
    in_valid : in std_logic;
    real_in : in std_logic_vector(8 downto 0);
    imag_in : in std_logic_vector(8 downto 0);
    r_en : out std_logic;
    data_adr_r : out std_logic_vector(g_adr_width - 1 downto 0);
    data_adr_w : out std_logic_vector(g_adr_width - 1 downto 0);
    out_valid : out std_logic;
    mag_out : out std_logic_vector(7 downto 0)
);
end Abs_Val_Cmplx;
architecture architecture_Abs_Val_Cmplx of Abs_Val_Cmplx is

    constant DAT_WIDTH : natural := 9;
    constant ADR_MAX : natural := 2**g_adr_width - 1;


    signal in_ready_sig : std_logic;
    signal in_valid_sig : std_logic;
    signal real_in_sig : std_logic_vector(8 downto 0);
    signal imag_in_sig : std_logic_vector(8 downto 0);
    signal r_en_sig : std_logic;
    signal data_adr_r_sig : std_logic_vector(g_adr_width - 1 downto 0);
    signal data_adr_w_sig : std_logic_vector(g_adr_width - 1 downto 0);
    signal out_valid_sig : std_logic;
    signal mag_out_sig : std_logic_vector(7 downto 0);

    type abs_write_states is(idle, reqDat, getDat, absStart);
    type abs_read_states is(idle, absDone, outResult);
    signal abs_w_state : abs_write_states;
    signal abs_r_state : abs_read_states;

    signal adr_cnt : unsigned(g_adr_width - 1 downto 0);

    signal adr_working : std_logic_vector(g_adr_width - 1 downto 0);

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
        val_A : in std_logic_vector(dat_width - 1 downto 0);
        val_B : in std_logic_vector(dat_width - 1 downto 0);
        in_valid : in std_logic;

        -- Outputs
        assoc_adr_out : out std_logic_vector(g_adr_width - 1 downto 0);
        o_flow : out std_logic;
        out_valid : out std_logic;
        result : out std_logic_vector(dat_width - 1 downto 0)

        -- Inouts

    );
    end component;

    signal AMpBM_0_assoc_adr_in : std_logic_vector(g_adr_width - 1 downto 0);
    signal AMpBM_0_val_A : std_logic_vector(dat_width - 1 downto 0);
    signal AMpBM_0_val_B : std_logic_vector(dat_width - 1 downto 0);
    signal AMpBM_0_in_valid : std_logic;
    signal AMpBM_0_out_valid : std_logic;
    signal AMpBM_0_assoc_adr_out : std_logic_vector(g_adr_width - 1 downto 0);
    signal AMpBM_0_o_flow : std_logic;
    signal AMpBM_0_result : std_logic_vector(dat_width - 1 downto 0);
    
begin

    in_ready_sig <= in_ready;
    in_valid_sig <= in_valid;
    real_in_sig <= real_in;
    imag_in_sig <= imag_in;

    r_en <= r_en_sig;
    data_adr_r <= data_adr_r_sig;
    data_adr_w <= data_adr_w_sig;
    out_valid <= out_valid_sig;
    mag_out <= mag_out_sig;

--=========================================================================

    process(PCLK, RSTn)
    begin
        if(RSTn = '0') then
            data_adr_w_sig <= (others => '0');
            data_adr_r_sig <= (others => '0');
            AMpBM_0_assoc_adr_in <= (others => '0');
            out_valid_sig <= '0';
            mag_out_sig <= (others => '0');

            abs_w_state <= idle;
            abs_r_state <= idle;
            adr_cnt <= (others => '0');

            AMpBM_0_in_valid <= '0';
            AMpBM_0_val_A <= (others => '0');
            AMpBM_0_val_B <= (others => '0');
        elsif(rising_edge(PCLK)) then
            if(in_ready_sig = '0') then
                -- sync reset
                data_adr_w_sig <= (others => '0');
                data_adr_r_sig <= (others => '0');
                AMpBM_0_assoc_adr_in <= (others => '0');
                out_valid_sig <= '0';
                mag_out_sig <= (others => '0');
    
                abs_w_state <= idle;
                abs_r_state <= idle;
                adr_cnt <= (others => '0');
            else
                case abs_w_state is
                    when idle =>
                        abs_w_state <= reqDat;
                    when reqDat =>
                        abs_w_state <= getDat;
                        if(adr_cnt /= ADR_MAX) then
                            adr_cnt <= adr_cnt + 1;
                        else

                        end if;
                        data_adr_r_sig <= std_logic_vector(adr_cnt);
                        AMpBM_0_assoc_adr_in <= std_logic_vector(adr_cnt);
                    when getDat =>
                        abs_w_state <= absStart;
                        if(in_valid_sig = '1') then
                            AMpBM_0_val_A <= real_in_sig;
                            AMpBM_0_val_B <= imag_in_sig;
                        end if;
                    when absStart =>
                        --if(RFD = '1' and in_valid = '0') then
                        --    AMpBM_0_in_valid <= '1';
                        --elsif(RFD = '0' and in_valid = '1') then
                        --    AMpBM_0_in_valid <= '0';
                            --abs_w_state <= outResult;
                        --end if;

                    when others =>
                end case;

                case abs_r_state is
                    when idle =>
                        if(out_valid = '1') then

                        end if;
                    when absDone =>
                    when outResult =>
                    when others =>
                end case;
            end if;
        end if;
    end process;

--=========================================================================

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
        RSTn => RSTn,
        in_valid => AMpBM_0_in_valid,
        assoc_adr_in => AMpBM_0_assoc_adr_in,
        val_A => AMpBM_0_val_A,
        val_B => AMpBM_0_val_B,

        -- Outputs
        assoc_adr_out => AMpBM_0_assoc_adr_out,
        o_flow => AMpBM_0_o_flow,
        out_valid => AMpBM_0_out_valid,
        result => AMpBM_0_result

        -- Inouts

    );

   -- architecture body
end architecture_Abs_Val_Cmplx;
