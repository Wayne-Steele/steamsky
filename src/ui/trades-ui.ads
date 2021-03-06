--    Copyright 2018-2019 Bartek thindil Jasicki
--
--    This file is part of Steam Sky.
--
--    Steam Sky is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    Steam Sky is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with Steam Sky.  If not, see <http://www.gnu.org/licenses/>.

-- ****h* Steamsky/Trades.UI
-- FUNCTION
-- Provides code for trading with bases and ships UI
-- SOURCE
package Trades.UI is
-- ****

   -- ****f* Trades.UI/CreateTradeUI
   -- FUNCTION
   -- Create infterace for trades
   -- SOURCE
   procedure CreateTradeUI;
   -- ****

   -- ****f* Trades.UI/ShowTradeUI
   -- FUNCTION
   -- Show interface for trades
   -- PARAMETERS
   -- ResetUI - If true, reset currently set category and search field
   -- SOURCE
   procedure ShowTradeUI(ResetUI: Boolean := True);
   -- ****

end Trades.UI;
