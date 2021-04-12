library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package hashpkg is

  constant CLK_PERIOD : time := 10 us;

  constant CAPA   : integer := 224; --security level
  constant RATE   : integer := 32; --message chunk width
  constant s	  : integer := 4; --width of S-box
  constant n	  : integer := 8; -- number of rows
  constant b	  : integer := 32; --bits
    
end hashpkg;
