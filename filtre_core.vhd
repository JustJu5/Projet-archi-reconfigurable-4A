library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filter_pkg.all;

entity filter_core is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    enable : in  std_logic;
    -- 3x3 pixels
    p0,p1,p2,p3,p4,p5,p6,p7,p8 : in pix8;
    -- Coefficients signés
    c0,c1,c2,c3,c4,c5,c6,c7,c8 : in s8;
    -- Normalisation (0 => pas de division)
    norm_factor : in integer;
    -- Sortie
    pixel_out   : out pix8
  );
end entity;

architecture rtl of filter_core is
  signal m0,m1,m2,m3,m4,m5,m6,m7,m8 : s16;
  signal sum_s : signed(19 downto 0);
  signal sum_i : integer;
  signal out_u8 : pix8;
begin
process(clk)
  variable sum_i : integer;
begin
  if rising_edge(clk) then
    if rst = '1' then
      pixel_out <= (others => '0');
    elsif enable = '1' then
      -- Accumulation
      sum_s <= resize(m0, 20) + resize(m1, 20) + resize(m2, 20) +
               resize(m3, 20) + resize(m4, 20) + resize(m5, 20) +
               resize(m6, 20) + resize(m7, 20) + resize(m8, 20);

      -- Normalisation et saturation avec variable
      sum_i := to_integer(sum_s);
      if norm_factor > 0 then
        sum_i := sum_i / norm_factor;
      end if;
      if sum_i < 0 then sum_i := 0; end if;
      if sum_i > 255 then sum_i := 255; end if;

      pixel_out <= std_logic_vector(to_unsigned(sum_i, 8));
    end if;
  end if;
end process;

end architecture;
