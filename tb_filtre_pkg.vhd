library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filter_pkg.all;

entity tb_filter_pkg is
end entity;

architecture tb of tb_filter_pkg is
begin
  stim : process
  begin
    report "COEFF_AVG_RING = " & integer'image(to_integer(COEFF_AVG_RING(0)));
    report "NORM_AVG_RING = " & integer'image(NORM_AVG_RING);
    report "COEFF_SOBEL_H(0) = " & integer'image(to_integer(COEFF_SOBEL_H(0)));
    report "NORM_GAUSS = " & integer'image(NORM_GAUSS);
    assert false report "Test filter_pkg terminé." severity failure;
  end process;
end architecture;
