----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Fri Mar 13 03:15:52 2020
-- Parameters for COREABC
----------------------------------------------------------------------


LIBRARY ieee;
   USE ieee.std_logic_1164.all;
   USE ieee.std_logic_unsigned.all;
   USE ieee.numeric_std.all;

package coreparameters is
    constant ABCCODE : string( 1 to 3035 ) := "JUMP $MAIN

    APBREAD FFT_ADR FFT_CTRL
    BITTST FFT_DAT_VAL_POS
    JUMP IFNOT ZERO $DONE_WITH_SMPL_BLOCK
    
    $DO_COLUMN
    
    
    //RAMREAD RAM_X_pos
    APBWRT ACC FFT_ADR FFT_SMPL_ADR
    APBWRT ACC LCD_ADR LCD_pixels_X_ADDR
    
    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 0
    APBWRT DAT8 LCD_ADR LCD_pixels_data_ADDR 0b01000000
    
    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 1
    APBREAD FFT_ADR FFT_SMPL_PB0
    APBWRT ACC LCD_ADR LCD_pixels_data_ADDR

    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 2
    APBREAD FFT_ADR FFT_SMPL_PB1
    APBWRT ACC LCD_ADR LCD_pixels_data_ADDR

    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 3
    APBREAD FFT_ADR FFT_SMPL_PB2
    APBWRT ACC LCD_ADR LCD_pixels_data_ADDR

    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 4
    APBREAD FFT_ADR FFT_SMPL_PB3
    APBWRT ACC LCD_ADR LCD_pixels_data_ADDR
    
    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 5
    APBWRT DAT8 LCD_ADR LCD_pixels_data_ADDR 0b00000010
    
    RAMREAD RAM_X_pos
    INC
    CMP DAT 84
    RAMWRT RAM_X_pos ACC
    JUMP IFNOT ZERO $DO_COLUMN
        // equal
    
    $DONE_WITH_SMPL_BLOCK

    APBWRT DAT8 FFT_ADR FFT_CTRL FFT_DAT_DONE_MASK
    
    // change LCD frame buffer to write to
    APBREAD LCD_ADR LCD_ctrl_ADDR
    XOR DAT8 0b00000100
    APBWRT ACC LCD_ADR LCD_ctrl_ADDR
    RAMWRT RAM_X_pos DAT8 0

    RETISR
$MAIN

    DEF FFT_ADR 0
    
    DEF FFT_CTRL 0x00
    DEF FFT_SMPL_ADR 0x01
    DEF FFT_SMPL_MAG 0x10
    DEF FFT_SMPL_PB0 0x11
    DEF FFT_SMPL_PB1 0x12
    DEF FFT_SMPL_PB2 0x13
    DEF FFT_SMPL_PB3 0x14
    
    DEF FFT_DAT_DONE_MASK 0b00000001
    DEF FFT_DAT_DONE_POS 0
    DEF FFT_DAT_VAL_MASK 0b00000010
    DEF FFT_DAT_VAL_POS 2
    DEF FFT_INT_MASK 0b10000000
    DEF FFT_INT_POS 7
    
    
    
    DEF LCD_ADR 1
    
    DEF LCD_ctrl_ADDR 0x00
    DEF LCD_pixels_data_ADDR 0x10
    DEF LCD_pixels_X_ADDR 0x11
    DEF LCD_pixels_Y_ADDR 0x12
    
    
    //DEF RAM_pixels      0x00
    //DEF RAM_pixels_last 0x01
    DEF RAM_X_pos       0x02
    
    // set LCD to write to both frame buffers
    APBREAD LCD_ADR LCD_ctrl_ADDR
    OR DAT8 0b00001000
    APBWRT ACC LCD_ADR LCD_ctrl_ADDR
    
    APBWRT DAT8 LCD_ADR LCD_pixels_X_ADDR 0
    APBWRT DAT8 LCD_ADR LCD_pixels_Y_ADDR 0
    APBWRT DAT8 LCD_ADR LCD_pixels_data_ADDR 0x0F
    $clear_lcd
    APBREAD LCD_ADR LCD_pixels_X_ADDR
    INC
    CMP DAT8 84
    JUMP IFNOT ZERO $WRT_X_ADDR
        APBREAD LCD_ADR LCD_pixels_Y_ADDR
        INC
        CMP DAT8 6
        JUMP IFNOT ZERO $WRT_Y_ADDDR
            LOAD DAT8 LCD_ADR
            JUMP $Halt_Stuff
        $WRT_Y_ADDDR
        APBWRT ACC LCD_ADR LCD_pixels_Y_ADDR
        LOAD DAT8 0
    $WRT_X_ADDR
    // writes 0 if = 84, or writes source + 1
    APBWRT ACC LCD_ADR LCD_pixels_X_ADDR
    APBWRT ACC LCD_ADR LCD_pixels_data_ADDR
    JUMP $clear_lcd

    $Halt_Stuff
    // set LCD stop writing to both frame buffers
    APBREAD LCD_ADR LCD_ctrl_ADDR
    AND DAT8 0b11110111
    APBWRT ACC LCD_ADR LCD_ctrl_ADDR
    

    APBWRT DAT8 FFT_ADR FFT_CTRL FFT_DAT_DONE_MASK


    HALT";
    constant ACT_CALIBRATIONDATA : integer := 1;
    constant APB_AWIDTH : integer := 8;
    constant APB_DWIDTH : integer := 8;
    constant APB_SDEPTH : integer := 2;
    constant CODEHEXDUMP : string( 1 to 0 ) := "";
    constant CODEHEXDUMP2 : string( 1 to 0 ) := "";
    constant DEBUG : integer := 1;
    constant EN_ACM : integer := 0;
    constant EN_ADD : integer := 1;
    constant EN_ALURAM : integer := 0;
    constant EN_AND : integer := 1;
    constant EN_CALL : integer := 1;
    constant EN_DATAM : integer := 2;
    constant EN_INC : integer := 1;
    constant EN_INDIRECT : integer := 0;
    constant EN_INT : integer := 1;
    constant EN_IOREAD : integer := 1;
    constant EN_IOWRT : integer := 1;
    constant EN_MULT : integer := 0;
    constant EN_OR : integer := 1;
    constant EN_PUSH : integer := 1;
    constant EN_RAM : integer := 1;
    constant EN_SHL : integer := 1;
    constant EN_SHR : integer := 1;
    constant EN_XOR : integer := 1;
    constant FAMILY : integer := 19;
    constant HDL_license : string( 1 to 1 ) := "U";
    constant ICWIDTH : integer := 6;
    constant IFWIDTH : integer := 2;
    constant IIWIDTH : integer := 2;
    constant IMEM_APB_ACCESS : integer := 0;
    constant INITWIDTH : integer := 11;
    constant INSMODE : integer := 0;
    constant IOWIDTH : integer := 1;
    constant ISRADDR : integer := 1;
    constant MAX_NVMDWIDTH : integer := 32;
    constant STWIDTH : integer := 4;
    constant TESTBENCH : string( 1 to 4 ) := "User";
    constant TESTMODE : integer := 0;
    constant UNIQ_STRING : string( 1 to 23 ) := "COREABC_C0_COREABC_C0_0";
    constant UNIQ_STRING_LENGTH : integer := 23;
    constant VERILOGCODE : string( 1 to 0 ) := "";
    constant VERILOGVARS : string( 1 to 0 ) := "";
    constant VHDLCODE : string( 1 to 0 ) := "";
    constant VHDLVARS : string( 1 to 0 ) := "";
    constant ZRWIDTH : integer := 0;
end coreparameters;
