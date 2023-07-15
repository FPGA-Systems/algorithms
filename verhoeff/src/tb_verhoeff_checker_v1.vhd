
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library work;
use work.all;

--online checker https://kik.amc.nl/home/rcornet/verhoeff.html
entity tb_verhoeff_checker_v1 is
end tb_verhoeff_checker_v1;

architecture sim of tb_verhoeff_checker_v1 is

    type sequence_type is array (natural range <>) of natural range 0 to 9;
    constant s0 : sequence_type := (2,3,6,3);--correct
    constant s1 : sequence_type := (0,1,0,4,2,0,1,7,3);--correct
    constant s2 : sequence_type := (1,3,2,1,5,1,8,9,1,8,1,5,1,1,3,2,1,6,5,1,9,8,7,7,8,4,6,5,1,3,2,1,6,5,4,9,8,7,9,5,6,1,3,2,1,5,6,4,8,9,4,8,4,9);--correct
    constant s3 : sequence_type := (0,9,8,1,2,3,7,4,0,9,8,1,7,5,3,4,2,0,5,9,8,7,8);--correct
    
    constant s4 : sequence_type := (2,3,6,4);--error
    constant s5 : sequence_type := (0,1,0,4,2,0,1,7,5);--error
    constant s6 : sequence_type := (1,3,2,1,5,1,8,9,1,8,1,5,1,1,3,2,1,6,5,1,9,8,7,7,8,4,6,5,1,3,2,1,6,5,4,9,8,7,9,5,6,1,3,2,1,5,6,4,8,9,4,8,4,6);--error
    constant s7 : sequence_type := (0,9,8,1,2,3,7,4,0,9,8,1,7,5,3,4,2,0,5,9,8,7,7);--error
    
    constant s8 : sequence_type := (2,3,5,3);--incorrect
    constant s9 : sequence_type := (0,1,0,3,2,0,1,7,3);--incorrect
   
    
    signal clk : std_logic := '1';
    constant clk_period : time := 10ns;
    signal reset : std_logic := '0';
    
    signal istart    : std_logic;
    signal idigit    : std_logic_vector(3 downto 0);
    signal idigit_valid : std_logic;
    signal idone     : std_logic;
    
    signal odone            : std_logic;
    signal ocorrect         : std_logic;
    signal oerror           : std_logic;
    signal oready           : std_logic;
    
    procedure execute (
        constant s : in sequence_type;
        signal start   : out std_logic;
        signal digit   : out std_logic_vector(3 downto 0);
        signal digit_valid : out std_logic;
        signal done    : out std_logic
    ) is
    
    begin
        
        start <= '0';
        digit <= (others => '0');
        digit_valid <= '0';
        done <= '0';
        
        wait for 3*clk_period;
        
        start <= '1';
        
        for i in s'reverse_range loop
            digit_valid <= '1';
            digit <= std_logic_vector(to_unsigned(s(i), digit'length));
            
            if i = 0 then done <= '1'; end if;
            
            wait for clk_period;
            start <= '0';
        end loop;
        
        done <= '0';
        digit_valid <= '0';
        digit <= std_logic_vector(to_unsigned(0, digit'length));
        
    end procedure;
begin
    
    clk <= not clk after clk_period/2;
    
    process
    begin
        wait for 10*clk_period;
        reset <= '1';
        wait for 3*clk_period;
        reset <= '0';
        
        --correct
        execute(s0, istart, idigit, idigit_valid, idone);
        execute(s1, istart, idigit, idigit_valid, idone);
        execute(s2, istart, idigit, idigit_valid, idone);
        execute(s3, istart, idigit, idigit_valid, idone);
        
        --error
        execute(s4, istart, idigit, idigit_valid, idone);
        execute(s5, istart, idigit, idigit_valid, idone);
        execute(s6, istart, idigit, idigit_valid, idone);
        execute(s7, istart, idigit, idigit_valid, idone);
        
        --incorrect
        execute(s8, istart, idigit, idigit_valid, idone);
        execute(s9, istart, idigit, idigit_valid, idone);
        
        wait;
    end process;
    
    dut: entity work.verhoeff_checker_v1(rtl)
    port map(
        iclk    => clk,
        ireset  => reset,
        
        idigit       => idigit,
        idigit_valid => idigit_valid,
        
        istart => istart,
        idone  => idone,
        
        odone          => odone,
        ocorrect       => ocorrect,
        oerror         => oerror,
        oready         => oready
    );
    
end sim;
