-------------------------------------------------------------------------------
-- German localization
-------------------------------------------------------------------------------

if (GetLocale() == "deDE") then

-- Mage
SMARTBUFF_MAGE_PATTERN = {"r\195\188stung$"};

-- Warlock
SMARTBUFF_WARLOCK_PATTERN = {"^D\195\164monen%a+"};

-- Hunter
SMARTBUFF_HUNTER_PATTERN = {"^Aspekt de%a %a+"};

-- Shamane
SMARTBUFF_SHAMAN_PATTERN = {"%a+schild$"};

-- Paladin
SMARTBUFF_PALADIN_PATTERN = {"^Siegel de%a %a+"};

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"Dolche", "\195\164xte", "schwerter", "streitkolben", "St\195\164be", "Faustwaffen"};
SMARTBUFF_WEAPON_BLUNT = {"streitkolben", "Faustwaffen", "St\195\164be"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "ewichtsstein$";
SMARTBUFF_WEAPON_SHARP = {"Dolche", "\195\164xte", "schwerter", "Stangenwaffen"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "etzstein$";

-- Creature types
SMARTBUFF_HUMANOID  = "Humanoid";
SMARTBUFF_DEMON     = "D\195\164mon";
SMARTBUFF_BEAST     = "Wildtier";
SMARTBUFF_ELEMENTAL = "Elementar";
SMARTBUFF_DEMONTYPE = "Wichtel";
SMARTBUFF_UNDEAD    = "Untot";

-- Classes
SMARTBUFF_CLASSES = {"Druide", "J\195\164ger", "Magier", "Paladin", "Priester", "Schurke", "Schamane", "Hexenmeister", "Krieger", "Todesritter", "J\195\164ger Pet", "Hexer Pet", "Todesritter Pet"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"Solo", "Gruppe", "Raid", "Schlachtfeld", "Arena", "ICC", "PDK", "Ulduar", "MC", "Ony", "BWL", "Naxx", "AQ", "ZG", "Custom 1", "Custom 2", "Custom 3", "Custom 4", "Custom 5"};
SMARTBUFF_INSTANCES = {"Eiskronenzitadelle", "Pr\195\188fung des Kreuzfahrers", "Ulduar", "geschmolzene Kern", "Onyxias Hort", "Pechschwingenhort", "Naxxramas", "Ahn'Qiraj", "Zul'Gurub"};

-- Mount
SMARTBUFF_MOUNT = "Erh\195\182ht Tempo um (%d+)%%.";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "Trigger";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "Ziel";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "Optionen";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "Buff Timer l\195\182schen";

-- Options Frame Text
SMARTBUFF_OFT                = "SmartBuff An/Aus";
SMARTBUFF_OFT_MENU           = "Zeige/verberge Optionen Men\195\188";
SMARTBUFF_OFT_AUTO           = "Erinnerung";
SMARTBUFF_OFT_AUTOTIMER      = "Check Timer";
SMARTBUFF_OFT_AUTOCOMBAT     = "im Kampf";
SMARTBUFF_OFT_AUTOCHAT       = "Chat";
SMARTBUFF_OFT_AUTOSPLASH     = "Splash";
SMARTBUFF_OFT_AUTOSOUND      = "Ton";
SMARTBUFF_OFT_AUTOREST       = "Unterdr\195\188ckt in St\195\164dten";
SMARTBUFF_OFT_HUNTERPETS     = "J\195\164ger Pets buffen";
SMARTBUFF_OFT_WARLOCKPETS    = "Hexer Pets buffen";
SMARTBUFF_OFT_ARULES         = "Zus\195\164tzliche Regeln";
SMARTBUFF_OFT_GRP            = "Raid Sub-Gruppen zum Buffen";
SMARTBUFF_OFT_SUBGRPCHANGED  = "\195\150ffne Men\195\188";
SMARTBUFF_OFT_BUFFS          = "Buffs/F\195\164higkeiten";
SMARTBUFF_OFT_TARGET         = "Bufft das anvisierte Ziel";
SMARTBUFF_OFT_DONE           = "Fertig";
SMARTBUFF_OFT_APPLY          = "\195\156bernehmen";
SMARTBUFF_OFT_GRPBUFFSIZE    = "Grp/Ra-Gr\195\182sse";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "Klassengr\195\182sse";
SMARTBUFF_OFT_MESSAGES       = "Unterdr\195\188cke Meldungen";
SMARTBUFF_OFT_MSGNORMAL      = "Normal";
SMARTBUFF_OFT_MSGWARNING     = "Warnung";
SMARTBUFF_OFT_MSGERROR       = "Fehler";
SMARTBUFF_OFT_HIDEMMBUTTON   = "Verberge Minimap-Knopf";
SMARTBUFF_OFT_REBUFFTIMER    = "Rebuff Timer";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "Vorlagenwechsel";
SMARTBUFF_OFT_SELFFIRST      = "Mich zuerst";
SMARTBUFF_OFT_SCROLLWHEELUP  = "Bufft mit Mausrad hoch";
SMARTBUFF_OFT_SCROLLWHEELDOWN = "runter";
SMARTBUFF_OFT_TARGETSWITCH   = "bei Zielwechsel";
SMARTBUFF_OFT_BUFFTARGET     = "Bufft das Ziel";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "Instanzen";
SMARTBUFF_OFT_CHECKCHARGES   = "Aufladungen";
SMARTBUFF_OFT_RBT            = "Reset BT";
SMARTBUFF_OFT_BUFFINCITIES   = "Bufft in St\195\164dten";
SMARTBUFF_OFT_UISYNC         = "UI Sync";
SMARTBUFF_OFT_ADVGRPBUFFCHECK = "Grp Buff Check";
SMARTBUFF_OFT_ADVGRPBUFFRANGE = "Grp Range Check";
SMARTBUFF_OFT_BLDURATION     = "Blacklisted";
SMARTBUFF_OFT_COMPMODE       = "Komp. Modus";
SMARTBUFF_OFT_MINIGRP        = "Mini Gruppe";
SMARTBUFF_OFT_ANTIDAZE       = "Anti-Daze";
SMARTBUFF_OFT_HIDESABUTTON   = "Verberge Action-Knopf";
SMARTBUFF_OFT_INCOMBAT       = "im Kampf";
SMARTBUFF_OFT_INSHAPESHIFT   = "Verwandelt";

-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "Schaltet SmartBuff An/Aus";
SMARTBUFF_OFTT_AUTO          = "Schaltet die Erinnerung an fehlende Buffs An/Aus";
SMARTBUFF_OFTT_AUTOTIMER     = "Verz\195\182gerung in Sekunden zwischen zwei Checks.";
SMARTBUFF_OFTT_AUTOCOMBAT    = "Check auch w\195\164hrend dem Kampf durchf\195\188hren.";
SMARTBUFF_OFTT_AUTOCHAT      = "Zeigt fehlende Buffs als Chat-Meldung an.";
SMARTBUFF_OFTT_AUTOSPLASH    = "Zeigt fehlende Buffs als Splash-Meldung\nin der mitte des Bildschirms an.";
SMARTBUFF_OFTT_AUTOSOUND     = "Bei fehlende Buffs erklingt ein Ton.";
SMARTBUFF_OFTT_AUTOREST      = "Erinnerung wird in den\nHauptst\195\164dten unterdr\195\188ckt.";
SMARTBUFF_OFTT_HUNTERPETS    = "Bufft die J\195\164ger Pets auch.";
SMARTBUFF_OFTT_WARLOCKPETS   = "Bufft die Hexer Pets auch,\nausser den " .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "Bufft nicht:\n- Dornen auf Magier, Priester und Hexer\n- Arkane Intelligenz auf Klassen ohne Mana\n- G\195\182ttlicher Willen auf Klassen ohne Mana";
SMARTBUFF_OFTT_SUBGRPCHANGED = "\195\150ffnet automatisch das SmartBuff Men\195\188,\nwenn du die Sub-Gruppe gewechselt hast.";
SMARTBUFF_OFTT_GRPBUFFSIZE   = "Anzahl Spieler die in der Gruppe/Raid sein\nm\195\188ssen und den Gruppen-Buff nicht haben,\ndamit der Gruppen-Buff verwendet wird.";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "Verbirgt den SmartBuff Minimap-Knopf.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf der Buffs,\nsoll daran erinnert werden.\n0 = Deaktivert";
SMARTBUFF_OFTT_SELFFIRST     = "Bufft den eigenen Charakter immer zuerst.";
SMARTBUFF_OFTT_SCROLLWHEELUP = "Bufft beim Bewegen des Scrollrads nach vorne.";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "Bufft beim Bewegen des Scrollrads zur\195\188ck.";
SMARTBUFF_OFTT_TARGETSWITCH  = "Bufft beim Wechsel eines Ziels.";
SMARTBUFF_OFTT_BUFFTARGET    = "Bufft zuerst das aktuelle Ziel,\nfalls dies freundlich ist.";
SMARTBUFF_OFTT_BUFFPVP       = "Bufft auch Spieler im PvP Modus,\nwenn man selbst nicht im PvP ist.";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "Wechselt automatisch die Buff-Vorlage,\nwenn der Gruppentyp sich \195\164ndert.";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "Wechselt automatisch die Buff-Vorlage,\nwenn die Instanz sich \195\164ndert.";
SMARTBUFF_OFTT_CHECKCHARGES  = "Erinnerung wenn die Aufladungen\neines Buffs bald aufgebraucht sind.\n0 = Deaktivert";
SMARTBUFF_OFTT_BUFFINCITIES  = "Bufft auch in den Hauptst\195\164dten.\nWenn du PvP geflagged bist, bufft es immer.";
SMARTBUFF_OFTT_UISYNC        = "Aktiviert die Synchronisation mit dem UI,\num die Buff-Zeiten der anderen Spieler zu erhalten.";
SMARTBUFF_OFTT_ADVGRPBUFFCHECK = "Der erweiterte Gruppenbuff-Check\nbezieht auch die Einzelbuffs mitein,\nbevor ein Gruppenbuff benutzt wird.";
SMARTBUFF_OFTT_ADVGRPBUFFRANGE = "Der erweiterte Gruppenbuff-Distanz-Check\n\195\188berpr\195\188ft ob jedes Gruppenmitglied auch\ninnerhalb der Buff-Distanz ist,\nbevor ein Gruppenbuff benutzt wird.";
SMARTBUFF_OFTT_BLDURATION    = "Wieviele Sekunden ein Spieler auf\ndie schwarze Liste gesetzt wird.\n0 = Deaktivert";
SMARTBUFF_OFTT_COMPMODE      = "Kompatibilit\195\164ts Modus\nWarnung!!!\nBenutzte diesen Modus nur, wenn Probleme auftreten\nBuffs auf sich selbst zu casten.";
SMARTBUFF_OFTT_MINIGRP       = "Zeigt die Raid-Subgruppen Einstellungen in einem\neigenen verschiebbaren Mini-Fenster an.";
SMARTBUFF_OFTT_ANTIDAZE      = "Bricht automatisch den\nAspekt des Geparden/Rudels ab,\nwenn jemand bet\195\164ubt wird\n(Selbst oder Gruppe).";
SMARTBUFF_OFTT_SPLASHSTYLE   = "Wechselt die Schriftart\nder Buff-Meldungen.";
SMARTBUFF_OFTT_HIDESABUTTON  = "Verbirgt den SmartBuff Action-Knopf.";
SMARTBUFF_OFTT_SPLASHDURATION= "Wieviele Sekunden die Splash Meldung angezeigt wird,\nbevor sie ausgeblendet wird.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "Bufft auch wenn du\nverwandelt bist.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "Nur mich";
SMARTBUFF_BST_SELFNOT        = "Mich nicht";
SMARTBUFF_BST_COMBATIN       = "Im Kampf";
SMARTBUFF_BST_COMBATOUT      = "Aus dem Kampf";
SMARTBUFF_BST_MAINHAND       = "Waffenhand";
SMARTBUFF_BST_OFFHAND        = "Schildhand";
SMARTBUFF_BST_REMINDER       = "Benachrichtigung";
SMARTBUFF_BST_MANALIMIT      = "Grenzwert";

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "Bufft nur deinen eigenen Charakter."; 
SMARTBUFF_BSTT_SELFNOT       = "Bufft alle anderen selektierte Klassen,\nausser deinen eigenen Charakter.";
SMARTBUFF_BSTT_COMBATIN      = "Bufft innerhalb des Kampfes.";
SMARTBUFF_BSTT_COMBATOUT     = "Bufft ausserhalb des Kampfes.";
SMARTBUFF_BSTT_MAINHAND      = "Bufft die Haupthand.";
SMARTBUFF_BSTT_OFFHAND       = "Bufft die Schildhand.";
SMARTBUFF_BSTT_REMINDER      = "Erinnerungs-Nachricht ausgeben.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Wieviele Sekunden vor Ablauf des Buffs,\nsoll daran erinnert werden.\n0 = Globaler Rebuff Timer";
SMARTBUFF_BSTT_MANALIMIT     = "Mana/Wut/Energie Grenzwert\nWenn du unter diesen Wert f\195\164llst\nwird der Buff nicht mehr verwendet.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "Minimiert/Maximiert\ndas Optionenfenster";

-- Messages
SMARTBUFF_MSG_LOADED         = "geladen";
SMARTBUFF_MSG_DISABLED       = "SmartBuff ist deaktiviert!";
SMARTBUFF_MSG_SUBGROUP       = "Du hast die Subgruppe gewechselt, bitte \195\188berpr\195\188fe die Einstellungen!";
SMARTBUFF_MSG_NOTHINGTODO    = "Nichts zu buffen";
SMARTBUFF_MSG_BUFFED         = "gebuffed";
SMARTBUFF_MSG_OOR            = "ist ausser Reichweite zum Buffen!";
--SMARTBUFF_MSG_CD             = "hat noch Cooldown";
SMARTBUFF_MSG_CD             = "Globaler Cooldown!";
SMARTBUFF_MSG_CHAT           = "nicht m\195\182glich \195\188ber Chat-Befehl!";
SMARTBUFF_MSG_SHAPESHIFT     = "In Verwandlung kann nicht gebufft werden!";
SMARTBUFF_MSG_NOACTIONSLOT   = "muss in einem Slot auf der Aktionsleiste sein, dass es funktioniert!";
SMARTBUFF_MSG_GROUP          = "Gruppe";
SMARTBUFF_MSG_NEEDS          = "ben\195\182tigt";
SMARTBUFF_MSG_OOM            = "Zuwenig Mana/Wut/Energie!";
SMARTBUFF_MSG_STOCK          = "Aktueller Bestand";
SMARTBUFF_MSG_NOREAGENT      = "Zuwenig";
SMARTBUFF_MSG_DEACTIVATED    = "deaktiviert!";
SMARTBUFF_MSG_REBUFF         = "ReBuff";
SMARTBUFF_MSG_LEFT           = "\195\188brig";
SMARTBUFF_MSG_CLASS          = "Klasse";
SMARTBUFF_MSG_CHARGES        = "Aufladungen";
SMARTBUFF_MSG_SPECCHANGED    = "Spec gewechselt (%s), lade Buff-Vorlagen...";

-- Support
SMARTBUFF_MINIMAP_TT         = "Links Klick: Optionen Men\195\188\nRechts Klick: An/Aus\nAlt-Links Klick: SmartDebuff\nShift-Ziehen: Knopf verschieben";
SMARTBUFF_TITAN_TT           = "Links Klick: Optionen Men\195\188\nRechts Klick: An/Aus\nAlt-Links Klick: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\nLinks Klick: Optionen Men\195\188\nShift-Links Klick: An/Aus\nAlt-Links Klick: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-Links ziehen: Fenster verschieben\n|cff20d2ff- S Knopf -|r\nLinks Klick: Ordne nach Klassen\nShift-Links Klick: Klassen-Farben\nAlt-Links Klick: Zeige L/R\n|cff20d2ff- P Knopf -|r\nLinks Klick: Verberge Pets";

end
