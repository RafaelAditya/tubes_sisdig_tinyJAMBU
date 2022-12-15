Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity decryption is
	port
	(
	clk, rst, proceed : IN std_logic;
	s: inout std_logic_vector(127 downto 0);
	c: in std_logic_vector(63 downto 0);
	m: out std_logic_vector(63 downto 0)
	);
end decryption

architecture decryption_arc of decryption is
	type states is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12);
	signal nState, cState : states;
	signal slv_value : std_logic_vector(1 downto 0);
	signal i : integer;
	signal k : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0) := '101';
	signal feedback : std_logic;
	signal mlen : integer;
	
	
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
		if j < mlen/32 then
			nState <= s1;
		elsif (mlen mod 32) > 0 then
			nState <= s5;
		else
			nState <= s12;
		end if;
	
	when s1 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s2;
	
	when s2 =>
		s <= s;
		k <= k;
		rst <= rst; 
		clk <= clk;
		proceed <= proceed;
		i <= 1024;
		nState <= s3;
		
	when s3 =>
		m((32*j + 31) downto 32*j) <= s(95 downto 64) xor c((32*j + 31) downto 32*j);
		nState <= s4;
		
	when s4 =>
		s(127 downto 96) <= s(127 downto 96) xor m((32*j + 31) downto 32*j);
		j <= j+1;
	
	when s5 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s6;
	
	when s6 =>
		s <= s;
		k <= k;
		rst <= rst; 
		clk <= clk;
		proceed <= proceed;
		i <= 1024;
		nState <= s7;
	
	when s7 =>
		lenp <= mlen mod 32;
		nState <= s8;
		
	when s8 =>
		startp <= mlen - lenp;
		nState <= s9;
	
	when s9 =>
		m((mlen-1) downto startp) <=  s((96+lenp-1) downto 96) xor c(mlen-1 downto starp);
		nState <= s10;
		
	when s10 =>
		s((96+lenp-1) downto 96) <= s((96+lenp-1) downto 96) xor m(mlen-1 downto startp);
		nState <= s11;
	
	when s11 =>
		slv_value <= std_logic_vector(to_unsigned(lenp, 2));
		s(33 downto 32) <= s(33 downto 32) xor (slv_value);
		nState <= s12
	
	when s12 =>
	
	end case;
end process;
end decryption_arc;