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
  constant RLT	    : std_logic_vector (7 downto 0) := x"29";   -- Rotate A left
  constant RRT	    : std_logic_vector (7 downto 0) := x"30";   -- Rotate A right
  constant SHL	    : std_logic_vector (7 downto 0) := x"31";   -- Shift A left
  constant SHR	    : std_logic_vector (7 downto 0) := x"32";   -- Shift A right
  constant SBC_AB   : std_logic_vector (7 downto 0) := x"33";   -- Subtract with carry

  type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

-- value 0x80
-- mod 0x81
-- divisor 0x82
-- counter 0x83

  constant ROM : rom_type := (  -- Initial values - 200 / 10. 
				0	=> LDA_IMM,
				1	=> x"AB", 	-- Numerator
				2	=> STA_DIR,
				3	=> x"80",
				4	=> LDA_IMM,
				5	=> x"78",	-- Denominator
				6	=> STA_DIR,
				7	=> x"82",
				-- Clear values
				8	=> LDA_IMM,
				9 	=> x"00", 	-- Load 0 into A register
				10	=> LDB_IMM,
				11	=> x"00", 	-- Load 0 into B register
				12	=> SUB_AB,	-- Clear remainder and carry flag
				-- Initialize the remainder to 0
				13	=> LDA_IMM,
				14	=> x"00",
				15	=> STA_DIR,
				16	=> x"81",
				-- Initialize counter to 8
				17	=> LDA_IMM,
				18	=> x"08",
				19	=> STA_DIR,
				20	=> x"83",
				-- Rotate quotient
				-- ROL value
				21	=> LDA_DIR, -- divloop
				22	=> x"80",
				23	=> BCS,
				24	=> x"1C",-- Jump to Carry = 1
				25	=> SHL, -- Carry = 0
				26	=> BRA,
				27	=> x"1E", 
				28	=> SHL, -- Carry = 1
				29	=> INCA,
				30	=> STA_DIR,
				31	=> x"80",
				-- ROL mod
				32	=> LDA_DIR,
				33	=> x"81",
				34	=> BCS,
				35	=> x"27",-- Jump to Carry = 1
				36	=> SHL, -- Carry = 0
				37	=> BRA,
				38	=> x"29", 
				39	=> SHL, -- Carry = 1
				40	=> INCA,
				41	=> STA_DIR,
				42	=> x"81",
				-- SBC
				43 	=> LDA_DIR,
				44	=> x"81",
				45	=> LDB_DIR,
				46	=> x"82",
				47	=> SBC_AB, -- A = dividend (num) - divisor (denom)
				-- Check C
				48	=> BCC,
				49	=> x"45", -- jump to ignore result (0) (num) < (denom)
				50	=> STA_DIR,
				51	=> x"81",
				-- DEX (Carry is 1 so DECA, SEC)
				52	=> LDA_DIR, -- ignore result (1)
				53	=> x"83",
				54	=> DECA,
				55	=> STA_DIR,
				56	=> x"83",
				57	=> BEQ,
				58	=> x"40", 	-- 0 path
				59	=> LDA_IMM, -- 1
				60	=> x"80",
				61	=> SHL,
				62	=> BRA,
				63	=> x"15", -- jump to divloop
				64	=> LDA_IMM, -- 0
				65	=> x"80",
				66	=> SHL,
				67	=> BRA,
				68	=> x"4C", -- jump to output
				-- DEX (Carry is 0, so DECA)
				69	=> LDA_DIR, -- ignore result (0)
				70	=> x"83",
				71	=> DECA,
				72	=> STA_DIR,
				73	=> x"83",
				74	=> BNE,
				75	=> x"15", -- jump to divloop
				-- Output
				76	=> LDA_DIR, -- value holds the answer to the division, but needs to be shifted left one more time
				77	=> x"80",
				78	=> BCS,
				79	=> x"53",-- Jump to Carry = 1
				80	=> SHL, -- Carry = 0
				81	=> BRA,
				82	=> x"55", 
				83	=> SHL, -- Carry = 1
				84	=> INCA,
				85	=> STA_DIR, -- Storing value
				86	=> x"80",
				87	=> STA_DIR,
				88	=> x"E0",
				89	=> LDA_DIR, -- mod holds the remainder
				90	=> x"81",
				91	=> STA_DIR,
				92	=> x"E1",
				-- Halt
				93	=> BRA,
				94	=> x"5D",
                              	others 	=> x"00");
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
