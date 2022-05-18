library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rom_128x8_sync is
  port     (clock    : in  std_logic;
            address  : in  std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync is


  -- Constants for Instruction Pnemonics
  constant LDA_IMM  : std_logic_vector (7 downto 0) := x"86";   -- Load Register A with Immediate Addressing
  constant LDA_DIR  : std_logic_vector (7 downto 0) := x"87";   -- Load Register A with Direct Addressing
  constant LDB_IMM  : std_logic_vector (7 downto 0) := x"88";   -- Load Register B with Immediate Addressing
  constant LDB_DIR  : std_logic_vector (7 downto 0) := x"89";   -- Load Register B with Direct Addressing
  constant STA_DIR  : std_logic_vector (7 downto 0) := x"96";   -- Store Register A to memory (RAM or IO)
  constant STB_DIR  : std_logic_vector (7 downto 0) := x"97";   -- Store Register B to memory (RAM or IO)
  constant ADD_AB   : std_logic_vector (7 downto 0) := x"42";   -- A <= A + B
  constant SUB_AB   : std_logic_vector (7 downto 0) := x"43";   -- A <= A - B
  constant AND_AB   : std_logic_vector (7 downto 0) := x"44";   -- A <= A and B
  constant OR_AB    : std_logic_vector (7 downto 0) := x"45";   -- A <= A or B
  constant INCA     : std_logic_vector (7 downto 0) := x"46";   -- A <= A + 1
  constant INCB     : std_logic_vector (7 downto 0) := x"47";   -- B <= B + 1
  constant DECA     : std_logic_vector (7 downto 0) := x"48";   -- A <= A - 1
  constant DECB     : std_logic_vector (7 downto 0) := x"49";   -- B <= B - 1
  constant BRA      : std_logic_vector (7 downto 0) := x"20";   -- Branch Always                           
  constant BMI      : std_logic_vector (7 downto 0) := x"21";   -- Branch if N=1
  constant BPL      : std_logic_vector (7 downto 0) := x"22";   -- Branch if N=0
  constant BEQ      : std_logic_vector (7 downto 0) := x"23";   -- Branch if Z=1
  constant BNE      : std_logic_vector (7 downto 0) := x"24";   -- Branch if Z=0  
  constant BVS      : std_logic_vector (7 downto 0) := x"25";   -- Branch if V=1
  constant BVC      : std_logic_vector (7 downto 0) := x"26";   -- Branch if V=0  
  constant BCS      : std_logic_vector (7 downto 0) := x"27";   -- Branch if C=1
  constant BCC      : std_logic_vector (7 downto 0) := x"28";   -- Branch if C=0  

  type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

-- Example program: 
  constant ROM : rom_type := (0      => LDB_IMM,
                              1      => x"01",   --Load 0x01 into B
                              2      => LDA_IMM,
                              3      => x"02",   --Load x02 into A 
			      4      => STA_DIR,
                              5      => x"E0",	      
			      6      => SUB_AB, 
                              7      => BNE,    --If we're not at 0, jump to storing A
                              8      => x"04",   
			      9      => BRA,    --otherwise jump to setting A
                              10     => x"02",
                              others => x"00"); 
-- Signal Declaration
  signal EN : std_logic; 

 begin

-- A circuit to create an enable so that this memory is only active for valid addresses (e.g., 0 to 127)
  enable : process (address) 
    begin
      if ( (to_integer(unsigned(address)) >= 0) and (to_integer(unsigned(address)) <= 127)) then
        EN <= '1';
      else 
        EN <= '0';
      end if;
    end process;  

-- Model of the ROM memory   
   memory : process (clock) 
     begin
        if (clock'event and clock='1') then
          if (EN='1') then
            data_out <= ROM(to_integer(unsigned(address)));  
          end if; 
      end if;
   end process;

end architecture;
