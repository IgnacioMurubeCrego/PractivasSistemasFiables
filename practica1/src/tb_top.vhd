--------------------------------------------------------------------------------
--
-- Title       : 	Testbench for the top module
-- Design      :	
-- Author      :	Ignacio Aznarez Ramos
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : tb_debouncer.vhd
-- Generated   : February 2024
--------------------------------------------------------------------------------
-- Description : This testbench based on an async signal will test if the output 
--    toggles when the duration of the debounce has finished
--    
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Ignacio Aznarez   :| 02/24  :| First version


-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top is 
end tb_top;

architecture testBench of tb_top is
  component top_practica1 is
  port (
      rst_n         : in std_logic;
      clk100Mhz     : in std_logic;
      BTNC           : in std_logic;
      LED           : out std_logic
  );
end component;

  constant timer_debounce : integer := 10; --ms
  constant freq : integer := 100_000; --KHZ
  constant clk_period : time := (1 ms/ freq);

  -- Inputs 
  signal  rst_n       :   std_logic := '0';
  signal  clk         :   std_logic := '0';
  signal  BTN     :   std_logic := '0';
  -- Output
  signal  LED   :   std_logic;
  --Senhal fin de simulacion
  signal  fin_sim : boolean := false;
  
begin
  UUT: top_practica1
    port map (
      rst_n     => rst_n,
      clk100Mhz => clk,
      BTNC       => BTN,
      LED       => LED
    );
	
  --Proceso de generacion del reloj 
  clock: process
  begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
      if fin_sim = true then
        wait;
      end if;
  end process;
  
  process is 
  begin
		-- Secuencia de reset
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		rst_n <= '1';                         -- Reset inactivo
		wait until clk'event and clk = '1';
		rst_n <= '0';                         -- Reset activo
		wait until clk'event and clk = '1';
		rst_n <= '1';                         -- Reset inactivo
		--Fin de secuencia de reset
    
    wait for 13 ns;
    wait until rising_edge(clk);
    -- Btn on with noise
    BTN <='1';
    wait for 235 ns;
    wait until rising_edge(clk);
    BTN <= '0';
    wait for 166 ns;
    wait until rising_edge(clk);
    BTN <='1';
    wait for 20 ms;
    wait until rising_edge(clk);
    -- False boton off 
    BTN <='0';
    wait for 164 ns;
    
    BTN <='1';
    wait for 20 ms;
    wait until rising_edge(clk);    
    -- Boton off with noise
    BTN <='0';
    wait for 150 ns;
    wait until rising_edge(clk);    
    BTN <='1';
    wait for 162 ns;
    wait until rising_edge(clk);    
    BTN <='0';
    wait for 20 ms; 
    wait until rising_edge(clk);
	-- Fin simulacion
	fin_sim <= true;
  end process;
end testBench;