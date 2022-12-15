library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.std_logic_arith.all; 
use IEEE.std_logic_unsigned.all; 
use work.all;

entity top_level_entity is 
    port(
	clk, rst, proceed : in std_logic;
        io_text : inout std_logic_vector(127 downto 0);
        key : in std_logic_vector(127 downto 0);
        nonce : in std_logic_vector(95 downto 0);
        sel_ed : in std_logic;

        tag : out std_logic_vector(63 downto 0)
    );
end top_level_entity;

architecture top_level_entity_arc of top_level_entity is
	signal i : integer;
	signal k : std_logic_vector(127 downto 0);
	signal framebits: std_logic_vector(2 downto 0);
	signal feedback : std_logic;
signal ad: STD_LOGIC_VECTOR(63 downto 0);
signal t: STD_LOGIC_VECTOR(63 downto 0);
signal s: STD_LOGIC_VECTOR(127 downto 0);
signal m: STD_LOGIC_VECTOR(63 downto 0);
signal c: STD_LOGIC_VECTOR(63 downto 0);
signal t_aksen: STD_LOGIC_VECTOR(63 downto 0);

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

begin 

        toinitial : initialization port map (clk, rst, proceed, s, nonce, feedback);
        toprocessad : process_ad port map (ad, clk, rst, proceed, s);
        toencryption : encryption port map (clk, rst, proceed, s, m, c);
        tofinalization : finalization port map ( clk,  rst,  proceed ,  s,  t);
       	todecryption : decryption port map (clk, rst, proceed, s, c, m);
        toverification : verification port map (clk, rst, proceed, s, t, t_aksen);

end top_level_entity_arc;
