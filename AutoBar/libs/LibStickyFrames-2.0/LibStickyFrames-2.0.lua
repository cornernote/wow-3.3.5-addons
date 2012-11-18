--[[
Name: LibStickyFrames-2.0
Revision: $Rev: 37 $
Author(s): Sorata,Toadkiller,Cladhaire,Tuller,Shadowed,JoshBorke,rophy123,Tekkub
Website: http://www.wowace.com/wiki/LibStickyFrames-2.0
Description: A library to manage snappy dragging & sticking of frames across multiple mods.
Dependencies: none
--]]

local MAJOR = "LibStickyFrames-2.0"
local MINOR = 90000 + tonumber(("$Revision: 37 $"):match("(%d+)"))

--[[
A library to manage snappy dragging & sticking of frames across multiple mods.

=The vision:=
Many mods have invisible display areas or otherwise draggable frames that I need to lay out in my UI so that they do not overlap & thus can exist in harmony.  All mods with such frames will one day use this lib to accomplish the following:
* When I start dragging a bar around in Bartender3 or AutoBar, or the raid warnings frames from Deadly Boss Mods, BigWigs or other display frames from Quartz, SCT, etc. then all these frames go green & red and so on & I can see exactly where I can drag to & thus snap to or stick to so I can lay out my interface with or without overlap as I desire.
* Once the sticking code goes in it is even more beautiful since I can just drag a few frames around at that point without destroying my careful layout or getting hosed with a ui scale change...
* Since the dragging interface is standard, I am not uselessly trying ctrl-alt-shift-left&right-button drag just to move some frame around.
* All these hard to access frames suddenly become easily accesible.

=Design goals:=
* A consistent drag experience across implementing mods.
* Snapping & sticking to all registered frames + select Blizzard frames.
* Visibility & Labeling of all frames of interest while dragging (except for the Blizzard frames?)
* Private Clusters
** Private Clusters stick only to themselves.
** Private Clusters have a supplied or calculated clusterFrame which participates in general sticking.
* Grouped Frames
** Groups of frames that are stuck together can be dragged by dragging any member of the group
* Consistent interface for all these operations, including modifier keys for sticking or not snapping or unsticking etc.

=Planned Features:=
* Make frame snapping more intelligent

=Origin of the Species=
This is based on code from:
[http://www.wowinterface.com/downloads/info4674-StickyFrames.html StickyFrames] by Cladhaire.
[http://www.wowwiki.com/LegoBlock LegoBlock] by Tekkub & JoshBorke.
FlyPaper by Tuller.
All mushed together in a terrible transporter accident producing the thing otherwise known as LibStickyFrames by Toadkiller enhanced by Sorata.
--]]

local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end -- no upgrade needed

local _G = _G

-- CallbackHandler
lib.events = lib.events or _G.LibStub("CallbackHandler-1.0"):New(lib)
-- Current Sticky Group
lib.group = lib.group or false
-- Embeded Frames
lib.registered = lib.registered or {}
lib.registered[_G.MainMenuBarArtFrame] = true
lib.registered[_G.CharacterMicroButton] = true
lib.registered[_G.ChatFrameMenuButton] = true
--lib.registered[_G.MainMenuBar] = true
lib.registered[_G.ChatFrame1] = true
-- Frame Insets
lib.insets = lib.insets or {}
lib.insets[_G.CharacterMicroButton] = { 3, 23, -181, 1 }
lib.insets[_G.ChatFrameMenuButton] = { 3, 3, 3, -91 }
lib.insets[_G.MainMenuBar] = { 7, 0, 40, 0 }
lib.insets[_G.ChatFrame1] = { -2, -4, -2, -6, }
-- Enabled Frames
lib.enabled = lib.enabled or {}
-- Hidden Frames
lib.hidden = lib.hidden or {}
-- Frame Points
lib.points = lib.points or {}
-- Frame Overlays
lib.overlays = lib.overlays or {}
lib.overlayCache = lib.overlayCache or {}
-- Frame Groups
lib.groups = lib.groups or {}
-- Frame Texts
lib.texts = lib.texts or {}
-- Table to temporarily hold any existing OnUpdate scripts.
lib.scripts = lib.scripts or {}

-- Snap range in pixels.  not saved, but mods can provide an interface to change it
lib.snapRangeDefault = 5
lib.snapRange = lib.snapRange or lib.snapRangeDefault

-- Key to hold down for no snapping.  Set to IsShiftKeyDown, IsControlKeyDown or IsAltKeyDown functions.
lib.IsSnapDisableKeyDown = lib.IsSnapDisableKeyDown or IsShiftKeyDown

-- Default color values to use.
lib.colorHidden = lib.colorHidden or { 1, 0, 0, 0.5 }
lib.colorEnabled = lib.colorEnabled or { 0, 1, 0, 0.5 }
lib.colorDisabled = lib.colorDisabled or { 0, 0, 1, 0.5 }

-- Default color values for snappable frames
lib.colorSnapEnabled = lib.colorSnapEnabled or { 0, 1, 0, 0.5 }
lib.colorSnapDisabled = lib.colorSnapDisabled or { 0, 0, 1, 0.5 }

-- Default border color values for hovering over the frame
lib.colorBorderEnabled = lib.colorBorderEnabled or { 0.5, 0.5, 0, 1 }
lib.colorBorderDisabled = lib.colorBorderDisabled or { 0, 0, 0, 0 }

--[[
Locals
--]]

local tinsert = table.insert
local new, del
do
	local cache = setmetatable({},{__mode='k'})
	function new(...)
		local t = next(cache)
		if t then
			cache[t] = nil
			for i = 1, select("#", ...) do
				tinsert(t, (select(i, ...)))
			end
			return t
		else
			return {...}
		end
	end
	function del(t)
		if type(t) == "table" then
			for k, v in pairs(t) do
				t[k] = nil
			end
			cache[t] = true
		end
		return nil
	end
end

local events = lib.events
local registered = lib.registered
local insets = lib.insets
local enabled = lib.enabled
local hidden = lib.hidden
local points = lib.points
local overlays = lib.overlays
local overlayCache = lib.overlayCache
local groups = lib.groups
local texts = lib.texts
local scripts = lib.scripts
local colorHidden = lib.colorHidden
local colorEnabled = lib.colorEnabled
local colorDisabled = lib.colorDisabled
local colorBorderEnabled = lib.colorBorderEnabled
local colorBorderDisabled = lib.colorBorderDisabled
local colorSnapEnabled = lib.colorSnapEnabled
local colorSnapDisabled = lib.colorSnapDisabled

local SetGroup
local GetGroup

local SetColorEnabled
local GetColorEnabled
local SetColorDisabled
local GetColorDisabled
local SetColorHidden
local GetColorHidden
local SetColorSnapEnabled
local GetColorSnapEnabled
local SetColorSnapDisabled
local GetColorSnapDisabled
local SetColorBorderEnabled
local GetColorBorderEnabled
local GetColorBorderDisabled
local GetColorBorderDisabled

local RegisterFrame
local IsRegisteredFrame
local UnregisterFrame
local AnchorFrame
local SetFrameInsets
local GetFrameInsets
local SetFrameGroup
local GetFrameGroup
local IsFrameGroup
local InFrameGroup
local SetFramePoints
local GetFramePoints
local GetFrameOverlay
local SetFrameText
local SetFrameText
local SetFrameEnabled
local IsFrameEnabled
local SetFrameHidden
local IsFrameHidden
local StartFrameMoving
local IsFrameMoving
local StopFrameMoving

local RetrieveOverlay
local StoreOverlay
local UpdateFrameColor
local GetFramePointsPosition
local IsOverlapping
local GetInsetOffset
local CanSnapFrame
local IsDependentOnFrame
local CanAttach
local MovingUpdate
local UpdateFrameGroup

--[[
overlay = RetrieveOverlay(frame) - Retrieves an overlay from the cache or creates one if
the cache is empty and setups up the overlay with the frames options.

frame: the frame the overlay is overlaying
--]]
function RetrieveOverlay(frame)
	local overlay = next(overlayCache)
	if overlay then
		overlayCache[overlay] = nil
	else
		overlay = CreateFrame("Button", nil, frame)
		overlay:EnableMouse(true)
		overlay:RegisterForDrag("LeftButton")
		overlay:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")
		overlay:SetToplevel(true)
		overlay:SetBackdrop({ bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tile = true, tileSize = 16, edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16, insets = {}, })
		overlay:Hide()
		local anchor = overlay:CreateTexture(nil, "ARTWORK")
		anchor:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
		anchor:SetVertexColor(1, 0, 0, 0.5)
		anchor:ClearAllPoints()
		anchor:Hide()
		overlay.anchor = anchor
		local text = overlay:CreateFontString(nil, "OVERLAY")
		text:SetFontObject(GameFontNormal)
		text:ClearAllPoints()
		text:SetPoint("CENTER", overlay, "CENTER", 0,0)
		overlay.text = text
	end
	overlays[frame] = overlay
	overlay.target = frame
	overlay:SetParent(UIParent)
	overlay:SetAllPoints(frame)
	overlay:SetFrameStrata("DIALOG")
	overlay:SetScript("OnShow", nil)
	overlay:SetScript("OnClick", nil)
	overlay:SetScript("OnEnter", nil)
	overlay:SetScript("OnLeave", nil)
	overlay:SetScript("OnDragStart", nil)
	overlay:SetScript("OnDragStop", nil)
	SetFrameEnabled(lib, frame, IsFrameEnabled(lib, frame))
	SetFrameInsets(lib, frame, GetFrameInsets(lib, frame))
	SetFrameText(lib, frame, GetFrameText(lib, frame))
	return overlay
end

--[[
StoreOverlay(frame) - Stores an overlay attached to a frame.
--]]
function StoreOverlay(frame)
	local overlay = overlays[frame]
	if overlay then
		overlay.target = nil
		overlay:ClearAllPoints()
		overlay:SetParent(nil)
		overlay:Hide()
		overlays[frame] = nil
		overlayCache[overlay] = true
	end
end

--[[
GetFramePointsPosition(frame) - Returns the position of the frames points with insets taken into account
--]]
function GetFramePointsPosition(frame)
	local l, t, r, b = GetFrameInsets(lib, frame)
	return frame:GetLeft() + l, frame:GetTop() - t, frame:GetRight() - r, frame:GetBottom() + b
end

--[[
isOverlapping - IsOverlapping(frameA, frameB) - Determines the overlap between two
frames. Returns true if the frames overlap anywhere, or false if they do not. Insets are
automatically taken into account.

frameA: frame to check
frameB: frame that is being overlapped
--]]
function IsOverlapping(frameA, frameB)
	local lA, tA, rA, bA = GetFramePointsPosition(frameA)
	local lB, tB, rB, bB = GetFramePointsPosition(frameB)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	return  ((lA * sA) < (rB * sB))
		and ((lB * sB) < (rA * sA))
		and ((bA * sA) < (tB * sB))
		and ((bB * sB) < (tA * sA))
end

--[[
x, y = GetInsetOffset(frameA, pointA, frameB, pointB) - This returns the x and y offsets
based on the frame insets and the anchor points

frameA:	The frame to be anchored
pointA:	The point on frameA to be attached
frameB:	The frame being anchored to
pointB:	The point on frameB to be attached to
--]]
function GetInsetOffset(frameA, pointA, frameB, pointB)
	pointA, pointB = pointA:lower(), pointB:lower()
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()

	local lA, tA, rA, bA = GetFrameInsets(lib, frameA)
	lA, tA, rA, bA = lA * sA, tA * sA, rA * sA, bA * sA
	local isLA = pointA == "left" or pointA == "topleft" or pointA == "bottomleft"
	local isRA = pointA == "right" or pointA == "topright" or pointA == "bottomright"
	local isTA = pointA == "top" or pointA == "topleft" or pointA == "topright"
	local isBA = pointA == "bottom" or pointA == "bottomleft" or pointA == "bottomright"
	if not isLA then
		lA = 0
	end
	if not isRA then
		rA = 0
	end
	if not isTA then
		tA = 0
	end
	if not isBA then
		bA = 0
	end

	local lB, tB, rB, bB = GetFrameInsets(lib, frameB)
	lB, tB, rB, bB = lB * sB, tB * sB, rB * sB, bB * sB
	local isLB = pointB == "left" or pointB == "topleft" or pointB == "bottomleft"
	local isRB = pointB == "right" or pointB == "topright" or pointB == "bottomright"
	local isTB = pointB == "top" or pointB == "topleft" or pointB == "topright"
	local isBB = pointB == "bottom" or pointB == "bottomleft" or pointB == "bottomright"
	if not isLB then
		lB = 0
	end
	if not isRB then
		rB = 0
	end
	if not isTB then
		tB = 0
	end
	if not isBB then
		bB = 0
	end

	local l, t, r, b
	if isLA and isLB then
		l = lA - lB
	else
		l = lA + lB
	end
	if isTA and isTB then
		t = tA - tB
	else
		t = tA + tB
	end
	if isRA and isRB then
		r = rA - rB
	else
		r = rA + rB
	end
	if isBA and isBB then
		b = bA - bB
	else
		b = bA + bB
	end

	local x = (l + r) / sA
	if isLA then
		x = x * -1
	end
	local y = (b + t) / sA
	if isBA then
		y = y * -1
	end
	
	return x, y
end

--[[
canSnap = CanSnapFrame(frameA, frameB) - This is called when finding an overlap between two sticky
frames. If frameA is near a sticky point of frameB, then it will snap to that point and
return true. If there is no sticky point collision, it returns nil so we can test other
frames for stickyness.
--]]
function CanSnapFrame(frameA, frameB)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	local xA, yA = frameA:GetCenter()
	local xB, yB = frameB:GetCenter()
	xA, yA, xB, yB = xA * sA, yA * sA, xB * sB, yB * sB

	-- Grab the points of each frame, for easier comparison
	local lA, tA, rA, bA = GetFramePointsPosition(frameA)
	lA, tA, rA, bA = lA * sA, tA * sA, rA * sA, bA * sA
	local lB, tB, rB, bB = GetFramePointsPosition(frameB)
	lB, tB, rB, bB = lB * sB, tB * sB, rB * sB, bB * sB

	local snapRange = lib.snapRange

	local pointA, pointB
	local x, y = 0, 0

	-- If we are within snapRange pixels of the point of a sticky frame then snap to the point.
	if lA > (rB - snapRange) then		-- Left stickyness
		if (yA < (yB + snapRange)) and (yA > (yB - snapRange)) then
			pointA = "left"
			pointB = "right"
		elseif tA > (tB - snapRange) and tA < (tB + snapRange) then
			pointA = "topleft"
			pointB = "topright"
		elseif bA < (bB + snapRange) and bA > (bB - snapRange) then
			pointA = "bottomleft"
			pointB = "bottomright"
		else
			pointA = "left"
			pointB = "right"
			if (yA > (yB + snapRange)) or (yA < (yB - snapRange)) then
				y = (yA - yB) / sA
			end
		end
	elseif rA < (lB + snapRange) then	-- Right stickyness
		if (yA < (yB + snapRange)) and (yA > (yB - snapRange)) then
			pointA = "right"
			pointB = "left"
		elseif tA > (tB - snapRange) and tA < (tB + snapRange) then
			pointA = "topright"
			pointB = "topleft"
		elseif bA < (bB + snapRange) and bA > (bB - snapRange) then
			pointA = "bottomright"
			pointB = "bottomleft"
		else
			pointA = "right"
			pointB = "left"
			if (yA > (yB + snapRange)) or (yA < (yB - snapRange)) then
				y = (yA - yB) / sA
			end
		end
	elseif bA > (tB - snapRange) then	-- Bottom stickyness
		if (xA < (xB + snapRange)) and (xA > (xB - snapRange)) then
			pointA = "bottom"
			pointB = "top"
		elseif lA > (lB - snapRange) and lA < (lB + snapRange) then
			pointA = "bottomleft"
			pointB = "topleft"
		elseif rA < (rB + snapRange) and rA > (rB - snapRange) then
			pointA = "bottomright"
			pointB = "topright"
		else
			pointA = "bottom"
			pointB = "top"
			if (xA > (xB + snapRange)) or (xA < (xB - snapRange)) then
				x = (xA - xB) / sA
			end
		end
	elseif tA < (bB + snapRange) then	-- Top stickyness
		if (xA < (xB + snapRange)) and (xA > (xB - snapRange)) then
			pointA = "top"
			pointB = "bottom"
		elseif lA > (lB - snapRange) and lA < (lB + snapRange) then
			pointA = "topleft"
			pointB = "bottomleft"
		elseif rA < (rB + snapRange) and rA > (rB - snapRange) then
			pointA = "topright"
			pointB = "bottomright"
		else
			pointA = "top"
			pointB = "bottom"
			if (xA > (xB + snapRange)) or (xA < (xB - snapRange)) then
				x = (xA - xB) / sA
			end
		end
	end

	-- Snap to the found point
	if pointA then
		SetFramePoints(lib, frameA, pointA, frameB, pointB, x, y)

		-- Remember Sticking stuff
		lib.point = pointA
		lib.frameTo = frameB
		lib.pointTo = pointB
		lib.x = x
		lib.y = y
		events:Fire("OnStickToFrame", frameA, pointA, frameB, pointB, x, y)
		return true
	end
end

--[[
isDependent = IsDependentOnFrame(frameA, frameB) - FLYPAPER - Handles sticking frames to
eachother using relative positioning credit to Tuller for this
--]]
function IsDependentOnFrame(frameA, frameB)
	if not frameA or not frameB then
		return
	elseif frameA == frameB then
		return true
	end

	local points = frameA:GetNumPoints()
	for i = 1, points do
		local _, frameC = frameA:GetPoint(i)
		if IsDependentOnFrame(frameC, frameB) then
			return true
		end
	end
end

--[[
canAttach = CanAttach(frameA, frameB) - returns true if its actually possible to attach
the two frames without error
--]]
function CanAttach(frameA, frameB)
	if frameA and frameB and frameA:GetNumPoints() ~= 0 and frameB:GetNumPoints() ~= 0 and frameA:GetWidth() ~= 0 and frameA:GetHeight() ~= 0 and frameB:GetWidth() ~= 0 and frameB:GetHeight() ~= 0 and not IsDependentOnFrame(frameB, frameA) then
		return true
	end
end

--[[
MovingUpdate() - The update function for moving the frame
--]]
function MovingUpdate()
	local frame = lib.frame
	local x, y = GetCursorPosition()
	local s = frame:GetEffectiveScale()
	x, y = (x / s) + lib.cursorX, (y / s) + lib.cursorY

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

	if not lib.IsSnapDisableKeyDown() then
		local group = GetFrameGroup(lib, frame)
		for frameB in pairs(registered) do
			if frame ~= frameB and frameB:IsVisible() and (IsFrameGroup(lib, frameB, group) or InFrameGroup(lib, frameB, group)) and CanAttach(frame, frameB) and IsOverlapping(frame, frameB) and CanSnapFrame(frame, frameB) then
				return
			end
		end
	end

	lib.point = nil
	lib.frameTo = nil
	lib.pointTo = nil
	lib.x = nil
	lib.y = nil
	SetFramePoints(lib, frame)
end

do
	local function onShow(self)
		UpdateFrameColor(self.target)
	end
	local onEnter = onShow
	local onLeave = onShow
	local function onClick(self, button)
		local frame = self.target
		if IsMouseButtonDown(button) then
			local x, y = GetCursorPosition()
			local xA, yA = frame:GetCenter()
			local sA = frame:GetEffectiveScale()
			lib.clickX = (xA * sA) - x
			lib.clickY = (yA * sA) - y
		else
			lib.clickX = nil
			lib.clickY = nil
			events:Fire("OnClick", frame, button)
		end
	end
	local function onDragStart(self)
		StartFrameMoving(lib, self.target)
	end
	local function onDragStop(self)
		if IsFrameMoving(lib, self.target) then
			StopFrameMoving(lib)
		end
	end
	--[[
	UpdateFrameGroup(frame) - Shows or hides overlays and registered frames that are
	hidden based on groupping.
	--]]
	function UpdateFrameGroup(frame)
		local overlay
		local group = lib.group
		local isGroup = IsFrameGroup(lib, frame, group)
		if group and (isGroup or InFrameGroup(lib, frame, group)) then
			overlay = GetFrameOverlay(lib, frame)

			overlay:SetScript("OnShow", onShow)
			overlay:SetScript("OnClick", onClick)
			if isGroup and IsFrameEnabled(lib, frame) then
				overlay:SetScript("OnEnter", onEnter)
				overlay:SetScript("OnLeave", onLeave)
				overlay:SetScript("OnDragStart", onDragStart)
				overlay:SetScript("OnDragStop", onDragStop)
			else
				overlay:SetScript("OnEnter", nil)
				overlay:SetScript("OnLeave", nil)
				overlay:SetScript("OnDragStart", nil)
				overlay:SetScript("OnDragStop", nil)
			end

			if not frame:IsShown() then
				SetFrameHidden(lib, frame, true)
				frame:Show()
			elseif overlay:IsShown() then
				UpdateFrameColor(frame)
			else
				overlay:Show()
			end
			return true
		else
			StoreOverlay(frame)
			if IsFrameMoving(lib, frame) then
				StopFrameMoving(lib, frame)
			end
			if IsFrameHidden(lib, frame) then
				frame:Hide()
				SetFrameHidden(lib, frame, false)
			end
		end
	end
end

--[[
Updates the color of the overlay depending on the state and grouping of the frame.
--]]
function UpdateFrameColor(frame)
	local overlay = GetFrameOverlay(lib, frame, true)
	if not overlay then return end
	local color, borderColor
	if IsFrameMoving(lib, frame) or GetMouseFocus() == overlay then
		borderColor = colorBorderEnabled
	else
		borderColor = colorBorderDisabled
	end
	local movingFrame = lib.frame
	if movingFrame then
		local group = GetFrameGroup(lib, movingFrame)
		if IsFrameGroup(lib, frame, group) or InFrameGroup(lib, frame, group) then
			color = colorSnapEnabled
		else
			color = colorSnapDisabled
		end
	elseif IsFrameHidden(lib, frame) or not frame:IsShown() then
		color = colorHidden
	elseif IsFrameGroup(lib, frame, lib.group) and IsFrameEnabled(lib, frame) then
		color = colorEnabled
	else
		color = colorDisabled
	end
	overlay:SetBackdropColor(unpack(color))
	overlay:SetBackdropBorderColor(unpack(borderColor))
end

--[[
Library functions
--]]

--[[
lib:SetGroup(group) - Set Sticky Mode to be on or off.

group: anything. true will make all frames sticky while anything else will only
make frames with the same group sticky.
--]]
function SetGroup(self, group)
	group = group and group or nil
	if (lib.group ~= group) then
		lib.group = group
		for frame in pairs(registered) do
			StoreOverlay(frame)
		end
		for frame in pairs(registered) do
			UpdateFrameGroup(frame)
		end
		events:Fire("OnSetGroup", group)
	end
end

--[[
group = lib:GetGroup() - returns the current Sticky Group
--]]
function GetGroup(self)
	return lib.group
end

--[[
lib:SetColorEnabled([r][, g][, b][, a])
--]]
function SetColorEnabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorEnabled[1] = r
	lib.colorEnabled[2] = g
	lib.colorEnabled[3] = b
	lib.colorEnabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorEnabled()
--]]
function GetColorEnabled(self)
	return unpack(lib.colorEnabled)
end

--[[
lib:SetColorDisabled([r][, g][, b][, a])
--]]
function SetColorDisabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorDisabled[1] = r
	lib.colorDisabled[2] = g
	lib.colorDisabled[3] = b
	lib.colorDisabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorDisabled()
--]]
function GetColorDisabled(self)
	return unpack(lib.colorDisabled)
end

--[[
lib:SetColorHidden([r][, g][, b][, a])
--]]
function SetColorHidden(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorHidden[1] = r
	lib.colorHidden[2] = g
	lib.colorHidden[3] = b
	lib.colorHidden[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorHidden()
--]]
function GetColorHidden(self)
	return unpack(lib.colorHidden)
end

--[[
lib:SetColorBorderEnabled([r][, g][, b][, a])
--]]
function SetColorBorderEnabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorBorderEnabled[1] = r
	lib.colorBorderEnabled[2] = g
	lib.colorBorderEnabled[3] = b
	lib.colorBorderEnabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorBorderEnabled()
--]]
function GetColorBorderEnabled(self)
	return unpack(lib.colorBorderEnabled)
end

--[[
lib:SetColorBorderDisabled([r][, g][, b][, a])
--]]
function SetColorBorderDisabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorBorderDisabled[1] = r
	lib.colorBorderDisabled[2] = g
	lib.colorBorderDisabled[3] = b
	lib.colorBorderDisabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorSnapDisabled()
--]]
function GetColorBorderDisabled(self)
	return unpack(lib.colorBorderDisabled)
end

--[[
lib:SetColorSnapEnabled([r][, g][, b][, a])
--]]
function SetColorSnapEnabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorSnapEnabled[1] = r
	lib.colorSnapEnabled[2] = g
	lib.colorSnapEnabled[3] = b
	lib.colorSnapEnabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorSnapEnabled()
--]]
function GetColorSnapEnabled(self)
	return unpack(lib.colorSnapEnabled)
end

--[[
lib:SetColorSnapDisabled([r][, g][, b][, a])
--]]
function SetColorSnapDisabled(self, r, g, b, a)
	r, g, b, a = r or 0, g or 0, b or 0, a or 1
	lib.colorSnapDisabled[1] = r
	lib.colorSnapDisabled[2] = g
	lib.colorSnapDisabled[3] = b
	lib.colorSnapDisabled[4] = a
	for frame in pairs(registered) do
		UpdateFrameColor(frame)
	end
end

--[[
r, g, b, a = lib:GetColorBorderDisabled()
--]]
function GetColorSnapDisabled(self)
	return unpack(lib.colorSnapDisabled)
end

--[[
lib:RegisterFrame(frame) - Registers a frame
--]]
function RegisterFrame(self, frame)
	registered[frame] = true
	UpdateFrameGroup(frame)
end

--[[
--]]
function GetColorEnabled(self)
	return unpack(lib.colorEnabled)
end

--[[
isRegistered = lib:IsRegisteredFrame(frame) - returns true if the frame is registered
--]]
function IsRegisteredFrame(self, frame)
	return registered[frame]
end

--[[
lib:UnregisterFrame(frame) - Unregisters a frame and resets any settings
--]]
function UnregisterFrame(self, frame)
	registered[frame] = nil
	insets[frame] = nil
	enabled[frame] = nil
	points[frame] = nil
	groups[frame] = nil
	texts[frame] = nil
	UpdateFrameGroup(frame)
end

--[[
lib:AnchorFrame(frame) - This can be called in conjunction with lib:StopStickyMoving()
to anchor the frame right back to the parent, so you can manipulate its children as a
group (This is useful in WatchDog).
--]]
function AnchorFrame(self, frame)
	local xA,yA = frame:GetCenter()
	local parent = frame:GetParent() or UIParent
	local xP, yP = parent:GetCenter()
	local sA, sP = frame:GetEffectiveScale(), parent:GetEffectiveScale()

	xP,yP = (xP * sP) / sA, (yP * sP) / sA

	local xo,yo = (xP - xA) * -1, (yP - yA) * -1

	frame:ClearAllPoints()
	frame:SetPoint("CENTER", parent, "CENTER", xo, yo)
	SetFramePoints(lib, frame)
end

--[[
lib:SetFrameInsets(frame, left, top, right, bottom) - Sets the insets for the frame.

left:		If your frame has a transparent border around the entire frame
			(think backdrops with borders).  This can be used to fine tune the
			edges when you are stickying groups.  Refers to any offset on the
			LEFT edge of the frame being moved.
top:		same
right:		same
bottom:		same
--]]
function SetFrameInsets(self, frame, left, top, right, bottom)
	left, top, right, bottom = left or 0, top or 0, right or 0, bottom or 0
	if left ~= 0 or top ~= 0 or right ~= 0 or bottom ~= 0 then
		insets[frame] = new(left, top, right, bottom)
	else
		insets[frame] = del(insets[frame])
	end

	SetFramePoints(lib, frame, GetFramePoints(lib, frame))
	for frameB, pointsB in pairs(points) do
		local frameC = pointsB and pointsB[2]
		if frameC == frame then
			SetFramePoints(lib, frameB, GetFramePoints(lib, frameB))
		end
	end
	local overlay = GetFrameOverlay(lib, frame, true)
	if overlay then
		overlay:ClearAllPoints()
		overlay:SetPoint("left", frame, "left", left, 0)
		overlay:SetPoint("top", frame, "top", 0, 0 - top)
		overlay:SetPoint("right", frame, "right", 0 - right, 0)
		overlay:SetPoint("bottom", frame, "bottom", 0, bottom)
	end
end

--[[
left, top, right, bottom = lib:GetFrameInsets(frame) - returns the insets for the frame
in this order
--]]
function GetFrameInsets(self, frame)
	local frameInset = insets[frame]
	if frameInset then
		if frameInset[1] or frameInset[2] or frameInset[3] or frameInset[4] then
		else
			Poppins:Print(true)
		end
		return unpack(frameInset)
	else
		return 0, 0, 0, 0
	end
end

--[[
libSetFrameGroup(frame, group) - Sets the group for the frame.

group: anything. true will make all frames sticky while anything else will only
make frames with the same group sticky. If group is a table it can contain the
other frames it can stick to but not part of the group like so:
group = { [frame1] = true, [frame2] = true, }
Alternativly if there is only 1 additional frame it can stick to, set the frame as the
group
--]]
function SetFrameGroup(self, frame, group)
	group = group and group ~= true and group or nil
	groups[frame] = group
	UpdateFrameGroup(frame)
end

--[[
group = lib:GetFrameGroup(frame) - returns the group for the frame
--]]
function GetFrameGroup(self, frame)
	return groups[frame] or true
end

--[[
isGroup = lib:IsFrameGroup(frame, group) - Returns true if the frame is the same
as the group or if group is true.
--]]
function IsFrameGroup(self, frame, group)
	return registered[frame] and (GetFrameGroup(lib, frame) == group or group == true)
end

--[[
inGroup = lib:InFrameGroup(frame, group) - Returns true if the frame is the group or if
the group is a table indexed by frames then the group will be checked to see if the frame
is present.
--]]
function InFrameGroup(self, frame, group)
	return registered[frame] and (group == frame or (type(group) == "table" and group[frame]))
end

do
	local rotPoints = { top = "right", bottom = "left", left = "top", right = "bottom" }
	local relPoints = { top = "bottom", bottom = "top", left = "right", right = "left", topright = "bottomleft", bottomright = "topleft", bottomleft = "topright", topleft = "bottomright" }
	--[[
	lib:SetFramePoints(frame, pointA, frameB, pointB, x, y) - Sets the frames points and
	shows the anchor
	
	pointA:	The point on frame that is sticking
	frameB:	The frame to stick to
	pointB:	The point on frameTo to stick to
	x: 		The x offset (the insets offset is automatically added)
	y:		the y offset (the insets offset is automatically added)
	--]]
	function SetFramePoints(self, frame, pointA, frameB, pointB, x, y)
		if pointA and frameB and pointB and not IsDependentOnFrame(frameB, frame) then
			pointA, pointB = pointA:lower(), pointB:lower()
			local xOffset, yOffset = GetInsetOffset(frame, pointA, frameB, pointB, x, y)
			frame:ClearAllPoints()
			frame:SetPoint(pointA, frameB, pointB, (x or 0) + xOffset, (y or 0) + yOffset)

			points[frame] = new(pointA, frameB, pointB, x, y)
		else
			points[frame] = del(points[frame])
		end

		local overlay = GetFrameOverlay(lib, frame, true)
		if not overlay then return end
		local anchor = overlay.anchor
		if pointA then
			local relPoint = relPoints[pointA]
			anchor:ClearAllPoints()
			anchor:SetPoint(pointA, overlay, pointA, 0, 0)
			anchor:SetPoint(relPoint, overlay, "center", 0, 0)
			local rotPoint = rotPoints[pointA]
			if rotPoint then
				local rotRelPoint = rotPoints[relPoint]
				anchor:SetPoint(rotPoint, overlay, rotPoint, 0, 0)
				anchor:SetPoint(rotRelPoint, overlay, rotRelPoint, 0, 0)
			end
			anchor:Show()
		else
			anchor:Hide()
		end
	end
end

--[[
pointA, frameB, pointB, x, y = lib:GetFramePoints(frame) - returns the points of the
frame
--]]
function GetFramePoints(self, frame)
	local framePoints = points[frame]
	if framePoints then
		return unpack(framePoints)
	end
end

--[[
overlay = lib:GetFrameOverlay(frame, nocreate) - returns the overlay and creates it if
it doesn't exist

noRetrieve: doesn't retrieve the overlay if not already retrieved
--]]
function GetFrameOverlay(self, frame, noRetrieve)
	if not overlays[frame] and not noRetrieve then
		return RetrieveOverlay(frame)
	end
	return overlays[frame]
end

--[[
lib:SetFrameText(frame, text) - Sets the text to be displayed on the overlay

text: a string
--]]
function SetFrameText(self, frame, text)
	text = type(text) == "string" and text or nil
	texts[frame] = text
	local overlay = GetFrameOverlay(lib, frame, true)
	if overlay then
		overlay.text:SetText(text)
	end
end

--[[
text = lib:GetFrameText(frame) - Returns the text displayed on the overlay
--]]
function GetFrameText(self, frame)
	return texts[frame]
end

--[[
lib:SetFrameEnabled(frame, state) - Sets whether the frame is enabled or not

state: true or false
--]]
function SetFrameEnabled(self, frame, state)
	state = state and true or nil
	enabled[frame] = state
	UpdateFrameGroup(frame)
end

--[[
state = lib:IsFrameEnabled(frame) - Returns the enabled state
--]]
function IsFrameEnabled(self, frame)
	return enabled[frame]
end

--[[
lib:SetFrameHidden(frame, state) - Set whether the frame should be hidden after
lb:SetGroup(group) is called and the frame is not part of the group. This is
automatically set if the frame isn't shown when lib:SetGroup(group) is called.
--]]
function SetFrameHidden(self, frame, state)
	hidden[frame] = state and true or nil
	UpdateFrameColor(frame)
end

--[[
state = lib:IsFrameHidden(frame) - Returns the hidden state. This is automatically cleared
after lib:SetGroup(group) is called and the frame isn't in the group.
--]]
function IsFrameHidden(self, frame)
	return hidden[frame] and true
end

--[[
lib:StartFrameMoving(frame) - Sets a custom OnUpdate for the frame so it follows
the mouse and snaps to the frames its grouped with.
--]]
function StartFrameMoving(self, frame)
	if lib.frame then
		StopFrameMoving(lib, lib.frame)
	end
	lib.frame = frame
	for frameB in pairs(registered) do
		UpdateFrameColor(frameB)
	end
	lib.cursorX, lib.cursorY = lib.clickX or 0, lib.clickY or 0
	lib.clickX, lib.clickY = nil, nil

	scripts[frame] = frame:GetScript("OnUpdate")
	frame:SetScript("OnUpdate", MovingUpdate)
	events:Fire("OnStartFrameMoving", frame)
end

--[[
isMoving = lib:IsFrameMoving(frame) - Returns true if the frame is moving.
--]]
function IsFrameMoving(self, frame)
	return lib.frame == frame
end

--[[
lib:StopFrameMoving() - This stops the OnUpdate, leaving the frame at its last position.
This will leave it anchored to the last frame it was able to attach to or the UIParent. 
You can call lib:AnchorFrame(frame) to anchor it back "TOPLEFT" of the UIParent.
--]]
function StopFrameMoving(self)
	local frame = lib.frame
	if not frame then return end
	local point, frameTo, pointTo, x, y = lib.point, lib.frameTo, lib.pointTo, lib.x, lib.y
	SetFramePoints(lib, frame, point, frameTo, pointTo, x, y)
	-- Perform Sticking if requested
	events:Fire("OnStopFrameMoving", frame, point, frameTo, pointTo, x, y)

	lib.frame = nil
	lib.point = nil
	lib.frameTo = nil
	lib.pointTo = nil
	lib.x = nil
	lib.y = nil

	frame:SetScript("OnUpdate", scripts[frame])
	scripts[frame] = nil
	for frameB in pairs(registered) do
		UpdateFrameColor(frameB)
	end
end

lib.SetGroup = SetGroup
lib.GetGroup = GetGroup

lib.SetColorEnabled = SetColorEnabled
lib.GetColorEnabled = GetColorEnabled
lib.SetColorDisabled = SetColorDisabled
lib.GetColorDisabled = GetColorDisabled
lib.SetColorHidden = SetColorHidden
lib.GetColorHidden = GetColorHidden
lib.SetColorBorderEnabled = SetColorBorderEnabled
lib.GetColorBorderEnabled = GetColorBorderEnabled
lib.GetColorBorderDisabled = GetColorBorderDisabled
lib.GetColorBorderDisabled = GetColorBorderDisabled

lib.RegisterFrame = RegisterFrame
lib.IsRegisteredFrame = IsRegisteredFrame
lib.UnregisterFrame = UnregisterFrame
lib.AnchorFrame = AnchorFrame
lib.SetFrameInsets = SetFrameInsets
lib.GetFrameInsets = GetFrameInsets
lib.SetFrameGroup = SetFrameGroup
lib.GetFrameGroup = GetFrameGroup
lib.IsFrameGroup = IsFrameGroup
lib.InFrameGroup = InFrameGroup
lib.SetFramePoints = SetFramePoints
lib.GetFramePoints = GetFramePoints
lib.GetFrameOverlay = GetFrameOverlay
lib.SetFrameText = SetFrameText
lib.SetFrameText = SetFrameText
lib.SetFrameEnabled = SetFrameEnabled
lib.IsFrameEnabled = IsFrameEnabled
lib.SetFrameHidden = SetFrameHidden
lib.IsFrameHidden = IsFrameHidden
lib.StartFrameMoving = StartFrameMoving
lib.IsFrameMoving = IsFrameMoving
lib.StopFrameMoving = StopFrameMoving