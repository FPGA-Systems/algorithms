library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity karatsuba is
    generic (
        C_WIDTH : natural := 128 --max of ia width and ib width, must be even (increase number to nearest even)    
    ); 
    port (
        iclk : in std_logic;
        ia : in std_logic_vector(C_WIDTH - 1 downto 0);
        ib : in std_logic_vector(C_WIDTH - 1 downto 0);
        oq :  out std_logic_vector(C_WIDTH + C_WIDTH - 1 downto 0)
    );
end karatsuba;

architecture rtl of karatsuba is

    signal a : std_logic_vector(ia'range) := (others => '0');
    signal b : std_logic_vector(ib'range) := (others => '0');
    
    --ia = 1111_3333
    signal a_right : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --3333
    signal a_left  : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --1111
    
    --ib = 5555_7777
    signal b_right : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --5555
    signal b_left  : unsigned(C_WIDTH / 2 - 1 downto 0) := (others => '0'); --7777
             
    signal y, y_dff1, y_dff2, y_dff3 : unsigned(a_right'length + b_right'length - 1 downto 0) := (others => '0'); -- 1111 * 5555
    signal x, x_dff1, x_dff2 : unsigned(a_left'length  + b_left'length  - 1 downto 0) := (others => '0'); -- 3333 * 7777
    
    signal x_scaled, x_scaled_dff1, x_scaled_dff2: unsigned(x'length + a_left'length + b_left'length - 1 downto 0):= (others => '0');
    
    signal a_res : unsigned(a_left'length downto 0):= (others => '0'); --1111 + 3333
    signal b_res : unsigned(b_left'length downto 0):= (others => '0'); --5555 + 7777
    signal z : unsigned(a_res'length + b_res'length - 1 downto 0):=  (others => '0'); -- (1111 + 3333) * (5555 + 7777)
    
    signal z_part : unsigned(z'range)  :=  (others => '0'); 
    signal z_scaled: unsigned(z_part'length + C_WIDTH / 2 - 1 downto 0) :=  (others => '0');
    signal l : unsigned(3 downto 0); 
    signal ll : unsigned(2 downto 0) := b"111";
    signal lr : unsigned(2 downto 0) := b"111";
begin
     
    karatsuba_mult : process(iclk) begin
        if rising_edge(iclk) then
            a_right <= unsigned(ia(ia'length / 2 - 1 downto 0));
            a_left  <= unsigned(ia(ia'length - 1 downto ia'length / 2));
            
            b_right <= unsigned(ib(ib'length / 2 - 1 downto 0));
            b_left  <= unsigned(ib(ib'length - 1 downto ib'length / 2));
            
            x <= a_left * b_left;            
            x_dff1 <= x;
            x_dff2 <= x_dff1;
            
            y <= a_right * b_right;
            y_dff1 <= y;
            y_dff2 <= y_dff1;
            y_dff3 <= y_dff2;
            
            a_res <= resize(('0' & a_left) + ('0'& a_right),a_res'length);
            b_res <= resize(('0' & b_left) + ('0'& b_right),b_res'length);
            
            z <=  a_res * b_res;           
            
            z_part <= z - x_dff1 - y_dff1;
            
            x_scaled(x_scaled'left downto x_scaled'length-x'length) <= x;
            x_scaled_dff1 <= x_scaled;
            x_scaled_dff2 <= x_scaled_dff1;
            
            z_scaled(z_scaled'left downto z_scaled'length-z'length) <= z_part;
            
            oq <= std_logic_vector(x_scaled_dff2 + z_scaled + y_dff3);
            
          end if;
    end process;
    
end rtl;
