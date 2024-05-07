library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
	--Proceso de generacion de estimulos
	--=============================================	
	process is
	begin
		-- Secuencia de reset
		wait until clk'event and clk = '1';
		wait until clk'event and clk = '1';
		rst <= '1';                         -- Reset inactivo
		wait until clk'event and clk = '1';
		rst <= '0';                         -- Reset activo
		wait until clk'event and clk = '1';
		rst <= '1';                         -- Reset inactivo
		--Fin de secuencia de reset
		wait for 100 us;
		
	end process;
	
	-- Needs to be modified.
	process is 
  --variables para manejar los ficheros
  file file_INPUT : text;
  file file_OUTPUT : text;
  variable v_status_input: file_open_status;
  variable v_status_output: file_open_status;
  
  variable v_ILINE: line; --Para almacenar cada linea del fichero
  variable v_OLINE: line;
  --Variables para los valores de entrada
  variable v_RST: integer; --Valor del boton que obtendremos del fichero
  variable v_BTNC: integer;
  variable v_TIME: time;
  
  --Variables para los valores de salida
  variable v_expected: std_logic;
  variable v_LED: integer;
  
  begin 
  
  --Abrimos los ficheros con la instruccion file_open (punto 2.2.2)
  file_open(v_status_input, file_INPUT, "../input.txt", read_mode);
  file_open(v_status_output, file_OUTPUT, "../output.txt", write_mode);
  
  --2.2.3 Uso de assert para verificacion de seniales
  
  --Comprobamos que se abren correctamente, en caso contrario paramos la simulacion
  assert v_status_input = open_ok 
    report "El fichero input.txt no se ha abierto correctamente"
    severity failure; --Con severity failure forzamos la simulacion a parar
	
  assert v_status_output = open_ok
    report "El fichero output.txt no se ha abierto correctamente"
    severity failure; --Con severity failure forzamos la simulacion a parar
  
  
  --2.2.6
   write(v_oline, string'("Simulation of top_practica1.vhd"));
   writeline(file_OUTPUT, v_OLINE);

    while (not endfile(file_INPUT)) loop
		readline(file_INPUT, v_ILINE); --lee toda la linea
		read(v_ILINE, v_TIME);         --lee hasta un espacio en blanco
		read(v_ILINE, v_RST);
		read(v_ILINE, v_BTNC);
		read(v_ILINE, v_LED);
		
		--2.2.5
		BTN <= to_unsigned(v_BTNC,1)(0); --Como es un std_logic se debe hacer con (v_btn, 1)(0), si fuera simple seria con (v_btn) solamente 
		rst_n <= to_unsigned(v_RST,1)(0);
		v_expected:= to_unsigned(v_LED,1)(0);
		
		wait for v_TIME;
		
		--2.2.6 Escribimos el reporte
		write(v_OLINE, "Time: " & time'image(v_TIME) & "  rst_n: " & integer'image(v_RST) & "  BTNC: " & integer'image(v_BTNC)); --primero debemos escribir con write todos los valores en una linea
		writeline(file_OUTPUT, v_OLINE); --despues de crear una linea se puede escribir en un archivo mediante writeline
		
		assert v_expected /= LED
		  report "ERROR"
		  severity note;
		  
		  if(v_expected = LED) then
		      write(v_OLINE, "LED: " & integer'image(v_LED));
		      writeline(file_OUTPUT, v_OLINE);
		  else
		      write(v_OLINE, "ERROR: " & "  Expected LED to be: " & integer'image(v_LED) &
		      "  actual value: " & std_logic'image(LED));
		      writeline(file_OUTPUT, v_OLINE);
            end if;
    end loop;
    
    write(v_oline, string'("END SIMULATION"));
    writeline(file_OUTPUT, v_OLINE);
     fin_sim <= true;
    wait;
    
  end process;
  
end rtl;