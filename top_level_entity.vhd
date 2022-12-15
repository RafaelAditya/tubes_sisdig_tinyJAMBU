library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all; 
use work.all;

entity top_level_entity is 
    port(
        io_text : inout std_logic_vector(127 downto 0);
        key : in std_logic_vector(127 downto 0);
        nonce : in std_logic_vector(95 downto 0);
        sel_ed : in std_logic;

        tag : out std_logic_vector(63 downto 0)
    );
end top_level_entity;

architecture top_level_entity_arc of top_level_entity is

-- komponen initialization
component initialization is
    port(
        clk, rst, proceed : IN std_logic;
	    s: inout std_logic_vector(127 downto 0);
	    nonce: IN std_logic_vector(95 downto 0);
	    feedback : inout std_logic
    );
end component;

-- komponen proses-ad
component process_ad is
    port(
        ad : in std_logic_vector (63 downto 0); -- ini harusnya adlen
        clk, rst, proceed : IN std_logic;
        s: inout std_logic_vector(127 downto 0)
    );
end component;

-- komponen enkripsi
component encryption is
    port(
        clk, rst, proceed : IN std_logic;
		s: inout std_logic_vector(127 downto 0);
		m: IN std_logic_vector(63 downto 0); -- ini harusnya mlen
		c: inout std_logic_vector(63 downto 0)
    );
end component;

-- komponen finalisasi
component finalization is
    port(
        signal clk, rst, proceed : IN std_logic;
		signal s: inout std_logic_vector(127 downto 0);
		signal t: out std_logic_vector(63 downto 0)
    );
end component;

-- komponen dekripsi
component decryption is
    port(
        clk, rst, proceed : IN std_logic;
	    s: inout std_logic_vector(127 downto 0);
	    c: in std_logic_vector(63 downto 0);
	    m: inout std_logic_vector(63 downto 0)
    );
end component;

-- komponen verifikasi
component verification is
    port(
        clk, rst, proceed : IN std_logic;
	    s: inout std_logic_vector(127 downto 0);
	    t: in std_logic_vector(63 downto 0);
		t_aksen: inout std_logic_vector(63 downto 0)
    );
end component;

    type states is (init, s0, s1, s2, s3, s4, s5)
	signal nState, cState : states;
	signal i : integer;
	signal k : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0);
	signal feedback : std_logic;

    process(rst, clk)
	begin
	if (rst = '1') then
		cState <= init;
	elsif( clk'event and clk = '1' ) then
		cState <= nState;
	end if;
	end process;
	
	process( proceed, cState )
	-- variable j : integer := 0;
	-- variable lenp : integer;
	-- variable startp: integer; 
	-- variable mlen: integer := 64;
	begin 
	case cState is 

	when init => 
		if (proceed = '0') then
			nState <= init;
		else
            if sel_ed = '0' then
			    nState <= s0;
            else
                nState <= s4;
            end if;
		end if;
    
    when s0 =>
        toinitial : initialization port map (clk, rst, proceed, s, nonce, feedback);
        nState <= s1;
    
    when s1 =>
        toprocessad : process_ad port map (ad, clk, rst, proceed, s);
        nState <= s2;
    
    when s2 =>
        toencryption : encryption port map (clk, rst, proceed, s, m, c);
        nState <= s3;
    
    when s3 =>
        tofinalization : finalization port map (signal clk, signal rst, signal proceed , signal s, signal t);
    
    when s4 =>
        todecryption : decryption port map (clk, rst, proceed, s, c, m);
        nState <= s5;
    
    when s5 =>
        toverification : verification port map (clk, rst, proceed, s, t, t_aksen);

    end case;
    end process;
end top_level_entity_arc;
