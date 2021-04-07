-- killer I/O interface
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- a = feedback
-- b = input

entity killerIO is
	generic (NBITS: integer);
        port(
                a       : in std_logic_vector(NBITS-1 downto 0);
                b       : in std_logic_vector(NBITS-1 downto 0);
                nReset  : in std_logic;
                nb	    : in std_logic;
                output  : out std_logic_vector(NBITS-1 downto 0)
                );

end entity killerIO;

architecture dfl of killerIO is

        signal nResetx, nbx : std_logic_vector(NBITS-1 downto 0);

begin
nResetx <= (others => nReset);
nbx <= (others => nb);

output <= (nResetx NAND a) XOR (nbx NAND b); 


end architecture dfl;