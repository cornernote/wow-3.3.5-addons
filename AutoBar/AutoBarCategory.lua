--
-- AutoBarProfile
-- Copyright 2007+ Toadkiller of Proudmoore.
--
-- Categories for AutoBar
-- A Category encapsulates a list of items / spells etc. along with metadata describing their use.
-- http://code.google.com/p/autobar/
--

--	PeriodicGroup
--		description
--		texture
--		targeted
--		nonCombat
--		location
--		battleground
--		notUsable (soul shards, arrows, etc.)
--		flying

--	AutoBar
--		spell
--		limit

local AutoBar = AutoBar
local spellNameList = AutoBar.spellNameList
local spellIconList = AutoBar.spellIconList

local REVISION = tonumber(("$Revision: 797 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end


AutoBarCategoryList = {}

local L = AutoBar.locale
local PT = LibStub("LibPeriodicTable-3.1")
local BZ = LibStub("LibBabble-Zone-3.0"):GetLookupTable()
--local BZ = AceLibrary:GetInstance("Babble-Zone-2.2")
local AceOO = AceLibrary("AceOO-2.0")
local _

-- List of categoryKey, category.description pairs for button categories
AutoBar.categoryValidateList = {}


local function sortList(a, b)
	local x = tonumber(a[2]);
	local y = tonumber(b[2]);

	if (x == y) then
		if (a[3]) then
			return false;
		else
			if (b[3]) then
				return true;
			else
				return false;
			end
		end
	else
		return x < y;
	end
end


local function castListPairs(castList)
	local i = -1

	return function ()
		i = i + 2
		if (castList[i]) then
			return i, castList[i], castList[i + 1]
		end
	end
end


-- Mandatory attributes:
--		description - localized description
--		texture - display icon texture
-- Optional attributes:
--		targeted, nonCombat, location, battleground, notUsable
AutoBarCategory = AceOO.Class()
AutoBarCategory.virtual = true

function AutoBarCategory.prototype:init(description, texture)
	AutoBarCategory.super.prototype.init(self) -- Mandatory init.
	self.categoryKey = description

	self.description = L[description]
	self.texture = texture
end

-- True if items can be targeted
function AutoBarCategory.prototype:SetTargeted(targeted)
	self.targeted = targeted
end

-- True if only usable outside combat
function AutoBarCategory.prototype:SetNonCombat(nonCombat)
	self.nonCombat = nonCombat
end

-- True if item is location specific
function AutoBarCategory.prototype:SetLocation(location)
	self.location = location
end

-- True if item is usable anywhere, including battlegrounds
function AutoBarCategory.prototype:SetAnywhere(anywhere)
	self.anywhere = anywhere
end

-- True if item is for battlegrounds only
function AutoBarCategory.prototype:SetBattleground(battleground)
	self.battleground = battleground
end

-- True if item is not usable (soul shards, arrows, etc.)
function AutoBarCategory.prototype:SetNotUsable(notUsable)
	self.notUsable = notUsable
end

-- True if item is not usable (soul shards, arrows, etc.)
function AutoBarCategory.prototype:SetNoSpellCheck(noSpellCheck)
	self.noSpellCheck = noSpellCheck
end


-- Convert rawList to a simple array of itemIds, ordered by their value in the set, and priority if any
function AutoBarCategory.prototype:RawItemsConvert(rawList)
	local itemArray = {}
	table.sort(rawList, sortList)
	for i, j in ipairs(rawList) do
		itemArray[i] = j[1]
	end
	return itemArray
end


-- Add items from set to rawList
-- If priority is true, the items will have priority over non-priority items with the same values
function AutoBarCategory.prototype:RawItemsAdd(rawList, set, priority)
	if (not rawList) then
		rawList = {}
	end
	if (set) then
		local cacheSet = PT:GetSetTable(set)
		if (cacheSet) then
			local index = # rawList + 1
			for itemId, value in PT:IterateSet(set) do
				if (not value or type(value) == "boolean") then
					value = 0;
				end
				value = tonumber(value)
				rawList[index] = {itemId, value, priority}
				index = index + 1
			end
		else
			print("AutoBar could not find the PT3.1 set ", set, ".  Make sure you have all the libraries AutoBar needs to function.")
		end
	end
	return rawList
end

-- Return nil or list of spells matching player class
-- itemsPerLine defaults to 2 (class type, spell).
-- Only supports 2 & 3 for now.
-- ToDo: generalize for more per line.
function AutoBarCategory:FilterClass(castList, itemsPerLine)
	local spellName, index, filteredList2, filteredList3
	if (not itemsPerLine) then
		itemsPerLine = 2
	end

	-- Filter out CLASS spells from castList
	index = 1
	for i = 1, # castList, itemsPerLine do
		if (AutoBar.CLASS == castList[i] or "*" == castList[i]) then
			spellName = castList[i + 1]
			if (not filteredList2) then
				filteredList2 = {}
			end
			if (itemsPerLine == 3 and not filteredList3) then
				filteredList3 = {}
			end
			filteredList2[index] = spellName
			if (itemsPerLine == 3) then
				spellName = castList[i + 2]
				filteredList3[index] = spellName
			end
			index = index + 1
		end
	end
	return filteredList2, filteredList3
end

-- Convert list of negative numbered spellId to spellName.
function AutoBarCategory:FilterPTSpells(castList)
	local spellName
--print("AutoBarCategory:FilterClass castList " .. tostring(castList))

	-- Filter out CLASS spells from castList
	for i = 1, # castList do
		local spellId = castList[i] * -1
		spellName = GetSpellInfo(spellId)
		castList[i] = spellName
	end
	return castList
end

-- Top castable item from castList will cast on RightClick
function AutoBarCategory.prototype:SetCastList(castList)
--AutoBar:Print("AutoBarCategory.prototype:SetCastList " .. description .. " castList " .. tostring(castList))
	if (castList) then
		self.spells = castList
		local noSpellCheck = self.noSpellCheck
		for index, spellName in ipairs(castList) do
--AutoBar:Print("AutoBarCategory.prototype:SetCastList " .. tostring(spellName))
			AutoBarSearch:RegisterSpell(spellName, noSpellCheck)
			if (AutoBarSearch:CanCastSpell(spellName)) then	-- TODO: update on leveling in case new spell aquired
--AutoBar:Print("AutoBarCategory.prototype:SetCastList castable " .. tostring(spellName))
				self.castSpell = spellName
			end
		end
	else
		self.spells = nil
		self.castSpell = nil
	end
end

-- Reset the item list based on changed settings.
-- So pet change, Spellbook changed for spells, etc.
function AutoBarCategory.prototype:Refresh()
end

-- Add a spell to the list.
-- spellNameRight specifies a separate spell to cast on right click
function AutoBarCategory.prototype:AddSpell(spellNameLeft, spellNameRight, itemsIndex)
	local noSpellCheck = self.noSpellCheck
	if (spellNameLeft) then
		if (not noSpellCheck) then
			spellNameLeft = GetSpellInfo(spellNameLeft)
		end
		if (not self.items) then
			self.items = {}
		end
	end
	if (spellNameRight) then
		if (not noSpellCheck) then
			spellNameRight = GetSpellInfo(spellNameRight)
		end
		if (not self.itemsRightClick) then
			self.itemsRightClick = {}
		end
	end

	if (spellNameLeft) then
		AutoBarSearch:RegisterSpell(spellNameLeft, noSpellCheck)
		self.items[itemsIndex] = spellNameLeft
		if (spellNameRight) then
			AutoBarSearch:RegisterSpell(spellNameRight, noSpellCheck)
			self.itemsRightClick[spellNameLeft] = spellNameRight
--AutoBar:Print("AutoBarCategory.prototype:AddSpell castable spellNameLeft " .. tostring(spellNameLeft) .. " spellNameRight " .. tostring(spellNameRight))
--		else
--			self.itemsRightClick[spellNameLeft] = spellNameLeft
--AutoBar:Print("AutoBarCategory.prototype:AddSpell castable spellNameLeft " .. tostring(spellNameLeft))
		end
		itemsIndex = itemsIndex + 1
	elseif (spellNameRight) then
		AutoBarSearch:RegisterSpell(spellNameRight, noSpellCheck)
		self.items[itemsIndex] = spellNameRight
		self.itemsRightClick[spellNameRight] = spellNameRight
		itemsIndex = itemsIndex + 1
	end
	return itemsIndex
end


-- Category consisting of regular items, defined by PeriodicTable sets
AutoBarItems = AceOO.Class(AutoBarCategory)

-- ptItems, ptPriorityItems are PeriodicTable sets
-- priorityItems sort higher than items at the same value
function AutoBarItems.prototype:init(description, shortTexture, ptItems, ptPriorityItems)
	AutoBarItems.super.prototype.init(self, description, "Interface\\Icons\\" .. shortTexture) -- Mandatory init.
	self.ptItems = ptItems
	self.ptPriorityItems = ptPriorityItems

	local rawList = nil
	rawList = self:RawItemsAdd(rawList, ptItems, false)
	if (ptPriorityItems) then
		rawList = self:RawItemsAdd(rawList, ptPriorityItems, true)
	end
	self.items = self:RawItemsConvert(rawList)
end

-- Reset the item list based on changed settings.
function AutoBarItems.prototype:Refresh()
end


local spellFeedPet = GetSpellInfo(6991)

-- Category consisting of regular items
AutoBarPetFood = AceOO.Class(AutoBarItems)

-- ptItems, ptPriorityItems are PeriodicTable sets
-- priorityItems sort higher than items at the same value
function AutoBarPetFood.prototype:init(description, shortTexture, ptItems, ptPriorityItems)
	AutoBarPetFood.super.prototype.init(self, description, "Interface\\Icons\\" .. shortTexture, ptItems, ptPriorityItems)

	self.castSpell = spellFeedPet
end

-- Reset the item list based on changed settings.
function AutoBarPetFood.prototype:Refresh()
end


-- Category consisting of spells
AutoBarSpells = AceOO.Class(AutoBarCategory)

-- castList, is of the form:
-- { "DRUID", "Flight Form", "DRUID", "Swift Flight Form", ["<class>", "<localized spell name>",] ... }
-- rightClickList, is of the form:
-- { "DRUID", "Mark of the Wild", "Gift of the Wild", ["<class>", "<localized spell name left click>", "<localized spell name right click>",] ... }
-- Pass in only one of castList, rightClickList
-- Icon from castList is used unless not available but rightClickList is
function AutoBarSpells.prototype:init(description, texture, castList, rightClickList, ptItems)
	AutoBarSpells.super.prototype.init(self, description, texture) -- Mandatory init.
	local spellName, index
--AutoBar:Print("AutoBarSpells.prototype:init " .. description .. " castList " .. tostring(castList))

	-- Filter out non CLASS spells from castList and rightClickList
	if (castList) then
		self.castList = AutoBarCategory:FilterClass(castList)
	end
	if (rightClickList) then
		self.castList, self.rightClickList = AutoBarCategory:FilterClass(rightClickList, 3)
	end
	if (pt3List) then
		local rawList = nil
		rawList = self:RawItemsAdd(rawList, ptItems, false)
		self.castList = self:RawItemsConvert(rawList)
		self.castList = AutoBarCategory:FilterPTSpells(self.castList)
	end

	-- Populate items based on currently castable spells
	self.items = {}
	if (self.rightClickList and not self.itemsRightClick) then
		self.itemsRightClick = {}
	end
	self:Refresh()
end

-- Reset the item list based on changed settings.
function AutoBarSpells.prototype:Refresh()
	local itemsIndex = 1
assert(self.items, "AutoBarSpells.prototype:Refresh wtff")
	if (self.castList and self.rightClickList) then
		for spellName in pairs(self.itemsRightClick) do
			self.itemsRightClick[spellName] = nil
		end

		for i = 1, # self.castList, 1 do
			local spellNameLeft, spellNameRight = self.castList[i], self.rightClickList[i]
--AutoBar:Print("AutoBarSpells.prototype:Refresh spellNameLeft " .. tostring(spellNameLeft) .. " spellNameRight " .. tostring(spellNameRight))
			itemsIndex = AutoBarSpells.super.prototype.AddSpell(self, spellNameLeft, spellNameRight, itemsIndex)
		end
		for i = itemsIndex, # self.items, 1 do
			self.items[i] = nil
		end
	elseif (self.castList) then
		for i, spellName in ipairs(self.castList) do
			if (spellName) then
				itemsIndex = AutoBarSpells.super.prototype.AddSpell(self, spellName, nil, itemsIndex)
			end
		end
		for i = itemsIndex, # self.items, 1 do
			self.items[i] = nil
		end
	end
end


-- Custom Category
AutoBarCustom = AceOO.Class(AutoBarCategory)

-- Return a unique key to use
function AutoBarCustom:GetCustomKey(customCategoryName)
	local newKey = "Custom" .. customCategoryName
	return newKey
end

-- Select an Icon to use
-- Add description verbatim to localization
function AutoBarCustom.prototype:init(customCategoriesDB)
	local description = customCategoriesDB.name
	if (not L[description]) then
		L[description] = description
	end

	-- Icon is first item found that is not an invalid spell
	local itemList = customCategoriesDB.items
	local itemType, itemId, itemInfo, spellName, spellClass, texture
	for index = # itemList, 1, -1 do
		local itemDB = itemList[index]
		itemType = itemDB.itemType
		itemId = itemDB.itemId
		itemInfo = itemDB.itemInfo
		spellName = itemDB.spellName
		spellClass = itemDB.spellClass
		texture = itemDB.texture
		if ((not spellClass) or (spellClass == AutoBar.CLASS)) then
			break
		end
	end
	if (itemType == "item") then
		_,_,_,_,_,_,_,_,_, texture = GetItemInfo(tonumber(itemId))
	elseif (itemType == "spell") then
		if (spellName) then
			_, _, texture = GetSpellInfo(spellName)
		end
	elseif (itemType == "macro") then
		if (itemId) then
			_, texture = GetMacroInfo(itemId)
		end
	elseif (itemType == "macroCustom") then
		texture = texture or "Interface\\Icons\\INV_Misc_Gift_05"
	else
		texture = "Interface\\Icons\\INV_Misc_Gift_01"
	end

	AutoBarCustom.super.prototype.init(self, description, texture)
	self.customCategoriesDB = customCategoriesDB

--AutoBar:Print("AutoBarCustom.prototype:init customCategoriesDB " .. tostring(customCategoriesDB) .. " self.customCategoriesDB " .. tostring(self.customCategoriesDB))
	self.customKey = AutoBarCustom:GetCustomKey(description)
--AutoBar:Print("AutoBarCustom.prototype:init description " .. tostring(description) .. " customKey " .. tostring(self.customKey))
	self.items = {}
	self:Refresh()
end

-- If not used yet, change name to newName
-- Return the name in use either way
function AutoBarCustom.prototype:ChangeName(newName)
	local newCategoryKey = AutoBarCustom:GetCustomKey(newName)
	if (not AutoBarCategoryList[newCategoryKey]) then
		local oldCustomKey = self.customKey
		self.customKey = newCategoryKey
--AutoBar:Print("AutoBarCustom.prototype:ChangeName oldCustomKey " .. tostring(oldCustomKey) .. " newCategoryKey " .. tostring(newCategoryKey))
		AutoBarCategoryList[newCategoryKey] = AutoBarCategoryList[oldCustomKey]
		AutoBarCategoryList[oldCustomKey] = nil
		-- Update categoryValidateList
		AutoBar.categoryValidateList[newCategoryKey] = self.description
		AutoBar.categoryValidateList[oldCustomKey] = nil

		self.customCategoriesDB.name = newName
		self.customCategoriesDB.desc = newName
		self.customCategoriesDB.categoryKey = newCategoryKey
		self.description = newName
		self.categoryKey = newCategoryKey

		local customCategories = AutoBar.db.account.customCategories
		customCategories[newCategoryKey] = customCategories[oldCustomKey]
		customCategories[oldCustomKey] = nil
	end
	return self.customCategoriesDB.name
end
-- /dump AutoBarCategoryList["Custom.Custom"]
-- /dump AutoBarCategoryList["Custom.XXX"]


-- Return the unique name to use
function AutoBarCustom:GetNewName(baseName, index)
	local newName = baseName .. index
	local newKey = AutoBarCustom:GetCustomKey(newName)
	local customCategories = AutoBar.db.account.customCategories
	while (customCategories[newKey] or AutoBarCategoryList[newKey]) do
		index = index + 1
		newName = baseName .. index
		newKey = AutoBarCustom:GetCustomKey(newName)
	end
	return newName, newKey
end


-- Reset the item list based on changed settings.
function AutoBarCustom.prototype:Refresh()
	local itemList = self.customCategoriesDB.items
	local itemType, itemId
	local itemsIndex = 1

	local items = self.items

	for index, itemDB in ipairs(itemList) do
		itemType = itemDB.itemType
		itemId = itemDB.itemId
		if (itemType == "item") then
			self.items[itemsIndex] = itemId
			itemsIndex = itemsIndex + 1
		elseif (itemType == "spell" and itemDB.spellName) then
			if (itemDB.spellClass == AutoBar.CLASS) then
				itemsIndex = AutoBarCustom.super.prototype.AddSpell(self, itemDB.spellName, nil, itemsIndex)
			end
		elseif (itemType == "macro") then
--AutoBar:Print("AutoBarCustom.prototype:Refresh --> itemDB.itemInfo " .. tostring(itemDB.itemInfo) .. " itemDB.itemId " .. tostring(itemDB.itemId))
			if (not itemDB.itemInfo) then
				itemDB.itemInfo = GetMacroInfo(itemId)
			end
			if (itemDB.itemInfo) then
				itemDB.itemId = GetMacroIndexByName(itemDB.itemInfo)
				itemId = itemDB.itemId
			end
--AutoBar:Print("AutoBarCustom.prototype:Refresh <-- itemDB.itemInfo " .. tostring(itemDB.itemInfo) .. " itemDB.itemId " .. tostring(itemDB.itemId))
			local macroId = "macro" .. itemId
			self.items[itemsIndex] = macroId
			itemsIndex = itemsIndex + 1
			AutoBarSearch:RegisterMacro(macroId, itemId)
		elseif (itemType == "macroCustom" and itemDB.itemInfo) then
			local macroId = "macroCustom" .. self.customCategoriesDB.categoryKey .. itemId
			self.items[itemsIndex] = macroId
			itemsIndex = itemsIndex + 1
			AutoBarSearch:RegisterMacro(macroId, nil, itemId, itemDB.itemInfo)
		end
	end

	-- Trim excess
	for index = itemsIndex, # self.items, 1 do
		self.items[index] = nil
	end
end
-- /dump AutoBarCategoryList["CustomArrangeTest"]


-- Create category list using PeriodicTable data.
function AutoBarCategory:Initialize()
	AutoBarCategoryList["Misc.Hearth"] = AutoBarItems:new(
			"Misc.Hearth", "INV_Misc_Rune_01", "Misc.Hearth")

	AutoBarCategoryList["Consumable.Buff.Free Action"] = AutoBarItems:new(
			"Consumable.Buff.Free Action", "INV_Potion_04", "Consumable.Buff.Free Action")

	AutoBarCategoryList["Consumable.Anti-Venom"] = AutoBarItems:new(
			"Consumable.Anti-Venom", "INV_Drink_14", "Consumable.Anti-Venom")
	AutoBarCategoryList["Consumable.Anti-Venom"]:SetTargeted(true)

	AutoBarCategoryList["Misc.Battle Standard.Battleground"] = AutoBarItems:new(
			"Misc.Battle Standard.Battleground", "INV_BannerPVP_01", "Misc.Battle Standard.Battleground")
	AutoBarCategoryList["Misc.Battle Standard.Battleground"]:SetBattleground(true)

	AutoBarCategoryList["Misc.Battle Standard.Alterac Valley"] = AutoBarItems:new(
			"Misc.Battle Standard.Alterac Valley", "INV_BannerPVP_02", "Misc.Battle Standard.Alterac Valley")
	AutoBarCategoryList["Misc.Battle Standard.Alterac Valley"]:SetLocation(BZ["Alterac Valley"])

	AutoBarCategoryList["Misc.Reagent.Ammo.Arrow"] = AutoBarItems:new(
			"Misc.Reagent.Ammo.Arrow", "INV_Ammo_Arrow_02", "Misc.Reagent.Ammo.Arrow")
	AutoBarCategoryList["Misc.Reagent.Ammo.Arrow"]:SetNotUsable(true)

	AutoBarCategoryList["Misc.Reagent.Ammo.Bullet"] = AutoBarItems:new(
			"Misc.Reagent.Ammo.Bullet", "INV_Ammo_Bullet_02", "Misc.Reagent.Ammo.Bullet")
	AutoBarCategoryList["Misc.Reagent.Ammo.Bullet"]:SetNotUsable(true)

	AutoBarCategoryList["Misc.Reagent.Ammo.Thrown"] = AutoBarItems:new(
			"Misc.Reagent.Ammo.Thrown", "INV_Axe_19", "Misc.Reagent.Ammo.Thrown")
	AutoBarCategoryList["Misc.Reagent.Ammo.Thrown"]:SetNotUsable(true)

	AutoBarCategoryList["Misc.Explosives"] = AutoBarItems:new(
			"Misc.Explosives", "INV_Misc_Bomb_08", "Misc.Explosives")
	AutoBarCategoryList["Misc.Explosives"]:SetTargeted(true)

	AutoBarCategoryList["Misc.Engineering.Fireworks"] = AutoBarItems:new(
			"Misc.Engineering.Fireworks", "INV_Misc_MissileSmall_Red", "Misc.Engineering.Fireworks")

	AutoBarCategoryList["Tradeskill.Tool.Fishing.Gear"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Gear", "INV_Helmet_31", "Tradeskill.Tool.Fishing.Gear")

	AutoBarCategoryList["Tradeskill.Tool.Fishing.Lure"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Lure", "INV_Misc_Food_26", "Tradeskill.Tool.Fishing.Lure")
	AutoBarCategoryList["Tradeskill.Tool.Fishing.Lure"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Tradeskill.Tool.Fishing.Other"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Other", "INV_Drink_03", "Tradeskill.Tool.Fishing.Other")

	AutoBarCategoryList["Tradeskill.Tool.Fishing.Tool"] = AutoBarItems:new(
			"Tradeskill.Tool.Fishing.Tool", "INV_Fishingpole_01", "Tradeskill.Tool.Fishing.Tool")

	AutoBarCategoryList["Consumable.Cooldown.Stone.Mana.Other"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Mana.Other", "Spell_Shadow_SealOfKings", "Consumable.Cooldown.Stone.Mana.Other")

	AutoBarCategoryList["Consumable.Cooldown.Stone.Health.Other"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Health.Other", "INV_Misc_Food_55", "Consumable.Cooldown.Stone.Health.Other")

	AutoBarCategoryList["Consumable.Bandage.Basic"] = AutoBarItems:new(
			"Consumable.Bandage.Basic", "INV_Misc_Bandage_Netherweave_Heavy", "Consumable.Bandage.Basic")
	AutoBarCategoryList["Consumable.Bandage.Basic"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Bandage.Battleground.Alterac Valley"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Alterac Valley", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Alterac Valley")
	AutoBarCategoryList["Consumable.Bandage.Battleground.Alterac Valley"]:SetTargeted(true)
	AutoBarCategoryList["Consumable.Bandage.Battleground.Alterac Valley"]:SetLocation(BZ["Alterac Valley"])

	AutoBarCategoryList["Consumable.Bandage.Battleground.Arathi Basin"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Arathi Basin", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Arathi Basin")
	AutoBarCategoryList["Consumable.Bandage.Battleground.Arathi Basin"]:SetTargeted(true)
	AutoBarCategoryList["Consumable.Bandage.Battleground.Arathi Basin"]:SetLocation(BZ["Arathi Basin"])

	AutoBarCategoryList["Consumable.Bandage.Battleground.Warsong Gulch"] = AutoBarItems:new(
			"Consumable.Bandage.Battleground.Warsong Gulch", "INV_Misc_Bandage_12", "Consumable.Bandage.Battleground.Warsong Gulch")
	AutoBarCategoryList["Consumable.Bandage.Battleground.Warsong Gulch"]:SetTargeted(true)
	AutoBarCategoryList["Consumable.Bandage.Battleground.Warsong Gulch"]:SetLocation(BZ["Warsong Gulch"])

	AutoBarCategoryList["Consumable.Food.Edible.Basic.Non-Conjured"] = AutoBarItems:new(
			"Consumable.Food.Edible.Basic.Non-Conjured", "INV_Misc_Food_23", "Consumable.Food.Edible.Basic.Non-Conjured")
	AutoBarCategoryList["Consumable.Food.Edible.Basic.Non-Conjured"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"] = AutoBarItems:new(
			"Consumable.Food.Edible.Battleground.Arathi Basin.Basic", "INV_Misc_Food_33", "Consumable.Food.Edible.Battleground.Arathi Basin.Basic")
	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Arathi Basin.Basic"]:SetLocation(BZ["Arathi Basin"])

	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"] = AutoBarItems:new(
			"Consumable.Food.Edible.Battleground.Warsong Gulch.Basic", "INV_Misc_Food_33", "Consumable.Food.Edible.Battleground.Warsong Gulch.Basic")
	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Edible.Battleground.Warsong Gulch.Basic"]:SetLocation(BZ["Warsong Gulch"])

	AutoBarCategoryList["Consumable.Food.Combo Health"] = AutoBarItems:new(
			"Consumable.Food.Combo Health", "INV_Misc_Food_33", "Consumable.Food.Combo Health")
	AutoBarCategoryList["Consumable.Food.Combo Health"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Edible.Combo.Non-Conjured"] = AutoBarItems:new(
			"Consumable.Food.Edible.Combo.Non-Conjured", "INV_Misc_Food_95_Grainbread", "Consumable.Food.Edible.Combo.Non-Conjured")
	AutoBarCategoryList["Consumable.Food.Edible.Combo.Non-Conjured"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Edible.Combo.Conjured"] = AutoBarItems:new(
			"Consumable.Food.Edible.Combo.Conjured", "INV_Misc_Food_100", "Consumable.Food.Edible.Combo.Conjured")
	AutoBarCategoryList["Consumable.Food.Edible.Combo.Conjured"]:SetNonCombat(true)

	local spellConjureFood, spellConjureFoodIcon
	spellConjureFood, _, spellConjureFoodIcon = GetSpellInfo(33717)
	local spellRitualOfRefreshment, spellRitualOfRefreshmentIcon
	spellRitualOfRefreshment, _, spellRitualOfRefreshmentIcon = GetSpellInfo(43987)
	AutoBarCategoryList["Consumable.Food.Edible.Bread.Conjured"] = AutoBarItems:new(
			"Consumable.Food.Edible.Bread.Conjured", spellConjureFoodIcon, "Consumable.Food.Edible.Basic.Conjured")
	AutoBarCategoryList["Consumable.Food.Edible.Bread.Conjured"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Edible.Bread.Conjured"]:SetCastList(AutoBarCategory:FilterClass({"MAGE", spellRitualOfRefreshment, "MAGE", spellConjureFood,}))

	AutoBarCategoryList["Consumable.Food.Feast"] = AutoBarItems:new(
			"Consumable.Food.Feast", "INV_Misc_Fish_52", "Consumable.Food.Feast")
	AutoBarCategoryList["Consumable.Food.Feast"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Percent.Basic"] = AutoBarItems:new(
			"Consumable.Food.Percent.Basic", "INV_Misc_Food_60", "Consumable.Food.Percent.Basic")
	AutoBarCategoryList["Consumable.Food.Percent.Basic"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Percent.Bonus"] = AutoBarItems:new(
			"Consumable.Food.Percent.Bonus", "INV_Misc_Food_62", "Consumable.Food.Percent.Bonus")
	AutoBarCategoryList["Consumable.Food.Percent.Bonus"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Combo Percent"] = AutoBarItems:new(
			"Consumable.Food.Combo Percent", "INV_Food_ChristmasFruitCake_01", "Consumable.Food.Combo Percent")
	AutoBarCategoryList["Consumable.Food.Combo Percent"]:SetNonCombat(true)

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Edible.Bread.Basic", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Bread.Conjured", true);
--	AutoBarCategoryList["Consumable.Food.Pet.Bread"]["items"] = self:RawItemsConvert(rawList);
--	["Consumable.Food.Pet.Bread"] = {
--		["description"] = Consumable.Food.Pet.Bread;
--		["texture"] = "INV_Misc_Food_35";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Bread"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Bread", "INV_Misc_Food_35", "Consumable.Food.Edible.Bread.Basic", "Consumable.Food.Edible.Basic.Conjured")
	AutoBarCategoryList["Consumable.Food.Pet.Bread"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Bread"]:SetTargeted("PET")

--	AutoBarCategoryList["Consumable.Food.Pet.Cheese"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Cheese.Basic");
--	["Consumable.Food.Pet.Cheese"] = {
--		["description"] = Consumable.Food.Pet.Cheese;
--		["texture"] = "INV_Misc_Food_37";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Cheese"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Cheese", "INV_Misc_Food_37", "Consumable.Food.Edible.Cheese.Basic")
	AutoBarCategoryList["Consumable.Food.Pet.Cheese"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Cheese"]:SetTargeted("PET")

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Fish", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Fish.Basic", true);
--	AutoBarCategoryList["Consumable.Food.Pet.Fish"]["items"] = self:RawItemsConvert(rawList);
--	["Consumable.Food.Pet.Fish"] = {
--		["description"] = Consumable.Food.Pet.Fish;
--		["texture"] = "INV_Misc_Fish_22";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Fish"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fish", "INV_Misc_Fish_22", "Consumable.Food.Inedible.Fish", "Consumable.Food.Edible.Fish.Basic")
	AutoBarCategoryList["Consumable.Food.Pet.Fish"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Fish"]:SetTargeted("PET")

--	AutoBarCategoryList["Consumable.Food.Pet.Fruit"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fruit.Basic");
--	["Consumable.Food.Pet.Fruit"] = {
--		["description"] = Consumable.Food.Pet.Fruit;
--		["texture"] = "INV_Misc_Food_19";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Fruit"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fruit", "INV_Misc_Food_19", "Consumable.Food.Edible.Fruit.Basic")
	AutoBarCategoryList["Consumable.Food.Pet.Fruit"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Fruit"]:SetTargeted("PET")

--	AutoBarCategoryList["Consumable.Food.Pet.Fungus"]["items"] = self:GetSetItemsArrayPT3("Consumable.Food.Edible.Fungus.Basic");	-- Now includes senjin combo ;-(
--	["Consumable.Food.Pet.Fungus"] = {
--		["description"] = Consumable.Food.Pet.Fungus;
--		["texture"] = "INV_Mushroom_05";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Fungus"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Fungus", "INV_Mushroom_05", "Consumable.Food.Edible.Fungus.Basic")
	AutoBarCategoryList["Consumable.Food.Pet.Fungus"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Fungus"]:SetTargeted("PET")

--	rawList = self:RawItemsAdd(nil, "Consumable.Food.Inedible.Meat", false);
--	rawList = self:RawItemsAdd(rawList, "Consumable.Food.Edible.Meat.Basic", true);
--	AutoBarCategoryList["Consumable.Food.Pet.Meat"]["items"] = self:RawItemsConvert(rawList);
--	["Consumable.Food.Pet.Meat"] = {
--		["description"] = Consumable.Food.Pet.Meat;
--		["texture"] = "INV_Misc_Food_14";
--		["nonCombat"] = true,
--		["targeted"] = "PET";
--		["castSpell"] = spellFeedPet;
--	},
	AutoBarCategoryList["Consumable.Food.Pet.Meat"] = AutoBarPetFood:new(
			"Consumable.Food.Pet.Meat", "INV_Misc_Food_14", "Consumable.Food.Inedible.Meat", "Consumable.Food.Edible.Meat.Basic")
	AutoBarCategoryList["Consumable.Food.Pet.Meat"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Food.Pet.Meat"]:SetTargeted("PET")

	AutoBarCategoryList["Consumable.Buff Pet"] = AutoBarPetFood:new(
			"Consumable.Buff Pet", "INV_Misc_Food_87_SporelingSnack", "Consumable.Buff Pet")
	AutoBarCategoryList["Consumable.Buff Pet"]:SetTargeted("PET")

	AutoBarCategoryList["Consumable.Food.Bonus"] = AutoBarItems:new(
			"Consumable.Food.Bonus", "INV_Misc_Food_47", "Consumable.Food.Bonus")
	AutoBarCategoryList["Consumable.Food.Bonus"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Agility"] = AutoBarItems:new(
			"Consumable.Food.Buff.Agility", "INV_Misc_Fish_13", "Consumable.Food.Buff.Agility")
	AutoBarCategoryList["Consumable.Food.Buff.Agility"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Attack Power"] = AutoBarItems:new(
			"Consumable.Food.Buff.Attack Power", "INV_Misc_Fish_13", "Consumable.Food.Buff.Attack Power")
	AutoBarCategoryList["Consumable.Food.Buff.Attack Power"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Healing"] = AutoBarItems:new(
			"Consumable.Food.Buff.Healing", "INV_Misc_Fish_13", "Consumable.Food.Buff.Healing")
	AutoBarCategoryList["Consumable.Food.Buff.Healing"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.HP Regen"] = AutoBarItems:new(
			"Consumable.Food.Buff.HP Regen", "INV_Misc_Fish_19", "Consumable.Food.Buff.HP Regen")
	AutoBarCategoryList["Consumable.Food.Buff.HP Regen"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Intellect"] = AutoBarItems:new(
			"Consumable.Food.Buff.Intellect", "INV_Misc_Food_63", "Consumable.Food.Buff.Intellect")
	AutoBarCategoryList["Consumable.Food.Buff.Intellect"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Mana Regen"] = AutoBarItems:new(
			"Consumable.Food.Buff.Mana Regen", "INV_Drink_17", "Consumable.Food.Buff.Mana Regen")
	AutoBarCategoryList["Consumable.Food.Buff.Mana Regen"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Spell Damage"] = AutoBarItems:new(
			"Consumable.Food.Buff.Spell Damage", "INV_Misc_Food_65", "Consumable.Food.Buff.Spell Damage")
	AutoBarCategoryList["Consumable.Food.Buff.Spell Damage"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Spirit"] = AutoBarItems:new(
			"Consumable.Food.Buff.Spirit", "INV_Misc_Fish_03", "Consumable.Food.Buff.Spirit")
	AutoBarCategoryList["Consumable.Food.Buff.Spirit"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Stamina"] = AutoBarItems:new(
			"Consumable.Food.Buff.Stamina", "INV_Misc_Food_65", "Consumable.Food.Buff.Stamina")
	AutoBarCategoryList["Consumable.Food.Buff.Stamina"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Strength"] = AutoBarItems:new(
			"Consumable.Food.Buff.Strength", "INV_Misc_Food_41", "Consumable.Food.Buff.Strength")
	AutoBarCategoryList["Consumable.Food.Buff.Strength"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Food.Buff.Other"] = AutoBarItems:new(
			"Consumable.Food.Buff.Other", "INV_Drink_17", "Consumable.Food.Buff.Other")
	AutoBarCategoryList["Consumable.Food.Buff.Other"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Cooldown.Potion.Combat"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Combat", "INV_Potion_54", "Consumable.Cooldown.Potion.Combat")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Anywhere"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.Anywhere", "INV_Alchemy_EndlessFlask_06", "Consumable.Cooldown.Potion.Health.Anywhere")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Anywhere"]:SetAnywhere(true)

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Basic"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.Basic", "INV_Potion_54", "Consumable.Cooldown.Potion.Health.Basic")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.PvP"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.PvP", "INV_Potion_39", "Consumable.Cooldown.Potion.Health.PvP")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.PvP"]:SetBattleground(true)

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Blades Edge"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.Blades Edge", "INV_Potion_167", "Consumable.Cooldown.Potion.Health.Blades Edge")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Blades Edge"]:SetLocation(BZ["Blade's Edge Mountains"])

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Coilfang"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.Coilfang", "INV_Potion_167", "Consumable.Cooldown.Potion.Health.Coilfang")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Coilfang"]:SetLocation("Coilfang")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Tempest Keep"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Health.Tempest Keep", "INV_Potion_153", "Consumable.Cooldown.Potion.Health.Tempest Keep")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Health.Tempest Keep"]:SetLocation("Tempest Keep")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Anywhere"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Anywhere", "INV_Alchemy_EndlessFlask_04", "Consumable.Cooldown.Potion.Mana.Anywhere")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Anywhere"]:SetAnywhere(true)

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Basic"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Basic", "INV_Potion_76", "Consumable.Cooldown.Potion.Mana.Basic")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Pvp"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Pvp", "INV_Potion_81", "Consumable.Cooldown.Potion.Mana.Pvp")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Pvp"]:SetBattleground(true)

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Blades Edge"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Blades Edge", "INV_Potion_168", "Consumable.Cooldown.Potion.Mana.Blades Edge")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Blades Edge"]:SetLocation(BZ["Blade's Edge Mountains"])

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Coilfang"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Coilfang", "INV_Potion_168", "Consumable.Cooldown.Potion.Mana.Coilfang")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Coilfang"]:SetLocation("Coilfang")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Tempest Keep"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Mana.Tempest Keep", "INV_Potion_156", "Consumable.Cooldown.Potion.Mana.Tempest Keep")
	AutoBarCategoryList["Consumable.Cooldown.Potion.Mana.Tempest Keep"]:SetLocation("Tempest Keep")

	AutoBarCategoryList["Consumable.Cooldown.Stone.Combat"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Combat", "INV_Stone_04", "Consumable.Cooldown.Stone.Combat")

	AutoBarCategoryList["Consumable.Cooldown.Stone.Health.Warlock"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Health.Warlock", "INV_Stone_04", "Consumable.Cooldown.Stone.Health.Warlock")

	AutoBarCategoryList["Misc.Booze"] = AutoBarItems:new(
			"Misc.Booze", "INV_Drink_03", "Misc.Booze")
	AutoBarCategoryList["Misc.Booze"]:SetNonCombat(true)

	AutoBarCategoryList["Misc.Minipet.Normal"] = AutoBarItems:new(
			"Misc.Minipet.Normal", "Ability_Creature_Poison_05", "Misc.Minipet.Normal")

	AutoBarCategoryList["Misc.Minipet.Snowball"] = AutoBarItems:new(
			"Misc.Minipet.Snowball", "INV_Misc_Bag_17", "Misc.Minipet.Snowball")

	AutoBarCategoryList["Misc.Mount.Normal"] = AutoBarItems:new(
			"Misc.Mount.Normal", "Ability_Mount_JungleTiger", "Misc.Mount.Normal")
	AutoBarCategoryList["Misc.Mount.Normal"]:SetNonCombat(true)

	AutoBarCategoryList["Misc.Mount.Ahn'Qiraj"] = AutoBarItems:new(
			"Misc.Mount.Ahn'Qiraj", "INV_Misc_QirajiCrystal_05", "Misc.Mount.Ahn'Qiraj")
	AutoBarCategoryList["Misc.Mount.Ahn'Qiraj"]:SetNonCombat(true)
	AutoBarCategoryList["Misc.Mount.Ahn'Qiraj"]:SetLocation(BZ["Ahn'Qiraj"])

	AutoBarCategoryList["Misc.Mount.Flying"] = AutoBarItems:new(
			"Misc.Mount.Flying", "Ability_Mount_Wyvern_01", "Misc.Mount.Flying")
	AutoBarCategoryList["Misc.Mount.Flying"]:SetNonCombat(true)

	AutoBarCategoryList["Misc.Openable"] = AutoBarItems:new(
			"Misc.Openable", "INV_Misc_Bag_17", "Misc.Openable")

--[[
	AutoBarCategoryList["Misc.Spell.Mount.Ahn'Qiraj"] = AutoBarSpells:new(
			"Misc.Spell.Mount.Ahn'Qiraj", "Ability_Mount_Wyvern_01", nil, nil, "Misc.Spell.Mount.Ahn'Qiraj")
	AutoBarCategoryList["Misc.Mount.Flying"]:SetNonCombat(true)

	self:AddCategory("Misc.Spell.Mount.Ahn'Qiraj")
	self:AddCategory("Misc.Spell.Mount.Flying.Fast")
	self:AddCategory("Misc.Spell.Mount.Flying.Slow")
	self:AddCategory("Misc.Spell.Mount.Ground.Fast")
	self:AddCategory("Misc.Spell.Mount.Ground.Slow")
--]]
	AutoBarCategoryList["Consumable.Cooldown.Potion.Rejuvenation"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Rejuvenation", "INV_Potion_47", "Consumable.Cooldown.Potion.Rejuvenation")

	AutoBarCategoryList["Consumable.Cooldown.Stone.Health.Statue"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Health.Statue", "INV_Misc_Statue_10", "Consumable.Cooldown.Stone.Health.Statue")

	AutoBarCategoryList["Consumable.Cooldown.Drums"] = AutoBarItems:new(
			"Consumable.Cooldown.Drums", "INV_Misc_Drum_05", "Consumable.Cooldown.Drums")

	AutoBarCategoryList["Consumable.Cooldown.Potion"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion", "INV_Potion_47", "Consumable.Cooldown.Potion")

	AutoBarCategoryList["Consumable.Cooldown.Stone"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone", "INV_Misc_Statue_10", "Consumable.Cooldown.Stone")

	AutoBarCategoryList["Consumable.Leatherworking.Drums"] = AutoBarItems:new(
			"Consumable.Leatherworking.Drums", "INV_Misc_Drum_06", "Consumable.Leatherworking.Drums")

	AutoBarCategoryList["Consumable.Tailor.Net"] = AutoBarItems:new(
			"Consumable.Tailor.Net", "INV_Misc_Net_01", "Consumable.Tailor.Net")

	AutoBarCategoryList["Consumable.Cooldown.Potion.Rejuvenation.Dreamless Sleep"] = AutoBarItems:new(
			"Consumable.Cooldown.Potion.Rejuvenation.Dreamless Sleep", "INV_Potion_83", "Consumable.Cooldown.Potion.Rejuvenation.Dreamless Sleep")

	spellNameList["Conjure Mana Gem"], _, spellIconList["Conjure Mana Gem"] = GetSpellInfo(42985)
	AutoBarCategoryList["Consumable.Cooldown.Stone.Mana.Mana Stone"] = AutoBarItems:new(
			"Consumable.Cooldown.Stone.Mana.Mana Stone", spellIconList["Conjure Mana Gem"], "Consumable.Cooldown.Stone.Mana.Mana Stone")

	AutoBarCategoryList["Consumable.Buff.Rage"] = AutoBarItems:new(
			"Consumable.Buff.Rage", "INV_Potion_24", "Consumable.Buff.Rage")

	AutoBarCategoryList["Consumable.Buff.Energy"] = AutoBarItems:new(
			"Consumable.Buff.Energy", "INV_Drink_Milk_05", "Consumable.Buff.Energy")

	local spellConjureWater, spellConjureWaterIcon
	spellConjureWater, _, spellConjureWaterIcon = GetSpellInfo(27090)
	AutoBarCategoryList["Consumable.Water.Basic"] = AutoBarItems:new(
			"Consumable.Water.Basic", "INV_Drink_10", "Consumable.Water.Basic", "Consumable.Water.Conjured")
	AutoBarCategoryList["Consumable.Water.Basic"]:SetNonCombat(true)
	AutoBarCategoryList["Consumable.Water.Basic"]:SetCastList(AutoBarCategory:FilterClass({"MAGE", spellConjureWater,}))

	AutoBarCategoryList["Consumable.Water.Conjure"] = AutoBarSpells:new(
			"Consumable.Water.Conjure", spellConjureWaterIcon, {
			"MAGE", spellConjureWater,
			})

	AutoBarCategoryList["Consumable.Food.Conjure"] = AutoBarSpells:new(
			"Consumable.Food.Conjure", spellConjureFoodIcon, {
			"MAGE", spellConjureFood,
			})

	AutoBarCategoryList["Consumable.Water.Percentage"] = AutoBarItems:new(
			"Consumable.Water.Percentage", "INV_Drink_04", "Consumable.Water.Percentage")
	AutoBarCategoryList["Consumable.Water.Percentage"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Water.Buff.Spirit"] = AutoBarItems:new(
			"Consumable.Water.Buff.Spirit", "INV_Drink_16", "Consumable.Water.Buff.Spirit")
	AutoBarCategoryList["Consumable.Water.Buff.Spirit"]:SetNonCombat(true)

	AutoBarCategoryList["Consumable.Water.Buff"] = AutoBarItems:new(
			"Consumable.Water.Buff", "INV_Drink_08", "Consumable.Water.Buff")
	AutoBarCategoryList["Consumable.Water.Buff"]:SetNonCombat(true)


	AutoBarCategoryList["Consumable.Weapon Buff.Oil.Mana"] = AutoBarItems:new("Consumable.Weapon Buff.Oil.Mana", "INV_Potion_100",
			"Consumable.Weapon Buff.Oil.Mana")
	AutoBarCategoryList["Consumable.Weapon Buff.Oil.Mana"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Oil.Wizard"] = AutoBarItems:new("Consumable.Weapon Buff.Oil.Wizard", "INV_Potion_105",
			"Consumable.Weapon Buff.Oil.Wizard")
	AutoBarCategoryList["Consumable.Weapon Buff.Oil.Wizard"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Crippling"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Crippling", "INV_Potion_19",
			"Consumable.Weapon Buff.Poison.Crippling")
	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Crippling"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Deadly"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Deadly", "Ability_Rogue_DualWeild",
			"Consumable.Weapon Buff.Poison.Deadly")
	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Deadly"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Instant"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Instant", "Ability_Poisons",
			"Consumable.Weapon Buff.Poison.Instant", "Consumable.Weapon Buff.Poison.Anesthetic")
	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Instant"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Mind Numbing"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Mind Numbing", "Spell_Nature_NullifyDisease",
			"Consumable.Weapon Buff.Poison.Mind Numbing")
	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Mind Numbing"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Wound"] = AutoBarItems:new("Consumable.Weapon Buff.Poison.Wound", "Ability_PoisonSting",
			"Consumable.Weapon Buff.Poison.Wound")
	AutoBarCategoryList["Consumable.Weapon Buff.Poison.Wound"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Stone.Sharpening Stone"] = AutoBarItems:new("Consumable.Weapon Buff.Stone.Sharpening Stone", "INV_Stone_SharpeningStone_01",
			"Consumable.Weapon Buff.Stone.Sharpening Stone")
	AutoBarCategoryList["Consumable.Weapon Buff.Stone.Sharpening Stone"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Weapon Buff.Stone.Weight Stone"] = AutoBarItems:new("Consumable.Weapon Buff.Stone.Weight Stone", "INV_Stone_WeightStone_02",
			"Consumable.Weapon Buff.Stone.Weight Stone")
	AutoBarCategoryList["Consumable.Weapon Buff.Stone.Weight Stone"]:SetTargeted("WEAPON")


	AutoBarCategoryList["Consumable.Buff Group.General.Self"] = AutoBarItems:new("Consumable.Buff Group.General.Self", "INV_Potion_80",
			"Consumable.Buff Group.General.Self")

	AutoBarCategoryList["Consumable.Buff Group.General.Target"] = AutoBarItems:new("Consumable.Buff Group.General.Target", "INV_Potion_80",
			"Consumable.Buff Group.General.Target")
	AutoBarCategoryList["Consumable.Buff Group.General.Target"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff Group.Caster.Self"] = AutoBarItems:new("Consumable.Buff Group.Caster.Self", "INV_Potion_66",
			"Consumable.Buff Group.Caster.Self")

	AutoBarCategoryList["Consumable.Buff Group.Caster.Target"] = AutoBarItems:new("Consumable.Buff Group.Caster.Target", "INV_Potion_66",
			"Consumable.Buff Group.Caster.Target")
	AutoBarCategoryList["Consumable.Buff Group.Caster.Target"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff Group.Melee.Self"] = AutoBarItems:new("Consumable.Buff Group.Melee.Self", "INV_Potion_43",
			"Consumable.Buff Group.Melee.Self")

	AutoBarCategoryList["Consumable.Buff Group.Melee.Target"] = AutoBarItems:new("Consumable.Buff Group.Melee.Target", "INV_Potion_43",
			"Consumable.Buff Group.Melee.Target")
	AutoBarCategoryList["Consumable.Buff Group.Melee.Target"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Other.Self"] = AutoBarItems:new("Consumable.Buff.Other.Self", "INV_Potion_80",
			"Consumable.Buff.Other.Self")

--[[
	AutoBarCategoryList["Consumable.Buff.Other.Target"] = AutoBarItems:new("Consumable.Buff.Other.Target", "INV_Potion_80",
			"Consumable.Buff.Other.Target")
	AutoBarCategoryList["Consumable.Buff.Other.Target"]:SetTargeted(true)
--]]

	AutoBarCategoryList["Consumable.Buff.Chest"] = AutoBarItems:new("Consumable.Buff.Chest", "INV_Misc_Rune_10",
			"Consumable.Buff.Chest")
	AutoBarCategoryList["Consumable.Buff.Chest"]:SetTargeted("CHEST")

	AutoBarCategoryList["Consumable.Buff.Shield"] = AutoBarItems:new("Consumable.Buff.Shield", "INV_Misc_Rune_13",
			"Consumable.Buff.Shield")
	AutoBarCategoryList["Consumable.Buff.Shield"]:SetTargeted("SHIELD")

	AutoBarCategoryList["Consumable.Weapon Buff"] = AutoBarItems:new("Consumable.Weapon Buff", "INV_Misc_Rune_13",
			"Consumable.Weapon Buff")
	AutoBarCategoryList["Consumable.Weapon Buff"]:SetTargeted("WEAPON")

	AutoBarCategoryList["Consumable.Buff.Health"] = AutoBarItems:new("Consumable.Buff.Health", "INV_Potion_43",
			"Consumable.Buff.Health")

	AutoBarCategoryList["Consumable.Buff.Armor"] = AutoBarItems:new("Consumable.Buff.Armor", "INV_Potion_66",
			"Consumable.Buff.Armor")

	AutoBarCategoryList["Consumable.Buff.Regen Health"] = AutoBarItems:new("Consumable.Buff.Regen Health", "INV_Potion_80",
			"Consumable.Buff.Regen Health")

	AutoBarCategoryList["Consumable.Buff.Agility"] = AutoBarItems:new("Consumable.Buff.Agility", "INV_Scroll_02",
			"Consumable.Buff.Agility")
	AutoBarCategoryList["Consumable.Buff.Agility"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Intellect"] = AutoBarItems:new("Consumable.Buff.Intellect", "INV_Scroll_01",
			"Consumable.Buff.Intellect")
	AutoBarCategoryList["Consumable.Buff.Intellect"]:SetTargeted(true)

--	AutoBarCategoryList["BUFF_PROTECTION"] = AutoBarItems:new("Consumable.Buff.Protection", "INV_Scroll_07",
--			"Consumable.Buff.Protection")
--	AutoBarCategoryList["BUFF_PROTECTION"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Spirit"] = AutoBarItems:new("Consumable.Buff.Spirit", "INV_Scroll_01",
			"Consumable.Buff.Spirit")
	AutoBarCategoryList["Consumable.Buff.Spirit"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Stamina"] = AutoBarItems:new("Consumable.Buff.Stamina", "INV_Scroll_07",
			"Consumable.Buff.Stamina")
	AutoBarCategoryList["Consumable.Buff.Stamina"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Strength"] = AutoBarItems:new("Consumable.Buff.Strength", "INV_Scroll_02",
			"Consumable.Buff.Strength")
	AutoBarCategoryList["Consumable.Buff.Strength"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Attack Power"] = AutoBarItems:new("Consumable.Buff.Attack Power", "INV_Misc_MonsterScales_07",
			"Consumable.Buff.Attack Power")
	AutoBarCategoryList["Consumable.Buff.Attack Power"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Attack Speed"] = AutoBarItems:new("Consumable.Buff.Attack Speed", "INV_Misc_MonsterScales_17",
			"Consumable.Buff.Attack Speed")
	AutoBarCategoryList["Consumable.Buff.Attack Speed"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Dodge"] = AutoBarItems:new("Consumable.Buff.Dodge", "INV_Misc_MonsterScales_17",
			"Consumable.Buff.Dodge")
	AutoBarCategoryList["Consumable.Buff.Dodge"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Resistance.Self"] = AutoBarItems:new("Consumable.Buff.Resistance", "INV_Misc_MonsterScales_15",
			"Consumable.Buff.Resistance.Self")

	AutoBarCategoryList["Consumable.Buff.Resistance.Target"] = AutoBarItems:new("Consumable.Buff.Resistance", "INV_Misc_MonsterScales_15",
			"Consumable.Buff.Resistance.Target")
	AutoBarCategoryList["Consumable.Buff.Resistance.Target"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Buff.Speed"] = AutoBarItems:new("Consumable.Buff.Speed", "INV_Potion_95",
			"Consumable.Buff.Speed")

	AutoBarCategoryList["Consumable.Buff Type.Battle"] = AutoBarItems:new("Consumable.Buff Type.Battle", "INV_Potion_111",
			"Consumable.Buff Type.Battle")

	AutoBarCategoryList["Consumable.Buff Type.Guardian"] = AutoBarItems:new("Consumable.Buff Type.Guardian", "INV_Potion_155",
			"Consumable.Buff Type.Guardian")

	AutoBarCategoryList["Consumable.Buff Type.Flask"] = AutoBarItems:new("Consumable.Buff Type.Flask", "INV_Potion_118",
			"Consumable.Buff Type.Flask")

	AutoBarCategoryList["Gear.Trinket"] = AutoBarItems:new("Gear.Trinket", "INV_Misc_OrnateBox",
			"Gear.Trinket")

	AutoBarCategoryList["Misc.Lockboxes"] = AutoBarItems:new("Misc.Lockboxes", "INV_Trinket_Naxxramas06",
			"Misc.Lockboxes")

	AutoBarCategoryList["Misc.Usable.BossItem"] = AutoBarItems:new("Misc.Usable.BossItem", "INV_BannerPVP_02",
			"Misc.Usable.BossItem")

	AutoBarCategoryList["Misc.Usable.Fun"] = AutoBarItems:new("Misc.Usable.Fun", "INV_Misc_Toy_10",
			"Misc.Usable.Fun")

	AutoBarCategoryList["Misc.Usable.Permanent"] = AutoBarItems:new("Misc.Usable.Permanent", "INV_BannerPVP_02",
			"Misc.Usable.Permanent")

	AutoBarCategoryList["Misc.Usable.Quest"] = AutoBarItems:new("Misc.Usable.Quest", "INV_BannerPVP_02",
			"Misc.Usable.Quest")

	AutoBarCategoryList["Misc.Usable.StartsQuest"] = AutoBarItems:new("Misc.Usable.StartsQuest", "INV_Staff_20",
			"Misc.Usable.StartsQuest")

	AutoBarCategoryList["Misc.Usable.Replenished"] = AutoBarItems:new("Misc.Usable.Replenished", "INV_BannerPVP_02",
			"Misc.Usable.Replenished")

	local spellCreateFirestone, spellCreateFirestoneIcon
	spellCreateFirestone, _, spellCreateFirestoneIcon = GetSpellInfo(27250)
	AutoBarCategoryList["Consumable.Warlock.Firestone"] = AutoBarItems:new("Consumable.Warlock.Firestone", "INV_Misc_MonsterScales_15",
			"Consumable.Warlock.Firestone")

	AutoBarCategoryList["Consumable.Warlock.Soulstone"] = AutoBarItems:new("Consumable.Warlock.Soulstone", "INV_Misc_MonsterScales_15",
			"Consumable.Warlock.Soulstone")
	AutoBarCategoryList["Consumable.Warlock.Soulstone"]:SetTargeted(true)

	AutoBarCategoryList["Consumable.Warlock.Spellstone"] = AutoBarItems:new("Consumable.Warlock.Spellstone", "INV_Misc_MonsterScales_15",
			"Consumable.Warlock.Spellstone")

	AutoBarCategoryList["Spell.Warlock.Create Firestone"] = AutoBarSpells:new(
			"Spell.Warlock.Create Firestone", spellCreateFirestoneIcon, {
			"WARLOCK", spellCreateFirestone,
			})

	local spellCreateHealthstone, spellCreateHealthstoneIcon
	spellCreateHealthstone, _, spellCreateHealthstoneIcon = GetSpellInfo(27230)
	local spellRitualOfSouls, spellRitualOfSoulsIcon
	spellRitualOfSouls, _, spellRitualOfSoulsIcon = GetSpellInfo(29893)
	AutoBarCategoryList["Spell.Warlock.Create Healthstone"] = AutoBarSpells:new(
			"Spell.Warlock.Create Healthstone", spellCreateHealthstoneIcon, {
			"WARLOCK", spellCreateHealthstone,
			"WARLOCK", spellRitualOfSouls,
			})

	local spellCreateSoulstone, spellCreateSoulstoneIcon
	spellCreateSoulstone, _, spellCreateSoulstoneIcon = GetSpellInfo(27238)
	AutoBarCategoryList["Spell.Warlock.Create Soulstone"] = AutoBarSpells:new(
			"Spell.Warlock.Create Soulstone", spellCreateSoulstoneIcon, {
			"WARLOCK", spellCreateSoulstone,
			})

	local spellCreateSpellstone, spellCreateSpellstoneIcon
	spellCreateSpellstone, _, spellCreateSpellstoneIcon = GetSpellInfo(28172)
	AutoBarCategoryList["Spell.Warlock.Create Spellstone"] = AutoBarSpells:new(
			"Spell.Warlock.Create Spellstone", spellCreateSpellstoneIcon, {
			"WARLOCK", spellCreateSpellstone,
			})

	spellNameList["Conjure Refreshment"] = GetSpellInfo(42955)
	AutoBarCategoryList["Spell.Mage.Conjure Food"] = AutoBarSpells:new(
			"Spell.Mage.Conjure Food", spellRitualOfRefreshmentIcon, {
			"MAGE", spellConjureFood,
			"MAGE", spellConjureWater,
			"MAGE", spellRitualOfRefreshment,
			"MAGE", spellNameList["Conjure Refreshment"],
			})
--/script local name, rank, icon, cost = GetSpellInfo(43987); AutoBar:Print("AutoBarCustom.prototype:init GetSpellInfo(43987) name " .. tostring(name) .. " rank " .. tostring(rank) .. " icon " .. tostring(icon) .. " cost " .. tostring(cost))

	AutoBarCategoryList["Spell.Mage.Conjure Mana Stone"] = AutoBarSpells:new(
			"Spell.Mage.Conjure Mana Stone", spellIconList["Conjure Mana Gem"], {
			"MAGE", spellNameList["Conjure Mana Gem"],
			})

	spellNameList["Crusader Aura"], _, spellIconList["Crusader Aura"] = GetSpellInfo(32223)
	spellNameList["Aspect of the Beast"] = GetSpellInfo(13161)
	spellNameList["Aspect of the Cheetah"] = GetSpellInfo(5118)
	spellNameList["Aspect of the Hawk"] = GetSpellInfo(27044)
	spellNameList["Aspect of the Monkey"] = GetSpellInfo(13163)
	spellNameList["Aspect of the Pack"] = GetSpellInfo(13159)
	spellNameList["Aspect of the Viper"] = GetSpellInfo(34074)
	spellNameList["Aspect of the Wild"] = GetSpellInfo(27045)
	spellNameList["Aspect of the Dragonhawk"] = GetSpellInfo(61846)
	spellNameList["Trueshot Aura"] = GetSpellInfo(19506)
	spellNameList["Concentration Aura"] = GetSpellInfo(19746)
	spellNameList["Devotion Aura"] = GetSpellInfo(465)
	spellNameList["Fire Resistance Aura"] = GetSpellInfo(19891)
	spellNameList["Frost Resistance Aura"] = GetSpellInfo(19888)
	spellNameList["Retribution Aura"] = GetSpellInfo(7294)
	spellNameList["Shadow Resistance Aura"] = GetSpellInfo(19876)
	AutoBarCategoryList["Spell.Aura"] = AutoBarSpells:new(
			"Spell.Aura", spellIconList["Crusader Aura"], {
			"HUNTER", spellNameList["Aspect of the Beast"],
			"HUNTER", spellNameList["Aspect of the Cheetah"],
			"HUNTER", spellNameList["Aspect of the Hawk"],
			"HUNTER", spellNameList["Aspect of the Monkey"],
			"HUNTER", spellNameList["Aspect of the Pack"],
			"HUNTER", spellNameList["Aspect of the Viper"],
			"HUNTER", spellNameList["Aspect of the Wild"],
			"HUNTER", spellNameList["Aspect of the Dragonhawk"],
			"HUNTER", spellNameList["Trueshot Aura"],
			"PALADIN", spellNameList["Concentration Aura"],
			"PALADIN", spellNameList["Crusader Aura"],
			"PALADIN", spellNameList["Devotion Aura"],
			"PALADIN", spellNameList["Fire Resistance Aura"],
			"PALADIN", spellNameList["Frost Resistance Aura"],
			"PALADIN", spellNameList["Retribution Aura"],
			"PALADIN", spellNameList["Shadow Resistance Aura"],
			})

	spellNameList["Bone Shield"] = GetSpellInfo(49222)
	spellNameList["Horn of Winter"] = GetSpellInfo(57330)

	spellNameList["Gift of the Wild"], _, spellIconList["Gift of the Wild"] = GetSpellInfo(26991)
	spellNameList["Amplify Magic"] = GetSpellInfo(33946)
	spellNameList["Dampen Magic"] = GetSpellInfo(33944)
	spellNameList["Focus Magic"] = GetSpellInfo(54646)
	spellNameList["Slow Fall"] = GetSpellInfo(130)
	spellNameList["Earth Shield"] = GetSpellInfo(974)
	spellNameList["Lightning Shield"] = GetSpellInfo(25472)
	spellNameList["Mark of the Wild"] = GetSpellInfo(26990)
	spellNameList["Water Shield"] = GetSpellInfo(33736)
	spellNameList["Water Walking"] = GetSpellInfo(546)
	spellNameList["Water Breathing"] = GetSpellInfo(131)

	spellNameList["Arcane Intellect"] = GetSpellInfo(27126)
	spellNameList["Arcane Brilliance"] = GetSpellInfo(27127)
	spellNameList["Dalaran Intellect"] = GetSpellInfo(61024)
	spellNameList["Dalaran Brilliance"] = GetSpellInfo(61316)

	spellNameList["Hand of Freedom"] = GetSpellInfo(1044)
	spellNameList["Blessing of Kings"] = GetSpellInfo(20217)
	spellNameList["Greater Blessing of Kings"] = GetSpellInfo(25898)
	spellNameList["Blessing of Might"] = GetSpellInfo(19740)
	spellNameList["Greater Blessing of Might"] = GetSpellInfo(25782)
	spellNameList["Hand of Protection"] = GetSpellInfo(1022)
	spellNameList["Hand of Sacrifice"] = GetSpellInfo(6940)
	spellNameList["Hand of Salvation"] = GetSpellInfo(1038)
	spellNameList["Blessing of Sanctuary"] = GetSpellInfo(20911)
	spellNameList["Greater Blessing of Sanctuary"] = GetSpellInfo(25899)
	spellNameList["Blessing of Wisdom"] = GetSpellInfo(27142)
	spellNameList["Greater Blessing of Wisdom"] = GetSpellInfo(27143)

	spellNameList["Shadow Protection"] = GetSpellInfo(976)
	spellNameList["Prayer of ShadowProtection"] = GetSpellInfo(27683)
	spellNameList["Divine Spirit"] = GetSpellInfo(14752)
	spellNameList["Prayer of Spirit"] = GetSpellInfo(27681)
	spellNameList["Power Word: Fortitude"] = GetSpellInfo(1243)
	spellNameList["Prayer of Fortitude"] = GetSpellInfo(21562)
	spellNameList["Inner Fire"] = GetSpellInfo(588)
	spellNameList["Vampiric Embrace"] = GetSpellInfo(15286)

	spellNameList["Omen of Clarity"] = GetSpellInfo(16864)
	spellNameList["Thorns"] = GetSpellInfo(26992)
	spellNameList["Natures Grasp"] = GetSpellInfo(27009)
	spellNameList["Frost Armor"] = GetSpellInfo(7301)
	spellNameList["Ice Armor"] = GetSpellInfo(27124)
	spellNameList["Mage Armor"] = GetSpellInfo(27125)
	spellNameList["Molten Armor"] = GetSpellInfo(30482)
	
	spellNameList["Detect Invisibility"] = GetSpellInfo(132)
	spellNameList["Demon Armor"] = GetSpellInfo(706)
	spellNameList["Demon Skin"] = GetSpellInfo(696)
	spellNameList["Fel Armor"] = GetSpellInfo(28189)

	spellNameList["Demoralizing Shout"] = GetSpellInfo(25203)
	spellNameList["Challenging Shout"] = GetSpellInfo(1161)
	spellNameList["Battle Shout"] = GetSpellInfo(2048)
	spellNameList["Commanding Shout"] = GetSpellInfo(469)
	AutoBarCategoryList["Spell.Class.Buff"] = AutoBarSpells:new(
			"Spell.Class.Buff", spellIconList["Gift of the Wild"], nil, {
			"DEATHKNIGHT", spellNameList["Bone Shield"], spellNameList["Bone Shield"],
			"DEATHKNIGHT", spellNameList["Horn of Winter"], spellNameList["Horn of Winter"],
			"DRUID", spellNameList["Omen of Clarity"], spellNameList["Omen of Clarity"],
			"DRUID", spellNameList["Thorns"], spellNameList["Thorns"],
			"DRUID", spellNameList["Mark of the Wild"], spellNameList["Gift of the Wild"],
			"DRUID", spellNameList["Natures Grasp"], spellNameList["Natures Grasp"],
			"MAGE", spellNameList["Arcane Intellect"], spellNameList["Arcane Brilliance"],
			"MAGE", spellNameList["Dalaran Intellect"], spellNameList["Dalaran Brilliance"],
			"MAGE", spellNameList["Frost Armor"], spellNameList["Frost Armor"],
			"MAGE", spellNameList["Ice Armor"], spellNameList["Ice Armor"],
			"MAGE", spellNameList["Mage Armor"], spellNameList["Mage Armor"],
			"MAGE", spellNameList["Molten Armor"], spellNameList["Molten Armor"],
			"MAGE", spellNameList["Amplify Magic"], spellNameList["Amplify Magic"],
			"MAGE", spellNameList["Dampen Magic"], spellNameList["Dampen Magic"],
			"MAGE", spellNameList["Focus Magic"], spellNameList["Focus Magic"],
			"MAGE", spellNameList["Slow Fall"], spellNameList["Slow Fall"],
			"PALADIN", spellNameList["Hand of Freedom"], spellNameList["Hand of Freedom"],
			"PALADIN", spellNameList["Blessing of Kings"], spellNameList["Greater Blessing of Kings"],
			"PALADIN", spellNameList["Blessing of Might"], spellNameList["Greater Blessing of Might"],
			"PALADIN", spellNameList["Hand of Protection"], spellNameList["Hand of Protection"],
			"PALADIN", spellNameList["Hand of Sacrifice"], spellNameList["Hand of Sacrifice"],
			"PALADIN", spellNameList["Hand of Salvation"], spellNameList["Hand of Salvation"],
			"PALADIN", spellNameList["Blessing of Sanctuary"], spellNameList["Greater Blessing of Sanctuary"],
			"PALADIN", spellNameList["Blessing of Wisdom"], spellNameList["Greater Blessing of Wisdom"],
			"PRIEST", spellNameList["Shadow Protection"], spellNameList["Prayer of ShadowProtection"],
			"PRIEST", spellNameList["Divine Spirit"], spellNameList["Prayer of Spirit"],
			"PRIEST", spellNameList["Power Word: Fortitude"], spellNameList["Prayer of Fortitude"],
			"PRIEST", spellNameList["Inner Fire"], spellNameList["Inner Fire"],
			"PRIEST", spellNameList["Vampiric Embrace"], spellNameList["Vampiric Embrace"],
			"SHAMAN", spellNameList["Water Walking"], spellNameList["Water Walking"],
			"SHAMAN", spellNameList["Water Breathing"], spellNameList["Water Breathing"],
			"SHAMAN", spellNameList["Earth Shield"], spellNameList["Earth Shield"],
			"SHAMAN", spellNameList["Lightning Shield"], spellNameList["Lightning Shield"],
			"SHAMAN", spellNameList["Water Shield"], spellNameList["Water Shield"],
			"WARLOCK", spellNameList["Detect Invisibility"], spellNameList["Detect Invisibility"],
			"WARLOCK", spellNameList["Demon Armor"], spellNameList["Demon Armor"],
			"WARLOCK", spellNameList["Demon Skin"], spellNameList["Demon Skin"],
			"WARLOCK", spellNameList["Fel Armor"], spellNameList["Fel Armor"],
			"WARRIOR", spellNameList["Demoralizing Shout"], spellNameList["Challenging Shout"],
			"WARRIOR", spellNameList["Battle Shout"], spellNameList["Commanding Shout"],
			"WARRIOR", spellNameList["Commanding Shout"], spellNameList["Battle Shout"],
			})
	if (AutoBar.CLASS == "PALADIN") then
		local spellDivineIntervention = GetSpellInfo(19752)
	end
	if (AutoBar.CLASS == "PRIEST") then
		local spellLevitate = GetSpellInfo(1706)
	end

	local spellForceOfNature, spellForceOfNatureIcon
	spellForceOfNature, _, spellForceOfNatureIcon = GetSpellInfo(33831)
	local spellEagleEye = GetSpellInfo(6197)
	local spellScareBeast = GetSpellInfo(14327)
	local spellTameBeast = GetSpellInfo(1515)
	local spellBeastTraining = GetSpellInfo(5149)
	local spellBeastLore = GetSpellInfo(1462)
	local spellEyesOfTheBeast = GetSpellInfo(1002)
	local spellMendPet = GetSpellInfo(27046)
	local spellDismissPet = GetSpellInfo(2641)
	local spellRevivePet = GetSpellInfo(982)
	local spellCallPet = GetSpellInfo(883)
	local spellSummonWaterElemental = GetSpellInfo(31687)
	local spellShadowfiend = GetSpellInfo(34433)
	local spellEarthElementalTotem = GetSpellInfo(2062)
	local spellFireElementalTotem = GetSpellInfo(2894)
	spellNameList["Feral Spirit"] = GetSpellInfo(51533)
	local spellEyeOfKilrogg = GetSpellInfo(126)
	local spellSummonFelguard = GetSpellInfo(30146)
	local spellSummonFelhunter = GetSpellInfo(691)
	local spellSummonImp = GetSpellInfo(688)
	local spellSummonSuccubus = GetSpellInfo(712)
	local spellSummonVoidwalker = GetSpellInfo(697)
	local spellInferno = GetSpellInfo(1122)
	local spellRitualOfDoom = GetSpellInfo(18540)
	AutoBarCategoryList["Spell.Class.Pet"] = AutoBarSpells:new(
			"Spell.Class.Pet", spellForceOfNatureIcon, {
			"DRUID", spellForceOfNature,
			"HUNTER", spellEagleEye,
			"HUNTER", spellScareBeast,
			"HUNTER", spellTameBeast,
			"HUNTER", spellBeastTraining,
			"HUNTER", spellBeastLore,
			"HUNTER", spellEyesOfTheBeast,
			"HUNTER", spellMendPet,
			"HUNTER", spellFeedPet,
			"HUNTER", spellDismissPet,
			"HUNTER", spellRevivePet,
			"HUNTER", spellCallPet,
			"MAGE", spellSummonWaterElemental,
			"PRIEST", spellShadowfiend,
			"SHAMAN", spellEarthElementalTotem,
			"SHAMAN", spellFireElementalTotem,
			"SHAMAN", spellNameList["Feral Spirit"],
			"WARLOCK", spellInferno,
			"WARLOCK", spellRitualOfDoom,
			"WARLOCK", spellEyeOfKilrogg,
			"WARLOCK", spellSummonFelguard,
			"WARLOCK", spellSummonFelhunter,
			"WARLOCK", spellSummonImp,
			"WARLOCK", spellSummonSuccubus,
			"WARLOCK", spellSummonVoidwalker,
			})

	local spellPortalShattrath, spellPortalShattrathIcon
	spellPortalShattrath, _, spellPortalShattrathIcon = GetSpellInfo(33691)
	local spellTeleportStonard = GetSpellInfo(49358)
	local spellPortalStonard = GetSpellInfo(49361)
	local spellTeleportTheramore = GetSpellInfo(49359)
	local spellPortalTheramore = GetSpellInfo(49360)
	local spellTeleportUndercity = GetSpellInfo(3563)
	local spellPortalUndercity = GetSpellInfo(11418)
	local spellTeleportThunderBluff = GetSpellInfo(3566)
	local spellPortalThunderBluff = GetSpellInfo(11420)
	local spellTeleportStormwind = GetSpellInfo(3561)
	local spellPortalStormwind = GetSpellInfo(10059)
	local spellTeleportSilvermoon = GetSpellInfo(32272)
	local spellPortalSilvermoon = GetSpellInfo(32267)
	local spellTeleportExodar = GetSpellInfo(32271)
	local spellPortalExodar = GetSpellInfo(32266)
	local spellTeleportDarnassus = GetSpellInfo(3565)
	local spellPortalDarnassus = GetSpellInfo(11419)
	local spellTeleportIronforge = GetSpellInfo(3562)
	local spellPortalIronforge = GetSpellInfo(11416)
	local spellTeleportOrgrimmar = GetSpellInfo(3567)
	local spellPortalOrgrimmar = GetSpellInfo(11417)
	local spellTeleportShattrath = GetSpellInfo(35715)
	spellNameList["Teleport: Dalaran"] = GetSpellInfo(53140)
	spellNameList["Portal: Dalaran"] = GetSpellInfo(53142)
	spellNameList["Death Gate"] = GetSpellInfo(50977)
	local spellTeleportMoonglade = GetSpellInfo(18960)
	local spellAstralRecall = GetSpellInfo(556)
	local spellRitualOfSummoning = GetSpellInfo(698)
	AutoBarCategoryList["Spell.Portals"] = AutoBarSpells:new(
			"Spell.Portals", spellPortalShattrathIcon, nil, {
			"MAGE", spellTeleportStonard, spellPortalStonard,
			"MAGE", spellTeleportTheramore, spellPortalTheramore,
			"MAGE", spellTeleportUndercity, spellPortalUndercity,
			"MAGE", spellTeleportThunderBluff, spellPortalThunderBluff,
			"MAGE", spellTeleportStormwind, spellPortalStormwind,
			"MAGE", spellTeleportSilvermoon, spellPortalSilvermoon,
			"MAGE", spellTeleportExodar, spellPortalExodar,
			"MAGE", spellTeleportDarnassus, spellPortalDarnassus,
			"MAGE", spellTeleportIronforge, spellPortalIronforge,
			"MAGE", spellTeleportOrgrimmar, spellPortalOrgrimmar,
			"MAGE", spellTeleportShattrath, spellPortalShattrath,
			"MAGE", spellNameList["Teleport: Dalaran"], spellNameList["Portal: Dalaran"],
			"DEATHKNIGHT", spellNameList["Death Gate"], spellNameList["Death Gate"],
			"DRUID", spellTeleportMoonglade, spellTeleportMoonglade,
			"SHAMAN", spellAstralRecall, spellAstralRecall,
			"WARLOCK", spellRitualOfSummoning, spellRitualOfSummoning,
			})

	spellNameList["Barkskin"] = GetSpellInfo(22812)

	spellNameList["Ice Barrier"], _, spellIconList["Ice Barrier"] = GetSpellInfo(11426)
	spellNameList["Mana Shield"] = GetSpellInfo(1463)

	spellNameList["Divine Protection"] = GetSpellInfo(498)

	spellNameList["Power Word: Shield"] = GetSpellInfo(17)

	spellNameList["Evasion"] = GetSpellInfo(5277)

	spellNameList["Shadow Ward"] = GetSpellInfo(6229)
	spellNameList["Soul Link"] = GetSpellInfo(19028)

	spellNameList["Last Stand"] = GetSpellInfo(12975)
	spellNameList["Shield Wall"] = GetSpellInfo(871)
	AutoBarCategoryList["Spell.Shields"] = AutoBarSpells:new(
			"Spell.Shields", "Spell_Ice_Lament", nil, {
			"DEATHKNIGHT", spellNameList["Bone Shield"], spellNameList["Bone Shield"],
			"DRUID", spellNameList["Barkskin"], spellNameList["Barkskin"],
			"MAGE", spellNameList["Ice Barrier"], spellNameList["Ice Barrier"],
			"MAGE", spellNameList["Mana Shield"], spellNameList["Mana Shield"],
			"PALADIN", spellNameList["Divine Protection"], spellNameList["Divine Protection"],
			"PALADIN", spellNameList["Hand of Protection"], spellNameList["Hand of Protection"],
			"SHAMAN", spellNameList["Earth Shield"], spellNameList["Earth Shield"],
			"SHAMAN", spellNameList["Lightning Shield"], spellNameList["Lightning Shield"],
			"SHAMAN", spellNameList["Water Shield"], spellNameList["Water Shield"],
			"PRIEST", spellNameList["Power Word: Shield"], spellNameList["Power Word: Shield"],
			"ROGUE", spellNameList["Evasion"], spellNameList["Evasion"],
			"WARLOCK", spellNameList["Shadow Ward"], spellNameList["Shadow Ward"],
			"WARLOCK", spellNameList["Soul Link"], spellNameList["Soul Link"],
			"WARRIOR", spellNameList["Last Stand"], spellNameList["Last Stand"],
			"WARRIOR", spellNameList["Shield Wall"], spellNameList["Shield Wall"],
			})
end

-- Create category list using PeriodicTable data.
-- Split up to avoid Lua upValue limitations
function AutoBarCategory:Initialize2()
	spellNameList["Berserker Stance"], _, spellIconList["Berserker Stance"] = GetSpellInfo(2458)
	spellNameList["Defensive Stance"] = GetSpellInfo(71)
	spellNameList["Battle Stance"] = GetSpellInfo(2457)
	AutoBarCategoryList["Spell.Stance"] = AutoBarSpells:new(
			"Spell.Stance", spellIconList["Berserker Stance"], nil, {
			"WARRIOR", spellNameList["Defensive Stance"], spellNameList["Berserker Stance"],
			"WARRIOR", spellNameList["Battle Stance"], spellNameList["Defensive Stance"],
			"WARRIOR", spellNameList["Berserker Stance"], spellNameList["Defensive Stance"],
			})

	local spellEarthElementalTotem, spellEarthElementalTotemIcon
	spellEarthElementalTotem, _, spellEarthElementalTotemIcon = GetSpellInfo(2062)
	local spellEarthbindTotem = GetSpellInfo(2484)
	local spellStoneclawTotem = GetSpellInfo(25525)
	local spellStoneskinTotem = GetSpellInfo(25509)
	local spellStrengthOfEarthTotem = GetSpellInfo(25528)
	local spellTremorTotem = GetSpellInfo(8143)
	AutoBarCategoryList["Spell.Totem.Earth"] = AutoBarSpells:new(
			"Spell.Totem.Earth", spellEarthElementalTotemIcon, {
			"SHAMAN", spellEarthElementalTotem,
			"SHAMAN", spellEarthbindTotem,
			"SHAMAN", spellStoneclawTotem,
			"SHAMAN", spellStoneskinTotem,
			"SHAMAN", spellStrengthOfEarthTotem,
			"SHAMAN", spellTremorTotem,
			})

	spellNameList["Grounding Totem"], _, spellIconList["Grounding Totem"] = GetSpellInfo(8177)
	local spellNatureResistanceTotem = GetSpellInfo(25574)
	local spellSentryTotem = GetSpellInfo(6495)
	local spellWindfuryTotem = GetSpellInfo(8512)
	local spellWrathOfAirTotem = GetSpellInfo(3738)
	AutoBarCategoryList["Spell.Totem.Air"] = AutoBarSpells:new(
			"Spell.Totem.Air", spellIconList["Grounding Totem"], {
			"SHAMAN", spellNameList["Grounding Totem"],
			"SHAMAN", spellNatureResistanceTotem,
			"SHAMAN", spellSentryTotem,
			"SHAMAN", spellWindfuryTotem,
			"SHAMAN", spellWrathOfAirTotem,
			})

	local spellFireNovaTotem, spellFireNovaTotemIcon
	spellFireNovaTotem, _, spellFireNovaTotemIcon = GetSpellInfo(25547)
	local spellFireElementalTotem = GetSpellInfo(2894)
	local spellFlametongueTotem = GetSpellInfo(25557)
	local spellFrostResistanceTotem = GetSpellInfo(8181)
	local spellMagmaTotem = GetSpellInfo(25552)
	local spellSearingTotem = GetSpellInfo(25533)
	local spellTotemOfWrath = GetSpellInfo(30706)
	AutoBarCategoryList["Spell.Totem.Fire"] = AutoBarSpells:new(
			"Spell.Totem.Fire", spellFireNovaTotemIcon, {
			"SHAMAN", spellFireElementalTotem,
			"SHAMAN", spellFireNovaTotem,
			"SHAMAN", spellFlametongueTotem,
			"SHAMAN", spellFrostResistanceTotem,
			"SHAMAN", spellMagmaTotem,
			"SHAMAN", spellSearingTotem,
			"SHAMAN", spellTotemOfWrath,
			})

	local spellManaTideTotem, spellManaTideTotemIcon
	spellManaTideTotem, _, spellManaTideTotemIcon = GetSpellInfo(16190)
	local spellDiseaseCleansingTotem = GetSpellInfo(8170)
	local spellFireResistanceTotem = GetSpellInfo(8184)
	local spellHealingStreamTotem = GetSpellInfo(25567)
	local spellManaSpringTotem = GetSpellInfo(10496)
	local spellPoisonCleansingTotem = GetSpellInfo(8166)
	AutoBarCategoryList["Spell.Totem.Water"] = AutoBarSpells:new(
			"Spell.Totem.Water", spellManaTideTotemIcon, {
			"SHAMAN", spellDiseaseCleansingTotem,
			"SHAMAN", spellFireResistanceTotem,
			"SHAMAN", spellHealingStreamTotem,
			"SHAMAN", spellManaSpringTotem,
			"SHAMAN", spellManaTideTotem,
			"SHAMAN", spellPoisonCleansingTotem,
			})

	spellNameList["Windfury Weapon"], _, spellIconList["Windfury Weapon"] = GetSpellInfo(8232)
	spellNameList["Earthliving Weapon"] = GetSpellInfo(51730)
	spellNameList["Flametongue Weapon"] = GetSpellInfo(8024)
	spellNameList["Frostbrand Weapon"] = GetSpellInfo(8033)
	spellNameList["Rockbiter Weapon"] = GetSpellInfo(8017)
	AutoBarCategoryList["Spell.Buff.Weapon"] = AutoBarSpells:new(
			"Spell.Buff.Weapon", spellIconList["Windfury Weapon"], {
			"SHAMAN", spellNameList["Windfury Weapon"],
			"SHAMAN", spellNameList["Rockbiter Weapon"],
			"SHAMAN", spellNameList["Frostbrand Weapon"],
			"SHAMAN", spellNameList["Flametongue Weapon"],
			"SHAMAN", spellNameList["Earthliving Weapon"],
			})
	AutoBarCategoryList["Spell.Buff.Weapon"]:SetTargeted("WEAPON")

	spellNameList["First Aid"], _, spellIconList["First Aid"] = GetSpellInfo(27028)
	spellNameList["Alchemy"] = GetSpellInfo(28596)
	spellNameList["BasicCampfire"] = GetSpellInfo(818)
	spellNameList["Blacksmithing"] = GetSpellInfo(29844)
	spellNameList["Cooking"] = GetSpellInfo(33359)
	if (GetLocale() == "deDE") then
		spellNameList["Kochen"] = GetSpellInfo(51296)
		spellNameList["Alchemie"] = GetSpellInfo(51304)
	end
	spellNameList["Disenchant"] = GetSpellInfo(13262)
	spellNameList["Enchanting"] = GetSpellInfo(28029)
	spellNameList["Engineering"] = GetSpellInfo(30350)
	spellNameList["Inscription"] = GetSpellInfo(45357)
	spellNameList["Jewelcrafting"] = GetSpellInfo(28897)
	spellNameList["Leatherworking"] = GetSpellInfo(32549)
	spellNameList["Milling"] = GetSpellInfo(51005)
	spellNameList["Poisons"] = GetSpellInfo(2842)
	spellNameList["Prospecting"] = GetSpellInfo(31252)
	spellNameList["Smelting"] = GetSpellInfo(2656)
	spellNameList["Tailoring"] = GetSpellInfo(26790)
	spellNameList["Runeforging"] = GetSpellInfo(53428)
	local craftList = {
		"*", spellNameList["Alchemy"],
		"*", spellNameList["BasicCampfire"],
		"*", spellNameList["Blacksmithing"],
		"*", spellNameList["Cooking"],
		"*", spellNameList["Disenchant"],
		"*", spellNameList["Enchanting"],
		"*", spellNameList["Engineering"],
		"*", spellNameList["First Aid"],
		"*", spellNameList["Inscription"],
		"*", spellNameList["Jewelcrafting"],
		"*", spellNameList["Leatherworking"],
		"*", spellNameList["Milling"],
		"*", spellNameList["Poisons"],
		"*", spellNameList["Prospecting"],
		"*", spellNameList["Smelting"],
		"*", spellNameList["Tailoring"],
		"DEATHKNIGHT", spellNameList["Runeforging"],
	}
	if (GetLocale() == "deDE") then
		tinsert(craftList, "*")
		tinsert(craftList, spellNameList["Alchemie"])
		tinsert(craftList, "*")
		tinsert(craftList, spellNameList["Kochen"])
	end
	AutoBarCategoryList["Spell.Crafting"] = AutoBarSpells:new(
			"Spell.Crafting", spellIconList["First Aid"], craftList)

	spellNameList["Curse of Tongues"], _, spellIconList["Curse of Tongues"] = GetSpellInfo(1714)
	spellNameList["Faerie Fire"] = GetSpellInfo(770)
	spellNameList["Faerie Fire (Feral)"] = GetSpellInfo(17390)
	spellNameList["Insect Swarm"] = GetSpellInfo(5570)
	spellNameList["Hex of Weakness"] = GetSpellInfo(25470)
	spellNameList["Curse of Agony"] = GetSpellInfo(27218)
	spellNameList["Curse of Doom"] = GetSpellInfo(30910)
	spellNameList["Curse of Exhaustion"] = GetSpellInfo(18223)
	spellNameList["Curse of Recklessness"] = GetSpellInfo(27226)
	spellNameList["Curse of the Elements"] = GetSpellInfo(1490)
	spellNameList["Curse of Weakness"] = GetSpellInfo(702)
	spellNameList["Hamstring"] = GetSpellInfo(25212)
	AutoBarCategoryList["Spell.Debuff.Multiple"] = AutoBarSpells:new(
			"Spell.Debuff.Multiple", spellIconList["Curse of Tongues"], {
			"DRUID", spellNameList["Faerie Fire"],
			"DRUID", spellNameList["Faerie Fire (Feral)"],
			"DRUID", spellNameList["Insect Swarm"],
			"PRIEST", spellNameList["Hex of Weakness"],
			"WARLOCK", spellNameList["Curse of Agony"],
			"WARLOCK", spellNameList["Curse of Doom"],
--			"WARLOCK", spellNameList["Curse of Recklessness"],
			"WARLOCK", spellNameList["Curse of Tongues"],
			"WARLOCK", spellNameList["Curse of the Elements"],
			"WARLOCK", spellNameList["Curse of Weakness"],
			"WARLOCK", spellNameList["Curse of Exhaustion"],
			})

	spellNameList["Slow"], _, spellIconList["Slow"] = GetSpellInfo(20165)
	spellNameList["Scorpid Sting"] = GetSpellInfo(3043)
	spellNameList["Serpent Sting"] = GetSpellInfo(1978)
	spellNameList["Viper Sting"] = GetSpellInfo(3034)
	spellNameList["Wyvern Sting"] = GetSpellInfo(19386)
	spellNameList["Silence"] = GetSpellInfo(15487)
	spellNameList["Blind"] = GetSpellInfo(2094)
	spellNameList["Sap"] = GetSpellInfo(11297)
	AutoBarCategoryList["Spell.Debuff.Single"] = AutoBarSpells:new(
			"Spell.Debuff.Single", spellIconList["Slow"], {
			"HUNTER", spellNameList["Scorpid Sting"],
			"HUNTER", spellNameList["Serpent Sting"],
			"HUNTER", spellNameList["Viper Sting"],
			"HUNTER", spellNameList["Wyvern Sting"],
			"MAGE", spellNameList["Slow"],
--			"PRIEST", spellNameList["Silence"],
			})

	-- ToDo: Deprecate in favor of Spell.Debuff.Single
	local spellWyvernStingIcon
	_, _, spellWyvernStingIcon = GetSpellInfo(27068)
	AutoBarCategoryList["Spell.Sting"] = AutoBarSpells:new(
			"Spell.Sting", spellWyvernStingIcon, {
			"HUNTER", spellNameList["Scorpid Sting"],
			"HUNTER", spellNameList["Serpent Sting"],
			"HUNTER", spellNameList["Viper Sting"],
			"HUNTER", spellNameList["Wyvern Sting"],
			})

	spellNameList["Fishing"], _, spellIconList["Fishing"] = GetSpellInfo(33095)
	AutoBarCategoryList["Spell.Fishing"] = AutoBarSpells:new(
			"Spell.Fishing", spellIconList["Fishing"], {
			"*", spellNameList["Fishing"],
			})

	spellNameList["Seal of Blood"] = GetSpellInfo(31892)
	spellNameList["Seal of Martyr"] = GetSpellInfo(53720)
	spellNameList["Seal of Command"] = GetSpellInfo(20375)
	spellNameList["Seal of Justice"] = GetSpellInfo(20164)
	spellNameList["Seal of Light"], _, spellIconList["Seal of Light"] = GetSpellInfo(20165)
	spellNameList["Seal of Righteousness"] = GetSpellInfo(21084)
	spellNameList["Seal of Corruption"] = GetSpellInfo(53736)
	spellNameList["Seal of Vengeance"] = GetSpellInfo(31801)
	spellNameList["Seal of Wisdom"] = GetSpellInfo(20166)
	AutoBarCategoryList["Spell.Seal"] = AutoBarSpells:new(
			"Spell.Seal", spellIconList["Seal of Light"], {
			"PALADIN", spellNameList["Seal of Blood"],
			"PALADIN", spellNameList["Seal of Martyr"],
			"PALADIN", spellNameList["Seal of Command"],
			"PALADIN", spellNameList["Seal of Justice"],
			"PALADIN", spellNameList["Seal of Light"],
			"PALADIN", spellNameList["Seal of Righteousness"],
			"PALADIN", spellNameList["Seal of Corruption"],
			"PALADIN", spellNameList["Seal of Vengeance"],
			"PALADIN", spellNameList["Seal of Wisdom"],
			})

	local spellTrackHumanoids, spellTrackHumanoidsIcon
	spellTrackHumanoids, _, spellTrackHumanoidsIcon = GetSpellInfo(19883)
	local spellFindFish = GetSpellInfo(43308)
	local spellFindHerbs = GetSpellInfo(2383)
	local spellFindMinerals = GetSpellInfo(2580)
	local spellFindTreasure = GetSpellInfo(2481)
	local spellTrackBeasts = GetSpellInfo(1494)
	local spellTrackDemons = GetSpellInfo(19878)
	local spellTrackDragonkin = GetSpellInfo(19879)
	local spellTrackElementals = GetSpellInfo(19880)
	local spellTrackGiants = GetSpellInfo(19882)
	local spellTrackHidden = GetSpellInfo(19885)
	local spellTrackUndead = GetSpellInfo(19884)
	local spellSenseUndead = GetSpellInfo(5502)
	local spellSenseDemons = GetSpellInfo(5500)
	AutoBarCategoryList["Spell.Track"] = AutoBarSpells:new(
			"Spell.Track", spellTrackHumanoidsIcon, {
			"*", spellFindFish,
			"*", spellFindHerbs,
			"*", spellFindMinerals,
			"*", spellFindTreasure,
			"DRUID", spellTrackHumanoids,
			"HUNTER", spellTrackBeasts,
			"HUNTER", spellTrackDemons,
			"HUNTER", spellTrackDragonkin,
			"HUNTER", spellTrackElementals,
			"HUNTER", spellTrackGiants,
			"HUNTER", spellTrackHidden,
			"HUNTER", spellTrackHumanoids,
			"HUNTER", spellTrackUndead,
			"PALADIN", spellSenseUndead,
			"WARLOCK", spellSenseDemons,
			})

	spellNameList["Snake Trap"], _, spellIconList["Snake Trap"] = GetSpellInfo(34600)
	spellNameList["Explosive Trap"] = GetSpellInfo(27025)
	spellNameList["Frost Trap"] = GetSpellInfo(13809)
	spellNameList["Immolation Trap"] = GetSpellInfo(27023)
	spellNameList["Freezing Trap"] = GetSpellInfo(14311)
	AutoBarCategoryList["Spell.Trap"] = AutoBarSpells:new(
			"Spell.Trap", spellIconList["Snake Trap"], {
			"HUNTER", spellNameList["Explosive Trap"],
			"HUNTER", spellNameList["Frost Trap"],
			"HUNTER", spellNameList["Immolation Trap"],
			"HUNTER", spellNameList["Snake Trap"],
			"HUNTER", spellNameList["Freezing Trap"],
			})

	spellNameList["Flight Form"] = GetSpellInfo(33943)
	spellNameList["Swift Flight Form"] = GetSpellInfo(40120)
	spellNameList["Summon Dreadsteed"], _, spellIconList["Summon Dreadsteed"] = GetSpellInfo(23161)
	spellNameList["Summon Warhorse"] = GetSpellInfo(34769)
	spellNameList["Summon Charger"] = GetSpellInfo(34767)
	spellNameList["Summon Felsteed"] = GetSpellInfo(5784)
	spellNameList["Travel Form"], _, spellIconList["Travel Form"] = GetSpellInfo(783)
	spellNameList["GhostWolf"] = GetSpellInfo(2645)
	AutoBarCategoryList["Misc.Mount.Summoned"] = AutoBarSpells:new(
			"Misc.Mount.Summoned", spellIconList["Summon Dreadsteed"], {
			"PALADIN", spellNameList["Summon Warhorse"],
			"PALADIN", spellNameList["Summon Charger"],
			"WARLOCK", spellNameList["Summon Felsteed"],
			"WARLOCK", spellNameList["Summon Dreadsteed"],
			"DRUID", spellNameList["Travel Form"],
			"DRUID", spellNameList["Flight Form"],
			"DRUID", spellNameList["Swift Flight Form"],
			"SHAMAN", spellNameList["GhostWolf"],
			})
	AutoBarCategoryList["Misc.Mount.Summoned"]:SetNonCombat(true)
end


local customCategoriesVersion = 3
-- Learned new spells etc.  Refresh all categories
function AutoBarCategory:Upgrade()
	if (not AutoBar.db.account.customCategories) then
		AutoBar.db.account.customCategories = {}
	end
	if (not AutoBar.db.account.customCategoriesVersion) then
		local newCustomCategories = {}
		local categoryKey
		local customCategories = AutoBar.db.account.customCategories
		for index, customCategoryDB in pairs(customCategories) do
			customCategoryDB.name = customCategoryDB.name:gsub("%.", "")
			categoryKey = AutoBarCustom:GetCustomKey(customCategoryDB.name)
			customCategoryDB.categoryKey = categoryKey
			newCustomCategories[categoryKey] = customCategoryDB
		end
		AutoBar.db.account.customCategories = newCustomCategories
		AutoBar.db.account.customCategoriesVersion = 1
	end
	if (AutoBar.db.account.customCategoriesVersion < customCategoriesVersion) then
		local customCategories = AutoBar.db.account.customCategories
		local newCustomCategories = {}
		local categoryKey
		if (AutoBar.db.account.customCategoriesVersion < 3) then
			for index, customCategoryDB in pairs(customCategories) do
				customCategoryDB.name = AutoBar:GetValidatedName(customCategoryDB.name)
				categoryKey = AutoBarCustom:GetCustomKey(customCategoryDB.name)
				if (categoryKey ~= index) then
					customCategoryDB.categoryKey = categoryKey
					AutoBar.Class.Button:RenameCategory(index, categoryKey)
				end
				if (customCategoryDB.categoryKey ~= categoryKey) then
					AutoBar.Class.Button:RenameCategory(customCategoryDB.categoryKey, categoryKey)
					customCategoryDB.categoryKey = categoryKey
				end
				newCustomCategories[categoryKey] = customCategoryDB
			end
			AutoBar.db.account.customCategories = newCustomCategories
			AutoBar.db.account.customCategoriesVersion = 3
		end
	end
end

-- Learned new spells etc.  Refresh all categories
function AutoBarCategory:UpdateCategories()
	for categoryKey, categoryInfo in pairs(AutoBarCategoryList) do
		categoryInfo:Refresh()
	end
end


function AutoBarCategory:UpdateCustomCategories()
	local customCategories = AutoBar.db.account.customCategories

	for categoryKey, customCategoriesDB in pairs(customCategories) do
		assert(customCategoriesDB and (categoryKey == customCategoriesDB.categoryKey), "customCategoriesDB nil or bad categoryKey")
		if (not AutoBarCategoryList[categoryKey]) then
			AutoBarCategoryList[categoryKey] = AutoBarCustom:new(customCategoriesDB)
		end
	end

	for categoryKey, categoryInfo in pairs(AutoBarCategoryList) do
		categoryInfo:Refresh()

		if (categoryInfo.customKey and not customCategories[categoryKey]) then
			AutoBarCategoryList[categoryKey] = nil
		end
	end

	for categoryKey in pairs(AutoBar.categoryValidateList) do
		AutoBar.categoryValidateList[categoryKey] = nil
	end
	for categoryKey, categoryInfo in pairs(AutoBarCategoryList) do
		AutoBar.categoryValidateList[categoryKey] = categoryInfo.description
	end
end


--[[
/dump AutoBarCategoryList["Consumable.Cooldown.Potion.Health.PvP"]
/dump AutoBarCategoryList["Spell.Crafting"].castList
/dump AutoBarCategoryList["Consumable.Buff Group.Caster.Self"]
/dump LibStub("LibPeriodicTable-3.1"):GetSetTable("Consumable.Buff Group.Caster.Self")
/script for itemId, value in LibStub("LibPeriodicTable-3.1"):IterateSet("Consumable.Buff Group.Caster.Self") do AutoBar:Print(itemId .. " " .. value); end
--]]
