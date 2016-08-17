library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM_AXI_v2_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
        Width : out std_logic_vector(31 downto 0);
        Freq : out std_logic_vector(31 downto 0);
        Dir : out std_logic;
        Enable : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		pwm_axi_aclk	: in std_logic;
		pwm_axi_aresetn	: in std_logic;
		pwm_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		pwm_axi_awprot	: in std_logic_vector(2 downto 0);
		pwm_axi_awvalid	: in std_logic;
		pwm_axi_awready	: out std_logic;
		pwm_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		pwm_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		pwm_axi_wvalid	: in std_logic;
		pwm_axi_wready	: out std_logic;
		pwm_axi_bresp	: out std_logic_vector(1 downto 0);
		pwm_axi_bvalid	: out std_logic;
		pwm_axi_bready	: in std_logic;
		pwm_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		pwm_axi_arprot	: in std_logic_vector(2 downto 0);
		pwm_axi_arvalid	: in std_logic;
		pwm_axi_arready	: out std_logic;
		pwm_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		pwm_axi_rresp	: out std_logic_vector(1 downto 0);
		pwm_axi_rvalid	: out std_logic;
		pwm_axi_rready	: in std_logic
	);
end PWM_AXI_v2_v1_0;

architecture arch_imp of PWM_AXI_v2_v1_0 is

	-- component declaration
	component PWM_AXI_v2_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		Width : out std_logic_vector(31 downto 0);
        Freq : out std_logic_vector(31 downto 0);
        Dir : out std_logic;
        Enable : out std_logic;
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component PWM_AXI_v2_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
PWM_AXI_v2_v1_0_S00_AXI_inst : PWM_AXI_v2_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    Width => Width,
        Freq => Freq,
        Dir => Dir,
        Enable => Enable,
		S_AXI_ACLK	=> pwm_axi_aclk,
		S_AXI_ARESETN	=> pwm_axi_aresetn,
		S_AXI_AWADDR	=> pwm_axi_awaddr,
		S_AXI_AWPROT	=> pwm_axi_awprot,
		S_AXI_AWVALID	=> pwm_axi_awvalid,
		S_AXI_AWREADY	=> pwm_axi_awready,
		S_AXI_WDATA	=> pwm_axi_wdata,
		S_AXI_WSTRB	=> pwm_axi_wstrb,
		S_AXI_WVALID	=> pwm_axi_wvalid,
		S_AXI_WREADY	=> pwm_axi_wready,
		S_AXI_BRESP	=> pwm_axi_bresp,
		S_AXI_BVALID	=> pwm_axi_bvalid,
		S_AXI_BREADY	=> pwm_axi_bready,
		S_AXI_ARADDR	=> pwm_axi_araddr,
		S_AXI_ARPROT	=> pwm_axi_arprot,
		S_AXI_ARVALID	=> pwm_axi_arvalid,
		S_AXI_ARREADY	=> pwm_axi_arready,
		S_AXI_RDATA	=> pwm_axi_rdata,
		S_AXI_RRESP	=> pwm_axi_rresp,
		S_AXI_RVALID	=> pwm_axi_rvalid,
		S_AXI_RREADY	=> pwm_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
