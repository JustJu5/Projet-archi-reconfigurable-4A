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

  -- Pipeline registers
  signal line0, line0_1, line0_2 : std_logic_vector(7 downto 0);
  signal line1, line1_1, line1_2 : std_logic_vector(7 downto 0);
  signal line2, line2_1, line2_2 : std_logic_vector(7 downto 0);

  -- Compteur de pixels écrits
  signal write_count : integer := 0;

begin

  
  -- Compteur d’écriture (sert uniquement pour contrôler le pipeline)

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
  -- On ne lit que lorsque FIFO contient des données et après un certain délai

  fifo1_rd_en <= '1' when (write_count > 128 and fifo1_empty = '0') else '0';
  fifo2_wr_en <= fifo1_rd_en;
  fifo2_rd_en <= '1' when (write_count > 256 and fifo2_empty = '0') else '0';


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
      prog_full_thresh => (others => '1'),
      prog_full => open,
      wr_rst_busy => open,
      rd_rst_busy => open
    );


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
      prog_full_thresh => (others => '1'),
      prog_full => open,
      wr_rst_busy => open,
      rd_rst_busy => open
    );


  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        line0 <= (others => '0'); line0_1 <= (others => '0'); line0_2 <= (others => '0');
        line1 <= (others => '0'); line1_1 <= (others => '0'); line1_2 <= (others => '0');
        line2 <= (others => '0'); line2_1 <= (others => '0'); line2_2 <= (others => '0');
        data_available <= '0';
      else
        -- Décalage pixels (pipeline)
        line0_2 <= line0_1; line0_1 <= line0; line0 <= pixel_in;
        line1_2 <= line1_1; line1_1 <= line1; line1 <= fifo1_dout;
        line2_2 <= line2_1; line2_1 <= line2; line2 <= fifo2_dout;

        -- Active data_available après que le pipeline soit rempli
        if write_count > 300 then
          data_available <= '1';
        else
          data_available <= '0';
        end if;
      end if;
    end if;
  end process;


  p0 <= line0;   p1 <= line0_1; p2 <= line0_2;
  p3 <= line1;   p4 <= line1_1; p5 <= line1_2;
  p6 <= line2;   p7 <= line2_1; p8 <= line2_2;

end Behavioral;
