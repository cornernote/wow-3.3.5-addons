--
-- AutoBarClassButton
-- Copyright 2007+ Toadkiller of Proudmoore.
-- A lot of code borrowed from Bartender3
--
-- Layout Buttons for AutoBar
-- Buttons are contained by AutoBar.Class.Bar
-- http://code.google.com/p/autobar/
--

local AutoBar = AutoBar
local spellIconList = AutoBar.spellIconList

local REVISION = tonumber(("$Revision: 748 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local AceOO = AceLibrary("AceOO-2.0")
local L = AutoBar.locale
local LBF = LibStub("LibButtonFacade", true)
local LibKeyBound = LibStub("LibKeyBound-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local _G = getfenv(0)
local _

-- Basic Button with textures, highlighting, keybindText, tooltips etc.
AutoBar.Class.Button = AceOO.Class(AutoBar.Class.BasicButton)


local function onAttributeChangedFunc(button)
	local self = button.class
	self:UpdateButton()
end

local function onDragStartFunc(button)
	local fromObject = button.class
	if (AutoBar.moveButtonsMode) then
		ClearCursor()
		SetCursor("BUY_CURSOR")
		AutoBar:SetDraggingObject(fromObject)
		fromObject:SetDragCursor()
	else
		local buttonDB = AutoBar:GetButtonDB(fromObject.buttonDB.buttonKey)
--print("onDragStartFunc", fromObject.buttonName, "arg1", arg1, "arg2", arg2, "buttonDB.drag", buttonDB.drag)
		if (buttonDB.drag) then
			ClearCursor()
			AutoBar:SetDraggingObject(nil)
			fromObject:SetDragCursor()
		end
	end
end

local function onReceiveDragFunc(button)
	local toObject = button.class
--print("onReceiveDragFunc " .. tostring(toObject.buttonName) .. " arg1 " .. tostring(arg1) .. " arg2 " .. tostring(arg2))
	toObject:DropObject()
	SetCursor(nil)
end

local function OnUpdateFunc(button, elapsed)
	local self = button.class
	self.elapsed = self.elapsed + elapsed
	if (self.elapsed > 0.2) then
		self:OnUpdate(self.elapsed)
		self.elapsed = 0
	end
end

local function menuFunc(object, unit, button)
	local self = object.class
--AutoBar:Print("menuFunc " .. tostring(object) .. " object.class " .. tostring(object.class) .. " button " .. tostring(button))
	self:ShowButtonOptions()
end

function AutoBar.Class.Button.prototype:init(parentBar, buttonDB)
	AutoBar.Class.Button.super.prototype.init(self)

	self.showgrid = 0
	self.flashing = 0
	self.flashtime = 0
	self.outOfRange = nil
	self.elapsed = 0
	self.action = 0

	self.parentBar = parentBar
	self.buttonDB = buttonDB
	self.buttonName = buttonDB.buttonKey
	self.buttonDBIndex = buttonDB.order
	self:CreateButtonFrame()
	self:Refresh(parentBar, buttonDB)
end

-- Refresh the category list
function AutoBar.Class.Button.prototype:Refresh(parentBar, buttonDB)
	self.parentBar = parentBar
	if (buttonDB ~= self.buttonDB) then
		self.buttonDB = buttonDB
		assert(self.buttonName == buttonDB.buttonKey, "AutoBar.Class.Button.prototype:Refresh Button Name changed")
		self.buttonDBIndex = buttonDB.order
	end
	self.buttonName = buttonDB.buttonKey
	if (self.buttonDB.hasCustomCategories) then
		for categoryIndex, categoryKey in ipairs(self.buttonDB) do
			self[categoryIndex] = categoryKey
		end

		-- Clear out excess if any
		for i = # self.buttonDB + 1, # self, 1 do
			self[i] = nil
		end
	end
end


-- Disable the Button
function AutoBar.Class.Button.prototype:Disable()
--	self.frame:SetAttribute("category", nil)
--	self.frame:SetAttribute("itemId", nil)
--	self.frame:Hide()
--AutoBar:Print("AutoBar.Class.Button.prototype:Disable " .. tostring(self.buttonName))
end

-- Return the name of the global frame of the button.  Keybinds are made to it.
function AutoBar.Class.Button.prototype:GetButtonFrameName()
	return self.buttonDB.buttonKey .. "Frame"
end

function AutoBar.Class.Button.prototype:GetButtonBinding()
	return self.buttonDB.buttonKey .. "_X"
end


--
-- LibKeyBound Handlers
--

function AutoBar.Class.Button:GetHotkey()
	local frame = self
	local key1 = GetBindingKey(frame.class.buttonName .. "_X")
	local key = LibKeyBound:ToShortKey(key1)
--AutoBar:Print("AutoBar.Class.Button.prototype:GetHotkey key1 " .. tostring(key1) .. " -> " .. tostring(key))-- .. " buttonName " .. tostring(frame.class.buttonName))
	return key
end

function AutoBar.Class.Button:GetActionName()
	local frame = self
	local buttonKey = frame.class.buttonDB.buttonKey
	return (L[buttonKey] or "???") .. " (" .. frame.class:GetButtonFrameName() .. ")"
end

function AutoBar.Class.Button:SetKey(key)
	local button = self.class
	local buttonKey = button.buttonDB.buttonKey
	local buttonFrameName = button:GetButtonFrameName()
	if (key) then
--		SetOverrideBindingClick(AutoBar.frame, false, key, buttonFrameName)
		local buttonBinding = button:GetButtonBinding()
		if (buttonBinding) then
--AutoBar:Print("AutoBar.Class.Button.prototype:SetKey buttonBinding " .. tostring(buttonBinding) .. " -> " .. tostring(key))-- .. " buttonName " .. tostring(frame.class.buttonName))
			SetBinding(key, buttonBinding)
--AutoBar:Print("AutoBar.Class.Button.prototype:SetKey buttonBinding " .. tostring(buttonBinding) .. " <- " .. tostring(GetBindingKey(buttonBinding)))-- .. " buttonName " .. tostring(frame.class.buttonName))
		end
		button:BindingsUpdate()
	end
end

function AutoBar.Class.Button:ClearBindings()
	local button = self.class
	local buttonFrameName = button:GetButtonFrameName()
	local buttonBinding = button:GetButtonBinding()
	while GetBindingKey(buttonBinding) do
		SetBinding(GetBindingKey(buttonBinding), nil)
	end
	button:BindingsUpdate()
end

function AutoBar.Class.Button:GetBindings()
	local button = self.class
	local buttonBinding = button:GetButtonBinding()
	local keys
	if (buttonBinding) then
		for i = 1, select('#', GetBindingKey(buttonBinding)) do
			local hotKey = select(i, GetBindingKey(buttonBinding))
			if keys then
				keys = keys .. ', ' .. GetBindingText(hotKey, 'KEY_')
			else
				keys = GetBindingText(hotKey, 'KEY_')
			end
		end
	end
	return keys
end
--/dump _G["AutoBarButtonTrinket2_X"]

function AutoBar.Class.Button.prototype:BindingsUpdate()
	local buttonFrameName = self:GetButtonFrameName()
	local buttonBinding = self:GetButtonBinding()
	for i = 1, select('#', GetBindingKey(buttonBinding)) do
		local hotKey = select(i, GetBindingKey(buttonBinding))
--AutoBar:Print("AutoBar.Class.Button.prototype:BindingsUpdate hotKey " .. tostring(hotKey) .. " buttonFrameName " .. tostring(buttonFrameName))
		SetOverrideBindingClick(AutoBar.frame, false, hotKey, buttonFrameName)
	end
--AutoBar:Print("AutoBar.Class.Button.prototype:BindingsUpdate -> buttonFrameName " .. tostring(buttonFrameName))
	self:UpdateHotkeys()
end


-- Update the keybinds for the Button.
-- Copied from Bartender3
-- Create Override Bindings from the Blizzard bindings to our dummy binds in Bindings.xml.
-- These do not clash with the real frames to bind to, so all is happy.
function AutoBar.Class.Button:UpdateBindings(buttonName, buttonFrameName)
	local key1, key2 = GetBindingKey(buttonName .. "_X")
	if (key1) then
--AutoBar:Print("AutoBar.Class.Button.prototype:UpdateBindings key1 " .. tostring(key1) .. " key2 " .. tostring(key2) .. " buttonName " .. tostring(buttonName))
		SetOverrideBindingClick(AutoBar.frame, false, key1, buttonFrameName)
	end
	if (key2) then
		SetOverrideBindingClick(AutoBar.frame, false, key2, buttonFrameName)
	end
end
--[[
/script SetOverrideBindingClick(AutoBarButtonTrinket1Frame, false, "U", "AutoBarButtonTrinket1Frame")
/script ClearOverrideBindings(AutoBarButtonTrinket1Frame)
/script AutoBarButtonTrinket2Frame.class:UpdateHotkeys()
/dump AutoBarButtonTrinket2Frame:GetScript("OnUpdate")
--]]


local function funcOnEnter(self)
	if (self.GetHotkey and AutoBar.keyBoundMode) then
		LibKeyBound:Set(self)
	end

	local noTooltip = not (AutoBar.db.account.showTooltip and self.needsTooltip or AutoBar.moveButtonsMode)
	noTooltip = noTooltip or (InCombatLockdown() and not AutoBar.db.account.showTooltipCombat)
	if (noTooltip) then
		self.UpdateTooltip = nil
		GameTooltip:Hide()
	else
		AutoBar.Class.BasicButton.TooltipShow(self)
	end
end

local function funcOnLeave(self)
	GameTooltip:Hide()
end

function AutoBar.Class.Button.prototype:CreateButtonFrame()
	local name = self:GetButtonFrameName()
	local frame = CreateFrame("Button", name, self.parentBar.frame, "ActionButtonTemplate SecureActionButtonTemplate SecureHandlerBaseTemplate")
	self.frame = frame

	local buttonWidth = self.parentBar.buttonWidth or 36
	local buttonHeight = self.parentBar.buttonHeight or 36
	frame:ClearAllPoints()
	frame:SetWidth(buttonWidth)
	frame:SetHeight(buttonHeight)

	-- Support selfcast and focuscast
	frame:SetAttribute("checkselfcast", true)
	frame:SetAttribute("checkfocuscast", true)

	frame.class = self
	frame:RegisterForClicks("AnyUp")
	frame:RegisterForDrag("LeftButton", "RightButton")

	frame:SetScript("OnUpdate", OnUpdateFunc)

	frame:SetScript("OnEnter", funcOnEnter)
	frame:SetScript("OnLeave", funcOnLeave)

---	frame:SetScript("OnAttributeChanged", onAttributeChangedFunc)
	frame:SetScript("OnDragStart", onDragStartFunc)
	frame:SetScript("OnReceiveDrag", onReceiveDragFunc)
---	frame:SetScript("PostClick", self.PostClick)

	frame.icon = _G[("%sIcon"):format(name)]
	frame.border = _G[("%sBorder"):format(name)]
	frame.cooldown = _G[("%sCooldown"):format(name)]
	frame.macroName = _G[("%sName"):format(name)]
	frame.hotKey = _G[("%sHotKey"):format(name)]
	frame.count = _G[("%sCount"):format(name)]
	frame.flash = _G[("%sFlash"):format(name)]
	if (LBF) then
		local group = self.parentBar.frame.LBFGroup
		frame.LBFButtonData = {
			Border = frame.border,
			Cooldown = frame.cooldown,
			Count = frame.count,
			Flash = frame.flash,
			HotKey = frame.hotKey,
			Icon = frame.icon,
			Name = frame.macroName,
		}
		group:AddButton(frame, frame.LBFButtonData)
	end
	frame.normalTexture = frame:GetNormalTexture()

	local frameStrata = AutoBar.barLayoutDBList[self.parentBar.barKey].frameStrata
	frame:SetFrameStrata(frameStrata)

	frame.GetHotkey = AutoBar.Class.Button.GetHotkey
	frame.GetActionName = AutoBar.Class.Button.GetActionName
	frame.SetKey = AutoBar.Class.Button.SetKey
	frame.ClearBindings = AutoBar.Class.Button.ClearBindings
	frame.GetBindings = AutoBar.Class.Button.GetBindings

	self:UpdateButton()
	self:EventsEnable()

--	self:RegisterBarEvents()
end

-- Handle a click on a popped up button
function AutoBar.Class.Button.prototype.OnClick(object, button, down)
	local self = object.class
--AutoBar:Print("OnClick " .. self.buttonName .. " " .. tostring(object) .. " object.class " .. tostring(object.class) .. " button " .. tostring(button) .. " down " .. tostring(down))
	if (down) then
		object:SetChecked(1)
		return true
	else
		object:SetChecked(0)
	end
end



-- For a given itemId, find and shuffle stacks of it to targetBag, targetSlot
-- Return true if successful
-- Return nil if not
function AutoBar.Class.Button:ShuffleItem(itemId, targetBag, targetSlot, isNewItem)
	local _, itemCount, locked = GetContainerItemInfo(targetBag, targetSlot)
	local totalCount = GetItemCount(itemId)
	if (not itemCount and totalCount > 0) then
		AutoBarSearch.stuff:ScanCombat()
	end

--	if (isNewItem) then
--AutoBar:Print("ShuffleItem isNewItem " .. " itemId " .. tostring(itemId) .. " itemCount " .. tostring(itemCount) .. " locked " .. tostring(locked))
--	end

	if ((itemCount == 1 and totalCount > 1) or (not itemCount and totalCount > 0) or (isNewItem and totalCount > 0)) then
		-- Shuffle in another stack
		local index = AutoBarSearch.found:GetTotalSlots(itemId)
--AutoBar:Print("ShuffleItem start index " .. tostring(self.class.buttonName) .. " itemId " .. tostring(itemId) .. " index " .. tostring(index))
		if (index and index > 0) then
			repeat
				local bag, slot, spell = AutoBarSearch.found:GetItemData(itemId, index)
--AutoBar:Print("ShuffleItem checking  index " .. tostring(index) .. " bag " .. tostring(bag) .. " slot " .. tostring(slot) .. " spell " .. tostring(spell))
				if (bag and slot) then
					local _, itemCount, locked = GetContainerItemInfo(bag, slot)
					if (itemCount and itemCount > 0) then
						ClearCursor()
						PickupContainerItem(bag, slot)
						PickupContainerItem(targetBag, targetSlot)
						AutoBarSearch.found:ClearItemData(itemId, index)
--AutoBar:Print("ShuffleItem actually swapped index " .. tostring(index) .. " bag " .. tostring(bag) .. " slot " .. tostring(slot) .. " locked " .. tostring(locked) .. " targetBag " .. tostring(targetBag) .. " targetSlot " .. tostring(targetSlot))
						return true
					end
				end
				index = index - 1
--AutoBar:Print("ShuffleItem done with  index " .. tostring(index) .. " bag " .. tostring(bag) .. " slot " .. tostring(slot) .. " spell " .. tostring(spell))
			until index <= 0
		else
			-- Redo scan for item only then call ShuffleItem again
		end
		return true
	elseif (totalCount == 1) then
		-- Redo scan for item only then call ShuffleItem again
	end

	-- Nothing left to shuffle in
	return nil
end

-- For a given itemId, find and shuffle stacks of it to targetBag, targetSlot
-- Return true if successful
-- Return nil if not
function AutoBar.Class.Button.prototype:SwitchItem(buttonItemId, targetBag, targetSlot)
	local popupHeader = self.frame.popupHeader
	if (popupHeader) then
		for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
			local frame = popupButton.frame
			local itemType = self.frame:GetAttribute("type")
			if (itemType == "item") then
				local itemId = frame:GetAttribute("itemId")
				local isUsable, notEnoughMana = IsUsableItem(itemId)
				if (isUsable) then
					-- It is usable so we have some in inventory so switch
					local didShuffle = AutoBar.Class.Button:ShuffleItem(itemId, targetBag, targetSlot, true)
					if (didShuffle) then
						local texture
						_,_,_,_,_,_,_,_,_, texture = GetItemInfo(tonumber(itemId))
						self.frame.icon:SetTexture(texture)
						_,_,_,_,_,_,_,_,_, texture = GetItemInfo(tonumber(buttonItemId))
						frame.icon:SetTexture("itemId", buttonItemId)
						return true
	--					self:UpdateButton()
	--					popupButton:UpdateButton()
					end
				end
			end
		end
	end
	return false
end

-- Handle shuffle buttons
function AutoBar.Class.Button.prototype:PostClick(mouseButton, down)
	local self = self.class

	if (self.buttonDB.shuffle and InCombatLockdown()) then
		local itemType = self.frame:GetAttribute("type")
		if (itemType == "item") then
			local itemId = self.frame:GetAttribute("itemId")
			local itemLink = self.frame:GetAttribute("item")
			local targetBag, targetSlot = strmatch(itemLink, "^(%d+)%s+(%d+)$")
			if (IsConsumableItem(itemId) and targetBag and targetSlot) then
				local didShuffle = AutoBar.Class.Button:ShuffleItem(itemId, targetBag, targetSlot)
				if (not didShuffle) then
--AutoBar:Print("\nAutoBar.Class.PopupButton.prototype:PostClick did not shuffle, switchItem itemId " .. tostring(itemId) .. " targetBag " .. tostring(targetBag) .. " targetSlot " .. tostring(targetSlot))
					-- Switch to next item
					local didSwitch = self:SwitchItem(itemId, targetBag, targetSlot)
--AutoBar:Print("\nAutoBar.Class.PopupButton.prototype:PostClick didSwitch " .. tostring(didSwitch) .. " targetBag " .. tostring(targetBag) .. " targetSlot " .. tostring(targetSlot))
				end
			end
		end
	end
end
-- /dump AutoBarSearch.found:GetTotalSlots(2723)
-- /dump AutoBarSearch.found:GetList()[2723]
-- /dump IsUsableItem(2723) Pinot Noir
-- /dump IsUsableItem(32902) Bottled Nethergon
-- /dump IsUsableItem("1 6")

local borderMoveActive = {r = 0, g = 1.0, b = 0, a = 1.0}
local borderMoveDisabled = {r = 1.0, g = 0, b = 0, a = 1.0}
local borderMoveEmpty = {r = 0, g = 0, b = 1.0, a = 1.0}

-- Returns Icon texture, borderColor
-- Nil borderColor hides border
function AutoBar.Class.Button.prototype:GetIconTexture()
	local frame = self.frame
	local texture, borderColor = AutoBar.Class.Button.super.prototype.GetIconTexture(self, frame)

	local category = frame:GetAttribute("category")
	if (AutoBar.moveButtonsMode) then
		if (texture) then
			borderColor = borderMoveActive
		else
			if (category and AutoBarCategoryList[category]) then
				texture = AutoBarCategoryList[category].texture
				borderColor = borderMoveEmpty
			else
				texture = "Interface\\Icons\\INV_Misc_Gift_01"
				borderColor = borderMoveDisabled
			end
		end
	elseif ((AutoBar.db.account.showEmptyButtons or self.buttonDB.alwaysShow) and not texture) then
		if (category and AutoBarCategoryList[category]) then
			texture = AutoBarCategoryList[category].texture
		end
	end

	return texture, borderColor
end

--/script AutoBar.buttonList["AutoBarButtonTrinket1"].frame.icon:SetTexture("Interface\\Buttons\\UI-Quickslot2")
--/script AutoBar.buttonList["AutoBarButtonTrinket1"].frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QirajiCrystal_05")
--/dump AutoBar.buttonList["AutoBarButtonTrinket1"].frame.icon:GetTexture()
--/script AutoBar.buttonList["AutoBarButtonTrinket1"]:UpdateIcon()

function AutoBar.Class.Button.prototype:UpdateIcon()
	local frame = self.frame
	local texture, borderColor = self:GetIconTexture()

	if (texture) then
		frame.icon:SetTexture(texture)
		frame.icon:Show()
		frame.tex = texture
	else
--		frame:Hide()
	end

	if (borderColor) then
		frame.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		frame.border:Show()
	else
		frame.border:Hide()
	end
end


function AutoBar.Class.Button.prototype:UpdateButton()
	local frame = self.frame
	self:UpdateIcon()
	self:UpdateCount()
	self:UpdateHotkeys()
	local itemType = frame:GetAttribute("type")
	if (AutoBar.moveButtonsMode) then
--		self:UnregisterButtonEvents()
		self:ShowButton()
	elseif (itemType) then
--		self:RegisterButtonEvents()
		self:UpdateUsable()
		self:UpdateCooldown()
		self:ShowButton()
		frame:SetScript("OnUpdate", OnUpdateFunc)
	else
		frame:SetScript("OnUpdate", nil)
--		self:UnregisterButtonEvents()

		frame.cooldown:Hide()
		self:HideButton()
	end

	if (AutoBar.moveButtonsMode) then
		frame.macroName:SetText(AutoBarButton:GetDisplayName(self.buttonDB))
--	elseif self.parentBar.sharedLayoutDB.showMacrotext then
--		frame.macroName:SetText(GetActionText(self.action))
	else
		frame.macroName:SetText("")
	end

	local buttonDB = self.buttonDB
	if (buttonDB.drop) then
		frame:RegisterEvent("ACTIONBAR_SHOWGRID")
		frame:RegisterEvent("ACTIONBAR_HIDEGRID")
	else
		frame:UnregisterEvent("ACTIONBAR_SHOWGRID")
		frame:UnregisterEvent("ACTIONBAR_HIDEGRID")
	end
end

function AutoBar.Class.Button.prototype:UpdateHotkeys()
	if (AutoBar.db.account.showHotkey) then
		self.frame.hotKey:Show()
	else
		self.frame.hotKey:Hide()
	end

	local frame = self.frame
	local buttonBinding = self:GetButtonBinding()
	local key
	if (buttonBinding) then
		key = GetBindingKey(buttonBinding)
	else
		key = LibKeyBound.Binder:GetBindings(frame)
	end
	if (key) then
		frame.hotKey:SetText(LibKeyBound:ToShortKey(GetBindingText(key, "KEY_", 1)))
	else
		frame.hotKey:SetText("")
	end
end


-- Set cooldown for the button and popups if any
function AutoBar.Class.Button.prototype:UpdateCooldown()
	AutoBar.Class.Button.super.prototype.UpdateCooldown(self)

	local popupHeader = self.frame.popupHeader
	if (popupHeader) then
		for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
			popupButton:UpdateCooldown()
		end
	end
end
--/script local start, duration, enabled = GetSpellCooldown("Summon Water Elemental", BOOKTYPE_SPELL); AutoBar:Print("start " .. tostring(start) .. " duration " .. tostring(duration) .. " enabled " .. tostring(enabled))

-- Set count for the button and popups if any
function AutoBar.Class.Button.prototype:UpdateCount()
	AutoBar.Class.Button.super.prototype.UpdateCount(self)
	if (AutoBar.db.account.showCount) then
		local popupHeader = self.frame.popupHeader
		if (popupHeader) then
			for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
				popupButton:UpdateCount()
			end
		end
	end
end

function AutoBar.Class.Button.prototype:UpdateUsable()
	local itemType = self.frame:GetAttribute("type")
	local category = self.frame:GetAttribute("category")
	if (itemType) then
		AutoBar.Class.Button.super.prototype.UpdateUsable(self)

		local popupHeader = self.frame.popupHeader
		if (popupHeader) then
			for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
				popupButton:UpdateUsable()
			end
		end
	elseif (category and (AutoBar.moveButtonsMode or AutoBar.db.account.showEmptyButtons or self.buttonDB.alwaysShow)) then
		self.frame.icon:SetVertexColor(0.4, 0.4, 0.4, 1)
	end
end
--[[
/script AutoBar.buttonList["AutoBarButtonQuest"].frame.icon:SetVertexColor(1.0, 1.0, 1.0)
/dump AutoBar.buttonList["AutoBarButtonTrinket1"].frame.hotKey:SetVertexColor(1.0, 1.0, 1.0)
--]]


--/dump AutoBar.buttonList["AutoBarButtonCat"]:IsActive()

function AutoBar.Class.Button.prototype:IsActive()
	if (not self.buttonDB.enabled) then
		return false
	end
	if (AutoBar.db.account.showEmptyButtons or AutoBar.moveButtonsMode or self.buttonDB.alwaysShow or not self.parentBar.sharedLayoutDB.collapseButtons) then --AutoBar.keyBoundMode or
		return true
	end
	local itemType = self.frame:GetAttribute("type")
	if (itemType) then
--AutoBar:Print("AutoBar.Class.Button.prototype:IsActive itemId " .. tostring(itemId))
		local category = self.frame:GetAttribute("category")
		local categoryInfo = AutoBarCategoryList[category]
		if (categoryInfo and categoryInfo.battleground and not AutoBar.inBG) then
			return false
		end

		local count = 0

		if (itemType == "item") then
			local itemId = self.frame:GetAttribute("itemId")
			count = GetItemCount(tonumber(itemId))
			if (count == 0) then
				local sortedItems = AutoBarSearch.sorted:GetList(self.buttonName)
				if (sortedItems) then
					local noPopup = self.buttonDB.noPopup
					local nItems = # sortedItems
					if (nItems > 1 and not noPopup) then
						count = 1
--AutoBar:Print("AutoBar.Class.Button.prototype:IsActive nItems " .. tostring(nItems))
					end
				end
				if (self.frame:GetAttribute("type2") == "spell") then
					count = 1
				end
			end
		elseif (itemType == "macro") then
			if (self.macroActive) then
				count = 1
			end
		elseif (itemType == "spell") then
			--ToDo: Reagent based count
--			local spellName = self.frame:GetAttribute("spell")
			count = 1
		end
		return count > 0
	elseif (self.macroTexture) then
		return true
	else
		return false
	end
end

local bookTypeSpell = BOOKTYPE_SPELL

local function FindSpell(spellName, bookType)
	local i, s
	local found = false;
	for i = 1, MAX_SKILLLINE_TABS do
		local name, texture, offset, numSpells = GetSpellTabInfo(i)
		if (not name) then
			break
		end
		for s = offset + 1, offset + numSpells do
			local	spell, rank = GetSpellName(s, bookType)
			if (spell == spellName) then
				found = true
			end
			if (found and spell ~=spellName) then
				return s-1
			end
		end
	end
	if (found) then
		return s
	end
	return nil
end

-- Set Cursor based on the type settings
function AutoBar.Class.Button.prototype:SetDragCursor()
	local itemType = self.frame:GetAttribute("type")
	if (itemType) then
		if (itemType == "item") then
			local itemLink = self.frame:GetAttribute("item")
			PickupItem(itemLink)
		elseif (itemType == "action") then
			local action = self.frame:GetAttribute("action1")
			PickupAction(action)
		elseif (itemType == "macro") then
			local macroIndex = self.frame:GetAttribute("macro")
			PickupMacro(macroIndex)
		elseif (itemType == "spell") then
			local spellName = self.frame:GetAttribute("spell")
			local spellId = FindSpell(spellName, bookTypeSpell)
			PickupSpell(spellId, bookTypeSpell)
		end
	end
end

local ATTACK_BUTTON_FLASH_TIME = ATTACK_BUTTON_FLASH_TIME

function AutoBar.Class.Button.prototype:OnUpdate(elapsed)
	if (not self.frame.tex) then
		self:UpdateIcon()
	end

	if ( self.flashing == 1 ) then
		self.flashtime = self.flashtime - elapsed;
		if ( self.flashtime <= 0 ) then
			local overtime = -self.flashtime;
			if ( overtime >= ATTACK_BUTTON_FLASH_TIME ) then
				overtime = 0;
			end
			self.flashtime = ATTACK_BUTTON_FLASH_TIME - overtime;

			local flashTexture = self.frame.flash
			if ( flashTexture:IsVisible() ) then
				flashTexture:Hide()
			else
				flashTexture:Show()
			end
		end
	end

	local frame = self.frame
	local itemType = frame:GetAttribute("type")
	local inRange = 1
	if (itemType == "item") then
		local itemId = frame:GetAttribute("itemId")
		if (ItemHasRange(itemId)) then
			inRange = IsItemInRange(itemId, "target")
		end
	elseif (itemType == "spell") then
		local spellName = frame:GetAttribute("spell")
		if (SpellHasRange(spellName)) then
			inRange = IsSpellInRange(spellName, "target")
		end
	end

	local spellName = frame:GetAttribute("spell")

	if (frame.outOfRange ~= (inRange == 0)) then
		frame.outOfRange = not frame.outOfRange
print(frame:GetName(), frame.outOfRange)
		self:UpdateUsable()
	end


	if (not self.updateTooltip) then
		return
	end

	self.updateTooltip = self.updateTooltip - elapsed
	if (self.updateTooltip > 0) then
		return
	end
end

function AutoBar.Class.Button.prototype:StartFlash()
	self.flashing = 1
	self.flashtime = 0
end

function AutoBar.Class.Button.prototype:StopFlash()
	self.flashing = 0
	self.frame.flash:Hide()
end

function AutoBar.Class.Button.prototype:ShowButton()
	local frame = self.frame

	if (LBF) then
		local frame = self.frame
		local backdrop, gloss = LBF:GetBackdropLayer(frame), LBF:GetGlossLayer(frame)
		if (backdrop) then
			backdrop:Show()
		end
		if (gloss) then
			gloss:Show()
		end
		local popupHeader = frame.popupHeader
		if (popupHeader) then
			for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
				frame = popupButton.frame
				local backdrop, gloss = LBF:GetBackdropLayer(frame), LBF:GetGlossLayer(frame)
				if (backdrop) then
					backdrop:Show()
				end
				if (gloss) then
					gloss:Show()
				end
			end
		end
	end
end

function AutoBar.Class.Button.prototype:HideButton()
	local frame = self.frame


	if (LBF) then
		local backdrop, gloss = LBF:GetBackdropLayer(self), LBF:GetGlossLayer(self)
		if (backdrop) then
			backdrop:Hide()
		end
		if (gloss) then
			gloss:Hide()
		end
		local popupHeader = frame.popupHeader
		if (popupHeader) then
			for popupButtonIndex, popupButton in pairs(popupHeader.popupButtonList) do
				frame = popupButton.frame
				local backdrop, gloss = LBF:GetBackdropLayer(frame), LBF:GetGlossLayer(frame)
				if (backdrop) then
					backdrop:Hide()
				end
				if (gloss) then
					gloss:Hide()
				end
			end
		end
	end
end

function AutoBar.Class.Button.prototype:ShowGrid(override)
--	local frame = self.frame
--	if not override then
--		self.showgrid = self.showgrid + 1
--	end
--	frame.icon:Hide()
--	frame.normalTexture:Show()
end

function AutoBar.Class.Button.prototype:HideGrid(override)
--	local frame = self.frame
--	if (not override) then
--		self.showgrid = self.showgrid - 1
--	end
--	local itemType = self.frame:GetAttribute("type")
--	if (self.showgrid == 0 and not itemType) then
--		if (not self.parentBar.sharedLayoutDB.showGrid) then
--			frame.normalTexture:Hide()
--		end
--	end
--	frame.icon:Show()
end

function AutoBar.Class.Button.prototype:MoveButtonsModeOn()
	local frame = self.frame
	frame:SetScript("OnDragStart", onDragStartFunc)
	frame:SetScript("OnReceiveDrag", onReceiveDragFunc)
	frame.macroName:SetText(AutoBarButton:GetDisplayName(self.buttonDB))
	frame:SetAttribute("type2", "menu")
	frame.menu = menuFunc
	frame:Show()
end

function AutoBar.Class.Button.prototype:MoveButtonsModeOff()
	local frame = self.frame
	frame:SetScript("OnDragStart", nil)
	frame:SetScript("OnReceiveDrag", nil)
	frame.macroName:SetText("")
	frame.menu = nil
	if (self.buttonDB.hide or self.parentBar.sharedLayoutDB.hide) then
		frame:Hide()
	elseif (self:IsActive()) then
--AutoBar:Print("AutoBar.Class.Button.prototype:MoveButtonsModeOff self:IsActive() " .. tostring(self:IsActive()) .. " self.buttonName " .. tostring(self.buttonName))
		frame:Show()
	else
		frame:Hide()
	end
end

function AutoBar.Class.Button.prototype:ShowButtonOptions()
	if InCombatLockdown() then
		assert(false, "In Combat with Move Button code. ShowButtonOptions")
	end
	self.optionsTable = AutoBar:CreateBarButtonOptions(nil, nil, self.buttonName, self.optionsTable)
--AutoBar:Print("AutoBar.Class.Button.prototype:ShowButtonOptions self.optionsTable " .. tostring(self.optionsTable) .. " self.buttonName " .. tostring(self.buttonName))
	dewdrop:Open(self.frame, 'children', function() dewdrop:FeedAceOptionsTable(self.optionsTable) end, 'cursorX', true, 'cursorY', true)
end


function AutoBar.Class.Button.prototype:RegisterBarEvents()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "BaseEventHandler")
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", "BaseEventHandler")
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", "BaseEventHandler")
	self:RegisterEvent("UPDATE_BINDINGS", "BaseEventHandler")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "BaseEventHandler")
end

function AutoBar.Class.Button.prototype:RegisterButtonEvents()
	if self.eventsregistered then return end
	self.eventsregistered = true
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "ButtonEventHandler")
	self:RegisterEvent("PLAYER_AURAS_CHANGED", "ButtonEventHandler")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "ButtonEventHandler")
	self:RegisterEvent("ACTIONBAR_UPDATE_USABLE", "ButtonEventHandler")
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", "ButtonEventHandler")
	self:RegisterEvent("ACTIONBAR_UPDATE_STATE", "ButtonEventHandler")
	self:RegisterEvent("UPDATE_INVENTORY_ALERTS", "ButtonEventHandler")
	self:RegisterEvent("PLAYER_ENTER_COMBAT", "ButtonEventHandler")
	self:RegisterEvent("PLAYER_LEAVE_COMBAT", "ButtonEventHandler")
	self:RegisterEvent("START_AUTOREPEAT_SPELL", "ButtonEventHandler")
	self:RegisterEvent("STOP_AUTOREPEAT_SPELL", "ButtonEventHandler")
--[[
	self:RegisterEvent("CRAFT_SHOW", "ButtonEventHandler")
	self:RegisterEvent("CRAFT_CLOSE", "ButtonEventHandler")
	self:RegisterEvent("TRADE_SKILL_SHOW", "ButtonEventHandler")
	self:RegisterEvent("TRADE_SKILL_CLOSE", "ButtonEventHandler")
--]]
end

function AutoBar.Class.Button.prototype:UnregisterButtonEvents()
	if not self.eventsregistered then return end
	self.eventsregistered = nil
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("PLAYER_AURAS_CHANGED")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("ACTIONBAR_UPDATE_USABLE")
	self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	self:UnregisterEvent("ACTIONBAR_UPDATE_STATE")
	self:UnregisterEvent("UPDATE_INVENTORY_ALERTS")
	self:UnregisterEvent("PLAYER_ENTER_COMBAT")
	self:UnregisterEvent("PLAYER_LEAVE_COMBAT")
	self:UnregisterEvent("START_AUTOREPEAT_SPELL")
	self:UnregisterEvent("STOP_AUTOREPEAT_SPELL")
--[[
	self:UnregisterEvent("CRAFT_SHOW")
	self:UnregisterEvent("CRAFT_CLOSE")
	self:UnregisterEvent("TRADE_SKILL_SHOW")
	self:UnregisterEvent("TRADE_SKILL_CLOSE")
--]]
end

--[[
	Following Events are always set and will always be called - i call them the base events
]]
function AutoBar.Class.Button.prototype:BaseEventHandler(e)
	if (not self.parentBar.sharedLayoutDB.enabled or self.parentBar.sharedLayoutDB.hide) then
		return
	end
	local e = event

	if ( e == "PLAYER_ENTERING_WORLD" or e == "ACTIONBAR_PAGE_CHANGED") then
		self:UpdateButton()
	elseif ( e == "UPDATE_BINDINGS" ) then
		self:UpdateHotkeys()
	elseif ( e == "UPDATE_SHAPESHIFT_FORM" ) then
		self:UpdateButton()
	end
end

-- Show grid feedback for droppable buttons
function AutoBar.Class.Button.prototype:ACTIONBAR_SHOWGRID()
--print(self.frame:GetName(), "ShowGrid")
	local frame = self.frame
	frame.icon:Hide()
	frame.normalTexture:Show()
end

-- Hide grid feedback for droppable buttons
function AutoBar.Class.Button.prototype:ACTIONBAR_HIDEGRID()
--print(self.frame:GetName(), "HideGrid")
	local frame = self.frame
	frame.icon:Show()
	frame.normalTexture:Hide()
end


--[[
	Following Events are only set when the Button in question has a valid action - i call them the button events
]]
function AutoBar.Class.Button.prototype:ButtonEventHandler(e)
	if (not self.parentBar.sharedLayoutDB.enabled or self.parentBar.sharedLayoutDB.hide) then
		return
	end
	local e = event
	local actionId = self.action

	if ( event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_AURAS_CHANGED" ) then
		self:UpdateUsable()
		self:UpdateHotkeys()
	elseif ( event == "UNIT_INVENTORY_CHANGED" ) then
		if ( arg1 == "player" ) then
			self:UpdateButton()
		end
	elseif ( event == "ACTIONBAR_UPDATE_USABLE" or event == "UPDATE_INVENTORY_ALERTS" or event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		self:UpdateUsable()
		self:UpdateCooldown()
---	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
---		self:UpdateState()
---	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
---		self:UpdateState()
	elseif ( event == "PLAYER_ENTER_COMBAT" ) then
		if ( IsAttackAction(actionId) ) then
			self:StartFlash()
		end
	elseif ( event == "PLAYER_LEAVE_COMBAT" ) then
		if ( IsAttackAction(actionId) ) then
			self:StopFlash()
		end
	elseif ( event == "START_AUTOREPEAT_SPELL" ) then
		if ( IsAutoRepeatAction(actionId) ) then
			self:StartFlash()
		end
	elseif ( event == "STOP_AUTOREPEAT_SPELL" ) then
		if ( self.flashing == 1 and not IsAttackAction(actionId) ) then
			self:StopFlash()
		end
	end
end



-- Return a unique key to use
function AutoBar.Class.Button:GetCustomKey(customButtonName)
	local barKey = "AutoBarCustomButton" .. customButtonName
	return barKey
end


function AutoBar.Class.Button:NameExists(newName)
	local newKey = AutoBar.Class.Button:GetCustomKey(newName)

	if (AutoBar.db.account.buttonList[newKey]) then
		return true
	end
	for classKey, classDB in pairs (AutoBarDB.classes) do
		if (classDB.buttonList[newKey]) then
			return true
		end
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		if (charDB.buttonList[newKey]) then
			return true
		end
	end

	return nil
end

-- Return a unique name and buttonKey to use
function AutoBar.Class.Button:GetNewName(baseName)
	local newName, newKey
	while true do
		newName = baseName .. AutoBar.db.account.keySeed
		newKey = AutoBar.Class.Button:GetCustomKey(newName)

		AutoBar.db.account.keySeed = AutoBar.db.account.keySeed + 1
		if (not AutoBar.Class.Button:NameExists(newName)) then
			break
		end
	end
	return newName, newKey
end

function AutoBar.Class.Button:Delete(buttonKey)
	AutoBar.db.account.buttonList[buttonKey] = nil
	for classKey, classDB in pairs (AutoBarDB.classes) do
		classDB.buttonList[buttonKey] = nil
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		charDB.buttonList[buttonKey] = nil
	end

	-- Delete ButtonKeys on Bars
	AutoBar.Class.Bar:DeleteButtonKey(AutoBar.db.account.barList, buttonKey)
	for classKey, classDB in pairs (AutoBarDB.classes) do
		AutoBar.Class.Bar:DeleteButtonKey(classDB.barList, buttonKey)
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		AutoBar.Class.Bar:DeleteButtonKey(charDB.barList, buttonKey)
	end

	-- Delete Instantiated Buttons
	AutoBar.buttonList[buttonKey] = nil
	AutoBar.buttonListDisabled[buttonKey] = nil
end

function AutoBar.Class.Button:RenameCategoryKey(dbList, oldKey, newKey)
	for buttonKey, buttonDB in pairs(dbList) do
		for index, categoryKey in ipairs(buttonDB) do
			if (categoryKey == oldKey) then
				buttonDB[index] = newKey
			end
		end
	end
end

function AutoBar.Class.Button:RenameCategory(oldKey, newKey)
	-- Change all db instances
	AutoBar.Class.Button:RenameCategoryKey(AutoBar.db.account.buttonList, oldKey, newKey)
	for classKey, classDB in pairs (AutoBarDB.classes) do
		AutoBar.Class.Button:RenameCategoryKey(classDB.buttonList, oldKey, newKey)
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		AutoBar.Class.Button:RenameCategoryKey(charDB.buttonList, oldKey, newKey)
	end
end

function AutoBar.Class.Button:RenameKey(dbList, oldKey, newKey, newName)
	local buttonDB = dbList[oldKey]
	if (buttonDB) then
		dbList[newKey] = buttonDB
		dbList[oldKey] = nil
		buttonDB.buttonKey = newKey
		if (buttonDB.name) then
			buttonDB.name = newName
		end
	end
end

function AutoBar.Class.Button:Rename(oldKey, newName)
	local newKey = AutoBar.Class.Button:GetCustomKey(newName)

	-- Change all db instances
	AutoBar.Class.Button:RenameKey(AutoBar.db.account.buttonList, oldKey, newKey, newName)
	for classKey, classDB in pairs (AutoBarDB.classes) do
		AutoBar.Class.Button:RenameKey(classDB.buttonList, oldKey, newKey, newName)
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		AutoBar.Class.Button:RenameKey(charDB.buttonList, oldKey, newKey, newName)
	end

	-- Change instantated Buttons
	if (AutoBar.buttonListDisabled[oldKey]) then
		AutoBar.buttonListDisabled[newKey] = AutoBar.buttonListDisabled[oldKey]
		AutoBar.buttonListDisabled[oldKey] = nil
	end
	if (AutoBar.buttonList[oldKey]) then
		AutoBar.buttonList[newKey] = AutoBar.buttonList[oldKey]
		AutoBar.buttonList[oldKey] = nil
	end

	-- Change ButtonKeys on Bars
	AutoBar.Class.Bar:RenameButtonKey(AutoBar.db.account.barList, oldKey, newKey)
	for classKey, classDB in pairs (AutoBarDB.classes) do
		AutoBar.Class.Bar:RenameButtonKey(classDB.barList, oldKey, newKey)
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		AutoBar.Class.Bar:RenameButtonKey(charDB.barList, oldKey, newKey)
	end
end

local buttonVersion = 1
function AutoBar.Class.Button:OptionsInitialize()
	if (not AutoBar.db.account.buttonList) then
		AutoBar.db.account.buttonList = {}
	end
	if (not AutoBar.db.class.buttonList) then
		AutoBar.db.class.buttonList = {}
	end
	if (not AutoBar.db.char.buttonList) then
		AutoBar.db.char.buttonList = {}
	end
	if (not AutoBar.db.char.buttonDataList) then
		AutoBar.db.char.buttonDataList = {}
	end
end

local function ResetCustomButtons(buttonListDB)
	for buttonKey, buttonDB in pairs(buttonListDB) do
		if (buttonDB.buttonClass == "AutoBarButtonCustom") then
			buttonListDB[buttonKey] = nil
		end
	end
end

function AutoBar.Class.Button:OptionsReset()
	ResetCustomButtons(AutoBar.db.account.buttonList)
--	AutoBar.db.account.buttonListVersion = buttonVersion
	ResetCustomButtons(AutoBar.db.class.buttonList)
	ResetCustomButtons(AutoBar.db.char.buttonList)
end

function AutoBar.Class.Button:OptionsUpgrade()
--AutoBar:Print("AutoBar.Class.Button:OptionsUpgrade start")
	if (not AutoBar.db.account.buttonListVersion) then
--		AutoBar.db.account.buttonListVersion = buttonVersion
	elseif (AutoBar.db.account.buttonListVersion < buttonVersion) then
--AutoBar:Print("AutoBar.Class.Button:OptionsUpgrade AutoBar.db.account.buttonListVersion " .. tostring(AutoBar.db.account.buttonListVersion))
--		AutoBar.db.account.buttonListVersion = buttonVersion
	end
end



--/dump AutoBar.barList
--/script AutoBarClassBarBasicFrame:Show()
--/script AutoBar.barList["AutoBarClassBarBasic"]:UnlockFrames()
--/dump AutoBar.barList["AutoBarClassBarExtras"].buttonList[13]
--/dump AutoBar.buttonList["AutoBarCustomButtonPlanning Mods"]
-- /script AutoBar.barList["AutoBarClassBarBasic"].buttonList[18].frame.normalTexture:Hide()
-- /script AutoBar.barList["AutoBarClassBarBasic"].buttonList[18].frame:SetChecked(0)
-- /script AutoBar.barList["AutoBarClassBarBasic"].buttonList[18].frame:GetPushedTexture():SetTexture("")
-- /dump AutoBar.barList["AutoBarClassBarBasic"].buttonList[18].showgrid
-- /script AutoBar.buttonList["AutoBarButtonQuest"].frame.popupHeader.popupButtonList[2].frame.icon:Show()
-- /script AutoBar.buttonList["AutoBarButtonQuest"].frame.popupHeader.popupButtonList[2].frame.oldNT:Hide()
