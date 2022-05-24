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
  constant OR_AZ	    : std_logic_vector (7 downto 0) := x"29";   -- A <= A or 0
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
  constant SEC	    : std_logic_vector (7 downto 0) := x"34";	-- Set Carry
  constant CLC	    : std_logic_vector (7 downto 0) := x"35";	-- Clear Carry
  constant SHLI	    : std_logic_vector (7 downto 0) := x"36";   -- Shift left + increment

  type rom_type is array (0 to 127) of std_logic_vector(7 downto 0);

-- value 0x80
-- mod 0x81
-- divisor 0x82
-- counter 0x83
-- output counter 0x84

-- 3 outputs
-- 0xE0 (store in here first)
-- 0xE1
-- 0xE2

  constant ROM : rom_type := (  -- Initial values - 255 / 10. 
				0	=> LDA_DIR,
				1	=> x"F0", 	-- Numerator
				2	=> STA_DIR,
				3	=> x"80",
				4	=> LDA_IMM,
				5	=> x"0A",	-- Denominator (10)
				6	=> STA_DIR,
				7	=> x"82",
				8	=> LDA_IMM,
				9	=> x"00",	-- Initialize output counter to 0
				10	=> STA_DIR,
				11	=> x"84",
				-- Initialize the remainder to 0
				12	=> LDA_IMM, -- :divide
				13	=> x"00",
				14	=> STA_DIR,
				15	=> x"81",
				-- Initialize counter to 8
				16	=> LDA_IMM,
				17	=> x"08",
				18	=> STA_DIR,
				19	=> x"83",
				-- Rotate quotient
				-- ROL value
				20	=> LDA_DIR, -- divloop
				21	=> x"80",
				22	=> BCS,
				23	=> x"1B",-- Jump to Carry = 1
				24	=> SHL, -- Carry = 0
				25	=> BRA,
				26	=> x"1C", 
				27	=> SHLI, -- Carry = 1
				28	=> STA_DIR,
				29	=> x"80",
				-- ROL mod
				30	=> LDA_DIR,
				31	=> x"81",
				32	=> BCS,
				33	=> x"25",-- Jump to Carry = 1
				34	=> SHL, -- Carry = 0
				35	=> BRA,
				36	=> x"26", 
				37	=> SHLI, -- Carry = 1
				38	=> STA_DIR,
				39	=> x"81",
				-- SBC
				40 => LDA_DIR,
				41	=> x"81",
				42	=> LDB_DIR,
				43	=> x"82",
				44	=> SBC_AB, -- A = dividend (num) - divisor (denom)
				-- Check C
				45	=> BCC,
				46	=> x"3E", -- jump to ignore result (0) (num) < (denom)
				47	=> STA_DIR,
				48	=> x"81",
				-- DEX (Carry is 1 so DECA, SEC)
				49	=> LDA_DIR, -- ignore result (1)
				50	=> x"83",
				51	=> DECA,
				52	=> STA_DIR,
				53	=> x"83",
				54	=> BEQ,
				55	=> x"3B", 	-- 0 path
				56	=> SEC,	    	-- 1
				57	=> BRA,
				58	=> x"14", -- jump to divloop
				59	=> SEC,		-- 0
				60	=> BRA,
				61	=> x"45", -- jump to output
				-- DEX (Carry is 0, so DECA)
				62	=> LDA_DIR, -- ignore result (0)
				63	=> x"83",
				64	=> DECA,
				65	=> STA_DIR,
				66	=> x"83",
				67	=> BNE,
				68	=> x"14", -- jump to divloop
				-- Output
				69	=> LDA_DIR, -- value holds the answer to the division, but needs to be shifted left one more time
				70	=> x"80",
				71	=> BCS,
				72	=> x"4C",-- Jump to Carry = 1
				73	=> SHL, -- Carry = 0
				74	=> BRA,
				75	=> x"4D", 
				76	=> SHLI, -- Carry = 1
				77	=> STA_DIR, -- Storing value
				78	=> x"80",
				-- Depending on current output counter is where we output the value
				-- Store mod in output
				-- Check index == 0
				79	=> LDA_DIR,
				80	=> x"84",
				81	=> OR_AZ,
				82	=> BNE,		-- Branch if current index =/= 0
				83	=> x"65",	-- Jump to "check index == 1"
				-- index == 0
				84	=> LDA_DIR,
				85	=> x"81",
				86	=> STA_DIR,
				87	=> x"E1",
				88	=> LDA_IMM,
				89	=> x"00",
				90	=> STA_DIR,
				91	=> x"E2",
				92	=> STA_DIR,
				93	=> x"E3",				
				94	=> LDA_DIR,
				95	=> x"84",
				96	=> INCA,
				97	=> STA_DIR,
				98 => x"84",
				99 => BRA,
				100 => x"79", 	--Branch to check for :divide
				-- check index == 1
				101 => LDA_DIR,
				102 => x"84",
				103 => DECA,
				104 => BNE,		-- Branch if current index =/= 1
				105 => x"75",	-- Jump to "else index == 2"
				-- index == 1
				106	=> LDA_DIR,
				107	=> x"81",
				108	=> STA_DIR,
				109	=> x"E2",
				110	=> LDA_DIR,
				111	=> x"84",
				112	=> INCA,
				113	=> STA_DIR,
				114	=> x"84",
				115	=> BRA,
				116	=> x"79",	-- Branch to check for :divide
				-- else index == 2
				117	=> LDA_DIR,
				118	=> x"81",
				119	=> STA_DIR,
				120	=> x"E3",
				-- Check for :divide	
				121	=> LDA_DIR, 
				122	=> x"80",
				123	=> OR_AZ,
				124	=> BNE,
				125	=> x"0C",	-- Jump to :divide
				-- Halt (User must press reset to do a new number)
				126	=> BRA,
				127	=> x"7E",
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
