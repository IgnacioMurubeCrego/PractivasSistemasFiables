--------------------------------------------------------------------------------
--
-- Title       : 	Test bench de Registro de desplazamiento
-- Author      :	Ignacio Aznarez Ramos
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : tb_shift_register.vhd
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

entity tb_shift_register is
end tb_shift_register;

architecture testBench of tb_shift_register is
  component shift_register is
	generic(
		g_N	: integer := 4         -- Size of the register
	);
	port (
		rst_n		: in std_logic; -- asynchronous reset, low active
		clk 		: in std_logic; -- system clk
		s0          : in std_logic;
		s1          : in std_logic;
		din   		: in std_logic; -- Serial IN. One bit serial input
		D  	      	: in std_logic_vector(g_N-1 downto 0);-- Paralel IN. Vector of generic g_n bits.
		Q         	: out std_logic_vector(g_N-1 downto 0);-- Paralel OUT. 
		dout     	: out std_logic -- Serial OUT.
	);
  end component;
  
  constant g_N	: integer := 4;         -- Size of the register
  constant freq : integer := 100_000;   --KHZ 
  constant clk_period : time := (1 ms/ freq);
  
  -- Inputs 
  signal rst_n      :   std_logic := '0';
  signal clk        :   std_logic := '0';
  signal s0         : std_logic := '0';
  signal s1         : std_logic := '0';
  signal din		:  std_logic := '0';-- Serial IN. One bit serial input
  signal D      	: std_logic_vector(g_N-1 downto 0) := (others => '0');-- Paralel IN. Vector of generic g_n bits.
  
  -- Output
  signal  dout 		:  std_logic;-- Synchronous clock at the g_freq_SCLK_KHZ
  signal  Q	        :  std_logic_vector(g_N-1 downto 0);-- one cycle signal of the rising edge of SCLK
   
begin
  UUT: shift_register
  	generic map(
		g_N	      => g_N       -- Size of the register
	)
    port map (
      rst_n     => rst_n,
      clk       => clk,
      s0        => s0,
      s1        => s1,
      din       => din,
      D         => D,
      Q         => Q,
      dout      => dout
    );
    
								 
	-----------------------------------------------              
	-- Genere el proceso para un reloj
	-----------------------------------------------
	
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
    
    --------------------------
    -- Completar con los casos de prueba
    -- Recuerda probar tanto la entrada en serie como la carga en paralelo, y ambos desplazamientos izq y drch
    --------------------------
    
    -- Finalizar simulacion

  end process;
end testBench;
