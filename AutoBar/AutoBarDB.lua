--
-- AutoBarDB
-- Copyright 2008+ Toadkiller of Proudmoore.
--
-- Defaults, initialization and persistence for AutoBar
-- http://code.google.com/p/autobar/
--

-- Custom Category:
--  AutoBar.db.account.customCategories[categoryKey]
--	A separate list of Categories that is global to all players
--	Users can add their own custom Categories to the list.
--	Custom Categories can have specific items and spells dragged into their list.
--	Custom Categories can also be set to PT3 Sets, one regular Set & one priority Set
--	A priority Set item has priority over a regular Set item with the same value.
--	All common settings available to a built in Category are also available to a Custom category

-- CustomButton:
--	A separate list of Buttons that is global to all players

-- Button:
--  AutoBar.db.<account|class|char>.buttonList[buttonIndex]
--	Some Buttons like custom Buttons can have their Categories chosen from the Categories list

--  AutoBar.db.char.buttons[buttonKey]
--  Contains the defaults for Button settings & changes to the settings are stored here.
--  Enable / Disable state is recorded here
--  Only one buttonKey per button found in a Bar
--  barKey.  Defaults to default bar to place on.  Moving Button changes barKey to match.  Removing Button nils it.
--  defaultButtonIndex (#, "*" for at end, "~" for do not place, "buttonKey" to insert after a button).
--    Buttons are placed in their barKey at defaultButtonIndex on initialize.
--  deleted: false. Can be deleted by deleting from a Bar.
--  Deleted Buttons can be added back to a Bar
--  Plugin & Custom Buttons are added here & must have non-clashing names

-- Bar:
--  AutoBar.barLayoutDBList
--  AutoBar.barList
--  AutoBar.db.account.barList[buttonKey]		-- common
--  AutoBar.db.class.barList[buttonKey]		-- class
--  AutoBar.db.char.barList[buttonKey]		-- char
--  Bars contain a list of their Buttons
--  Also, resetting a Bar replaces all buttons defaulting to it.
--	Buttons can be reordered within the Bar
--	enabled: true or false
--  Plugin & Custom Bars are added here & must have non-clashing names

-- ToDo:
-- BarSettings:
--  AutoBar.db.*.barSettings[barKey]
--	Bar & Button visual settings are inherited AutoBar -> Bar -> Button
--  Plugin Buttons / Bars


local AutoBar = AutoBar
local REVISION = tonumber(("$Revision: 748 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2009-02-09 04:08:11 +0000 (Mon, 09 Feb 2009) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local L = AutoBar.locale

local ROW_COLUMN_MAX = 32


local classBar = {
	DEATHKNIGHT = "AutoBarClassBarDeathKnight",
	DRUID = "AutoBarClassBarDruid",
	HUNTER = "AutoBarClassBarHunter",
	MAGE = "AutoBarClassBarMage",
	PALADIN = "AutoBarClassBarPaladin",
	PRIEST = "AutoBarClassBarPriest",
	ROGUE = "AutoBarClassBarRogue",
	SHAMAN = "AutoBarClassBarShaman",
	WARLOCK = "AutoBarClassBarWarlock",
	WARRIOR = "AutoBarClassBarWarrior",
}

function AutoBar:GetValidatedName(name)
	name = name:gsub("%.", "")
	name = name:gsub("\"", "")
	name = name:gsub(" ", "")
	return name
end

function AutoBar:InitializeDB(overide)
	AutoBar.classBar = classBar[AutoBar.CLASS]

	AutoBar:UpgradeVersion()
	AutoBar:InitializeDefaults()

-- ToDo: Temporary, implement buttonKey field.  Remove sometime after beta.
	AutoBar:VerifyDB()

	AutoBar:RefreshButtonDBList()
	AutoBar:RefreshBarDBLists()
	AutoBar:BarsCompact()
	AutoBar:RemoveDuplicateButtons()
	AutoBar:RefreshUnplacedButtonList()
	AutoBar:PopulateBars(true)
end


-- Character specific data for a particular Button
-- For instance, the arrangeOnUse item.
function AutoBar:GetCategoryDB(categoryKey)
	return AutoBar.db.account.customCategories[categoryKey]
end

function AutoBar:GetCategoryItemDB(categoryKey, itemIndex)
	return AutoBar.db.account.customCategories[categoryKey].items[itemIndex]
end


function AutoBar:InitializeDefaults()
	if (not self.defaults) then
		self.defaults = {
			name = "Spambelly",
			guiName = "Spambelly",
			alignButtons = "3",
			alpha = 1,
			frameLocked = false,
			showCount = true,
			showHotkey = true,
			showTooltip = true,
			showMacrotext = true,
			performance = false,
			selfCastRightClick = true,
			showEmptyButtons = false,
			sticky = true,
			style = "Dreamlayout",
			barList = {},
		}
	end
	self:RegisterDefaults('account', self.defaults)

	AutoBar.Class.Bar:OptionsInitialize()
	AutoBar.Class.Bar:OptionsUpgrade()

	AutoBar.Class.Button:OptionsInitialize()
	AutoBar.Class.Button:OptionsUpgrade()

	-- Simply ascend by 1 so each session produces non-conflicting keys.
	if (not AutoBar.db.account.keySeed) then
		AutoBar.db.account.keySeed = 1
	end

	if (not AutoBar.db.account.barList["AutoBarClassBarBasic"]) then
		AutoBar.db.account.barList["AutoBarClassBarBasic"] = {
			enabled = true,
			rows = 1,
			columns = ROW_COLUMN_MAX,
			alignButtons = "3",
			alpha = 1,
			buttonWidth = 36,
			buttonHeight = 36,
			collapseButtons = true,
			docking = nil,
			dockShiftX = 0,
			dockShiftY = 0,
			fadeOut = false,
			frameStrata = "LOW",
			hide = false,
			padding = 0,
			popupDirection = "1",
			scale = 1,
			showOnModifier = nil,
			posX = 300,
			posY = 200,
			DEATHKNIGHT = true,
			DRUID = true,
			HUNTER = true,
			MAGE = true,
			PALADIN = true,
			PRIEST = true,
			ROGUE = true,
			SHAMAN = true,
			WARLOCK = true,
			WARRIOR = true,
			buttonKeys = {},
		}
	end
	if (not AutoBar.db.account.barList["AutoBarClassBarExtras"]) then
		AutoBar.db.account.barList["AutoBarClassBarExtras"] = {
			enabled = true,
			rows = 1,
			columns = ROW_COLUMN_MAX,
			alignButtons = "3",
			alpha = 1,
			buttonWidth = 36,
			buttonHeight = 36,
			collapseButtons = true,
			docking = nil,
			dockShiftX = 0,
			dockShiftY = 0,
			fadeOut = false,
			frameStrata = "LOW",
			hide = false,
			padding = 0,
			popupDirection = "1",
			scale = 1,
			showOnModifier = nil,
			posX = 300,
			posY = 360,
			DEATHKNIGHT = true,
			DRUID = true,
			HUNTER = true,
			MAGE = true,
			PALADIN = true,
			PRIEST = true,
			ROGUE = true,
			SHAMAN = true,
			WARLOCK = true,
			WARRIOR = true,
			buttonKeys = {},
		}
	end

	if (AutoBar.CLASS == "DEATHKNIGHT") then

-- ToDo: This temporarily forces existing configs to recognize DEATHKNIGHT.  Remove after wotlk
AutoBar.db.account.barList["AutoBarClassBarBasic"].DEATHKNIGHT = true
AutoBar.db.account.barList["AutoBarClassBarExtras"].DEATHKNIGHT = true

		if (not AutoBar.db.class.barList["AutoBarClassBarDeathKnight"]) then
			AutoBar.db.class.barList["AutoBarClassBarDeathKnight"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				DEATHKNIGHT = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "DRUID") then
		if (not AutoBar.db.class.barList["AutoBarClassBarDruid"]) then
			AutoBar.db.class.barList["AutoBarClassBarDruid"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				DRUID = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "HUNTER") then
		if (not AutoBar.db.class.barList["AutoBarClassBarHunter"]) then
			AutoBar.db.class.barList["AutoBarClassBarHunter"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				HUNTER = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "MAGE") then
		if (not AutoBar.db.class.barList["AutoBarClassBarMage"]) then
			AutoBar.db.class.barList["AutoBarClassBarMage"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				MAGE = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "PALADIN") then
		if (not AutoBar.db.class.barList["AutoBarClassBarPaladin"]) then
			AutoBar.db.class.barList["AutoBarClassBarPaladin"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				PALADIN = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "PRIEST") then
		if (not AutoBar.db.class.barList["AutoBarClassBarPriest"]) then
			AutoBar.db.class.barList["AutoBarClassBarPriest"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				PRIEST = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "ROGUE") then
		if (not AutoBar.db.class.barList["AutoBarClassBarRogue"]) then
			AutoBar.db.class.barList["AutoBarClassBarRogue"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				ROGUE = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "SHAMAN") then
		if (not AutoBar.db.class.barList["AutoBarClassBarShaman"]) then
			AutoBar.db.class.barList["AutoBarClassBarShaman"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				SHAMAN = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "WARLOCK") then
		if (not AutoBar.db.class.barList["AutoBarClassBarWarlock"]) then
			AutoBar.db.class.barList["AutoBarClassBarWarlock"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				WARLOCK = true,
				buttonKeys = {},
			}
		end
	end
	if (AutoBar.CLASS == "WARRIOR") then
		if (not AutoBar.db.class.barList["AutoBarClassBarWarrior"]) then
			AutoBar.db.class.barList["AutoBarClassBarWarrior"] = {
				enabled = true,
				share = "2",
				rows = 1,
				columns = ROW_COLUMN_MAX,
				alignButtons = "3",
				alpha = 1,
				buttonWidth = 36,
				buttonHeight = 36,
				collapseButtons = true,
				docking = nil,
				dockShiftX = 0,
				dockShiftY = 0,
				fadeOut = false,
				frameStrata = "LOW",
				hide = false,
				padding = 0,
				popupDirection = "1",
				scale = 1,
				showOnModifier = nil,
				posX = 300,
				posY = 280,
				WARRIOR = true,
				buttonKeys = {},
			}
		end
	end

	if (AutoBar.CLASS == "DRUID") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonBear"]) then
			AutoBar.db.class.buttonList["AutoBarButtonBear"] = {
				buttonKey = "AutoBarButtonBear",
				buttonClass = "AutoBarButtonBear",
				barKey = "AutoBarClassBarDruid",
				defaultButtonIndex = 1,
				enabled = true,
				noPopup = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonCat"]) then
			AutoBar.db.class.buttonList["AutoBarButtonCat"] = {
				buttonKey = "AutoBarButtonCat",
				buttonClass = "AutoBarButtonCat",
				barKey = "AutoBarClassBarDruid",
				defaultButtonIndex = 2,
				enabled = true,
				noPopup = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonTravel"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTravel"] = {
				buttonKey = "AutoBarButtonTravel",
				buttonClass = "AutoBarButtonTravel",
				barKey = AutoBar.classBar,
				defaultButtonIndex = 3,
				enabled = true,
				noPopup = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonBoomkinTree"]) then
			AutoBar.db.class.buttonList["AutoBarButtonBoomkinTree"] = {
				buttonKey = "AutoBarButtonBoomkinTree",
				buttonClass = "AutoBarButtonBoomkinTree",
				barKey = "AutoBarClassBarDruid",
				defaultButtonIndex = 4,
				enabled = true,
				noPopup = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonPowerShift"]) then
			AutoBar.db.class.buttonList["AutoBarButtonPowerShift"] = {
				buttonKey = "AutoBarButtonPowerShift",
				buttonClass = "AutoBarButtonPowerShift",
				barKey = "AutoBarClassBarDruid",
				defaultButtonIndex = 5,
				enabled = true,
				noPopup = true,
			}
		end
	end

	if (not AutoBar.db.account.buttonList["AutoBarButtonHearth"]) then
		AutoBar.db.account.buttonList["AutoBarButtonHearth"] = {
			buttonKey = "AutoBarButtonHearth",
			buttonClass = "AutoBarButtonHearth",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 1,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonMount"]) then
		AutoBar.db.account.buttonList["AutoBarButtonMount"] = {
			buttonKey = "AutoBarButtonMount",
			buttonClass = "AutoBarButtonMount",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 2,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonBandages"]) then
		AutoBar.db.account.buttonList["AutoBarButtonBandages"] = {
			buttonKey = "AutoBarButtonBandages",
			buttonClass = "AutoBarButtonBandages",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 3,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonHeal"]) then
		AutoBar.db.account.buttonList["AutoBarButtonHeal"] = {
			buttonKey = "AutoBarButtonHeal",
			buttonClass = "AutoBarButtonHeal",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 4,
			enabled = false,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonRecovery"]) then
		AutoBar.db.account.buttonList["AutoBarButtonRecovery"] = {
			buttonKey = "AutoBarButtonRecovery",
			buttonClass = "AutoBarButtonRecovery",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 5,
			enabled = false,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionHealth"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionHealth"] = {
			buttonKey = "AutoBarButtonCooldownPotionHealth",
			buttonClass = "AutoBarButtonCooldownPotionHealth",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 6,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionMana"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionMana"] = {
			buttonKey = "AutoBarButtonCooldownPotionMana",
			buttonClass = "AutoBarButtonCooldownPotionMana",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 7,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionRejuvenation"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionRejuvenation"] = {
			buttonKey = "AutoBarButtonCooldownPotionRejuvenation",
			buttonClass = "AutoBarButtonCooldownPotionRejuvenation",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 8,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionCombat"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownPotionCombat"] = {
			buttonKey = "AutoBarButtonCooldownPotionCombat",
			buttonClass = "AutoBarButtonCooldownPotionCombat",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 9,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneHealth"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneHealth"] = {
			buttonKey = "AutoBarButtonCooldownStoneHealth",
			buttonClass = "AutoBarButtonCooldownStoneHealth",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 10,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneMana"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneMana"] = {
			buttonKey = "AutoBarButtonCooldownStoneMana",
			buttonClass = "AutoBarButtonCooldownStoneMana",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 11,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneCombat"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownStoneCombat"] = {
			buttonKey = "AutoBarButtonCooldownStoneCombat",
			buttonClass = "AutoBarButtonCooldownStoneCombat",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 12,
			enabled = true,
			shuffle = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonRotationDrums"]) then
		AutoBar.db.account.buttonList["AutoBarButtonRotationDrums"] = {
			buttonKey = "AutoBarButtonRotationDrums",
			buttonClass = "AutoBarButtonRotationDrums",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 13,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCooldownDrums"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCooldownDrums"] = {
			buttonKey = "AutoBarButtonCooldownDrums",
			buttonClass = "AutoBarButtonCooldownDrums",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 14,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonFood"]) then
		AutoBar.db.account.buttonList["AutoBarButtonFood"] = {
			buttonKey = "AutoBarButtonFood",
			buttonClass = "AutoBarButtonFood",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 15,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonFoodBuff"]) then
		AutoBar.db.account.buttonList["AutoBarButtonFoodBuff"] = {
			buttonKey = "AutoBarButtonFoodBuff",
			buttonClass = "AutoBarButtonFoodBuff",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 16,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonFoodCombo"]) then
		AutoBar.db.account.buttonList["AutoBarButtonFoodCombo"] = {
			buttonKey = "AutoBarButtonFoodCombo",
			buttonClass = "AutoBarButtonFoodCombo",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 17,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonBuff"]) then
		AutoBar.db.account.buttonList["AutoBarButtonBuff"] = {
			buttonKey = "AutoBarButtonBuff",
			buttonClass = "AutoBarButtonBuff",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 18,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonBuffWeapon1"]) then
		AutoBar.db.account.buttonList["AutoBarButtonBuffWeapon1"] = {
			buttonKey = "AutoBarButtonBuffWeapon1",
			buttonClass = "AutoBarButtonBuffWeapon",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 19,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonElixirBattle"]) then
		AutoBar.db.account.buttonList["AutoBarButtonElixirBattle"] = {
			buttonKey = "AutoBarButtonElixirBattle",
			buttonClass = "AutoBarButtonElixirBattle",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 20,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonElixirGuardian"]) then
		AutoBar.db.account.buttonList["AutoBarButtonElixirGuardian"] = {
			buttonKey = "AutoBarButtonElixirGuardian",
			buttonClass = "AutoBarButtonElixirGuardian",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 21,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonElixirBoth"]) then
		AutoBar.db.account.buttonList["AutoBarButtonElixirBoth"] = {
			buttonKey = "AutoBarButtonElixirBoth",
			buttonClass = "AutoBarButtonElixirBoth",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 22,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonTrack"]) then
		AutoBar.db.account.buttonList["AutoBarButtonTrack"] = {
			buttonKey = "AutoBarButtonTrack",
			buttonClass = "AutoBarButtonTrack",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 23,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonCrafting"]) then
		AutoBar.db.account.buttonList["AutoBarButtonCrafting"] = {
			buttonKey = "AutoBarButtonCrafting",
			buttonClass = "AutoBarButtonCrafting",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 24,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonQuest"]) then
		AutoBar.db.account.buttonList["AutoBarButtonQuest"] = {
			buttonKey = "AutoBarButtonQuest",
			buttonClass = "AutoBarButtonQuest",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 25,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonTrinket1"]) then
		AutoBar.db.account.buttonList["AutoBarButtonTrinket1"] = {
			buttonKey = "AutoBarButtonTrinket1",
			buttonClass = "AutoBarButtonTrinket1",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 26,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonTrinket2"]) then
		AutoBar.db.account.buttonList["AutoBarButtonTrinket2"] = {
			buttonKey = "AutoBarButtonTrinket2",
			buttonClass = "AutoBarButtonTrinket2",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = 27,
			enabled = true,
		}
	end

	if (not AutoBar.db.class.buttonList["AutoBarButtonBuffWeapon2"]) then
		AutoBar.db.class.buttonList["AutoBarButtonBuffWeapon2"] = {
			buttonKey = "AutoBarButtonBuffWeapon2",
			buttonClass = "AutoBarButtonBuffWeapon",
			barKey = "AutoBarClassBarBasic",
			defaultButtonIndex = "*",
			enabled = false,
			arrangeOnUse = true,
			invertButtons = true,
		}
		if (AutoBar.CLASS == "HUNTER" or AutoBar.CLASS == "ROGUE" or AutoBar.CLASS == "SHAMAN" or AutoBar.CLASS == "WARRIOR") then
			AutoBar.db.class.buttonList["AutoBarButtonBuffWeapon2"].enabled = true
		end
	end

	if (not AutoBar.db.account.buttonList["AutoBarButtonSpeed"]) then
		AutoBar.db.account.buttonList["AutoBarButtonSpeed"] = {
			buttonKey = "AutoBarButtonSpeed",
			buttonClass = "AutoBarButtonSpeed",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 1,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonFreeAction"]) then
		AutoBar.db.account.buttonList["AutoBarButtonFreeAction"] = {
			buttonKey = "AutoBarButtonFreeAction",
			buttonClass = "AutoBarButtonFreeAction",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 2,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonExplosive"]) then
		AutoBar.db.account.buttonList["AutoBarButtonExplosive"] = {
			buttonKey = "AutoBarButtonExplosive",
			buttonClass = "AutoBarButtonExplosive",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 3,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonFishing"]) then
		AutoBar.db.account.buttonList["AutoBarButtonFishing"] = {
			buttonKey = "AutoBarButtonFishing",
			buttonClass = "AutoBarButtonFishing",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 4,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonPets"]) then
		AutoBar.db.account.buttonList["AutoBarButtonPets"] = {
			buttonKey = "AutoBarButtonPets",
			buttonClass = "AutoBarButtonPets",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 5,
			enabled = true,
			arrangeOnUse = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonBattleStandards"]) then
		AutoBar.db.account.buttonList["AutoBarButtonBattleStandards"] = {
			buttonKey = "AutoBarButtonBattleStandards",
			buttonClass = "AutoBarButtonBattleStandards",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 6,
			enabled = true,
		}
	end
	if (not AutoBar.db.account.buttonList["AutoBarButtonOpenable"]) then
		AutoBar.db.account.buttonList["AutoBarButtonOpenable"] = {
			buttonKey = "AutoBarButtonOpenable",
			buttonClass = "AutoBarButtonOpenable",
			barKey = "AutoBarClassBarExtras",
			defaultButtonIndex = 7,
			enabled = true,
			drag = true,
		}
	end

	if (AutoBar.CLASS ~= "ROGUE" and AutoBar.CLASS ~= "WARRIOR") then
		if (not AutoBar.db.account.buttonList["AutoBarButtonWater"]) then
			AutoBar.db.account.buttonList["AutoBarButtonWater"] = {
				buttonKey = "AutoBarButtonWater",
				buttonClass = "AutoBarButtonWater",
				barKey = "AutoBarClassBarBasic",
				defaultButtonIndex = "AutoBarButtonFood",
				enabled = true,
				}
		end

		if (not AutoBar.db.account.buttonList["AutoBarButtonWaterBuff"]) then
			AutoBar.db.account.buttonList["AutoBarButtonWaterBuff"] = {
				buttonKey = "AutoBarButtonWaterBuff",
				buttonClass = "AutoBarButtonWaterBuff",
				barKey = "AutoBarClassBarBasic",
				defaultButtonIndex = "AutoBarButtonWater",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS == "HUNTER") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonFoodPet"]) then
			AutoBar.db.class.buttonList["AutoBarButtonFoodPet"] = {
				buttonKey = "AutoBarButtonFoodPet",
				buttonClass = "AutoBarButtonFoodPet",
				barKey = "AutoBarClassBarHunter",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
				rightClickTargetsPet = true,
			}
		end
		if (not AutoBar.db.class.buttonList["AutoBarButtonTrap"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTrap"] = {
				buttonKey = "AutoBarButtonTrap",
				buttonClass = "AutoBarButtonTrap",
				barKey = "AutoBarClassBarHunter",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
		if (not AutoBar.db.class.buttonList["AutoBarButtonSting"]) then
			AutoBar.db.class.buttonList["AutoBarButtonSting"] = {
				buttonKey = "AutoBarButtonSting",
				buttonClass = "AutoBarButtonSting",
				barKey = "AutoBarClassBarHunter",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS == "DRUID" or AutoBar.CLASS == "ROGUE" or AutoBar.CLASS == "MAGE") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonStealth"]) then
			AutoBar.db.class.buttonList["AutoBarButtonStealth"] = {
				buttonKey = "AutoBarButtonStealth",
				buttonClass = "AutoBarButtonStealth",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end

	if (AutoBar.CLASS == "DRUID" or AutoBar.CLASS == "HUNTER" or AutoBar.CLASS == "PRIEST" or AutoBar.CLASS == "MAGE" or AutoBar.CLASS == "WARLOCK") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonDebuff"]) then
			AutoBar.db.class.buttonList["AutoBarButtonDebuff"] = {
				buttonKey = "AutoBarButtonDebuff",
				buttonClass = "AutoBarButtonDebuff",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end

	if (AutoBar.CLASS == "MAGE" or AutoBar.CLASS == "WARLOCK") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonConjure"]) then
			AutoBar.db.class.buttonList["AutoBarButtonConjure"] = {
				buttonKey = "AutoBarButtonConjure",
				buttonClass = "AutoBarButtonConjure",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end

	if (AutoBar.CLASS ~= "ROGUE" and AutoBar.CLASS ~= "WARRIOR" and AutoBar.CLASS ~= "PALADIN") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonClassPet"]) then
			AutoBar.db.class.buttonList["AutoBarButtonClassPet"] = {
				buttonKey = "AutoBarButtonClassPet",
				buttonClass = "AutoBarButtonClassPet",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end

	if (AutoBar.CLASS ~= "ROGUE" and AutoBar.CLASS ~= "HUNTER") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonClassBuff"]) then
			AutoBar.db.class.buttonList["AutoBarButtonClassBuff"] = {
				buttonKey = "AutoBarButtonClassBuff",
				buttonClass = "AutoBarButtonClassBuff",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS ~= "HUNTER") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonShields"]) then
			AutoBar.db.class.buttonList["AutoBarButtonShields"] = {
				buttonKey = "AutoBarButtonShields",
				buttonClass = "AutoBarButtonShields",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS ~= "WARLOCK") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonER"]) then
			AutoBar.db.class.buttonList["AutoBarButtonER"] = {
				buttonKey = "AutoBarButtonER",
				buttonClass = "AutoBarButtonER",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
				noPopup = true,
			}
		end
	end

	if (AutoBar.CLASS == "DRUID" or AutoBar.CLASS == "WARRIOR") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonCharge"]) then
			AutoBar.db.class.buttonList["AutoBarButtonCharge"] = {
				buttonKey = "AutoBarButtonCharge",
				buttonClass = "AutoBarButtonCharge",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS == "HUNTER" or AutoBar.CLASS == "PALADIN") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonAura"]) then
			AutoBar.db.class.buttonList["AutoBarButtonAura"] = {
				buttonKey = "AutoBarButtonAura",
				buttonClass = "AutoBarButtonAura",
				barKey = AutoBar.classBar,
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end
	end

	if (AutoBar.CLASS == "ROGUE") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonPickLock"]) then
			AutoBar.db.class.buttonList["AutoBarButtonPickLock"] = {
				buttonKey = "AutoBarButtonPickLock",
				buttonClass = "AutoBarButtonPickLock",
				barKey = "AutoBarClassBarRogue",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
				targeted = "Lockpicking",
			}
		end
	end

	if (AutoBar.CLASS == "SHAMAN") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonTotemEarth"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTotemEarth"] = {
				buttonKey = "AutoBarButtonTotemEarth",
				buttonClass = "AutoBarButtonTotemEarth",
				barKey = "AutoBarClassBarShaman",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonTotemAir"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTotemAir"] = {
				buttonKey = "AutoBarButtonTotemAir",
				buttonClass = "AutoBarButtonTotemAir",
				barKey = "AutoBarClassBarShaman",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonTotemFire"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTotemFire"] = {
				buttonKey = "AutoBarButtonTotemFire",
				buttonClass = "AutoBarButtonTotemFire",
				barKey = "AutoBarClassBarShaman",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonTotemWater"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTotemWater"] = {
				buttonKey = "AutoBarButtonTotemWater",
				buttonClass = "AutoBarButtonTotemWater",
				barKey = "AutoBarClassBarShaman",
				defaultButtonIndex = "*",
				enabled = true,
				arrangeOnUse = true,
			}
		end

		if (not AutoBar.db.class.buttonList["AutoBarButtonTravel"]) then
			AutoBar.db.class.buttonList["AutoBarButtonTravel"] = {
				buttonKey = "AutoBarButtonTravel",
				buttonClass = "AutoBarButtonTravel",
				barKey = AutoBar.classBar,
				defaultButtonIndex = 3,
				enabled = true,
				noPopup = true,
			}
		end
	end

	if (AutoBar.CLASS == "WARLOCK") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonWarlockStones"]) then
			AutoBar.db.class.buttonList["AutoBarButtonWarlockStones"] = {
				buttonKey = "AutoBarButtonWarlockStones",
				buttonClass = "AutoBarButtonWarlockStones",
				barKey = "AutoBarClassBarWarlock",
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end

	if (AutoBar.CLASS == "WARRIOR") then
		if (not AutoBar.db.class.buttonList["AutoBarButtonStance"]) then
			AutoBar.db.class.buttonList["AutoBarButtonStance"] = {
				buttonKey = "AutoBarButtonStance",
				buttonClass = "AutoBarButtonStance",
				barKey = "AutoBarClassBarWarrior",
				defaultButtonIndex = "*",
				enabled = true,
			}
		end
	end
end

local changedCategoryKey = {
	["Consumable.Buff Type.Both"] = "Consumable.Buff Type.Flask"
}
function AutoBar:VerifyDB()
	-- Temporary, implement buttonKey field
	for buttonKey, buttonDB in pairs(AutoBar.db.char.buttonList) do
		buttonDB.buttonKey = buttonKey
		if (buttonDB.buttonClass ~= "AutoBarButtonCustom") then
			buttonDB.name = nil
		end
		for categoryIndex, categoryKey in ipairs(buttonDB) do
			local changedCategoryKey = changedCategoryKey[categoryKey]
			if (changedCategoryKey) then
				buttonDB[categoryIndex] = changedCategoryKey
			end
		end
	end
	for buttonKey, buttonDB in pairs(AutoBar.db.class.buttonList) do
		buttonDB.buttonKey = buttonKey
		if (buttonDB.buttonClass ~= "AutoBarButtonCustom") then
			buttonDB.name = nil
		end
		for categoryIndex, categoryKey in ipairs(buttonDB) do
			local changedCategoryKey = changedCategoryKey[categoryKey]
			if (changedCategoryKey) then
				buttonDB[categoryIndex] = changedCategoryKey
			end
		end
	end
	for buttonKey, buttonDB in pairs(AutoBar.db.account.buttonList) do
		buttonDB.buttonKey = buttonKey
		if (buttonDB.buttonClass ~= "AutoBarButtonCustom") then
			buttonDB.name = nil
		end
		for categoryIndex, categoryKey in ipairs(buttonDB) do
			local changedCategoryKey = changedCategoryKey[categoryKey]
			if (changedCategoryKey) then
				buttonDB[categoryIndex] = changedCategoryKey
			end
		end
	end
end

-- Populate AutoBar.buttonDBList with the correct DB from char, class or account
function AutoBar:RefreshButtonDBList()
	local buttonDBList = AutoBar.buttonDBList
	for buttonKey, buttonDB in pairs(buttonDBList) do
		buttonDBList[buttonKey] = nil
	end
	for buttonKey, buttonDB in pairs(AutoBar.db.char.buttonList) do
		buttonDBList[buttonKey] = AutoBar:GetButtonDB(buttonKey)
	end
	for buttonKey, buttonDB in pairs(AutoBar.db.class.buttonList) do
		buttonDBList[buttonKey] = AutoBar:GetButtonDB(buttonKey)
	end
	for buttonKey, buttonDB in pairs(AutoBar.db.account.buttonList) do
		buttonDBList[buttonKey] = AutoBar:GetButtonDB(buttonKey)
	end
end
--AutoBar:Print("AutoBar:RefreshButtonDBList<-- " .. tostring(buttonKey) .. " buttonDBList[buttonKey] " .. tostring(buttonDBList[buttonKey]))

-- Populate AutoBar.unplacedButtonList with buttons that are not on a bar
function AutoBar:RefreshUnplacedButtonList()
	local unplacedButtonList = AutoBar.unplacedButtonList
	wipe(unplacedButtonList)

	-- Duplicate all buttons
	local buttonDBList = AutoBar.buttonDBList
	for buttonKey, buttonDB in pairs(buttonDBList) do
		unplacedButtonList[buttonKey] = L[buttonKey]
	end

--[[
	-- Remove placed ones
	local barButtonsDBList = AutoBar.barButtonsDBList
	for barKey, barDB in pairs(barButtonsDBList) do
		local buttonKeys = barDB.buttonKeys
		for buttonKeyIndex, buttonKey in pairs(buttonKeys) do
			unplacedButtonList[buttonKey] = nil
		end
	end
--]]
end

-- Populate AutoBar.barLayoutDBList, barButtonsDBList, barPositionDBList with the correct DB from char, class or account
function AutoBar:RefreshBarDBLists()
	local barButtonsDBList = AutoBar.barButtonsDBList
	local barLayoutDBList = AutoBar.barLayoutDBList
	local barPositionDBList = AutoBar.barPositionDBList
	wipe(barButtonsDBList)
	wipe(barLayoutDBList)
	wipe(barPositionDBList)
	for barKey, barDB in pairs(AutoBar.db.char.barList) do
		barButtonsDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedButtons")
		barLayoutDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLayout")
		barPositionDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLocation")
	end
	for barKey, barDB in pairs(AutoBar.db.class.barList) do
		barButtonsDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedButtons")
		barLayoutDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLayout")
		barPositionDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLocation")
	end
	for barKey, barDB in pairs(AutoBar.db.account.barList) do
		barButtonsDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedButtons")
		barLayoutDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLayout")
		barPositionDBList[barKey] = AutoBar:GetSharedBarDB(barKey, "sharedLocation")
	end

	for barKey, bar in pairs(AutoBar.barList) do
		bar:UpdateShared()
	end

	local barValidateList = AutoBar.barValidateList
	wipe(barValidateList)
	barValidateList[""] = L["None"]
	for barKey, barDB in pairs(barLayoutDBList) do
		if (not L[barKey]) then
			L[barKey] = barLayoutDBList[barKey].name
		end
		barValidateList[barKey] = L[barKey]
	end
end

function AutoBar:ButtonExists(barDB, targetButtonDB)
	for buttonKeyIndex, buttonKey in ipairs(barDB.buttonKeys) do
		if (buttonKey == targetButtonDB.buttonKey) then
			return true
		end
	end
	return false
end

local foundButtons = {}
-- Changing sharing may expose duplicate buttons. Also dragging from lower shared levels to higher shared levels may result in duplicates cross character.
-- Use the Button's barKey to resolve issues.
function AutoBar:RemoveDuplicateButtons()
	local barButtonsDBList = AutoBar.barButtonsDBList
	local buttonDBList = AutoBar.buttonDBList

	for buttonKey in pairs(foundButtons) do
		foundButtons[buttonKey] = nil
	end

	for barKey, barDB in pairs(barButtonsDBList) do
		local delete
		local buttonKeys = barDB.buttonKeys
		local nKeys = 0

		-- Remove Bar Duplicates
		for buttonKeyIndex, buttonKey in pairs(buttonKeys) do
			foundBarKey = foundButtons[buttonKey]
			if (foundBarKey and foundBarKey == barKey) then
				buttonKeys[buttonKeyIndex] = false
				delete = true
			else
				foundButtons[buttonKey] = barKey
			end
			if (buttonKeyIndex > nKeys) then
				nKeys = buttonKeyIndex
			end
		end
		if (delete) then
			local buttonKeyList = buttonKeys
			for index = nKeys, 1, -1 do
				if (buttonKeyList[index] == false) then
					local numKeys = # buttonKeyList
					buttonKeyList[index] = nil
					for buttonIndex = index, numKeys - 1, 1 do
						buttonKeyList[buttonIndex] = buttonKeyList[buttonIndex + 1]
					end
				end
			end
		end

		-- Adjust Bar Location
		delete = false
		for buttonKeyIndex, buttonKey in ipairs(buttonKeys) do
			local buttonDB = buttonDBList[buttonKey]
			if (buttonDB) then
				if (not buttonDB.barKey) then
					-- Not officially placed, so place
					buttonDB.barKey = barKey
				end
				if (buttonDB.barKey ~= barKey) then
					local currentBarDB = barButtonsDBList[buttonDB.barKey]
					if (not currentBarDB) then
						-- Placed on a currently unaccesible Bar.  Adjust official location.
						-- ToDo: This implies placement on class or character only bar.  Should change sharing when doing that for the Button.
						buttonDB.barKey = barKey
					elseif (AutoBar:ButtonExists(currentBarDB, buttonDB)) then
						-- Exists in official location.  Remove duplicate.
						buttonKeys[buttonKeyIndex] = false
						delete = true
					else
						-- Not in official location.  Adjust official location.
						buttonDB.barKey = barKey
					end
				end
			end
		end
		if (delete) then
			local buttonKeyList = buttonKeys
			for index = nKeys, 1, -1 do
				if (buttonKeyList[index] == false) then
					local numKeys = # buttonKeyList
					buttonKeyList[index] = nil
					for buttonIndex = index, numKeys - 1, 1 do
						buttonKeyList[buttonIndex] = buttonKeyList[buttonIndex + 1]
					end
				end
			end
		end
	end
end

function AutoBar:ButtonInsertNew(barDB, buttonDB)
	for buttonDBIndex, buttonKey in ipairs(barDB.buttonKeys) do
		if (buttonKey == buttonDB.defaultButtonIndex) then
--AutoBar:Print("AutoBar:ButtonInsertNew buttonDBIndex + 1 " .. tostring(buttonDBIndex + 1) .. " " .. tostring(buttonDB.buttonKey) .. " # barDB.buttonKeys " .. tostring(# barDB.buttonKeys))
			table.insert(barDB.buttonKeys, buttonDBIndex + 1, buttonDB.buttonKey)
--AutoBar:Print("AutoBar:ButtonInsertNew # barDB.Buttons " .. tostring(# barDB.buttons))
			return nil
		end
	end
	return buttonDB
end

-- /script AutoBar:BarsCompact()
function AutoBar:BarsCompact()
	for barKey, barDB in pairs(AutoBar.barButtonsDBList) do
--AutoBar:Print("AutoBar:BarsCompact barKey " .. tostring(barKey) .. " AutoBar.barLayoutDBList[barKey].buttonKeys " .. tostring(AutoBar.barLayoutDBList[barKey].buttonKeys))
		local buttonKeys = barDB.buttonKeys
		local badIndexMax = nil
		local nKeys = 0
		for buttonKeyIndex, buttonKey in pairs(buttonKeys) do
			if (buttonKeyIndex > 1 and buttonKeys[buttonKeyIndex - 1] == nil) then
				badIndexMax = buttonKeyIndex
			end
			if (buttonKeyIndex > nKeys) then
				nKeys = buttonKeyIndex
			end
		end
		if (badIndexMax) then
--print("AutoBar:BarsCompact badIndexMax " .. tostring(badIndexMax))
			local source = 0
			local sink = 1
			local sinkButtonKey, sourceButtonKey
			while true do
				sinkButtonKey = buttonKeys[sink]
				if (sinkButtonKey) then
					sink = sink + 1
				else
					if (source < sink) then
						source = sink + 1
					end
					while source <= nKeys do
						sourceButtonKey = buttonKeys[source]
						if (sourceButtonKey) then
							-- Move it
							buttonKeys[sink] = sourceButtonKey
							buttonKeys[source] = nil
							sink = sink + 1
							source = source + 1
							break
						else
							source = source + 1
						end
					end
				end
				if (source > nKeys or sink > nKeys) then
					break
				end
			end
		end
	end
end

function AutoBar:ButtonPopulateNew(buttonDB)
	newButtonDB = {}
	-- ToDo: Upgrade if there is ever a table inside
	for key, value in pairs(buttonDB) do
		newButtonDB[key] = value
	end
	newButtonDB.barKey = nil
	newButtonDB.defaultButtonIndex = nil
--AutoBar:Print("AutoBar:ButtonPopulateNew " .. tostring(newButtonDB.buttonKey))
	return newButtonDB
end


local insertList = {}
local appendList = {}

-- if ignorePlace then ignore previous placement
function AutoBar:PopulateBars(ignorePlace)
	local barButtonsDBList = AutoBar.barButtonsDBList
	local barDB, buttonIndex
	for index in pairs(insertList) do
		insertList[index] = nil
	end
	for index in pairs(appendList) do
		appendList[index] = nil
	end
	for buttonKey, buttonDB in pairs(AutoBar.buttonDBList) do
		if (buttonDB.barKey) then
			barDB = barButtonsDBList[buttonDB.barKey]
		else
			barDB = nil
		end
		if (barDB and not AutoBar:ButtonExists(barDB, buttonDB)) then
			buttonIndex = nil
			if (type(buttonDB.defaultButtonIndex) == "number") then
				buttonIndex = tonumber(buttonDB.defaultButtonIndex)
			elseif (type(buttonDB.defaultButtonIndex) == "string") then
				-- "*" append, "~" do not place, "buttonKey" insert after the button
				if (buttonDB.defaultButtonIndex == "*") then
--AutoBar:Print("AutoBar:PopulateBars # appendList + 1 " .. tostring(# appendList + 1) .. " " .. tostring(buttonDB.buttonKey) .. " buttonKey " .. tostring(buttonKey))
					appendList[# appendList + 1] = buttonDB
				elseif (buttonDB.defaultButtonIndex == "~") then
				else
					insertList[# insertList + 1] = buttonDB
				end
			end
			if (buttonIndex) then
				if (barDB.buttonKeys[buttonIndex]) then
					appendList[# appendList + 1] = buttonDB
				else
					barDB.buttonKeys[buttonIndex] = buttonDB.buttonKey
--AutoBar:Print("AutoBar:PopulateBars buttonIndex " .. tostring(buttonIndex) .. " " .. tostring(buttonDB.buttonKey) .. " buttonKey " .. tostring(buttonKey))
				end
			end
		end
	end
	AutoBar:BarsCompact()
	for index, buttonDB in ipairs(insertList) do
		barDB = barButtonsDBList[buttonDB.barKey]
		local couldNotInsertDB = AutoBar:ButtonInsertNew(barDB, buttonDB)
		if (couldNotInsertDB) then
			appendList[# appendList + 1] = couldNotInsertDB
		end
	end
--AutoBar:Print("AutoBar:BarsCompact ")
	for index, buttonDB in ipairs(appendList) do
		barDB = barButtonsDBList[buttonDB.barKey]
		local nButtons = # barDB.buttonKeys + 1
		barDB.buttonKeys[nButtons] = buttonDB.buttonKey
--AutoBar:Print("AutoBar:PopulateBars append nButtons " .. tostring(nButtons) .. " " .. tostring(buttonDB.buttonKey))
	end
end

-- /dump AutoBar.options.args.bars.args["AutoBarClassBarBasic"].args.buttons.args[1]
-- /dump AutoBar.db.class.barList["AutoBarClassBarHunter"]
-- /dump AutoBar.db.class.barList["AutoBarClassBarHunter"].buttonKeys
-- /dump (# AutoBar.db.class.barList["AutoBarClassBarHunter"].buttonKeys)
-- /dump AutoBar.options.args.categories
--AutoBar:Print("AutoBar:DragStop" .. frame:GetName() .. " x/y " .. tostring().. " / " ..tostring())
-- /script AutoBar.db.account.customCategories = nil


-- Upgrade from old DB versions
local dbVersion = 2
local renameButtonList
local renameBarList

function AutoBar:UpgradeBar(barKey, barDB)
	if (barDB.isCustomBar) then
		local oldKey = barDB.barKey
		local newName = AutoBar:GetValidatedName(barDB.name)
		if (newName ~= barDB.name) then
			renameBarList[oldKey] = newName
		end
	end
end

function AutoBar:UpgradeButton(buttonKey, buttonDB)
	if (buttonDB.buttonClass == "AutoBarButtonCustom") then
		local oldKey = buttonDB.buttonKey
		local newName = AutoBar:GetValidatedName(buttonDB.name)
		if (newName ~= buttonDB.name) then
			renameButtonList[oldKey] = newName
		end
	end
end

-- Options are at three levels: Account, Class, Character
function AutoBar:UpgradeLevel(levelDB)
	if (levelDB.barList) then
		for barKey, barDB in pairs(levelDB.barList) do
			AutoBar:UpgradeBar(barKey, barDB)
		end
	end
	if (levelDB.buttonList) then
		for buttonKey, buttonDB in pairs(levelDB.buttonList) do
			AutoBar:UpgradeButton(buttonKey, buttonDB)
		end
	end
end

function AutoBar:UpgradeVersion()
	if (not AutoBar.db.account.dbVersion) then
		AutoBar.db.account.customBarList = nil
		AutoBar.db.account.bars = nil
		if (AutoBarDB.classes) then
			for classKey, classDB in pairs (AutoBarDB.classes) do
				if (classDB.bars) then
					classDB.bars = nil
					if (not classDB.barList and not classDB.buttonList) then
						AutoBarDB.classes[classKey] = nil
					end
				end
			end
		end
		if (AutoBarDB.chars) then
			for charKey, charDB in pairs (AutoBarDB.chars) do
				if (charDB.bars) then
					charDB.bars = nil
					if (not charDB.barList and not charDB.buttonList) then
						AutoBarDB.chars[charKey] = nil
					end
				end
			end
		end
		AutoBarDB.currentProfile = nil
		AutoBarDB.profiles = nil
		AutoBar.db.account.dbVersion = 1
	end
	if (AutoBar.db.account.dbVersion < dbVersion) then
		if (not renameButtonList) then
			renameButtonList = {}
		end
		wipe(renameButtonList)
		if (not renameBarList) then
			renameBarList = {}
		end
		wipe(renameBarList)

		AutoBar:UpgradeLevel(AutoBarDB.account)
		if (AutoBarDB.classes) then
			for classKey, classDB in pairs (AutoBarDB.classes) do
				AutoBar:UpgradeLevel(classDB)
			end
		end
		if (AutoBarDB.chars) then
			for charKey, charDB in pairs (AutoBarDB.chars) do
				AutoBar:UpgradeLevel(charDB)
			end
		end

		for oldKey, newName in pairs(renameButtonList) do
			AutoBar.Class.Button:Rename(oldKey, newName)
		end
		for oldKey, newName in pairs(renameBarList) do
			AutoBar.Class.Bar:Rename(oldKey, newName)
		end
--		AutoBar.db.account.dbVersion = 2
	end
end


