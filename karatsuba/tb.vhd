library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture behavioral of tb is
    constant C_WIDTH : natural := 28;--max of ia width and ib width, must be even (increase number to nearest even)
    signal ia : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
    signal ib : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
    signal oq, oq2, oq_dff, oq_dff2, oq_dff3, oq_dff4 : std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0) := (others => '0');
    
    
    signal iclk : std_logic := '0';
    
    constant clk_period : time := 10ns;
    
    signal error : std_logic := '0';
    
begin
    
    iclk <= not iclk after clk_period/2;
    
    dut : entity work.karatsuba_2(rtl)
    generic map(
        C_WIDTH => C_WIDTH
    )
    port map (
        ia => ia,
        ib => ib,
        oq => oq2,
        iclk => iclk
    );
    
    golden : entity work.mult(rtl)
        generic map(
            C_WIDTH => C_WIDTH
        )
        port map (
            ia => ia,
            ib => ib,
            oq => oq,
            iclk => iclk
        );
    
    process  begin
        wait for 250ns;
        ia <= std_logic_vector(to_unsigned(11118_3333, ia'length));
        ib <= std_logic_vector(to_unsigned(5555_7777, ib'length));
        wait for clk_period;
        
        
        
        ia <= (others => '0');
        ib <= (others => '0');
        wait;
    end process;
    
    process (iclk) begin
        if falling_edge(iclk) then
            if (oq_dff3 /= oq2) then
                error <= '1';
            else
                error <= '0';
            end if;
        end if;
    end process;
    
    
    process (iclk) begin
            if rising_edge(iclk) then
                oq_dff <= oq;
                oq_dff2 <= oq_dff;
                oq_dff3 <= oq_dff2;
            end if;
        end process;
end behavioral;
