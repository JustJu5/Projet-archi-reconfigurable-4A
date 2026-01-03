library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filter_pkg.all;

entity filter_wrapper is
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    enable     : in  std_logic;
    filter_sel : in  unsigned(2 downto 0); -- 0..4
    p0,p1,p2,p3,p4,p5,p6,p7,p8 : in pix8;
    pixel_out  : out pix8
  );
end entity;

architecture struct of filter_wrapper is
  signal c0,c1,c2,c3,c4,c5,c6,c7,c8 : s8;
  signal norm : integer;
begin
  -- Sélection des coefficients
  process(filter_sel)
    variable sel : integer := to_integer(filter_sel);
  begin
    case sel is
      when 0 =>
        c0 <= COEFF_AVG_RING(0); c1 <= COEFF_AVG_RING(1); c2 <= COEFF_AVG_RING(2);
        c3 <= COEFF_AVG_RING(3); c4 <= COEFF_AVG_RING(4); c5 <= COEFF_AVG_RING(5);
        c6 <= COEFF_AVG_RING(6); c7 <= COEFF_AVG_RING(7); c8 <= COEFF_AVG_RING(8);
        norm <= NORM_AVG_RING;
      when 1 =>
        c0 <= COEFF_AVG_ALL(0); c1 <= COEFF_AVG_ALL(1); c2 <= COEFF_AVG_ALL(2);
        c3 <= COEFF_AVG_ALL(3); c4 <= COEFF_AVG_ALL(4); c5 <= COEFF_AVG_ALL(5);
        c6 <= COEFF_AVG_ALL(6); c7 <= COEFF_AVG_ALL(7); c8 <= COEFF_AVG_ALL(8);
        norm <= NORM_AVG_ALL;
      when 2 =>
        c0 <= COEFF_SOBEL_H(0); c1 <= COEFF_SOBEL_H(1); c2 <= COEFF_SOBEL_H(2);
        c3 <= COEFF_SOBEL_H(3); c4 <= COEFF_SOBEL_H(4); c5 <= COEFF_SOBEL_H(5);
        c6 <= COEFF_SOBEL_H(6); c7 <= COEFF_SOBEL_H(7); c8 <= COEFF_SOBEL_H(8);
        norm <= NORM_SOBEL_H;
      when 3 =>
        c0 <= COEFF_SOBEL_V(0); c1 <= COEFF_SOBEL_V(1); c2 <= COEFF_SOBEL_V(2);
        c3 <= COEFF_SOBEL_V(3); c4 <= COEFF_SOBEL_V(4); c5 <= COEFF_SOBEL_V(5);
        c6 <= COEFF_SOBEL_V(6); c7 <= COEFF_SOBEL_V(7); c8 <= COEFF_SOBEL_V(8);
        norm <= NORM_SOBEL_V;
      when others =>
        c0 <= COEFF_GAUSS(0); c1 <= COEFF_GAUSS(1); c2 <= COEFF_GAUSS(2);
        c3 <= COEFF_GAUSS(3); c4 <= COEFF_GAUSS(4); c5 <= COEFF_GAUSS(5);
        c6 <= COEFF_GAUSS(6); c7 <= COEFF_GAUSS(7); c8 <= COEFF_GAUSS(8);
        norm <= NORM_GAUSS;
    end case;
  end process;

  -- Instanciation du cœur
  core : entity work.filter_core
    port map (
      clk    => clk,
      rst    => rst,
      enable => enable,
      p0 => p0, p1 => p1, p2 => p2,
      p3 => p3, p4 => p4, p5 => p5,
      p6 => p6, p7 => p7, p8 => p8,
      c0 => c0, c1 => c1, c2 => c2,
      c3 => c3, c4 => c4, c5 => c5,
      c6 => c6, c7 => c7, c8 => c8,
      norm_factor => norm,
      pixel_out   => pixel_out
    );
end architecture;
