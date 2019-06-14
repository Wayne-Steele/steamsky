--    Copyright 2016-2019 Bartek thindil Jasicki
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

with Ada.Characters.Handling; use Ada.Characters.Handling;
with DOM.Core; use DOM.Core;
with DOM.Core.Documents;
with DOM.Core.Nodes; use DOM.Core.Nodes;
with DOM.Core.Elements; use DOM.Core.Elements;
with Log; use Log;
with Game; use Game;

package body Help is

   procedure LoadHelp(Reader: Tree_Reader) is
      TmpHelp: Help_Data;
      NodesList: Node_List;
      HelpData: Document;
      Action: DataAction;
      HelpIndex: Unbounded_String;
      HelpNode: Node;
   begin
      TmpHelp :=
        (Title => Null_Unbounded_String, Text => Null_Unbounded_String);
      HelpData := Get_Tree(Reader);
      NodesList :=
        DOM.Core.Documents.Get_Elements_By_Tag_Name(HelpData, "entry");
      for I in 0 .. Length(NodesList) - 1 loop
         HelpNode := Item(NodesList, I);
         if Get_Attribute(HelpNode, "action")'Length > 0 then
            Action := DataAction'Value(Get_Attribute(HelpNode, "action"));
         else
            Action := ADD;
         end if;
         HelpIndex := To_Unbounded_String(Get_Attribute(HelpNode, "index"));
         if (Action = UPDATE or Action = REMOVE) then
            if not Help_Container.Contains(Help_List, HelpIndex) then
               raise Data_Loading_Error
                 with "Can't " & To_Lower(DataAction'Image(Action)) &
                 " help '" & To_String(HelpIndex) &
                 "', there no help with that index.";
            end if;
         elsif Help_Container.Contains(Help_List, HelpIndex) then
            raise Data_Loading_Error
              with "Can't add help '" & To_String(HelpIndex) &
              "', there is one with that index.";
         end if;
         if Action /= REMOVE then
            TmpHelp.Title :=
              To_Unbounded_String(Get_Attribute(HelpNode, "title"));
            if Action = UPDATE then
               TmpHelp := Help_List(HelpIndex);
            end if;
            if Has_Child_Nodes(HelpNode) then
               TmpHelp.Text :=
                 To_Unbounded_String(Node_Value(First_Child(HelpNode)));
            end if;
            if Action /= UPDATE then
               Help_Container.Include(Help_List, HelpIndex, TmpHelp);
               LogMessage("Help added: " & To_String(HelpIndex), Everything);
            else
               Help_List(HelpIndex) := TmpHelp;
            end if;
         else
            Help_Container.Exclude(Help_List, HelpIndex);
            LogMessage("Help removed: " & To_String(HelpIndex), Everything);
         end if;
         TmpHelp :=
           (Title => Null_Unbounded_String, Text => Null_Unbounded_String);
      end loop;
   end LoadHelp;

end Help;
