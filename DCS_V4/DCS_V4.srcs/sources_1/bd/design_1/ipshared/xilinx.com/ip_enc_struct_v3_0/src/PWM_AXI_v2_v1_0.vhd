library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enc_axi_v2_v1_0 is
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
        Pos : in std_logic_vector(31 downto 0);
        Dir : in std_logic;
        Enc_Fail : in STD_LOGIC;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		enc_axi_aclk	: in std_logic;
		enc_axi_aresetn	: in std_logic;
		enc_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		enc_axi_awprot	: in std_logic_vector(2 downto 0);
		enc_axi_awvalid	: in std_logic;
		enc_axi_awready	: out std_logic;
		enc_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		enc_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		enc_axi_wvalid	: in std_logic;
		enc_axi_wready	: out std_logic;
		enc_axi_bresp	: out std_logic_vector(1 downto 0);
		enc_axi_bvalid	: out std_logic;
		enc_axi_bready	: in std_logic;
		enc_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		enc_axi_arprot	: in std_logic_vector(2 downto 0);
		enc_axi_arvalid	: in std_logic;
		enc_axi_arready	: out std_logic;
		enc_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		enc_axi_rresp	: out std_logic_vector(1 downto 0);
		enc_axi_rvalid	: out std_logic;
		enc_axi_rready	: in std_logic
	);
end enc_axi_v2_v1_0;

architecture arch_imp of enc_axi_v2_v1_0 is

	-- component declaration
	component enc_axi_v2_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		Pos : in std_logic_vector(31 downto 0);
        Dir : in std_logic;
        Enc_Fail : in STD_LOGIC;
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
	end component enc_axi_v2_v1_0_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
enc_axi_v2_v1_0_S00_AXI_inst : enc_axi_v2_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    Pos => Pos,
        Dir => Dir,
        Enc_Fail => Enc_Fail,
		S_AXI_ACLK	=> enc_axi_aclk,
		S_AXI_ARESETN	=> enc_axi_aresetn,
		S_AXI_AWADDR	=> enc_axi_awaddr,
		S_AXI_AWPROT	=> enc_axi_awprot,
		S_AXI_AWVALID	=> enc_axi_awvalid,
		S_AXI_AWREADY	=> enc_axi_awready,
		S_AXI_WDATA	=> enc_axi_wdata,
		S_AXI_WSTRB	=> enc_axi_wstrb,
		S_AXI_WVALID	=> enc_axi_wvalid,
		S_AXI_WREADY	=> enc_axi_wready,
		S_AXI_BRESP	=> enc_axi_bresp,
		S_AXI_BVALID	=> enc_axi_bvalid,
		S_AXI_BREADY	=> enc_axi_bready,
		S_AXI_ARADDR	=> enc_axi_araddr,
		S_AXI_ARPROT	=> enc_axi_arprot,
		S_AXI_ARVALID	=> enc_axi_arvalid,
		S_AXI_ARREADY	=> enc_axi_arready,
		S_AXI_RDATA	=> enc_axi_rdata,
		S_AXI_RRESP	=> enc_axi_rresp,
		S_AXI_RVALID	=> enc_axi_rvalid,
		S_AXI_RREADY	=> enc_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
