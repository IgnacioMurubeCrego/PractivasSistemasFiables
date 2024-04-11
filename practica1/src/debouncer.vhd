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
--   v1.1  | Ignacio Murube ; Juan Manuel Vicente ; Jesus Navas :| 02/24 : Completed First Version
-- -----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity debouncer is
    generic (
        g_timeout          : integer   := 5;        -- Time in ms
        g_clock_freq_KHZ   : integer   := 100_000   -- Frequency in KHz of the system 
    );   
    port (  
        rst_n       : in    std_logic; -- asynchronous reset, low -active
        clk         : in    std_logic; -- system clk
        ena         : in    std_logic; -- enable must be on 1 to work (kind of synchronous reset)
        sig_in      : in    std_logic; -- signal to debounce
        debounced   : out   std_logic  -- 1 pulse flag output when the timeout has occurred
    ); 
end debouncer;

architecture Behavioural of debouncer is 
      
    -- Calculate the number of cycles of the counter (debounce_time * freq), result in cycles
    constant c_cycles           : integer := integer(g_timeout * g_clock_freq_KHZ);
    -- Calculate the length of the counter so the count fits
    constant c_counter_width    : integer := integer(ceil(log2(real(c_cycles))));
    constant c_max_cycles : unsigned(c_counter_width-1 downto 0) :=
    to_unsigned(c_cycles, c_counter_width);
    
    -- -----------------------------------------------------------------------------
    -- Declarar un tipo para los estados de la FSM usando type
    -- -----------------------------------------------------------------------------
    type SM_type is (IDLE, BTN_PRS, BTN_UNPRS, VALID);
    
    signal CS, NS            : SM_type := IDLE;
    signal counter           : unsigned(c_counter_width-1 downto 0) := (others => '0'); -- contador
    signal time_elapsed      : std_logic := '0';
    signal en_count          : std_logic := '0';
    
begin
    -- Timer
process (clk, rst_n)
begin
    if rst_n = '0' then
        time_elapsed <= '0';    
        counter <= (others => '0');
    elsif rising_edge(clk) then
        time_elapsed <= '0';
        if en_count = '1' then
            --report "counting";
            counter <= counter + 1;
            if counter = c_max_cycles then
                --report "time elapsed";
                counter <= (others => '0');
                time_elapsed <= '1';
            end if;
        end if;
    end if;
end process;

    -- FSM Register of next state
    process (clk, rst_n)
    begin
        if rst_n = '0' then
            CS <= IDLE;
        elsif rising_edge(clk) then
            CS <= NS;
        end if;
    end process;
    
    -- FSM Combinational Logic
    process (clk, rst_n, sig_in, ena, time_elapsed)
    begin
        case CS is
            when IDLE =>
                en_count <= '0';
                --report "IDLE";
                if sig_in = '1' then
                    NS <= BTN_PRS;
                end if;
            when BTN_PRS =>
                --report "BTN_PRS";
                if ena = '0' then
                    NS <= IDLE;
                elsif time_elapsed = '1' and sig_in = '0' then
                    NS <= IDLE;
                elsif (time_elapsed = '1' and sig_in = '1') then
                    NS <= VALID;
                else
                    --report "count enabled";
                    en_count <= '1';
                end if;
            when VALID => 
                en_count <= '0';
                --report "VALID";
                if ena = '0' then
                    NS <= IDLE;
                elsif sig_in = '0' then
                    NS <= BTN_UNPRS;
                end if;
            when BTN_UNPRS => 
                --report "BTN_UNPRS";
                if ena = '0' or (time_elapsed = '1' and sig_in = '0') then
                    NS <= IDLE;
                elsif time_elapsed = '1' and sig_in = '1' then
                    NS <= VALID;
                else
                    --report "count enabled";
                    en_count <= '1';
                end if;              
            when others =>
                NS <= IDLE; -- Default transition to IDLE for uncontrolled states
        end case;
    end process;
    
    debounced <= sig_in when time_elapsed = '1' else '0';
    
end Behavioural;