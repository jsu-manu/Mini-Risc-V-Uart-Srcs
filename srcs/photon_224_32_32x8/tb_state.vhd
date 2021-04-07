LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.ALL;

-- file functions
USE ieee.std_logic_textio.all;
LIBRARY STD;
USE STD.TEXTIO.ALL;

--package
use work.hashpkg.all;
 
ENTITY tb_state IS
END tb_state;
 
ARCHITECTURE bench OF tb_state IS 
 
-- Component Declaration for the Unit Under Test (UUT)

component lwh is
        port(
        		clk			: in std_logic;
        		init		: in std_logic;
        		nReset		: in std_logic;
        		nBlock		: in std_logic;
                lwh_input       : in std_logic_vector(n*s-1 downto 0);
                lwh_output      : out std_logic_vector(n*s-1 downto 0);
        		outReady	: out std_logic
                );

end component lwh;

   --Inputs
   signal clk : std_logic := '0';
 
   signal lwh_input, lwh_output : std_logic_vector(n*s-1 downto 0);
   signal nReset, nBlock, outReady, init : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
UUT: lwh
     port map(
     			clk		 => clk, 
        		init	 => init,
        		nReset	 => nReset,
        		nBlock	 => nBlock,
                lwh_input    => lwh_input,
                lwh_output   => lwh_output,
        		outReady => outReady
                );


   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
	check_results : process
		begin

--start here!--
init <= '0';
nBlock <= '0';
lwh_input <= (others => '1');
--reset for min n clk cycles
nReset <= '0';
wait for 2*n*clk_period;

--reset done, input initial data
-- wait for 0.5*clk_period;
nReset <= '1';
--  wait for 0.5*clk_period;

-- input all 0's 
				lwh_input <= (others => '0');
				init <= '0';
				nBlock <= '1';
				wait for (n-1)*clk_period;
-- input IV 
				lwh_input <= x"00382020";
				wait for clk_period;
				
--S-box feedback instead of 0
init <= '1';
nBlock <= '0';

wait for 12*(2*n+1)*clk_period;
		
			end process check_results;	
END;