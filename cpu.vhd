library IEEE;
use IEEE.std_logic_1164.all; 

entity cpu is
    port   ( clock          : in   std_logic;
             reset          : in   std_logic;
             address        : out  std_logic_vector (7 downto 0);
             write          : out  std_logic;
             to_memory      : out  std_logic_vector (7 downto 0);
             from_memory    : in   std_logic_vector (7 downto 0));
end entity;

architecture cpu_arch of cpu is

-- Component Declaration
  component control_unit
    port   ( clock          : in   std_logic;
             reset          : in   std_logic;

             IR_load        : out  std_logic;
             IR             : in   std_logic_vector (7 downto 0);
             MAR_load       : out  std_logic;
             PC_load        : out  std_logic;
             PC_Inc         : out  std_logic;
             A_load         : out  std_logic;
             B_load         : out  std_logic;
             ALU_Sel        : out  std_logic_vector (2 downto 0);
             CCR_Result     : in   std_logic_vector (3 downto 0);
             CCR_load       : out  std_logic;
             Bus2_Sel       : out  std_logic_vector (1 downto 0);
             Bus1_Sel       : out  std_logic_vector (1 downto 0);

             write          : out  std_logic);
  end component;

  component data_path
    port   ( clock          : in   std_logic;
             reset          : in   std_logic;

             IR_load        : in   std_logic;
             IR             : out  std_logic_vector (7 downto 0);
             MAR_load       : in   std_logic;
             PC_load        : in   std_logic;
             PC_Inc         : in   std_logic;
             A_load         : in   std_logic;
             B_load         : in   std_logic;
             ALU_Sel        : in   std_logic_vector (2 downto 0);
             CCR_Result     : out  std_logic_vector (3 downto 0);
             CCR_load       : in   std_logic;
             Bus2_Sel       : in   std_logic_vector (1 downto 0);
             Bus1_Sel       : in   std_logic_vector (1 downto 0);

             from_memory    : in   std_logic_vector (7 downto 0);
             to_memory      : out  std_logic_vector (7 downto 0);

             address        : out  std_logic_vector (7 downto 0)); 
  end component;

-- Signal Declaration

 
     signal  IR_Load   : STD_LOGIC;
     signal  IR        : STD_LOGIC_VECTOR (7 downto 0);
     signal  MAR_Load  : STD_LOGIC;             
     signal  PC_Load   : STD_LOGIC;
     signal  PC_Inc    : STD_LOGIC;             
     signal  A_Load    : STD_LOGIC;
     signal  B_Load    : STD_LOGIC;             
     signal  ALU_Sel   : STD_LOGIC_VECTOR (2 downto 0);             
     signal  CCR_Result: STD_LOGIC_VECTOR (3 downto 0);
     signal  CCR_Load  : STD_LOGIC;             
     signal  Bus1_Sel  : STD_LOGIC_VECTOR (1 downto 0);                          
     signal  Bus2_Sel  : STD_LOGIC_VECTOR (1 downto 0);

  begin

 -- Component Instantiations

 CU_1 : Control_unit
  port map ( clock      => clock,
             reset      => reset,
             write      => write,
             IR_Load    => IR_Load,
             IR         => IR,
             MAR_Load   => MAR_Load,
             PC_Load    => PC_Load,
             PC_Inc     => PC_Inc,
             A_Load     => A_load,
             B_Load     => B_Load,
             ALU_Sel    => ALU_Sel,
             CCR_Result => CCR_Result,
             CCR_Load   => CCR_Load,
             Bus1_Sel   => Bus1_Sel,
             Bus2_Sel   => Bus2_Sel);

 DP_1 : data_path
  port map ( clock       => clock,
             reset       => reset,
             from_memory => from_memory,  
             to_memory   => to_memory,
             address     => address,
             IR_Load     => IR_Load ,
             IR          => IR,
             MAR_Load    => MAR_Load,             
             PC_Load     => PC_Load,
             PC_Inc      => PC_Inc,             
             A_Load      => A_Load,
             B_Load      => B_Load,
             ALU_Sel     => ALU_Sel,
             CCR_Result  => CCR_Result,
             CCR_Load    => CCR_Load,
             Bus1_Sel    => Bus1_Sel,
             Bus2_Sel    => Bus2_Sel);

end architecture;