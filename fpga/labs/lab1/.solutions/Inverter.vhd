--
-- A simple inverter (NOT gate) in VHDL
-- 
-- Luca Pacher - pacher@to.infn.it
-- Fall 2020
--


library ieee ;
use ieee.std_logic_1164.all ;   -- include extended logic values (by default VHDL only provides 0/1 with the 'bit' data type)


-- entity declaration
entity Inverter is

   port (
      X  : in  std_logic ;
      ZN : out std_logic
   ) ;

end entity Inverter ;


-- architecture implementation
architecture rtl of Inverter is

begin

   -- signal assignment
   ZN <= not X after 3 ns ; 


   -- conditional signal assignment (MUX-style)
   --ZN <= '1' when X = '0' else '0' ;

end architecture rtl ;

