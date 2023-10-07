
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity shift_add_3 is
    port (
        iclk : in  std_logic;
        ireset : in std_logic;
        ishift : in std_logic;
        iadd   : in std_logic;
        id     : in std_logic;
        oq      : out std_logic;
        odigit  : out std_logic_vector(3 downto 0)
    );
end shift_add_3;

architecture rtl of shift_add_3 is
    
    signal sr : std_logic_vector(3 downto 0) := (others => '0');
    
begin
    
    process(iclk) begin
        if rising_edge(iclk) then
            if (ireset = '1') then
                sr <= (others => '0');
            else
               if (ishift = '1') then 
                    sr(0) <= id;
                    sr(1) <= sr(0);
                    sr(2) <= sr(1);
                    sr(3) <= sr(2);
               end if;
               
               if (iadd = '1') then
                    if (sr > 4) then
                        sr <= sr + "11";
                    end if;
               end if;                
            
            end if;
        end if;
    
    end process;

    oq <= sr(3);
    odigit <= sr;
    
end rtl;
