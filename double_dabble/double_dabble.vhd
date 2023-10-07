
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.all;

entity double_dabble is
generic(
    C_NUMBER_WIDTH : natural := 8;
    C_DIGITS : natural := 3
);
  port (
    iclk            : in std_logic;
    ireset          : in std_logic;
    inumber         : in std_logic_vector(C_NUMBER_WIDTH - 1 downto 0);
    istart          : in std_logic;
    odigits         : out std_logic_vector(C_DIGITS*4 - 1 downto 0);
    odone           : out std_logic
  );
end double_dabble;

architecture rtl of double_dabble is
    
    type state_type is (s0, s1, s2, s3, s4, s5);
    signal state : state_type := s0;
    
    signal k: natural range inumber'range;
    
    signal shift    : std_logic := '0';
    signal add      : std_logic := '0';
    signal clear    : std_logic := '0';
    signal from_to  : std_logic_vector(C_DIGITS downto 0) := (others => '0');
    
    signal sreg : std_logic_vector(inumber'range):= (others => '0');
begin
    from_to(0) <= sreg(C_NUMBER_WIDTH-1);
    s: for i in C_DIGITS-1 downto 0 generate
        sr: entity work.shift_add_3(rtl) 
        port map(
            iclk   => iclk,
            ireset => clear,
            ishift => shift,
            iadd   => add,
            id     => from_to(i),
            oq     => from_to(i+1),
            odigit => odigits(i*4 +3 downto i*4)
        );
    end generate;
    
    process(iclk) begin
        if rising_edge(iclk) then
            if ireset = '1' then
                state <= s0;
                shift <= '0';
                add <= '0';
                k <= 0;
                clear <= '0';
            else
                case state is
                    when s0 =>
                    
                        shift   <= '0';
                        add     <= '0';
                        k       <= 0;
                        clear   <= '1';
                        odone   <= '0';
                        
                        if istart = '1' then
                            clear   <= '0';
                            state <= s1;
                        end if;
                        
                    when s1 => --shift
                       add <= '0';
                       shift <= '1';
                       
                       if k = C_NUMBER_WIDTH-1  then
                            state  <= s3;
                       else 
                            k <= k + 1;
                            state <= s2; 
                       end if;
                       
                     when s2 => --add
                         add <= '1';
                         shift <= '0'; 
                         state <= s1;
                         
                    when s3 =>
                        odone <= '1';
                        shift <= '0';
                        state <= s0;
                          
                    when others => state <= s0;
                end case;
            
            end if;
        end if;
    end process;
    
    process (iclk) begin
        if rising_edge(iclk) then
            if istart = '1' then
                sreg <= inumber;
            else
                if shift = '1' then
                    for i in C_NUMBER_WIDTH-1 downto 1 loop
                        sreg(i) <= sreg(i-1);
                    end loop;
                    sreg(0) <= '0';
                end if;
            end if;  
        end if;     
    end process;
end rtl;
