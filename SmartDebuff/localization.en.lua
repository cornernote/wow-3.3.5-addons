-------------------------------------------------------------------------------
-- English localization (Default)
-------------------------------------------------------------------------------

-- Whats new info
SMARTDEBUFF_WHATSNEW = "|cffffffffWhats new:|r\n\n"
  .."- Added 'Spell Guard' ('S' button), displays icons for the listed spells. Enter a custom spell in the textbox and press enter to add it. Drag'n'drop to change the order, right click to remove it.\n\n"
  .."- Added 'Spell Guard' option frame\n\n"
  .."- Updated 'Class order' option frame\n\n"
  ;  
  

-- Debuff types
SMARTDEBUFF_DISEASE = "Disease";
SMARTDEBUFF_MAGIC   = "Magic";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Curse";
SMARTDEBUFF_CHARMED = "Mind Control";
SMARTDEBUFF_HEAL    = "Heal";


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoid";
SMARTDEBUFF_DEMON     = "Demon";
SMARTDEBUFF_BEAST     = "Beast";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Imp";
SMARTDEBUFF_FELHUNTER = "Felhunter";
SMARTDEBUFF_DOOMGUARD = "Doomguard";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druid", ["HUNTER"] = "Hunter", ["MAGE"] = "Mage", ["PALADIN"] = "Paladin", ["PRIEST"] = "Priest", ["ROGUE"] = "Rogue"
                      , ["SHAMAN"] = "Shaman", ["WARLOCK"] = "Warlock", ["WARRIOR"] = "Warrior", ["DEATHKNIGHT"] = "Death Knight", ["HPET"] = "Hunter Pet", ["WPET"] = "Warlock Pet"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Options frame";

SMARTDEBUFF_KEYS = {["L"]  = "Left",
                    ["R"]  = "Right",
                    ["M"]  = "Middle",
                    ["SL"] = "Shift left",
                    ["SR"] = "Shift right",
                    ["SM"] = "Shift middle",
                    ["AL"] = "Alt left",
                    ["AR"] = "Alt right",
                    ["AM"] = "Alt middle",
                    ["CL"] = "Ctrl left",
                    ["CR"] = "Ctrl right",
                    ["CM"] = "Ctrl middle"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "loaded";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff options frame";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Keys/Modes";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Trgt";


-- Options frame text
SMARTDEBUFF_OFT                = "Show/Hide SmartDebuff options frame";
SMARTDEBUFF_OFT_HUNTERPETS     = "Hunter pets";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Warlock pets";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Death Knight pets";
SMARTDEBUFF_OFT_HP             = "HP";
SMARTDEBUFF_OFT_MANA           = "Mana";
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Invert";
SMARTDEBUFF_OFT_CLASSVIEW      = "Class view";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Class colors";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "Headers";
SMARTDEBUFF_OFT_GROUPNR        = "Group Nr.";
SMARTDEBUFF_OFT_SOUND          = "Sound";
SMARTDEBUFF_OFT_TOOLTIP        = "Tooltip";
SMARTDEBUFF_OFT_TARGETMODE     = "Target mode";
SMARTDEBUFF_OFT_HEALRANGE      = "Heal range";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Vertical arranged";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical up";
SMARTDEBUFF_OFT_HEADERROW      = "Title bar";
SMARTDEBUFF_OFT_BACKDROP       = "Background";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "Gradient";
SMARTDEBUFF_OFT_INFOFRAME      = "Summary frame";
SMARTDEBUFF_OFT_AUTOHIDE       = "Auto hide";
SMARTDEBUFF_OFT_COLUMNS        = "Columns";
SMARTDEBUFF_OFT_INTERVAL       = "Interval";
SMARTDEBUFF_OFT_FONTSIZE       = "Font size";
SMARTDEBUFF_OFT_WIDTH          = "Width";
SMARTDEBUFF_OFT_HEIGHT         = "Height";
SMARTDEBUFF_OFT_BARHEIGHT      = "Bar height";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacity in range";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacity out of range";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacity debuff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff Guard";
SMARTDEBUFF_OFT_VEHICLE        = "Vehicles";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Raid icons";
SMARTDEBUFF_OFT_SHOWSPELLICON  = "Spell icon";
SMARTDEBUFF_OFT_INFOROW        = "Info bar";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";
SMARTDEBUFF_NRDT_TITLE         = "Unremovable Debuffs";
SMARTDEBUFF_SG_TITLE           = "Spell Guard";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Left drag: Move frame\n|cff20d2ff- S button -|r\nLeft click: Show by classes\nShift-Left click: Class colors\nAlt-Left click: Highlight L/R\nRight click: Background";
SMARTDEBUFF_TT_TARGETMODE      = "In target mode |cff20d2ffLeft click|r selects the unit and |cff20d2ffRight click|r casts the fastest heal spell. Use |cff20d2ffAlt-Left/Right click|r to debuff.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "Displays critical debuffs\nwhich are not removable.";
SMARTDEBUFF_TT_HP              = "Displays actual health\npoints of the unit.";
SMARTDEBUFF_TT_MANA            = "Displays actual mana\npool of the unit.";
SMARTDEBUFF_TT_HPTEXT          = "Displays actual hp/mana\npool as percentage of\nthe unit as text.";
SMARTDEBUFF_TT_INVERT          = "Displays health points\nand mana pool inverted.";
SMARTDEBUFF_TT_CLASSVIEW       = "Displays the unit buttons\norder by class.";
SMARTDEBUFF_TT_CLASSCOLOR      = "Displays the unit buttons in\ntheir corresponding class colors.";
SMARTDEBUFF_TT_SHOWLR          = "Displays the corresponding\nmouse button (L/R/M), if\na unit has a debuff.";
SMARTDEBUFF_TT_HEADERS         = "Displays the class name\nas header row.";
SMARTDEBUFF_TT_GROUPNR         = "Displays the group number\nin front of the unit name.";
SMARTDEBUFF_TT_SOUND           = "Plays a sound, if a\nunit gets a debuff.";
SMARTDEBUFF_TT_TOOLTIP         = "Displays the tooltip,\nonly out of combat.";
SMARTDEBUFF_TT_HEALRANGE       = "Displays a red boarder,\nif your spell is out of range.";
SMARTDEBUFF_TT_SHOWAGGRO       = "Displays which\nunit has aggro.";
SMARTDEBUFF_TT_VERTICAL        = "Displays the units\nvertical arranged.";
SMARTDEBUFF_TT_VERTICALUP      = "Displays the units\nfrom bottom to top.";
SMARTDEBUFF_TT_HEADERROW       = "Displays header row,\nincluding menu buttons.";
SMARTDEBUFF_TT_BACKDROP        = "Displays a black\nbackground frame.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "Displays the unit buttons\nwith color gradient.";
SMARTDEBUFF_TT_INFOFRAME       = "Displays the summary frame,\nonly in group or raid setup.";
SMARTDEBUFF_TT_AUTOHIDE        = "Hides the unit buttons automatically,\nif you are out of combat and\nno one has a debuff.";
SMARTDEBUFF_TT_VEHICLE         = "Displays in addition the vehicle of\na unit  as own button.";
SMARTDEBUFF_TT_SHOWRAIDICON    = "Displays the raid icon\nof the unit.";
SMARTDEBUFF_TT_SHOWSPELLICON   = "Displays the HoT icon\non the unit.";
SMARTDEBUFF_TT_INFOROW         = "Displays an info bar in short style #\nPlayers/Dead/AFK/Offline\nHP/Mana\nReady check state\n(only in a raid)";

--SMARTDEBUFF_TT_COLUMNS         = "Columns";
--SMARTDEBUFF_TT_INTERVAL        = "Interval";
--SMARTDEBUFF_TT_FONTSIZE        = "Font size";
--SMARTDEBUFF_TT_WIDTH           = "Width";
--SMARTDEBUFF_TT_HEIGHT          = "Height";
--SMARTDEBUFF_TT_BARHEIGHT       = "Bar height";
--SMARTDEBUFF_TT_OPACITYNORMAL   = "Opacity in range";
--SMARTDEBUFF_TT_OPACITYOOR      = "Opacity out of range";
--SMARTDEBUFF_TT_OPACITYDEBUFF   = "Opacity debuff";

-- Tooltip text key bindings
SMARTDEBUFF_TT_DROP            = "Drop";
SMARTDEBUFF_TT_DROPINFO        = "Drop a spell/item/macro\nof your book/inventory.\n|cff00ff00Left click set target function.";
SMARTDEBUFF_TT_DROPSPELL       = "Spell click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_DROPITEM        = "Item click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_DROPMACRO       = "Macro click:\nLeft to pickup\nShift-Left to clone\nRight to remove";
SMARTDEBUFF_TT_TARGET          = "Target";
SMARTDEBUFF_TT_TARGETINFO      = "Selects the specified unit\nas the current target.";
SMARTDEBUFF_TT_DROPTARGET      = "Unit click:\nRemove";
SMARTDEBUFF_TT_DROPACTION      = "Pet action:\nRemove not possible!";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nLeft Click: Open options\nShift-Left Click: On/Off";
SMARTDEBUFF_BROKER_TT          = "Left Click: Open options\nRight Click: On/Off";

