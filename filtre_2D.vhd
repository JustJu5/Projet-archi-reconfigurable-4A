library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtre_2D is
  Port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    enable : in STD_LOGIC;
    p0,p1,p2,p3,p4,p5,p6,p7,p8: in std_logic_vector(7 downto 0);
    result : out STD_LOGIC_VECTOR(7 downto 0)
  );
end filtre_2D;

architecture Behavioral of filtre_2D is
  signal sum : unsigned(13 downto 0); 
  signal avg : unsigned(7 downto 0);
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sum <= (others => '0');
        avg <= (others => '0');
        result <= (others => '0');
      elsif enable = '1' then
        -- Somme des 9 pixels
        sum <= unsigned(p0) + unsigned(p1) + unsigned(p2) +
               unsigned(p3) + unsigned(p4) + unsigned(p5) +
               unsigned(p6) + unsigned(p7) + unsigned(p8);

        -- Division par 9 (approximation par décalage n'est pas possible, on fait division entière)
        avg <= sum / 9;
        result <= std_logic_vector(avg);
      end if;
    end if;
  end process;
end Behavioral;