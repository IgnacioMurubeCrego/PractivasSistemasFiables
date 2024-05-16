library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library std; 
use std.textio.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture rtl of fir_filter_tb is

constant beta1    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-10,8));--(100,8)); Probad distintos filtros
constant beta2    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(110,8));--(100,8));
constant beta3    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(127,8));--(100,8));
constant beta4    : std_logic_vector( 7 downto 0):= std_logic_vector(to_signed(-20,8));--(100,8));

component fir_test_data_generator
port (
  clk                   : in  std_logic;
  rst                  : in  std_logic;
  pattern_sel           : in  integer;  -- 0=> delta; 1=> step; 2=> sine
  enable      : in  std_logic;
  o_data                  : out std_logic_vector( 7 downto 0)); -- to FIR 
end component;

component fir_filter
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
end component;

constant freq : integer := 100_000;   --KHZ
constant clk_period : time := (1 ms/ freq);

signal clk : std_logic := '0';
signal rst : std_logic := '0';
signal pattern_sel : integer := 0;
signal enable : std_logic := '0';
signal w_data_test : std_logic_vector( 7 downto 0) := (others => '0');
signal o_data : std_logic_vector( 9 downto 0) := (others => '0');

  --variables para manejar los ficheros
  file file_INPUT : text;

begin

  --================================= 
	--Instaciar el generador de datos  aqui
	--==============================
U_fir_test_data_generator : fir_test_data_generator
port map(
    clk => clk,
    rst => rst,
    pattern_sel => pattern_sel,
    enable => enable,
    o_data => w_data_test
	);
	
	--================================= 
	--Instaciar el filtro fir aqui
	--==============================
	UUT : fir_filter 
	port map(
	   clk => clk,
        rst => rst,
        beta1 => beta1,
        beta2 => beta2,
        beta3 => beta3,
        beta4 => beta4,
        i_data => w_data_test,
        o_data => o_data
		);
  
	--=============================================
	--Crear el proceso de generacion de reloj aqui
	--=============================================
	process is
	begin
	   clk <= '0';
	   wait for clk_period/2;
	   clk <= '1';
	   wait for clk_period/2;
	end process;
	
    --=============================================
    -- Proceso de generacion de estimulos
    --=============================================
    process is
    
      variable v_status_input: file_open_status;
      variable v_ILINE: line; -- Para almacenar cada linea del fichero
    
      -- Variables para los valores de entrada
      variable v_TIME: time;
      variable v_PATTERN: integer; -- Valor del boton que obtendremos del fichero
    
    begin
    
        -- Abrimos el fichero de entrada
        file_open(v_status_input, file_INPUT, "../input.txt", read_mode);
        
        -- Verificamos que se abre correctamente, en caso contrario, paramos la simulacion
        assert v_status_input = open_ok 
            report "El fichero input.txt no se ha abierto correctamente"
            severity failure;
    
        -- Secuencia de reset
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rst <= '1';                         -- Reset activo
        wait until rising_edge(clk);
        rst <= '0';                         -- Reset inactivo
        wait until rising_edge(clk);
        rst <= '1';                         -- Reset activo
        wait until rising_edge(clk);
        
        -- Leer y aplicar los estímulos desde el archivo de entrada
        while not endfile(file_INPUT) loop
            readline(file_INPUT, v_ILINE); -- Lee toda la línea
            read(v_ILINE, v_TIME);         -- Lee hasta un espacio en blanco
            read(v_ILINE, v_PATTERN);      -- Lee el patrón de estímulo
            
            -- Aplicar el patrón de estímulo
            enable <= '1';                  -- Activar la señal de habilitación
            pattern_sel <= v_PATTERN;       -- Configurar el selector de patrón
            
            -- Esperar hasta el próximo cambio de tiempo
            wait for v_TIME;
        end loop;
    
        -- Cerrar el archivo de entrada
        file_close(file_INPUT);
        
        -- Esperar hasta el próximo cambio de reloj
        wait;
    
    end process;
  
end rtl;