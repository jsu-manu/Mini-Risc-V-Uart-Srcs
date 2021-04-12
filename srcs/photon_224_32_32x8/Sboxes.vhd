----------------------------------------------------------------------------------
-- wrapper to instantiate all n S-boxes in a convenient way
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.hashpkg.all;

entity Sboxes is
    Port ( sboxIn : in  STD_LOGIC_VECTOR (n*s-1 downto 0);
           sboxOut : out  STD_LOGIC_VECTOR (n*s-1 downto 0)
           );
end Sboxes;

architecture dfl of Sboxes is

component SboxDAO is
    Port ( sboxIn : in  STD_LOGIC_VECTOR (3 downto 0);
           sboxOut : out  STD_LOGIC_VECTOR (3 downto 0)
           );
end component SboxDAO;

----------------------------------------------------------
-- data signals
----------------------------------------------------------

begin
gen_SB:
For i in 1 to n GENERATE
SB: SboxDAO
	port map(
	sboxIn => sboxIn(s*i-1 downto s*(i-1)),
	sboxOut => sboxOut(s*i-1 downto s*(i-1))
	);
end GENERATE gen_SB;
end dfl;