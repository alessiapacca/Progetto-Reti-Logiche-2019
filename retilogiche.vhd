Alessia, [30.03.19 11:11]
----------------------------------------------------------------------------------
-- Company: Politecnico di Milano 
-- Engineer: Alessia Paccagnella
-- 
-- Create Date: 03/07/2019 06:13:11 PM
-- Design Name: 
-- Module Name: project_reti_logiche - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.ALL;

entity project_reti_logiche is
    Port (
            i_clk       :in std_logic; 
            i_start     :in std_logic;
            i_rst       :in std_logic;
            i_data      :in std_logic_vector(7 downto 0);
            o_address   :out std_logic_vector(15 downto 0);
            o_done      :out std_logic;
            o_en        :out std_logic;
            o_we        :out std_logic;
            o_data      :out std_logic_vector(7 downto 0)
          );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

    type state_type is (RESET, INIT, START, SALVOMASCHERA, LEGGOXP, LEGGOYP, CENTROIDEMASCHERA, LEGGOCENTROIDEX, LEGGOCENTROIDEY, CALCOLADISTANZA, CONFRONTA, INCREMENTOCENTROIDE, DISTAUGUALE, DISTAMINIMA, FINITO, SCRIVOUSCITA, DONE);
    signal next_state : state_type := INIT;
    signal current_state: state_type := INIT;
    signal addr : UNSIGNED(15 downto 0);
    signal xcentroide: UNSIGNED(8 downto 0) := "000000000"; 
    signal ycentroide: UNSIGNED(8 downto 0) := "000000000";
    signal xpunto: UNSIGNED(8 downto 0) := "000000000";
    signal ypunto: UNSIGNED(8 downto 0) := "000000000";
    signal maschera : STD_LOGIC_VECTOR( 7 downto 0) := "00000000";
    signal contatore: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal distanza: UNSIGNED(8 downto 0) := "000000000";
    signal distanzaminima: UNSIGNED(8 downto 0) := "111111111";
    signal mascherauscita: STD_LOGIC_VECTOR(7 downto 0) := "00000000";
 

begin

--REGOLA
    o_address <= std_logic_vector(addr);
   

-- state_sequence : Aggiorna lo stato della macchina a stati finiti per ogni colpo di clock.
    state_sequence: process(i_clk, i_rst)
    begin
        if (i_rst = '1')  then
            current_state <= RESET;
        elsif rising_edge(i_clk) then
            current_state <= next_state;
        end if;
end process;

-- init è solo lo stato di inizializzazioni delle variabili. invece START è quello dove salva la maschera
--  transitions : Dato lo stato corrente della FSM e leggendo i segnali della transizione computa lo stato successivo 

    transitions: process(i_clk, current_state, i_start, i_rst)
    begin
        if falling_edge(i_clk) then
            case current_state is
                --when INIT =>
                    --if i_rst = '1' then
                        --next_state <= RESET;
                    --end if;
                when RESET =>  
                    if i_start = '1' then
                        next_state <= START;
                    end if;
                when START =>
                    next_state <= SALVOMASCHERA;
                when SALVOMASCHERA =>
                    next_state <= LEGGOXP;
                when LEGGOXP =>
                    next_state <= LEGGOYP;
                when LEGGOYP =>
                    next_state <= CENTROIDEMASCHERA;
                when CENTROIDEMASCHERA =>
                    if((contatore AND maschera) = "00000000") then
                        next_state <= INCREMENTOCENTROIDE; 
                    else
                        next_state <= LEGGOCENTROIDEX;
                    end if;           
                when LEGGOCENTROIDEX =>
                    next_state <= LEGGOCENTROIDEY;
                when LEGGOCENTROIDEY =>
                    next_state <= CALCOLADISTANZA;
                when CALCOLADISTANZA =>
                    next_state <= CONFRONTA;
                
                when CONFRONTA =>
                    if (distanza < distanzaminima) then

next_state <= DISTAMINIMA;
                    else
                        if (distanza = distanzaminima) then 
                            next_state <= DISTAUGUALE;
                        else
                            next_state <= INCREMENTOCENTROIDE;
                        end if;
                    end if;
                when INCREMENTOCENTROIDE =>
                    if (contatore = "10000000") then 
                        next_state <= FINITO;
                    else
                        next_state <= CENTROIDEMASCHERA;
                    end if;
                when FINITO => 
                    next_state <= SCRIVOUSCITA;
                when SCRIVOUSCITA =>
                    next_state <= DONE;
                when DISTAMINIMA =>
                  next_state <= INCREMENTOCENTROIDE;
                when DISTAUGUALE =>
                   next_state <= INCREMENTOCENTROIDE;
                when DONE =>
                    next_state <= RESET;
                when others => next_state <= RESET;
            end case;
        end if;
end process;


-- MAIN_PROCESS : Contiene le operazioni che devono essere fatte in uno specifico stato della FSM 
    MAIN_PROCESS : process(i_clk, current_state, i_start, i_rst
    )
    begin
    if falling_edge(i_clk) then
        case current_state is
        
            when RESET =>
            
                xcentroide <= "000000000";
                ycentroide <= "000000000";
                xpunto <= "000000000";
                ypunto <= "000000000";
                maschera <= "00000000";
                contatore <= "00000000";
                distanza <= "000000000";
                distanzaminima <= "111111111";
                mascherauscita <= "00000000";
                addr <= "0000000000000000";
                o_done <= '0';
                
            when START =>
                o_en <= '1';
                
            when SALVOMASCHERA =>
                maschera <= i_data;
                addr <= "0000000000010001";

            when LEGGOXP =>
                xpunto <= UNSIGNED('0'& i_data); 
                addr <= addr + 1;      

            when LEGGOYP =>
                ypunto <= UNSIGNED('0'& i_data);
                contatore <= "00000001"; --rappresenta il primo centroide
                addr <= "0000000000000001"; --mi porto sulla prima coordinata

            when CENTROIDEMASCHERA =>
             if ((contatore AND maschera) = "00000000") then
                   addr <= addr + 2;
              end if;

            when LEGGOCENTROIDEX =>
                xcentroide <= UNSIGNED('0'& i_data);
                addr <= addr + 1;
            
            when LEGGOCENTROIDEY =>
                ycentroide <= UNSIGNED('0' & i_data);
                addr <= addr + 1;
               
            when CALCOLADISTANZA => 
                distanza <= UNSIGNED(ABS(SIGNED(xpunto)- SIGNED(xcentroide)) + ABS(SIGNED(ypunto)- SIGNED(ycentroide)));  
                
            when DISTAUGUALE =>
                mascherauscita <= mascherauscita OR contatore;
            
            when DISTAMINIMA =>
                mascherauscita <= "00000000" OR contatore;
                distanzaminima <= distanza;
                
                
            when INCREMENTOCENTROIDE =>
                contatore <= contatore(6 downto 0) & '0';  -- in questo modo sto shiftando a sx
            
            when FINITO =>
                o_we <= '1';
                addr <= "0000000000010011";
                
            when SCRIVOUSCITA =>
                o_data <= mascherauscita;
            
            when DONE =>
                o_we <= '0';
                o_en <= '0';
                o_done <= '1';
                
            when others => 
                o_en <= '1';
               
    end case; 
    end if;      
end process;

end Behavioral;