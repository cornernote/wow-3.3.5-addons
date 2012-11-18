--
-- AutoBarClassBar
-- Copyright 2007+ Toadkiller of Proudmoore.
-- A lot of code borrowed from Bartender3
--
-- Layout Bars for AutoBar
-- Layout Bars logically organize similar buttons and provide for layout options for the Bar and its Buttons
-- Sticky dragging is provided as well
-- http://code.google.com/p/autobar/
--

local AutoBar = AutoBar
local REVISION = tonumber(("$Revision: 798 $"):match("%d+"))
if AutoBar.revision < REVISION then
	AutoBar.revision = REVISION
	AutoBar.date = ('$Date: 2007-09-26 14:04:31 -0400 (Wed, 26 Sep 2007) $'):match('%d%d%d%d%-%d%d%-%d%d')
end

local AceOO = AceLibrary("AceOO-2.0")
local L = AutoBar.locale
local LBF = LibStub("LibButtonFacade", true)
local LibKeyBound = LibStub:GetLibrary("LibKeyBound-1.0")
local LibStickyFrames = LibStub("LibStickyFrames-2.0")
local dewdrop = AceLibrary("Dewdrop-2.0")
local _G = getfenv(0)

-- List of Bars for the current user
AutoBar.barList = {}

if (not AutoBar.Class) then
	AutoBar.Class = {}
end

local function onReceiveDragFunc(bar)
	local toObject = bar.class
--AutoBar:Print("onReceiveDragFunc " .. tostring(toObject.barKey) .. " arg1 " .. tostring(arg1) .. " arg2 " .. tostring(arg2))
	toObject:DropObject()
end

local FADEOUT_UPDATE_TIME = 0.1
local function onUpdateFunc(button, elapsed)
	local self = button.class
--AutoBar:Print("onUpdateFunc " .. tostring(self.barName) .. " elapsed " .. tostring(elapsed) .. " self.elapsed " .. tostring(self.elapsed))
	self.elapsed = self.elapsed + elapsed
	if (self.fadeOutDelay) then
		if (self.elapsed < self.fadeOutDelay) then
			return
		else
			self.elapsed = self.elapsed - self.fadeOutDelay
			self.fadeOutDelay = nil
		end
	end
	if (self.elapsed > FADEOUT_UPDATE_TIME) then
		self:UpdateFadeOut(self.elapsed)
		self.elapsed = 0
	end
end


-- Basic Bar that can do the classic AutoBar layout grid
-- Provides snapto when dragging bars
AutoBar.Class.Bar = AceOO.Class("AceEvent-2.0")


-- Handle dragging of items, macros, spells to the button
-- Handle rearranging of buttons when buttonLock is off
function AutoBar.Class.Bar.prototype:DropObject()
	local toObject = self
	local fromObject = AutoBar:GetDraggingObject()
--AutoBar:Print("AutoBar.Class.Bar.prototype:DropObject " .. tostring(fromObject and fromObject.buttonDB.buttonKey or "none") .. " --> " .. tostring(toObject.buttonDB.buttonKey))
	if (fromObject and AutoBar.moveButtonsMode) then
		local targetButton = # self.buttonList + 1
		AutoBar:ButtonMove(fromObject.parentBar.barKey, fromObject.order, self.barKey, targetButton)
		AutoBar:BarButtonChanged()
		fromObject:UpdateButton()
	end
	AutoBar:SetDraggingObject(nil)
end


function AutoBar.Class.Bar.prototype:init(barKey)
	AutoBar.Class.Bar.super.prototype.init(self) -- Mandatory init.

	self.barKey = barKey
	self:UpdateShared()
	if (not L[barKey]) then
		L[barKey] = self.sharedLayoutDB.name
	end
	self.barName = L[barKey]
--	if self.statebar and self.id == 1 then self.mainbar = true end

	self:CreateBarFrame()
	self:CreateDragFrame()

	self.buttonList = {}		-- Button by index
	self.activeButtonList = {}	-- Button by index, non-empty & enabled ones only
	self:UpdateObjects()
end

--/script AutoBar:Print(tostring(AutoBar.barList["AutoBarClassBarExtras"].frame:GetAttribute("state")))
--/script AutoBar:Print(tostring(AutoBar.buttonList["AutoBarButtonFishing"].frame:GetAttribute("state")))


function AutoBar.Class.Bar:SkinChanged(SkinID, Gloss, Backdrop, barKey, buttonKey, Colors)
	if (buttonKey) then
		local buttonDB = AutoBar.buttonDBList[buttonKey]
		buttonDB.SkinID = SkinID
		buttonDB.Gloss = Gloss
		buttonDB.Backdrop = Backdrop
		buttonDB.Colors = Colors
	elseif (barKey) then
		local barLayoutDB = AutoBar.barLayoutDBList[barKey]
		barLayoutDB.SkinID = SkinID
		barLayoutDB.Gloss = Gloss
		barLayoutDB.Backdrop = Backdrop
		barLayoutDB.Colors = Colors
	else
--AutoBar:Print("AutoBar.Class.Bar.prototype:SkinChanged SkinID " .. tostring(SkinID) .. " barKey " .. tostring(barKey) .. " buttonKey " .. tostring(buttonKey))
		AutoBar.db.account.SkinID = SkinID
		AutoBar.db.account.Gloss = Gloss
		AutoBar.db.account.Backdrop = Backdrop
		AutoBar.db.account.Colors = Colors
	end
end

function AutoBar.Class.Bar.prototype:CreateBarFrame()
	local name = self.barKey .. "Driver"
	local driver = CreateFrame("Button", name, UIParent, "SecureHandlerStateTemplate")
	driver.class = self
	driver:SetClampedToScreen(AutoBar.db.account.clampedToScreen)
	driver:EnableMouse(false)
	driver:SetMovable(true)
	driver:RegisterForDrag("LeftButton")
	driver:RegisterForClicks("RightButtonDown", "LeftButtonUp")
	driver:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, insets = {left = 0, right = 0, top = 0, bottom = 0},})
	driver:SetBackdropColor(0, 1, 1, 0)
	driver:ClearAllPoints()
	driver:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	driver.text = driver:CreateFontString(nil, "ARTWORK")
	driver.text:SetFontObject(GameFontNormal)
	driver.text:SetText()
	driver.text:Show()
	driver.text:ClearAllPoints()
	driver.text:SetPoint("CENTER", driver, "CENTER", 0, 0)
	if (self.sharedLayoutDB.hide) then
		driver:Hide()
	else
		driver:Show()
	end
	self.frame = driver

	LibStickyFrames:RegisterFrame(self.frame)

	self.elapsed = 0
	if (self.sharedLayoutDB.fadeOut) then
		self:CreateFadeFrame()
		self.fadeFrame:SetScript("OnUpdate", onUpdateFunc)
	end

	if (LBF) then
		local group = LBF:Group("AutoBar", self.barKey)
		driver.LBFGroup = group
		group.SkinID = self.sharedLayoutDB.SkinID or "Blizzard"
		group.Backdrop = self.sharedLayoutDB.Backdrop
		group.Gloss = self.sharedLayoutDB.Gloss
		group.Colors = self.sharedLayoutDB.Colors or {}
	end
end
-- /dump LibStub("LibButtonFacade",true):ListSkins()
-- /dump LibStub("LibButtonFacade",true):ListAddons()
-- /dump LibStub("LibButtonFacade",true):ListGroups("AutoBar")
-- /dump LibStub("LibButtonFacade",true):ListButtons("AutoBar", "AutoBarClassBarBasic")

-- Refresh the Bar
-- New buttons are added, unused ones removed
function AutoBar.Class.Bar.prototype:UpdateShared()
	self.sharedLayoutDB = AutoBar.barLayoutDBList[self.barKey]
	self.sharedButtonDB = AutoBar.barButtonsDBList[self.barKey]
	self.sharedPositionDB = AutoBar.barPositionDBList[self.barKey]
	assert(self.sharedLayoutDB, "nil sharedLayoutDB " .. self.barKey)
	assert(self.sharedButtonDB, "nil sharedButtonDB " .. self.barKey)
	assert(self.sharedPositionDB, "nil sharedPositionDB " .. self.barKey)
end

-- Apply the new skin
function AutoBar.Class.Bar.prototype:UpdateSkin(SkinID)
	if (LBF) then
		local group = self.frame.LBFGroup
		group.SkinID = SkinID
		group:Skin(group.SkinID, group.Backdrop, group.Gloss, group.Colors)
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateSkin SkinID " .. tostring(group.SkinID))
	end
end

-- Refresh the Bar
-- New buttons are added, unused ones removed
function AutoBar.Class.Bar.prototype:UpdateObjects()
	local buttonList = self.buttonList
	local buttonKeyList = self.sharedButtonDB.buttonKeys
	local buttonDB

	-- Create or Refresh the Bar's Buttons
	local delete
	for buttonKeyIndex, buttonKey in ipairs(buttonKeyList) do
		buttonDB = AutoBar.buttonDBList[buttonKey]
		if (not buttonDB) then
		elseif (buttonDB.enabled) then
			-- Recover from disabled cache
assert(buttonDB.buttonKey == buttonKey, "AutoBar.Class.Bar.prototype:UpdateObjects mismatched keys")
			if (AutoBar.buttonListDisabled[buttonKey]) then
				AutoBar.buttonList[buttonKey] = AutoBar.buttonListDisabled[buttonKey]
				AutoBar.buttonListDisabled[buttonKey] = nil
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects Thaw " .. tostring(buttonKey) .. " <-- buttonListDisabled")
			end

			if (AutoBar.buttonList[buttonKey]) then
				buttonList[buttonKeyIndex] = AutoBar.buttonList[buttonKey]
				buttonList[buttonKeyIndex]:Refresh(self, buttonDB)
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects existing buttonKeyIndex " .. tostring(buttonKeyIndex) .. " buttonKey " .. tostring(buttonKey))
			else
				buttonList[buttonKeyIndex] = AutoBar.Class[buttonDB.buttonClass]:new(self, buttonDB)
				AutoBar.buttonList[buttonKey] = buttonList[buttonKeyIndex]
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects new buttonKeyIndex " .. tostring(buttonKeyIndex) .. " buttonKey " .. tostring(buttonKey))
			end
			buttonList[buttonKeyIndex].order = buttonKeyIndex
		else
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects Disabled " .. tostring(buttonKey) .. " --> buttonListDisabled ?")
			-- Move to disabled cache
			if (AutoBar.buttonList[buttonKey]) then
				buttonList[buttonKeyIndex] = AutoBar.buttonList[buttonKey]
				buttonList[buttonKeyIndex]:Refresh(self, buttonDB)
				AutoBar.buttonListDisabled[buttonKey] = AutoBar.buttonList[buttonKey]
				AutoBar.buttonList[buttonKey] = nil
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects Freeze " .. tostring(buttonKey) .. " --> buttonListDisabled")
			elseif (AutoBar.buttonListDisabled[buttonKey]) then
				buttonList[buttonKeyIndex] = AutoBar.buttonListDisabled[buttonKey]
				buttonList[buttonKeyIndex]:Refresh(self, buttonDB)
			else
				buttonList[buttonKeyIndex] = AutoBar.Class[buttonDB.buttonClass]:new(self, buttonDB)
				AutoBar.buttonListDisabled[buttonKey] = buttonList[buttonKeyIndex]
			end
		end
	end

	-- Trim Excess
	for buttonIndex = # buttonList, # buttonKeyList + 1, -1 do
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateObjects Trim " .. tostring(buttonList[buttonIndex].buttonDB.buttonKey) .. " buttonIndex " .. tostring(buttonIndex))
		buttonList[buttonIndex] = nil
	end

end
--/dump AutoBar.buttonList["AutoBarCustomButtonCustoXyXz"]
--/dump AutoBar.buttonList["AutoBarButtonBandages"]
--/dump AutoBar.buttonList["CustomButton28"]:IsActive()
--/dump AutoBar.buttonListDisabled["CustomButton30"]:IsActive()
--/script AutoBar.buttonListDisabled["CustomButton30"].frame:Show()
--/dump AutoBar.barList["AutoBarClassBarExtras"].buttonList[2].buttonDB.buttonKey
--/dump AutoBar.barList["AutoBarClassBarExtras"].buttonList[2]:IsActive()
--/dump # AutoBar.barList["AutoBarClassBarExtras"].activeButtonList
--/dump AutoBar.barList["AutoBarClassBarDruid"].buttonList
--/script AutoBar.barList["AutoBarClassBarBasic"]:UpdateActive()
--/dump (# AutoBar.barList["AutoBarClassBarBasic"].activeButtonList)
--/dump (# AutoBar.barList["AutoBarClassBarBasic"].buttonList)
--/dump (# AutoBar.buttonList)
--/dump (# AutoBar.buttonListDisabled)


-- Based on the current Scan results, update the Button and Popup Attributes
-- Create Popup Buttons as needed
function AutoBar.Class.Bar.prototype:UpdateAttributes()
	local buttonList = self.buttonList

	-- Create or Refresh the Bar's Buttons
	for buttonIndex, button in ipairs(buttonList) do
		button:SetupButton()
	end
end


-- The activeButtonList contains only active buttons.  Make it so.
function AutoBar.Class.Bar.prototype:UpdateActive()
	local activeButtonList = self.activeButtonList
	local maxButtons = # self.buttonList
	local activeIndex = 1
	local maxActiveButtons = self.sharedLayoutDB.rows * self.sharedLayoutDB.columns

--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateActive maxButtons " .. tostring(maxButtons))
	for index = 1, maxButtons, 1 do
		local button = self.buttonList[index]
		if (button and button:IsActive()) then
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateActive Active " .. tostring(activeIndex) .. " " .. tostring(button.buttonName))
			activeButtonList[activeIndex] = button
			activeIndex = activeIndex + 1
			button.frame:Show()
		elseif (button) then
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateActive Inactive " .. tostring(index) .. " " .. tostring(button.buttonName))
			button.frame:Hide()
		end
	end

	-- Ditch buttons in excess of rows * columns
	if ((activeIndex - 1) > maxActiveButtons and not AutoBar.moveButtonsMode) then
--AutoBar:Print("AutoBar.Class.Bar.prototype:UpdateActive activeIndex " .. tostring(activeIndex - 1) .. " maxActiveButtons " .. tostring(maxActiveButtons) .. " = rows " .. tostring(self.sharedLayoutDB.rows) .. " columns " .. tostring(self.sharedLayoutDB.columns))
		activeIndex = maxActiveButtons + 1
	end

	-- Trim Excess
	for i = activeIndex, # activeButtonList, 1 do
		local button = activeButtonList[i]
		button:Disable()
		activeButtonList[i] = nil
	end
end
-- /dump AutoBar.buttonListDisabled
-- /dump (# AutoBar.buttonList)
-- /dump (# AutoBar.barList["AutoBarClassBarBasic"].buttonList)
-- /dump AutoBar.barList["AutoBarClassBarBasic"].buttonList[6]
-- /dump AutoBar.barList["AutoBarClassBarBasic"].activeButtonList[2].frame.popupHeader:GetAttribute("state")
-- /script AutoBar.barList["AutoBarClassBarBasic"].activeButtonList[4].frame:SetChecked(1)


function AutoBar.Class.Bar.prototype:UpdateFadeOut()
--AutoBar:Print("AutoBar.Class.Bar.prototype:OnUpdate self.sharedLayoutDB.fadeOut " .. tostring(self.sharedLayoutDB.fadeOut))
	if (self.sharedLayoutDB.fadeOut) then
		local cancelFade = InCombatLockdown() and self.sharedLayoutDB.fadeOutCancelInCombat or self.frame:IsMouseOver() or IsShiftKeyDown() and self.sharedLayoutDB.fadeOutCancelOnShift or IsControlKeyDown() and self.sharedLayoutDB.fadeOutCancelOnCtrl or IsAltKeyDown() and self.sharedLayoutDB.fadeOutCancelOnAlt
		for buttonIndex, button in pairs(self.activeButtonList) do
--- ToDo: Verify
			if (button.frame.popupHeader and button.frame.popupHeader:IsVisible()) then
				cancelFade = true
			end
		end
		if (cancelFade) then
			self.frame:SetAlpha(self.sharedLayoutDB.alpha)
			self.faded = nil
			self.fadeOutDelay = self.sharedLayoutDB.fadeOutDelay
		elseif (not self.faded) then
			local startAlpha = self.sharedLayoutDB.alpha
			local fadeOutAlpha = self.sharedLayoutDB.fadeOutAlpha or 0
			local fadeOutChunks = (self.sharedLayoutDB.fadeOutTime or 10) / FADEOUT_UPDATE_TIME
			local decrement = (startAlpha - fadeOutAlpha) / fadeOutChunks
			local alpha = self.frame:GetAlpha() - decrement
			if (alpha < fadeOutAlpha) then
				alpha = fadeOutAlpha
			end
			if (AutoBar.stickyMode or AutoBar.moveButtonsMode) then
				self.frame:SetAlpha(startAlpha)
				self.faded = nil
			elseif (alpha > fadeOutAlpha) then
				self.frame:SetAlpha(alpha)
			else
				self.frame:SetAlpha(fadeOutAlpha)
				self.faded = true
			end
		end
	end
end

function AutoBar.Class.Bar.prototype:SetFadeOut(fadeOut)
	self.sharedLayoutDB.fadeOut = fadeOut
	self.faded = nil
	if (fadeOut) then
		self:CreateFadeFrame()
		self.fadeFrame:SetScript("OnUpdate", onUpdateFunc)
	else
		self.frame:SetAlpha(self.sharedLayoutDB.alpha)
		self.fadeFrame:SetScript("OnUpdate", nil)
	end
end

function AutoBar.Class.Bar.prototype:StickTo(frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
	LibStickyFrames:SetFramePoints(frame, point, stickToFrame, stickToPoint, stickToX, stickToY)
	self.sharedLayoutDB.stickPoint = point
	self.sharedLayoutDB.stickToFrameName = stickToFrame and stickToFrame:GetName() or nil
	self.sharedLayoutDB.stickToPoint = stickToPoint
	self.sharedLayoutDB.stickToX = stickToX
	self.sharedLayoutDB.stickToY = stickToY
end

local colorMoveButtons = {r = 1, b = 1, g = 0, a = 0.5}
function AutoBar.Class.Bar.prototype:ColorBars()
	local frame = self.frame
	if (AutoBar.keyBoundMode or AutoBar.moveButtonsMode) then
		-- Adjust Frame Strata
		frame:SetFrameStrata("DIALOG")
		self:SetButtonFrameStrata("LOW")

		-- Cancel Fade
		if self.sharedLayoutDB.fadeOut then
			frame:SetAlpha(self.sharedLayoutDB.alpha)
			self.faded = nil
		end

		-- Set Color
		if (AutoBar.keyBoundMode) then
			frame:SetBackdropColor(LibKeyBound:GetColorKeyBoundMode())
		elseif (AutoBar.moveButtonsMode) then
			if (self.sharedLayoutDB.hide) then
				frame:SetBackdropColor(LibStickyFrames:GetColorHidden())
			else
				frame:SetBackdropColor(colorMoveButtons.r, colorMoveButtons.g, colorMoveButtons.b, colorMoveButtons.a)
			end
		end
		frame.text:SetText(self.barName)
		frame:Show()
	elseif (AutoBar.stickyMode) then
		frame:SetFrameStrata(self.sharedLayoutDB.frameStrata)
		self:SetButtonFrameStrata(self.sharedLayoutDB.frameStrata)
		frame.text:SetText(self.barName)
	else
		if (self.sharedLayoutDB.hide) then
			self.frame:Hide()
		else
			self.frame:Show()
		end
		frame:SetFrameStrata(self.sharedLayoutDB.frameStrata)
		self:SetButtonFrameStrata(self.sharedLayoutDB.frameStrata)
		frame.text:SetText("")
		frame:SetBackdropColor(0, 0, 0, 0)
		frame:SetBackdropBorderColor(0, 0, 0, 0)
	end
end


function AutoBar.Class.Bar.prototype:SetButtonFrameStrata(frameStrata)
	for index, button in pairs(self.buttonList) do
		button.frame:SetFrameStrata(frameStrata)
		if (button.frame.popupHeader) then
			button.frame.popupHeader:SetFrameStrata("DIALOG")
		end
	end
end

local oldOnReceiveDragFunc

function AutoBar.Class.Bar.prototype:MoveButtonsModeOn()
	local frame = self.frame
	frame:EnableMouse(# self.buttonList == 0)
	oldOnReceiveDragFunc = frame:GetScript("OnReceiveDrag")
---	frame:SetScript("OnReceiveDrag", onReceiveDragFunc)
	self:ColorBars()
	for index, button in pairs(self.buttonList) do
		button:MoveButtonsModeOn()
	end
	self.dragFrame:Show()
end

function AutoBar.Class.Bar.prototype:MoveButtonsModeOff()
	local frame = self.frame
	frame:EnableMouse(AutoBar.stickyMode)
---	frame:SetScript("OnReceiveDrag", oldOnReceiveDragFunc)
	frame:SetFrameStrata(self.sharedLayoutDB.frameStrata)
	self:SetButtonFrameStrata(self.sharedLayoutDB.frameStrata)
	self:ColorBars()
	for index, button in pairs(self.buttonList) do
		button:MoveButtonsModeOff()
	end
	self.dragFrame:Hide()
end


function AutoBar.Class.Bar.prototype:CreateDragFrame()
	if (not self.dragFrame) then
		local name = self.barKey .. "DragFrame"
		local frame = CreateFrame("Button", name, self.frame, "ActionButtonTemplate SecureActionButtonTemplate SecureHandlerDragTemplate")
		frame:GetNormalTexture():Hide()
		frame:SetNormalTexture(nil)
		self.dragFrame = frame
	--AutoBar:Print(tostring(self.parentBar.frame) .. " ->  " .. tostring(frame) .. " button " .. tostring(name))

		frame.class = self
		frame:EnableMouse(true)
		frame:RegisterForClicks("AnyUp")
		frame:RegisterForDrag("LeftButton", "RightButton")
---		frame:SetScript("OnReceiveDrag", onReceiveDragFunc)
	end
end


function AutoBar.Class.Bar.prototype:CreateFadeFrame()
	if (not self.fadeFrame) then
		local name = self.barKey .. "FadeFrame"
		local frame = CreateFrame("CheckButton", name, self.frame, "ActionButtonTemplate, SecureActionButtonTemplate")
		frame:SetNormalTexture(nil)
		frame.class = self

		self.fadeFrame = frame
		self.fadeFrame:SetScript("OnUpdate", onUpdateFunc)
	end
end


function AutoBar.Class.Bar.prototype:ToggleVisibilty()
	-- Disable during combat or Move Buttons
	if (InCombatLockdown() or AutoBar.moveButtonsMode) then
		return
	end

	if (self.sharedLayoutDB.hide) then
		self.sharedLayoutDB.hide = nil
	else
		self.sharedLayoutDB.hide = true
	end
	AutoBar:BarsChanged()
	if (not AutoBar.stickyMode) then
		if (self.sharedLayoutDB.hide) then
--			self.frame:Hide()
		else
--			self.frame:Show()
		end
	end
end

function AutoBar.Class.Bar.prototype:RefreshLayout()
	-- Disable during combat
	if (InCombatLockdown()) then
		return
	end

	self:RefreshScale()
	self:RefreshButtonLayout()
	self:RefreshAlpha()
	if ((AutoBar.stickyMode or AutoBar.moveButtonsMode)) then
		self.frame:Show()
	elseif (self.sharedLayoutDB.hide or not self.sharedLayoutDB.enabled) then
		self.frame:Hide()
	else
		self.frame:Show()
	end
end

function AutoBar.Class.Bar.prototype:PositionLoad()
	local sharedPositionDB = self.sharedPositionDB
	local sharedLayoutDB = self.sharedLayoutDB
	if (sharedPositionDB.stickToFrameName and _G[sharedPositionDB.stickToFrameName]) then
		local stickToFrame = _G[sharedPositionDB.stickToFrameName]
		LibStickyFrames:SetFramePoints(self.frame, sharedPositionDB.stickPoint, stickToFrame, sharedPositionDB.stickToPoint, sharedPositionDB.stickToX, sharedPositionDB.stickToY)
--AutoBar:Print("AutoBar.Class.Bar.prototype:PositionLoad " .. tostring(barDB.stickToFrameName))
	else
		if (not sharedLayoutDB.alignButtons) then
			sharedLayoutDB.alignButtons = "3"
		end
		if (not sharedPositionDB.posX) then
			sharedPositionDB.posX = 300
			sharedPositionDB.posY = 360
		end
		local alignPoint = AutoBar.Class.Bar:GetAlignPoints(sharedLayoutDB.alignButtons)
		local x, y, s = sharedPositionDB.posX, sharedPositionDB.posY, self.frame:GetEffectiveScale()
		x, y = x/s, y/s
		self.frame:ClearAllPoints()
		self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
	end
end

function AutoBar.Class.Bar.prototype:PositionSave()
	local frame = self.frame
	local x, y = frame:GetLeft(), frame:GetBottom()
	local s = frame:GetEffectiveScale()
	x, y = x * s, y * s
	self.sharedPositionDB.posX = x
	self.sharedPositionDB.posY = y
end


-- Translate the alignButtons setting
function AutoBar.Class.Bar:GetAlignPoints(alignButtons)
	local alignPoint, columnRelativePoint, rowRelativePoint, signX, signY

	if (alignButtons == "3") then
		alignPoint = "BOTTOMLEFT"
		rowRelativePoint = "BOTTOMRIGHT"
		columnRelativePoint = "TOPLEFT"
		signX, signY = 1, 1
	elseif (alignButtons == "6") then
		alignPoint = "BOTTOMLEFT"
		rowRelativePoint = "BOTTOMRIGHT"
		columnRelativePoint = "TOPLEFT"
		signX, signY = 1, 1
	elseif (alignButtons == "9") then
		alignPoint = "BOTTOMRIGHT"
		rowRelativePoint = "BOTTOMLEFT"
		columnRelativePoint = "TOPRIGHT"
		signX, signY = -1, 1
	elseif (alignButtons == "8") then
		alignPoint = "BOTTOMRIGHT"
		rowRelativePoint = "BOTTOMLEFT"
		columnRelativePoint = "TOPRIGHT"
		signX, signY = -1, 1
	elseif (alignButtons == "5") then
		alignPoint = "BOTTOMLEFT"
		rowRelativePoint = "BOTTOMRIGHT"
		columnRelativePoint = "TOPLEFT"
		signX, signY = 1, 1
	elseif (alignButtons == "2") then
		alignPoint = "BOTTOMLEFT"
		rowRelativePoint = "BOTTOMRIGHT"
		columnRelativePoint = "TOPLEFT"
		signX, signY = 1, 1
	elseif (alignButtons == "7") then
		alignPoint = "TOPRIGHT"
		rowRelativePoint = "TOPLEFT"
		columnRelativePoint = "BOTTOMRIGHT"
		signX, signY = -1, -1
	elseif (alignButtons == "4") then
		alignPoint = "TOPLEFT"
		rowRelativePoint = "TOPRIGHT"
		columnRelativePoint = "BOTTOMLEFT"
		signX, signY = 1, -1
	elseif (alignButtons == "1") then
		alignPoint = "TOPLEFT"
		rowRelativePoint = "TOPRIGHT"
		columnRelativePoint = "BOTTOMLEFT"
		signX, signY = 1, -1
	end
	return alignPoint, rowRelativePoint, columnRelativePoint, signX, signY
end

--	["1"] = L["TOPLEFT"],
--	["2"] = L["LEFT"],
--	["3"] = L["BOTTOMLEFT"],
--	["4"] = L["TOP"],
--	["5"] = L["CENTER"],
--	["6"] = L["BOTTOM"],
--	["7"] = L["TOPRIGHT"],
--	["8"] = L["RIGHT"],
--	["9"] = L["BOTTOMRIGHT"],

-- Get offsets for any of the centered options of alignButtons
local function getCenterShift(alignButtons, signX, signY, rows, columns, displayedRows, displayedColumns, buttonWidth, buttonHeight, padding)
	local centerShiftX = 0
	local centerShiftY = 0

	local x = buttonWidth + padding
	local y = buttonHeight + padding

	if (alignButtons == "6") then
		centerShiftX = signX * (columns - displayedColumns) * ((buttonWidth + padding)) / 2
	elseif (alignButtons == "8") then
		centerShiftY = signY * (rows - displayedRows) * ((buttonHeight + padding)) / 2
	elseif (alignButtons == "5") then
		centerShiftX = signX * (columns - displayedColumns) * ((buttonWidth + padding)) / 2
		centerShiftY = signY * (rows - displayedRows) * ((buttonHeight + padding)) / 2
	elseif (alignButtons == "2") then
		centerShiftY = signY * (rows - displayedRows) * ((buttonHeight + padding)) / 2
	elseif (alignButtons == "4") then
		centerShiftX = signX * (columns - displayedColumns) * ((buttonWidth + padding)) / 2
	end
	return centerShiftX, centerShiftY
end


-- Lay out the buttons in the rows, columns grid specified
-- Collapse holes if collapseButtons is true
-- Obey the alignment options in alignButtons
function AutoBar.Class.Bar.prototype:RefreshButtonLayout()
	local buttons = # self.buttonList
	local rows = self.sharedLayoutDB.rows or 1
	local columns = self.sharedLayoutDB.columns or 24
	local buttonWidth = self.sharedLayoutDB.buttonWidth
	local buttonHeight = self.sharedLayoutDB.buttonHeight
	local padding = self.sharedLayoutDB.padding
	local alignButtons = self.sharedLayoutDB.alignButtons or "3"
	local alignPoint, rowRelativePoint, columnRelativePoint, signX, signY = AutoBar.Class.Bar:GetAlignPoints(alignButtons)
	local collapseButtons = self.sharedLayoutDB.collapseButtons
	local framePadding = math.max(0, padding)

	self.frame:SetWidth(buttonWidth * columns + ((columns + 1) * framePadding))
	self.frame:SetHeight(buttonHeight * rows + ((rows + 1) * framePadding))

	local anchorFrame = self.frame

	local activeButtonList = self.activeButtonList

	local displayedRows = math.floor((# activeButtonList - 1) / columns) + 1
	local displayedColumns = math.min(# activeButtonList, columns)
	local centerShiftX, centerShiftY = getCenterShift(alignButtons, signX, signY, rows, columns, displayedRows, displayedColumns, buttonWidth, buttonHeight, padding)

	local nButtons = # activeButtonList
	local frame
	for i = 1, nButtons do
		frame = activeButtonList[i].frame
		frame:ClearAllPoints()
		frame:SetHeight(buttonHeight)
		frame:SetWidth(buttonWidth)
		frame:SetScale(1)
		frame:SetPoint(alignPoint, anchorFrame, alignPoint, ((i - 1) % columns) * signX * (buttonWidth + padding) + signX * padding + centerShiftX, (math.floor((i - 1) / columns)) * signY * (buttonHeight + padding) + signY * padding + centerShiftY)
	end

	-- Dummy drag button for empty bar and end of bar drags
	if (AutoBar.moveButtonsMode) then
		local i = nButtons + 1
		frame = self.dragFrame
		frame:ClearAllPoints()
		local emptyColumns = columns - ((i - 1) % columns)
--AutoBar:Print("AutoBar.Class.Bar.prototype:RefreshButtonLayout columns  " .. tostring(columns) .. " i  " .. tostring(i) .. " emptyColumns  " .. tostring(emptyColumns))
		frame:SetWidth((buttonWidth + padding) * emptyColumns)
		frame:SetPoint(alignPoint, anchorFrame, alignPoint, ((i - 1) % columns) * signX * (buttonWidth + padding) + signX * padding + centerShiftX, (math.floor((i - 1) / columns)) * signY * (buttonHeight + padding) + signY * padding + centerShiftY)
	end
end


function AutoBar.Class.Bar.prototype:RefreshScale()
	self.frame:SetScale(self.sharedLayoutDB.scale or 1)
	self:PositionLoad()
end


function AutoBar.Class.Bar.prototype:RefreshAlpha()
	for index, button in pairs(self.buttonList) do
		button.frame:SetAlpha(self.sharedLayoutDB.alpha or 1)
	end
end


-- Remove a button from the Bar
function AutoBar.Class.Bar.prototype:ButtonRemove(buttonDB)
	for i, button in pairs(self.buttonList) do
		if (button.buttonDB == buttonDB) then
			button.frame:SetAttribute("category", nil)
			button.frame:SetAttribute("itemId", nil)
			button.frame:Hide()

			if (AutoBar.buttonListDisabled[buttonDB.buttonKey]) then
				AutoBar.buttonListDisabled[buttonDB.buttonKey] = nil
			end
			if (AutoBar.buttonList[buttonDB.buttonKey]) then
				AutoBar.buttonList[buttonDB.buttonKey] = nil
			end

			for j = i, # self.buttonList, 1 do
				if (self.buttonList[j + 1]) then
					self.buttonList[j] = self.buttonList[j + 1]
					self.buttonList[j + 1] = nil
				end
			end
			break
		end
	end
end


function AutoBar.Class.Bar.prototype:ShowBarOptions()
	if InCombatLockdown() then
		return
	end
	AutoBar:CreateOptionsAce3()
	self.optionsTable = AutoBar.optionsMain.args.bars.args[self.barKey]
	dewdrop:Open(self.frame, 'children', function() dewdrop:FeedAceOptionsTable(self.optionsTable) end, 'cursorX', true, 'cursorY', true)
end


-- Return a unique key to use
function AutoBar.Class.Bar:GetCustomKey(customBarName)
	local barKey = "AutoBarCustomBar" .. customBarName
	return barKey
end


-- Change name if possible.  return current name
function AutoBar.Class.Bar.prototype:ChangeName(newName)
	L[self.barKey] = newName
	self.barName = newName
	self.barKey = AutoBar.Class.Bar:GetCustomKey(newName)
end


function AutoBar.Class.Bar:NameExists(newName)
	local newKey = AutoBar.Class.Bar:GetCustomKey(newName)

	if (AutoBar.db.account.barList[newKey]) then
		return true
	end
	for classKey, classDB in pairs (AutoBarDB.classes) do
		if (classDB.barList[newKey]) then
			return true
		end
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		if (charDB.barList[newKey]) then
			return true
		end
	end

	return nil
end

-- Return a unique barName and barKey to use
function AutoBar.Class.Bar:GetNewName(baseName)
	local newName, newKey
	while true do
		newName = baseName .. AutoBar.db.account.keySeed
		newKey = AutoBar.Class.Bar:GetCustomKey(newName)

		AutoBar.db.account.keySeed = AutoBar.db.account.keySeed + 1
		if (not AutoBar.Class.Bar:NameExists(newName)) then
			break
		end
	end
	return newName, newKey
end

function AutoBar.Class.Bar:Delete(barKey)
	AutoBar.barList[barKey] = nil
	AutoBar.db.account.barList[barKey] = nil
	for classKey, classDB in pairs(AutoBarDB.classes) do
		classDB.barList[barKey] = nil
	end
	for charKey, charDB in pairs(AutoBarDB.chars) do
		charDB.barList[barKey] = nil
	end
end

function AutoBar.Class.Bar:DeleteButtonKey(barDBList, buttonKey)
	for barKey, barDB in pairs(barDBList) do
		local buttonKeys = barDB.buttonKeys
		for buttonIndex, buttonKey in ipairs(buttonKeys) do
			if (buttonKey == oldKey) then
				for index = buttonKey, # buttonKeys - 1, 1 do
					buttonKeys[index] = buttonKeys[index + 1]
				end
			end
		end
	end
end

function AutoBar.Class.Bar:RenameButtonKey(barDBList, oldKey, newKey)
	for barKey, barDB in pairs(barDBList) do
		local buttonKeys = barDB.buttonKeys
		for buttonIndex, buttonKey in pairs(buttonKeys) do
			if (buttonKey == oldKey) then
				buttonKeys[buttonIndex] = newKey
			end
		end
	end
end

function AutoBar.Class.Bar:RenameKey(barDBList, oldKey, newKey, newName)
	local barDB = barDBList[oldKey]
	if (barDB) then
		barDBList[newKey] = barDB
		barDBList[oldKey] = nil
		barDB.barKey = newKey
		if (barDB.name) then
			barDB.name = newName
		end
	end
end

function AutoBar.Class.Bar:Rename(oldKey, newName)
	local newKey = AutoBar.Class.Bar:GetCustomKey(newName)

	-- Rename Bar for all classes and characters
	AutoBar.Class.Bar:RenameKey(AutoBar.db.account.barList, oldKey, newKey, newName)
	for classKey, classDB in pairs (AutoBarDB.classes) do
		AutoBar.Class.Bar:RenameKey(classDB.barList, oldKey, newKey, newName)
	end
	for charKey, charDB in pairs (AutoBarDB.chars) do
		AutoBar.Class.Bar:RenameKey(charDB.barList, oldKey, newKey, newName)
	end

	-- Rename instantiated Bar
	local bar = AutoBar.barList[oldKey]
	if (bar) then
		AutoBar.barList[newKey] = bar
		AutoBar.barList[oldKey] = nil
	end
end

local barListVersion = 1
function AutoBar.Class.Bar:OptionsInitialize()
	if (not AutoBar.db.account.barList) then
		AutoBar.db.account.barList = {}
	end
	if (not AutoBar.db.class.barList) then
		AutoBar.db.class.barList = {}
	end
	if (not AutoBar.db.char.barList) then
		AutoBar.db.char.barList = {}
	end
	if LBF then
		LBF:RegisterSkinCallback("AutoBar", self.SkinChanged, self)
	end
end

function AutoBar.Class.Bar:OptionsReset()
	AutoBar.db.account.barList = {}
--	AutoBar.db.account.barListVersion = barListVersion
end

function AutoBar.Class.Bar:OptionsUpgrade()
--AutoBar:Print("AutoBar.Class.Bar:OptionsUpgrade start")
	if (not AutoBar.db.account.barListVersion) then
--		AutoBar.db.account.barListVersion = barListVersion
	elseif (AutoBar.db.account.barListVersion < barListVersion) then
--AutoBar:Print("AutoBar.Class.Bar:OptionsUpgrade AutoBar.db.account.barListVersion " .. tostring(AutoBar.db.account.barListVersion))
--		AutoBar.db.account.barListVersion = barListVersion
	end
end

--[[
/dump AutoBar.barList
/script AutoBarClassBarBasicFrame:Show()
/dump AutoBar.barList["AutoBarClassBar"]
--]]
