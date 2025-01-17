--Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2015.4 (lin64) Build 1412921 Wed Nov 18 09:44:32 MST 2015
--Date        : Mon Aug  8 13:00:30 2016
--Host        : Mimas running 64-bit Debian GNU/Linux 8.4 (jessie)
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    Dir : out STD_LOGIC;
    Dir_1 : out STD_LOGIC;
    Dir_2 : out STD_LOGIC;
    Dir_3 : out STD_LOGIC;
    Dir_4 : out STD_LOGIC;
    Enable : out STD_LOGIC;
    Enable_1 : out STD_LOGIC;
    Enable_2 : out STD_LOGIC;
    Enable_3 : out STD_LOGIC;
    Enable_4 : out STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    Pulse : out STD_LOGIC;
    Pulse_1 : out STD_LOGIC;
    Pulse_2 : out STD_LOGIC;
    Pulse_3 : out STD_LOGIC;
    Pulse_4 : out STD_LOGIC;
    chan_A : in STD_LOGIC;
    chan_A_1 : in STD_LOGIC;
    chan_A_2 : in STD_LOGIC;
    chan_A_3 : in STD_LOGIC;
    chan_A_4 : in STD_LOGIC;
    chan_A_5 : in STD_LOGIC;
    chan_B : in STD_LOGIC;
    chan_B_1 : in STD_LOGIC;
    chan_B_2 : in STD_LOGIC;
    chan_B_3 : in STD_LOGIC;
    chan_B_4 : in STD_LOGIC;
    chan_B_5 : in STD_LOGIC;
    chan_nA : in STD_LOGIC;
    chan_nA_1 : in STD_LOGIC;
    chan_nA_2 : in STD_LOGIC;
    chan_nA_3 : in STD_LOGIC;
    chan_nA_4 : in STD_LOGIC;
    chan_nA_5 : in STD_LOGIC;
    chan_nB : in STD_LOGIC;
    chan_nB_1 : in STD_LOGIC;
    chan_nB_2 : in STD_LOGIC;
    chan_nB_3 : in STD_LOGIC;
    chan_nB_4 : in STD_LOGIC;
    chan_nB_5 : in STD_LOGIC;
    reset_rtl : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is
  component design_1 is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    sys_clock : in STD_LOGIC;
    reset_rtl : in STD_LOGIC;
    chan_A : in STD_LOGIC;
    chan_B : in STD_LOGIC;
    chan_A_3 : in STD_LOGIC;
    chan_B_3 : in STD_LOGIC;
    chan_B_2 : in STD_LOGIC;
    chan_A_2 : in STD_LOGIC;
    chan_B_1 : in STD_LOGIC;
    chan_A_1 : in STD_LOGIC;
    chan_A_4 : in STD_LOGIC;
    chan_B_4 : in STD_LOGIC;
    chan_A_5 : in STD_LOGIC;
    chan_B_5 : in STD_LOGIC;
    Pulse : out STD_LOGIC;
    Pulse_1 : out STD_LOGIC;
    Pulse_2 : out STD_LOGIC;
    Pulse_3 : out STD_LOGIC;
    Pulse_4 : out STD_LOGIC;
    chan_nA : in STD_LOGIC;
    chan_nB : in STD_LOGIC;
    chan_nA_1 : in STD_LOGIC;
    chan_nB_1 : in STD_LOGIC;
    chan_nA_2 : in STD_LOGIC;
    chan_nB_2 : in STD_LOGIC;
    chan_nA_3 : in STD_LOGIC;
    chan_nB_3 : in STD_LOGIC;
    chan_nA_4 : in STD_LOGIC;
    chan_nB_4 : in STD_LOGIC;
    chan_nA_5 : in STD_LOGIC;
    chan_nB_5 : in STD_LOGIC;
    Dir : out STD_LOGIC;
    Enable : out STD_LOGIC;
    Dir_1 : out STD_LOGIC;
    Enable_1 : out STD_LOGIC;
    Dir_2 : out STD_LOGIC;
    Enable_2 : out STD_LOGIC;
    Dir_3 : out STD_LOGIC;
    Enable_3 : out STD_LOGIC;
    Dir_4 : out STD_LOGIC;
    Enable_4 : out STD_LOGIC
  );
  end component design_1;
begin
design_1_i: component design_1
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      Dir => Dir,
      Dir_1 => Dir_1,
      Dir_2 => Dir_2,
      Dir_3 => Dir_3,
      Dir_4 => Dir_4,
      Enable => Enable,
      Enable_1 => Enable_1,
      Enable_2 => Enable_2,
      Enable_3 => Enable_3,
      Enable_4 => Enable_4,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      Pulse => Pulse,
      Pulse_1 => Pulse_1,
      Pulse_2 => Pulse_2,
      Pulse_3 => Pulse_3,
      Pulse_4 => Pulse_4,
      chan_A => chan_A,
      chan_A_1 => chan_A_1,
      chan_A_2 => chan_A_2,
      chan_A_3 => chan_A_3,
      chan_A_4 => chan_A_4,
      chan_A_5 => chan_A_5,
      chan_B => chan_B,
      chan_B_1 => chan_B_1,
      chan_B_2 => chan_B_2,
      chan_B_3 => chan_B_3,
      chan_B_4 => chan_B_4,
      chan_B_5 => chan_B_5,
      chan_nA => chan_nA,
      chan_nA_1 => chan_nA_1,
      chan_nA_2 => chan_nA_2,
      chan_nA_3 => chan_nA_3,
      chan_nA_4 => chan_nA_4,
      chan_nA_5 => chan_nA_5,
      chan_nB => chan_nB,
      chan_nB_1 => chan_nB_1,
      chan_nB_2 => chan_nB_2,
      chan_nB_3 => chan_nB_3,
      chan_nB_4 => chan_nB_4,
      chan_nB_5 => chan_nB_5,
      reset_rtl => reset_rtl,
      sys_clock => sys_clock
    );
end STRUCTURE;
