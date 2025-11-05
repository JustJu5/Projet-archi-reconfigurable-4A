library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity filtre_flou is
  Port (
    clk : in std_logic;
    p0, p1, p2, p3, p4, p5, p6, p7, p8 : in std_logic_vector(7 downto 0);
    pixel_out : out std_logic_vector(7 downto 0)
  );
end filtre_flou;

architecture Behavioral of filtre_flou is
  signal stage1_sum : integer := 0;
  signal stage2_sum : integer := 0;
  signal stage3_sum : integer := 0;
  signal stage4_sum : integer := 0;
  signal stage5_sum : integer := 0;
  signal stage6_sum : integer := 0;
  signal stage_out  : integer := 0;
  signal stage3_out : std_logic_vector(7 downto 0);
begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- : addition partielle
      stage1_sum <= to_integer(unsigned(p0)) + to_integer(unsigned(p1)); 
      stage2_sum <= to_integer(unsigned(p2)) + to_integer(unsigned(p3));
      stage3_sum <=  to_integer(unsigned(p5)) + to_integer(unsigned(p6));
      stage4_sum <= to_integer(unsigned(p7)) + to_integer(unsigned(p8));

      -- ajout des pixels restants (sans p4)
      stage5_sum <= stage1_sum + stage2_sum;  
      stage6_sum <= stage3_sum + stage4_sum;
      
      stage_out <=  stage5_sum + stage6_sum ;
      
      --  division et conversion
      stage3_out <= std_logic_vector(to_unsigned(stage_out, 11)(10 downto 3));
    end if;
  end process;

  pixel_out <= stage3_out;

end Behavioral;
