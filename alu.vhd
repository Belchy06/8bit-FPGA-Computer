library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
      port ( A, B        : in  STD_LOGIC_VECTOR (7 downto 0);
             ALU_Sel     : in  STD_LOGIC_VECTOR (2 downto 0);
             Result      : out STD_LOGIC_VECTOR (7 downto 0);
             NZVC        : out STD_LOGIC_VECTOR (3 downto 0) );
end entity;

architecture alu_arch of alu is
  
 
  begin

  ALU_PROCESS : process (A, B, ALU_Sel)
  
  variable Sum_uns : unsigned(8 downto 0); 
  variable Sum	   : signed(7 downto 0);
  
    begin
      if (ALU_Sel = "000") then -- ADDITION
        --  producing the sum
           Sum_uns := unsigned('0' & A) + unsigned('0' & B);
           Result  <= std_logic_vector(Sum_uns(7 downto 0));
         
        -- producing the status flags
           -- Negative flag
           NZVC(3) <= Sum_uns(7);

           -- Zero flag
           if (Sum_uns(7 downto 0) = x"00") then
              NZVC(2) <= '1';
           else
              NZVC(2) <= '0';            
           end if;
         
           -- Overflow flag
           if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or (A(7)='1' and B(7)='1' and Sum_uns(7)='0')) then
              NZVC(1) <= '1';
           else
              NZVC(1) <= '0';            
           end if;

           -- Carry flag
           NZVC(0) <= Sum_uns(8);

--      elsif (ALU_Sel ...
--                : ?other ALU functionality goes here?
      elsif (ALU_Sel = "001") then -- SUBTRACTION
	Sum := signed(B) - signed(A);
	Result <= std_logic_vector(Sum);

        -- producing the status flags
           -- Negative flag
           NZVC(3) <= Sum(7);

           -- Zero flag
           if (Sum = x"00") then
              NZVC(2) <= '1';
           else
              NZVC(2) <= '0';            
           end if;
         
           -- Overflow flag
           if ((A(7)='0' and B(7)='0' and Sum(7)='1') or (A(7)='1' and B(7)='1' and Sum(7)='0')) then
              NZVC(1) <= '1';
           else
              NZVC(1) <= '0';            
           end if;  

      elsif (ALU_Sel = "010") then -- AND
	Result <= A AND B;

      elsif (ALU_Sel = "011") then -- OR
	Result <= A OR B;

      elsif (ALU_Sel = "100" or ALU_Sel = "101") then -- INC
        --  producing the sum 
	   -- The input register is actually B input
           Sum_uns := unsigned('0' & B) + 1;
           Result  <= std_logic_vector(Sum_uns(7 downto 0));
         
        -- producing the status flags
           -- Negative flag
           NZVC(3) <= Sum_uns(7);

           -- Zero flag
           if (Sum_uns(7 downto 0) = x"00") then
              NZVC(2) <= '1';
           else
              NZVC(2) <= '0';            
           end if;
         
           -- Overflow flag
           if ((A(7)='0' and B(7)='0' and Sum_uns(7)='1') or (A(7)='1' and B(7)='1' and Sum_uns(7)='0')) then
              NZVC(1) <= '1';
           else
              NZVC(1) <= '0';            
           end if;

           -- Carry flag
           NZVC(0) <= Sum_uns(8);

      elsif (ALU_Sel = "110" or ALU_Sel = "111") then -- DEC
	Sum := signed(B) - 1;
	Result <= std_logic_vector(Sum);

        -- producing the status flags
           -- Negative flag
           NZVC(3) <= Sum(7);

           -- Zero flag
           if (Sum = x"00") then
              NZVC(2) <= '1';
           else
              NZVC(2) <= '0';            
           end if;
         
           -- Overflow flag
           if ((A(7)='0' and B(7)='0' and Sum(7)='1') or (A(7)='1' and B(7)='1' and Sum(7)='0')) then
              NZVC(1) <= '1';
           else
              NZVC(1) <= '0';            
           end if;


      else  
        Result <= "ZZZZZZZZ";
        NZVC   <= "ZZZZ";

    end if;
    
  end process;


end architecture;