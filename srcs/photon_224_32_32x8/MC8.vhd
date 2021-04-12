-- serial-MixColumns
-- computes 1 nibble
-- 1, x, x^3, x^2+1, x^3, x
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;

entity MC8 is
        port(
                input       : in std_logic_vector(n*s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end entity MC8;

architecture dfl of MC8 is

component times2 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end component times2;

component times4 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end component times4;

component times8 is
        port(
                input       : in std_logic_vector(s-1 downto 0);
                output      : out std_logic_vector(s-1 downto 0)
                );

end component times8;

   signal S0,S1,S2,S3,S4,S5,S6,S7 : std_logic_vector(s-1 downto 0);
   signal S02,S14,S22,S32,S38,S42,S58,S64,S72,S74 : std_logic_vector(s-1 downto 0);

begin

---------------------------------------------------------------------
-- | S0 | S1 | S2 | S3 | S4 | S5 | S6 | S7 |

--   x   x2    x  x3+x+1  x  x3  x2+1  x2+x
--   2    4    2    11    2   8    5    6
---------------------------------------------------------------------
S0 <= input(31 downto 28);
S1 <= input(27 downto 24);
S2 <= input(23 downto 20);
S3 <= input(19 downto 16);
S4 <= input(15 downto 12);
S5 <= input(11 downto 8);
S6 <= input(7 downto 4);
S7 <= input(3 downto 0);

xS0: times2
port map(
	input => S0,
	output => S02
	);

x2S1: times4
port map(
	input => S1,
	output => S14
	);

xS2: times2
port map(
	input => S2,
	output => S22
	);

xS3: times2
port map(
	input => S3,
	output => S32
	);

x3S3: times8
port map(
	input => S3,
	output => S38
	);

xS4: times2
port map(
	input => S4,
	output => S42
	);

x3S5: times8
port map(
	input => S5,
	output => S58
	);
	
x2S6: times4
port map(
	input => S6,
	output => S64
	);

xS7: times2
port map(
	input => S7,
	output => S72
	);

x2S7: times4
port map(
	input => S7,
	output => S74
	);

output <= S02 XOR S14 XOR S22 XOR S38 XOR S32 XOR S3 XOR S42 XOR S58 XOR S64 XOR S6 XOR S74 XOR S72; 


end architecture dfl;