library ieee;
use ieee.std_logic_1164.all;


entity top is
generic (
        C_WIDTH : natural := 512 --max of ia width and ib width, must be even (increase number to nearest even)    
    ); 
    port (
        iclk : in std_logic;
        ia : in std_logic_vector(C_WIDTH - 1 downto 0);
        ib : in std_logic_vector(C_WIDTH - 1 downto 0);
        oq :  out std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0);
        oq2 :  out std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0)
    );
end top;

architecture rtl of top is
    
   
    
begin
    
    karatsuba : entity work.karatsuba(rtl)
    generic map(
        C_WIDTH => C_WIDTH
    )
    port map (
        ia => ia,
        ib => ib,
        oq => oq2,
        iclk => iclk
    );
    
    native : entity work.mult(rtl)
        generic map(
            C_WIDTH => C_WIDTH
        )
        port map (
            ia => ia,
            ib => ib,
            oq => oq,
            iclk => iclk
        );

end rtl;
