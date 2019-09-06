--  This package has been generated automatically by GNATtest.
--  You are allowed to add your code to the bodies of test routines.
--  Such changes will be kept during further regeneration of this file.
--  All code placed outside of test routine bodies will be lost. The
--  code intended to set up and tear down the test environment should be
--  placed into Bases.Trade.Test_Data.

with AUnit.Assertions; use AUnit.Assertions;
with System.Assertions;

--  begin read only
--  id:2.2/00/
--
--  This section can be used to add with clauses if necessary.
--
--  end read only

--  begin read only
--  end read only
package body Bases.Trade.Test_Data.Tests is

--  begin read only
--  id:2.2/01/
--
--  This section can be used to add global variables and other elements.
--
--  end read only

--  begin read only
--  end read only
--  begin read only
   procedure Wrap_Test_HireRecruit_e2a034_6a9998 (RecruitIndex, Cost: Positive; DailyPayment, TradePayment: Natural; ContractLenght: Integer) 
   is
   begin
      GNATtest_Generated.GNATtest_Standard.Bases.Trade.HireRecruit (RecruitIndex, Cost, DailyPayment, TradePayment, ContractLenght);
   end Wrap_Test_HireRecruit_e2a034_6a9998;
--  end read only

--  begin read only
   procedure Test_HireRecruit_test_hirerecruit (Gnattest_T : in out Test);
   procedure Test_HireRecruit_e2a034_6a9998 (Gnattest_T : in out Test) renames Test_HireRecruit_test_hirerecruit;
--  id:2.2/e2a03470a37e9b74/HireRecruit/1/0/test_hirerecruit/
   procedure Test_HireRecruit_test_hirerecruit (Gnattest_T : in out Test) is
   procedure HireRecruit (RecruitIndex, Cost: Positive; DailyPayment, TradePayment: Natural; ContractLenght: Integer) renames Wrap_Test_HireRecruit_e2a034_6a9998;
--  end read only

      pragma Unreferenced (Gnattest_T);
      Amount: constant Positive := Positive(PlayerShip.Crew.Length);

   begin

      HireRecruit(1, 1, 0, 0, 1);
      Assert(Positive(PlayerShip.Crew.Length) = Amount + 1, "Failed to hire recruit to player ship crew.");

--  begin read only
   end Test_HireRecruit_test_hirerecruit;
--  end read only

--  begin read only
--  id:2.2/02/
--
--  This section can be used to add elaboration code for the global state.
--
begin
--  end read only
   null;
--  begin read only
--  end read only
end Bases.Trade.Test_Data.Tests;