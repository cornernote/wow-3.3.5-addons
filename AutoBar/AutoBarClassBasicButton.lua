--
-- AutoBarClassBasicButton
-- Copyright 2008+ Toadkiller of Proudmoore.
-- Implements SecureHandler and other code common to both anchor and popup buttons
--
-- Buttons are contained by AutoBar.Class.Bar
-- http://code.google.com/p/autobar/
--

local AutoBar = AutoBar
local spellIconList = AutoBar.spellIconList

local REVISION = tonumber(("$Revision: 758 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2009-04-19 04:51:26 +0000 (Sun, 19 Apr 2009) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local AceOO = AceLibrary("AceOO-2.0")
local L = AutoBar.locale
local LBF = LibStub("LibButtonFacade", true)
local LibKeyBound = LibStub("LibKeyBound-1.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local _G = getfenv(0)
local _

if (not AutoBar.Class) then
	AutoBar.Class = {}
end

-- Basic Button with textures, highlighting, keybindText, tooltips etc.
AutoBar.Class.BasicButton = AceOO.Class()

function AutoBar.Class.BasicButton.prototype:init(parentBar, buttonDB)
	AutoBar.Class.BasicButton.super.prototype.init(self)
end


-- OnLeave function.  Added to a button to allow calling it via control:CallMethod("TooltipHide")
function AutoBar.Class.BasicButton.TooltipHide()
	GameTooltip:Hide()
end


-- OnEnter function.  Added to a button to allow calling it via control:CallMethod("TooltipSet")
function AutoBar.Class.BasicButton.TooltipShow(button)
	if (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, button)
	else
		local x = button:GetRight()
		if (x >= (GetScreenWidth() / 2)) then
			GameTooltip:SetOwner(button, "ANCHOR_LEFT")
		else
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		end
	end

	local itemLink = button:GetAttribute("itemLink")
	local buttonType = button:GetAttribute("type")
	if (AutoBar.moveButtonsMode) then
		local name = AutoBarButton:GetDisplayName(button.class.buttonDB)
		GameTooltip:AddLine(name, 0.8, 0, 1)
		GameTooltip:Show()
	elseif (buttonType == "macro") then
		-- There is no accesible GameTooltip function for macros so make one with its name and the macro text
		local macroName = button:GetAttribute("macroName")
		local macroBody = button:GetAttribute("macroBody")

		if (macroName and macroBody) then
			GameTooltip:AddLine(macroName, 0.2, 0.8, 0.8)
			GameTooltip:AddLine(macroBody, 1, 1, 1, 1)
			button.UpdateTooltip = AutoBar.Class.BasicButton.TooltipShow
			GameTooltip:Show()
		end
	elseif (itemLink) then
		if (GameTooltip:SetHyperlink(itemLink)) then
			button.UpdateTooltip = AutoBar.Class.BasicButton.TooltipShow
		end
	elseif (buttonType == "item") then
		-- There is no way to get charge information outside built in Blizzard functions for buttonType == "action"
		-- The best we can do is link to a specific bag/slot so at least the tooltip can show this info
		-- Sadly, the itemString for this is "[bag] [slot]" which is not a valid paramater for SetHyperlink
		-- It is thus special cased here
		local bagslot = button:GetAttribute("item")
		if (bagslot) then
			local bag, slot = strmatch(bagslot, "^(%d+)%s+(%d+)$")
			if (bag and slot and GameTooltip:SetBagItem(bag, slot)) then
				button.UpdateTooltip = AutoBar.Class.BasicButton.TooltipShow
			end
		end
	end

	local rightClickType = button:GetAttribute("type2")
	if (rightClickType == "spell") then
		local spellName = button:GetAttribute("spell")
		local spellName2 = button:GetAttribute("spell2")
		if (not spellName or (spellName2 ~= spellName)) then
			GameTooltip:AddLine(L["Right Click casts "] .. spellName2, 1, 0.2, 1, 1)
			GameTooltip:Show()
		end
	end
end
--[[
/dump GameTooltip:SetHyperlink("spell:32246")
--]]

-- Apply tooltipType to the Button
function AutoBar.Class.BasicButton:TooltipApply(button)
	if (AutoBar.db.account.showTooltip) then
		if (not button.TooltipShow) then
			button.TooltipShow = AutoBar.Class.BasicButton.TooltipShow
--			SecureHandlerWrapScript(button, "OnEnter", button, [[ control:CallMethod("TooltipShow", self) ]])
		end
		if (not button.TooltipHide) then
			button.TooltipHide = AutoBar.Class.BasicButton.TooltipHide
			SecureHandlerWrapScript(button, "OnLeave", button, [[ control:CallMethod("TooltipHide") ]])
		end
		button:SetAttribute("showTooltip", true)
	else
		button:SetAttribute("showTooltip", nil)
	end
end


local borderBlue = {r = 0, g = 0, b = 1.0, a = 0.35}
local borderGreen = {r = 0, g = 1.0, b = 0, a = 0.35}

function AutoBar.Class.BasicButton.prototype:GetIconTexture(frame)
	local texture, borderColor
	local itemType = frame:GetAttribute("type")

	if (itemType == "item") then
		local itemId = frame:GetAttribute("itemId")
		if (itemId) then
			_,_,_,_,_,_,_,_,_, texture = GetItemInfo(tonumber(itemId))
			local bag, slot = AutoBarSearch.found:GetItemData(itemId)
			if ((not bag) and slot) then
				-- Add a green border if button is an equipped item
				borderColor = borderGreen
			end
if (itemId == 43569) then
--	print("43569:", texture)
end
		end
	elseif (itemType == "macro") then
		local macroIndex = frame:GetAttribute("macro")
		if (macroIndex) then
			_, texture = GetMacroInfo(macroIndex)
		else
			texture = frame.class.macroTexture
			if (not texture) then
				texture = "Interface\\Icons\\INV_Misc_Gift_05"
			end
		end
	elseif (itemType == "spell") then
		local spellName = frame:GetAttribute("spell")
		if (spellName) then
			_, _, texture = GetSpellInfo(spellName)

			-- Spells like mounts and critters are immune to the normal spell api
			if (not texture) then
				texture = spellIconList[spellName]
			end

			-- Add a blue border if button is a spell
			borderColor = borderBlue
		end
	end

	-- Fall through to right click spell
	if (not texture) then
		local spellName = frame:GetAttribute("spell2")
		if (spellName) then
			_, _, texture = GetSpellInfo(spellName)

			-- Add a blue border if button is a spell
			borderColor = borderBlue
		end
	end
	return texture, borderColor
end


-- Set cooldown based on the type settings
function AutoBar.Class.BasicButton.prototype:UpdateCooldown()
	local itemType = self.frame:GetAttribute("type")
	if (itemType) then-- and not self.parentBar.faded
		local start, duration, enabled = 0, 0, 0

		if (itemType == "item") then
			local itemId = self.frame:GetAttribute("itemId")
			start, duration, enabled = GetItemCooldown(itemId)
		elseif (itemType == "macro") then
--			local macroText = self.frame:GetAttribute("macrotext")
--			SecureCmdOptionParse()?
		elseif (itemType == "spell") then
			local spellName = self.frame:GetAttribute("spell")
			start, duration, enabled = GetSpellCooldown(spellName)
		end

		if (start and duration and enabled and start > 0 and duration > 0) then
			CooldownFrame_SetTimer(self.frame.cooldown, start, duration, enabled)
		else
			CooldownFrame_SetTimer(self.frame.cooldown, 0, 0, 0)
		end
	end
end

-- Set count based on the type and type2 settings
function AutoBar.Class.BasicButton.prototype:UpdateCount()
	local frame = self.frame
	if (AutoBar.db.account.showCount) then
		frame.count:Show()
		local count1 = 0
		local count2 = 0
		local itemType = frame:GetAttribute("type")

		if (itemType) then
			if (itemType == "item") then
				local itemId = frame:GetAttribute("itemId")
				count1 = GetItemCount(tonumber(itemId), nil, true) or 0
			elseif (itemType == "macro") then
			elseif (itemType == "spell") then
				local spellName = frame:GetAttribute("spell")
				count1 = GetSpellCount(spellName) or 0
				local spellName2 = frame:GetAttribute("spell2")
				if (spellName2) then
					count2 = GetSpellCount(spellName2) or 0
				end
			end
		end

		local displayCount1 = count1
		local displayCount2 = count2
		if (count1 > 99) then
			displayCount1 = "*"
		end
		if (count2 > 99) then
			displayCount2 = "*"
		end

		if (itemType == "spell") then
			if (count1 > 1 and count2 > 0) then
				frame.count:SetText(displayCount1 .. "/" .. displayCount2)
			elseif (count2 > 0) then
				frame.count:SetText("/" .. displayCount2)
			elseif (count1 > 0) then
				frame.count:SetText(displayCount1)
			else
				frame.count:SetText("")
			end
		elseif (count1 > 1) then
			frame.count:SetText(displayCount1)
		else
			frame.count:SetText("")
		end
	else
		frame.count:Hide()
	end
end


function AutoBar.Class.BasicButton.prototype:UpdateUsable()
	local frame = self.frame
	local itemType = frame:GetAttribute("type")
	local category = frame:GetAttribute("category")
	if (itemType) then
		local isUsable, notEnoughMana

		if (itemType == "item") then
			local itemId = frame:GetAttribute("itemId")
			isUsable, notEnoughMana = IsUsableItem(itemId)
			if (isUsable) then
				-- Single use in combat potion hack
				local start, duration, enabled = GetItemCooldown(itemId)
				if (not enabled) then
					isUsable = false
				end
			end
		elseif (itemType == "spell") then
			local spellName = frame:GetAttribute("spell")
			isUsable, notEnoughMana = IsUsableSpell(spellName)
		elseif (itemType == "macro") then
			isUsable = true
		else
			frame.icon:SetVertexColor(1.0, 1.0, 1.0)
			frame.hotKey:SetVertexColor(1.0, 1.0, 1.0)
			return
		end
		local categoryInfo = AutoBarCategoryList[category]
		if (isUsable and categoryInfo and categoryInfo.location) then
			local zone = GetRealZoneText()
			if (categoryInfo.location ~= zone) then
				local zoneGroup = AutoBarSearch.zoneGroup[zone]
				if (zoneGroup ~= categoryInfo.location) then
					isUsable = nil
				end
			end
		end

		local oor = AutoBar.db.account.outOfRange or "none"
		if (isUsable and (not frame.outOfRange or not (oor ~= "none"))) then
			frame.icon:SetVertexColor(1.0, 1.0, 1.0)
			frame.hotKey:SetVertexColor(1.0, 1.0, 1.0)
		elseif ((oor ~= "none") and frame.outOfRange) then
print("AutoBar.Class.BasicButton.prototype:UpdateUsable", oor)
			if (oor == "button") then
				frame.icon:SetVertexColor(0.8, 0.1, 0.1)
				frame.hotKey:SetVertexColor(1.0, 1.0, 1.0)
			else
				frame.hotKey:SetVertexColor(0.8, 0.1, 0.1)
				frame.icon:SetVertexColor(1.0, 1.0, 1.0)
			end
		elseif ((oor ~= "none") and notEnoughMana) then
			frame.icon:SetVertexColor(0.1, 0.3, 1.0)
		else
			frame.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	end
end


local function scriptOnEvent(self, event, ...)
	self.class[event](self.class, ...)
end

function AutoBar.Class.BasicButton.prototype:EventsEnable()
	self.frame:SetScript("OnEvent", scriptOnEvent)
end

