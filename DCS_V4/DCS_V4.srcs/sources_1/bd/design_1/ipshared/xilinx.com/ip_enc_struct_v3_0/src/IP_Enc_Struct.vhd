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

entity IP_ENC_Struct is
	generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH    : integer    := 32;
    C_S00_AXI_ADDR_WIDTH    : integer    := 4
    );
	port (
    -- Ports of Axi Slave Bus Interface enc_axi
    chan_A : in STD_LOGIC;
    chan_B : in STD_LOGIC;
    chan_nA : in STD_LOGIC;
    chan_nB : in STD_LOGIC;
    clk : in std_logic;
    nrst : in std_logic;
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
end IP_ENC_Struct;

architecture Structural of IP_ENC_Struct is
    component ENC_AXI_v2_v1_0 is
    generic (
        C_S00_AXI_DATA_WIDTH    : integer    := 32;
        C_S00_AXI_ADDR_WIDTH    : integer    := 4
    );
    port (
        Pos : in std_logic_vector(31 downto 0);
        Dir : in std_logic;
        Enc_Fail : in STD_LOGIC;
        enc_axi_aclk    : in std_logic;
        enc_axi_aresetn    : in std_logic;
        enc_axi_awaddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        enc_axi_awprot    : in std_logic_vector(2 downto 0);
        enc_axi_awvalid    : in std_logic;
        enc_axi_awready    : out std_logic;
        enc_axi_wdata    : in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        enc_axi_wstrb    : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
        enc_axi_wvalid    : in std_logic;
        enc_axi_wready    : out std_logic;
        enc_axi_bresp    : out std_logic_vector(1 downto 0);
        enc_axi_bvalid    : out std_logic;
        enc_axi_bready    : in std_logic;
        enc_axi_araddr    : in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
        enc_axi_arprot    : in std_logic_vector(2 downto 0);
        enc_axi_arvalid    : in std_logic;
        enc_axi_arready    : out std_logic;
        enc_axi_rdata    : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
        enc_axi_rresp    : out std_logic_vector(1 downto 0);
        enc_axi_rvalid    : out std_logic;
        enc_axi_rready    : in std_logic
    );
    end component;
    
    component Encoder is
    Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           chan_A : in STD_LOGIC;
           chan_B : in STD_LOGIC;
           chan_nA : in STD_LOGIC;
           chan_nB : in STD_LOGIC;
           Enc_Fail : out STD_LOGIC;
           Pos : out STD_LOGIC_VECTOR (31 downto 0);
           Dir : out STD_LOGIC);
    end component;
    
    signal int_pos : std_logic_vector(31 downto 0);
    signal int_dir : std_logic;
    signal int_enc_fail : std_logic;
begin
    ENC_AXI_IP : ENC_AXI_v2_v1_0
	generic map (
		C_S00_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S00_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    Pos => int_pos,
	    Dir => int_dir,
	    Enc_Fail => int_enc_fail,
		enc_axi_aclk => s00_axi_aclk,
		enc_axi_aresetn => s00_axi_aresetn,
		enc_axi_awaddr => s00_axi_awaddr,
		enc_axi_awprot => s00_axi_awprot,
		enc_axi_awvalid=> s00_axi_awvalid,
		enc_axi_awready => s00_axi_awready,
		enc_axi_wdata => s00_axi_wdata,
		enc_axi_wstrb => s00_axi_wstrb,
		enc_axi_wvalid => s00_axi_wvalid,
		enc_axi_wready => s00_axi_wready,
		enc_axi_bresp => s00_axi_bresp,
		enc_axi_bvalid => s00_axi_bvalid,
		enc_axi_bready => s00_axi_bready,
		enc_axi_araddr => s00_axi_araddr,
		enc_axi_arprot => s00_axi_arprot,
		enc_axi_arvalid => s00_axi_arvalid,
		enc_axi_arready => s00_axi_arready,
		enc_axi_rdata => s00_axi_rdata,
		enc_axi_rresp => s00_axi_rresp,
		enc_axi_rvalid => s00_axi_rvalid,
		enc_axi_rready => s00_axi_rready
	);
	
	Encoder_2 : Encoder
    port map (
        clk => clk,
        nrst => nrst,
        chan_A => chan_A,
        chan_B => chan_B,
        chan_nA => chan_nA,
        chan_nB => chan_nB,
        Enc_Fail => int_enc_fail,
        Pos => int_pos,
        Dir => int_dir
    );
end Structural;
