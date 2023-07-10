library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.all;

entity luhn_checker_v2 is
end luhn_checker_v2;

architecture tb of luhn_checker_v2 is

    signal iclk : std_logic := '1';
    signal ireset : std_logic := '0';
    signal istart : std_logic := '0';
    signal iodd_even:  std_logic := '0';
    signal idigit : std_logic_vector(3 downto 0) := (others => '0');
    signal idigit_valid : std_logic := '0';
    signal idone: std_logic := '0';
    signal oready : std_logic;
    signal ocorrect: std_logic;
    signal oerror : std_logic;
    
    constant clk_period : time := 10ns;
    
    type sequence_type is array (natural range <>) of natural range 0 to 9;
    constant s0 : sequence_type := (0,1,2,3,4,5,6);
    constant s1 : sequence_type := (4,5,6,1,2,6,1,2,1,2,3,4,5,4,6,7);--correct
    constant s2 : sequence_type := (3,0,1,1,8,9,7);--correct
    constant s3 : sequence_type := (4,6,2,1,4,6,2,6,2,6,7,2,6,7,1,6,7,6,4,6,7,4,6,1,7,6,5,2,7,6,1,6,7,2,6,4,2,1,6,7); -- incorrect
    constant s4 : sequence_type := (4,6,2,1,4,6,2,6,2,6,7,2,6,7,1,6,7,6,4,6,7,4,6,1,7,6,5,2,7,6,1,6,7,2,6,4,2,1,6,7,3); -- correct
    
    
    procedure execute  (
         s : in sequence_type;
         signal start: out std_logic;
         signal odd_even: out std_logic;
         signal digit: out std_logic_vector(3 downto 0);
         signal digit_valid: out std_logic;
         signal done: out std_logic
     ) is
    begin
        
        wait for 10*clk_period; 
        
        start <= '1';
        if ( (s'length - 1) mod 2 = 0) then
            odd_even <= '0';
        else
            odd_even <= '1';
        end if;
        
        wait for    clk_period; 
        start <= '0';
        odd_even <= '0';
        
        for i in s'range loop
            wait for clk_period;
            digit <= std_logic_vector(to_unsigned(s(i),4));
            digit_valid <= '1';
        end loop;
        
        wait for clk_period;
        digit_valid <= '0';
        done <= '1';
        digit <= std_logic_vector(to_unsigned(0,4));
        
        wait for clk_period;
        done <= '0';
        
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
        
        execute(s1, istart, iodd_even, idigit, idigit_valid, idone);
        execute(s2, istart, iodd_even, idigit, idigit_valid, idone);
        execute(s3, istart, iodd_even, idigit, idigit_valid, idone);
        execute(s4, istart, iodd_even, idigit, idigit_valid, idone);
        
        wait;
    end process;
    
    
    
    dut: entity work.luhn_check(rtl)
    port map (
        iclk           => iclk          ,
        ireset         => ireset        ,
        iodd_even =>   iodd_even,
        istart         => istart        ,
        idigit         => idigit        ,
        idigit_valid   => idigit_valid  ,
        idone          => idone,
        oready         => oready        ,
        ocorrect       => ocorrect      ,
        oerror         => oerror      
    ); 

end architecture tb;