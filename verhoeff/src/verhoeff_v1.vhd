
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity verhoeff_v1 is
    port (
        iclk    : in std_logic;
        ireset  : in std_logic;
        
        idigit  : in std_logic_vector(3 downto 0);
        idigit_valid    : in std_logic;
        
        istart  : in std_logic;
        idone    : in std_logic;
        
        odone   : out std_logic;
        ocontrol_digit  : out std_logic_vector(3 downto 0);
        oready  : out std_logic
    );
end verhoeff_v1;

architecture rtl of verhoeff_v1 is
    
    type num_type is array (0 to 9) of natural range 0 to 9;
    type p_type is array  (0 to 7) of num_type;
        
    signal p: p_type := (
        (0,	1,	2,	3,	4,	5,	6,	7,	8,	9),
        (1,	5,	7,	6,	2,	8,	3,	0,	9,	4),
        (5,	8,	0,	3,	7,	9,	6,	1,	4,	2),
        (8,	9,	1,	6,	0,	4,	3,	5,	2,	7),
        (9,	4,	5,	3,	1,	2,	6,	8,	7,	0),
        (4,	2,	8,	6,	5,	7,	3,	9,	0,	1),
        (2,	7,	9,	3,	8,	0,	6,	4,	1,	5),
        (7,	0,	4,	6,	9,	1,	3,	2,	5,	8)
    );
    
    type d_type is array (0 to 9) of num_type;
    signal d : d_type := (
        (0,	1,	2,	3,	4,	5,	6,	7,	8,	9),
        (1,	2,	3,	4,	0,	6,	7,	8,	9,	5),
        (2,	3,	4,	0,	1,	7,	8,	9,	5,	6),
        (3,	4,	0,	1,	2,	8,	9,	5,	6,	7),
        (4,	0,	1,	2,	3,	9,	5,	6,	7,	8),
        (5,	9,	8,	7,	6,	0,	4,	3,	2,	1),
        (6,	5,	9,	8,	7,	1,	0,	4,	3,	2),
        (7,	6,	5,	9,	8,	2,	1,	0,	4,	3),
        (8,	7,	6,	5,	9,	3,	2,	1,	0,	4),
        (9,	8,	7,	6,	5,	4,	3,	2,	1,	0)
    );
    
    signal inv: num_type := (0, 4, 3, 2, 1, 5, 6, 7, 8, 9);
    
    type state_type is (s0, s1, s2, s3, s4);
    signal state : state_type := s0;
    
    signal k : std_logic_vector(2 downto 0) := b"001";
    
    signal c : natural range 0 to 9 := 0;
    
begin

    process(iclk)
        variable p_value : natural range 0 to 9;
    begin
        
        if rising_edge(iclk) then
            if ireset = '1' then
                odone <= '0';
                ocontrol_digit <= (others => '0');
                oready <= '1';
                
                state <= s0;
                k <= b"001";
                c <= 0;
            else
                
                case state is
                    when s0 =>
                        k <= b"001";
                        odone <= '0';
                        ocontrol_digit <= (others => '0');
                        oready <= '1';
                        c <= 0;
                        
                        if istart = '1' then
                            if idigit_valid = '1' then
                                p_value := p(to_integer(unsigned(k)))
                                            (to_integer(unsigned(idigit)));
                                
                                c <= d(c)(p_value);
                                k <= k + '1';
                                
                            end if;
                            
                            state <= s1;
                        end if;
                        
                   when s1 =>
                        if idone = '1' then
                            oready <= '0';
                            state <= s2;
                        end if;
                        
                        if idigit_valid = '1' then
                            p_value := p(to_integer(unsigned(k)))
                                        (to_integer(unsigned(idigit)));
                            
                            c <= d(c)(p_value);
                            k <= k + '1';
                        end if;
                        
                    when s2 => 
                        ocontrol_digit <= std_logic_vector(to_unsigned(inv(c),ocontrol_digit'length));
                        odone <= '1';
                        state <= s0;
                        
                    when others =>  state <= s0;
                end case;
                
            end if;
        end if;
    end process;
end rtl;
