--------------------------------------------------------------------------------
--
-- Title       : 	Test bench de divisor de frequencia
-- Author      :	Ignacio Aznarez Ramos
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : tb_divisor_3.vhd
-- Generated   : February 2024
--------------------------------------------------------------------------------
-- Description : 
	
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Ignacio Aznarez   :| Feb/24    :| First version

-- -----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity tb_divisor_3 is
end entity;

architecture test of tb_divisor_3 is

	component divisor_3 is
		port(clk:       in     std_logic;
			 nRst:      in     std_logic;
			 f_div_2_5: buffer std_logic;
			 f_div_1_25: buffer std_logic;
			 f_div_500:  buffer std_logic);
	end component;
	
  signal clk:     std_logic;
  signal nRst:    std_logic;
  signal f_div_2_5: std_logic;
  signal f_div_1_25: std_logic;
  signal f_div_500: std_logic;
  
  signal end_simulation: boolean := false;
  
  -- modifique la siguiente constante para un reloj de 10 MHz
  constant T_clk: time := 100 ns;
    
begin
----------------------------------------------------------
-- Instancie el bloque divisor de frecuencia que sera testeado
----------------------------------------------------------	
uut: divisor_3
     port map(clk,nRst,f_div_2_5,f_div_1_25,f_div_500);
								 
-----------------------------------------------              
-- Genere el proceso para un reloj de 10 MHz
-----------------------------------------------
process
begin
    clk <= '0';
    wait for T_clk/2;
    clk <= '1';
    wait for T_clk/2;
    if end_simulation = true then
        wait;
    end if;
end process;

-- Secuencia de test
process
begin
  -- Secuencia de reset
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  nRst <= '1';                         -- Reset inactivo
  wait until clk'event and clk = '1';
  nRst <= '0';                         -- Reset activo
  wait until clk'event and clk = '1';
  nRst <= '1';                         -- Reset inactivo
  --Fin de secuencia de reset
  
  -- Complete el test para que puedan observarse
  -- 5 periodos de reloj en la salida f_div_500
  wait for T_clk*5*20;
  end_simulation <= true;
  
  wait;
  
end process;

end test;