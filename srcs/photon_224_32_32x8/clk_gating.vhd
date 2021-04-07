LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY clock_gate IS
PORT (  clk    : IN std_logic;
        enable : IN std_logic;
        clk_en : OUT std_logic
);
END ENTITY clock_gate;

--
ARCHITECTURE behav OF clock_gate IS
signal enable_latch : std_logic;

BEGIN
  -- Latch, on negative clock --
  process (clk, enable) begin
    if (clk = '0') then
     enable_latch <= enable;
  end if;
end process;  
  -- AND Gate
  clk_en <= enable_latch AND clk;
END ARCHITECTURE behav;
