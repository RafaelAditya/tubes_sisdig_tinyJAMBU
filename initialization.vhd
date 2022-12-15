Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.state_update.all;

entity initialization is
port (
	clk, rst, proceed : IN std_logic;
	s: inout std_logic_vector(127 downto 0);
	nonce: IN std_logic_vector(95 downto 0);
	feedback : out std_logic;
);
end initialization;

architecture initialization_arc of initialization is
	type states is (init, s0, s1, s2, s3, s4, s5, s6);
	signal nState, cState : states;
	
	i : integer;
	j : integer := 0;
	k : std_logic_vector(127 downto 0);
 	framebits: std_logic_vector(2 downto 0) := '001';
	
begin
	state_update : entity work.state_update(state_update_arc) port map(
	s => s,
	k => k,
	rst => rst, 
	clk => clk, 
	proceed => proceed,
	i => i,
	
	feedback => feedback
	);
	
	type states is (init, s0, s1, s2, s3, s4, s5, s6);
	signal nState, cState : states;
	
	process(rst, clk)
	begin
	if (rst = '1') then
		cState <= init;
	elsif( clk'event and clk = '1' ) then
		cState <= nState;
	end if;
	end process;
	
	process( proceed, cState )
	case cState
	
	when init => 
		if (proceed = '0') then
			nState <= init;
		else
			nState <= s0;
		end if;
	
	when s0 =>
		s <= (others => '0');
		nState <= s1;
		
	when s1 =>
		s <= s;
		k <= k;
		rst <= rst; 
		clk <= clk;
		proceed <= proceed;
		i <= 1024;
		nState <= s2;
		
	when s2 =>
		if j < 3 then
			s(38 downto 36) <= s(38 downto 36) xor framebits;
			nState <= s3;
		else
			nState <= s6;
	
	when s3 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s4;
		
	when s4 =>
		s <= s;
		k <= k;
		rst <= rst; 
		clk <= clk;
		proceed <= proceed;
		i <= 640;
		nState <= s5;
		
	when s5 =>
		s(127 downto 96) <= s(127 downto 96) xor nonce((32*i + 31) downto 32*i);	
		i <= j + 1;
		nState <= s2;
		
	when s6 => 	
	end case;
end process;
end initialization_arc;
