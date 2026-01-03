library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.filter_pkg.all;

entity tb_filter_wrapper is
end entity;

architecture tb of tb_filter_wrapper is
  signal clk, rst, enable : std_logic := '0';
  signal filter_sel : unsigned(2 downto 0) := (others => '0');
  signal p0,p1,p2,p3,p4,p5,p6,p7,p8 : pix8 := (others => '0');
  signal pixel_out : pix8;
begin
  clk <= not clk after 5 ns;

  dut : entity work.filter_wrapper
    port map (
      clk => clk, rst => rst, enable => enable,
      filter_sel => filter_sel,
      p0 => p0, p1 => p1, p2 => p2,
      p3 => p3, p4 => p4, p5 => p5,
      p6 => p6, p7 => p7, p8 => p8,
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

    -- Tester les filtres
    for sel in 0 to 4 loop
      filter_sel <= to_unsigned(sel,3);
      wait for 30 ns;
      report "Filtre_sel=" & integer'image(sel) &
             " ? pixel_out=" & integer'image(to_integer(unsigned(pixel_out)));
    end loop;

    assert false report "Test filter_wrapper terminé." severity failure;
  end process;
end architecture;
