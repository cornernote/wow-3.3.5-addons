--[[
	Enchantrix:Barker Addon for World of Warcraft(tm).
	Version: 5.9.4960 (WhackyWallaby)
	Revision: $Id: BarkerUtil.lua 4938 2010-10-14 17:41:42Z Nechckn $
	URL: http://enchantrix.org/

	General utility functions

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
EnchantrixBarker_RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.9/Enchantrix-Barker/BarkerUtil.lua $", "$Rev: 4938 $")

-- Global functions

local split
local chatPrint
local getRevision

local round
local roundUp

local createProfiler

------------------------
--   Item functions   --
------------------------


-----------------------------------
--   General Utility Functions   --
-----------------------------------

-- Extract the revision number from SVN keyword string
function getRevision(str)
	if not str then return 0 end
	local _, _, rev = str:find("Revision: (%d+)")
	return tonumber(rev) or 0
end

function split(str, at)
	local splut = {};

	if (type(str) ~= "string") then return nil end
	if (not str) then str = "" end

	if (not at)
		then table.insert(splut, str)

	else
		for n, c in str:gmatch('([^%'..at..']*)(%'..at..'?)') do
			table.insert(splut, n);

			if (c == '') then break end
		end
	end
	return splut;
end


function chatPrint(text, cRed, cGreen, cBlue, cAlpha, holdTime)
	local frameIndex = Barker.Settings.GetSetting('printframe');

	if (cRed and cGreen and cBlue) then
		if _G["ChatFrame"..frameIndex] then
			_G["ChatFrame"..frameIndex]:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);

		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, cRed, cGreen, cBlue, cAlpha, holdTime);
		end

	else
		if _G["ChatFrame"..frameIndex] then
			_G["ChatFrame"..frameIndex]:AddMessage(text, 1.0, 0.5, 0.25);
		elseif (DEFAULT_CHAT_FRAME) then
			DEFAULT_CHAT_FRAME:AddMessage(text, 1.0, 0.5, 0.25);
		end
	end
end


------------------------
--   Math Functions   --
------------------------

-- Round up m to nearest multiple of n
function roundUp(m, n)
	return math.ceil(m / n) * n
end

-- Round m to n digits in given base
function round(m, n, base, offset)
	base = base or 10 -- Default to base 10
	offset = offset or 0.5

	if (n or 0) == 0 then
		return math.floor(m + offset)
	end

	if m == 0 then
		return 0
	elseif m < 0 then
		return -round(-m, n, base, offset)
	end

	-- Get integer and fractional part of n
	local f = math.floor(n)
	n, f = f, n - f

	-- Pre-rounding multiplier is 1 / f
	local mul = 1
	if f > 0.1 then
		mul = math.floor(1 / f + 0.5)
	end

	local d
	if n > 0 then
		d = base^(n - math.floor(math.log(m) / math.log(base)) - 1)
	else
		d = 1
	end
	if offset >= 1 then
		return math.ceil(m * d * mul) / (d * mul)
	else
		return math.floor(m * d * mul + offset) / (d * mul)
	end
end


Barker.Util = {
	Revision			= "$Revision: 4938 $",

	Split				= split,
	ChatPrint			= chatPrint,
	GetRevision			= getRevision,

	Round				= round,
	RoundUp				= roundUp,
}



local DebugLib = LibStub("DebugLib")
local debug, assert
if DebugLib then
	debug, assert = DebugLib("Enchantrix-Barker")
else
	function debug() end
	assert = debug
end

ENX_CRITICAL = "Critical"
ENX_ERROR = "Error"
ENX_WARNING = "Warning"
ENX_NOTICE = "Notice"
-- info will only go to nLog
ENX_INFO = "Info"
-- Debug will print to the chat console as well as to nLog
ENX_DEBUG = "Debug"

function Barker.Util.DebugPrint(mType, mLevel, mTitle, ...)
	-- function debugPrint(addon, message, category, title, errorCode, level)
	local message = debug:Dump(...)
	debug(message, mType, mTitle, nil, mLevel)
end

-- when you just want to print a message and don't care about the rest
function Barker.Util.DebugPrintQuick(...)
	Barker.Util.DebugPrint("General", "Info", "QuickDebug", "QuickDebug:", ... )
end
