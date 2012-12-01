-------------------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------------------

SMARTDEBUFF_TTC_R = 1.0;
SMARTDEBUFF_TTC_G = 0.82;
SMARTDEBUFF_TTC_B = 0.0;
SMARTDEBUFF_TTC_A = 1.0;

SMARTDEBUFF_OF_HEIGHT = 500;
SMARTDEBUFF_OF_WIDTH = 500;

SMARTDEBUFF_CONST_SOUND = "Sound\\Doodad\\BellTollTribal.wav";

-- Support spell IDs
SMARTDEBUFF_REJUVENATION_ID       = 774;
SMARTDEBUFF_RENEW_ID              = 139;
SMARTDEBUFF_FLASHOFLIGHT_ID       = 19750;
SMARTDEBUFF_LESSERHEALINGWAVE_ID  = 8004;
SMARTDEBUFF_MISDIRECTION_ID       = 34477;
SMARTDEBUFF_POLYMORPH_ID          = 118;
SMARTDEBUFF_HEX_ID                = 51514;
SMARTDEBUFF_INTERVENE_ID          = 3411;
SMARTDEBUFF_DEATHCOIL_ID          = 52375;
SMARTDEBUFF_TRICKS_ID             = 57934;

-- Debuff spell IDs
SMARTDEBUFF_CUREDISEASE_ID_PRIEST = 528;
SMARTDEBUFF_CUREDISEASE_ID_SHAMAN = 2870;
SMARTDEBUFF_ABOLISHDISEASE_ID     = 552;
SMARTDEBUFF_PURIFY_ID             = 1152;
SMARTDEBUFF_CLEANSE_ID            = 4987;
SMARTDEBUFF_DISPELMAGIC_ID        = 527;
SMARTDEBUFF_CUREPOISON_ID_DRUID   = 8946;
SMARTDEBUFF_CUREPOISON_ID_SHAMAN  = 526;
SMARTDEBUFF_ABOLISHPOISON_ID      = 2893;
SMARTDEBUFF_REMOVELESSERCURSE_ID  = 475;
SMARTDEBUFF_REMOVECURSE_ID        = 2782;
SMARTDEBUFF_PURGE_ID              = 370;
SMARTDEBUFF_CLEANSESPIRIT_ID      = 51886;

-- Misc spell IDs
SMARTDEBUFF_UNENDINGBREATH_ID     = 5697;
SMARTDEBUFF_PET_FELHUNTER_ID      = 19505;


-- Effects ignore list
SMARTDEBUFF_DEBUFFSKIP_NAME = { };
SMARTDEBUFF_DEBUFFSKIP_ID = {
   [1] = 15822, --Dreamless Sleep
	 [2] = 24360, --Greater Dreamless Sleep
	 [3] = 28504, --Major Dreamless Sleep
	 [4] = 2096,  --Mind Vision
	 [5] = 28169, --Mutating Injection
   [6] = 710,   --Banish
   [7] = 4511,  --Phase Shift
   [8] = 30451, --Arcane Blast
   [9] = 30108, --Unstable Affliction
  [10] = 13810, --Frost Trap Aura
  [11] = 30108, --Unstable Affliction
  [12] = 19372, --Ancient Hysteria
  [13] = 19659, --Ignite Mana
  [14] = 16567, --Tainted Mind
  [15] = 28732, --Widow's Embrace
  [16] = 24306, --Delusions of Jin'do
  [17] = 15487, --Silence
  [18] = 1714,  --Curse of Tongues
  [19] = 29904, --Sonic Burst
  [20] = 19496, --Magma Shackles
  [21] = 33787, --Cripple
  [22] = 26072, --Dust Cloud
  [23] = 30633, --Thunderclap
};

-- Global ignore list
SMARTDEBUFF_DEBUFFSKIPLIST = { };
SMARTDEBUFF_DEBUFFSKIPLIST_ID = {1,2,3,4,5,6,7,8,9,10};

-- Class ignore list
SMARTDEBUFF_DEBUFFCLASSSKIPLIST = { };
SMARTDEBUFF_DEBUFFCLASSSKIPLIST_ID = {
	["WARRIOR"] = {12,13,14,15,16};
	["ROGUE"]   = {12,13,14,15,16,17,18,19};
	["HUNTER"]  = {16,20};
	["MAGE"]    = {16,20,21,22,23};
	["WARLOCK"] = {16,21,22,23};
	["DRUID"]   = {16,22,23};
	["PRIEST"]  = {16,21,22,23};
	["PALADIN"] = {16,22};
	["SHAMAN"]  = {16,22};
	["DEATHKNIGHT"] = {16,22};
};

--[[
Prowl 5215
Stealth 1784
Shadowmeld 20580
Invisibility 66
Lesser Invisibility 7870
]]--


SMARTDEBUFF_NOTREMOVABLE_ID = {
  39837, --Impaling Spine (Naj'entus)
  40239, --Incinerate (Teron)
  --40243, --Crushing Shadows (Teron)
  42005, --Bloodboil (Gurtogg)
  40604, --Fel Rage (Gurtogg)
  41001, --Fatal Attraction (Mother Shahraz)
  40860, --Vile Beam (Mother Shahraz)
  41485, --Deadly Poison (Veras Darkshadow, Illidari Council)
  40932, --Agonizing Flames (Illidan)
  41917, --Parasitic Shadowfiend (Illidan)
  40585, --Dark Barrage (Illidan)
  31249, --Icebolt (Winterchill)
  31340, --Rain of Fire (Azgalor)
  31944, --Doomfire (Archimonde)
  45141, --Burn (Brutallus)
  46008, --Negative Energy (Muru)
  38235, --Water Tomb (Hydross)
  38049, --Watery Grave (Morogrim)
};

