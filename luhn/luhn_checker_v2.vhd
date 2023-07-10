
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity luhn_checker_v2 is
    port (
        iclk : in std_logic;
        ireset : in std_logic;
        istart : in std_logic; --set pulse, like write enable, for current checking sequence
                                           --used as start signal
        iodd_even: in std_logic; --is it even or odd number of digits in sequence, exclude control number
        idigit: in std_logic_vector(3 downto 0); --current digit in sequence
        idigit_valid: in std_logic; --valid signal for new digit
        idone: in std_logic; --done with number, rise up when all numbers include control uploaded
        
        oready  : out std_logic; --ready to receive next digit
        ocorrect: out std_logic; --checked number is correct ('1' - correct)
        oerror  : out std_logic; --checked number is incorrect ('1' - incorrect)
        odone   : out std_logic  --complete computation
    );
end luhn_checker_v2;

architecture rtl of luhn_checker_v2 is
    
    type rom is array (0 to 9) of natural range 0 to 9;
    --Luhn algorith requires double the value of digits, if result more then 9 => add digits
    --example 
    -- 2   3   4   5   6
    -- 2x2 3x2 4x2 5x2 6x2
    -- 4   6   8   10  12
    -- 4   6   8   1+0 1+2
    -- 4   6   8   1   3  -> this result
    -- To skip arithmetic computation we place result in table,
    --0x2 = 0              
    --1x2 = 2              
    --2x2 = 4              
    --3x2 = 6              
    --4x2 = 8              
    --5x2 = 10 => 1 + 0 = 1
    --6x2 = 12 => 1 + 2 = 3
    --7x2 = 14 => 1 + 4 = 5
    --8x2 = 16 => 1 + 6 = 7
    --9x2 = 18 => 1 + 8 = 9
    constant luhn_rom: rom := (0, 2, 4, 6, 8, 1, 3, 5, 7, 9 );
    
    --save temporaly result of sums
    --
    --Important notice
    --Instead of finding mod10 of result after computation
    --we will substract 10 every time when tmp is more then 10
    --Thanks Evgeny Sidelnikov for this genious solution!
    --
    signal tmp: natural range 0 to 31;
    
    --main manager 
    type state_type is (s0, s1, s2, s3, s4, s5, s6);
    signal state : state_type := s0;
    
begin
    
    
    
    process(iclk) begin
        if rising_edge(iclk) then
            if ireset = '1' then
                state <= s0;
                tmp <= 0;
                oready <= '1';
                oerror <= '0';
                ocorrect <= '0';
                odone    <= '0';
            else 
               case (state) is
                    when s0 =>
                        
                        oready <= '1';
                        oerror <= '0';
                        ocorrect <= '0';
                        tmp <= 0;
                        odone    <= '0';
                        
                        if istart = '1' then
                        
                            if idigit_valid = '1' then
                                tmp <= tmp + luhn_rom(to_integer(unsigned(idigit)));
                            end if;
                        
                            --check even or odd digits in sequence !!!whitout control digit
                            if iodd_even = '0' then -- even
                                state <= s3;
                            else
                                state <= s2;
                            end if;
                        end if;
                        
                        when s2 => 
                            if idigit_valid = '1' then
                                if tmp > 10 then
                                    tmp <= tmp + luhn_rom(to_integer(unsigned(idigit))) - 10;
                                else
                                    tmp <= tmp + luhn_rom(to_integer(unsigned(idigit)));
                                end if;
                                
                                state <= s3;
                             end if;
                             
                             if idone = '1' then
                               oready <= '0';
                               state <= s4;
                             end if;
                            
                        when s3 => --skip digit
                            if idigit_valid = '1' then
                               
                                if tmp > 10 then
                                    tmp <= tmp + to_integer(unsigned(idigit)) - 10;
                                else
                                    tmp <= tmp + to_integer(unsigned(idigit));
                                end if;
                                state <= s2;
                            end if;
                            
                            if idone = '1' then
                               oready <= '0';
                               state <= s4;
                            end if;
                            
                        when s4 =>
                        oready <= '0';
                        odone <= '1';
                         if tmp = 0 or tmp = 10 then
                            ocorrect <= '1';
                         else
                            oerror <= '1';
                         end if;
                         state <= s0;
                        
                    when others => state <= s0;
               end case;
            end if;
        end if;
    end process;

end rtl;
