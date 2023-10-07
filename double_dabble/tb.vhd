
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.all;

entity tb is

generic(
    C_NUMBER_WIDTH : natural := 64;
    C_DIGITS : natural := 19
);

end tb;

architecture behavioral of tb is
    
    
    
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal inumber :  std_logic_vector(C_NUMBER_WIDTH - 1 downto 0) := (others => '0');
    signal istart :  std_logic := '0';
    signal odigits:  std_logic_vector(C_DIGITS*4 - 1 downto 0);
    signal odone :  std_logic;
    
    constant clk_period : time := 10ns;
    signal tmp : natural ;
    
begin

    clk <= not clk after clk_period/2;
    
    process begin
    wait for 1ns;
        reset <= '0';
        wait for 3*clk_period;
        reset <= '1';
        wait for 3*clk_period;
        reset <= '0';
        
            
            wait for 10*clk_period;
            istart <= '1';
            inumber <= "0111111111111111111111111111111111111111111111111111111111111111";
            wait for clk_period;
            istart <= '0';
            
            wait on odone;
            
            
        
        
        
    end process;
    
    
    
    dut: entity work.double_dabble(rtl)
    generic map (
        C_NUMBER_WIDTH => C_NUMBER_WIDTH,
        C_DIGITS => C_DIGITS
    ) port map (
        iclk     => clk            ,       
        ireset   => reset          ,       
        inumber  => inumber        ,       
        istart   => istart         ,       
        odigits  => odigits        ,       
        odone    => odone                 
    );

end behavioral;
