--[[
Name: AutoBar
Author: Toadkiller of Proudmoore
Credits: Saien the original author.  Sayclub (Korean), PDI175 (Chinese traditional and simplified), Teodred (German), Cinedelle (French), shiftos (Spanish)
Website: http://www.wowace.com/
Description: Dynamic 24 button bar automatically adds potions, water, food and other items you specify into a button for use. Does not use action slots so you can save those for spells and abilities.
--]]
local REVISION = tonumber(("$Revision: 783 $"):match("%d+"))
local DATE = ("$Date: 2007-05-31 17:44:03 -0400 (Thu, 31 May 2007) $"):match("%d%d%d%d%-%d%d%-%d%d")
--
-- Copyright 2004, 2005, 2006 original author.
-- New Stuff Copyright 2006+ Toadkiller of Proudmoore.

-- Maintained by Azethoth / Toadkiller of Proudmoore.  Original author Saien of Hyjal
-- http://code.google.com/p/autobar/

-- See Changelist.lua for changes


--
-- The Update Cycle / Hierarchy
--

-- Initialize
-- UpdateCategories
-- UpdateCustomBars
-- UpdateCustomButtons
-- UpdateSpells
-- UpdateObjects
-- UpdateRescan
-- UpdateScan
-- UpdateAttributes
-- UpdateActive
-- UpdateButtons

-- In normal operation after one each of UpdateCategories through UpdateObjects, only UpdateRescan & down are required.
-- The Update functions can be called directly or via AutoBar.delay["UpdateButtons"].
-- Delayed calls allow multiple updates to clump & get dealt with at once, especially after combat ends.

local _G = getfenv(0)
local LibKeyBound = LibStub("LibKeyBound-1.0")
local LibStickyFrames = LibStub("LibStickyFrames-2.0")
local AceOO = AceLibrary("AceOO-2.0")
local AceEvent = AceLibrary("AceEvent-2.0")
local LBF = LibStub("LibButtonFacade", true)
local AceCfgDlg = LibStub("AceConfigDialog-3.0")
local L

-- If the Debug library is available then use it
if AceLibrary:HasInstance("AceDebug-2.0") then
	AutoBar = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceHook-2.1", "AceDebug-2.0");
else
	AutoBar = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceDB-2.0", "AceHook-2.1");
end
local AutoBar = AutoBar
AutoBar.revision = REVISION
AutoBar.date = DATE

-- List of [spellName] = <GetSpellInfo Name>
AutoBar.spellNameList = {}
-- List of [spellName] = <GetSpellInfo Icon>
AutoBar.spellIconList = {}

AutoBar.events = {}

AutoBar.delay = {}


function AutoBar:ConfigToggle()
	if (not InCombatLockdown()) then
---		if (waterfall:IsOpen("AutoBar")) then
---			waterfall:Close("AutoBar")
---		else
			AutoBar:OpenOptions()
---		end
	end
end


function AutoBar:OnInitialize()
	L = AutoBar.locale
	BINDING_HEADER_AUTOBAR_SEP = L["AutoBar"];
	BINDING_NAME_AUTOBAR_CONFIG = L["CONFIG_WINDOW"];

	BINDING_HEADER_AutoBarButtonHeader = L["AutoBarButtonHeader"]
	BINDING_NAME_AutoBarButtonHearth_X = L["AutoBarButtonHearth"]
	BINDING_NAME_AutoBarButtonMount_X = L["AutoBarButtonMount"]
	BINDING_NAME_AutoBarButtonBandages_X = L["AutoBarButtonBandages"]
	BINDING_NAME_AutoBarButtonCrafting_X = L["AutoBarButtonCrafting"]
	BINDING_NAME_AutoBarButtonHeal_X = L["AutoBarButtonHeal"]
	BINDING_NAME_AutoBarButtonRecovery_X = L["AutoBarButtonRecovery"]
	BINDING_NAME_AutoBarButtonFood_X = L["AutoBarButtonFood"]
	BINDING_NAME_AutoBarButtonFoodBuff_X = L["AutoBarButtonFoodBuff"]
	BINDING_NAME_AutoBarButtonFoodCombo_X = L["AutoBarButtonFoodCombo"]
	BINDING_NAME_AutoBarButtonBuff_X = L["AutoBarButtonBuff"]
	BINDING_NAME_AutoBarButtonBuffWeapon1_X = L["AutoBarButtonBuffWeapon1"]
	BINDING_NAME_AutoBarButtonBuffWeapon2_X = L["AutoBarButtonBuffWeapon2"]
	BINDING_NAME_AutoBarButtonCharge_X = L["AutoBarButtonCharge"]
	BINDING_NAME_AutoBarButtonClassBuff_X = L["AutoBarButtonClassBuff"]
	BINDING_NAME_AutoBarButtonShields_X = L["AutoBarButtonShields"]
	BINDING_NAME_AutoBarButtonClassPet_X = L["AutoBarButtonClassPet"]
	BINDING_NAME_AutoBarButtonFreeAction_X = L["AutoBarButtonFreeAction"]
	BINDING_NAME_AutoBarButtonER_X = L["AutoBarButtonER"]
	BINDING_NAME_AutoBarButtonExplosive_X = L["AutoBarButtonExplosive"]
	BINDING_NAME_AutoBarButtonFishing_X = L["AutoBarButtonFishing"]
	BINDING_NAME_AutoBarButtonBattleStandards_X = L["AutoBarButtonBattleStandards"]
	BINDING_NAME_AutoBarButtonTrinket1_X = L["AutoBarButtonTrinket1"]
	BINDING_NAME_AutoBarButtonTrinket2_X = L["AutoBarButtonTrinket2"]
	BINDING_NAME_AutoBarButtonPets_X = L["AutoBarButtonPets"]
	BINDING_NAME_AutoBarButtonQuest_X = L["AutoBarButtonQuest"]
	BINDING_NAME_AutoBarButtonSpeed_X = L["AutoBarButtonSpeed"]
	BINDING_NAME_AutoBarButtonStance_X = L["AutoBarButtonStance"]
	BINDING_NAME_AutoBarButtonStealth_X = L["AutoBarButtonStealth"]
	BINDING_NAME_AutoBarButtonWater_X = L["AutoBarButtonWater"]

	BINDING_HEADER_AutoBarClassBarExtras = L["AutoBarClassBarExtras"]

	BINDING_HEADER_AutoBarCooldownHeader = L["AutoBarCooldownHeader"]
	BINDING_NAME_AutoBarButtonCooldownDrums_X = L["AutoBarButtonCooldownDrums"]
	BINDING_NAME_AutoBarButtonCooldownPotionCombat_X = L["AutoBarButtonCooldownPotionCombat"]
	BINDING_NAME_AutoBarButtonCooldownStoneCombat_X = L["AutoBarButtonCooldownStoneCombat"]
	BINDING_NAME_AutoBarButtonCooldownPotionHealth_X = L["AutoBarButtonCooldownPotionHealth"]
	BINDING_NAME_AutoBarButtonCooldownStoneHealth_X = L["AutoBarButtonCooldownStoneHealth"]
	BINDING_NAME_AutoBarButtonCooldownPotionMana_X = L["AutoBarButtonCooldownPotionMana"]
	BINDING_NAME_AutoBarButtonCooldownStoneMana_X = L["AutoBarButtonCooldownStoneMana"]
	BINDING_NAME_AutoBarButtonCooldownPotionRejuvenation_X = L["AutoBarButtonCooldownPotionRejuvenation"]
	BINDING_NAME_AutoBarButtonCooldownStoneRejuvenation_X = L["AutoBarButtonCooldownStoneRejuvenation"]
	BINDING_NAME_AutoBarButtonRotationDrums_X = L["AutoBarButtonRotationDrums"]

	BINDING_HEADER_AutoBarClassBarHeader = L["AutoBarClassBarHeader"]
	BINDING_NAME_AutoBarButtonDebuff_X = L["AutoBarButtonDebuff"]

	BINDING_HEADER_AutoBarClassBarDeathKnight = L["AutoBarClassBarDeathKnight"]

	BINDING_HEADER_AutoBarClassBarDruid = L["AutoBarClassBarDruid"]
	BINDING_NAME_AutoBarButtonBear_X = L["AutoBarButtonBear"]
	BINDING_NAME_AutoBarButtonBoomkinTree_X = L["AutoBarButtonBoomkinTree"]
	BINDING_NAME_AutoBarButtonCat_X = L["AutoBarButtonCat"]
	BINDING_NAME_AutoBarButtonPowerShift_X = L["AutoBarButtonPowerShift"]
	BINDING_NAME_AutoBarButtonTravel_X = L["AutoBarButtonTravel"]

	BINDING_HEADER_AutoBarClassBarHunter = L["AutoBarClassBarHunter"]
	BINDING_NAME_AutoBarButtonFoodPet_X = L["AutoBarButtonFoodPet"]
	BINDING_NAME_AutoBarButtonSting_X = L["AutoBarButtonSting"]
	BINDING_NAME_AutoBarButtonTrap_X = L["AutoBarButtonTrap"]

	BINDING_HEADER_AutoBarClassBarMage = L["AutoBarClassBarMage"]

	BINDING_HEADER_AutoBarClassBarPaladin = L["AutoBarClassBarPaladin"]

	BINDING_HEADER_AutoBarClassBarPriest = L["AutoBarClassBarPriest"]

	BINDING_HEADER_AutoBarClassBarRogue = L["AutoBarClassBarRogue"]
	BINDING_NAME_AutoBarButtonPickLock_X = L["AutoBarButtonPickLock"]

	BINDING_HEADER_AutoBarClassBarShaman = L["AutoBarClassBarShaman"]
	BINDING_NAME_AutoBarButtonTotemAir_X = L["AutoBarButtonTotemAir"]
	BINDING_NAME_AutoBarButtonTotemEarth_X = L["AutoBarButtonTotemEarth"]
	BINDING_NAME_AutoBarButtonTotemFire_X = L["AutoBarButtonTotemFire"]
	BINDING_NAME_AutoBarButtonTotemWater_X = L["AutoBarButtonTotemWater"]

	BINDING_HEADER_AutoBarClassBarWarlock = L["AutoBarClassBarWarlock"]
	BINDING_NAME_AutoBarButtonWarlockStones_X = L["AutoBarButtonWarlockStones"]

	BINDING_HEADER_AutoBarClassBarWarrior = L["AutoBarClassBarWarrior"]

	AutoBar.dockingFramesValidateList = {
		["NONE"] = L["None"],
		["BT3Bar1"] = L["AUTOBAR_CONFIG_BT3BAR"]..1,
		["BT3Bar2"] = L["AUTOBAR_CONFIG_BT3BAR"]..2,
		["BT3Bar3"] = L["AUTOBAR_CONFIG_BT3BAR"]..3,
		["BT3Bar4"] = L["AUTOBAR_CONFIG_BT3BAR"]..4,
		["BT3Bar6"] = L["AUTOBAR_CONFIG_BT3BAR"]..6,
		["BT3Bar10"] = L["AUTOBAR_CONFIG_BT3BAR"]..10,
		["MainMenuBarArtFrame"] = L["AUTOBAR_CONFIG_DOCKTOMAIN"],
		["ChatFrame1"] = L["AUTOBAR_CONFIG_DOCKTOCHATFRAME"],
		["ChatFrameMenuButton"] = L["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"],
		["MainMenuBar"] = L["AUTOBAR_CONFIG_DOCKTOACTIONBAR"],
		["CharacterMicroButton"] = L["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"],
	}

	AutoBar.dockingFrames = {
		["NONE"] = {
			text = L["None"],
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["BT3Bar1"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..1,
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["BT3Bar2"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..2,
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["BT3Bar3"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..3,
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["BT3Bar4"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..4,
			offset = { x = 0, y = 0, point = "CENTER", relative = "BOTTOMLEFT" },
		},
		["BT3Bar6"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..6,
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["BT3Bar10"] = {
			text = L["AUTOBAR_CONFIG_BT3BAR"]..10,
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPLEFT" },
		},
		["MainMenuBarArtFrame"] = {
			text = L["AUTOBAR_CONFIG_DOCKTOMAIN"],
			offset = { x = 0, y = 0, point = "CENTER", relative = "TOPRIGHT" },
		},
		["ChatFrame1"] = {
			text = L["AUTOBAR_CONFIG_DOCKTOCHATFRAME"],
			offset = { x = 0, y = 25, point = "CENTER", relative = "TOPLEFT" },
		},
		["ChatFrameMenuButton"] = {
			text = L["AUTOBAR_CONFIG_DOCKTOCHATFRAMEMENU"],
			offset = { x = 0, y = 25, point = "CENTER", relative = "TOPLEFT" },
		},
		["MainMenuBar"] = {
			text = L["AUTOBAR_CONFIG_DOCKTOACTIONBAR"],
			offset = { x = 7, y = 40, point = "CENTER", relative = "TOPLEFT" },
		},
		["CharacterMicroButton"] = {
			text = L["AUTOBAR_CONFIG_DOCKTOMENUBUTTONS"],
			offset = { x = 0, y = 0, point = "CENTER", relative = "BOTTOMLEFT" },
		},
	}

	AutoBar.currentPlayer = UnitName("player") .. " - " .. GetCVar("realmName");
	_, AutoBar.CLASS = UnitClass("player")
	AutoBar.CLASSPROFILE = "_" .. AutoBar.CLASS;

	AutoBar:RegisterDB("AutoBarDB", nil, "class")

	AutoBar.inWorld = false
	AutoBar.inCombat = nil		-- For item use restrictions
	AutoBar.inBG = false		-- For battleground only items
	AutoBar.flyable = SecureCmdOptionParse("[flyable]1")

	-- Single parent for key binding overides, and event handling
	AutoBar.frame = CreateFrame("Frame", nil, UIParent)
	AutoBar.frame:SetScript("OnEvent",
		function(self, event, ...)
			AutoBar.events[event](AutoBar, ...)
		end)

	-- List of barKey = barDB (the correct DB to use between char, class or account)
	AutoBar.barButtonsDBList = {}
	AutoBar.barLayoutDBList = {}
	AutoBar.barPositionDBList = {}

	-- List of Bar Names
	AutoBar.barValidateList = {}

	-- List of buttonKey = buttonDB (the correct DB to use between char, class or account)
	AutoBar.buttonDBList = {}

	-- List of buttonKey for Buttons not currently placed on a Bar
	AutoBar.unplacedButtonList = {}

	-- List of buttonName = AutoBarButton
	AutoBar.buttonList = {}

	-- List of buttonName = AutoBarButton for disabled buttons
	AutoBar.buttonListDisabled = {}

--	AutoBar.db.account.performance = true
	AutoBar:LogEvent("OnInitialize")
	AutoBar:InitializeDB()
	AutoBarCategory:Upgrade()
	AutoBar:InitializeOptions()
	AutoBar:Initialize()
--	AutoBar.db.account.performance = false
--print("--> FullyInitialized")
	AutoBar:RegisterEvent("AceEvent_FullyInitialized", "FullyInitialized")
end

function AutoBar:FullyInitialized()
--print("<-- FullyInitialized")
	AutoBar.enableBindings = true
	AutoBar:UpdateCategories()
--	AutoBar.delay["UpdateObjects"]:Start()
end

function AutoBar:OnEnable(first)
	self:LogEvent("OnEnable")

	-- Called when the addon is enabled
	AutoBar.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	AutoBar.frame:RegisterEvent("PLAYER_LEAVING_WORLD")
	AutoBar.frame:RegisterEvent("BAG_UPDATE")
	AutoBar.frame:RegisterEvent("LEARNED_SPELL_IN_TAB")
	AutoBar.frame:RegisterEvent("SPELLS_CHANGED")
	AutoBar.frame:RegisterEvent("ACTIONBAR_UPDATE_USABLE")

	-- For item use restrictions
	AutoBar.frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	AutoBar.frame:RegisterEvent("MINIMAP_ZONE_CHANGED")
	AutoBar.frame:RegisterEvent("ZONE_CHANGED")
	AutoBar.frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	AutoBar.frame:RegisterEvent("PLAYER_ALIVE")
	AutoBar.frame:RegisterEvent("PLAYER_AURAS_CHANGED")
	AutoBar.frame:RegisterEvent("PLAYER_CONTROL_GAINED")
	AutoBar.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
	AutoBar.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	AutoBar.frame:RegisterEvent("PLAYER_UNGHOST")
	AutoBar.frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	AutoBar.frame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	AutoBar.frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	AutoBar.frame:RegisterEvent("COMPANION_UPDATE")
	AutoBar.frame:RegisterEvent("COMPANION_LEARNED")

	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_ENABLED")
	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_DISABLED")
	LibKeyBound.RegisterCallback(self, "LIBKEYBOUND_MODE_COLOR_CHANGED")

	LibStickyFrames.RegisterCallback(self, "OnSetGroup")
	LibStickyFrames.RegisterCallback(self, "OnClick")
--	LibStickyFrames.RegisterCallback(self, "OnStartFrameMoving")
	LibStickyFrames.RegisterCallback(self, "OnStopFrameMoving")
	LibStickyFrames.RegisterCallback(self, "OnStickToFrame")
end


function AutoBar:OnDisable()
	-- Called when the addon is disabled
	AutoBar:LogEvent("OnDisable")
end

local logItems = {}	-- n = startTime
local logMemory = {}	-- n = startMemory

function AutoBar:LogEvent(eventName, arg1)
	if (AutoBar.db.account.logMemory) then
		UpdateAddOnMemoryUsage()
		local memory = GetAddOnMemoryUsage("AutoBar")
		print(eventName, "memory" , memory)
	end
	if (AutoBar.db.account.performance or AutoBar.db.account.logEvents) then
		if (arg1) then
			print(eventName, "arg1" , arg1, "time:", GetTime(), memString, memory)
		else
			print(eventName, "time:", GetTime())
		end
	end
end

function AutoBar:LogEventStart(eventName)
	if (AutoBar.db.account.logMemory) then
		UpdateAddOnMemoryUsage()
		local memory = GetAddOnMemoryUsage("AutoBar")
--			print(eventName, "memory" , memory)
		logMemory[eventName] = memory
	end
	if (AutoBar.db.account.performance) then
		if (logItems[eventName]) then
			print(eventName, "restarted before previous completion")
		else
			logItems[eventName] = GetTime()
			print(eventName, "started time:", logItems[eventName])
		end
	end
end

function AutoBar:LogEventEnd(eventName, arg1)
	if (AutoBar.db.account.performance) then
		if (logItems[eventName]) then
			local elapsed = GetTime() - logItems[eventName]
			logItems[eventName] = nil
			if (arg1) then
				print(eventName, arg1, "time:", elapsed)
			else
				print(eventName, "time:", elapsed)
			end
		else
			print(eventName, "restarted before previous completion")
		end
	end
	if (AutoBar.db.account.logMemory) then
		UpdateAddOnMemoryUsage()
		local memory = GetAddOnMemoryUsage("AutoBar")
		local deltaMemory = memory - (logMemory[eventName] or 0)
		print(eventName, "memory" , deltaMemory)
		logMemory[eventName] = nil
	end
end


-- Will not update if set during combat
function AutoBar:RegisterOverrideBindings()
	AutoBar:LogEvent("RegisterOverrideBindings")
	ClearOverrideBindings(AutoBar.frame)
	for buttonKey, buttonDB in pairs(AutoBar.buttonDBList) do
		AutoBar.Class.Button:UpdateBindings(buttonKey, buttonKey .. "Frame")
	end
end


-- Layered delayed callback objects
-- Timers lower down the list are superceded and cancelled by those higher up
local timerList = {
	{name = "AutoBarInit", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateCategories", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateCustomBars", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateCustomButtons", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateSpells", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateObjects", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateRescan", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateScan", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateAttributes", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateActive", timer = nil, runPostCombat = false, callback = nil},
	{name = "UpdateButtons", timer = nil, runPostCombat = false, callback = nil},
}
local timerIndexList = {
	["AutoBarInit"] = 1,
	["UpdateCategories"] = 2,
	["UpdateCustomBars"] = 3,
	["UpdateCustomButtons"] = 4,
	["UpdateSpells"] = 5,
	["UpdateObjects"] = 6,
	["UpdateRescan"] = 7,
	["UpdateScan"] = 8,
	["UpdateAttributes"] = 9,
	["UpdateActive"] = 10,
	["UpdateButtons"] = 11,
}
local IDelayedCallback = AceOO.Interface { Callback = "function" }

local DELAY_TIME = 0.06
local DELAY_TIME_INCREMENTAL = 0.01

local Delayed = AceOO.Class(IDelayedCallback)
Delayed.virtual = true
Delayed.prototype.postCombat = false -- Set to true to trigger call after combat
Delayed.prototype.timerList = timerList
Delayed.prototype.timerListIndex = 0
Delayed.prototype.timerInfo = 0
Delayed.prototype.name = "No Name"

function Delayed.prototype:init(timerListIndex)
	Delayed.super.prototype.init(self)
	self.timerListIndex = timerListIndex
	self.timerInfo = timerList[timerListIndex]
	self.name = timerList[timerListIndex].name
--	print("Delayed.prototype:init " .. tostring(self.name))
end

function Delayed.prototype:Callback()
	self.timerInfo.timer = nil
end

-- Start the timer if appropriate
function Delayed.prototype:Start(arg1, customDelay)
	AutoBar:LogEvent("--> DELAYED ", self.name)

	-- If in combat delay call till after combat
	if (InCombatLockdown()) then
		self.timerInfo.runPostCombat = true
		return
	end

	local currentTime = GetTime()
	local function MyCallback()
		local myself = self
		local arg1 = arg1
--print("***MyCallback "..myself.name.." at  " .. tostring(GetTime()).." arg1  " .. tostring(arg1))
		myself:Callback(arg1)
	end

--print("***Delayed.prototype:Start "..self.name.." here ");
	if (self.timerInfo.timer) then
--print("***Delayed.prototype:Start "..self.name.." extend timer at " .. currentTime);
		-- Timer not expired, extend it
		if (currentTime - self.timerInfo.timer > DELAY_TIME - DELAY_TIME_INCREMENTAL) then
			-- Almost or already exceeding DELAY_TIME, so use a small incremental delay
			AutoBar:CancelScheduledEvent(self.name)
			AutoBar:ScheduleEvent(self.name, MyCallback, DELAY_TIME_INCREMENTAL)
		else
			-- Still more than DELAY_TIME_INCREMENTAL before the original timer so do not change it
		end
	else
		-- Cancel if higher level timer already in progress
		for i, timerInfo in ipairs(self.timerList) do
			if (i < self.timerListIndex and timerInfo.timer) then
--print("***Delayed.prototype:Start cancel "..self.name.." because " .. timerInfo.name)
				return
			elseif (i == self.timerListIndex) then
				break
			end
		end

		-- Start new Timer
		self.timerInfo.timer = currentTime;
		AutoBar:ScheduleEvent(self.name, MyCallback, customDelay or DELAY_TIME)
--print("***Delayed.prototype:Start start "..self.name.." delay at " .. currentTime)

		-- Cancel Superceded timers
		for i, timerInfo in ipairs(self.timerList) do
			if (i > self.timerListIndex and timerInfo.timer) then
				AutoBar:CancelScheduledEvent(timerInfo.name)
				timerInfo.timer = nil
			end
		end
	end
--print("***Delayed.prototype:Start "..self.name.." end ");
end


function AutoBar.events:PLAYER_ENTERING_WORLD()
	AutoBar.inCombat = nil
	local scanned = false;
	if (not AutoBar.initialized) then
--print("   PLAYER_ENTERING_WORLD")
		AutoBar.delay["UpdateCategories"]:Start()
		scanned = true;
		AutoBar.initialized = true;
	end

	if (not AutoBar.inWorld) then
		AutoBar.inWorld = true;
--print("   PLAYER_ENTERING_WORLD")
		AutoBar.delay["UpdateCategories"]:Start()
	end
end


function AutoBar.events:PLAYER_LEAVING_WORLD()
	AutoBar.inWorld = false;
end


function AutoBar.events:BAG_UPDATE(arg1)
	AutoBar:LogEvent("BAG_UPDATE", arg1)
	if (AutoBar.inWorld and arg1 <= NUM_BAG_FRAMES) then
		AutoBarSearch.dirtyBags[arg1] = true
		if (InCombatLockdown()) then
			for buttonName, button in pairs(AutoBar.buttonList) do
				button:UpdateCount()
			end
		else
			AutoBar.delay["UpdateScan"]:Start()
		end
	end
end


function AutoBar.events:BAG_UPDATE_COOLDOWN(arg1)
	AutoBar:LogEvent("BAG_UPDATE_COOLDOWN", arg1)
--print("   BAG_UPDATE_COOLDOWN arg1 " .. tostring(arg1))
	if (not InCombatLockdown()) then
		AutoBar.delay["UpdateScan"]:Start(arg1)
	end
	for buttonName, button in pairs(AutoBar.buttonList) do
		button:UpdateCooldown()
	end
end


function AutoBar.events:SPELL_UPDATE_COOLDOWN(arg1)
	AutoBar:LogEvent("SPELL_UPDATE_COOLDOWN", arg1)
--print("   SPELL_UPDATE_COOLDOWN arg1 " .. tostring(arg1))
	for buttonName, button in pairs(AutoBar.buttonList) do
		button:UpdateCooldown()
	end
end


function AutoBar.events:ACTIONBAR_UPDATE_USABLE(arg1)
	AutoBar:LogEvent("ACTIONBAR_UPDATE_USABLE", arg1)
	if (AutoBar.inWorld) then
		if (InCombatLockdown()) then
			for buttonName, button in pairs(AutoBar.buttonList) do
				button:UpdateUsable()
			end
			pendingScan = true
		else
			AutoBar.delay["UpdateScan"]:Start(arg1)
		end
	end
end


function AutoBar.events:UPDATE_SHAPESHIFT_FORMS(arg1)
	AutoBar:LogEvent("UPDATE_SHAPESHIFT_FORMS", arg1)
	if (AutoBar.inWorld) then
		if (InCombatLockdown()) then
			for buttonName, button in pairs(AutoBar.buttonList) do
				button:UpdateUsable()
			end
			pendingScan = true
		else
			AutoBar.delay["UpdateScan"]:Start(arg1)
		end
	end
end


-- companionType = nil - Update the current companion
-- companionType = "CRITTER" or "MOUNT" indicates that the active companion of that type has changed.
function AutoBar.events:COMPANION_UPDATE(companionType)
	AutoBar:LogEventStart("COMPANION_UPDATE", companionType)
	if (AutoBar.inWorld) then
		local button = AutoBar.buttonList["AutoBarButtonMount"]
		local thisIsSpam = true
		if (button and companionType ~= "CRITTER") then
			thisIsSpam = button:Refresh(button.parentBar, button.buttonDB, companionType == "MOUNT")
		end
		button = AutoBar.buttonList["AutoBarButtonPets"]
		if (button and companionType ~= "MOUNT") then
			button:Refresh(button.parentBar, button.buttonDB)
		end
		if (not thisIsSpam) then
			AutoBar.delay["UpdateCategories"]:Start()
			if (InCombatLockdown()) then
				pendingScan = true
			end
		end
	end
	AutoBar:LogEventEnd("COMPANION_UPDATE", companionType)
end


function AutoBar.events:COMPANION_LEARNED()
	AutoBar:LogEventStart("COMPANION_LEARNED", companionType)
	if (AutoBar.inWorld) then
		local button = AutoBar.buttonList["AutoBarButtonMount"]
		if (button) then
			button:Learned(button.parentBar, button.buttonDB, companionType == "MOUNT")
		end
		button = AutoBar.buttonList["AutoBarButtonPets"]
		if (button) then
			button:Refresh(button.parentBar, button.buttonDB)
		end
		AutoBar.delay["UpdateCategories"]:Start()
		if (InCombatLockdown()) then
			pendingScan = true
		end
	end
	AutoBar:LogEventEnd("COMPANION_LEARNED", companionType)
end


function AutoBar.events:UPDATE_BINDINGS()
	if (not InCombatLockdown()) then
		self:RegisterOverrideBindings()
		AutoBar.delay["UpdateButtons"]:Start()
	end
end


function AutoBar.events:LEARNED_SPELL_IN_TAB(arg1)
	AutoBar:LogEvent("LEARNED_SPELL_IN_TAB", arg1)
	AutoBar.delay["UpdateSpells"]:Start(arg1)
end


function AutoBar.events:SPELLS_CHANGED(arg1)
	AutoBar:LogEvent("SPELLS_CHANGED", arg1)
	if (InCombatLockdown()) then
		AutoBar:SetRegenEnableUpdate("UpdateSpells")
	else
		AutoBar.delay["UpdateSpells"]:Start(arg1)
	end
end

local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
local zoneDalaran = BZ["Dalaran"]
local zoneKrasusLanding = BZ["Krasus' Landing"]
local zoneWintergrasp = BZ["Wintergrasp"]

function AutoBar:UpdateZone(event)
--[[
	print(tostring(event) .. " GetZoneText()" .. GetZoneText())
	print(tostring(event) .. " GetRealZoneText()" .. GetRealZoneText())
	print(tostring(event) .. " GetSubZoneText()" .. GetSubZoneText())
	print(tostring(event) .. " GetMinimapZoneText()" .. GetMinimapZoneText())
	print(tostring(event) .. " GetMinimapZoneText()" .. GetMinimapZoneText())
--]]
	local newZone = AutoBarSearch.subZoneGroup[GetSubZoneText()]
	local zone = GetRealZoneText()
	if (not newZone) then
		if (zone and zone ~= "") then
			newZone = AutoBarSearch.subZoneGroup[zone]
		end
	end
	if (newZone and newZone ~= AutoBar.currentZone) then
--print("AutoBar:UpdateZone ", AutoBar.currentZone, "-->", newZone)
		AutoBar.currentZone = newZone
	end

	local flyable = IsFlyableArea()
	if (zone == zoneWintergrasp or (zone == zoneDalaran and GetSubZoneText() ~= zoneKrasusLanding)) then
--print("zoneWintergrasp or zoneDalaran. no fly for u!", newZone, flyable)
		flyable = nil
	else
--print("whatever", newZone, flyable)
	end
	if (AutoBar.flyable ~= flyable) then
		AutoBar.flyable = flyable
		if (AutoBar.buttonList["AutoBarButtonMount"]) then
--print("AutoBar:UpdateZone AutoBar.flyable", AutoBar.flyable, "-->", flyable)
			AutoBar.delay["UpdateScan"]:Start(nil)
		end
	end

end

function AutoBar.events:MINIMAP_ZONE_CHANGED(arg1)
	AutoBar:LogEvent("MINIMAP_ZONE_CHANGED", arg1)
	AutoBar:UpdateZone("MINIMAP_ZONE_CHANGED")
	if (not InCombatLockdown()) then
--		AutoBar.delay["UpdateActive"]:Start()
	end
end

function AutoBar.events:ZONE_CHANGED(arg1)
	AutoBar:LogEvent("ZONE_CHANGED", arg1)
	AutoBar:UpdateZone("ZONE_CHANGED")
	if (not InCombatLockdown()) then
--		AutoBar.delay["UpdateActive"]:Start()
	end
end
-- GetSubZoneText();

function AutoBar.events:ZONE_CHANGED_INDOORS(arg1)
	AutoBar:LogEvent("ZONE_CHANGED_INDOORS", arg1)
	AutoBar:UpdateZone("ZONE_CHANGED_INDOORS")
	if (not InCombatLockdown()) then
--		AutoBar.delay["UpdateActive"]:Start()
	end
end


function AutoBar.events:ZONE_CHANGED_NEW_AREA(arg1)
	AutoBar:LogEvent("ZONE_CHANGED_NEW_AREA", arg1)
	AutoBar:UpdateZone("ZONE_CHANGED_NEW_AREA")
	if (not InCombatLockdown()) then
		AutoBarSearch.sorted:DirtyButtons()
		AutoBar.delay["UpdateActive"]:Start(nil, 3)
	end
end


function AutoBar.events:PLAYER_CONTROL_GAINED()
	AutoBar:LogEvent("PLAYER_CONTROL_GAINED", arg1)
	if (not InCombatLockdown()) then
		AutoBar.delay["UpdateButtons"]:Start()
	end
end

local regenEnableUpdate = "UpdateRescan"
function AutoBar:SetRegenEnableUpdate(scanType)
	if (timerIndexList[scanType] < timerIndexList[regenEnableUpdate]) then
		regenEnableUpdate = scanType
	end
end


function AutoBar.events:PLAYER_REGEN_ENABLED(arg1)
	AutoBar:LogEvent("PLAYER_REGEN_ENABLED", arg1)
	AutoBar.inCombat = nil
	AutoBar.delay[regenEnableUpdate]:Start()
--print("PLAYER_REGEN_ENABLED " .. tostring(self))
end


function AutoBar.events:PLAYER_REGEN_DISABLED(arg1)
	AutoBar:LogEvent("PLAYER_REGEN_DISABLED", arg1)
	AutoBar.inCombat = true
if (InCombatLockdown()) then
	print("PLAYER_REGEN_DISABLED called while InCombatLockdown")
--else
--print("PLAYER_REGEN_DISABLED " .. tostring(self))
end

	if (AutoBar.moveButtonsMode) then
		AutoBar:MoveButtonsModeOff()
		LibKeyBound:Deactivate()
	end
	if (AutoBar.keyBoundMode) then
		LibKeyBound:Deactivate()
	end
--print("   PLAYER_REGEN_DISABLED")
	if (self:IsEventScheduled("UpdateRescan")) then
		self:CancelScheduledEvent("UpdateRescan")
		AutoBarSearch.stuff:Reset()
	elseif (self:IsEventScheduled("UpdateScan")) then
		self:CancelScheduledEvent("UpdateScan")
		AutoBarSearch.stuff:Scan()
	elseif (self:IsEventScheduled("UpdateActive")) then
		self:CancelScheduledEvent("UpdateActive")
	elseif (self:IsEventScheduled("UpdateButtons")) then
		self:CancelScheduledEvent("UpdateButtons")
	end
	AutoBar:UpdateActive()
	AceCfgDlg:Close(appName)
	AutoBar:SetRegenEnableUpdate("UpdateRescan")
end


--function AutoBar:UNIT_MANA()
--	if (arg1 == "player") then
--		AutoBar:LogEvent("UNIT_MANA", arg1)
--		if (not InCombatLockdown()) then
--			AutoBar.delay["UpdateButtons"]:Start()
--		end
--	end
--end
--
--
--function AutoBar:UNIT_HEALTH()
--	if (arg1 == "player") then
--		AutoBar:LogEvent("UNIT_HEALTH", arg1)
--		if (not InCombatLockdown()) then
--			AutoBar.delay["UpdateButtons"]:Start()
--		end
--	end
--end


function AutoBar.events:PLAYER_ALIVE(arg1)
	if (not InCombatLockdown()) then
		AutoBar:LogEvent("PLAYER_ALIVE", arg1)
		AutoBar.delay["UpdateButtons"]:Start()
	end
end


function AutoBar.events:PLAYER_AURAS_CHANGED(arg1)
	if (InCombatLockdown()) then
		for buttonName, button in pairs(AutoBar.buttonList) do
			button:UpdateUsable()
		end
	else
		AutoBar:LogEvent("PLAYER_AURAS_CHANGED", arg1)
		AutoBar.delay["UpdateButtons"]:Start()
	end
end


function AutoBar.events:PLAYER_UNGHOST(arg1)
	if (not InCombatLockdown()) then
		AutoBar:LogEvent("PLAYER_UNGHOST", arg1)
		AutoBar.delay["UpdateButtons"]:Start()
	end
end


function AutoBar.events:UPDATE_BATTLEFIELD_STATUS()
	if (AutoBar.inWorld) then
		local bgStatus = false
		for i = 1, MAX_BATTLEFIELD_QUEUES do
			local status, mapName, instanceID = GetBattlefieldStatus(i);
			if (instanceID ~= 0) then
				bgStatus = true
				break
			end
		end
		if (AutoBar.inBG ~= bgStatus) then
			AutoBar.inBG = bgStatus
			AutoBar.delay["UpdateActive"]:Start()
		end
	end
end


-- When dragging, contains { frameName, index }, otherwise nil
AutoBar.dragging = nil;
local draggingData = {};

function AutoBar.GetDraggingIndex(frameName)
	if (AutoBar.dragging and AutoBar.dragging.frameName == frameName) then
		return AutoBar.dragging.index;
	end
	return nil;
end


function AutoBar.SetDraggingIndex(frameName, index)
	draggingData.frameName = frameName;
	draggingData.index = index;
	AutoBar.dragging = draggingData;
end


function AutoBar.LinkDecode(link)
	if (link) then
		local _, _, id, _, _, _, name = string.find(link, "item:(%d+):(%d+):(%d+):(%d+).+%[(.+)%]")
		if (id and name) then
			return name, tonumber(id)
		end
	end
end



-- Initialize
--		All Initialization
-- UpdateCategories
--		Based on the current db, add or remove Custom Categories
-- UpdateCustomBars
--		Based on the current db, add or remove Custom Bars
-- UpdateCustomButtons
--		Based on the current db, add or remove Custom Buttons
-- UpdateSpells
--		Rescan all registerred spells
--		This is on a less frequent cycle than UpdateScan.  Called on leveling or spellbook changes.
--		ToDo: Also trigger on spec changes
-- UpdateObjects
--		Based on the current db, instantiate or refresh Bars, Buttons
--		Move disabled Bars, Buttons to cold storage, & thaw out re-enabled ones
--		This is done on Initialize and on Configuration changes
--		Could be triggered by events (Boss specific categories for instance)
-- UpdateRescan
--		Rescan all bags and inventory from scratch based on current Buttons and their Categories
-- UpdateScan
--		Scan all bags and inventory based on current Buttons and their Categories
--		Triggered by bag & inventory changes, combat end
-- UpdateAttributes
--		Based on the current Scan results, update the Button and Popup Attributes
--		Create Popup Buttons as needed
-- UpdateActive
--		Based on the current Scan results, Bars and their Buttons, determine the active Buttons
-- UpdateButtons
--		Based on the active Bars and their Buttons display them
--		Triggered by events

-- ToDo: Mmm Styles callback should be pulled out of the hierarchy



function AutoBar:Initialize()
--print("AutoBar:Initialize")
	self:LogEventStart("AutoBar:Initialize")

	-- Set AutoBar Skin
	if (LBF and not AutoBar.LBFGroup) then
		local group = LBF:Group("AutoBar")
		AutoBar.LBFGroup = group
		group.SkinID = AutoBar.db.account.SkinID or "Blizzard"
		group.Gloss = AutoBar.db.account.Gloss
		group.Backdrop = AutoBar.db.account.Backdrop
		group.Colors = AutoBar.db.account.Colors or {}
	end

	AutoBarCategory:Initialize()
	AutoBarCategory:Initialize2()
	AutoBarCategory:UpdateCustomCategories()
	AutoBarSearch:Initialize()
	self:LogEventEnd("AutoBar:Initialize")
AutoBarSearch:Test()
end

-- Complete reload of everything.  Dump most old data structures.
local DelayedInitialize = AceOO.Class(Delayed)

function DelayedInitialize.prototype:init(timerListIndex)
	DelayedInitialize.super.prototype.init(self, timerListIndex)
end

function DelayedInitialize.prototype:Callback()
--print("   DelayedInitialize.prototype:Callback  self " .. tostring(self))
	DelayedInitialize.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedInitialize <--")
	AutoBar:Initialize()
	AutoBar:UpdateCategories()
end



local otherStickyFrames = {
	"GridLayoutFrame",
}

-- Based on the current db, add or remove Custom Categories
-- ToDo: support scheme for mutable categories like pet food.
function AutoBar:UpdateCategories()
	if (otherStickyFrames) then
		local delete = true
		for index, stickyFrame in pairs(otherStickyFrames) do
			if (_G[stickyFrame]) then
--print("AutoBar:OnEnable " .. tostring(index) .. "  " .. tostring(stickyFrame))
				LibStickyFrames:RegisterFrame(_G[stickyFrame])
			else
				delete = false
			end
		end
		if (delete) then
			otherStickyFrames = nil
		end
	end

	if (not InCombatLockdown()) then
		self:LogEventStart("AutoBar:UpdateCategories")
		AutoBarCategory:UpdateCustomCategories()
		self:LogEventEnd("AutoBar:UpdateCategories")
		self:UpdateCustomBars()
	else
		self:LogEvent("AutoBar:UpdateCategories InCombatLockdown")
	end
end

local DelayedUpdateCategories = AceOO.Class(Delayed)

function DelayedUpdateCategories.prototype:init()
	DelayedUpdateCategories.super.prototype.init(self, timerIndexList["UpdateCategories"])
end

function DelayedUpdateCategories.prototype:Callback()
	DelayedUpdateCategories.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateCategories <--")
	if (not InCombatLockdown()) then
		AutoBar:UpdateCategories()
	end
end



-- Based on the current db, add Custom Bars that match player CLASS
-- Update shared state
function AutoBar:UpdateCustomBars()
	self:LogEventStart("AutoBar:UpdateCustomBars")

	self:LogEventEnd("AutoBar:UpdateCustomBars")
	self:UpdateCustomButtons()
end

local DelayedUpdateCustomBars = AceOO.Class(Delayed)

function DelayedUpdateCustomBars.prototype:init()
	DelayedUpdateCustomBars.super.prototype.init(self, timerIndexList["UpdateCustomBars"])
end

function DelayedUpdateCustomBars.prototype:Callback()
	DelayedUpdateCustomBars.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateCustomBars <--")
	AutoBar:UpdateCustomBars()
end



-- Based on the current db, add Custom Buttons used by existing Bars
function AutoBar:UpdateCustomButtons()
	self:LogEventStart("AutoBar:UpdateCustomButtons")

	self:LogEventEnd("AutoBar:UpdateCustomButtons")
	self:UpdateSpells()
end

local DelayedUpdateCustomButtons = AceOO.Class(Delayed)

function DelayedUpdateCustomButtons.prototype:init()
	DelayedUpdateCustomButtons.super.prototype.init(self, timerIndexList["UpdateCustomButtons"])
end

function DelayedUpdateCustomButtons.prototype:Callback()
	DelayedUpdateCustomButtons.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateCustomButtons <--")
	AutoBar:UpdateCustomButtons()
end



-- Rescan all registerred spells
function AutoBar:UpdateSpells()
	self:LogEventStart("AutoBar:UpdateSpells")
	AutoBarSearch.stuff:ScanSpells()
	AutoBarSearch.stuff:ScanMacros()
	AutoBarCategory:UpdateCategories()
--	AutoBar:RefreshButtons()
	self:LogEventEnd("AutoBar:UpdateSpells")
	-- ToDo: update on learn.
	self:UpdateObjects()
end

local DelayedUpdateSpells = AceOO.Class(Delayed)

function DelayedUpdateSpells.prototype:init()
	DelayedUpdateSpells.super.prototype.init(self, timerIndexList["UpdateSpells"])
end

function DelayedUpdateSpells.prototype:Callback()
	DelayedUpdateSpells.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateSpells <--")
	AutoBar:UpdateSpells()
end


-- Based on the current db, instantiate or refresh Bars, Buttons, Popups
function AutoBar:UpdateObjects()
	self:LogEventStart("AutoBar:UpdateObjects")
	local barLayoutDBList = AutoBar.barLayoutDBList
	local bar
	for barKey, barDB in pairs(barLayoutDBList) do
		if (barDB.enabled and barDB[AutoBar.CLASS]) then
--print("UpdateObjects barKey " .. tostring(barKey) .. " AutoBar.CLASS " .. tostring(AutoBar.CLASS) .. " barDB[AutoBar.CLASS] " .. tostring(barDB[AutoBar.CLASS]))
			if (AutoBar.barList[barKey]) then
				AutoBar.barList[barKey]:UpdateObjects()
			else
				AutoBar.barList[barKey] = AutoBar.Class.Bar:new(barKey)
--print("UpdateObjects barKey " .. tostring(barKey) .. " Name " .. tostring(AutoBar.barList[barKey].barName))
			end
			bar = AutoBar.barList[barKey]
			LibStickyFrames:SetFrameEnabled(bar.frame, true)
			LibStickyFrames:SetFrameHidden(bar.frame, bar.sharedLayoutDB.hide)
			LibStickyFrames:SetFrameText(bar.frame, bar.barName)
		elseif (AutoBar.barList[barKey]) then
--print("UpdateObjects barKey " .. tostring(barKey) .. " Hide " .. tostring(AutoBar.barList[barKey].barName))
			bar = AutoBar.barList[barKey]
			bar.frame:Hide()
			LibStickyFrames:SetFrameEnabled(bar.frame)
			LibStickyFrames:SetFrameText(bar.frame, bar.barName)
		end
	end
	self:LogEventEnd("AutoBar:UpdateObjects")
	self:UpdateRescan()
end
-- /script AutoBar.barList["AutoBarClassBarExtras"].frame:Hide()
-- /dump AutoBar.barList["AutoBarClassBarHunter"].buttonList

local DelayedUpdateObjects = AceOO.Class(Delayed)

function DelayedUpdateObjects.prototype:init()
	DelayedUpdateObjects.super.prototype.init(self, timerIndexList["UpdateObjects"])
end

function DelayedUpdateObjects.prototype:Callback()
	DelayedUpdateObjects.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateObjects <--")
	AutoBar:UpdateObjects()
end



-- Rescan all bags and inventory from scratch based on current Buttons and their Categories
function AutoBar:UpdateRescan()
	self:LogEventStart("AutoBar:UpdateRescan")
	AutoBarSearch:Reset()
	self:LogEventEnd("AutoBar:UpdateRescan")
	self:UpdateAttributes()
end

local DelayedUpdateRescan = AceOO.Class(Delayed)

function DelayedUpdateRescan.prototype:init()
	DelayedUpdateRescan.super.prototype.init(self, timerIndexList["UpdateRescan"])
end

function DelayedUpdateRescan.prototype:Callback()
	DelayedUpdateRescan.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateRescan <--")
	AutoBar:UpdateRescan()
end



-- Scan all bags and inventory based on current Buttons and their Categories
function AutoBar:UpdateScan()
	self:LogEventStart("AutoBar:UpdateScan")
	AutoBarSearch:UpdateScan()
	self:LogEventEnd("AutoBar:UpdateScan")
	self:UpdateAttributes()
end

local DelayedUpdateScan = AceOO.Class(Delayed)

function DelayedUpdateScan.prototype:init()
	DelayedUpdateScan.super.prototype.init(self, timerIndexList["UpdateScan"])
end

function DelayedUpdateScan.prototype:Callback()
	DelayedUpdateScan.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateScan <--")
	AutoBar:UpdateScan()
end



-- Based on the current Scan results, update the Button and Popup Attributes
-- Create Popup Buttons as needed
function AutoBar:UpdateAttributes()
	self:LogEventStart("AutoBar:UpdateAttributes")
	for barKey, bar in pairs(AutoBar.barList) do
		bar:UpdateAttributes()
	end
	self:LogEventEnd("AutoBar:UpdateAttributes")
	self:UpdateActive()
end

local DelayedUpdateAttributes = AceOO.Class(Delayed)

function DelayedUpdateAttributes.prototype:init()
	DelayedUpdateAttributes.super.prototype.init(self, timerIndexList["UpdateAttributes"])
end

function DelayedUpdateAttributes.prototype:Callback()
	DelayedUpdateAttributes.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateAttributes <--")
	AutoBar:UpdateAttributes()
end



-- Based on the current Scan results, Bars and their Buttons, determine the active Buttons
function AutoBar:UpdateActive()
	self:LogEventStart("AutoBar:UpdateActive")
	for barKey, bar in pairs(AutoBar.barList) do
		bar:UpdateActive()
		bar:RefreshLayout()
	end
	self:LogEventEnd("AutoBar:UpdateActive")
	self:UpdateButtons()
end

local DelayedUpdateActive = AceOO.Class(Delayed)

function DelayedUpdateActive.prototype:init()
	DelayedUpdateActive.super.prototype.init(self, timerIndexList["UpdateActive"])
end

function DelayedUpdateActive.prototype:Callback()
	DelayedUpdateActive.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateActive <--")
	AutoBar:UpdateActive()
end



-- Based on the active Bars and their Buttons display them
function AutoBar:UpdateButtons()
	self:LogEventStart("AutoBar:UpdateButtons")
	for buttonName, button in pairs(self.buttonListDisabled) do
--print("   AutoBar:UpdateButtons Disabled " .. buttonName);
		button:Disable()
		button:UpdateCooldown()
		button:UpdateCount()
		button:UpdateHotkeys()
		button:UpdateIcon()
		button:UpdateUsable()
	end
	for buttonKey, button in pairs(self.buttonList) do
--print("   AutoBar:UpdateButtons Enabled " .. buttonName);
		assert(button.buttonDB.enabled, "In list but disabled " .. buttonKey)
		button:SetupButton()
		button:UpdateCooldown()
		button:UpdateCount()
		button:UpdateHotkeys()
		button:UpdateIcon()
		button:UpdateUsable()
	end
	self:LogEventEnd("AutoBar:UpdateButtons #buttons " .. tostring(# self.buttonList))
	if (self.enableBindings) then
		self:RegisterOverrideBindings()
		AutoBar.frame:RegisterEvent("UPDATE_BINDINGS")
		self.enableBindings = nil
--print("<-- enableBindings")
	end
end

local DelayedUpdateButtons = AceOO.Class(Delayed)

function DelayedUpdateButtons.prototype:init()
	DelayedUpdateButtons.super.prototype.init(self, timerIndexList["UpdateButtons"])
end

function DelayedUpdateButtons.prototype:Callback()
	DelayedUpdateButtons.super.prototype.Callback(self)
	AutoBar:LogEvent("DelayedUpdateButtons <--")
	AutoBar:UpdateButtons()
end


AutoBar.delayInitialize = DelayedInitialize:new(timerIndexList["AutoBarInit"])
AutoBar.delay["UpdateCategories"] = DelayedUpdateCategories:new()
AutoBar.delay["UpdateCustomBars"] = DelayedUpdateCustomBars:new()
AutoBar.delay["UpdateCustomButtons"] = DelayedUpdateCustomButtons:new()
AutoBar.delay["UpdateSpells"] = DelayedUpdateSpells:new()
AutoBar.delay["UpdateObjects"] = DelayedUpdateObjects:new()
AutoBar.delay["UpdateRescan"] = DelayedUpdateRescan:new()
AutoBar.delay["UpdateScan"] = DelayedUpdateScan:new()
AutoBar.delay["UpdateActive"] = DelayedUpdateActive:new()
AutoBar.delay["UpdateButtons"] = DelayedUpdateButtons:new()


--
-- Bar & Button drag locking / unlocking and key binding modes
--

function AutoBar:ColorAutoBar()
	for i, bar in pairs(AutoBar.barList) do
		if (bar.sharedLayoutDB.enabled) then
			bar:ColorBars()
		end
	end
	if (AutoBarFuBar) then
		AutoBarFuBar:UpdateDisplay()
	end
end

function AutoBar:LIBKEYBOUND_ENABLED()
	AutoBar:MoveBarModeOff()
	AutoBar:MoveButtonsModeOff()
	AutoBar.keyBoundMode = true
	AutoBar:ColorAutoBar()
end

function AutoBar:LIBKEYBOUND_DISABLED()
	AutoBar.keyBoundMode = nil
	AutoBar:ColorAutoBar()
end

function AutoBar:LIBKEYBOUND_MODE_COLOR_CHANGED()
	AutoBar:ColorAutoBar()
end

function AutoBar:MoveBarModeToggle()
--print("AutoBar:MoveBarModeToggle")
	if (LibStickyFrames:GetGroup()) then
		AutoBar:MoveBarModeOff()
	else
		AutoBar:MoveBarModeOn()
	end
end

function AutoBar:MoveBarModeOff()
	LibStickyFrames:SetGroup(nil)
	AutoBar.stickyMode = false
end

function AutoBar:MoveBarModeOn()
	LibKeyBound:Deactivate()
	AutoBar:MoveButtonsModeOff()
	LibStickyFrames:SetGroup(true)
	AutoBar.stickyMode = true
end

function AutoBar.OnSetGroup(group)
--print("AutoBar.SetStickyMode stickyMode " .. tostring(stickyMode))
	AutoBar.stickyMode = false
	if (group == true) then
		AutoBar.stickyMode = true
	elseif (type(group) == "table") then
		for i, bar in pairs(AutoBar.barList) do
			if (bar.sharedLayoutDB.enabled and LibStickyFrames:InFrameGroup(bar.frame, group)) then
				AutoBar.stickyMode = true
				break
			end
		end
	end
	if (AutoBarFuBar) then
		AutoBarFuBar:UpdateDisplay()
	end
end

function AutoBar:OnClick(event, frame, button)
--print("AutoBar.Class.Bar.OnClick frame " .. tostring(frame) .. " button " .. tostring(button) .. " lolwut " .. tostring(lolwut))
	local bar = frame.class
	if (bar and bar.sharedLayoutDB) then
		if (button == "RightButton") then
	--print("AutoBar.Class.Bar.OnClick ShowBarOptions frame " .. tostring(frame) .. " button " .. tostring(button))
			bar:ShowBarOptions()
		elseif (button == "LeftButton") then
	--print("AutoBar.Class.Bar.OnClick ToggleVisibilty frame " .. tostring(frame) .. " button " .. tostring(button))
			bar:ToggleVisibilty()
		end
	end
end

--[[
function AutoBar:OnStartFrameMoving()
--print("AutoBar.OnStartFrameMoving")
end

--]]
function AutoBar:OnStopFrameMoving(event, frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
	local bar = frame.class
	if (bar and bar.sharedPositionDB) then
--print("AutoBar:OnStopFrameMoving " .. tostring(bar.barName) .. " frame " .. tostring(frame) .. " point " .. tostring(point) .. " stickToFrame " .. tostring(stickToFrame) .. " stickToPoint " .. tostring(stickToPoint))
		bar:StickTo(frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
		bar:PositionSave()
	end
end

function AutoBar:OnStickToFrame(event, frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
	local bar = frame.class
--print("AutoBar:OnStickToFrame " .. tostring(bar.barName) .. " frame " .. tostring(frame) .. " point " .. tostring(point) .. " stickToFrame " .. tostring(stickToFrame) .. " stickToPoint " .. tostring(stickToPoint))
	if (bar and bar.sharedPositionDB) then
		bar:StickTo(frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
		bar:PositionSave()
	end
end


function AutoBar:MoveButtonsModeToggle()
	if AutoBar.moveButtonsMode then
		AutoBar:MoveButtonsModeOff()
	else
		AutoBar:MoveButtonsModeOn()
	end
end

function AutoBar:MoveButtonsModeOn()
	AutoBar:MoveBarModeOff()
	LibKeyBound:Deactivate()
	AutoBar.moveButtonsMode = true
	for i, bar in pairs(self.barList) do
		if (bar.sharedLayoutDB.enabled) then
			bar:MoveButtonsModeOn()
		end
	end
	self:UpdateActive()
	if (AutoBarFuBar) then
		AutoBarFuBar:UpdateDisplay()
	end
end

function AutoBar:MoveButtonsModeOff()
	AutoBar.moveButtonsMode = nil
	for i, bar in pairs(self.barList) do
		if bar.sharedLayoutDB.enabled then
			bar:MoveButtonsModeOff()
		end
	end
	self:UpdateActive()
	if (AutoBarFuBar) then
		AutoBarFuBar:UpdateDisplay()
	end
end

function AutoBar:SkinModeToggle()
	local ace3 = LibStub("AceAddon-3.0")
	local BF = ace3 and ace3:GetAddon("ButtonFacade", true)
	if (BF) then
		AutoBar:MoveBarModeOff()
		AutoBar:MoveButtonsModeOff()
		LibKeyBound:Deactivate()
		if (BF:OpenOptions()) then
--			BF:OpenMenu()
		else
--			BF:CloseMenu()
		end
	else
		print(L["ButtonFacade is required to Skin the Buttons"])
	end
end

 
--
-- ConfigMode support
--

-- Create the global table if it does not exist yet
CONFIGMODE_CALLBACKS = CONFIGMODE_CALLBACKS or {}

-- Declare our handler
CONFIGMODE_CALLBACKS["AutoBar"] = function(action)
	if (action == "ON") then
		AutoBar:MoveBarModeOn()
	elseif (action == "OFF") then
		AutoBar:MoveBarModeOff()
	end
end

 
--
-- Drag and Drop support
--

-- Retrieve last object dragged from
function AutoBar:GetDraggingObject()
	return AutoBar.fromObject
end

-- Record last object dragged from
function AutoBar:SetDraggingObject(fromObject)
	AutoBar.fromObject = fromObject
end


--/dump AutoBar.db.account.barList["AutoBarClassBarBasic"].buttonKeys[16]
--/dump AutoBar.moveButtonsMode
--/script AutoBar.db.account.logEvents = true
--/script AutoBar.db.account.logEvents = nil
--/script LibStub("LibKeyBound-1.0"):SetColorKeyBoundMode(0.75, 1, 0, 0.5)
--/script DEFAULT_CHAT_FRAME:AddMessage("" .. tostring())
--/print GetMouseFocus():GetName()
