library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity delay_line is
  Port (
    clk : in std_logic;
    rst : in std_logic;
    pixel_in : in std_logic_vector(7 downto 0);
    wr_en : in std_logic;
    rd_en : in std_logic;
    data_available : out std_logic;
    p0, p1, p2, p3, p4, p5, p6, p7, p8 : out std_logic_vector(7 downto 0)
  );
end delay_line;

architecture Behavioral of delay_line is

  component fifo_generator_0
    port (
      clk : in std_logic;
      rst : in std_logic;
      din : in std_logic_vector(7 downto 0);
      wr_en : in std_logic;
      rd_en : in std_logic;
      dout : out std_logic_vector(7 downto 0);
      full : out std_logic;
      empty : out std_logic;
      prog_full_thresh : in std_logic_vector(9 downto 0);
      prog_full : out std_logic;
      wr_rst_busy : out std_logic;
      rd_rst_busy : out std_logic
    );
  end component;

  -- FIFO signals
  signal fifo1_dout, fifo2_dout : std_logic_vector(7 downto 0);
  signal fifo1_empty, fifo2_empty : std_logic;
  signal fifo1_rd_en, fifo2_rd_en, fifo2_wr_en : std_logic;

  -- Bascule pour chaque ligne
  signal reg0_a, reg0_b, reg0_c : std_logic_vector(7 downto 0);
  signal reg1_a, reg1_b, reg1_c : std_logic_vector(7 downto 0);
  signal reg2_a, reg2_b, reg2_c : std_logic_vector(7 downto 0);

  -- Compteur de pixels écrits
  signal write_count : integer := 0;

begin

  -- Compteur d'écriture
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        write_count <= 0;
      else
        if wr_en = '1' then
          write_count <= write_count + 1;
        end if;
      end if;
    end if;
  end process;

  -- Contrôle lecture / écriture FIFO
  fifo1_rd_en <= '1' when (write_count > 128 and fifo1_empty = '0') else '0';
  fifo2_wr_en <= fifo1_rd_en;
  fifo2_rd_en <= '1' when (write_count > 256 and fifo2_empty = '0') else '0';

  -- FIFO 1
  fifo1_inst : fifo_generator_0
    port map (
      clk => clk,
      rst => rst,
      din => pixel_in,
      wr_en => wr_en,
      rd_en => fifo1_rd_en,
      dout => fifo1_dout,
      full => open,
      empty => fifo1_empty,
      prog_full_thresh => std_logic_vector(to_unsigned(124, 10)),
      prog_full => open,
      wr_rst_busy => open,
      rd_rst_busy => open
    );

  -- FIFO 2
  fifo2_inst : fifo_generator_0
    port map (
      clk => clk,
      rst => rst,
      din => fifo1_dout,
      wr_en => fifo2_wr_en,
      rd_en => fifo2_rd_en,
      dout => fifo2_dout,
      full => open,
      empty => fifo2_empty,
      prog_full_thresh => std_logic_vector(to_unsigned(124, 10)),
      prog_full => open,
      wr_rst_busy => open,
      rd_rst_busy => open
    );

  -- Bascule horizontale pour chaque ligne
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        reg0_a <= (others => '0'); reg0_b <= (others => '0'); reg0_c <= (others => '0');
        reg1_a <= (others => '0'); reg1_b <= (others => '0'); reg1_c <= (others => '0');
        reg2_a <= (others => '0'); reg2_b <= (others => '0'); reg2_c <= (others => '0');
        data_available <= '0';
      else
        -- Ligne 0 (entrée directe)
        reg0_c <= reg0_b;
        reg0_b <= reg0_a;
        reg0_a <= pixel_in;

        -- Ligne 1 (sortie FIFO1)
        reg1_c <= reg1_b;
        reg1_b <= reg1_a;
        reg1_a <= fifo1_dout;

        -- Ligne 2 (sortie FIFO2)
        reg2_c <= reg2_b;
        reg2_b <= reg2_a;
        reg2_a <= fifo2_dout;

        -- Active data_available après pipeline rempli
        if write_count > 300 then
          data_available <= '1';
        else
          data_available <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Sorties (ordre corrigé : p0 = pixel le plus ancien)
  p0 <= reg0_c; p1 <= reg0_b; p2 <= reg0_a;
  p3 <= reg1_c; p4 <= reg1_b; p5 <= reg1_a;
  p6 <= reg2_c; p7 <= reg2_b; p8 <= reg2_a;

end Behavioral;