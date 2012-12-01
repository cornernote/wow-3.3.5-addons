-------------------------------------------------------------------------------
-- Spanish localization
-------------------------------------------------------------------------------

if (GetLocale() == "esES") then


-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Enfermedad";
SMARTDEBUFF_MAGIC   = "Magia";
SMARTDEBUFF_POISON  = "Veneno";
SMARTDEBUFF_CURSE   = "Maldici\195\179n";
SMARTDEBUFF_CHARMED = "Control mental";
SMARTDEBUFF_HEAL    = "Sanar";
]]--


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoide";
SMARTDEBUFF_DEMON     = "Demonio";
SMARTDEBUFF_BEAST     = "Bestia";
SMARTDEBUFF_ELEMENTAL = "Elemental";
SMARTDEBUFF_IMP       = "Diablillo";
SMARTDEBUFF_FELHUNTER = "Man\195\161fago";
SMARTDEBUFF_DOOMGUARD = "Guardia apocal\195\173ptico";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druida", ["HUNTER"] = "Cazador", ["MAGE"] = "Mago", ["PALADIN"] = "Palad\195\173n", ["PRIEST"] = "Sacerdote", ["ROGUE"] = "P\195\173caro"
                      , ["SHAMAN"] = "Cham\195\161n", ["WARLOCK"] = "Brujo", ["WARRIOR"] = "Guerrero", ["DEATHKNIGHT"] = "Caballero de la Muerte", ["HPET"] = "Mascota de cazador", ["WPET"] = "Mascota de Brujo"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Marco de opciones";

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
SMARTDEBUFF_MSG_LOADED         = "cargado";
SMARTDEBUFF_MSG_SDB            = "Marco de opciones de SmartDebuff";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Keys/Modes";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Trgt";


-- Options frame text
SMARTDEBUFF_OFT                = "Mostrar/ocultar Marco de opciones de SmartDebuff";
SMARTDEBUFF_OFT_HUNTERPETS     = "Mascotas de cazador";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Mascotas de brujo";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Mascotas de Caballero de la Muerte";
SMARTDEBUFF_OFT_HP             = "HP"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_MANA           = "Mana"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Invertir";
SMARTDEBUFF_OFT_CLASSVIEW      = "Ver clases";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Colores de clases";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "Encabezados";
SMARTDEBUFF_OFT_GROUPNR        = "Nº de grupo";
SMARTDEBUFF_OFT_SOUND          = "Sonido";
SMARTDEBUFF_OFT_TOOLTIP        = "Ayuda visual";
SMARTDEBUFF_OFT_TARGETMODE     = "Modo objetivo";
SMARTDEBUFF_OFT_HEALRANGE      = "Rango de cura";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Orden vertical";
SMARTDEBUFF_OFT_VERTICALUP     = "Vertical arriba";
SMARTDEBUFF_OFT_HEADERROW      = "Encabezado de fila, con botones";
SMARTDEBUFF_OFT_BACKDROP       = "Mostrar fondo";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "Gradient"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_INFOFRAME      = "Mostrar marco de sumario";
SMARTDEBUFF_OFT_AUTOHIDE       = "Auto hide"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_COLUMNS        = "Columnas";
SMARTDEBUFF_OFT_INTERVAL       = "Intervalo";
SMARTDEBUFF_OFT_FONTSIZE       = "Tama\195\177o de fuente";
SMARTDEBUFF_OFT_WIDTH          = "Ancho";
SMARTDEBUFF_OFT_HEIGHT         = "Alto";
SMARTDEBUFF_OFT_BARHEIGHT      = "Barra alto";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "Opacidad en rango";
SMARTDEBUFF_OFT_OPACITYOOR     = "Opacidad fuera de rango";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Opacidad al quitar debuff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff Guard"; -- NOT TRANSLATED
SMARTDEBUFF_OFT_VEHICLE        = "Veh\195\173culo";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Banda signo";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Sort by class order";
SMARTDEBUFF_NRDT_TITLE         = "Unremovable Debuffs";


-- Tooltip text
SMARTDEBUFF_TT                 = "May\195\186sculas-arrastrar izquierdo: Mover marco\n|cff20d2ff- S bot\195\179n -|r\nClick Izquierdo: Mostrar por clases\nMay\195\186scuals-Click Izquierdo: Colores de clase\nAlt-Click izquierdo: Destacar L/R\nClick derecho: Fondo";
SMARTDEBUFF_TT_TARGETMODE      = "En modo objetivo |cff20d2ffClick izquierdo|r selecciona la unidad y |cff20d2ffClick derecho|r lanza el hechizo m\195\161s r\195\161pido de curaci\195\179n.\nUsar |cff20d2ffAlt-Click derecho/izquierdo|r para debuff.";
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
SMARTDEBUFF_FUBAR_TT           = "\nClick izquierdo: Abrir opciones\nMay\195\186sulas-Click izquierdo: On/Off";
SMARTDEBUFF_BROKER_TT          = "\nClick izquierdo: Abrir opciones\nClick derecho: On/Off";

end