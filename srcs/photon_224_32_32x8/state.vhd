-- Template for the state of AES like priitives
-- one row is processed in one clock cycle
-- shift row offset is done by wiring
-- all columns have two inputs, consists of n registers 
--
--   +--+  +-----+  +--+<-MC
-- <-|00|<-| ... |<-|05|
--   +--+  +-----+  +--+<-14
--        \ \ \ \  \
--   +--+  +-----+  +--+<-MC
-- <-|10|<-| ... |<-|15|
--   +--+  +-----+  +--+<-24
--        \ \ \ \  \
--   +--+  +-----+  +--+<-MC
-- <-|20|<-| ... |<-|25|
--   +--+  +-----+  +--+<-34
--        \ \ \ \  \
--   +--+  +-----+  +--+<-MC
-- <-|30|<-| ... |<-|35|
--   +--+  +-----+  +--+<-44
--        \ \ \ \  \
--   +--+  +-----+  +--+<-MC
-- <-|40|<-| ... |<-|45|
--   +--+  +-----+  +--+<-54
--        \ \ \ \  \
----        / / / /  /
--   +--+  +-----+  +--+<-MC
-- <-|50|<-| ... |<-|55|
--   +--+  +-----+  +--+<-inS
--    c1    rows     lc
-- outS  = 00&01&02&03&04&05
-- outMC = 00&10&20&30&40&50

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state is
	generic (NBITS_s: integer;
		 	NBITS_n: integer);
	port(
		clk: in std_logic;
		selSR: in std_logic;
		inS	 : in std_logic_vector(NBITS_s*NBITS_n - 1 downto 0);
		outS : out std_logic_vector(NBITS_s*NBITS_n -1 downto 0);
		outMC: out std_logic_vector(NBITS_s*NBITS_n*NBITS_n -1 downto 0)
		);

end entity state;


architecture dfl of state is

	signal int_D0, int_D1, int_Q 	: std_logic_vector(NBITS_s*NBITS_n*NBITS_n- 1 downto 0);
	signal row0,row1,row2,row3,row4 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal row5 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
 	signal row6 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal row7 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal col0,col1,col2,col3,col4 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal col5 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
 	signal col6 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal col7 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal in0row0,in0row1,in0row2,in0row3,in0row4 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal in0row5 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
 	signal in0row6 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose
	signal in0row7 	: std_logic_vector(NBITS_s*NBITS_n-1 downto 0); --one row for testing purpose

component dflipfloplw2in is
	generic (NBITS: integer);
	port(
		clk	: in std_logic;
		n_reset	: in std_logic;
		D	: in std_logic_vector(NBITS-1 downto 0);
		D_rst	: in std_logic_vector(NBITS-1 downto 0);
		Q	: out std_logic_vector(NBITS-1 downto 0)
		);
end component dflipfloplw2in;

begin
-------------------------------------------------------------------------------------
-- wiring, horizontal input
-------------------------------------------------------------------------------------
int_D0 <= in0row0&in0row1&in0row2&in0row3&in0row4&in0row5&in0row6&in0row7;
-------------------------------------------------------------------------------------
-- ShiftRows, in one clock cycle
-------------------------------------------------------------------------------------
in0row0 <= row0;
in0row1 <= row1((NBITS_n-1)*NBITS_s-1 downto 0)&row1(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s);
in0row2 <= row2((NBITS_n-2)*NBITS_s-1 downto 0)&row2(NBITS_n*NBITS_s-1 downto (NBITS_n-2)*NBITS_s);
in0row3 <= row3((NBITS_n-3)*NBITS_s-1 downto 0)&row3(NBITS_n*NBITS_s-1 downto (NBITS_n-3)*NBITS_s);
in0row4 <= row4((NBITS_n-4)*NBITS_s-1 downto 0)&row4(NBITS_n*NBITS_s-1 downto (NBITS_n-4)*NBITS_s);
in0row5 <= row5((NBITS_n-5)*NBITS_s-1 downto 0)&row5(NBITS_n*NBITS_s-1 downto (NBITS_n-5)*NBITS_s);
in0row6 <= row6((NBITS_n-6)*NBITS_s-1 downto 0)&row6(NBITS_n*NBITS_s-1 downto (NBITS_n-6)*NBITS_s);
in0row7 <= row7((NBITS_n-7)*NBITS_s-1 downto 0)&row7(NBITS_n*NBITS_s-1 downto (NBITS_n-7)*NBITS_s); 
-------------------------------------------------------------------------------------
-- wiring, vertical input
-------------------------------------------------------------------------------------
int_D1 <= row1&row2&row3&row4&row5&row6&row7&inS;

-------------------------------------------------------------------------------------
-- state matrix consists of n x n FFs, each s-bit
-------------------------------------------------------------------------------------
gen_rows:
FOR i in 1 to NBITS_n GENERATE
	gen_cols:
	FOR j in 1 to NBITS_n GENERATE
	gff: dflipfloplw2in
		generic map(NBITS=>NBITS_s)
		port map(
			clk => clk,
			n_reset => selSR,
	      	D => int_D1(NBITS_s*((i-1)*NBITS_n+j) - 1 downto NBITS_s*((i-1)*NBITS_n+j-1)),
	  		D_rst => int_D0(NBITS_s*((i-1)*NBITS_n+j) - 1 downto NBITS_s*((i-1)*NBITS_n+j-1)),
	      	Q => int_Q(NBITS_s*((i-1)*NBITS_n+j) - 1 downto NBITS_s*((i-1)*NBITS_n+j-1))
			);
	END GENERATE gen_cols;
END GENERATE gen_rows;


-------------------------------------------------------------------------------------
-- output, outMC is concatenation of first column
-------------------------------------------------------------------------------------
outMC <= col0&col1&col2&col3&col4&col5&col6&col7;
outS <= row0; 
-------------------------------------------------------------------------------------
-- row signals not only for debugging purpose
-------------------------------------------------------------------------------------
row0 <= int_Q(NBITS_n*NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_n*NBITS_s);
row1 <= int_Q((NBITS_n-1)*NBITS_n*NBITS_s-1 downto (NBITS_n-2)*NBITS_n*NBITS_s);
row2 <= int_Q((NBITS_n-2)*NBITS_n*NBITS_s-1 downto (NBITS_n-3)*NBITS_n*NBITS_s);
row3 <= int_Q((NBITS_n-3)*NBITS_n*NBITS_s-1 downto (NBITS_n-4)*NBITS_n*NBITS_s);
row4 <= int_Q((NBITS_n-4)*NBITS_n*NBITS_s-1 downto (NBITS_n-5)*NBITS_n*NBITS_s);
row5 <= int_Q((NBITS_n-5)*NBITS_n*NBITS_s-1 downto (NBITS_n-6)*NBITS_n*NBITS_s);
row6 <= int_Q((NBITS_n-6)*NBITS_n*NBITS_s-1 downto (NBITS_n-7)*NBITS_n*NBITS_s);
row7 <= int_Q((NBITS_n-7)*NBITS_n*NBITS_s-1 downto (NBITS_n-8)*NBITS_n*NBITS_s);

-------------------------------------------------------------------------------------
-- col signals not only for debugging purpose
-------------------------------------------------------------------------------------
col0 <= row0(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row1(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row2(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row3(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row4(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row5(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row6(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s)&row7(NBITS_n*NBITS_s-1 downto (NBITS_n-1)*NBITS_s);
col1 <= row0((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row1((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row2((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row3((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row4((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row5((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row6((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s)&row7((NBITS_n-1)*NBITS_s-1 downto (NBITS_n-2)*NBITS_s);
col2 <= row0((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row1((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row2((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row3((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row4((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row5((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row6((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s)&row7((NBITS_n-2)*NBITS_s-1 downto (NBITS_n-3)*NBITS_s);
col3 <= row0((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row1((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row2((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row3((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row4((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row5((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row6((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s)&row7((NBITS_n-3)*NBITS_s-1 downto (NBITS_n-4)*NBITS_s);
col4 <= row0((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row1((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row2((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row3((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row4((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row5((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row6((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s)&row7((NBITS_n-4)*NBITS_s-1 downto (NBITS_n-5)*NBITS_s);
col5 <= row0((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row1((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row2((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row3((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row4((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row5((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row6((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s)&row7((NBITS_n-5)*NBITS_s-1 downto (NBITS_n-6)*NBITS_s);
col6 <= row0((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row1((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row2((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row3((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row4((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row5((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row6((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s)&row7((NBITS_n-6)*NBITS_s-1 downto (NBITS_n-7)*NBITS_s);
col7 <= row0((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row1((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row2((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row3((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row4((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row5((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row6((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s)&row7((NBITS_n-7)*NBITS_s-1 downto (NBITS_n-8)*NBITS_s);
end architecture;
