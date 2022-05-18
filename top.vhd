library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
	port (Clock_50	: in std_logic;
			Reset		: in std_logic;
			SW 		: in std_logic_vector(9 downto 0);
			LEDR 		: out std_logic_vector(9 downto 0);
			HEX0 		: out std_logic_vector(6 downto 0);
			HEX1 		: out std_logic_vector(6 downto 0);
			HEX2 		: out std_logic_vector(6 downto 0);
			HEX3 		: out std_logic_vector(6 downto 0);
			HEX4 		: out std_logic_vector(6 downto 0);
			HEX5 		: out std_logic_vector(6 downto 0);
			GPIO_1	: out std_logic_vector(15 downto 0);
			KEY		: in	std_logic_vector(3 downto 0));
end entity;




architecture top_arch of top is 	
	signal clock_div		:	std_logic;
	-- Signal Declaration
   signal  port_out_00 : std_logic_vector (7 downto 0);
   signal  port_out_01 : std_logic_vector (7 downto 0);
   signal  port_out_02 : std_logic_vector (7 downto 0);
   signal  port_out_03 : std_logic_vector (7 downto 0);
   signal  port_out_04 : std_logic_vector (7 downto 0);
   signal  port_out_05 : std_logic_vector (7 downto 0);
   signal  port_out_06 : std_logic_vector (7 downto 0);
   signal  port_out_07 : std_logic_vector (7 downto 0);
   signal  port_out_08 : std_logic_vector (7 downto 0);
   signal  port_out_09 : std_logic_vector (7 downto 0);
   signal  port_out_10 : std_logic_vector (7 downto 0);
   signal  port_out_11 : std_logic_vector (7 downto 0);
   signal  port_out_12 : std_logic_vector (7 downto 0);
   signal  port_out_13 : std_logic_vector (7 downto 0);
   signal  port_out_14 : std_logic_vector (7 downto 0);
   signal  port_out_15 : std_logic_vector (7 downto 0);
   signal  port_in_00  : std_logic_vector (7 downto 0);
   signal  port_in_01  : std_logic_vector (7 downto 0);
   signal  port_in_02  : std_logic_vector (7 downto 0);
   signal  port_in_03  : std_logic_vector (7 downto 0);
   signal  port_in_04  : std_logic_vector (7 downto 0);
   signal  port_in_05  : std_logic_vector (7 downto 0);
   signal  port_in_06  : std_logic_vector (7 downto 0);
   signal  port_in_07  : std_logic_vector (7 downto 0);
   signal  port_in_08  : std_logic_vector (7 downto 0);
   signal  port_in_09  : std_logic_vector (7 downto 0);
   signal  port_in_10  : std_logic_vector (7 downto 0);
   signal  port_in_11  : std_logic_vector (7 downto 0);
   signal  port_in_12  : std_logic_vector (7 downto 0);
   signal  port_in_13  : std_logic_vector (7 downto 0);
   signal  port_in_14  : std_logic_vector (7 downto 0);
   signal  port_in_15  : std_logic_vector (7 downto 0);
	

	component clock_div_prec
		port (Clock_In 	: in std_logic;
				Reset 		: in std_logic;
				Sel			: in std_logic_vector(1 downto 0);
				Clock_Out	: out std_logic);	
	end component;
	
	component char_decoder
		port (BIN_IN : in std_logic_vector (3 downto 0);
				HEX_OUT : out std_logic_vector (6 downto 0));	
	end component;
	
	component computer
		port  (clock          : in   std_logic;
             reset          : in   std_logic;
             port_in_00     : in   std_logic_vector (7 downto 0);
             port_in_01     : in   std_logic_vector (7 downto 0);
             port_in_02     : in   std_logic_vector (7 downto 0);
             port_in_03     : in   std_logic_vector (7 downto 0);
             port_in_04     : in   std_logic_vector (7 downto 0);
             port_in_05     : in   std_logic_vector (7 downto 0);
             port_in_06     : in   std_logic_vector (7 downto 0);               
             port_in_07     : in   std_logic_vector (7 downto 0);
             port_in_08     : in   std_logic_vector (7 downto 0);
             port_in_09     : in   std_logic_vector (7 downto 0);
             port_in_10     : in   std_logic_vector (7 downto 0);
             port_in_11     : in   std_logic_vector (7 downto 0);
             port_in_12     : in   std_logic_vector (7 downto 0);
             port_in_13     : in   std_logic_vector (7 downto 0);
             port_in_14     : in   std_logic_vector (7 downto 0);
             port_in_15     : in   std_logic_vector (7 downto 0);                                                                   
             port_out_00    : out  std_logic_vector (7 downto 0);
             port_out_01    : out  std_logic_vector (7 downto 0);
             port_out_02    : out  std_logic_vector (7 downto 0);
             port_out_03    : out  std_logic_vector (7 downto 0);
             port_out_04    : out  std_logic_vector (7 downto 0);
             port_out_05    : out  std_logic_vector (7 downto 0);
             port_out_06    : out  std_logic_vector (7 downto 0);
             port_out_07    : out  std_logic_vector (7 downto 0);
             port_out_08    : out  std_logic_vector (7 downto 0);
             port_out_09    : out  std_logic_vector (7 downto 0);
             port_out_10    : out  std_logic_vector (7 downto 0);
             port_out_11    : out  std_logic_vector (7 downto 0);
             port_out_12    : out  std_logic_vector (7 downto 0);
             port_out_13    : out  std_logic_vector (7 downto 0);
             port_out_14    : out  std_logic_vector (7 downto 0);
             port_out_15    : out  std_logic_vector (7 downto 0));
  end component;
	
	begin		
		divider	:	clock_div_prec	port map	(Clock_In => Clock_50, Reset => Reset, Sel => SW(9 downto 8), Clock_Out => clock_div);
		
		pc			: computer port map   (clock        => clock_div,
												  reset        => Reset,
												  port_out_00  => port_out_00,
												  port_out_01  => port_out_01,
												  port_out_02  => port_out_02,
												  port_out_03  => port_out_03,
												  port_out_04  => port_out_04,
												  port_out_05  => port_out_05,
												  port_out_06  => port_out_06,
												  port_out_07  => port_out_07,
												  port_out_08  => port_out_08,
												  port_out_09  => port_out_09,
												  port_out_10  => port_out_10,
												  port_out_11  => port_out_11,
												  port_out_12  => port_out_12,
												  port_out_13  => port_out_13,
												  port_out_14  => port_out_14,
												  port_out_15  => port_out_15,                    
												  port_in_00   => SW(7 downto 0),
												  port_in_01   => "0000" & KEY(3 downto 0),
												  port_in_02   => port_in_02,
												  port_in_03   => port_in_03,
												  port_in_04   => port_in_04,
												  port_in_05   => port_in_05,
												  port_in_06   => port_in_06,
												  port_in_07   => port_in_07,
												  port_in_08   => port_in_08,
												  port_in_09   => port_in_09,
												  port_in_10   => port_in_10,
												  port_in_11   => port_in_11,
												  port_in_12   => port_in_12,
												  port_in_13   => port_in_13,
												  port_in_14   => port_in_14,
												  port_in_15   => port_in_15);
		
		
		C0 : char_decoder port map (BIN_IN => port_out_01(3 downto 0), HEX_OUT => HEX0);
		C1 : char_decoder port map (BIN_IN => port_out_01(7 downto 4), HEX_OUT => HEX1);
		C2 : char_decoder port map (BIN_IN => port_out_02(3 downto 0), HEX_OUT => HEX2);
		C3 : char_decoder port map (BIN_IN => port_out_02(7 downto 4), HEX_OUT => HEX3);
		C4 : char_decoder port map (BIN_IN => port_out_03(3 downto 0), HEX_OUT => HEX4);
		C5 : char_decoder port map (BIN_IN => port_out_03(7 downto 4), HEX_OUT => HEX5);
		
		LEDR(7 downto 0) <= port_out_00;
		GPIO_1(7 downto 0) <= port_out_04;
		GPIO_1(15 downto 8) <= port_out_05;	

		

end architecture;


