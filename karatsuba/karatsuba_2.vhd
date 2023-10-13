library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity karatsuba_2 is
    generic (
        C_WIDTH : natural := 28 --max of ia width and ib width, must be even (increase number to nearest even)    
    ); 
    port (
        iclk : in std_logic;
        ia : in std_logic_vector(C_WIDTH - 1 downto 0);
        ib : in std_logic_vector(C_WIDTH - 1 downto 0);
        oq :  out std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0)
    );
--    attribute USE_DSP : string;
--    attribute USE_DSP of karatsuba_2: entity is "YES";
end karatsuba_2;

architecture rtl of karatsuba_2 is
    
    signal a_right : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --3333
    signal a_left  : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --1111
    
    signal b_right : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --5555
    signal b_left  : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --7777
             
    signal X : unsigned(C_WIDTH - 1 downto 0) := (others => '0'); -- 1111 * 5555
    signal Y : unsigned(C_WIDTH  - 1 downto 0) := (others => '0'); -- 3333 * 7777
    signal x_add_y : unsigned(C_WIDTH downto 0) := (others => '0');
    
    signal T0 : unsigned(C_WIDTH/2 downto 0):= (others => '0'); --1111 + 3333
    signal T1 : unsigned(C_WIDTH/2 downto 0):= (others => '0'); --5555 + 7777
    
    signal z : unsigned(C_WIDTH + 1 downto 0):=  (others => '0'); -- (1111 + 3333) * (5555 + 7777)
    
    signal xs2_y, xs2_y_dff : unsigned(X'length + C_WIDTH-1 downto 0) := (others => '0');
    signal zs : unsigned(Z'length + C_WIDTH/2 - 1 downto 0):=(others => '0');
    
    constant s  : unsigned(C_WIDTH/2 - 1 downto 0) :=(others => '0');
    constant s2 : unsigned(C_WIDTH   - 1 downto 0) :=(others => '0');
    
--    attribute USE_DSP : string;
--    attribute USE_DSP of x_add_y: signal is "YES";

begin
     
    karatsuba_mult : process(iclk) begin
        if rising_edge(iclk) then
            a_right <= unsigned(ia(ia'length / 2 - 1 downto 0));
            a_left  <= unsigned(ia(ia'length - 1 downto ia'length / 2));
            b_right <= unsigned(ib(ib'length / 2 - 1 downto 0));
            b_left  <= unsigned(ib(ib'length - 1 downto ib'length / 2));
            
            X <= a_left * b_left;            
            Y <= a_right * b_right;
            T0 <= ('0' & a_left) + ('0'& a_right);
            T1 <= ('0' & b_left) + ('0'& b_right);
            
            z <=  T0 * T1;           
            x_add_y <= ('0' & X) + ('0' & Y);
            xs2_y <= (x & s2 ) + Y;
            
            zs <= (z - x_add_y)&s;
            xs2_y_dff <= xs2_y;
            
            oq <= std_logic_vector(zs + xs2_y_dff);
          end if;
    end process;
    
end rtl;
