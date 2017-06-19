--    Copyright 2017 Bartek thindil Jasicki
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

with Ada.Containers.Vectors; use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

package Statistics is

   type Statistics_Data is -- Data for finished goals and destroyed ships
   record
      Index: Unbounded_String; -- Index of goal or ship name
      Amount: Positive; -- Amount of finished goals or ships of that type
   end record;
   package Statistics_Container is new Vectors(Positive, Statistics_Data);
   type GameStats_Data is -- Data for game statistics
   record
      DestroyedShips: Statistics_Container
        .Vector; -- Data for all destroyed ships by player
      BasesVisited: Positive; -- Amount of visited bases
      MapVisited: Positive; -- Amount of visited map fields
      DistanceTraveled: Natural; -- Amount of map fields travelled
      CraftingOrders: Natural; -- Amount of finished crafting orders
      AcceptedMissions: Natural; -- Amount of accepted missions
      FinishedMissions: Natural; -- Amount of finished missions
      FinishedGoals: Statistics_Container
        .Vector; -- Data for all finished goals
   end record;
   GameStats: GameStats_Data; -- Game statistics

   procedure UpdateDestroyedShips
     (ShipName: Unbounded_String); -- Add new destroyed ship to list
   procedure ClearGameStats; -- Clear game statistics
   procedure UpdateFinishedGoals
     (Index: Unbounded_String); -- Add new finished goal to list

end Statistics;
