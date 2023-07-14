
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity luhn_checker_v1 is
    port (
        iclk : in std_logic;
        ireset : in std_logic;
        inum_of_digits: std_logic_vector(10 downto 0); --how much digits in checking number !!!whitout control digit
        istart : in std_logic; --set pulse, like write enable, for current checking sequence
                                           --used as start signal
        idigit: in std_logic_vector(3 downto 0); --current digit in sequence
        idigit_valid: in std_logic; --valid signal for new digit
        
        oready  : out std_logic; --ready to receive next digit
        ocorrect: out std_logic; --checked sequence is correct ('1' - correct)
        oerror  : out std_logic; --checked sequence is incorrect ('1' - incorrect)
        odone   : out std_logic  --complete computation
    );
end luhn_checker_v1;

architecture rtl of luhn_checker_v1 is
    
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
    signal tmp: natural range 0 to 31;--need to set correct tmp width to exclude overflow
    
    --main manager 
    type state_type is (s0, s1, s2, s3, s4, s5, s6);
    signal state : state_type := s0;
    
    signal k: natural range 0 to 2**inum_of_digits'left - 1 := 0; --current index of checking digit
    
begin
    
    --
    --Important notice
    --Instead of finding mod10 of result after computation
    --we will substract 10 every time when tmp is more then 10
    --Thanks Evgeny Sidelnikov for this genious solution!
    --
    
    process(iclk) begin
        if rising_edge(iclk) then
            if ireset = '1' then
                state <= s0;
                tmp <= 0;
                k <= 0;
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
                        k <= 0;
                        tmp <= 0;
                        odone    <= '0';
                        
                        if istart = '1' then
                        
                            
                        
                            --check even or odd digits in sequence !!!whitout control digit
                            if inum_of_digits(0) = '0' then -- even
                                if idigit_valid = '1' then
                                    tmp <= to_integer(unsigned(idigit));
                                    k <= k + 1;
                                    state <= s1;
                                else
                                    state <= s2;
                                end if;
                                
                                
                            else
                                if idigit_valid = '1' then
                                    tmp <= luhn_rom(to_integer(unsigned(idigit)));
                                    k <= k + 1;
                                    state <= s2;
                                else
                                    state <= s1;
                                end if;
                                
                            end if;
                        end if;
                        
                        when s1 => 
                            if idigit_valid = '1' then
                                if tmp > 10 then
                                    tmp <= tmp + luhn_rom(to_integer(unsigned(idigit))) - 10;
                                else
                                    tmp <= tmp + luhn_rom(to_integer(unsigned(idigit)));
                                end if;
                                
                                k <= k + 1;
                                
                                if k = to_integer(unsigned(inum_of_digits)) then
									oready <= '0';                                    
									state <= s3;
                                else
                                    state <= s2;                                
                                end if;
                                
                                
                            end if;
                            
                        when s2 => --skip digit
                            if idigit_valid = '1' then
                                k <= k + 1;
                                
                                if tmp > 10 then
                                    tmp <= tmp + to_integer(unsigned(idigit)) - 10;
                                else
                                    tmp <= tmp + to_integer(unsigned(idigit));
                                end if;
                                
                                
                                if k = to_integer(unsigned(inum_of_digits)) then
                                    oready <= '0';
                                    state <= s3;
                                else
                                    state <= s1;                                
                                end if;
                                
                                
                            end if;
                            
                        when s3 =>
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
