library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filter_pkg.all;

entity tb_filter_core is
end entity;

architecture tb of tb_filter_core is
  signal clk, rst, enable : std_logic := '0';
  signal p0,p1,p2,p3,p4,p5,p6,p7,p8 : pix8 := (others => '0');
  signal pixel_out : pix8;

  signal c0,c1,c2,c3,c4,c5,c6,c7,c8 : s8;
  signal norm_factor : integer := 9;
begin
  clk <= not clk after 5 ns;

  dut : entity work.filter_core
    port map (
      clk => clk, rst => rst, enable => enable,
      p0 => p0, p1 => p1, p2 => p2,
      p3 => p3, p4 => p4, p5 => p5,
      p6 => p6, p7 => p7, p8 => p8,
      c0 => c0, c1 => c1, c2 => c2,
      c3 => c3, c4 => c4, c5 => c5,
      c6 => c6, c7 => c7, c8 => c8,
      norm_factor => norm_factor,
      pixel_out => pixel_out
    );

  stim : process
  begin
    -- Reset
    rst <= '1'; enable <= '0';
    wait for 20 ns;
    rst <= '0'; enable <= '1';

    -- Charger une fenêtre simple
    p0 <= x"0A"; p1 <= x"14"; p2 <= x"1E";
    p3 <= x"28"; p4 <= x"32"; p5 <= x"3C";
    p6 <= x"46"; p7 <= x"50"; p8 <= x"5A";

    -- Coefficients moyenne
    c0 <= to_signed(1,8); c1 <= to_signed(1,8); c2 <= to_signed(1,8);
    c3 <= to_signed(1,8); c4 <= to_signed(1,8); c5 <= to_signed(1,8);
    c6 <= to_signed(1,8); c7 <= to_signed(1,8); c8 <= to_signed(1,8);

    wait for 50 ns;
    report "Résultat filtre_core (moyenne) = " & integer'image(to_integer(unsigned(pixel_out)));

    assert false report "Test filter_core terminé." severity failure;
  end process;
end architecture;
