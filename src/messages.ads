--    Copyright 2016 Bartek thindil Jasicki
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

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Terminal_Interface.Curses; use Terminal_Interface.Curses;
with Game; use Game;

package Messages is

    type Message_Type is (Default, CombatMessage, TradeMessage, OrderMessage,
        CraftMessage, OtherMessage); -- Types of messages

    LastMessage : Unbounded_String := To_Unbounded_String(""); -- Last message received
    function FormatedTime return String; -- Format game time
    procedure AddMessage(Message : String; MType : Message_Type); -- Add new message to list
    function GetMessage(MessageIndex : Integer; MType : Message_Type := Default) return String; -- Return selected message
    procedure ClearMessages; -- Remove all messages;
    function MessagesAmount(MType : Message_Type := Default) return Natural; -- Return amount of selected type messages
    procedure RestoreMessage(Message : Unbounded_String; MType : Message_Type := Default); -- Restore message from save file
    function GetMessageType(MessageIndex : Integer) return Message_Type; -- Return type of selected message
    procedure ShowMessages; -- Show messages list
    function MessagesKeys(Key : Key_Code; OldState : GameStates) return GameStates; -- Handle keys in messages list

end Messages;
