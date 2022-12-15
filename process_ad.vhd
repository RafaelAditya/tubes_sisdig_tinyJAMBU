Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity process_ad is
port(
ad : in std_logic_vector (63 downto 0); -- ini harusnya adlen
clk, rst, proceed : IN std_logic;
s: inout std_logic_vector(127 downto 0);
);

end process_ad;

architecture process_ad_arc of process_ad is
	type states is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
	signal nState, cState : states;
	
	j : integer := 0;
	i : integer;
	k : std_logic_vector(127 downto 0);
	framebits: std_logic_vector(2 downto 0) := '011';
	feedback : std_logic;
	lenp : integer;
	startp: integer; 
	

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
	
	type states is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9);
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
	case cState is
	
	when init => 
		if (proceed = '0') then
			nState <= init;
		else
			nState <= s0;
		end if;
	
	when s0 =>
	if j < (64 / 32) then 
		s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
		nState <= s1 
	elsif (64 mod 32) > 0 then -- ini harusnya adlen
		nState <= s3;
	else 
		nState <= s9;
	end if; 
	
	when s1 => 
		s <= s;
		k <= k;
		rst <= rst; 
		clk <= clk;
		proceed <= proceed;
		i <= 640;
		nState <= s2;
	
	when s2 => 
	s(127 downto 96) <= s(127 downto 96) xor ad(32*j+31 downto 32*j)
	j <= j + 1;
	nState <= s0;
	
	when s3 => 
	s(38 downto 36) <= s(38 downto 36) xor framebits(2 downto 0);
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
		lenp <= 64 mod 32;
		nState <= s6;
	
	when s6 => 
		startp <= 64 - lenp;
		nState <= s7;
	
	when s7 => 
		s((96+lenp-1) downto 96) <= s((96+lenp-1) downto 96) xor ad((64-1) downto startp);
		nState <= s8;
	
	when s8 =>
		s(33 downto 32) <= s(33 downto 32) xor (lenp / 8); 
		nState <= s9;
	
	when s9 =>
	end case;
	end process;
end process_ad_arc;
