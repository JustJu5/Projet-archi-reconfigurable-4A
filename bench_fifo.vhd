library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bench_fifo is
end bench_fifo;

architecture Behavioral of bench_fifo is

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

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal din : std_logic_vector(7 downto 0) := (others => '0');
  signal wr_en : std_logic := '0';
  signal rd_en : std_logic := '0';
  signal dout : std_logic_vector(7 downto 0);
  signal full, empty, prog_full : std_logic;
  signal wr_rst_busy, rd_rst_busy : std_logic;
  signal prog_full_thresh : std_logic_vector(9 downto 0) := "0000000100";

  constant CLK_PERIOD : time := 10 ns;

begin

  clk_process : process
  begin
    while true loop
      clk <= '0';
      wait for CLK_PERIOD / 2;
      clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;


  uut_fifo : fifo_generator_0
    port map (
      clk => clk,
      rst => rst,
      din => din,
      wr_en => wr_en,
      rd_en => rd_en,
      dout => dout,
      full => full,
      empty => empty,
      prog_full_thresh => prog_full_thresh,
      prog_full => prog_full,
      wr_rst_busy => wr_rst_busy,
      rd_rst_busy => rd_rst_busy
    );

stim_proc : process
begin
  -- Reset
  rst <= '1';
  wait for 200 ns;
  rst <= '0';

  -- Attendre que la FIFO soit prête
  wait for 100 ns;

  -- Écriture de 5 octets
  wr_en <= '1';
  din <= x"11"; wait for CLK_PERIOD;
  din <= x"22"; wait for CLK_PERIOD;
  din <= x"33"; wait for CLK_PERIOD;
  din <= x"44"; wait for CLK_PERIOD;
  din <= x"55"; wait for CLK_PERIOD;
  wr_en <= '0';

  -- Attendre avant lecture
  wait for 100 ns;

  -- Lecture seulement si empty = '0'
  if empty = '0' then
    rd_en <= '1'; wait for CLK_PERIOD * 5;
    rd_en <= '0';
  end if;

  wait;
end process;

end Behavioral;
