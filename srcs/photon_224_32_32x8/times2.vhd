--times two in gf(s^s)
-- using x^4 = x + 1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;

entity times2 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end entity times2;

architecture dfl of times2 is

        signal MSB : std_logic;

begin
MSB <= input(s-1);

output <= input(s-2 downto 1)&(input(0) XOR MSB)&MSB; 

end architecture dfl;