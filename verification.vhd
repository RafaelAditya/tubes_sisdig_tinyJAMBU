Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


entity verification is
	port
	(
	clk, rst, proceed : IN std_logic;
	s: inout std_logic_vector(127 downto 0);
	t: in std_logic_vector(63 downto 0);
	
	t_aksen: inout std_logic_vector(63 downto 0)
	);
end verification;

architecture verification_arc of verification is
	type states is (init, s0, s1, s2, s3, s4, s5, s6);
	signal nState, cState : states;

	signal k : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0) := "101";
	signal feedback : std_logic;
	signal i : integer;
	
begin
	state_update : entity work.state_update(state_update_arc) 
	port map(
		s => s,
		k => k,
		rst => rst, 
		clk => clk, 
		proceed => proceed,
		i => i,
	
		feedback => feedback
	);

process(rst, clk)
	begin
	if (rst = '1') then
		cState <= init;
	elsif( clk'event and clk = '1' ) then
		cState <= nState;
	end if;
	end process;
	
	process( proceed, cState )
	variable j : integer := 0;
	variable mlen : integer;
	variable lenp : integer;
	variable startp : integer;	

	begin
	case cState is
	
	when init => 
		if (proceed = '0') then 
			nState <= init;
		else
			nState <= s0;
		end if;
		
	when s0 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s1;
	
	when s1 =>
		s <= s;
		k <= k;
		i <= 1024;
		nState <= s2;
	
	when s2 =>
		t_aksen <= s(95 downto 64);
		nState <= s3;
		
	when s3 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s4;
	
	when s4 =>
		s <= s;
		k <= k;
		i <= 640;
		nState <= s5;
	
	when s5 =>
		t_aksen(63 downto 32) <= s(95 downto 64);
		nState <= s6;
	
	when s6 =>
		t_aksen <= t_aksen(63 downto 0);
	end case;
	end process;

end verification_arc;