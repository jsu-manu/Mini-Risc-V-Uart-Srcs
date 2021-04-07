----------------------------------------------------------------------------------
-- wrapper to instantiate all n MC's in a convenient way
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.hashpkg.all;

entity MCS is
    Port ( input : in  STD_LOGIC_VECTOR (n*n*s-1 downto 0);
           output : out  STD_LOGIC_VECTOR (n*s-1 downto 0)
           );
end MCS;

architecture dfl of MCS is

component MC8 is
        port(
                input       : in std_logic_vector(n*s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end component MC8;

----------------------------------------------------------
-- data signals
----------------------------------------------------------

begin
gen_MC:
For i in 1 to n GENERATE
MC: MC8
	port map(
	input => input(n*s*i-1 downto n*s*(i-1)),
	output => output(s*i-1 downto s*(i-1))
	);
end GENERATE gen_MC;
end dfl;