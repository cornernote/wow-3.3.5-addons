--
-- AutoBarClassPopupButton
-- Copyright 2007+ Toadkiller of Proudmoore.
--
-- Popup Buttons for AutoBar
-- Popup Buttons are contained by AutoBar.Class.Button
-- http://code.google.com/p/autobar/
--

local AutoBar = AutoBar
local REVISION = tonumber(("$Revision: 647 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local AceOO = AceLibrary("AceOO-2.0")
local L = AutoBar.locale
local LBF = LibStub("LibButtonFacade", true)
local _G = getfenv(0)
local _


-- Basic Button with textures, highlighting, keybindText, tooltips etc.
-- Bound to the underlying AutoBarButton which provides its state information, icon etc.
AutoBar.Class.PopupButton = AceOO.Class(AutoBar.Class.BasicButton)

function AutoBar.Class.PopupButton:GetPopupButton(parentButton, popupButtonIndex, popupHeader, popupKeyHandler)
	local popupButtonList = popupHeader.popupButtonList
	if (popupButtonList[popupButtonIndex]) then
		popupButtonList[popupButtonIndex]:Refresh(parentButton, popupButtonIndex, popupHeader)
	else
		popupButtonList[popupButtonIndex] = AutoBar.Class.PopupButton:new(parentButton, popupButtonIndex, popupHeader, popupKeyHandler)
	end

	return popupButtonList[popupButtonIndex]
end



function AutoBar.Class.PopupButton.prototype:init(parentButton, popupButtonIndex, popupHeader, popupKeyHandler)
	AutoBar.Class.PopupButton.super.prototype.init(self)

	self.parentBar = parentButton.parentBar
	self.parentButton = parentButton
	self.buttonDB = parentButton.buttonDB
	self.buttonName = self.buttonDB.buttonKey
	self.popupButtonIndex = popupButtonIndex
	self.popupHeader = popupHeader
	self.popupKeyHandler = popupKeyHandler
	self:CreateButtonFrame()
	self:Refresh(parentButton, popupButtonIndex, popupHeader)
end


function AutoBar.Class.PopupButton.prototype:Refresh(parentButton, popupButtonIndex, popupHeader)
end


local function funcOnEnter(self)
	local noTooltip = not (AutoBar.db.account.showTooltip and self.needsTooltip or AutoBar.moveButtonsMode)
	noTooltip = noTooltip or (InCombatLockdown() and not AutoBar.db.account.showTooltipCombat)
	if (noTooltip) then
		self.UpdateTooltip = nil
		GameTooltip:Hide()
	else
		AutoBar.Class.BasicButton.TooltipShow(self)
	end
--	self.popupHeader:Show()
end

local function funcOnLeave(self)
	GameTooltip:Hide()
end

-- Return the name of the global frame for the button.  Keybinds are made to it.
function AutoBar.Class.PopupButton.prototype:GetButtonFrameName(popupButtonIndex)
	return self.parentButton:GetButtonFrameName() .. "Popup" .. popupButtonIndex
end

function AutoBar.Class.PopupButton.prototype:CreateButtonFrame()
	local popupButtonIndex = self.popupButtonIndex
	local popupHeader = self.popupHeader
	local popupKeyHandler = self.popupKeyHandler
	local popupButtonName = self:GetButtonFrameName(popupButtonIndex)
	local frame = CreateFrame("Button", popupButtonName, popupKeyHandler or popupHeader, "ActionButtonTemplate SecureActionButtonTemplate SecureHandlerBaseTemplate")
	self.frame = frame
	frame.class = self
	frame:RegisterForClicks("AnyUp")

	frame:SetFrameRef("popupHeader", popupHeader)
	frame.popupHeader = popupHeader
	frame:SetScript("OnEnter", funcOnEnter)
	frame:SetScript("OnLeave", funcOnLeave)
	SecureHandlerWrapScript(frame, "OnEnter", frame, [[ self:GetFrameRef("popupHeader"):Show() ]])
	SecureHandlerWrapScript(frame, "OnLeave", frame, [[ self:GetFrameRef("popupHeader"):Hide() ]])

	local buttonWidth = self.parentBar.buttonWidth or 36
	local buttonHeight = self.parentBar.buttonHeight or 36
	frame:ClearAllPoints()
	frame:SetWidth(buttonWidth)
	frame:SetHeight(buttonHeight)

---	frame:SetScript("PostClick", self.PostClick)

	frame.icon = _G[("%sIcon"):format(popupButtonName)]
	frame.cooldown = _G[("%sCooldown"):format(popupButtonName)]
	frame.macroName = _G[("%sName"):format(popupButtonName)]
	frame.hotKey = _G[("%sHotKey"):format(popupButtonName)]
	frame.count = _G[("%sCount"):format(popupButtonName)]
	frame.flash = _G[("%sFlash"):format(popupButtonName)]
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

	frame.border = _G[("%sBorder"):format(popupButtonName)]
end


function AutoBar.Class.PopupButton.prototype:UpdateIcon()
	local frame = self.frame
	local texture, borderColor = self:GetIconTexture(frame)
	frame:SetAttribute("icon", texture)

	if (texture) then
		frame.icon:SetTexture(texture)
		frame.icon:Show()
		frame.tex = texture
	else
		frame.icon:Hide()
		frame.cooldown:Hide()
		frame.hotKey:SetVertexColor(0.6, 0.6, 0.6)
		frame.tex = nil
	end

	if (borderColor) then
		frame.border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
		frame.border:Show()
	else
		frame.border:Hide()
	end
end


function AutoBar.Class.PopupButton.prototype:IsActive()
	return self.frame:GetAttribute("type")
end

