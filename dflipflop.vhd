library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Dflipflop is
	port(	Clock	: in 	std_logic;
			Reset	: in	std_logic;
			D		: in	Std_logic;
			Q, Qn	: out	std_logic);
end entity;

architecture Dflipflop_arch of Dflipflop is
	begin
		Dflipflop_process	:	process(Clock, Reset)
			begin
				if (Reset = '0') then
					Q <= '0'; Qn <= '1';
				elsif (Clock'event and Clock='1') then
					Q <= D; Qn <= not D;
				end if;
		end process;
end architecture;