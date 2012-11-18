--[[
	Auctioneer
	Version: 5.9.4960 (WhackyWallaby)
	Revision: $Id: CoreUtil.lua 4880 2010-09-15 20:02:11Z Nechckn $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

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
if not AucAdvanced then return end

local lib = AucAdvanced
local private = {}
local coremodule = AucAdvanced.GetCoreModule("CoreUtil")
if not coremodule then return end -- Someone has explicitely broken us
local tooltip = LibStub("nTipHelper:1")
local Const = lib.Const


function coremodule.OnLoad(addon)
	if addon == "auc-advanced" then
		private.FactionOnLoad()
	end
end

coremodule.Processors = {}
function coremodule.Processors.auctionopen()
	private.isAHOpen = true
end
function coremodule.Processors.auctionclose()
	private.isAHOpen = false
end
function coremodule.Processors.newmodule(event, libType, libName)
	-- resetting caches here allows us to respond to modules that are not created by lib.NewModule,
	-- as long as they correctly send a "newmodule" message when created
	private.modulecache = nil
	private.resetPriceModels()
end

--Localization via babylonian
local Babylonian = LibStub("Babylonian")
assert(Babylonian, "Babylonian is not installed")
local babylonian = Babylonian(AuctioneerLocalizations)
function lib.localizations(stringKey)
	local locale = lib.Settings.GetSetting("SelectedLocale")--locales are user choose-able
	-- translated key or english Key or Raw Key
	return babylonian(locale, stringKey) or babylonian[stringKey] or stringKey
end

--The following function will build tables correlating Chat Frame names with their index numbers, and return different formats according to an option passed in.
function lib.getFrameNames(option)
	local frames = {}
	local frameName = ""
--This iterates through the first 10 ChatWindows, getting the name associated with it.
	for i=1, 10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i)
		--If the name isn't blank, then we build tables where the Chat Frame names are the keys, and indexes the values if the frame is either shown or docked.
		if (name ~= "" and (shown or docked)) then
			frames[name] = i
		end
	end
	--Next, if a number was passed as an option, we simply retrieve the frame name and assign it to frameName
	if (type(option) == "number") then
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(option);
		frameName = name
		return frameName
	--If no option was specified, we return the Name=>Index table
	elseif (not option) then
		return frames
	end
end

--This function will be called by our configuration screen to build the appropriate list.
function lib.configFramesList()
	local configFrames = {}
	for i=1, 10 do
		local name, fontSize, r, g, b, a, shown, locked, docked = GetChatWindowInfo(i)
		if (name ~= "") and (docked or shown) then
			table.insert(configFrames, {name, name})
		end
	end
	return configFrames
end
--This function will retrieve the index we've got stored for the user
function lib.getFrameIndex()
	--Check to make sure AucAdvanced.Settings exists, if not initialize it
	if (not AucAdvanced.Settings) then
		AucAdvanced.Settings = {}
	end
	local get = AucAdvanced.Settings.GetSetting
	--Get the value of AucAdvanced.Settings["printwindow"]
	local value = get("printwindow")
	--If that value doesn't exist, we return a default of 0
	if (not value) then
		return 0
	end
	--Otherwise, we return the value
	return value
end

--This function is used to store the user's preferred chatframe
function lib.setFrame(frame)
	local set = AucAdvanced.Settings.SetSetting
	--If called with no argument
	if (not frame) then
		frame = 0
	--Compatibility, for those who had set this previously.
	elseif (type(frame) == "number" and frame > 0 and frame < 10) then
		frame,_,_,_,_,_,_,_,_=GetChatWindowInfo(frame)
	--If the frame argument is a string, set that as the frameNumber
	elseif (type(frame) == "string") then
		set("printwindow", frame)
	--Otherwise set it to 0
	else
		set("printwindow", 0)
	end
end

--This is the printing function.  If the user has selected a preferred chatframe, we'll use it.  If not, we'll default to the first one.
function lib.Print(...)
	local output, part, frameIndex
	local frame = AucAdvanced.getFrameIndex()
	local allFrames = AucAdvanced.getFrameNames()
	if (type(frame) == "string") then
		if (allFrames[frame]) then
			frameIndex = allFrames[frame]
		else
			frameIndex = 1
		end
	--For backward compatibility
	elseif (type(frame) == "number" and frame > 0 and frame < 9) then
		frameIndex = frame
	elseif (frame == 0) then
		frameIndex = 1
	else
		frameIndex = 1
	end
	local frameReference = _G["ChatFrame"..frameIndex]
	for i=1, select("#", ...) do
		part = select(i, ...)
		part = tostring(part):gsub("{{", "|cffddeeff"):gsub("}}", "|r")
		if (output) then output = output .. " " .. part
		else output = part end
	end
	--If we have a stored chat frame, print our output there
	if (frameReference) then
		frameReference:AddMessage(output, 0.3, 0.9, 0.8)
	--Otherwise, print it to the client's DEFAULT_CHAT_FRAME
	else
		DEFAULT_CHAT_FRAME:AddMessage(output, 0.3, 0.9, 0.8)
	end
end

--Creates the list of locales to choose from
function lib.changeLocale()
	local localizations, default = {}, lib.Settings.GetSetting("SelectedLocale") --get the user choosen locale make it first on the list
	for i in pairs(AuctioneerLocalizations) do
		if default == i then
			table.insert(localizations,1, {i, i})
		else
			table.insert(localizations, {i, i})
		end
	end
	return localizations
end

-- Creates the list of Pricing Models for use in dropdowns
-- Usage: gui:AddControl(id, "Selectbox",  column, indent, AucAdvanced.selectorPriceModels, "util.modulename.model")
do
	local pricemodels
	function private.resetPriceModels()
		-- called every time a new module loads
		pricemodels = nil
	end
	function lib.selectorPriceModels()
		if not pricemodels then
			-- delay creating table until function is first called, to give all modules a chance to load first
			pricemodels = {}
			table.insert(pricemodels,{"market", lib.localizations("UCUT_Interface_MarketValue")})--Market value {Reusing Undercut's existing localization string}
			local algoList = AucAdvanced.API.GetAlgorithms()
			for pos, name in ipairs(algoList) do
				table.insert(pricemodels,{name, lib.localizations("APPR_Interface_Stats").." "..name})--Stats: {Reusing Appraiser's existing localization string}
			end
		end
		return pricemodels
	end
end

-- Creates the list of Auction Durations for use in deposit cost dropdowns
-- Usage: gui:AddControl(id, "Selectbox",  column, indent, AucAdvanced.selectorAuctionLength, "util.modulename.deplength")
do
	local auctionlength = {
			{12, FORMATED_HOURS:format(12)},
			{24, FORMATED_HOURS:format(24)},
			{48, FORMATED_HOURS:format(48)},
		}
	function lib.selectorAuctionLength()
		return auctionlength
	end
end

function lib.GetFactor(...) return tooltip:GetFactor(...) end
function lib.SanitizeLink(...) return tooltip:SanitizeLink(...) end
function lib.DecodeLink(...) return tooltip:DecodeLink(...) end
function lib.GetLinkQuality(...) return tooltip:GetLinkQuality(...) end
function lib.ShowItemLink(...) return tooltip:ShowItemLink(...) end
function lib.BreakHyperlink(...) return tooltip:BreakHyperlink(...) end
lib.breakHyperlink = lib.BreakHyperlink

do -- Faction and ServerKey related functions
	local splitcache = {}
	local localizedfactions = {
		-- the following entries are placeholders
		["Alliance"] = "Alliance",
		["Horde"] = "Horde",
		["Neutral"] = "Neutral",
	}
	function lib.SplitServerKey(serverKey)
		local split = splitcache[serverKey]
		if not split then
			if type(serverKey) ~= "string" then return end
			local realm, faction = strmatch(serverKey, "^(.+)%-(%u%l+)$")
			local transfaction = localizedfactions[faction]
			if not transfaction then return end
			split = {realm, faction, realm.." - "..transfaction}
			splitcache[serverKey] = split
		end
		return split[1], split[2], split[3]
	end

	local lookupfaction = {
		["alliance"] = "Alliance",
		[FACTION_ALLIANCE:lower()] = "Alliance",
		["horde"] = "Horde",
		[FACTION_HORDE:lower()] = "Horde",
		["neutral"] = "Neutral",
	}
	-- Used to check user text input for some form of a faction name; returns standardized form if found
	-- Possible results are "Alliance", "Horde", "Neutral" or nil if not found
	function lib.IsFaction(faction)
		if type(faction) == "string" then
			return lookupfaction[faction:lower()]
		end
	end

	function lib.GetFaction()
		local factionGroup = lib.GetFactionGroup()
		if not factionGroup then return end
		if factionGroup ~= lib.curFactionGroup then
			local curFaction
			if (factionGroup == "Neutral") then
				lib.cutRate = 0.15
				lib.depositRate = 0.25 -- deprecated
				curFaction = Const.ServerKeyNeutral
			else
				lib.cutRate = 0.05
				lib.depositRate = 0.05 -- deprecated
				curFaction = Const.ServerKeyHome
			end
			lib.curFaction = curFaction -- deprecated (it's a serverKey, so calling it curFaction is confusing)
			lib.curFactionGroup = factionGroup
			lib.curServerKey = curFaction
		end
		return lib.curServerKey, Const.PlayerRealm, factionGroup
	end

	local zonefactions = {}
	function lib.GetFactionGroup()
		if private.isAHOpen or not lib.Settings.GetSetting("alwaysHomeFaction") then
			local currentZone = GetMinimapZoneText()
			local factionGroup = zonefactions[currentZone]
			if not factionGroup then
				SetMapToCurrentZone()
				local map = GetMapInfo()
				if ((map == "Tanaris") or (map == "Winterspring") or (map == "Stranglethorn")) then
					factionGroup = "Neutral"
				else
					factionGroup = Const.PlayerFaction
				end
				zonefactions[currentZone] = factionGroup
			end
			return factionGroup
		end
		return Const.PlayerFaction
	end

	function private.FactionOnLoad()
		local alliance = lib.localizations("ADV_Interface_FactionAlliance")
		local horde = lib.localizations("ADV_Interface_FactionHorde")
		local neutral = lib.localizations("ADV_Interface_FactionNeutral")

		localizedfactions.Alliance = alliance
		localizedfactions.Horde = horde
		localizedfactions.Neutral = neutral

		lookupfaction[alliance:lower()] = "Alliance"
		lookupfaction[horde:lower()] = "Horde"
		lookupfaction[neutral:lower()] = "Neutral"

		wipe(splitcache)
	end
end

function private.relevelFrame(frame)
	return private.relevelFrames(frame:GetFrameLevel() + 2, frame:GetChildren())
end

function private.relevelFrames(myLevel, ...)
	for i = 1, select("#", ...) do
		local child = select(i, ...)
		child:SetFrameLevel(myLevel)
		private.relevelFrame(child)
	end
end

function lib.AddTab(tabButton, tabFrame)
	-- Count the number of auction house tabs (including the tab we are going
	-- to insert).
	local tabCount = 1;
	while (_G["AuctionFrameTab"..(tabCount)]) do
		--check that tab has not already been created, since we can optionally remove tabs now
		if _G["AuctionFrameTab"..(tabCount)]:GetName() == tabButton:GetName() then
			lib.Print("Tab with that name already exists")
			return
		end
		tabCount = tabCount + 1;
	end

	-- Find the correct location to insert our Search Auctions and Post Auctions
	-- tabs. We want to insert them at the end or before BeanCounter's
	-- Transactions tab.
	local tabIndex = 1;
	while (_G["AuctionFrameTab"..(tabIndex)] and
		   _G["AuctionFrameTab"..(tabIndex)]:GetName() ~= "AuctionFrameTabUtilBeanCounter") do
		tabIndex = tabIndex + 1;
	end

	-- Make room for the tab, if needed.
	for index = tabCount, tabIndex + 1, -1  do
		_G["AuctionFrameTab"..(index)] = _G["AuctionFrameTab"..(index - 1)];
		_G["AuctionFrameTab"..(index)]:SetID(index);
	end

	-- Configure the frame.
	tabFrame:SetParent("AuctionFrame");
	tabFrame:SetPoint("TOPLEFT", "AuctionFrame", "TOPLEFT", 0, 0);
	private.relevelFrame(tabFrame);

	-- Configure the tab button.
	_G["AuctionFrameTab"..tabIndex] = tabButton;
	tabButton:SetParent("AuctionFrame");
	tabButton:SetPoint("TOPLEFT", _G["AuctionFrameTab"..(tabIndex - 1)]:GetName(), "TOPRIGHT", -8, 0);
	tabButton:SetID(tabIndex);
	tabButton:Show();

	-- If we inserted a tab in the middle, adjust the layout of the next tab button.
	if (tabIndex < tabCount) then
		nextTabButton = _G["AuctionFrameTab"..(tabIndex + 1)];
		nextTabButton:SetPoint("TOPLEFT", tabButton:GetName(), "TOPRIGHT", -8, 0);
	end

	-- Update the tab count.
	PanelTemplates_SetNumTabs(AuctionFrame, tabCount)
end
--used by modules to "hide" their auction house tab.
function lib.RemoveTab(tabButton, tabFrame)
	-- Count the number of auction house tabs.
	local tabCount = 0
	while (_G["AuctionFrameTab"..(tabCount+1)]) do
		tabCount = tabCount + 1;
	end

	-- Find the correct location to remove the tab
	local tabIndex, tabFound = 1
	while _G["AuctionFrameTab"..(tabIndex)] do
		if _G["AuctionFrameTab"..(tabIndex)]:GetName() == tabButton:GetName() then
			tabFound = tabIndex
			break
		end
		tabIndex = tabIndex + 1
	end

	--if we did nto find the correct tab then end
	if not tabFound then return end

	-- If we inserted a tab in the middle, adjust the layout of the next tab button after removal.
	if tabFound and (tabFound < tabCount) then
		nextTabButton = _G["AuctionFrameTab"..(tabFound + 1)]
		nextTabButton:SetPoint("TOPLEFT", _G["AuctionFrameTab"..(tabFound - 1)]:GetName(), "TOPRIGHT", -8, 0)
	end

	-- Reduce count on tabs remaining
	_G["AuctionFrameTab"..(tabFound)] = nil --remove old tab from namespace
	for index = tabFound, tabCount do
		local tab = _G["AuctionFrameTab"..(index + 1)]
		if tab then
			_G["AuctionFrameTab"..(index)] =  tab
			_G["AuctionFrameTab"..(index)]:SetID(index)
		else --last tab index needs to be removed
			_G["AuctionFrameTab"..(index)] = nil
		end
	end

	-- Hide the frame.
	tabFrame:Hide()
	tabButton:Hide()

	-- Update the tab count.
	PanelTemplates_SetNumTabs(AuctionFrame, tabCount - 1)
end

-- Table management functions:
local function replicate(source, depth, history)
	if type(source) ~= "table" then return source end
	assert(depth==nil or tonumber(depth), "Unknown depth: " .. tostring(depth))
	if not depth then depth = 0 history = {} end
	assert(history, "Have depth but without history")
	assert(depth < 100, "Structure is too deep")
	local dest = {} history[source] = dest
	for k, v in pairs(source) do
		if type(v) == "table" then
			if history[v] then dest[k] = history[v]
			else dest[k] = replicate(v, depth+1, history) end
		else dest[k] = v end
	end
	return dest
end
local function empty(item)
	if type(item) == 'table' then wipe(item) end
end
local function fill(item, ...)
	if type(item) ~= 'table' then return end
	wipe(item)
	local n = select('#', ...)
	for i = 1,n do item[i] = select(i, ...) end
end
-- End table management functions

-- Old functions (compatability)
lib.Recycle = function() end
lib.Acquire = function(...) return {...} end
lib.Clone = replicate
lib.Scrub = empty
-- New functions
lib.Replicate = replicate
lib.Empty = empty
lib.Fill = fill

--[[
Functions for establishing a new copy of the library.
Recommended method:

  local libType, libName = "myType", "myName"
  local lib,parent,private = AucAdvanced.NewModule(libType, libName)
  if not lib then return end
  local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill,_TRANS = AucAdvanced.GetModuleLocals()

--]]

--[[

Usage:
  local lib,parent,private = AucAdvanced.NewModule(libType, libName)

--]]
local moduleKit = {}
function lib.NewModule(libType, libName)
	assert(lib.Modules[libType], "Invalid AucAdvanced libType specified: "..tostring(libType))

	if not lib.Modules[libType][libName] then
		local module = {}
		local modulePrivate = {}
		module.libType = libType
		module.libName = libName
		module.Private = modulePrivate
		module.GetName = function() return libName end
		for k,v in pairs(moduleKit) do
			module[k] = v
		end

		lib.Modules[libType][libName] = module
		lib.SendProcessorMessage("newmodule", libType, libName)
		return module, lib, modulePrivate
	end
end

--[[

Usage:
  local libCopy = AucAdvanced.GetModule(libType, libName)

--]]
function lib.GetModule(libType, libName)
	assert(lib.Modules[libType], "Invalid AucAdvanced libType specified: "..tostring(libType))

	if lib.Modules[libType][libName] then
		return lib.Modules[libType][libName], lib, private
	end
end

--[[

Usage:
  local print,decode,_,_,replicate,empty,get,set,default,debugPrint,fill,_TRANS = AucAdvanced.GetModuleLocals()

-- ]]
function lib.GetModuleLocals()
	return lib.Print, lib.DecodeLink,
	lib.Recycle, lib.Acquire, lib.Replicate, lib.Empty,
	lib.Settings.GetSetting, lib.Settings.SetSetting, lib.Settings.SetDefault,
	lib.Debug.DebugPrint, lib.Fill, lib.localizations
end

private.checkedModules = {}
function private.CheckModule(name, module)
	if private.checkedModules[module] then return end

	local fix
	if not module.GetName or type(module.GetName) ~= "function" then
		-- Sometimes we find engines that don't have a "GetName()" function.
		-- All engines should have this function!
		if nLog then
			nLog.AddMessage("Auctioneer", "CheckModule", N_WARNING, "Module without GetName()", "No GetName() function was found for module indexed as \""..name.."\". Please fix this!")
		end
		fix = true
	else
		local reportedName = module.GetName()
		if reportedName ~= name then
			if nLog then
				nLog.AddMessage("Auctioneer", "CheckModule", N_WARNING, "Module GetName() mismatch", "The GetName() function was found for module indexed as \""..name.."\", but actually returns \""..reportedName.."\". Please fix this!")
			end
			fix = true
		end
	end

	if fix then
		module.GetName = function()
			return name
		end
	end

	private.checkedModules[module] = true
end

function lib.GetAllModules(having, findSystem, findEngine)
	local modules
	if findSystem then findSystem = findSystem:lower() end
	if findEngine then findEngine = findEngine:lower() end
	if not findEngine then modules = {} end

	if not having and not findSystem and private.modulecache then
		for k,v in ipairs(private.modulecache) do
			modules[k] = v
		end
		return modules
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		if not findSystem or system:lower() == findSystem then
			for engine, engineLib in pairs(systemMods) do
				private.CheckModule(engine, engineLib)
				if not having or engineLib[having] then
					if not findEngine then
						table.insert(modules, engineLib)
					elseif engine:lower() == findEngine then
						return engineLib, system, engine
					end
				end
			end
		end
	end

	if not having and not findSystem then
		if not private.modulecache then private.modulecache = {} end
		for k,v in ipairs(modules) do
			private.modulecache[k] = v
		end
	end
	return modules
end


--[[ End of CoreModule ]]--

local spmArray = {}
function lib.SendProcessorMessage(spmMsg, ...)
	local spmp = spmArray[spmMsg]
	if (spmp) then
		for i=1,#spmp do
			local x = spmp[i]
			local f = x.Func
--if (nLog) then nLog.AddMessage("Auctioneer", "Coreutil", N_INFO, ("SendProcessorMessage Called %s For %s"):format(x.Name, spmMsg), ("SendProcessorMessage Called %s For %s"):format(x.Name, spmMsg)) end

			good,msg=pcall(f, spmMsg, ...)
			if not good then
				lib.Debug.DebugPrint(msg, "SendProcessorMessage", "Processor Error in "..(x.Name or "??"), 0, "Debug")
			end
		end
	else
		spmp = {}
		spmArray[spmMsg] = spmp

		local modules = AucAdvanced.GetAllModules("Processors")
		local good, msg
		for pos, engineLib in ipairs(modules) do
			local f = engineLib.Processors[spmMsg]
			if f then
				local x = {}
				x.Name = engineLib.GetName()
				if (spmMsg=="tooltip") then
					local f1 = f
					x.Func = function(spmMsg, ...)
						-- TODO: Make these defaults configurable
						tooltip:SetColor(0.3, 0.9, 0.8)
						tooltip:SetMoneyAsText(false)
						tooltip:SetEmbed(false)
						f1(spmMsg, ...)
					end
				else
					x.Func = f
				end
				table.insert(spmp, x)
--if (nLog) then nLog.AddMessage("Auctioneer", "Coreutil", N_INFO, ("SendProcessorMessage Called %s For %s (using Processors)"):format(x.Name, spmMsg), ("SendProcessorMessage Called %s For %s"):format(x.Name, spmMsg)) end
				good,msg=pcall(f, spmMsg, ...)
				if not good then
					lib.Debug.DebugPrint(msg, "SendProcessorMessage", "Processor Error in "..(x.Name or "??"), 0, "Debug")
				end
			end
		end

		modules = AucAdvanced.GetAllModules("Processor")
		local good, msg
		for pos, engineLib in ipairs(modules) do
			if (not engineLib.Processors) then
				local x = {}
				x.Name = engineLib.GetName()
				x.Func = engineLib.Processor
				lib.Debug.DebugPrint("Module Using Deprecated Processor to recieve "..(spmMsg or "Unknown").." processor messages.", "SendProcessorMessage", "Deprecated Function Seen in "..(x.Name or "??"), 0, "Warning")
				table.insert(spmp, x)
				good,msg=pcall(engineLib.Processor, spmMsg, ...)
				if not good then
					lib.Debug.DebugPrint(msg, "SendProcessorMessage", "Processor Error in "..(x.Name or "??"), 0, "Debug")
				end
			end
		end
	end
end

function lib.ResetSPMArray()
	spmArray = {}
end

-- Returns the tooltip helper
function lib.GetTooltip()
	return tooltip
end

-- Turns a copper amount into colorized text
function lib.Coins(amount, graphic)
	return (tooltip:Coins(amount, graphic))
end

-- Creates a new coin object
function lib.CreateMoney(height)
	return (tooltip:CreateMoney(height))
end

AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.9/Auc-Advanced/CoreUtil.lua $", "$Rev: 4880 $")
