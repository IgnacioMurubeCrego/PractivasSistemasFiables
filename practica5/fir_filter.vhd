--------------------------------------------------------------------------------
--
-- Title       : 	FIR filter
-- Design      :	
-- Author      :	Ignacio Azn?rez ramos
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : fir.vhd
-- Generated   : 02 May 2024
--------------------------------------------------------------------------------
-- Description : Practica 5
-- Enunciado   :
-- FIR 8 bit filter with four stages
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Ignacio Aznarez     :| 03/05/22  :| First version
--   v2.0  | Ignacio Murube Crego ; Juan Manuel Vicente Martin ; Javier Navas :| 10/05/24 :| Completed Lab


-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter is
port (
	clk		:in std_logic;
	rst		:in std_logic;
	-- Coeficientes
	beta1	:in std_logic_vector(7 downto 0);
 	beta2	:in std_logic_vector(7 downto 0);
	beta3	:in std_logic_vector(7 downto 0);
	beta4	:in std_logic_vector(7 downto 0);
	-- Data input 8 bit
	i_data 	:in std_logic_vector(7 downto 0);
	-- Filtered data
	o_data 	:out std_logic_vector(9 downto 0)
	);
end fir_filter;

--Declaracion de arquitectura con 5 procesos sequenciales:

architecture rtl of fir_filter is

--Crear los tipos de datos para el pipeline (typdef): 1 para los coeficientes, 1 para los datos, 1 para las multiplicaciones y 1 para las sumas
-- La forma de inicializar un array de std_logics_vector es "(others=>(others=>'0'));"


type pipeline is array (0 to 3) of signed(7 downto 0);
type type_coef          is array (0 to 3) of signed(7 downto 0);
type type_mult           is array (0 to 3) of signed(15 downto 0);
type type_sum        is array (0 to 1) of signed(15+1 downto 0);

signal pipe : pipeline := (others=>(others=>'0'));
signal coeficients : type_coef ;
signal multiplications : type_mult;
signal sums : type_sum;
signal final_sum : signed(15+2 downto 0);

begin

-- Proceso 1 asignar todos los coeficientes a un array de coeficientes de 4 elementos, ir desplazando cada dato de entrada una posicion en un array de 4
input : process(clk,rst)
begin
  if(rst = '0') then
    pipe <= (others=>(others=>'0'));
    coeficients <= (others=>(others=>'0'));
  elsif(rising_edge(clk)) then
    pipe(3) <= pipe(2);
    pipe(2) <= pipe(1);
    pipe(1) <= pipe(0);
    pipe(0) <= signed(i_data);
    coeficients(0)  <= signed(beta1);
    coeficients(1)  <= signed(beta2);
    coeficients(2)  <= signed(beta3);
    coeficients(3)  <= signed(beta4);
  end if;
end process input;

-- Proceso 2 para multiplicar cada dato con cada coeficiente (usad pipeline)
process(clk)
begin
    multiplications(0) <= pipe(0)*coeficients(0);
    multiplications(1) <= pipe(1)*coeficients(1);
    multiplications(2) <= pipe(2)*coeficients(2);
    multiplications(3) <= pipe(3)*coeficients(3);
end process;

-- Proceso 3 para sumar los 4 coeficientes dos a dos (usad pipeline)
process(clk)
begin
    sums(0) <= resize(multiplications(0) + multiplications(1), sums(0)'length);
    sums(1) <= resize(multiplications(2)+ multiplications(3), sums(1)'length);
end process;

-- Proceso 4 para sumar las dos sumas del proceso 3
process(clk)
begin
    final_sum <= resize(sums(0)+sums(1), final_sum'length);
end process;

-- Proceso 5 para asignar el resultado del proceso 4 a la salida
process(clk)
begin
    o_data <= std_logic_vector(final_sum(16 downto 7));
end process;

end rtl;