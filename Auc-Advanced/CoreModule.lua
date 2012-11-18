--[[
	Auctioneer
	Version: 5.9.4960 (WhackyWallaby)
	Revision: $Id: CoreConst.lua 4598 2010-01-07 20:40:09Z brykrys $
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
--]]

--[[
	Auctioneer Core Module Support

	This code helps maintain internal integrity of Auctioneer.  Allows a module to be created to support the Core
	without hoisting variables into a public namespace.  
	Also creates an addon local (can only get a reference during auctioneers startup) tablespace, allowing more intermodule interaction
	without hoisting the variables into the public tablespace.
--]]


if not AucAdvanced then return end
local lib = AucAdvanced

local modules = {}
local internal = {}

-- This is an initial creation function.  Create and return items once.  Expect the caller to store that value for use.
function lib.GetCoreModule(moduleName)
	local x = {}
	if (moduleName) then
		if (modules[moduleName]) then return end
		modules[moduleName] = x
	end
	return x, internal
end

--[[ CoreModule
	A dummy module representing the core of Auc-Advanced
	Used to catch messages and pass them on to elements of the core
--]]
local coremoduleInternal = {}
local coremodule = {
	libType = "Util",
	libName = "CoreModule",
	GetName = function() return "CoreModule" end,
	}


	
local function HasOnlyFunctions(tbl)
	for _, elem in pairs(tbl) do
		if not type(elem)=="function" then
			return false
		end
	end
	return true
end

-- called from CoreMain's private OnLoad function
function lib.CoreModuleOnLoad(addon)
	local tcheck = {}
	local ncheck = {}
	for mdl, core in pairs(modules) do
		for elem, dat in pairs(core) do
			local tp = type(dat)
			if (tp=="table" and HasOnlyFunctions(dat)) then tp="nestedfunction" end
			if ((not tcheck[elem]) or tcheck[elem]==tp) then
				if not tcheck[elem] then
					tcheck[elem] = tp
					ncheck[elem] = mdl
				end
				if (tp=="table") then
					if not coremodule[elem] then coremodule[elem] = {} end
					local ts = coremodule[elem]
					for x, y in pairs(dat) do
						ts[x] = y
					end
				elseif (tp=="nestedfunction") then
					if not coremoduleInternal[elem] then coremoduleInternal[elem] = {} end
					local fns = coremoduleInternal[elem]
					for fName, fCode in pairs(dat) do
						if not fns[fName] then fns[fName] = {} end
						local fs = fns[fName]
						if not coremodule[elem] then coremodule[elem] = {} end
						if not coremodule[elem][fName] then
							local f = elem
							coremodule[elem][fName]=function(...)
								for i=1,#fs do
									local fn = fs[i]
									fn(...)
								end
							end
						end
						table.insert(fs, fCode)
					end
				elseif (tp=="function") then
					if not coremoduleInternal[elem] then coremoduleInternal[elem] = {} end
					local fs = coremoduleInternal[elem]
					
					if not coremodule[elem] then
						local f = elem
						coremodule[elem]=function(...)
							for i=1,#fs do
								local fn = fs[i]
								fn(...)
							end
						end
					end
					table.insert(fs, dat)
				end
			else
				if nLog then 
					nLog.AddMessage("Auctioneer", "CoreModule", N_WARNING, "CoreModule did not match expected layout", 
						("For %s, Baseline %s has type %s while %s has type %s"):format(
							elem, ncheck[elem] or "??", tcheck[elem] or "??",
							mdl, tp))
				end
			end
		end
	end

	-- install as a Module
	lib.Modules.Util.CoreModule = coremodule
	lib.SendProcessorMessage("newmodule", "Util", "CoreModule")

	-- do OnLoad
	if coremodule.OnLoad then
		coremodule.OnLoad(addon)
	end

	-- delete the initialization code as we only need it once
	lib.CoreModuleOnLoad = nil
	lib.GetCoreModule = nil
end


AucAdvanced.RegisterRevision("$URL: http://dev.norganna.org/auctioneer/trunk/Auc-Advanced/CoreConst.lua $", "$Rev: 4598 $")
