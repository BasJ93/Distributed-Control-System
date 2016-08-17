----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2016 11:14:29
-- Design Name: 
-- Module Name: PWM - Functional
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PWM is
    Port ( clk : in STD_LOGIC;
           nrst : in STD_LOGIC;
           freq : in STD_LOGIC_VECTOR (31 downto 0);
           width : in STD_LOGIC_VECTOR (31 downto 0);
           pulse_out : out STD_LOGIC);
end PWM;

architecture Functional of PWM is
signal freq_int : integer := 8192;
signal width_int : integer := -1;
signal counter : integer := -1;
signal counter2 : integer := -1;

   Function bin2int(word : in Std_Logic_vector) return integer is
      Variable result : integer;
      Begin                                          
         result := 0;
         FOR i in word'range LOOP
            IF word(i) = '1' THEN
               result := result + 2**i;
            ELSIF word(i) /= '0' THEN
               result := -1;
               EXIT;
            END IF;
         END LOOP;
         Return result;
    END bin2int;

begin

    process (clk, nrst)
    begin
        if nrst = '0' then
            counter <= 0;
            --counter2 <= 0;
        elsif clk'event and clk = '1' and nrst = '1' then
            counter <= (counter + 1) rem freq_int;
            --counter2 <= counter rem width_int;
            if counter = 0 then
                pulse_out <= '1';
            end if;
            if counter = (width_int) then
                pulse_out <= '0';
            end if;
        end if;
        freq_int <= bin2int(freq);
        width_int <= bin2int(width);
    end process;
end Functional;
