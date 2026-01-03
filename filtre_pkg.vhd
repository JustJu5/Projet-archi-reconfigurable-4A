library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package filter_pkg is
  subtype pix8  is std_logic_vector(7 downto 0);
  subtype s8    is signed(7 downto 0);
  subtype s16   is signed(15 downto 0);
  subtype s20   is signed(19 downto 0);

  type coeff9 is array(0 to 8) of s8;

  -- Coefficients prédéfinis
  constant COEFF_AVG_RING : coeff9 := (
    to_signed(1,8), to_signed(1,8), to_signed(1,8),
    to_signed(1,8), to_signed(0,8), to_signed(1,8),
    to_signed(1,8), to_signed(1,8), to_signed(1,8)
  );
  constant NORM_AVG_RING : integer := 8;

  constant COEFF_AVG_ALL : coeff9 := (
    to_signed(1,8), to_signed(1,8), to_signed(1,8),
    to_signed(1,8), to_signed(1,8), to_signed(1,8),
    to_signed(1,8), to_signed(1,8), to_signed(1,8)
  );
  constant NORM_AVG_ALL : integer := 9;

  constant COEFF_SOBEL_H : coeff9 := (
    to_signed(-1,8), to_signed(0,8),  to_signed(1,8),
    to_signed(-2,8), to_signed(0,8),  to_signed(2,8),
    to_signed(-1,8), to_signed(0,8),  to_signed(1,8)
  );
  constant NORM_SOBEL_H : integer := 1;

  constant COEFF_SOBEL_V : coeff9 := (
    to_signed(-1,8), to_signed(-2,8), to_signed(-1,8),
    to_signed(0,8),  to_signed(0,8),  to_signed(0,8),
    to_signed(1,8),  to_signed(2,8),  to_signed(1,8)
  );
  constant NORM_SOBEL_V : integer := 1;

  constant COEFF_GAUSS : coeff9 := (
    to_signed(1,8), to_signed(2,8), to_signed(1,8),
    to_signed(2,8), to_signed(4,8), to_signed(2,8),
    to_signed(1,8), to_signed(2,8), to_signed(1,8)
  );
  constant NORM_GAUSS : integer := 16;
end package;
