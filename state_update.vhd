Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity state_update is
port( 
	s : IN std_logic_vector(127 downto 0);
	k : IN std_logic_vector(127 downto 0);
	rst, clk, proceed: IN std_logic;
	i : IN integer;
	
	feedback : out std_logic;
);
end state_update;

architecture state_update_arc of state_update is
	type states is (init, s0, s1, s2);
	signal nState, cState : states;
	j : integer := 0;

begin
	process(rst, clk)
	begin
	if (rst = '1') then
		cState <= init;
	elsif( clk'event and clk = '1' ) then
		cState <= nState;
	end if;
	end process;
	
	process( proceed, cState )
	begin
	case cState is
	
	when init => 
		if (proceed = '0') then
			nState <= init;
		else
			nState <= s0;
		end if;
	
	when s0 =>
		feedback <= s(0) xor s(47) xor (not(s(70) and s(85))) xor s(91) xor k(i mod 128) 
		nState <= s1;
	
	when s1 =>
		for j in 0 to 126 loop
			s(j) <= s(j+1);
		end loop
		nState <= s2;
	
	when s2 => 
		s(127) <= feedback;
	end case;
	
end state_update_arc;	