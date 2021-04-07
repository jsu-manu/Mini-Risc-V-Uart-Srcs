library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hashpkg.all;
-- n x n is the size of the Matrix
entity controler is
port(
	clk		: in std_logic;
	nReset  : in std_logic;
	round   : out std_logic_vector(3 downto 0);
  	offset  : out std_logic_vector(3 downto 0);
  	selSR   : out std_logic;
	selMC   : out std_logic;
	done    : out std_logic
);
end entity controler;

	
architecture fsm of controler is

----------------------------------------------------------
-- component declaration
----------------------------------------------------------

component LFSRcounter8 is
	port(
		clk	: in std_logic;
		selDataIn    : in std_logic;
		q	: out std_logic_vector(3 downto 0)
		);

end component LFSRcounter8;

component LFSRcounter15 is
	port(
		clk	: in std_logic;
		selDataIn    : in std_logic;
		q	: out std_logic_vector(3 downto 0)
		);

end component LFSRcounter15;

component clock_gate IS
PORT (  clk    : IN std_logic;
        enable : IN std_logic;
        clk_en : OUT std_logic
);
END component clock_gate;

----------------------------------------------------------
-- finite state stuff
----------------------------------------------------------
	
	type lwh_states is (S_IDLE, S_INIT, S_SB, S_SR, S_MC);
 
  	signal lwh_state  		: lwh_states;
  	signal next_state 		: lwh_states;

----------------------------------------------------------
-- signal declaration
----------------------------------------------------------

signal countRound  : std_logic_vector(3 downto 0);
signal countRows : std_logic_vector(3 downto 0);
signal en_countRound, rst_countRound : std_logic;
signal rst_countRows : std_logic;
signal clk_countRound : std_logic;  
signal int_selMC : std_logic;  

begin

----------------------------------------------------------
-- component instantiation
----------------------------------------------------------

-- row counter
        
cnt_Rows: LFSRcounter8
  port map(
            clk => clk,
            selDataIn => rst_countRows,
            q => countRows
            );
  
-- round counter
cg_countRound: clock_gate
port map(  clk => clk,
        enable => en_countRound,
        clk_en => clk_countRound
        );

cnt_round: LFSRcounter15
  port map(
            clk => clk_countRound,
            selDataIn => rst_countRound,
            q => countRound
            );

----------------------------------------------------------
-- finite state stuff
----------------------------------------------------------

ps_state_change:	process(clk)
begin
	if(clk'event and clk = '0') then
		if (nReset = '0') then
			lwh_state <= S_IDLE;
		else
			lwh_state <= next_state;
		end if;
	end if;
end process;


----------------------------------------------------------
-- FSM
----------------------------------------------------------

ps_state_compute:  process(lwh_state, countRows)

begin

----------------------------------------------------------
-- finite state stuff
----------------------------------------------------------
next_state <= lwh_state;

-- by default all register shift vertically
-- selSR <= '1';
int_selMC <= '0';
			
-- by default no reset
rst_countRound <= '1';
rst_countRows <= '1';

-- by default no counter counts
en_countRound <= '0';
		
case lwh_state is

        when S_IDLE =>
        --reset counters etc
        --needs to be active low for at least n clock cycles
			rst_countRound <= '0';
			rst_countRows <= '0';
			en_countRound <= '1';
			next_state <= S_SB;
        
		when S_SB=>
		--n clock cycles
		--all register clock
		--all sel in vertical mode
			if(countRows="0000") then  
			  next_state <= S_SR;
			end if;
        
        when S_SR=>
    	--rotate by the according offset in horizontal mode
-- 	    	selSR <= '0';
	    	rst_countRows <= '0';
			next_state  <= S_MC;
			
		when S_MC =>
				-- first column in vertical shifting mode
 				int_selMC <= '1';
			if(countRows="0000") then 
			  	next_state <= S_SB;
			  	en_countRound <= '1';
			end if;
        
        when others =>
        next_state <= S_IDLE;
        
end case;
        
end process;

----------------------------------------------------------
-- signal wiring
----------------------------------------------------------
round <= countRound;
offset <= countRows;
selMC <= int_selMC;
selSR <= rst_countRows AND nReset; 
-- done when countRound is 0100 = 12 rounds
done <= (NOT countRound(3)) AND countRound(2) AND (countRound(1) NOR countRound(0)) AND (NOT int_selMC);

end;
