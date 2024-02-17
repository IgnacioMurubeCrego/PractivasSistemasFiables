--------------------------------------------------------------------------------
--
-- Title       : 	Debounce Logic module
-- Design      :	
-- Author      :	Ignacio Aznarez Ramos
-- Company     :	Universidad de Nebrija
--------------------------------------------------------------------------------
-- File        : debouncer.vhd
-- Generated   : February 2024
--------------------------------------------------------------------------------
-- Description : Given a synchronous signal it debounces it.
--------------------------------------------------------------------------------
-- Revision History :
-- -----------------------------------------------------------------------------

--   Ver  :| Author            :| Mod. Date :|    Changes Made:

--   v1.0  | Ignacio Aznarez     :| 02/24  :| First version

-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic(
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic;  -- 1 pulse flag output when the timeout has occurred
        count : out integer;
        time_out : out std_logic
    ); 
end debouncer;


architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ) ;
	-- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    
    -- -----------------------------------------------------------------------------
    -- Declarar un tipo para los estados de la fsm usando type
    -- -----------------------------------------------------------------------------
    type SM_type is (IDLE ,BTN_PRS, BTN_UNPRS, VALID);
    signal CS, NS : SM_type := IDLE;
    signal counter : integer;
    signal time_elapsed : std_logic := '0';
    signal en_count : std_logic := '0';
    
    
begin

    count <= counter;
    time_out <= time_elapsed;

    --Timer
    process (clk, rst_n)
    begin
    if rst_n = '0' then
        counter <= 0;
    elsif rising_edge(clk) and  counter = g_timeout then
        en_count <= '0';
        time_elapsed <= '1';
    elsif rising_edge(clk) and en_count = '1' then
        counter <= counter + 1;
    end if;
    end process;

    --FSM Register of next state
    process (clk, rst_n)
    begin
    
    if rst_n = '0' then
        CS <= IDLE;
    elsif rising_edge(clk) then
        CS <= NS;
    end if;
    end process;
	
    process (clk, rst_n, sig_in, ena, time_elapsed)--sensitivity list)
    begin
        case CS is
          
            when IDLE =>
                if sig_in = '1' then
                    NS <= BTN_PRS;
                end if;
            when BTN_PRS =>
                en_count <= '1';
                if ena = '0' or (time_elapsed = '1' and sig_in = '0') then
                    NS <= IDLE;
                elsif time_elapsed = '1' and sig_in = '1' then
                    debounced <= '1';
                    NS <= VALID;
                end if;
            when VALID => 
                if ena = '0' then
                    NS <= IDLE;
                elsif sig_in = '0' then
                    NS <= BTN_UNPRS;
                end if;
            when BTN_UNPRS => 
                if ena = '0' or (time_elapsed = '1' and sig_in = '0') then
                    NS <= IDLE;
                elsif time_elapsed = '1' and sig_in = '1' then
                    NS <= VALID;
                elsif time_elapsed = '0' then
                    en_count <= '1';
                end if;              
        end case;
    end process;
    
    debounced <= sig_in when time_elapsed = '1' else '0';
    
end Behavioural;