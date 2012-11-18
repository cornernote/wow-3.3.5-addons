--[[
	Slidebar AddOn for World of Warcraft (tm)
	Version: 5.9.4960 (WhackyWallaby)
	Revision: $Id: SlideMain.lua 272 2010-09-19 03:14:25Z kandoko $
	URL: http://auctioneeraddon.com/dl/

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit license to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]

local LIBRARY_VERSION_MAJOR = "SlideBar"
local LIBRARY_VERSION_MINOR = 10

--[[-----------------------------------------------------------------

LibStub is a simple versioning stub meant for use in Libraries.
See <http://www.wowwiki.com/LibStub> for more info.
LibStub is hereby placed in the Public Domain.
Credits:
    Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke

--]]-----------------------------------------------------------------
do
	local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2
	local LibStub = _G[LIBSTUB_MAJOR]

	if not LibStub or LibStub.minor < LIBSTUB_MINOR then
		LibStub = LibStub or {libs = {}, minors = {} }
		_G[LIBSTUB_MAJOR] = LibStub
		LibStub.minor = LIBSTUB_MINOR

		function LibStub:NewLibrary(major, minor)
			assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
			minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")

			local oldminor = self.minors[major]
			if oldminor and oldminor >= minor then return nil end
			self.minors[major], self.libs[major] = minor, self.libs[major] or {}
			return self.libs[major], oldminor
		end

		function LibStub:GetLibrary(major, silent)
			if not self.libs[major] and not silent then
				error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
			end
			return self.libs[major], self.minors[major]
		end

		function LibStub:IterateLibraries() return pairs(self.libs) end
		setmetatable(LibStub, { __call = LibStub.GetLibrary })
	end
end
--[End of LibStub]---------------------------------------------------

local lib = LibStub:NewLibrary(LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR)
if not lib then return end

LibStub("LibRevision"):Set("$URL: http://svn.norganna.org/libs/trunk/SlideBar/SlideMain.lua $","$Rev: 272 $","5.1.DEV.", 'auctioneer', 'libs')

-- Autoconvert existing nSideBar instances to SlideBar
if LibStub.libs.nSideBar then
	for k,v in pairs(LibStub.libs.nSideBar) do
		lib[k] = v
	end
	LibStub.libs.nSideBar = lib
	LibStub.minors.nSideBar = LIBRARY_VERSION_MINOR
end

if not lib.private then
	lib.private = {}
end

local private = lib.private
local frame
local ldb = LibStub("LibDataBroker-1.1")



--[[  API FUNCTIONS ]]--

-- Return the version of the current bar library
function lib.GetVersion()
	return LIBRARY_VERSION_MAJOR, LIBRARY_VERSION_MINOR;
end

-- Capture the bar and stop it from closing (must release!)
function lib.Capture()
	frame.PopTimer = 0.01
	frame.PopDirection = 1
	frame.captured = true
end

-- Release the bar if you have captured it
function lib.Release()
	if not frame.captured then return end
	frame.PopTimer = 0.75
	frame.PopDirection = -1
	frame.captured = nil
end

-- Capture the bar and stop it from closing before object
function lib.WaitFor(object)
	frame.PopTimer = 0.01
	frame.PopDirection = 1
	frame.captured = object
end

-- Add a button to the bar, where:
--   id = the id for this button (you will use this to reference the button).
--   texture = the path to your button's texture.
--   priority = determines your button's position in the list (lower numbers = earlier).
--   globalname = if specified, sets your button's "frame name".
--   quiet = stops nsidebar from popping open to let the user know there's a new button.
function lib.AddButton(id, texture, priority, globalname, quiet, dataobj)
	assert(type(id)=="string", "ButtonId must be a string")

	local button
	if not frame.buttons[id] then
		button = CreateFrame("Button", globalname, frame)
		button.frame = frame
		button.dataobj = dataobj
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0,0)
		button:SetWidth(30)
		button:SetHeight(30)
		button:RegisterForClicks("LeftButtonUp","RightButtonUp")
		button:SetScript("OnMouseDown", function (self, ...) private.MouseDown(self.frame, self, ...) end)
		button:SetScript("OnMouseUp", function (self, ...) private.MouseUp(self.frame, self, ...) end)
		button:SetScript("OnEnter", function (self, ...) private.PopOut(self.frame, self, ...) if dataobj and dataobj.OnEnter then dataobj.OnEnter(self) GameTooltip:Hide() end end) --LDB dataobjects can have possible on enter/leave scripts to execute as well
		button:SetScript("OnLeave", function (self, ...) private.PopBack(self.frame, self, ...) if dataobj and dataobj.OnLeave then dataobj.OnLeave(self) end end)
		button.icon = button:CreateTexture("", "BACKGROUND")
		button.icon:SetTexCoord(0.025, 0.975, 0.025, 0.975)
		button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 0,0)
		button.icon:SetWidth(30)
		button.icon:SetHeight(30)
		button.id = id
		frame.buttons[id] = button
	else
		button = frame.buttons[id]
	end
	if texture then
		button.icon:SetTexture(texture)
	end
	--LDB textures
	if dataobj then
		dataobj.button = button
		if dataobj.OnClick then
			button:SetScript("OnClick", dataobj.OnClick)
		end
		if dataobj.icon then
			button.icon:SetTexture(dataobj.icon)
			--check the desaturated method.  true if icon starts in a desaturated state
			if dataobj.iconDesaturated then
				button.icon:SetDesaturated(true)	
			end			
		end	
	end
	if priority or not button.priority then
		button.priority = priority or 200
	end
	button.removed = nil
	button:Show()

	if quiet then
		lib.ApplyLayout()
	else
		-- Show people that the button has popped in
		lib.FlashOpen(1.5)
	end
	return button
end

-- Returns an iterator over the button list (id, button)
function lib.IterateButtons()
	return pairs(frame.buttons)
end

-- Gets the button with the associated id (if it exists)
function lib.GetButton(id)
	return frame.buttons[id]
end

-- Removes the button with the associated id from the bar
function lib.RemoveButton(id)
	local button = frame.buttons[id]
	if not button then return end

	button:Hide()
	frame.buttons[id].removed = true
	lib.ApplyLayout()
end

-- Causes the button to be displayed (persists across sessions)
function lib.ShowButton(id)
	local button = frame.buttons[id]
	assert(button, "ButtonId "..id.." does not exist")
	SlideBarConfig[id..".hide"] = nil
	lib.ApplyLayout()
end

-- Causes the button to be hidden (persists across sessions)
function lib.HideButton(id)
	local button = frame.buttons[id]
	assert(button, "ButtonId "..id.." does not exist")
	SlideBarConfig[id..".hide"] = 1
	lib.ApplyLayout()
end

-- Causes the bar to flash open for a given number of seconds
function lib.FlashOpen(delay)
	private:PerformOpen()
	-- Schedule a close in 1.5 seconds
	frame.PopTimer = delay or 1.5
	frame.PopDirection = -1
end

-- Updates the bar's buttons and position, where
--   useLayout = if set, uses the cached layout, otherwise regenerates it;
--               if you hide, show, add or remove buttons, you should regenerate.
function lib.ApplyLayout(useLayout)
	local vis = SlideBarConfig.visibility or "0"
	local wide = SlideBarConfig.maxWidth or 12
	local side = SlideBarConfig.anchor or "right"
	local position = SlideBarConfig.position or "180"
	local active = SlideBarConfig.enabled or "1"

	for k,v in pairs(SlideBarConfig) do
		if not private.lastConfig[k] or private.lastConfig[k] ~= v then
			useLayout = false
		end
		private.lastConfig[k] = v
	end

	position = tonumber(position) or 180
	wide = tonumber(wide)
	side = side:lower()
	if not active or active == "0" or active == 0 then
		active = false
	else
		active = true
	end

	if not active then
		frame:Hide()
		return
	end

	if not lib.private.layout then
		lib.private.layout = {}
		useLayout = false
	end
	local layout = lib.private.layout

	if not useLayout then
		for i = 1, #layout do table.remove(layout) end
		for id, button in pairs(frame.buttons) do
			if not button.removed
			and not SlideBarConfig[id..".hide"] then
				table.insert(layout, button)
			elseif button:IsShown() then
				button:Hide()
			end
		end

		if (#layout == 0) then
			frame:Hide()
			return
		end

		table.sort(layout, private.buttonSort)
	end

	if (#layout == 0) then
		frame:Hide()
		return
	end

	local width = wide
	if (#layout < wide) then width = #layout end
	local height = math.floor((#layout - 1) / wide) + 1

	local distance = 9
	if (frame.isOpen) then
		distance = width * 32 + 10
		if (frame:GetAlpha() < 1) then
			UIFrameFadeIn(frame, 0.25, frame:GetAlpha(), 1)
		end
	elseif (vis == "1") then
		if (frame:GetAlpha() > 0.2) then
			UIFrameFadeOut(frame, 1.5, frame:GetAlpha(), 0.2)
		end
	end

	frame:ClearAllPoints()
	if (side == "top") then
		frame:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", position, -1*distance)
	elseif (side == "bottom") then
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", position, distance)
	elseif (side == "left") then
		frame:SetPoint("TOPRIGHT", UIParent, "TOPLEFT", distance, -1*position)
	elseif (side == "right") then
		frame:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -1*distance, -1*position)
	end

	if (useLayout) then return end

	frame.Tab:ClearAllPoints()
	if (side == "top" or side == "bottom") then
		frame:SetWidth(height * 32 + 10)
		frame:SetHeight(width * 32 + 18)
		if (side == "top") then
			frame.Tab:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
			frame.Tab:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		else
			frame.Tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
			frame.Tab:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
		end
		frame.Tab:SetHeight(3)
	else
		frame:SetWidth(width * 32 + 18)
		frame:SetHeight(height * 32 + 10)
		if (side == "right") then
			frame.Tab:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
			frame.Tab:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
		else
			frame.Tab:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
			frame.Tab:SetPoint("BOTTOM", frame, "BOTTOM", 0, 5)
		end
		frame.Tab:SetWidth(3)
	end
	frame:Show()

	local button
	for pos = 1, #layout do
		button = layout[pos]
		pos = pos - 1
		local row = math.floor(pos / wide)
		local col = pos % wide

		if (row == 0) then width = col end

		button:ClearAllPoints()
		if (side == "right") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", col*32+10, 0-(row*32+5))
		elseif (side == "left") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", col*32+10, 0-(row*32+5))
		elseif (side == "bottom") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", row*32+5, 0-(col*32+10))
		elseif (side == "top") then
			button:SetPoint("TOPLEFT", frame, "TOPLEFT", row*32+5, 0-(col*32+10))
		end

		if not button:IsShown() then
			button:Show()
		end
	end
end

--[[  END OF API FUNCTIONS ]]--

-- Private functions and variables follow, you shouldn't need to fiddle with these.

-- Setup our main frame (or reuse the old one)
if lib.frame then
	frame = lib.frame
else
	frame = CreateFrame("Frame", "", UIParent)
	frame:SetToplevel(true)
	--frame:SetClampedToScreen(true)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetHitRectInsets(-3, -3, -3, -3)
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	frame:SetBackdropColor(0,0,0, 0.5)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", function(...) private.PopOut(...) end)
	frame:SetScript("OnLeave", function(...) private.PopBack(...) end)
	frame:SetScript("OnMouseDown", function(...) private.BeginMove(...) end)
	frame:SetScript("OnMouseUp", function(...) private.EndMove(...) end)
	frame:SetScript("OnUpdate", function(...) private.Popper(...) end)
	frame:SetScript("OnEvent", function(self, event, arg, ...)
		if event == "PLAYER_LOGIN" then
			private.startCounter = 10
			private.GUI() --create the configuration GUI
			private.RescanLDBObjects() --scan LibDataBroker objects for any additions or changes.
			frame:UnregisterEvent("PLAYER_LOGIN")
		elseif event == "ADDON_LOADED" and arg == "SlideBar" then
			--removed the needlessly complex string variable system. Were not using Cvar or embeded anymore
			if not SlideBarConfig or type(SlideBarConfig) == "string" then 
				SlideBarConfig = {} 
			end
			frame:UnregisterEvent("ADDON_LOADED")
		end
	end)
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("ADDON_LOADED")
	
	frame.Tab = frame:CreateTexture()
	frame.Tab:SetTexture(0.98, 0.78, 0)
	frame.buttons = {}

	SLASH_NSIDEBAR1 = "/sbar"
	SLASH_NSIDEBAR2 = "/slidebar"
	SLASH_NSIDEBAR3 = "/nsb"
	SlashCmdList["NSIDEBAR"] = function(msg)
		private.CommandHandler(msg)
	end

	lib.frame = frame
end

-- Create a special tooltip just for us
if not lib.tooltip then
	lib.tooltip = CreateFrame("GameTooltip", "SlidebarTooltip", UIParent, "GameTooltipTemplate")
	local function hide_tip()
		lib.tooltip:Hide()
	end
	lib.tooltip.fadeInfo = {}
	function lib:SetTip(frame, ...)
		local n = select("#", ...)
		if n == 1 then
			-- Allow passing of tip lines as a single table
			local tip = select(1, ...)
			if type(tip) == "table" then
				lib:SetTip(frame, unpack(tip))
				return
			end
		end

		if not frame or n == 0 then
			lib.tooltip.fadeInfo.finishedFunc = hide_tip
			local curAlpha = lib.tooltip:GetAlpha()
			UIFrameFadeOut(lib.tooltip, 0.25, curAlpha, 0)
			lib.tooltip:SetAlpha(curAlpha)
			lib.tooltip.schedule = nil
			return
		end

		if lib.tooltip:GetAlpha() > 0 then
			-- Speed up this fade
			UIFrameFadeOut(lib.tooltip, 0.01, 0, 0)
			lib.tooltip:SetAlpha(0)
		end

		lib.tooltip:SetOwner(frame, "ANCHOR_NONE")
		lib.tooltip:ClearLines()

		local tip
		for i=1, n do
			tip = select(i, ...)
			tip = tostring(tip):gsub("{{", "|cff1fb3ff"):gsub("}}", "|r")
			lib.tooltip:AddLine(tostring(tip) or "", 1,1,0.5, 1)
		end
		lib.tooltip:Show()
		lib.tooltip:SetAlpha(0)
		lib.tooltip:SetBackdropColor(0,0,0, 1)
		--corrects tooltip overlaps
		local _, _, _, X, Y = frame:GetPoint("BOTTOM") --Offset of button
		local side = SlideBarConfig.anchor or "right"
		if side == "right" or side == "left" then
			lib.tooltip:SetPoint("TOP", frame.frame, "BOTTOMLEFT", X + 10, -5)
		else
			lib.tooltip:SetPoint("LEFT", frame.frame, "TOPRIGHT", 0, Y + -10)
		end
		lib.tooltip.schedule = GetTime() + 1
	end
	lib.tooltip:SetScript("OnUpdate", function()
		if lib.tooltip.schedule and GetTime() > lib.tooltip.schedule then
			local curAlpha = lib.tooltip:GetAlpha()
			UIFrameFadeIn(lib.tooltip, 0.33, curAlpha, 1)
			lib.tooltip:SetAlpha(curAlpha) -- Tooltips set alpha when they are shown, and UIFrameFadeIn does a :Show()
			lib.tooltip.schedule = nil
		end
	end)
	lib.tooltip:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true, tileSize = 32, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 }
	})
	lib.tooltip:SetBackdropColor(0,0,0.3, 1)
	--lib.tooltip:SetClampedToScreen(true)
	--no easy way to make our old and LDB tooltips play togather so created a new function
	function lib:SetTipLDB(frame, ...)
		if not frame  then
			lib.tooltip.fadeInfo.finishedFunc = hide_tip
			local curAlpha = lib.tooltip:GetAlpha()
			UIFrameFadeOut(lib.tooltip, 0.25, curAlpha, 0)
			lib.tooltip:SetAlpha(curAlpha)
			lib.tooltip.schedule = nil
			return
		end
		
		if not frame.dataobj then return end
		
		if lib.tooltip:GetAlpha() > 0 then
			-- Speed up this fade
			UIFrameFadeOut(lib.tooltip, 0.01, 0, 0)
			lib.tooltip:SetAlpha(0)
		end
		
		lib.tooltip:SetOwner(frame, "ANCHOR_NONE")
		lib.tooltip:ClearLines()
		
		if not frame.dataobj.OnTooltipShow then
			--fake TT
			lib.tooltip:AddLine(frame.dataobj.name)
		else
			frame.dataobj.OnTooltipShow(lib.tooltip)
		end
		
		lib.tooltip:Show()
		lib.tooltip:SetAlpha(0)
		lib.tooltip:SetBackdropColor(0,0,0, 1)
		local _, _, _, X, Y = frame:GetPoint("BOTTOM") --Offset of button
		local side = SlideBarConfig.anchor or "right"
		if side == "right" or side == "left" then
			lib.tooltip:SetPoint("TOP", frame.frame, "BOTTOMLEFT", X + 10, -5)
		else
			lib.tooltip:SetPoint("LEFT", frame.frame, "TOPRIGHT", 0, Y + -10)
		end
		lib.tooltip.schedule = GetTime() + .25 -- reduced show delay to .25 from 1 this is nicer IMO that "lag" like 1 sec delay
	end
end

private.lastConfig = {}

-- Functions to start and stop the sidebar drag
function private:BeginMove(...)
	if SlideBarConfig.locked == "1" then return end
	local button = ...
	if button == "LeftButton" then
		private.moving = true
	end
end

function private:EndMove(...)
	if private.moving then
		private.moving = nil
	end
end

-- Checks to see if the argument is a button
function private.IsButton(button)
	if not button then return end
	if type(button) ~= "table" then return end
	if button.id and button.icon then return true end
end

-- Functions to control the popping in and out of the bar
function private:PopOut(...)
	local button = ...
	self.PopTimer = 0.15
	self.PopDirection = 1
	if private.IsButton(button) then -- this is a button
		button.icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		if (button.tip) then
			lib:SetTip(button, button.tip)
		else
			lib:SetTipLDB(button) --LDB buttons use this tip method
		end
		if button.OnEnter then button:OnEnter(select(2, ...)) end
	end
end

function private:PopBack(...)
	local button = ...
	self.PopTimer = 0.75
	self.PopDirection = -1
	if private.IsButton(button) then -- this is a button
		lib:SetTip()
		button.icon:SetTexCoord(0.025, 0.975, 0.025, 0.975)
		if button.OnLeave then button:OnLeave(select(2, ...)) end
	end
end

function private:PerformOpen(useLayout)
	-- Pop Out
	frame.PopDirection = nil
	frame:ClearAllPoints()
	frame.isOpen = true
	lib.ApplyLayout(useLayout)
	for _,button in ipairs(frame.buttons) do
		if button.OnOpen then button:OnOpen() end
	end
end

function private:PerformClose(useLayout)
	-- Pop Back
	frame.PopDirection = nil
	frame:ClearAllPoints()
	frame.isOpen = false
	lib.ApplyLayout(useLayout)
	for _,button in ipairs(frame.buttons) do
		if button.OnOpen then button:OnClose() end
	end
end

function private:Popper(...)
	local duration = ...
	if private.moving then
		local side, pos = private.boxMover()
		SlideBarConfig.anchor = side
		SlideBarConfig.position = pos
		lib.ApplyLayout(true)
		return
	end
	if self.PopDirection then
		self.PopTimer = self.PopTimer - duration
		if self.PopTimer < 0 then
			if self.PopDirection > 0 then
				private:PerformOpen(true)
			else
				if frame.captured
				and type(frame.captured) == "table"
				and frame.captured:IsShown() then
					frame.captured = nil
				end
				if not frame.captured then
					private:PerformClose(true)
				end
			end
		end
	end

	if private.startCounter then
		private.startCounter = private.startCounter - 1
		if private.startCounter == 0 then
			lib.FlashOpen(5)
			private.startCounter = nil
		end
	end
end

-- Functions to make the icon enlarge/shrink when the mouse moves over it
function private:MouseDown(...)
	local button = ...
	if button then
		button.icon:SetTexCoord(0, 1, 0, 1)
	end
	if self.MouseDown then self:MouseDown(...) end
end

function private:MouseUp(...)
	local button = ...
	if button then
		button.icon:SetTexCoord(0.025, 0.975, 0.025, 0.975)
	end
	if self.MouseUp then self:MouseUp(...) end
end

-- Command processor
function private.CommandHandler(msg)
	local vis = SlideBarConfig.visibility or "0"
	local wide = SlideBarConfig.maxWidth or 12
	local side = SlideBarConfig.anchor or "right"
	local position = SlideBarConfig.position or "180"
	local active = SlideBarConfig.enabled or "1"

	if not active or active=="0" or active=="" then
		active = false
	else
		active = true
	end

	local save = false
	if (not msg or msg == "") then msg = "help" end
	local a, b, c = strsplit(" ", msg:lower())
	if (a == "help") then
		DEFAULT_CHAT_FRAME:AddMessage("/nsb top | left | bottom | right  |cff1020ff Set the anchor for the sidebar |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb config  |cff1020ff Display the GUI to show or hide buttons|r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb <n>  |cff1020ff Set the position for the sidebar |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb fadeout | nofade  |cff1020ff Set whether the sidebar fades or not |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb size <n>  |cff1020ff Set the number of icons before the bar wraps |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb lock | unlock  |cff1020ff enab |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb reset  |cff1020ff Reset the bar to factory defaults |r")
		DEFAULT_CHAT_FRAME:AddMessage("/nsb off | on | toggle  |cff1020ff Disable/Enable/Toggle bar's visibility |r")
		return
	end

	if a == "lock" then
		SlideBarConfig.locked = "1"
		save = true
	elseif a == "unlock" then
		SlideBarConfig.locked = "0"
		save = true
	end

	if a == "reset" then
		SlideBarConfig = {}
		save = true
	end

	if (a == "top")
	or (a == "left")
	or (a == "bottom")
	or (a == "right") then
		SlideBarConfig.anchor = a
		save = true
		if (tonumber(b)) then
			a, b, c = b, nil, nil
		end
	end
	if (tonumber(a)) then
		SlideBarConfig.position = math.min(math.abs(tonumber(a)), 1200)
		save = true
	end
	if (a == "fadeout" or a == "fade") then
		SlideBarConfig.visibility = "1"
		save = true
	elseif (a == "nofade") then
		SlideBarConfig.visibility = "0"
		save = true
	end
	if (a == "size") then
		if (tonumber(b)) then
			wide = math.floor(tonumber(b))
			if (wide < 1) then wide = 1 end
			SlideBarConfig.maxWidth = wide
			save = true
		end
	end

	if (a == "on") then
		SlideBarConfig.enabled = "1"
		save = true
	elseif (a == "off") then
		SlideBarConfig.enabled = "0"
		save = true
	elseif (a == "toggle") then
		if active then
			SlideBarConfig.enabled = "0"
		else
			SlideBarConfig.enabled = "1"
		end
		save = true
	end
	if (a == "config") then
		InterfaceOptionsFrame_OpenToCategory(frame.config)
	end
	if (save) then
		lib.ApplyLayout()
	end
end

-- Function to sort the buttons by priority during the layout phase
function private.buttonSort(a, b)
	if (a.priority ~= b.priority) then
		return a.priority < b.priority
	end
	return a.id < b.id
end

-- Function to work out where along the edge of the screen to position the bar
local SWITCH_TEXELS = 100 -- number of texels to do edge switches at
function private.boxMover()
	local curX, curY = GetCursorPosition()
	local uiScale = UIParent:GetEffectiveScale()
	local uiWidth, uiHeight = UIParent:GetWidth(), UIParent:GetHeight()
	curX, curY = curX / uiScale, curY / uiScale

	local anchor = SlideBarConfig.anchor or "right"

	if anchor == "top" and curY < uiHeight - SWITCH_TEXELS
	or anchor == "bottom" and curY > SWITCH_TEXELS then
		if curX < SWITCH_TEXELS then
			anchor = "left"
		elseif curX > uiWidth - SWITCH_TEXELS  then
			anchor = "right"
		end
	elseif anchor == "left" and curX > SWITCH_TEXELS
	or anchor == "right" and curX < uiWidth - SWITCH_TEXELS then
		if curY < SWITCH_TEXELS then
			anchor = "bottom"
		elseif curY > uiHeight - SWITCH_TEXELS  then
			anchor = "top"
		end
	end

	local pos
	if anchor == "top" or anchor == "bottom" then
		pos = curX
	else
		pos = uiHeight - curY
	end

	return anchor, pos - 16
end

--[[Use Blizzards config frame. We do not use the Configator lib]]
function private.GUI()
	if frame.config then return end
	
	frame.config = CreateFrame("Frame", nil, UIParent)
	frame.config:SetWidth(420)
	frame.config:SetHeight(400)
	frame.config:SetToplevel(true)
	frame.config:Hide()

	frame.config.name = "Norganna SlideBar"
	--add to Blizzards addon configuration menu
	InterfaceOptions_AddCategory(frame.config)

	frame.config.help = frame.config:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	frame.config.help:SetText("Click on a button above to Show or Hide it from the Slidebar addon")
	frame.config.help:SetPoint("TOPLEFT", frame.config,"LEFT" , 15, 150)
	frame.config.help:SetPoint("BOTTOMRIGHT", frame.config,"BOTTOMRIGHT" , -15, 0)

	frame.config.enableCheck = CreateFrame("CheckButton", "nSlideBarenableCheck", frame.config, "InterfaceOptionsCheckButtonTemplate")
	nSlideBarenableCheckText:SetText("Enable SlideBar")
	frame.config.enableCheck:SetPoint("LEFT", frame.config, "LEFT", 10, -80)
	frame.config.enableCheck:SetChecked(SlideBarConfig.enabled or "1")
	function frame.config.enableCheck.setFunc(state)
		SlideBarConfig.enabled = state
		lib.ApplyLayout()
	end

	frame.config.searchBox = CreateFrame("EditBox", "nSlideBarLengthEditBox", frame.config, "InputBoxTemplate") --has to have a name or the template bugs
	frame.config.searchBox:SetMaxLetters(2)
	frame.config.searchBox:SetNumeric(true)
	local wide = SlideBarConfig.maxWidth or 12
	frame.config.searchBox:SetNumber(wide)
	frame.config.searchBox:SetAutoFocus(false)
	frame.config.searchBox:SetPoint("TOP", frame.config.enableCheck, "BOTTOM", 40,-10)
	frame.config.searchBox:SetWidth(22)
	frame.config.searchBox:SetHeight(15)
	frame.config.searchBox:SetScript("OnEnterPressed", function(self)
									EditBox_ClearFocus(self)
									local wide = self:GetNumber()
									if (wide < 1) then wide = 1 end
									SlideBarConfig.maxWidth = wide
									lib.ApplyLayout()
									lib.FlashOpen(5)
							end)
	frame.config.searchBox.help = frame.config:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.config.searchBox.help:SetPoint("LEFT", frame.config.searchBox, "RIGHT", 5, 0)
	frame.config.searchBox.help:SetText("Number of buttons before a new row is started.")
							
	frame.config.lockCheck = CreateFrame("CheckButton", "nSlideBarlockCheck", frame.config, "InterfaceOptionsCheckButtonTemplate")
	nSlideBarlockCheckText:SetText("Lock the Bar's location")
	frame.config.lockCheck:SetPoint("TOP", frame.config.searchBox, "BOTTOM", 0, -10)
	function frame.config.lockCheck.setFunc(state)
		SlideBarConfig.locked = state
		lib.ApplyLayout()
	end
	frame.config.lockCheck:SetChecked(SlideBarConfig.locked)


	frame.config.fadeCheck = CreateFrame("CheckButton", "nSlideBarfadeCheck", frame.config, "InterfaceOptionsCheckButtonTemplate")
	nSlideBarfadeCheckText:SetText("Fade the slidebar when not in use.")
	frame.config.fadeCheck:SetPoint("TOP",frame.config.lockCheck, "BOTTOM")
	function frame.config.fadeCheck.setFunc(state)
		SlideBarConfig.visibility = state
		lib.ApplyLayout()
	end
	frame.config.fadeCheck:SetChecked(SlideBarConfig.visibility)

	frame.config.reset = CreateFrame("Button", nil, frame.config, "OptionsButtonTemplate")
	frame.config.reset:SetWidth(160)
	frame.config.reset:SetPoint("TOPLEFT",frame.config.fadeCheck, "BOTTOM", -50,-5)
	frame.config.reset:SetText("RESET ALL SETTINGS")
	frame.config.reset:SetScript("OnClick", function() 
						      SlideBarConfig = {} 
						      lib.ApplyLayout() 
						end)



	frame.config.buttons = {}
	function private.createIconGUI()
		local pos = #frame.config.buttons + 1
		local button = CreateFrame("Button", nil, frame.config, "PopupButtonTemplate")
		button:SetScript("OnClick", function(self)
						lib.FlashOpen(5)
						if self:GetNormalTexture():IsDesaturated() then
							self:GetNormalTexture():SetDesaturated(false)
							self.tex:Hide()
							lib.ShowButton(self.name)
						elseif self:GetNormalTexture() then
							self:GetNormalTexture():SetDesaturated(true)
							self.tex:Show()
							lib.HideButton(self.name)
						end
					end)
		button.pos = pos
		button:SetScale(.8)
		
		--should we use a X texture
		button.tex = button:CreateTexture()
		button.tex:SetTexture("Interface\\WorldMap\\X_Mark_64")
		button.tex:SetPoint("TOPLEFT", button, "TOPLEFT",-5,5)
		button.tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -20, 10)
		button.tex:SetTexCoord(0,0.5,0.5,1)
		button.tex:SetDrawLayer("OVERLAY")
		button.tex:Hide()
			
		frame.config.buttons[pos] = button
		return button
	end
	--Was gonna make this dynamic depending on how user resized window. Decided on static for now
	do
		for pos = 1, 50 do
			private.createIconGUI()			
		end

		local width = frame.config:GetWidth()
		local height = frame.config:GetHeight()
		local spacer = 5
		local row = 0
		local column = 0
		local total = 0
		local button = frame.config.buttons
		
		--create 50 slots for our button icons
		for pos = 1, #button do
			if total + 45 > width then
				column =  0
				row = row + 45 + spacer
				total = 0
			end
			--button[pos]:ClearAllPoints()
			
			if column == 0 then
				button[pos]:SetPoint("TOPLEFT", frame.config, "TOPLEFT",  column+20, -row - 20)
			else
				button[pos]:SetPoint("TOPLEFT", button[pos-1], "TOPLEFT",  45 + spacer, 0)
			end
			
			column = column + 36 + spacer
			total = total + 36 + spacer
		end
		
	end

	--apply GUI layout to match slidebars button order
	--Blizzards frame calls this when options are opened
	function frame.config.refresh()
		local layout = {}
		for id, button in pairs(frame.buttons) do
			table.insert(layout, button)
		end
		table.sort(layout, private.buttonSort)
		
		local GUI = frame.config.buttons
		for pos = 1, #GUI do
			local button = layout[pos]
			if button then
				if  GUI[pos] and button.icon then
					GUI[pos]:Enable()
					GUI[pos]:SetNormalTexture(button.icon:GetTexture())
					GUI[pos].name = button.id
					if SlideBarConfig[button.id..".hide"] then
						GUI[pos]:GetNormalTexture():SetDesaturated(true)
						if GUI[pos].tex then
							GUI[pos].tex:Hide()
						end
					end
				else
					GUI[pos]:Disable()
				end
			else
				GUI[pos]:Disable()
			end
		end
	end
	
	--[[LibDataBroker setup Functions]]
	--core function adds LDB objects to our bar
	function private:LibDataBroker_DataObjectCreated(event, name, dataobj)
		if not name or not dataobj or not dataobj.type then return end
		if dataobj.type == "launcher" then
			lib.AddButton(name, nil, nil, nil, nil, dataobj)
		end	
	end
	ldb.RegisterCallback(private, "LibDataBroker_DataObjectCreated")
	--add any LDB objects created before we loaded. Not all LDB objects initialize everything when they create themselves. So we need to recan after all are loded to get all methods
	function private.RescanLDBObjects()
		for name, dataobj in ldb:DataObjectIterator() do
			private:LibDataBroker_DataObjectCreated(nil, name, dataobj)
		end
	end
end

--[[not used atm. Will allow buttons to me dragged when we add user ordering to the button layout
function  private.dragButton(event, self)
	if event == "start" then
		frame.config.start = self
	else
		--switch textures
		local tex1 = frame.config.start:GetNormalTexture():GetTexture() --gets texture ref then texture path  :GetNormalTexture():GetTexture()
		local tex2 = self:GetNormalTexture():GetTexture()
		
		self:SetNormalTexture(tex1)
		frame.config.start:SetNormalTexture(tex2)
	end
end]]
