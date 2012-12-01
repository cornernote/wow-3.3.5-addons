-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() == "deDE") then


-- Debuff types, in english in game!
--[[
SMARTDEBUFF_DISEASE = "Krankheit";
SMARTDEBUFF_MAGIC   = "Magie";
SMARTDEBUFF_POISON  = "Gift";
SMARTDEBUFF_CURSE   = "Fluch";
SMARTDEBUFF_CHARMED = "Verf\195\188hrung";
]]--


-- Creatures
SMARTDEBUFF_HUMANOID  = "Humanoid";
SMARTDEBUFF_DEMON     = "D\195\164mon";
SMARTDEBUFF_BEAST     = "Wildtier";
SMARTDEBUFF_ELEMENTAL = "Elementar";
SMARTDEBUFF_IMP       = "Wichtel";
SMARTDEBUFF_FELHUNTER = "Teufelsj\195\164ger";
SMARTDEBUFF_DOOMGUARD = "Verdammniswache";

-- Classes
SMARTDEBUFF_CLASSES = { ["DRUID"] = "Druide", ["HUNTER"] = "J\195\164ger", ["MAGE"] = "Magier", ["PALADIN"] = "Paladin", ["PRIEST"] = "Priester", ["ROGUE"] = "Schurke"
                      , ["SHAMAN"] = "Schamane", ["WARLOCK"] = "Hexer", ["WARRIOR"] = "Krieger", ["DEATHKNIGHT"] = "Todesritter", ["HPET"] = "J\195\164ger Pet", ["WPET"] = "Hexer Pet"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "Optionen";

SMARTDEBUFF_KEYS = {["L"]  = "Links",
                    ["R"]  = "Rechts",
                    ["M"]  = "Mitte",
                    ["SL"] = "Shift links",
                    ["SR"] = "Shift rechts",
                    ["SM"] = "Shift mitte",
                    ["AL"] = "Alt links",
                    ["AR"] = "Alt rechts",
                    ["AM"] = "Alt mitte",
                    ["CL"] = "Strg links",
                    ["CR"] = "Strg rechts",
                    ["CM"] = "Strg mitte"
                    };


-- Messages
SMARTDEBUFF_MSG_LOADED         = "geladen";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff Optionen";

-- Frame text
SMARTDEBUFF_FT_MODES           = "Tasten/Modus";
SMARTDEBUFF_FT_MODENORMAL      = "Norm";
SMARTDEBUFF_FT_MODETARGET      = "Ziel";


-- Options frame text
SMARTDEBUFF_OFT                = "Zeige/verberge SmartDebuff Optionen";
SMARTDEBUFF_OFT_HUNTERPETS     = "J\195\164ger Pets";
SMARTDEBUFF_OFT_WARLOCKPETS    = "Hexer Pets";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "Todesritter Pets";
SMARTDEBUFF_OFT_HP             = "HP";
SMARTDEBUFF_OFT_MANA           = "Mana";
SMARTDEBUFF_OFT_HPTEXT         = "%";
SMARTDEBUFF_OFT_INVERT         = "Invertiert";
SMARTDEBUFF_OFT_CLASSVIEW      = "Klassenansicht";
SMARTDEBUFF_OFT_CLASSCOLOR     = "Klassenfarben";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "Titel";
SMARTDEBUFF_OFT_GROUPNR        = "Gruppen Nr.";
SMARTDEBUFF_OFT_SOUND          = "Warnton";
SMARTDEBUFF_OFT_TOOLTIP        = "Tooltip";
SMARTDEBUFF_OFT_TARGETMODE     = "Ziel-Modus";
SMARTDEBUFF_OFT_HEALRANGE      = "Heil-Reichweite";
SMARTDEBUFF_OFT_SHOWAGGRO      = "Aggro";
SMARTDEBUFF_OFT_VERTICAL       = "Vertikal anordnen";
SMARTDEBUFF_OFT_VERTICALUP     = "Unten -> Oben";
SMARTDEBUFF_OFT_HEADERROW      = "Titelleiste";
SMARTDEBUFF_OFT_BACKDROP       = "Hintergrund";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "Farbverlauf";
SMARTDEBUFF_OFT_INFOFRAME      = "Status-Fenster";
SMARTDEBUFF_OFT_AUTOHIDE       = "Auto. verbergen";
SMARTDEBUFF_OFT_COLUMNS        = "Spalten";
SMARTDEBUFF_OFT_INTERVAL       = "Interval";
SMARTDEBUFF_OFT_FONTSIZE       = "Schriftgr\195\182sse";
SMARTDEBUFF_OFT_WIDTH          = "Breite";
SMARTDEBUFF_OFT_HEIGHT         = "H\195\182he";
SMARTDEBUFF_OFT_BARHEIGHT      = "Balkenh\195\182he";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "In Reichweite";
SMARTDEBUFF_OFT_OPACITYOOR     = "Ausser Reichweite";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "Debuff";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff W\195\164chter";
SMARTDEBUFF_OFT_VEHICLE        = "Fahrzeuge";
SMARTDEBUFF_OFT_SHOWRAIDICON   = "Raidsymbole";
SMARTDEBUFF_OFT_SHOWSPELLICON  = "Cast Symbol";
SMARTDEBUFF_OFT_INFOROW        = "Info-Zeile";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "Klassenanordnung";
SMARTDEBUFF_NRDT_TITLE         = "Unentfernbare Debuffs";
SMARTDEBUFF_SG_TITLE           = "Zauber-W\195\164chter";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S Knopf -|r\nLinks Klick: Ordne nach Klassen\nShift-Links Klick: Klassen-Farben\nAlt-Links Klick: Zeige L/R\nRechts Klick: Hintergrund";
SMARTDEBUFF_TT_TARGETMODE      = "Im Ziel-Modus w\195\164hlt |cff20d2fflinks klick|r die Einheit aus und |cff20d2ffrechts klick|r zaubert den schnellsten Heilspruch.\n|cff20d2ffAlt-Links/Rechts klick|r wird zum Debuffen benutzt.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "Zeigt kritische Debuffs an,\nauch wenn sie nicht entfernt\nwerden k\195\182nnen.";
SMARTDEBUFF_TT_HP              = "Zeigt die aktuellen Lebenspunkte\nder Einheit an.";
SMARTDEBUFF_TT_MANA            = "Zeigt das aktuelle Mana\nder Einheit an.";
SMARTDEBUFF_TT_HPTEXT          = "Zeigt die aktuellen Lebens-\nund Manapunkte der Einheit\nals Text in Prozent an.";
SMARTDEBUFF_TT_INVERT          = "Stellt die Lebenspunkte und\ndas Mana invertiert dar.";
SMARTDEBUFF_TT_CLASSVIEW       = "Stellt die Kn\195\182pfe nach\nKlasse sortiert dar.";
SMARTDEBUFF_TT_CLASSCOLOR      = "Stellt die Kn\195\182pfe in der\njeweiligen Klassenfarbe dar.";
SMARTDEBUFF_TT_SHOWLR          = "Zeigt den zugeh\195\182rigen\nMausknopf (L/R/M)\nan, wenn jemand\neinen Debuff hat.";
SMARTDEBUFF_TT_HEADERS         = "Stellt den Klassennamen\nals Zeilentitel dar.";
SMARTDEBUFF_TT_GROUPNR         = "Blendet die Gruppennummer\nvor dem Spielernamen ein.";
SMARTDEBUFF_TT_SOUND           = "Spielt einen Ton ab, wenn\njemand einen Debuff bekommt.";
SMARTDEBUFF_TT_TOOLTIP         = "Zeigt Tooltip-Infos zum\njeweiligen Knopf an, nur\nausserhalb des Kampfes.";
SMARTDEBUFF_TT_HEALRANGE       = "Stellt einen roten Rahmen dar,\nwenn der Heil-Zauber ausser\nReichweite ist.";
SMARTDEBUFF_TT_SHOWAGGRO       = "Zeigt wer gerade\nAggro hat.";
SMARTDEBUFF_TT_VERTICAL        = "Stellt die Kn\195\182pfe vertikal\nangeordnet dar.";
SMARTDEBUFF_TT_VERTICALUP      = "Baut die Kn\195\182pfe vertikal\nvon unten nach oben auf.";
SMARTDEBUFF_TT_HEADERROW       = "Stellt die Titelzeile, inklusiv\nder Men\195\188-Kn\195\182pfe dar.";
SMARTDEBUFF_TT_BACKDROP        = "Blendet einen schwarzen\nHintergrund ein.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "Stellt die Kn\195\182pfe mit\neinem Farbverlauf dar.";
SMARTDEBUFF_TT_INFOFRAME       = "Blendet das Status-Fenster ein,\nnur in der Gruppe oder Raid.";
SMARTDEBUFF_TT_AUTOHIDE        = "Verbirgt die Kn\195\182pfe automatisch,\nwenn man nicht mehr im Kampf\nist und niemand einen Debuff hat.";
SMARTDEBUFF_TT_VEHICLE         = "Stellt zus\195\164tzlich das Fahrzeug der\nEinheit als eigener Knopf dar.";
SMARTDEBUFF_TT_SHOWRAIDICON    = "Stellt das Raidsymbol\nder Einheit dar.";
SMARTDEBUFF_TT_SHOWSPELLICON   = "Stellt das Cast-Symbol\nauf der Einheit dar.";
SMARTDEBUFF_TT_INFOROW         = "Zeigt in kurzform eine Infozeile #\nSpieler/Tot/AFK/Offline\nHP/Mana\nReady check Status\n(Nur im Raid)";

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
SMARTDEBUFF_TT_DROPINFO        = "F\195\188ge einen Zauber/Item/Makro\naus dem Buch/Inventar ein.\n|cff00ff00Links-klick Ziel-Funktion setzen";
SMARTDEBUFF_TT_DROPSPELL       = "Zauber klick:\nLinks aufnehmen\nShift-Links kopieren\nRechts entfernen";
SMARTDEBUFF_TT_DROPITEM        = "Item klick:\nLinks aufnehmen\nShift-Links kopieren\nRechts entfernen";
SMARTDEBUFF_TT_DROPMACRO       = "Makro klick:\nLinks aufnehmen\nShift-Links kopieren\nRechts entfernen";
SMARTDEBUFF_TT_TARGET          = "Ziel";
SMARTDEBUFF_TT_TARGETINFO      = "Selektiert die gew\195\164hlte Einheit\nund nimmt diese ins Ziel.";
SMARTDEBUFF_TT_DROPTARGET      = "Einheit klick:\nEntfernen";
SMARTDEBUFF_TT_DROPACTION      = "Pet-Aktion:\nEntfernen nicht m\195\182glich!";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\nLinks Klick: Optionen Men\195\188\nShift-Links Klick: An/Aus";
SMARTDEBUFF_BROKER_TT          = "\nLinks Klick: Optionen Men\195\188\nRechts Klick: An/Aus";

end
