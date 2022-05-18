library IEEE;
use IEEE.std_logic_1164.all;

entity control_unit is
      port ( clock     : in  STD_LOGIC;
             reset     : in  STD_LOGIC;
             write     : out STD_LOGIC;
             IR_Load   : out STD_LOGIC;
             IR        : in  STD_LOGIC_VECTOR (7 downto 0);
             MAR_Load  : out STD_LOGIC;             
             PC_Load   : out STD_LOGIC;
             PC_Inc    : out STD_LOGIC;             
             A_Load    : out STD_LOGIC;
             B_Load    : out STD_LOGIC;             
             ALU_Sel   : out STD_LOGIC_VECTOR (2 downto 0);             
             CCR_Result: in  STD_LOGIC_VECTOR (3 downto 0);
             CCR_Load  : out STD_LOGIC;             
             Bus1_Sel  : out STD_LOGIC_VECTOR (1 downto 0);                          
             Bus2_Sel  : out STD_LOGIC_VECTOR (1 downto 0));    
end entity;

architecture control_unit_arch of control_unit is

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


  type state_type is (S_FETCH_0,              -- Opcode fetch states
                      S_FETCH_1,
                      S_FETCH_2,

                      S_DECODE_3,             -- Opcode decode state

                      S_LDA_IMM_4,            -- Load A (Immediate) states
                      S_LDA_IMM_5,
                      S_LDA_IMM_6,

-- Above is the states for LDA_IMM. 
-- Below are the states you may need for your instructions.

                      S_LDA_DIR_4,            -- Load A (Direct) states
                      S_LDA_DIR_5,
                      S_LDA_DIR_6,
                      S_LDA_DIR_7,
                      S_LDA_DIR_8,                      
                    
                      S_STA_DIR_4,            -- Store A (Direct) States
                      S_STA_DIR_5,
                      S_STA_DIR_6,
                      S_STA_DIR_7,
                      
                      S_LDB_IMM_4,            -- Load B (Immediate) states
                      S_LDB_IMM_5,
                      S_LDB_IMM_6,

                      S_LDB_DIR_4,            -- Load B (Direct) states
                      S_LDB_DIR_5,
                      S_LDB_DIR_6,
                      S_LDB_DIR_7,
		      S_LDB_DIR_8,
                    
                      S_STB_DIR_4,            -- Store B (Direct) States
                      S_STB_DIR_5,
                      S_STB_DIR_6,
                      S_STB_DIR_7,
                      
                      S_ADD_AB_4,             -- Data Manipulations
                      S_SUB_AB_4,
                      S_AND_AB_4,
                      S_OR_AB_4,
                      S_INC_A_4,
                      S_INC_B_4,
                      S_DEC_A_4,
                      S_DEC_B_4,


                    
                      S_BRA_4,                -- Branch States
                      S_BRA_5,
                      S_BRA_6,
                      
                      S_BEQ_4,                -- BRanch Equal States
                      S_BEQ_5,
                      S_BEQ_6,
                      S_BEQ_7,

                      S_BNE_4,                -- Branch Not Equal States
                      S_BNE_5,
                      S_BNE_6,
                      S_BNE_7,

                      S_BMI_4,                -- Branch if MInus
                      S_BMI_5,
                      S_BMI_6,
                      S_BMI_7,

                      S_BPL_4,                -- Branch if PLus
                      S_BPL_5,
                      S_BPL_6,
                      S_BPL_7,

                      S_BVS_4,                -- Branch oVerflow Set
                      S_BVS_5,
                      S_BVS_6,
                      S_BVS_7,

                      S_BVC_4,                -- Branch oVerflow Clear
                      S_BVC_5,
                      S_BVC_6,
                      S_BVC_7,

                      S_BCS_4,                -- Branch Carry Set
                      S_BCS_5,
                      S_BCS_6,
                      S_BCS_7,

                      S_BCC_4,                -- Branch Carry Clear
                      S_BCC_5,
                      S_BCC_6,
                      S_BCC_7);

  signal current_state, next_state : state_type;

 begin

------------------------------------------------------------------------------------
-- STATE MEMORY
------------------------------------------------------------------------------------
  STATE_MEMORY : process(Clock, Reset)      
    begin
      if (Reset = '0') then
        current_state <= S_FETCH_0;
      elsif (clock'event and clock = '1') then
        current_state <= next_state;
      end if;
    end process;

------------------------------------------------------------------------------------
-- NEXT STATE LOGIC
------------------------------------------------------------------------------------
  NEXT_STATE_LOGIC : process(current_state, IR, CCR_Result)
    begin
      if (current_state = S_FETCH_0) then 
        next_state <= S_FETCH_1;
      elsif (current_state = S_FETCH_1) then 
        next_state <= S_FETCH_2;
      elsif (current_state = S_FETCH_2) then 
        next_state <= S_DECODE_3;
      elsif (current_state = S_DECODE_3) then 
          -- here is where the different paths in the FSM are decided
          if (IR = LDA_IMM) then        
            next_state <= S_LDA_IMM_4;  -- Load A Immediate
          elsif (IR = LDA_DIR) then
            next_state <= S_LDA_DIR_4;  -- Load A Direct
          elsif (IR = STA_DIR) then
            next_state <= S_STA_DIR_4;  -- Store A Direct
            
          elsif (IR = LDB_IMM) then                     
            next_state <= S_LDB_IMM_4;  --  Register B
          elsif (IR = LDB_DIR) then
            next_state <= S_LDB_DIR_4;
          elsif (IR = STB_DIR) then
            next_state <= S_STB_DIR_4;
            
          elsif (IR = ADD_AB) then      -- Add A and B
            next_state <= S_ADD_AB_4; 

          elsif (IR = SUB_AB) then      -- Sub A and B
            next_state <= S_SUB_AB_4;   

          elsif (IR = AND_AB) then      -- Bitwise AND A and B
            next_state <= S_AND_AB_4;

          elsif (IR = OR_AB) then      -- Bitwise OR A and B
            next_state <= S_OR_AB_4; 

          elsif (IR = INCA) then      -- Increment A
            next_state <= S_INC_A_4;  

          elsif (IR = INCB) then      -- Increment B
            next_state <= S_INC_B_4;  

          elsif (IR = DECA) then      -- Decrement A
            next_state <= S_DEC_A_4;  

          elsif (IR = DECB) then      -- Decrement B
            next_state <= S_DEC_B_4;            

          elsif (IR = BRA) then         -- Branches
            next_state <= S_BRA_4;

-- N
          elsif (IR = BEQ and CCR_Result(3) = '1') then         -- BMI (We do jump) N=1
            next_state <= S_BMI_4;
          elsif (IR = BEQ and CCR_Result(3) = '0') then         -- BMI (We don't jump) N=0
            next_state <= S_BMI_7;

          elsif (IR = BNE and CCR_Result(3) = '1') then         -- BPL (We don't jump) N=1
            next_state <= S_BPL_7;
          elsif (IR = BNE and CCR_Result(3) = '0') then         -- BPL (We do jump) N=0
            next_state <= S_BPL_4;
-- Z
          elsif (IR = BEQ and CCR_Result(2) = '1') then         -- BEQ (We do jump) Z=1
            next_state <= S_BEQ_4;
          elsif (IR = BEQ and CCR_Result(2) = '0') then         -- BEQ (We don't jump) Z=0
            next_state <= S_BEQ_7;

          elsif (IR = BNE and CCR_Result(2) = '1') then         -- BNE (We don't jump) Z=1
            next_state <= S_BNE_7;
          elsif (IR = BNE and CCR_Result(2) = '0') then         -- BNE (We do jump) Z=0
            next_state <= S_BNE_4;
-- V
          elsif (IR = BEQ and CCR_Result(1) = '1') then         -- BVS (We do jump) N=1
            next_state <= S_BVS_4;
          elsif (IR = BEQ and CCR_Result(1) = '0') then         -- BVS (We don't jump) N=0
            next_state <= S_BVS_7;

          elsif (IR = BNE and CCR_Result(1) = '1') then         -- BVC (We don't jump) V=1
            next_state <= S_BVC_7;
          elsif (IR = BNE and CCR_Result(1) = '0') then         -- BVC (We do jump) V=0
            next_state <= S_BVC_4; 
-- C
          elsif (IR = BEQ and CCR_Result(0) = '1') then         -- BCS (We do jump) C=1
            next_state <= S_BCS_4;
          elsif (IR = BEQ and CCR_Result(0) = '0') then         -- BCS (We don't jump) C=0
            next_state <= S_BCS_7;

          elsif (IR = BNE and CCR_Result(0) = '1') then         -- BCC (We don't jump) C=1
            next_state <= S_BCC_7;
          elsif (IR = BNE and CCR_Result(0) = '0') then         -- BCC (We do jump) C=0
            next_state <= S_BCC_4; 

            
 	  else next_state <= S_FETCH_0; 
          end if;

      elsif (current_state = S_LDA_IMM_4) then     -- Path for LDA_IMM instruction
        next_state <= S_LDA_IMM_5;
      elsif (current_state = S_LDA_IMM_5) then 
        next_state <= S_LDA_IMM_6;
      elsif (current_state = S_LDA_IMM_6) then 
        next_state <= S_FETCH_0;

      elsif (current_state = S_LDA_DIR_4) then     -- Path for LDA_DIR instruction
	next_state <= S_LDA_DIR_5;
      elsif (current_state = S_LDA_DIR_5) then
	next_state <= S_LDA_DIR_6;
      elsif (current_state = S_LDA_DIR_6) then
	next_state <= S_LDA_DIR_7;
      elsif (current_state = S_LDA_DIR_7) then
	next_state <= S_LDA_DIR_8;
      elsif (current_state = S_LDA_DIR_8) then
	next_state <= S_FETCH_0;

      elsif (current_state = S_STA_DIR_4) then     -- Path for STA_DIR instruction
	next_state <= S_STA_DIR_5;
      elsif (current_state = S_STA_DIR_5) then
	next_state <= S_STA_DIR_6;
      elsif (current_state = S_STA_DIR_6) then
	next_state <= S_STA_DIR_7;
      elsif (current_state = S_STA_DIR_7) then
	next_state <= S_FETCH_0;

      elsif (current_state = S_BRA_4) then     -- Path for BRA instruction
	next_state <= S_BRA_5;
      elsif (current_state = S_BRA_5) then
	next_state <= S_BRA_6;
      elsif (current_state = S_BRA_6) then
	next_state <= S_FETCH_0;

      elsif (current_state = S_LDB_IMM_4) then     -- Path for LDB_IMM instruction
        next_state <= S_LDB_IMM_5;
      elsif (current_state = S_LDB_IMM_5) then 
        next_state <= S_LDB_IMM_6;
      elsif (current_state = S_LDB_IMM_6) then 
        next_state <= S_FETCH_0;

      elsif (current_state = S_LDB_DIR_4) then     -- Path for LDB_DIR instruction
	next_state <= S_LDB_DIR_5;
      elsif (current_state = S_LDB_DIR_5) then
	next_state <= S_LDB_DIR_6;
      elsif (current_state = S_LDB_DIR_6) then
	next_state <= S_LDB_DIR_7;
      elsif (current_state = S_LDB_DIR_7) then
	next_state <= S_LDB_DIR_8;
      elsif (current_state = S_LDB_DIR_8) then
	next_state <= S_FETCH_0;

      elsif (current_state = S_STB_DIR_4) then     -- Path for STB_DIR instruction
	next_state <= S_STB_DIR_5;
      elsif (current_state = S_STB_DIR_5) then
	next_state <= S_STB_DIR_6;
      elsif (current_state = S_STB_DIR_6) then
	next_state <= S_STB_DIR_7;
      elsif (current_state = S_STB_DIR_7) then
	next_state <= S_FETCH_0;

      elsif (current_state = S_ADD_AB_4) then     -- Path for ADD_AB instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_SUB_AB_4) then     -- Path for SUB_AB instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_AND_AB_4) then     -- Path for AND_AB instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_OR_AB_4) then     -- Path for OR_AB instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_INC_A_4) then     -- Path for INCA instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_INC_B_4) then     -- Path for INCB instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_DEC_A_4) then     -- Path for DECA instruction
	next_state <= S_FETCH_0;

      elsif (current_state = S_DEC_B_4) then     -- Path for DECB instruction
	next_state <= S_FETCH_0;
-- N
      elsif (current_state = S_BMI_4) then     -- Path for BMI instruction (We do jump)
	next_state <= S_BMI_5;
      elsif (current_state = S_BMI_5) then    
	next_state <= S_BMI_6;      elsif (current_state = S_BMI_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BMI_7) then     -- Path for BMI instruction (We don't jump)
	next_state <= S_FETCH_0;

      elsif (current_state = S_BPL_4) then     -- Path for BPL instruction (We do jump)
	next_state <= S_BPL_5;
      elsif (current_state = S_BPL_5) then    
	next_state <= S_BPL_6;      elsif (current_state = S_BPL_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BPL_7) then     -- Path for BPL instruction (We don't jump)
	next_state <= S_FETCH_0;
-- Z
      elsif (current_state = S_BEQ_4) then     -- Path for BEQ instruction (We do jump)
	next_state <= S_BEQ_5;
      elsif (current_state = S_BEQ_5) then    
	next_state <= S_BEQ_6;      elsif (current_state = S_BEQ_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BEQ_7) then     -- Path for BEQ instruction (We don't jump)
	next_state <= S_FETCH_0;

      elsif (current_state = S_BNE_4) then     -- Path for BNE instruction (We do jump)
	next_state <= S_BNE_5;
      elsif (current_state = S_BNE_5) then    
	next_state <= S_BNE_6;      elsif (current_state = S_BNE_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BNE_7) then     -- Path for BNE instruction (We don't jump)
	next_state <= S_FETCH_0;
-- V
      elsif (current_state = S_BVS_4) then     -- Path for BVS instruction (We do jump)
	next_state <= S_BVS_5;
      elsif (current_state = S_BVS_5) then    
	next_state <= S_BVS_6;      elsif (current_state = S_BVS_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BVS_7) then     -- Path for BVS instruction (We don't jump)
	next_state <= S_FETCH_0;

      elsif (current_state = S_BVC_4) then     -- Path for BVC instruction (We do jump)
	next_state <= S_BVC_5;
      elsif (current_state = S_BVC_5) then    
	next_state <= S_BVC_6;      elsif (current_state = S_BVC_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BVC_7) then     -- Path for BVC instruction (We don't jump)
	next_state <= S_FETCH_0;
-- C
      elsif (current_state = S_BCS_4) then     -- Path for BCS instruction (We do jump)
	next_state <= S_BCS_5;
      elsif (current_state = S_BCS_5) then    
	next_state <= S_BCS_6;      elsif (current_state = S_BCS_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BCS_7) then     -- Path for BCS instruction (We don't jump)
	next_state <= S_FETCH_0;

      elsif (current_state = S_BCC_4) then     -- Path for BCC instruction (We do jump)
	next_state <= S_BCC_5;
      elsif (current_state = S_BCC_5) then    
	next_state <= S_BCC_6;      elsif (current_state = S_BCC_6) then     
	next_state <= S_FETCH_0;
      elsif (current_state = S_BCC_7) then     -- Path for BCC instruction (We don't jump)
	next_state <= S_FETCH_0;
      end if;
    end process;

------------------------------------------------------------------------------------
-- OUTPUT LOGIC
------------------------------------------------------------------------------------
  OUTPUT_LOGIC : process(current_state)     
    begin
      case(current_state) is
        when S_FETCH_0 =>   -- Put PC onto MAR to provide address of Opcode
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_FETCH_1 =>   -- Increment PC, Opcode will be available next state
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   
                  
        when S_FETCH_2 =>   -- Put Opcode into IR
           IR_Load  <= '1';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   
               
        when S_DECODE_3 =>  -- No outputs, machine is decoding IR to decide which state to go to next
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   
          
      --------------------------------------------------------------------------------------------------
      -- LDA_IMM
      --------------------------------------------------------------------------------------------------      
        when S_LDA_IMM_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';            
          
        when S_LDA_IMM_5 =>  -- Increment PC, Operand will be available next state
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   
          
        when S_LDA_IMM_6 =>  -- Operand is available, latch into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   

      --------------------------------------------------------------------------------------------------
      -- LDA_DIR
      -------------------------------------------------------------------------------------------------- 
        when S_LDA_DIR_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   

        when S_LDA_DIR_5 =>  -- Increment the PC to the next address is program memory
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDA_DIR_6 =>  -- Put the memory address on Bus2 into MAR
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDA_DIR_7 =>  -- Give memory time to update
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDA_DIR_8 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

      --------------------------------------------------------------------------------------------------
      -- STA_DIR
      -------------------------------------------------------------------------------------------------- 
        when S_STA_DIR_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

        when S_STA_DIR_5 =>  -- Increment PC
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0'; 

        when S_STA_DIR_6 =>  -- Put the address on Bus2 into MAR
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0'; 

        when S_STA_DIR_7 =>  -- Write Bus1 to A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '1'; 

      --------------------------------------------------------------------------------------------------
      -- BRA
      --------------------------------------------------------------------------------------------------   
        when S_BRA_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

        when S_BRA_5 =>  -- Increment PC
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0'; 

        when S_BRA_6 =>  -- Put the address on Bus2 into PC
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory  

      --------------------------------------------------------------------------------------------------
      -- LDB_IMM
      --------------------------------------------------------------------------------------------------      
        when S_LDB_IMM_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';            
          
        when S_LDB_IMM_5 =>  -- Increment PC, Operand will be available next state
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   
          
        when S_LDB_IMM_6 =>  -- Operand is available, latch into B
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '1';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   

      --------------------------------------------------------------------------------------------------
      -- LDB_DIR
      -------------------------------------------------------------------------------------------------- 
        when S_LDB_DIR_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';   

        when S_LDB_DIR_5 =>  -- Increment the PC to the next address is program memory
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDB_DIR_6 =>  -- Put the memory address on Bus2 into MAR
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDB_DIR_7 =>  -- Give memory time to update
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

        when S_LDB_DIR_8 =>  -- Operand is available, latch into B
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '1';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

      --------------------------------------------------------------------------------------------------
      -- STB_DIR
      -------------------------------------------------------------------------------------------------- 
        when S_STB_DIR_4 =>  -- Put PC into MAR to provide address of Operand
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

        when S_STB_DIR_5 =>  -- Increment PC
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0'; 

        when S_STB_DIR_6 =>  -- Put the address on Bus2 into MAR
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0'; 

        when S_STB_DIR_7 =>  -- Write Bus1 to B
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "10"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '1'; 


      --------------------------------------------------------------------------------------------------
      -- ADD_AB
      -------------------------------------------------------------------------------------------------- 
        when S_ADD_AB_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- SUB_AB
      -------------------------------------------------------------------------------------------------- 
        when S_SUB_AB_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "001";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- AND_AB
      -------------------------------------------------------------------------------------------------- 
        when S_AND_AB_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "010";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- OR_AB
      -------------------------------------------------------------------------------------------------- 
        when S_OR_AB_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "011";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- INCA
      -------------------------------------------------------------------------------------------------- 
        when S_INC_A_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "100";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- INCB
      -------------------------------------------------------------------------------------------------- 
        when S_INC_B_4 =>  -- Put output from ALU onto bus2 and load into B
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '1';                 
           ALU_Sel  <= "101";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "10"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- DECA
      -------------------------------------------------------------------------------------------------- 
        when S_DEC_A_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '1';            
           B_Load   <= '0';                 
           ALU_Sel  <= "110";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "01"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- DECB
      -------------------------------------------------------------------------------------------------- 
        when S_DEC_B_4 =>  -- Put output from ALU onto bus2 and load into A
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '1';                 
           ALU_Sel  <= "111";                 
           CCR_Load <= '1';                      
           Bus1_Sel <= "10"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory           write    <= '0'; 

      --------------------------------------------------------------------------------------------------
      -- BEQ
      --------------------------------------------------------------------------------------------------                
        when S_BEQ_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BEQ_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BEQ_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BEQ_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';


      --------------------------------------------------------------------------------------------------
      -- BNE
      --------------------------------------------------------------------------------------------------                
        when S_BNE_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BNE_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BNE_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BNE_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';


      --------------------------------------------------------------------------------------------------
      -- BMI
      --------------------------------------------------------------------------------------------------                
        when S_BMI_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BMI_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BMI_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BMI_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';


      --------------------------------------------------------------------------------------------------
      -- BPL
      --------------------------------------------------------------------------------------------------                
        when S_BPL_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BPL_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BPL_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BPL_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

     --------------------------------------------------------------------------------------------------
      -- BVS
      --------------------------------------------------------------------------------------------------                
        when S_BVS_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVS_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVS_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVS_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

     --------------------------------------------------------------------------------------------------
      -- BVC
      --------------------------------------------------------------------------------------------------                
        when S_BVC_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVC_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVC_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BVC_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

     --------------------------------------------------------------------------------------------------
      -- BCS
      --------------------------------------------------------------------------------------------------                
        when S_BCS_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCS_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCS_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCS_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

     --------------------------------------------------------------------------------------------------
      -- BCC
      --------------------------------------------------------------------------------------------------                
        when S_BCC_4 => 
           IR_Load  <= '0';         
           MAR_Load <= '1';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "01"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCC_5 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCC_6 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '1';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "10"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';

        when S_BCC_7 => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '1';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';



      --------------------------------------------------------------------------------------------------
      -- OTHERS
      --------------------------------------------------------------------------------------------------                
        when others => 
           IR_Load  <= '0';         
           MAR_Load <= '0';                       
           PC_Load  <= '0';         
           PC_Inc   <= '0';                     
           A_Load   <= '0';            
           B_Load   <= '0';                 
           ALU_Sel  <= "000";                 
           CCR_Load <= '0';                      
           Bus1_Sel <= "00"; -- "00"=PC,  "01"=A,    "10"=B
           Bus2_Sel <= "00"; -- "00"=ALU, "01"=Bus1, "10"=from_memory
           write    <= '0';  

      end case;
    end process;

end architecture;