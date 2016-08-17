----------------------------------------------------------------------------------
-- Company: Fontys
-- Engineer: Emmily Jansen
-- 
-- Create Date: 11.05.2016 13:02:47
-- Design Name: Encoder read
-- Module Name: Encoder - Functional
-- Project Name: DCS
-- Target Devices: Zybo, Zedboard
-- Tool Versions: Vivado 2015.4.1
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 3.1 Release
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Encoder is
    Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           chan_A : in STD_LOGIC;
           chan_B : in STD_LOGIC;
           chan_nA : in STD_LOGIC;
           chan_nB : in STD_LOGIC;
           Enc_Fail : out STD_LOGIC;
           Pos : out STD_LOGIC_VECTOR (31 downto 0);
           Dir : out STD_LOGIC);
end Encoder;

architecture Functional of Encoder is
signal nrst_state : std_logic;
signal chan_A_prev : std_logic;
signal chan_B_prev : std_logic;
signal Dir_Int : std_logic;
signal Pos_Int : std_logic_vector(31 downto 0);
signal prev_Pos: std_logic_vector(31 downto 0); 

    function sub (in1 : std_logic_vector; in2 : std_logic) return std_logic_vector is
    variable tmp1 : std_logic_vector(31 downto 0); --output
    variable tmp2 : std_logic_vector(32 downto 0); --borrow
    variable xorout :std_logic;
    variable andout :std_logic;
    variable andout2 :std_logic;
    begin
        tmp2(0) := in2;
        for i in in1'LOW to in1'HIGH loop
            xorout := in1(i) xor '0';
            andout2 := not(in1(i)) and '0';
            andout := not(xorout) and tmp2(i);
            tmp1(i) := tmp2(i) xor xorout;
            tmp2(i+1) := andout or andout2;
        end loop;
        return tmp1; 
    end;
    
    function add (in1 : std_logic_vector; in2 : std_logic) return std_logic_vector is
    variable tmp1 : std_logic_vector(31 downto 0); --output
    variable tmp2 : std_logic_vector(32 downto 0); --borrow
    variable xorout :std_logic;
    variable andout :std_logic;
    variable andout2 :std_logic;
    begin
        tmp2(0) := in2;
        for i in in1'LOW to in1'HIGH loop
            xorout := in1(i) xor '0';
            andout2 := in1(i) and '0';
            andout := xorout and tmp2(i);
            tmp1(i) := tmp2(i) xor xorout;
            tmp2(i+1) := andout or andout2;
        end loop;
        return tmp1; 
    end; 

begin
    process (nrst, clk)
    begin
        if  nrst = '1' then
            Pos_Int <=  "00100000000000000000000000000000";
            prev_Pos <= "00100000000000000000000000000000";
            nrst_state <= '1';
        elsif nrst_state = '1' and clk'event and clk = '1' then
            --if (chan_A = '0' and chan_nA = '1') or (chan_A = '1' and chan_nA = '0') then
                --Enc_Fail <= '0';
                if chan_A_prev = '0' and chan_A = '1' then
                    if chan_B = '1' then
                        Pos_int <= sub(Pos_int, '1');
                    elsif chan_B = '0' then
                        Pos_int <= add(Pos_int, '1');
                    end if; 
--              elsif chan_A_prev = '1' and chan_A = '0' then
--                  if chan_B = '0' then
--                      Pos_int <= sub(Pos_int, '1');
--                  elsif chan_B = '1' then
--                      Pos_int <= add(Pos_Int, '1');
--                  end if;
                end if;
           -- elsif (chan_A = '1' and chan_nA = '1') or (chan_A = '0' and chan_nA = '0') then
                --Enc_Fail <= '1';
            --end if;
            
--            if chan_B_prev = '0' and chan_B = '1' then
--                if chan_A = '1' then
--                    Pos_int <= sub(Pos_int, '1');
--                elsif chan_A = '0' then
--                    Pos_int <= add(Pos_int, '1');
--                end if;
--            elsif chan_B_prev = '1' and chan_B = '0' then
--                if chan_A = '0' then
--                    Pos_int <= sub(Pos_int, '1');
--                elsif chan_A = '1' then
--                    Pos_int <= add(Pos_int, '1');
--                end if;
--            end if;
            
            if Pos_int >=   "00111111111111111111111111111111" and Dir_Int = '0' then
                Pos_int <=  "00000000000000000000000000000001";
            elsif Pos_int = "00000000000000000000000000000000" and Dir_Int = '1' then
                Pos_int <=  "00111111111111111111111111111110";
            end if;
            
            if (Pos_int > prev_Pos) then
                Dir_Int <= '0';
            elsif (Pos_int < prev_Pos) then
                Dir_Int <= '1';
            end if;
            
            prev_Pos <= Pos_int;            
            Pos <= Pos_int;
            Dir <= Dir_Int;
            chan_A_prev <= chan_A;
            chan_B_prev <= chan_B;
        end if;
    end process;
 end Functional;
