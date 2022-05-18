library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_div_2ton is
	port(	Clock_In	:	in		std_logic;
			Reset		: 	in		std_logic;
			Sel		:	in		std_logic_vector(1 downto 0);
			Clock_Out:	out	std_logic);
end entity;


architecture clock_div_2ton_arch of clock_div_2ton is
	signal CNT, CNTn		:	std_logic_vector(37 downto 0);
	
	component Dflipflop
		port (Clock : in std_logic;
				Reset : in std_logic;
				D		: in std_logic;
				Q		: out std_logic;
				Qn		: out std_logic);	
	end component;
	
	begin
		GEN_DFF: for i in 37 downto 0 generate
			if1: if i = 0 generate
				DFF1	:	Dflipflop	port map
				( Clock => Clock_In, Reset => Reset, D => CNTn(i), Q => CNT(i), Qn => CNTn(i));
			end generate if1;
			if2: if i /= 0 generate
				DFF2	:	Dflipflop	port map
				( Clock => CNTn(i - 1), Reset => Reset, D => CNTn(i), Q => CNT(i), Qn => CNTn(i));
			end generate if2; 
		end generate GEN_DFF;
	
		SELECTOR : process (Clock_In, Sel)
			begin
				case (Sel) is
					when "00"	=> Clock_Out <= CNT(1);
					when "01"	=> Clock_Out <= CNT(17);
					when "10"	=> Clock_Out <= CNT(22);
					when "11"	=> Clock_Out <= CNT(24);
				end case;
		end process;
		
end architecture;