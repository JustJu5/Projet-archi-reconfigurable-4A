library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_lena_flou is
end tb_lena_flou;

architecture arch_tb_lena_flou of tb_lena_flou is

  -- Composants
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

 component filtre_flou
  port (
    clk : in std_logic;
    p0, p1, p2, p3, p4, p5, p6, p7, p8 : in std_logic_vector(7 downto 0);
    pixel_out : out std_logic_vector(7 downto 0)
  );
end component;



  -- Signaux
  signal CLK : std_logic := '0';
  signal RST : std_logic := '1';
  signal DATA : std_logic;
  signal I1 : std_logic_vector(7 downto 0);
  signal p0, p1, p2, p3, p4, p5, p6, p7, p8 : std_logic_vector(7 downto 0);
  signal pixel_blur : std_logic_vector(7 downto 0);
  constant CLK_PERIOD : time := 10 ns;

begin

  -- Instanciation delay_line
  uut : delay_line
    port map (
      clk => CLK,
      rst => RST,
      pixel_in => I1,
      wr_en => '1',
      rd_en => '1',
      data_available => DATA,
      p0 => p0, p1 => p1, p2 => p2, p3 => p3, p4 => p4,
      p5 => p5, p6 => p6, p7 => p7, p8 => p8
    );


    blur_inst : filtre_flou
       port map (
        clk => CLK,
        p0 => p0, p1 => p1, p2 => p2,
        p3 => p3, p4 => p4, p5 => p5,
        p6 => p6, p7 => p7, p8 => p8,
        pixel_out => pixel_blur
    );


  -- Horloge
  clk_process : process
  begin
    while true loop
      CLK <= '0'; wait for CLK_PERIOD / 2;
      CLK <= '1'; wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Reset
  rst_process : process
  begin
    RST <= '1';
    wait for 100 ns;
    RST <= '0';
    wait;
  end process;

  -- Lecture fichier Lena
  p_read : process
    file vectors : text;
    variable Iline : line;
    variable I1_var : std_logic_vector(7 downto 0);
  begin
    file_open(vectors, "Lena128x128g_8bits.dat", read_mode);
    wait for 120 ns;

    while not endfile(vectors) loop
      readline(vectors, Iline);
      read(Iline, I1_var);
      I1 <= I1_var;
      wait for CLK_PERIOD;
    end loop;

    file_close(vectors);
    wait;
  end process;

  -- Écriture fichier flou
  p_write : process
    file results : text;
    variable OLine : line;
    variable pixel_count : integer := 0;
  begin
    file_open(results, "Lena_blur.dat", write_mode);
    wait for 5000 ns;

    while pixel_count < 16384 loop
      wait until rising_edge(CLK);
      if DATA = '1' then
        write(OLine, pixel_blur, right, 2);
        writeline(results, OLine);
        pixel_count := pixel_count + 1;
      end if;
    end loop;

    file_close(results);
    report "Écriture terminée : " & integer'image(pixel_count) & " pixels.";
    wait;
  end process;

end arch_tb_lena_flou;