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

package Utils is

   type Debug_Types is
     (None,
      Everything,
      Combat); -- Types of debug mode, which messages log to file
   DebugMode: Debug_Types := None; -- Did game is run in debug mode

   function GetRandom
     (Min: Natural;
      Max: Positive)
     return Natural; -- Return random number from Min to Max range
   procedure Log
     (Message: String;
      MessageType: Debug_Types); -- Log message (if proper type) to file in debug mode

end Utils;
