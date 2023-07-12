library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.all;

entity tb_luhn_checker_v1 is
end tb_luhn_checker_v1;

architecture tb of tb_luhn_checker_v1 is

    signal iclk : std_logic := '1';
    signal ireset : std_logic := '0';
    signal inum_of_digits: std_logic_vector(10 downto 0);
    signal istart : std_logic := '0';
    signal idigit : std_logic_vector(3 downto 0) := (others => '0');
    signal idigit_valid : std_logic := '0';
    signal oready : std_logic;
    signal ocorrect: std_logic;
    signal oerror : std_logic;
    
    constant clk_period : time := 10ns;
    
    type sequence_type is array (natural range <>) of natural range 0 to 9;
    constant s0 : sequence_type := (0,1,2,3,4,5,6);--incorrect
    constant s1 : sequence_type := (4,5,6,1,2,6,1,2,1,2,3,4,5,4,6,7);
    constant s2 : sequence_type := (3,0,1,1,8,9,7);
    constant s3 : sequence_type := (4,6,2,1,4,6,2,6,2,6,7,2,6,7,1,6,7,6,4,6,7,4,6,1,7,6,5,2,7,6,1,6,7,2,6,4,2,1,6,7);
    constant s4 : sequence_type := (4,6,2,1,4,6,2,6,2,6,7,2,6,7,1,6,7,6,4,6,7,4,6,1,7,6,5,2,7,6,1,6,7,2,6,4,2,1,6,7,3);
    constant s5 : sequence_type := (7,4,1,2,3,3,1);--correct
    
    
    procedure execute  (
         s : in sequence_type;
         signal start: out std_logic;
         signal num_of_digits: out std_logic_vector(10 downto 0);
         signal digit: out std_logic_vector(3 downto 0);
         signal digit_valid: out std_logic
     ) is
    begin
        
        wait for 10*clk_period;
        start <= '1';
        num_of_digits <= std_logic_vector(to_unsigned(s'length-1, 11));
        --wait for    clk_period; 
        
        for i in s'range loop
            
            digit <= std_logic_vector(to_unsigned(s(i),4));
            digit_valid <= '1';
            wait for clk_period;
            start <= '0';
        end loop;
        
        wait for clk_period;
        digit_valid <= '0';
        digit <= std_logic_vector(to_unsigned(0,4));
        
        
    end procedure;
    
    procedure execute_delayed_data  (
         s : in sequence_type;
         signal start: out std_logic;
         signal num_of_digits: out std_logic_vector(10 downto 0);
         signal digit: out std_logic_vector(3 downto 0);
         signal digit_valid: out std_logic
     ) is
    begin
        
        wait for 10*clk_period;
        start <= '1';
        num_of_digits <= std_logic_vector(to_unsigned(s'length-1, 11)); 
        
        wait for clk_period;
        start <= '0';
        
        wait for 2*clk_period;
           
        for i in s'range loop
            wait for clk_period;
            digit <= std_logic_vector(to_unsigned(s(i),4));
            digit_valid <= '1';
            
        end loop;
        
        wait for clk_period;
        digit_valid <= '0';
        digit <= std_logic_vector(to_unsigned(0,4));
        
        
    end procedure;
    
begin
    
    --https://www.dcode.fr/luhn-algorithm
    --test sequence 301189 control digit 7
    --will check 3011897  
    
    iclk <= not iclk after clk_period/2;
    
    
    
    process
    begin
        wait for 10*clk_period;
        ireset <= '1';
        wait for 3*clk_period;
        ireset <= '0';
        
--        execute(s0, istart, inum_of_digits, idigit, idigit_valid);
--        execute(s1, istart, inum_of_digits, idigit, idigit_valid);
--        execute(s2, istart, inum_of_digits, idigit, idigit_valid);
--        execute(s3, istart, inum_of_digits, idigit, idigit_valid);
--        execute(s4, istart, inum_of_digits, idigit, idigit_valid);
        
        execute(s0, istart, inum_of_digits, idigit, idigit_valid);
        execute_delayed_data(s0, istart, inum_of_digits, idigit, idigit_valid);
        
        execute(s1, istart, inum_of_digits, idigit, idigit_valid);
        execute_delayed_data(s1, istart, inum_of_digits, idigit, idigit_valid);

        execute(s5, istart, inum_of_digits, idigit, idigit_valid);
        execute_delayed_data(s5, istart, inum_of_digits, idigit, idigit_valid);
        wait;
    end process;
    
    
    
    dut: entity work.luhn_checker_v1(rtl)
    port map (
        iclk           => iclk          ,
        ireset         => ireset        ,
        inum_of_digits => inum_of_digits,
        istart         => istart        ,
        idigit         => idigit        ,
        idigit_valid   => idigit_valid  ,
        oready         => oready        ,
        ocorrect       => ocorrect      ,
        oerror         => oerror      
    ); 

end architecture tb;