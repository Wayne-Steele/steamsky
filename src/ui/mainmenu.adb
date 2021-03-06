--    Copyright 2018-2020 Bartek thindil Jasicki
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
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Directories; use Ada.Directories;
with Ada.Calendar; use Ada.Calendar;
with Ada.Calendar.Formatting;
with Ada.Calendar.Time_Zones; use Ada.Calendar.Time_Zones;
with Ada.Containers; use Ada.Containers;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;
with Ada.Strings; use Ada.Strings;
with GNAT.Directory_Operations; use GNAT.Directory_Operations;
with GNAT.Traceback.Symbolic; use GNAT.Traceback.Symbolic;
with GNAT.String_Split; use GNAT.String_Split;
with GNAT.OS_Lib; use GNAT.OS_Lib;
with Gtkada.Builder; use Gtkada.Builder;
with Gtk.Adjustment; use Gtk.Adjustment;
with Gtk.Box; use Gtk.Box;
with Gtk.Button; use Gtk.Button;
with Gtk.Combo_Box; use Gtk.Combo_Box;
with Gtk.Combo_Box_Text; use Gtk.Combo_Box_Text;
with Gtk.Dialog; use Gtk.Dialog;
with Gtk.Enums; use Gtk.Enums;
with Gtk.Frame; use Gtk.Frame;
with Gtk.GEntry; use Gtk.GEntry;
with Gtk.Info_Bar; use Gtk.Info_Bar;
with Gtk.Label; use Gtk.Label;
with Gtk.List_Store; use Gtk.List_Store;
with Gtk.Link_Button; use Gtk.Link_Button;
with Gtk.Main;
with Gtk.Message_Dialog; use Gtk.Message_Dialog;
with Gtk.Overlay; use Gtk.Overlay;
with Gtk.Scrolled_Window; use Gtk.Scrolled_Window;
with Gtk.Stack; use Gtk.Stack;
with Gtk.Text_Buffer; use Gtk.Text_Buffer;
with Gtk.Text_View; use Gtk.Text_View;
with Gtk.Toggle_Button; use Gtk.Toggle_Button;
with Gtk.Tree_Model; use Gtk.Tree_Model;
with Gtk.Tree_Selection; use Gtk.Tree_Selection;
with Gtk.Tree_View; use Gtk.Tree_View;
with Gtk.Tree_View_Column; use Gtk.Tree_View_Column;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Window; use Gtk.Window;
with Glib; use Glib;
with Glib.Error; use Glib.Error;
with Glib.Object; use Glib.Object;
with Glib.Properties; use Glib.Properties;
with Gdk.Event;
with Gdk.Types; use Gdk.Types;
with Gdk.Types.Keysyms; use Gdk.Types.Keysyms;
with Game; use Game;
with HallOfFame; use HallOfFame;
with Ships; use Ships;
with Crew; use Crew;
with Config; use Config;
with Goals.UI; use Goals.UI;
with Maps.UI; use Maps.UI;
with Help; use Help;
with Goals; use Goals;
with Game.SaveLoad; use Game.SaveLoad;
with Utils; use Utils;
with Utils.UI; use Utils.UI;
with Log; use Log;
with Help.UI; use Help.UI;
with Factions; use Factions;
with Events; use Events;
with Themes; use Themes;
with DebugUI; use DebugUI;
with BasesTypes; use BasesTypes;

package body MainMenu is

   -- ****iv* MainMenu/Builder
   -- FUNCTION
   -- Gtkada_Builder used for creating UI
   -- SOURCE
   Builder: Gtkada_Builder;
   -- ****
   -- ****iv* MainMenu/AllNews
   -- FUNCTION
   -- If true, show all news, not only from last version. Default is false
   -- SOURCE
   AllNews: Boolean := False;
   -- ****
   -- ****iv* MainMenu/Setting
   -- FUNCTION
   -- If true, UI is in setting state. Default is false
   -- SOURCE
   Setting: Boolean := False;
   -- ****
   -- ****iv* MainMenu/DataError
   -- FUNCTION
   -- Used to store errors related to loading the game data
   -- SOURCE
   DataError: Unbounded_String;
   -- ****
   -- ****iv* MainMenu/AdjNames
   -- FUNCTION
   -- Array of Gtk_Adjustments names for the game difficulty
   -- SOURCE
   AdjNames: constant array(Positive range <>) of Unbounded_String :=
     (To_Unbounded_String("adjenemydamage"),
      To_Unbounded_String("adjplayerdamage"),
      To_Unbounded_String("adjenemymelee"),
      To_Unbounded_String("adjplayermelee"),
      To_Unbounded_String("adjexperience"),
      To_Unbounded_String("adjreputation"), To_Unbounded_String("adjupdate"),
      To_Unbounded_String("adjprices"));
   -- ****

   -- ****if* MainMenu/BaseTypeName
   -- FUNCTION
   -- Type of base for new game
   -- SOURCE
   BaseTypeName: Unbounded_String;
   -- ****

   -- ****iv* MainMenu/ErrorDialog
   -- FUNCTION
   -- Gtk dialog used to show information about the crash of the game.
   -- SOURCE
   ErrorDialog: Gtk_Dialog;
   -- ****

   -- ****if* MainMenu/Quit
   -- FUNCTION
   -- Quit from the game
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure Quit(Object: access Gtkada_Builder_Record'Class) is
   -- ****
   begin
      Unref(Object);
      Gtk.Main.Main_Quit;
   end Quit;

   -- ****if* MainMenu/RefreshSavesList
   -- FUNCTION
   -- Refresh list of available saved games
   -- SOURCE
   procedure RefreshSavesList is
      -- ****
      SavesList: constant Gtk_List_Store :=
        Gtk_List_Store(Get_Object(Builder, "saveslist"));
      Iter: Gtk_Tree_Iter;
      Files: Search_Type;
      FoundFile: Directory_Entry_Type;
      Tokens: Slice_Set;
   begin
      Clear(SavesList);
      Start_Search(Files, To_String(SaveDirectory), "*.sav");
      while More_Entries(Files) loop
         Get_Next_Entry(Files, FoundFile);
         Create(Tokens, Simple_Name(FoundFile), "_");
         Append(SavesList, Iter);
         Set(SavesList, Iter, 0, Slice(Tokens, 1));
         Set(SavesList, Iter, 1, Slice(Tokens, 2));
         Set
           (SavesList, Iter, 2,
            Ada.Calendar.Formatting.Image
              (Modification_Time(FoundFile), False, UTC_Time_Offset));
         Set(SavesList, Iter, 3, Full_Name(FoundFile));
      end loop;
      End_Search(Files);
   end RefreshSavesList;

   -- ****if* MainMenu/LoadFile
   -- FUNCTION
   -- Load license, readme, contributing, etc files to UI
   -- PARAMETERS
   -- FileName - Name of file to load
   -- SOURCE
   procedure LoadFile(FileName: String) is
      -- ****
      LicenseFile: File_Type;
      LicenseText: Unbounded_String := Null_Unbounded_String;
   begin
      if not Exists(To_String(DocDirectory) & FileName) then
         LicenseText :=
           To_Unbounded_String
             ("Can't find file to load. Did '" & FileName & "' file is in '" &
              To_String(DocDirectory) & "' directory?");
      else
         Open(LicenseFile, In_File, To_String(DocDirectory) & FileName);
         while not End_Of_File(LicenseFile) loop
            Append(LicenseText, Get_Line(LicenseFile));
            Append(LicenseText, LF);
         end loop;
         Close(LicenseFile);
      end if;
      Set_Text
        (Gtk_Text_Buffer(Get_Object(Builder, "licensebuffer")),
         To_String(LicenseText));
   end LoadFile;

   -- ****if* MainMenu/SetBaseType
   -- FUNCTION
   -- Set base type for new game based on the game settings
   -- PARAMETERS
   -- Model - Gtk_Tree_Model with bases types
   -- Path  - Gtk_Tree_Path to currently selected base type. Unused
   -- Iter  - Gtk_Tree_Iter to currently selected base type
   -- RESULT
   -- Return true if current base type was set as default, otherwise false
   -- SOURCE
   function SetBaseType
     (Model: Gtk_Tree_Model; Path: Gtk_Tree_Path; Iter: Gtk_Tree_Iter)
      return Boolean is
      pragma Unreferenced(Path);
      -- ****
   begin
      if Get_String(Model, Iter, 0) = To_String(BaseTypeName) then
         Set_Active_Iter
           (Gtk_Combo_Box(Get_Object(Builder, "cmbbasetype")), Iter);
         return True;
      end if;
      return False;
   end SetBaseType;

   -- ****if* MainMenu/ShowPage
   -- FUNCTION
   -- Show selected page to the player
   -- PARAMETERS
   -- User_Data - Button pressed
   -- SOURCE
   procedure ShowPage(User_Data: access GObject_Record'Class) is
   -- ****
   begin
      if User_Data = Get_Object(Builder, "btnnewgame") then
         if Get_Text(Gtk_GEntry(Get_Object(Builder, "entrycharactername"))) =
           "" then
            Set_Text
              (Gtk_Entry(Get_Object(Builder, "entrycharactername")),
               To_String(NewGameSettings.PlayerName));
         end if;
         if Get_Text(Gtk_GEntry(Get_Object(Builder, "entryshipname"))) =
           "" then
            Set_Text
              (Gtk_Entry(Get_Object(Builder, "entryshipname")),
               To_String(NewGameSettings.ShipName));
         end if;
         if NewGameSettings.PlayerGender = 'M' then
            Set_Active(Gtk_Combo_Box(Get_Object(Builder, "cmbgender")), 0);
         else
            Set_Active(Gtk_Combo_Box(Get_Object(Builder, "cmbgender")), 1);
         end if;
         if not Set_Active_Id
             (Gtk_Combo_Box(Get_Object(Builder, "cmbfaction")),
              To_String(NewGameSettings.PlayerFaction)) then
            return;
         end if;
         if Factions_Container.Contains
             (Factions_List, NewGameSettings.PlayerFaction) then
            for I in Factions_List(NewGameSettings.PlayerFaction).Careers
              .Iterate loop
               if Careers_Container.Key(I) = NewGameSettings.PlayerCareer then
                  if not Set_Active_Id
                      (Gtk_Combo_Box_Text(Get_Object(Builder, "cmbcareer")),
                       To_String(Careers_Container.Key(I))) then
                     return;
                  end if;
                  exit;
               end if;
            end loop;
         end if;
         if NewGameSettings.StartingBase /= "Any" then
            for I in BasesTypes_List.Iterate loop
               if BasesTypes_Container.Key(I) =
                 NewGameSettings.StartingBase then
                  BaseTypeName := BasesTypes_List(I).Name;
                  exit;
               end if;
            end loop;
            Foreach
              (Gtk_List_Store(Get_Object(Builder, "basesstore")),
               SetBaseType'Access);
         else
            Set_Active(Gtk_Combo_Box(Get_Object(Builder, "cmbbasetype")), 0);
         end if;
         CreateGoalsMenu;
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page1");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "entrycharactername")));
      elsif User_Data = Get_Object(Builder, "btnback") then
         ShowMainMenu;
      elsif User_Data = Get_Object(Builder, "btnhalloffame") then
         declare
            HofList: constant Gtk_List_Store :=
              Gtk_List_Store(Get_Object(Builder, "hoflist"));
            Iter: Gtk_Tree_Iter;
         begin
            Clear(HofList);
            for I in HallOfFame_Array'Range loop
               exit when HallOfFame_Array(I).Name = Null_Unbounded_String;
               Append(HofList, Iter);
               Set(HofList, Iter, 0, Gint(I));
               Set(HofList, Iter, 1, To_String(HallOfFame_Array(I).Name));
               Set(HofList, Iter, 2, Gint(HallOfFame_Array(I).Points));
               Set
                 (HofList, Iter, 3,
                  To_String(HallOfFame_Array(I).DeathReason));
            end loop;
         end;
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page2");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback2")));
      elsif User_Data = Get_Object(Builder, "btnnews") then
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page3");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnfull")));
      elsif User_Data = Get_Object(Builder, "btnabout") then
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page4");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback4")));
      elsif User_Data = Get_Object(Builder, "btnlicense") then
         LoadFile("COPYING");
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page5");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback5")));
      elsif User_Data = Get_Object(Builder, "btnloadgame") then
         RefreshSavesList;
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page6");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnload")));
         Set_Cursor
           (Gtk_Tree_View(Get_Object(Builder, "treesaves")),
            Gtk_Tree_Path_New_From_String("0"),
            Gtk_Tree_View_Column(Get_Object(Builder, "columnplayername")),
            False);
      elsif User_Data = Get_Object(Builder, "btncontribute") then
         LoadFile("CONTRIBUTING.md");
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page5");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback5")));
      elsif User_Data = Get_Object(Builder, "btnmodding") then
         LoadFile("MODDING.md");
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page5");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback5")));
      elsif User_Data = Get_Object(Builder, "btnreadme") then
         LoadFile("README.md");
         Set_Visible_Child_Name
           (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page5");
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnback5")));
      end if;
   end ShowPage;

   -- ****if* MainMenu/UpdateNews
   -- FUNCTION
   -- Refresh list of the game news
   -- SOURCE
   procedure UpdateNews is
      -- ****
      ChangesFile: File_Type;
      NewsText: Unbounded_String := Null_Unbounded_String;
      FileText: Unbounded_String;
   begin
      if not Exists(To_String(DocDirectory) & "CHANGELOG.md") then
         NewsText :=
           To_Unbounded_String
             ("Can't find changelog file. Did 'CHANGELOG.md' file is in '" &
              To_String(DocDirectory) & "' directory?");
      else
         Open(ChangesFile, In_File, To_String(DocDirectory) & "CHANGELOG.md");
         Set_Line(ChangesFile, 6);
         while not End_Of_File(ChangesFile) loop
            FileText := To_Unbounded_String(Get_Line(ChangesFile));
            if Length(FileText) > 1 and not AllNews then
               exit when Slice(FileText, 1, 3) = "## ";
            end if;
            Append(NewsText, FileText);
            Append(NewsText, LF);
         end loop;
         Close(ChangesFile);
      end if;
      Set_Text
        (Gtk_Text_Buffer(Get_Object(Builder, "newsbuffer")),
         To_String(NewsText));
   end UpdateNews;

   -- ****if* MainMenu/ShowAllNews
   -- Show all the game news
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure ShowAllNews(Object: access Gtkada_Builder_Record'Class) is
   -- ****
   begin
      AllNews := not AllNews;
      UpdateNews;
      if AllNews then
         Set_Label
           (Gtk_Button(Get_Object(Object, "btnfull")),
            "Show only newest changes");
      else
         Set_Label
           (Gtk_Button(Get_Object(Object, "btnfull")), "Show all changes");
      end if;
   end ShowAllNews;

   -- ****if* MainMenu/RandomName
   -- FUNCTION
   -- Generate random player and ship names, baesd on selected faction
   -- PARAMETERS
   -- User_Data - Text entry in which Enter key was pressed
   -- SOURCE
   procedure RandomName(User_Data: access GObject_Record'Class) is
      -- ****
      FactionIndex: constant Unbounded_String :=
        To_Unbounded_String
          (Get_Active_Id(Gtk_Combo_Box(Get_Object(Builder, "cmbfaction"))));
   begin
      if User_Data = Get_Object(Builder, "entryshipname") then
         Set_Text
           (Gtk_Entry(User_Data), To_String(GenerateShipName(FactionIndex)));
      else
         if Get_Active(Gtk_Combo_Box(Get_Object(Builder, "cmbgender"))) =
           0 then
            Set_Text
              (Gtk_Entry(User_Data),
               To_String(GenerateMemberName('M', FactionIndex)));
         else
            Set_Text
              (Gtk_Entry(User_Data),
               To_String(GenerateMemberName('F', FactionIndex)));
         end if;
      end if;
   end RandomName;

   -- ****if* MainMenu/ShowGoals
   -- Show goal selection UI
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI (unused)
   -- SOURCE
   procedure ShowGoals(Object: access Gtkada_Builder_Record'Class) is
      pragma Unreferenced(Object);
      -- ****
   begin
      ShowGoalsMenu;
   end ShowGoals;

   -- ****if* MainMenu/StartGame
   -- FUNCTION
   -- Initialize the game data and UI
   -- SOURCE
   procedure StartGame is
   -- ****
   begin
      GenerateTraders;
      Hide(Gtk_Widget(Get_Object(Builder, "mainmenuwindow")));
      CreateHelpUI;
      CreateGoalsMenu;
      if DebugMode = Menu or DebugMode = Everything then
         CreateDebugUI;
      end if;
      CreateSkyMap;
   end StartGame;

   -- ****if* MainMenu/LoadGame
   -- FUNCTION
   -- Load selected file with the game data
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure LoadGame(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      SavesIter: Gtk_Tree_Iter;
      SavesModel: Gtk_Tree_Model;
   begin
      Get_Selected
        (Get_Selection(Gtk_Tree_View(Get_Object(Object, "treesaves"))),
         SavesModel, SavesIter);
      if SavesIter = Null_Iter then
         return;
      end if;
      SaveName := To_Unbounded_String(Get_String(SavesModel, SavesIter, 3));
      LoadGame;
      StartGame;
   end LoadGame;

   -- ****if* MainMenu/RandomDifficulty
   -- FUNCTION
   -- Set random difficulty levels for the game
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure RandomDifficulty(Object: access Gtkada_Builder_Record'Class) is
   -- ****
   begin
      Setting := True;
      for Name of AdjNames loop
         Set_Value
           (Gtk_Adjustment(Get_Object(Object, To_String(Name))),
            Gdouble(GetRandom(1, 500)));
      end loop;
      Set_Active(Gtk_Combo_Box(Get_Object(Object, "cmbdifficulty")), 5);
      Setting := False;
   end RandomDifficulty;

   -- ****if* MainMenu/NewGame
   -- FUNCTION
   -- Start a new game
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure NewGame(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      Gender: Character;
   begin
      if Get_Active(Gtk_Combo_Box(Get_Object(Object, "cmbgender"))) = 0 then
         Gender := 'M';
      else
         Gender := 'F';
      end if;
      if Get_Active
          (Gtk_Toggle_Button(Get_Object(Object, "cbtndifficulty"))) then
         RandomDifficulty(Object);
      end if;
      NewGameSettings :=
        (PlayerName =>
           To_Unbounded_String
             (Get_Text(Gtk_Entry(Get_Object(Object, "entrycharactername")))),
         PlayerGender => Gender,
         ShipName =>
           To_Unbounded_String
             (Get_Text(Gtk_Entry(Get_Object(Object, "entryshipname")))),
         PlayerFaction =>
           To_Unbounded_String
             (Get_Active_Id
                (Gtk_Combo_Box_Text(Get_Object(Object, "cmbfaction")))),
         PlayerCareer =>
           To_Unbounded_String
             (Get_Active_Id
                (Gtk_Combo_Box_Text(Get_Object(Object, "cmbcareer")))),
         StartingBase =>
           To_Unbounded_String
             (Get_String
                (Gtk_List_Store(Get_Object(Object, "basesstore")),
                 Get_Active_Iter
                   (Gtk_Combo_Box(Get_Object(Object, "cmbbasetype"))),
                 0)),
         EnemyDamageBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjenemydamage"))) /
              100.0),
         PlayerDamageBonus =>
           Float
             (Get_Value
                (Gtk_Adjustment(Get_Object(Object, "adjplayerdamage"))) /
              100.0),
         EnemyMeleeDamageBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjenemymelee"))) /
              100.0),
         PlayerMeleeDamageBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjplayermelee"))) /
              100.0),
         ExperienceBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjexperience"))) /
              100.0),
         ReputationBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjreputation"))) /
              100.0),
         UpgradeCostBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjupdate"))) /
              100.0),
         PricesBonus =>
           Float
             (Get_Value(Gtk_Adjustment(Get_Object(Object, "adjprices"))) /
              100.0),
         DifficultyLevel =>
           Natural
             (Get_Active
                (Gtk_Combo_Box_Text(Get_Object(Object, "cmbdifficulty")))));
      for I in BasesTypes_List.Iterate loop
         if BasesTypes_List(I).Name = NewGameSettings.StartingBase then
            NewGameSettings.StartingBase := BasesTypes_Container.Key(I);
            exit;
         end if;
      end loop;
      NewGame;
      StartGame;
   end NewGame;

   -- ****if* MainMenu/DeleteGame
   -- FUNCTION
   -- Delete selected file with game data
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure DeleteGame(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      SavesIter: Gtk_Tree_Iter;
      SavesModel: Gtk_Tree_Model;
   begin
      if not ShowConfirmDialog
          ("Are you sure you want delete this savegame?",
           Gtk_Window(Get_Object(Object, "mainmenuwindow"))) then
         return;
      end if;
      Get_Selected
        (Get_Selection(Gtk_Tree_View(Get_Object(Object, "treesaves"))),
         SavesModel, SavesIter);
      if SavesIter = Null_Iter then
         return;
      end if;
      SaveName := To_Unbounded_String(Get_String(SavesModel, SavesIter, 3));
      Delete_File(To_String(SaveName));
      RefreshSavesList;
      if N_Children(SavesModel) = 0 then
         ShowPage(Get_Object(Builder, "btnback"));
      else
         Set_Cursor
           (Gtk_Tree_View(Get_Object(Builder, "treesaves")),
            Gtk_Tree_Path_New_From_String("0"),
            Gtk_Tree_View_Column(Get_Object(Builder, "columnplayername")),
            False);
      end if;
   end DeleteGame;

   -- ****if* MainMenu/ShowFactionDescription
   -- FUNCTION
   -- Updated faction description when player select new faction
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure ShowFactionDescription
     (Object: access Gtkada_Builder_Record'Class) is
      -- ****
      FactionIndex: constant Unbounded_String :=
        To_Unbounded_String
          (Get_Active_Id(Gtk_Combo_Box(Get_Object(Object, "cmbfaction"))));
      CareerComboBox: constant Gtk_Combo_Box_Text :=
        Gtk_Combo_Box_Text(Get_Object(Object, "cmbcareer"));
   begin
      if FactionIndex = Null_Unbounded_String then
         return;
      end if;
      if FactionIndex = To_Unbounded_String("random") then
         Hide(Gtk_Widget(Get_Object(Object, "cmbcareer")));
         Hide(Gtk_Widget(Get_Object(Object, "lblcareer")));
         Set_Label
           (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
            Get_Tooltip_Text(Gtk_Widget(Get_Object(Object, "cmbfaction"))) &
            LF & LF &
            "Faction and career will be randomly selected for you during creating new game. Not recommended for new player.");
         return;
      end if;
      Remove_All(CareerComboBox);
      for I in Factions_List(FactionIndex).Careers.Iterate loop
         Append
           (CareerComboBox, To_String(Careers_Container.Key(I)),
            To_String(Factions_List(FactionIndex).Careers(I).Name));
      end loop;
      Append(CareerComboBox, "random", "Random");
      Setting := True;
      Set_Active(Gtk_Combo_Box(CareerComboBox), 0);
      Setting := False;
      Show_All(Gtk_Widget(Get_Object(Object, "cmbcareer")));
      Show_All(Gtk_Widget(Get_Object(Object, "lblcareer")));
      Set_Label
        (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
         Get_Tooltip_Text(Gtk_Widget(Get_Object(Object, "cmbfaction"))) & LF &
         LF & To_String(Factions_List(FactionIndex).Description));
      if Factions_List(FactionIndex).Flags.Contains
          (To_Unbounded_String("nogender")) then
         Set_Active(Gtk_Combo_Box(Get_Object(Object, "cmbgender")), 0);
         Hide(Gtk_Widget(Get_Object(Object, "cmbgender")));
         Hide(Gtk_Widget(Get_Object(Object, "lblgender")));
      else
         Show_All(Gtk_Widget(Get_Object(Object, "cmbgender")));
         Show_All(Gtk_Widget(Get_Object(Object, "lblgender")));
      end if;
      declare
         BasesList: constant Gtk_List_Store :=
           Gtk_List_Store(Get_Object(Builder, "basesstore"));
         BaseIter: Gtk_Tree_Iter;
      begin
         BasesList.Clear;
         Append(BasesList, BaseIter);
         Set(BasesList, BaseIter, 0, "Any");
         Set
           (BasesList, BaseIter, 1,
            "Start game in randomly selected base type.");
         for I in Factions_List(FactionIndex).BasesTypes.Iterate loop
            Append(BasesList, BaseIter);
            Set
              (BasesList, BaseIter, 0,
               To_String(BasesTypes_List(BaseType_Container.Key(I)).Name));
            Set
              (BasesList, BaseIter, 1,
               To_String
                 (BasesTypes_List(BaseType_Container.Key(I)).Description));
         end loop;
         Setting := True;
         Set_Active(Gtk_Combo_Box(Get_Object(Object, "cmbbasetype")), 0);
         Setting := False;
      end;
   end ShowFactionDescription;

   -- ****if* MainMenu/ShowCareerDescription
   -- FUNCTION
   -- Show selected career description
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure ShowCareerDescription
     (Object: access Gtkada_Builder_Record'Class) is
      -- ****
      FactionIndex: constant Unbounded_String :=
        To_Unbounded_String
          (Get_Active_Id(Gtk_Combo_Box(Get_Object(Object, "cmbfaction"))));
      CareerIndex: constant Unbounded_String :=
        To_Unbounded_String
          (Get_Active_Id(Gtk_Combo_Box(Get_Object(Object, "cmbcareer"))));
   begin
      if FactionIndex = Null_Unbounded_String or
        CareerIndex = Null_Unbounded_String or Setting then
         return;
      end if;
      if CareerIndex /= To_Unbounded_String("random") then
         Set_Label
           (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
            Get_Tooltip_Text(Gtk_Widget(Get_Object(Object, "cmbcareer"))) &
            LF & LF &
            To_String
              (Factions_List(FactionIndex).Careers(CareerIndex).Description));
      else
         Set_Label
           (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
            Get_Tooltip_Text(Gtk_Widget(Get_Object(Object, "cmbcareer"))) &
            LF & LF &
            "Career will be randomly selected for you during creating new game. Not recommended for new player.");
      end if;
   end ShowCareerDescription;

   -- ****if* MainMenu/ShowBaseDescription
   -- FUNCTION
   -- Show selected base type description, when player select new type
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure ShowBaseDescription(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      BaseTypeIndex: constant Integer :=
        Integer(Get_Active(Gtk_Combo_Box(Get_Object(Object, "cmbbasetype"))));
      BasesTypesList: constant Gtk_List_Store :=
        Gtk_List_Store(Get_Object(Object, "basesstore"));
   begin
      if BaseTypeIndex = -1 or Setting then
         return;
      end if;
      Set_Label
        (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
         Get_Tooltip_Text(Gtk_Widget(Get_Object(Object, "cmbbasetype"))) & LF &
         LF &
         Get_String
           (BasesTypesList,
            Get_Iter_From_String(BasesTypesList, Integer'Image(BaseTypeIndex)),
            1));
   end ShowBaseDescription;

   -- ****if* MainMenu/NewGameKeyPressed
   -- FUNCTION
   -- Use Page Up and Page Down buttons to scroll new game UI
   -- PARAMETERS
   -- Self  - Gtk_Widget on which key was pressed (unused)
   -- Event - Details about key pressed event
   -- RESULT
   -- This function always return false
   -- SOURCE
   function NewGameKeyPressed
     (Self: access Gtk_Widget_Record'Class; Event: Gdk.Event.Gdk_Event_Key)
      return Boolean is
      pragma Unreferenced(Self);
      -- ****
      ScrollBar: constant Gtk_Adjustment :=
        Get_Vadjustment
          (Gtk_Scrolled_Window(Get_Object(Builder, "scrollinfo")));
   begin
      if Event.Keyval = GDK_Page_Up then
         Set_Value
           (ScrollBar, Get_Value(ScrollBar) - Get_Page_Increment(ScrollBar));
      elsif Event.Keyval = GDK_Page_Down then
         Set_Value
           (ScrollBar, Get_Value(ScrollBar) + Get_Page_Increment(ScrollBar));
      end if;
      return False;
   end NewGameKeyPressed;

   -- ****if* MainMenu/UpdateInfo
   -- FUNCTION
   -- Update new game info
   -- PARAMETERS
   -- User_Data - UI element which was selected
   -- RESULT
   -- This function always return false
   -- SEE ALSO
   -- UpdateInfoProc
   -- SOURCE
   function UpdateInfo
     (User_Data: access GObject_Record'Class) return Boolean is
   -- ****
   begin
      Set_Label
        (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
         Get_Tooltip_Text(Gtk_Widget(User_Data)));
      return False;
   end UpdateInfo;

   -- ****if* MainMenu/UpdateInfoProc
   -- FUNCTION
   -- Update new game info
   -- PARAMETERS
   -- User_Data - UI element which was selected
   -- SEE ALSO
   -- UpdateInfo
   -- SOURCE
   procedure UpdateInfoProc(User_Data: access GObject_Record'Class) is
   -- ****
   begin
      Set_Label
        (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
         Get_Tooltip_Text(Gtk_Widget(User_Data)));
   end UpdateInfoProc;

   -- ****if* MainMenu/UpdateSummary
   -- FUNCTION
   -- Update amount of bonus or malus to the game point from difficulty
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure UpdateSummary(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      MalusNames: constant array(Positive range <>) of Unbounded_String :=
        (To_Unbounded_String("adjplayerdamage"),
         To_Unbounded_String("adjplayermelee"),
         To_Unbounded_String("adjexperience"),
         To_Unbounded_String("adjreputation"));
      Bonus, Value: Integer := 0;
   begin
      for Name of AdjNames loop
         Value :=
           Natural
             (Get_Value(Gtk_Adjustment(Get_Object(Object, To_String(Name)))));
         for I in MalusNames'Range loop
            if Name = MalusNames(I) then
               if Value < 100 then
                  Value := 100 + ((100 - Value) * 4);
               elsif Value > 100 then
                  Value := 100 - Value;
               end if;
               exit;
            end if;
         end loop;
         Bonus := Bonus + Value;
      end loop;
      Bonus := Bonus / AdjNames'Length;
      if Bonus < 1 then
         Bonus := 1;
      end if;
      Set_Text
        (Gtk_Label(Get_Object(Object, "lblbonuspoints")),
         "Total gained points:" & Integer'Image(Bonus) & "%");
      Setting := True;
      Set_Active(Gtk_Combo_Box_Text(Get_Object(Object, "cmbdifficulty")), 5);
      Setting := False;
   end UpdateSummary;

   -- ****if* MainMenu/RandomDifficultyToggled
   -- FUNCTION
   -- Show or hide info about bonus to the game points on toggle random
   -- difficulty
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure RandomDifficultyToggled
     (Object: access Gtkada_Builder_Record'Class) is
      -- ****
      ToggleButton: constant GObject := Get_Object(Object, "cbtndifficulty");
   begin
      Set_Label
        (Gtk_Label(Get_Object(Builder, "lblnewgameinfo")),
         Get_Tooltip_Text(Gtk_Widget(ToggleButton)));
      if Get_Active(Gtk_Toggle_Button(ToggleButton)) then
         Set_Text
           (Gtk_Label(Get_Object(Object, "lblbonuspoints")),
            "Total gained points: unknown");
      else
         UpdateSummary(Object);
      end if;
   end RandomDifficultyToggled;

   -- ****if* MainMenu/SetDifficulty
   -- FUNCTION
   -- Set presetted level of the game difficulty
   -- PARAMETERS
   -- Object - Gtkada_Builder used to create UI
   -- SOURCE
   procedure SetDifficulty(Object: access Gtkada_Builder_Record'Class) is
      -- ****
      type DifficultyArray is array(1 .. 8) of Gdouble;
      CurrentLevel: constant Gint :=
        Get_Active(Gtk_Combo_Box_Text(Get_Object(Object, "cmbdifficulty")));
      procedure UpdateDifficulty(Values: DifficultyArray) is
      begin
         for I in AdjNames'Range loop
            Set_Value
              (Gtk_Adjustment(Get_Object(Object, To_String(AdjNames(I)))),
               Values(I));
         end loop;
      end UpdateDifficulty;
   begin
      Setting := True;
      case CurrentLevel is
         when 0 =>
            UpdateDifficulty
              ((10.0, 450.0, 10.0, 450.0, 450.0, 450.0, 10.0, 10.0));
         when 1 =>
            UpdateDifficulty
              ((50.0, 250.0, 50.0, 250.0, 250.0, 250.0, 50.0, 50.0));
         when 2 =>
            UpdateDifficulty
              ((100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0));
         when 3 =>
            UpdateDifficulty
              ((250.0, 50.0, 250.0, 50.0, 50.0, 50.0, 250.0, 250.0));
         when 4 =>
            UpdateDifficulty
              ((450.0, 10.0, 450.0, 10.0, 10.0, 10.0, 450.0, 450.0));
         when others =>
            null;
      end case;
      Set_Active
        (Gtk_Combo_Box_Text(Get_Object(Object, "cmbdifficulty")),
         CurrentLevel);
      Setting := False;
   end SetDifficulty;

   -- ****if* MainMenu/CreateErrorUI
   -- FUNCTION
   -- Create error reporting UI
   -- SOURCE
   procedure CreateErrorUI is
      -- ****
      TextView: constant Gtk_Text_View := Gtk_Text_View_New;
      Scroll: constant Gtk_Scrolled_Window := Gtk_Scrolled_Window_New;
      Frame: constant Gtk_Frame := Gtk_Frame_New("Technical information:");
      Label: Gtk_Label;
      LinkButton: Gtk_Link_Button;
      ErrorBox: Gtk_Vbox;
   begin
      ErrorDialog :=
        Gtk_Dialog_New
          ("Steam Sky - error",
           Gtk_Window(Get_Object(Builder, "mainmenuwindow")), Modal);
      Set_Position(ErrorDialog, Win_Pos_Center_Always);
      if not Set_Icon_From_File(ErrorDialog, "data/ui/images/icon.png") then
         Ada.Text_IO.Put_Line("Can't set icon for the error dialog.");
      end if;
      Set_Default_Size(ErrorDialog, 500, -1);
      ErrorBox := Get_Content_Area(ErrorDialog);
      Label :=
        Gtk_Label_New
          ("Oops, something bad happens and the game has crashed. Game should save your progress, but better verify this yourself. Also, please, remember what you were doing before the crash and report this problem at");
      Set_Line_Wrap(Label, True);
      Set_Property(Label, Name_Property, "normalfont");
      Pack_Start(ErrorBox, Label, False);
      LinkButton :=
        Gtk_Link_Button_New("https://github.com/thindil/steamsky/issues");
      Set_Relief(LinkButton, Relief_None);
      Set_Halign(LinkButton, Align_Center);
      Set_Property(LinkButton, Name_Property, "flatbutton");
      Pack_Start(ErrorBox, LinkButton, False);
      Label :=
        Gtk_Label_New
          ("or if you prefer, on one of the game community options:");
      Set_Line_Wrap(Label, True);
      Set_Property(Label, Name_Property, "normalfont");
      Pack_Start(ErrorBox, Label, False);
      LinkButton := Gtk_Link_Button_New("https://thindil.itch.io/steam-sky");
      Set_Relief(LinkButton, Relief_None);
      Set_Halign(LinkButton, Align_Center);
      Set_Property(LinkButton, Name_Property, "flatbutton");
      Pack_Start(ErrorBox, LinkButton, False);
      Label := Gtk_Label_New("and attach (if possible) file 'error.log'");
      Set_Line_Wrap(Label, True);
      Set_Property(Label, Name_Property, "normalfont");
      Pack_Start(ErrorBox, Label, False);
      Add(Scroll, TextView);
      Add(Frame, Scroll);
      Set_Property(Frame, Name_Property, "normalfont");
      Set_Property(TextView, Name_Property, "normalfont");
      Pack_Start(ErrorBox, Frame);
      if Add_Button(ErrorDialog, "Close", Gtk_Response_Close) = null then
         raise Program_Error with "Can't add Close button to error dialog";
      end if;
   end CreateErrorUI;

   procedure CreateMainMenu is
      Error: aliased GError;
      AdjValues: constant array(Positive range <>) of Gdouble :=
        (Gdouble(NewGameSettings.EnemyDamageBonus),
         Gdouble(NewGameSettings.PlayerDamageBonus),
         Gdouble(NewGameSettings.EnemyMeleeDamageBonus),
         Gdouble(NewGameSettings.PlayerMeleeDamageBonus),
         Gdouble(NewGameSettings.ExperienceBonus),
         Gdouble(NewGameSettings.ReputationBonus),
         Gdouble(NewGameSettings.UpgradeCostBonus),
         Gdouble(NewGameSettings.PricesBonus));
   begin
      LoadThemes;
      SetFontSize(ALLFONTS);
      Gtk_New(Builder);
      if Add_From_File
          (Builder,
           To_String(DataDirectory) & "ui" & Dir_Separator & "mainmenu.glade",
           Error'Access) =
        Guint(0) then
         Put_Line("Error : " & Get_Message(Error));
         return;
      end if;
      CreateErrorUI;
      Register_Handler(Builder, "Main_Quit", Quit'Access);
      Register_Handler(Builder, "Show_All_News", ShowAllNews'Access);
      Register_Handler(Builder, "Hide_Window", HideWindow'Access);
      Register_Handler(Builder, "Random_Name", RandomName'Access);
      Register_Handler(Builder, "Show_Goals", ShowGoals'Access);
      Register_Handler(Builder, "Load_Game", LoadGame'Access);
      Register_Handler(Builder, "New_Game", NewGame'Access);
      Register_Handler(Builder, "Show_Page", ShowPage'Access);
      Register_Handler(Builder, "Delete_Game", DeleteGame'Access);
      Register_Handler
        (Builder, "Show_Faction_Description", ShowFactionDescription'Access);
      Register_Handler
        (Builder, "Show_Career_Description", ShowCareerDescription'Access);
      Register_Handler
        (Builder, "Show_Base_Description", ShowBaseDescription'Access);
      Register_Handler(Builder, "Update_Info", UpdateInfo'Access);
      Register_Handler(Builder, "Update_Info_Proc", UpdateInfoProc'Access);
      Register_Handler(Builder, "Random_Difficulty", RandomDifficulty'Access);
      Register_Handler(Builder, "Update_Summary", UpdateSummary'Access);
      Register_Handler
        (Builder, "Random_Difficulty_Toggled", RandomDifficultyToggled'Access);
      Register_Handler(Builder, "Set_Difficulty", SetDifficulty'Access);
      Do_Connect(Builder);
      SetUtilsBuilder(Builder);
      Set_Label(Gtk_Label(Get_Object(Builder, "lblversion")), GameVersion);
      if HallOfFame_Array(1).Name = Null_Unbounded_String then
         Hide(Gtk_Widget(Get_Object(Builder, "btnhalloffame")));
      end if;
      UpdateNews;
      Set_Text
        (Gtk_Entry(Get_Object(Builder, "entrycharactername")),
         To_String(NewGameSettings.PlayerName));
      Set_Text
        (Gtk_Entry(Get_Object(Builder, "entryshipname")),
         To_String(NewGameSettings.ShipName));
      DataError := To_Unbounded_String(LoadGameData);
      declare
         FactionComboBox: constant Gtk_Combo_Box_Text :=
           Gtk_Combo_Box_Text(Get_Object(Builder, "cmbfaction"));
      begin
         Remove_All(FactionComboBox);
         for I in Factions_List.Iterate loop
            if Factions_List(I).Careers.Length > 0 then
               Append
                 (FactionComboBox, To_String(Factions_Container.Key(I)),
                  To_String(Factions_List(I).Name));
            end if;
         end loop;
         Append(FactionComboBox, "random", "Random");
         Set_Active(FactionComboBox, 0);
      end;
      declare
         BasesList: constant Gtk_List_Store :=
           Gtk_List_Store(Get_Object(Builder, "basesstore"));
         BaseIter: Gtk_Tree_Iter;
      begin
         for BaseType of BasesTypes_List loop
            Append(BasesList, BaseIter);
            Set(BasesList, BaseIter, 0, To_String(BaseType.Name));
            Set(BasesList, BaseIter, 1, To_String(BaseType.Description));
         end loop;
      end;
      Setting := True;
      Set_Active
        (Gtk_Combo_Box_Text(Get_Object(Builder, "cmbdifficulty")),
         Gint(NewGameSettings.DifficultyLevel));
      for I in AdjNames'Range loop
         Set_Value
           (Gtk_Adjustment(Get_Object(Builder, To_String(AdjNames(I)))),
            (AdjValues(I) * 100.0));
      end loop;
      Setting := False;
      On_Key_Press_Event
        (Gtk_Widget(Get_Object(Builder, "newgamebox")),
         NewGameKeyPressed'Access);
      declare
         Label: constant Gtk_Label :=
           Gtk_Label(Get_Child(Get_Content_Area(ErrorDialog), 4));
         ErrorFileDirectory: Unbounded_String :=
           To_Unbounded_String(Current_Directory);
         NewDataDirectory: Unbounded_String := DataDirectory;
         DotIndex: Natural := 1;
         LastDirSeparator: Natural :=
           Index(ErrorFileDirectory, "" & Dir_Separator, Backward);
      begin
         loop
            DotIndex := Index(NewDataDirectory, ".." & Dir_Separator, 1);
            exit when DotIndex = 0;
            Delete
              (ErrorFileDirectory, LastDirSeparator,
               Length(ErrorFileDirectory));
            Delete(NewDataDirectory, DotIndex, 3);
            LastDirSeparator :=
              Index(ErrorFileDirectory, "" & Dir_Separator, Backward);
         end loop;
         Append
           (ErrorFileDirectory, Dir_Separator & To_String(NewDataDirectory));
         Set_Label
           (Label,
            Get_Label(Label) & " from '" & To_String(ErrorFileDirectory) &
            "' directory.");
      end;
      ShowMainMenu;
      if DataError /= Null_Unbounded_String then
         Hide(Gtk_Widget(Get_Object(Builder, "btnloadgame")));
         Hide(Gtk_Widget(Get_Object(Builder, "btnnewgame")));
         ShowDialog
           ("Can't load game data files. Error: " & To_String(DataError));
         return;
      end if;
      if not Is_Write_Accessible_File(To_String(SaveDirectory)) then
         Hide(Gtk_Widget(Get_Object(Builder, "btnloadgame")));
         Hide(Gtk_Widget(Get_Object(Builder, "btnnewgame")));
         ShowDialog
           ("Directory " & To_String(SaveDirectory) &
            " is not write accessible, thus save games cannot be saved.");
      end if;
      ShowFactionDescription(Builder);
   end CreateMainMenu;

   -- ****if* MainMenu/ShowErrorInfo
   -- FUNCTION
   -- Show error dialog with information about occured error
   -- PARAMETERS
   -- Message - Full stack message from error
   -- SOURCE
   procedure ShowErrorInfo(Message: Unbounded_String) is
   -- ****
   begin
      Set_Text
        (Get_Buffer
           (Gtk_Text_View
              (Get_Child
                 (Gtk_Scrolled_Window
                    (Get_Child
                       (Gtk_Frame
                          (Get_Child(Get_Content_Area(ErrorDialog), 5))))))),
         To_String(Message));
      Show_All(ErrorDialog);
      if Run(ErrorDialog) /= Gtk_Response_Accept then
         Destroy(ErrorDialog);
         Gtk.Main.Main_Quit;
      end if;
   end ShowErrorInfo;

   procedure UpdateGoalButton(Message: String) is
   begin
      Set_Label(Gtk_Button(Get_Object(Builder, "btngoal")), Message);
   end UpdateGoalButton;

   procedure ShowMainMenu is
      Files: Search_Type;
   begin
      Show_All(Gtk_Widget(Get_Object(Builder, "mainmenuwindow")));
      Set_Visible_Child_Name
        (Gtk_Stack(Get_Object(Builder, "mainmenustack")), "page0");
      Start_Search(Files, To_String(SaveDirectory), "*.sav");
      if not More_Entries(Files) then
         Hide(Gtk_Widget(Get_Object(Builder, "btnloadgame")));
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnnewgame")));
      else
         Grab_Focus(Gtk_Widget(Get_Object(Builder, "btnloadgame")));
      end if;
      End_Search(Files);
      if DataError /= Null_Unbounded_String or
        not Is_Write_Accessible_File(To_String(SaveDirectory)) then
         declare
            MessageLabel: constant Gtk_Label := Gtk_Label_New;
         begin
            Set_Line_Wrap(MessageLabel, True);
            Set_Width_Chars(MessageLabel, 40);
            Set_Max_Width_Chars(MessageLabel, 40);
            MessageBox := Gtk_Info_Bar_New;
            Set_Show_Close_Button(MessageBox, True);
            Set_Message_Type(MessageBox, Message_Info);
            Pack_Start
              (Gtk_Box(Get_Content_Area(MessageBox)), MessageLabel, False);
            On_Response(MessageBox, HideDialog'Access);
            Set_Halign(MessageBox, Align_Center);
            Set_Valign(MessageBox, Align_Center);
         end;
         Add_Overlay
           (Gtk_Overlay(Get_Object(Builder, "menuoverlay")), MessageBox);
      end if;
      if DataError /= Null_Unbounded_String then
         Hide(Gtk_Widget(Get_Object(Builder, "btnloadgame")));
         Hide(Gtk_Widget(Get_Object(Builder, "btnnewgame")));
      end if;
      if not Exists(To_String(SaveDirectory) & "halloffame.dat") then
         Hide(Gtk_Widget(Get_Object(Builder, "btnhalloffame")));
      end if;
   end ShowMainMenu;

   procedure SaveException
     (An_Exception: Exception_Occurrence; PrintToTerminal: Boolean) is
      ErrorFile: File_Type;
      ErrorText: Unbounded_String;
   begin
      if Natural(PlayerShip.Crew.Length) > 0 then
         SaveGame;
      end if;
      if Exists(To_String(SaveDirectory) & "error.log") then
         Open(ErrorFile, Append_File, To_String(SaveDirectory) & "error.log");
      else
         Create
           (ErrorFile, Append_File, To_String(SaveDirectory) & "error.log");
      end if;
      Append(ErrorText, Ada.Calendar.Formatting.Image(Clock));
      Append(ErrorText, LF);
      Append(ErrorText, GameVersion);
      Append(ErrorText, LF);
      Append(ErrorText, "Exception: " & Exception_Name(An_Exception));
      Append(ErrorText, LF);
      Append(ErrorText, "Message: " & Exception_Message(An_Exception));
      Append(ErrorText, LF);
      Append(ErrorText, "-------------------------------------------------");
      Append(ErrorText, LF);
      Append(ErrorText, Symbolic_Traceback_No_Hex(An_Exception));
      Append(ErrorText, LF);
      Append(ErrorText, "-------------------------------------------------");
      Put_Line(ErrorFile, To_String(ErrorText));
      Close(ErrorFile);
      if PrintToTerminal then
         Put_Line(To_String(ErrorText));
      else
         ShowErrorInfo(ErrorText);
      end if;
      EndLogging;
   end SaveException;

   procedure On_Exception(An_Exception: Exception_Occurrence) is
   begin
      SaveException(An_Exception, False);
   end On_Exception;

end MainMenu;
