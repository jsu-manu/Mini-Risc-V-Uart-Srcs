--times two in gf(s^s)
-- using x^4 = x + 1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;

entity times4 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end entity times4;

architecture dfl of times4 is

        signal a,b,c,d : std_logic;

begin
a <= input(s-1);
b <= input(s-2);
c <= input(s-3);
d <= input(s-4);

output <= c&(d XOR a)&(a XOR b)&b; 

end architecture dfl;