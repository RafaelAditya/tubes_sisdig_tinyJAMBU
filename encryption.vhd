Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity encryption is
	port(
		clk, rst, proceed : IN std_logic;
		s: inout std_logic_vector(127 downto 0);
		m: IN std_logic_vector(63 downto 0); -- ini harusnya mlen
		c: inout std_logic_vector(63 downto 0)
	);
end encryption;

architecture encryption_arc of encryption is
	type states is (init, s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11);
	signal nState, cState : states;
	signal slv_value : std_logic_vector(1 downto 0);
	signal i : integer;
	signal k : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0) := "101";
	signal feedback : std_logic;

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
	variable startp: integer; 
	variable mlen: integer := 64;
	begin 
	case cState is 

	when init => 
		if (proceed = '0') then
			nState <= init;
		else
			nState <= s0;
		end if;
	
	when s0 =>
		if j < 64/32 then
			s(38 downto 36) <= s(38 downto 36) xor framebits;
			nState <= s1;
		elsif 64 mod 32 > 0 then -- ini harusnya mlen
			nState <= s4;
		else
			nState <= s11;
	end if;
		
	when s1 =>
		s <= s;
		k <= k;
		i <= 1024;
		nState <= s2;
	
	when s2 =>
		s(127 downto 96) <= s(127 downto 96) xor m((32*j + 31) downto 32*j);
		nState <= s3;
	
	when s3 =>
		c((32*j + 31) downto 32*j) <= s(95 downto 64) xor m((32*j + 31) downto 32*j);
		j := j+1;
	
	when s4 =>
		s(38 downto 36) <= s(38 downto 36) xor framebits;
		nState <= s5;
	
	when s5 =>
		s <= s;
		k <= k;
		i <= 1024;
		nState <= s6;
	
	when s6 =>
		lenp := 64 mod 32; -- harusnya mlen
		nState <= s7;
	
	when s7 =>
		startp := 64 - lenp; -- harusnya mlen
		nState <= s8;
	
	when s8 =>
		s((96 + lenp - 1) downto 96) <= s((96 + lenp - 1) downto 96) xor m((mlen - 1) downto startp);
		nState <= s9;
	
	when s9 =>
		c((64-1) downto startp) <= c((64-1) downto startp) xor m((64-1) downto startp);
		nState <= s10;
		
	when s10 =>
		slv_value <= std_logic_vector(to_unsigned(lenp, 2));
		s(33 downto 32) <= s(33 downto 32) xor (slv_value);
		nState <= s11;
		
	when s11 =>
	
	end case;
end process;
end encryption_arc;
