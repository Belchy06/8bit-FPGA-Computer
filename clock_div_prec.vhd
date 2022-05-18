library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_prec is
	port (Clock_in : in std_logic;
			Reset : in std_logic;
			Sel : in std_logic_vector (1 downto 0);
			Clock_out : out std_logic);
end entity;

architecture clock_div_prec_arch of clock_div_prec is
	signal MaxValue :	integer;
	signal Counter	:	integer;
	signal DividedClock	:	std_logic;
	
	begin
		CLOCK : process(Clock_in, Reset)
			begin
				if(Reset='0') then
					DividedClock <= '0';
				elsif(Clock_in'event and Clock_in='1') then
					if(Counter>=MaxValue) then
						DividedClock <= not DividedClock;
						Counter <= 0;
					else
						Counter <= Counter + 1;
					end if;
				end if;
				
		end process;
		
		SELECTOR : process(Sel)
			begin
					case (Sel) is
						when "00"	=> MaxValue <= 25000;
						when "01"	=> MaxValue <= 250000;
						when "10"	=> MaxValue <= 2500000;
						when "11"	=> MaxValue <= 25000000;
					end case; 
		end process;
		
		Clock_out <= DividedClock;
end architecture;

