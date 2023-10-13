library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity mult is
    generic (
        C_WIDTH : natural := 128 --max of ia width and ib width, must be even (increase number to nearest even)    
    ); 
    port (
        iclk : in std_logic;
        ia : in std_logic_vector(C_WIDTH - 1 downto 0);
        ib : in std_logic_vector(C_WIDTH - 1 downto 0);
        oq : out std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0)
    );
end mult;

architecture rtl of mult is

    signal a : std_logic_vector(ia'range) := (others => '0');
    signal b : std_logic_vector(ib'range) := (others => '0');
    
    
    --delay for test with karatsuba algorith
    signal q, q_dff1, q_dff2, q_dff3, q_dff4 : std_logic_vector(oq'range) := (others => '0');
    
begin
    
    pure_mult: process(iclk) begin
        if rising_edge(iclk) then
            a <= ia;
            b <= ib;
            
            oq <= a * b;
--            q_dff1 <= q;
--            q_dff2 <= q_dff1;
--            q_dff3 <= q_dff2;
--            oq <= q_dff3;
        end if;
    end process;
    
    
    
end rtl;
