--[[
Name: LibKeyBoundExtra-1.0
Revision: $Rev: 29 $
Author(s): Toadkiller, Tuller
Website: http://www.wowace.com/wiki/LibKeyBoundExtra-1.0
Documentation: http://www.wowace.com/wiki/LibKeyBoundExtra-1.0
SVN: http://svn.wowace.com/wowace/trunk/LibKeyBoundExtra-1.0
Description: Applies LibKeyBound to Spell Book and Macro UI Buttons.
Dependencies: LibKeyBound-1.0
--]]

local MAJOR = "LibKeyBoundExtra-1.0"
local MINOR = 90000 + tonumber(("$Revision: 29 $"):match("(%d+)"))

--[[
	LibKeyBoundExtra-1.0
		KeyBound/macro.lua and KeyBound/spell.lua by Tuller -> LibKeyBoundExtra library by Toadkiller.
--]]

local LibKeyBoundExtra, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not LibKeyBoundExtra then return end -- no upgrade needed

local LibKeyBound = LibStub:GetLibrary("LibKeyBound-1.0")
local _G = _G

-- #NODOC

LibKeyBoundExtra.MacroButton = LibKeyBoundExtra.MacroButton or CreateFrame("Frame")
LibKeyBoundExtra.CastButton = LibKeyBoundExtra.CastButton or CreateFrame("Frame")


function LibKeyBoundExtra.MacroButton:Load()
	local i = 1
	local button
	repeat
		button = getglobal(format("MacroButton%d", i))
		if button then
			local OnEnter = button:GetScript("OnEnter")
			button:SetScript("OnEnter", function(self)
				LibKeyBound:Set(self)
				return OnEnter and OnEnter(self)
			end)

			button.GetBindAction = self.GetBindAction
			button.GetActionName = self.GetActionName
			button.SetKey = self.SetKey
			button.GetHotkey = self.GetHotkey
			button.ClearBindings = self.ClearBindings
			button.GetBindings = self.GetBindings
			i = i + 1
		end
	until not button
end

function LibKeyBoundExtra.MacroButton:OnEnter()
	LibKeyBound:Set(self)
end

function LibKeyBoundExtra.MacroButton:GetActionName()
	return GetMacroInfo(MacroFrame.macroBase + self:GetID())
end

-- returns the keybind action of the given button
function LibKeyBoundExtra.MacroButton:GetBindAction()
	return format("MACRO %d", MacroFrame.macroBase + self:GetID())
end

-- binds the given key to the given button
function LibKeyBoundExtra.MacroButton:SetKey(key)
	SetBindingMacro(key, MacroFrame.macroBase + self:GetID())
end

-- removes all keys bound to the given button
function LibKeyBoundExtra.MacroButton:ClearBindings()
	local binding = self:GetBindAction()
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

-- returns a string listing all bindings of the given button
function LibKeyBoundExtra.MacroButton:GetBindings()
	local keys
	local binding = self:GetBindAction()
	for i = 1, select("#", GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys then
			keys = keys .. ", " .. GetBindingText(hotKey, "KEY_")
		else
			keys = GetBindingText(hotKey, "KEY_")
		end
	end
	return keys
end

function LibKeyBoundExtra.MacroButton:GetHotkey()
	return LibKeyBound:ToShortKey(GetBindingKey(self:GetBindAction()))
end

function LibKeyBoundExtra.CastButton:Load()
	local i = 1
	local button
	repeat
		button = getglobal('SpellButton' .. i)
		if button then
			button:HookScript('OnEnter', self.OnEnter)

			button.GetBindAction = self.GetBindAction
			button.GetActionName = self.GetActionName
			button.SetKey = self.SetKey
			button.GetHotkey = self.GetHotkey
			button.ClearBindings = self.ClearBindings
			button.GetBindings = self.GetBindings
			i = i + 1
		end
	until not button
end

function LibKeyBoundExtra.CastButton:OnEnter()
	local id = SpellBook_GetSpellID(self:GetID())
	local bookType = SpellBookFrame.bookType

	if not(bookType == BOOKTYPE_PET or IsPassiveSpell(id, bookType)) then
		LibKeyBound:Set(self)
	end
end

function LibKeyBoundExtra.CastButton:GetActionName()
	local name, subName = GetSpellName(SpellBook_GetSpellID(self:GetID()), SpellBookFrame.bookType)
	if(subName and subName ~= '') then
		return format('%s(%s)', name, subName)
	end
	return name
end

-- returns the keybind action of the given button
function LibKeyBoundExtra.CastButton:GetBindAction()
	return format('SPELL %s', self:GetActionName())
end

-- binds the given key to the given button
function LibKeyBoundExtra.CastButton:SetKey(key)
	SetBindingSpell(key, self:GetActionName())
end

-- removes all keys bound to the given button
function LibKeyBoundExtra.CastButton:ClearBindings()
	local binding = self:GetBindAction()
	while GetBindingKey(binding) do
		SetBinding(GetBindingKey(binding), nil)
	end
end

-- returns a string listing all bindings of the given button
function LibKeyBoundExtra.CastButton:GetBindings()
	local keys
	local binding = self:GetBindAction()
	for i = 1, select('#', GetBindingKey(binding)) do
		local hotKey = select(i, GetBindingKey(binding))
		if keys then
			keys = keys .. ', ' .. GetBindingText(hotKey, 'KEY_')
		else
			keys = GetBindingText(hotKey, 'KEY_')
		end
	end
	return keys
end

function LibKeyBoundExtra.CastButton:GetHotkey()
	return LibKeyBound:ToShortKey(GetBindingKey(self:GetBindAction()))
end



do
	LibKeyBoundExtra.MacroButton:UnregisterAllEvents()
	LibKeyBoundExtra.MacroButton:SetScript("OnEvent", function(self, event, addon)
		if addon == "Blizzard_MacroUI" then
			self:UnregisterEvent("ADDON_LOADED")
			self:Load()
		end
	end)
	LibKeyBoundExtra.MacroButton:RegisterEvent("ADDON_LOADED")

	LibKeyBoundExtra.CastButton:UnregisterAllEvents()
	LibKeyBoundExtra.CastButton:SetScript("OnEvent", function(self, event, addon)
		if (event == "PLAYER_LOGIN") then
			self:Load()
			self:UnregisterEvent("PLAYER_LOGIN")
		end
	end)
	LibKeyBoundExtra.CastButton:RegisterEvent("PLAYER_LOGIN")

end

