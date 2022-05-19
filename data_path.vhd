library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_path is
      port ( clock       : in  STD_LOGIC;
             reset       : in  STD_LOGIC;
             from_memory : in  STD_LOGIC_VECTOR (7 downto 0);             
             to_memory   : out STD_LOGIC_VECTOR (7 downto 0);
             address     : out STD_LOGIC_VECTOR (7 downto 0);
             IR_Load     : in  STD_LOGIC;
             IR          : out STD_LOGIC_VECTOR (7 downto 0);
             MAR_Load    : in  STD_LOGIC;             
             PC_Load     : in  STD_LOGIC;
             PC_Inc      : in  STD_LOGIC;             
             A_Load      : in  STD_LOGIC;
             B_Load      : in  STD_LOGIC;             
             ALU_Sel     : in  STD_LOGIC_VECTOR (3 downto 0);             
             CCR_Result  : out STD_LOGIC_VECTOR (3 downto 0);
             CCR_Load    : in  STD_LOGIC;             
             Bus1_Sel    : in  STD_LOGIC_VECTOR (1 downto 0);                          
             Bus2_Sel    : in  STD_LOGIC_VECTOR (1 downto 0));                            
end entity;

architecture data_path_arch of data_path is

-- Component Declaration

 component alu is
      port ( A, B        : in  STD_LOGIC_VECTOR (7 downto 0);
             ALU_Sel     : in  STD_LOGIC_VECTOR (3 downto 0);
             Result      : out STD_LOGIC_VECTOR (7 downto 0);
             NZVC        : out STD_LOGIC_VECTOR (3 downto 0) );
 end component;

-- Signal Declaration

 signal Bus1, Bus2 : STD_LOGIC_VECTOR (7 downto 0);
 signal A,B        : STD_LOGIC_VECTOR (7 downto 0);
 signal ALU_Result : STD_LOGIC_VECTOR (7 downto 0);
 signal NZVC       : STD_LOGIC_VECTOR (3 downto 0); 

 signal PC_uns     : UNSIGNED (7 downto 0); 

 signal PC         : STD_LOGIC_VECTOR (7 downto 0);
 signal MAR        : STD_LOGIC_VECTOR (7 downto 0);

 begin

 
---------------------------------------------------
--  Multiplexers
---------------------------------------------------

 MUX_BUS1 : process(Bus1_Sel, PC, A, B)      
   begin
     case (Bus1_Sel) is
       when "00"   => Bus1 <= PC;
       when "01"   => Bus1 <= A;
       when "10"   => Bus1 <= B;
       when others => Bus1 <= x"00";
     end case;
 end process;

 MUX_BUS2 : process(Bus2_Sel, ALU_Result, Bus1, from_memory)
   begin
     case (Bus2_Sel) is
       when "00"   => Bus2 <= ALU_Result;
       when "01"   => Bus2 <= Bus1;
       when "10"   => Bus2 <= from_memory;
       when others => Bus2 <= x"00";
     end case;
 end process;

---------------------------------------------------
--  Concurrent Signal Assignments
---------------------------------------------------

  to_memory <= Bus1;

  address <= MAR;

--------------------------------------------------
--  Registers
--------------------------------------------------

 INSTRUCTION_REGISTER : process(Clock, Reset)    
  begin
   if (Reset = '0') then
     IR <= x"00";
   elsif (Clock'event and Clock = '1') then
      if (IR_Load = '1') then
        IR <= Bus2;
      end if;
   end if;
  end process;

 MEMORY_ADDRESS_REGISTER : process(Clock, Reset) 
  begin
   if (Reset = '0') then
     MAR <= x"00";
   elsif (Clock'event and Clock = '1') then
      if (MAR_Load = '1') then
        MAR <= Bus2;
      end if;
   end if;
  end process;

 PROGRAM_COUNTER : process(Clock, Reset)       
  begin
   if (Reset = '0') then
     PC_uns <= x"00";
   elsif (Clock'event and Clock = '1') then
      if (PC_Load = '1') then
        PC_uns <= unsigned(Bus2);
      elsif (PC_Inc = '1') then
        PC_uns <= PC_uns + 1;       
      end if;
   end if;
  end process;

  PC <= std_logic_vector(PC_uns);


 A_REGISTER : process(Clock, Reset)
  begin
   if (Reset = '0') then
     A <= x"00";
   elsif (Clock'event and Clock = '1') then
      if (A_Load = '1') then
        A <= Bus2;
      end if;
   end if;
  end process;
 
 B_REGISTER : process(Clock, Reset)
  begin
   if (Reset = '0') then
     B <= x"00";
   elsif (Clock'event and Clock = '1') then
      if (B_Load = '1') then
        B <= Bus2;
      end if;
   end if;
  end process; 

--------------------------------------------------
--  ALU
--------------------------------------------------

-- Component Instantiations

  ALU_1 : alu port map (A       => B,
                        B       => Bus1,
                        ALU_Sel => ALU_Sel,
                        Result  => ALU_Result,
                        NZVC    => NZVC);

--------------------------------------------------
--  CONDITION CODE REGISTER
-------------------------------------------------- 
 
 CONDITION_CODE_REGISTER : process(Clock, Reset)    
  begin
   if (Reset = '0') then
     CCR_Result <= x"0";
   elsif (Clock'event and Clock = '1') then
      if (CCR_Load = '1') then
        CCR_Result <= NZVC;
      end if;
   end if;
  end process;


end architecture;