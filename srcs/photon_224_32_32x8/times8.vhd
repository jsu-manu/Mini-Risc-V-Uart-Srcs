--times two in gf(s^s)
-- using x^4 = x + 1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;

entity times8 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end entity times8;

architecture dfl of times8 is

        signal a,b,c,d : std_logic;

begin
a <= input(s-1);
b <= input(s-2);
c <= input(s-3);
d <= input(s-4);

output <= (a XOR d)&(a XOR b)&(b XOR c)&c; 

end architecture dfl;