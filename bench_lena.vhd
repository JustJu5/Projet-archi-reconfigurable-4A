library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_dupliq is
end tb_lena_dupliq;

architecture arch_tb_lena_dupliq of tb_lena_dupliq is
  component delay_line
    port (
      clk : in std_logic;
      rst : in std_logic;
      pixel_in : in std_logic_vector(7 downto 0);
      wr_en : in std_logic;
      rd_en : in std_logic;
      data_available : out std_logic;
      p0, p1, p2, p3, p4, p5, p6, p7, p8 : out std_logic_vector(7 downto 0)
    );
  end component;
  

signal result_pixel : std_logic_vector(7 downto 0);

  signal I1 : std_logic_vector(7 downto 0);
  signal CLK : std_logic := '0';
  signal DATA : std_logic;
  signal p0, p1, p2, p3, p4, p5, p6, p7, p8 : std_logic_vector(7 downto 0);
  constant CLK_PERIOD : time := 10 ns;

begin
  -- Instanciation du module delay_line
  uut : delay_line
    port map (
      clk => CLK, rst => '0',
      pixel_in => I1, wr_en => '1', rd_en => '1',
      data_available => DATA,
      p0 => p0, p1 => p1, p2 => p2, p3 => p3, p4 => p4, p5 => p5, p6 => p6, p7 => p7, p8 => p8
    );
    

  -- Génération d'horloge
  clk_process : process
  begin
    while true loop
      CLK <= '0'; wait for CLK_PERIOD / 2;
      CLK <= '1'; wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Lecture fichier Lena
  p_read : process
    file vectors : text;
    variable Iline : line;
    variable I1_var : std_logic_vector(7 downto 0);
  begin
    file_open(vectors, "Lena128x128g_8bits.dat", read_mode);
    wait for 100 ns;

    while not endfile(vectors) loop
      readline(vectors, Iline);
      read(Iline, I1_var);
      I1 <= I1_var;
      report "Pixel lu : " & integer'image(to_integer(unsigned(I1)));
      wait for CLK_PERIOD;
    end loop;

    file_close(vectors);
    wait;
  end process;

  -- Écriture fichier résultat
  p_write : process
    file results : text;
    variable OLine : line;
    variable pixel_count : integer := 0;
  begin
    file_open(results, "Lena_filtered.dat", write_mode);
    wait for 100 ns;

    while pixel_count < 16384 loop
      wait until rising_edge(CLK);
      if DATA = '1' then
        write(OLine, p4, right, 2); -- pixel central
        writeline(results, OLine);
        pixel_count := pixel_count + 1;
      end if;
    end loop;
    file_close(results);
    
    wait;
  end process;
end arch_tb_lena_dupliq;
