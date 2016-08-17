----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.06.2016 14:00:11
-- Design Name: 
-- Module Name: IP_PWM_Struct - Structural
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IP_PWM_Struct is
	generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH    : integer    := 32;
    C_S00_AXI_ADDR_WIDTH    : integer    := 4
    );
	port (
    -- Ports of Axi Slave Bus Interface pwm_AXI
    Pulse : out std_logic;
    Dir : out std_logic;
    Enable : out std_logic;
    clk : in std_logic;
    s00_axi_aclk    : in std_logic;
    s00_axi_aresetn    : in std_logic;
    s00_axi_awaddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot    : in std_logic_vector(2 downto 0);
    s00_axi_awvalid    : in std_logic;
    s00_axi_awready    : out std_logic;
    s00_axi_wdata    : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb    : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid    : in std_logic;
    s00_axi_wready    : out std_logic;
    s00_axi_bresp    : out std_logic_vector(1 downto 0);
    s00_axi_bvalid    : out std_logic;
    s00_axi_bready    : in std_logic;
    s00_axi_araddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot    : in std_logic_vector(2 downto 0);
    s00_axi_arvalid    : in std_logic;
    s00_axi_arready    : out std_logic;
    s00_axi_rdata    : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp    : out std_logic_vector(1 downto 0);
    s00_axi_rvalid    : out std_logic;
    s00_axi_rready    : in std_logic
    );
end IP_PWM_Struct;

architecture Structural of IP_PWM_Struct is
    component PWM_AXI_v2_v1_0 is
    generic (
        C_S00_AXI_DATA_WIDTH    : integer    := 32;
        C_S00_AXI_ADDR_WIDTH    : integer    := 4
    );
    port (
        Width : out std_logic_vector(31 downto 0);
        Freq : out std_logic_vector(31 downto 0);
        Dir : out std_logic;
        Enable : out std_logic;
        pwm_axi_aclk    : in std_logic;
        pwm_axi_aresetn    : in std_logic;
        pwm_axi_awaddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        pwm_axi_awprot    : in std_logic_vector(2 downto 0);
        pwm_axi_awvalid    : in std_logic;
        pwm_axi_awready    : out std_logic;
        pwm_axi_wdata    : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        pwm_axi_wstrb    : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        pwm_axi_wvalid    : in std_logic;
        pwm_axi_wready    : out std_logic;
        pwm_axi_bresp    : out std_logic_vector(1 downto 0);
        pwm_axi_bvalid    : out std_logic;
        pwm_axi_bready    : in std_logic;
        pwm_axi_araddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        pwm_axi_arprot    : in std_logic_vector(2 downto 0);
        pwm_axi_arvalid    : in std_logic;
        pwm_axi_arready    : out std_logic;
        pwm_axi_rdata    : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        pwm_axi_rresp    : out std_logic_vector(1 downto 0);
        pwm_axi_rvalid    : out std_logic;
        pwm_axi_rready    : in std_logic
    );
    end component;
    
    component PWM is
    port (
            clk : in STD_LOGIC;
            nrst : in STD_LOGIC;
            width : in STD_LOGIC_VECTOR (31 downto 0);
            Freq : in std_logic_vector(31 downto 0);
            pulse_out : out STD_LOGIC
    );
    end component;
    
    signal int_width : std_logic_vector(31 downto 0);
    signal int_freq : std_logic_vector(31 downto 0);
begin
    PWM_AXI_IP : PWM_AXI_v2_v1_0
	generic map (
		C_S00_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S00_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    Width => int_width,
	    Freq => int_freq,
        Dir => Dir,
        Enable => Enable,
		pwm_axi_aclk => s00_axi_aclk,
		pwm_axi_aresetn => s00_axi_aresetn,
		pwm_axi_awaddr => s00_axi_awaddr,
		pwm_axi_awprot => s00_axi_awprot,
		pwm_axi_awvalid=> s00_axi_awvalid,
		pwm_axi_awready => s00_axi_awready,
		pwm_axi_wdata => s00_axi_wdata,
		pwm_axi_wstrb => s00_axi_wstrb,
		pwm_axi_wvalid => s00_axi_wvalid,
		pwm_axi_wready => s00_axi_wready,
		pwm_axi_bresp => s00_axi_bresp,
		pwm_axi_bvalid => s00_axi_bvalid,
		pwm_axi_bready => s00_axi_bready,
		pwm_axi_araddr => s00_axi_araddr,
		pwm_axi_arprot => s00_axi_arprot,
		pwm_axi_arvalid => s00_axi_arvalid,
		pwm_axi_arready => s00_axi_arready,
		pwm_axi_rdata => s00_axi_rdata,
		pwm_axi_rresp => s00_axi_rresp,
		pwm_axi_rvalid => s00_axi_rvalid,
		pwm_axi_rready => s00_axi_rready
	);
	
	PWM_2 : PWM
    port map (
        Width => int_width,
        Freq => int_freq,
        clk => clk,
        nrst => s00_axi_aresetn,
        pulse_out => Pulse
    );
end Structural;
