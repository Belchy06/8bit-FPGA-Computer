library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity char_decoder is
		port (BIN_IN 	: in std_logic_vector (3 downto 0);
				HEX_OUT 	: out std_logic_vector (6 downto 0));
end entity;

architecture char_decoder_arch of char_decoder is

	begin
		-- Decoder process goes here…
		HEX_OUT 	<=	"1000000" when (BIN_IN="0000") else
					"1111001" when (BIN_IN="0001") else
					"0100100" when (BIN_IN="0010") else
					"0110000" when (BIN_IN="0011") else
					"0011001" when (BIN_IN="0100") else
					"0010010" when (BIN_IN="0101") else
					"0000010" when (BIN_IN="0110") else
					"1111000" when (BIN_IN="0111") else
					"0000000" when (BIN_IN="1000") else
					"0010000" when (BIN_IN="1001") else
					"0001000" when (BIN_IN="1010") else
					"0000011" when (BIN_IN="1011") else
					"0100111" when (BIN_IN="1100") else
					"0100001" when (BIN_IN="1101") else
					"0000110" when (BIN_IN="1110") else
					"0001110" when (BIN_IN="1111");
		
end architecture;