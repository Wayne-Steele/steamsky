--    Copyright 2018 Bartek thindil Jasicki
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

with GNAT.String_Split; use GNAT.String_Split;
with Gtk.Window; use Gtk.Window;
with Gtk.Stack; use Gtk.Stack;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Tree_Model; use Gtk.Tree_Model;
with Gtk.List_Store; use Gtk.List_Store;
with Gtk.Combo_Box; use Gtk.Combo_Box;
with Gtk.Text_Buffer; use Gtk.Text_Buffer;
with Gtk.Text_Iter; use Gtk.Text_Iter;
with Glib; use Glib;
with Utils.UI; use Utils.UI;
with Messages; use Messages;
with Maps.UI; use Maps.UI;
with Ships; use Ships;
with Bases; use Bases;
with Items; use Items;
with Factions; use Factions;

package body Stories.UI is

   Builder: Gtkada_Builder;
   Setting: Boolean;

   procedure ShowStoryInfo(Object: access Gtkada_Builder_Record'Class) is
      StoryIndex: Positive;
      StoryBuffer: constant Gtk_Text_Buffer :=
        Gtk_Text_Buffer(Get_Object(Object, "txtstory"));
      Iter: Gtk_Text_Iter;
      TargetText: Unbounded_String;
      Tokens: Slice_Set;
      Step: Step_Data;
   begin
      if Setting then
         return;
      end if;
      StoryIndex :=
        Natural(Get_Active(Gtk_Combo_Box(Get_Object(Object, "cmbstories")))) +
        1;
      Set_Text(StoryBuffer, "");
      Get_Start_Iter(StoryBuffer, Iter);
      for StepText of FinishedStories(StoryIndex).StepsTexts loop
         Insert(StoryBuffer, Iter, To_String(StepText) & ASCII.LF & ASCII.LF);
      end loop;
      if Natural(FinishedStories(StoryIndex).StepsTexts.Length) <
        FinishedStories(StoryIndex).StepsAmount then
         Insert(StoryBuffer, Iter, To_String(GetCurrentStoryText) & ASCII.LF);
         if CurrentStory.Data /= Null_Unbounded_String then
            if CurrentStory.CurrentStep = 0 then
               Step := Stories_List(CurrentStory.Index).StartingStep;
            elsif CurrentStory.CurrentStep > 0 then
               Step :=
                 Stories_List(CurrentStory.Index).Steps
                   (CurrentStory.CurrentStep);
            else
               Step := Stories_List(CurrentStory.Index).FinalStep;
            end if;
            Create(Tokens, To_String(CurrentStory.Data), ";");
            case Step.FinishCondition is
               when ASKINBASE =>
                  if Slice_Count(Tokens) < 2 then
                     TargetText :=
                       To_Unbounded_String(" You must travel to base ") &
                       CurrentStory.Data & To_Unbounded_String(" at X:");
                     for I in SkyBases'Range loop
                        if SkyBases(I).Name = CurrentStory.Data then
                           Append
                             (TargetText, Positive'Image(SkyBases(I).SkyX));
                           Append(TargetText, " Y:");
                           Append
                             (TargetText, Positive'Image(SkyBases(I).SkyY));
                           exit;
                        end if;
                     end loop;
                  else
                     TargetText :=
                       To_Unbounded_String(" You can ask in any base. ");
                  end if;
               when DESTROYSHIP =>
                  TargetText :=
                    To_Unbounded_String(" You must find ") &
                    ProtoShips_List(Positive'Value(Slice(Tokens, 3))).Name &
                    To_Unbounded_String(" at X:") &
                    To_Unbounded_String(Slice(Tokens, 1)) &
                    To_Unbounded_String(" Y:") &
                    To_Unbounded_String(Slice(Tokens, 2));
               when EXPLORE =>
                  TargetText :=
                    To_Unbounded_String(" You must travel to X:") &
                    To_Unbounded_String(Slice(Tokens, 1)) &
                    To_Unbounded_String(" Y:") &
                    To_Unbounded_String(Slice(Tokens, 2));
               when LOOT =>
                  TargetText :=
                    To_Unbounded_String(" You must loot: ") &
                    Items_List(Positive'Value(Slice(Tokens, 1))).Name &
                    To_Unbounded_String(" from ");
                  if Slice(Tokens, 2) = "any" then
                     Append(TargetText, "any ");
                     for Faction of Factions_List loop
                        if Faction.Index =
                          GetStepData(Step.FinishData, "faction") then
                           Append(TargetText, Faction.Name);
                           Append(TargetText, " ship.");
                           exit;
                        end if;
                     end loop;
                  else
                     for ProtoShip of ProtoShips_List loop
                        if ProtoShip.Index =
                          To_Unbounded_String(Slice(Tokens, 2)) then
                           Append(TargetText, ProtoShip.Name);
                           Append(TargetText, ".");
                           exit;
                        end if;
                     end loop;
                  end if;
               when ANY =>
                  null;
            end case;
         end if;
         Insert(StoryBuffer, Iter, To_String(TargetText) & ASCII.LF);
         Show_All(Gtk_Widget(Get_Object(Builder, "btnstorycenter")));
         Show_All(Gtk_Widget(Get_Object(Builder, "btnstorydestination")));
      else
         Hide(Gtk_Widget(Get_Object(Builder, "btnstorycenter")));
         Hide(Gtk_Widget(Get_Object(Builder, "btnstorydestination")));
      end if;
   end ShowStoryInfo;

   procedure SetStoryAsDestination
     (Object: access Gtkada_Builder_Record'Class) is
      NewX, NewY: Positive := 1;
   begin
      GetStoryLocation(NewX, NewY);
      if NewX = PlayerShip.SkyX and NewY = PlayerShip.SkyY then
         ShowDialog
           ("You are at this story location now.",
            Gtk_Window(Get_Object(Object, "skymapwindow")));
         return;
      end if;
      PlayerShip.DestinationX := NewX;
      PlayerShip.DestinationY := NewY;
      AddMessage
        ("You set the travel destination for your ship.", OrderMessage);
      ShowSkyMap;
      Set_Visible_Child_Name
        (Gtk_Stack(Get_Object(Object, "gamestack")), "skymap");
      Set_Deletable(Gtk_Window(Get_Object(Object, "skymapwindow")), True);
   end SetStoryAsDestination;

   procedure ShowStory(Object: access Gtkada_Builder_Record'Class) is
      NewX, NewY: Positive := 1;
   begin
      GetStoryLocation(NewX, NewY);
      ShowSkyMap(NewX, NewY);
      Set_Visible_Child_Name
        (Gtk_Stack(Get_Object(Object, "gamestack")), "skymap");
      Set_Deletable(Gtk_Window(Get_Object(Object, "skymapwindow")), True);
   end ShowStory;

   procedure CreateStoriesUI(NewBuilder: Gtkada_Builder) is
   begin
      Builder := NewBuilder;
      Register_Handler(Builder, "Show_Story_Info", ShowStoryInfo'Access);
      Register_Handler
        (Builder, "Set_Story_As_Destination", SetStoryAsDestination'Access);
      Register_Handler(Builder, "Show_Story", ShowStory'Access);
   end CreateStoriesUI;

   procedure ShowStoriesUI is
      StoriesIter: Gtk_Tree_Iter;
      StoriesList: Gtk_List_Store;
   begin
      if FinishedStories.Length = 0 then
         Show_All(Gtk_Widget(Get_Object(Builder, "btnmenu")));
         Hide(Gtk_Widget(Get_Object(Builder, "btnclose")));
         ShowDialog
           ("You didn't discovered any story yet.",
            Gtk_Window(Get_Object(Builder, "skymapwindow")));
         return;
      end if;
      Setting := True;
      StoriesList := Gtk_List_Store(Get_Object(Builder, "storieslist"));
      Clear(StoriesList);
      for FinishedStory of FinishedStories loop
         Append(StoriesList, StoriesIter);
         Set
           (StoriesList, StoriesIter, 0,
            To_String(Stories_List(FinishedStory.Index).Name));
      end loop;
      Setting := False;
      Set_Active
        (Gtk_Combo_Box(Get_Object(Builder, "cmbstories")),
         Gint(FinishedStories.Length - 1));
      Set_Visible_Child_Name
        (Gtk_Stack(Get_Object(Builder, "gamestack")), "stories");
      Set_Deletable(Gtk_Window(Get_Object(Builder, "skymapwindow")), False);
      ShowLastMessage(Builder);
   end ShowStoriesUI;

end Stories.UI;
