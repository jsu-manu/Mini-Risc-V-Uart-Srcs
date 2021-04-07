-- D-Flip-Flop lightweight
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;

entity lwh is
        port(
        		clk			: in std_logic;
        		init		: in std_logic; -- keep high while calculating?
        		nReset		: in std_logic; -- pull low to reset
        		nBlock		: in std_logic; -- low for S-box feedback, loads inputs
                lwh_input   : in std_logic_vector(n*s-1 downto 0); -- clock 8 32-bit registers in
                lwh_output  : out std_logic_vector(n*s-1 downto 0); -- clock 8 32-bit registers out
        		outReady	: out std_logic -- high while reading outputs
        		-- on falling edge clock, rising edge outReady, start reading values
                );

end entity lwh;

architecture dfl of lwh is

---------------------------------------------------------------------------
-- Component declaration
---------------------------------------------------------------------------
component killerIO is
	generic (NBITS: integer);
        port(
                a       : in std_logic_vector(NBITS-1 downto 0);
                b       : in std_logic_vector(NBITS-1 downto 0);
                nReset  : in std_logic;
                nb	    : in std_logic;
                output  : out std_logic_vector(NBITS-1 downto 0)
                );

end component killerIO;

component controler is
port(
	clk		: in std_logic;
	nReset  : in std_logic;
	round   : out std_logic_vector(3 downto 0);
  	offset  : out std_logic_vector(3 downto 0);
  	selSR   : out std_logic;
	selMC   : out std_logic;
	done    : out std_logic
);
end component controler;

component State is
	generic (NBITS_s: integer;
		 	NBITS_n: integer);
	port(
		clk: in std_logic;
		selSR: in std_logic;
		inS	 : in std_logic_vector(NBITS_s*NBITS_n - 1 downto 0);
		outS : out std_logic_vector(NBITS_s*NBITS_n -1 downto 0);
		outMC: out std_logic_vector(NBITS_s*NBITS_n*NBITS_n -1 downto 0)
		);
end component State;

component Sboxes is
    Port ( sboxIn : in  STD_LOGIC_VECTOR (n*s-1 downto 0);
           sboxOut : out  STD_LOGIC_VECTOR (n*s-1 downto 0)
           );
end component Sboxes;

component MCS is
        port(
                input       : in std_logic_vector(n*n*s-1 downto 0);
                output      : out std_logic_vector(n*s-1 downto 0)
                );
end component MCS;

---------------------------------------------------------------------------
-- Signal declaration
---------------------------------------------------------------------------
        signal MCin : std_logic_vector(n*n*s-1 downto 0);
        signal MCout, CAin : std_logic_vector(n*s-1 downto 0);
        signal round, offset : std_logic_vector(s-1 downto 0);
        
        signal StateIn, StateOut, SboxIn, SboxOut : std_logic_vector(n*s-1 downto 0);
        signal selSR, selMC : std_logic;
        
begin

---------------------------------------------------------------------------
-- I/O
---------------------------------------------------------------------------
IO: killerIO
	generic map(NBITS=>n*s)
    port map(
                a => stateOut,--SboxOut,--stateOut,
                b => lwh_input,
                nReset  => init,
                nb	    => nBlock,
                output  => CAin--StateIn--CAin
                );

---------------------------------------------------------------------------
-- Finite State Machine
---------------------------------------------------------------------------
fsm: controler
	port map(
	clk	=> clk,
	nReset => nReset,
	round  => round,
  	offset  => offset,
  	selSR => selSR,
  	selMC => selMC,
  	done => outReady
		);

---------------------------------------------------------------------------
-- State array
---------------------------------------------------------------------------
mem: state
	generic map (NBITS_s => s,
		 	NBITS_n => n)
	port map( 
		clk => clk,
		selSR  => selSR,
		inS	   => StateIn,
		outS   => StateOut,
		outMC  => MCin
		);

---------------------------------------------------------------------------
-- Sbox
---------------------------------------------------------------------------
SB: Sboxes
port map(
	sboxIn => SboxIn,
	sboxOut => SboxOut
	);

---------------------------------------------------------------------------
-- MixColumns
---------------------------------------------------------------------------
MCserial: MCS
port map(
	input => MCin,
	output => MCout
	);
       
---------------------------------------------------------------------------
-- input MUXes
---------------------------------------------------------------------------
StateIn <= SboxOut when selMC='0'
			else MCout;

---------------------------------------------------------------------------
-- Constant Addition to the s MSB of each row
---------------------------------------------------------------------------
SboxIn <= (CAin(n*s-1 downto (n-1)*s) XOR round XOR offset)&CAin((n-1)*s-1 downto 0);

---------------------------------------------------------------------------
-- output is direct from register
---------------------------------------------------------------------------
lwh_output <= StateOut;

end architecture dfl;