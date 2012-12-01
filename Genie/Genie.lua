--[[///////////////////////////////////////////////////////////////////////////////////////
    GENIE r218
        Core 218;
        
    Author: adjo
    Website: http://wow.curseforge.com/projects/genie
    Feedback: http://wow.curseforge.com/projects/genie/tickets/
    Localization: http://wow.curseforge.com/addons/genie/localization/
    
	adjo 2010-10-12T21:16:20Z

	This document may be redistributed as a whole, 
    provided it is unaltered and this copyright notice is not removed.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
    
--///////////////////////////////////////////////////////////////////////////////////////]]

Genie = LibStub("AceAddon-3.0"):NewAddon("Genie", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceComm-3.0", "AceSerializer-3.0")
local CLIENT_VERSION, CLIENT_BUILD = GetBuildInfo()
local L = LibStub("AceLocale-3.0"):GetLocale("Genie", true)

Genie.API = {} --global api
local API = Genie.API

Genie.ICONS = {}
    Genie.ICONS.editMode = 'Interface\\AddOns\\Genie\\Media\\icon_editmode' 
    Genie.ICONS.default = 'Interface\\AddOns\\Genie\\Media\\icon_default'
    Genie.ICONS[false] = Genie.ICONS.default
    Genie.ICONS[true] = Genie.ICONS.editMode

Genie.theWorks = {}
Genie.Queue = {}
Genie.SortStringCache = {}

Genie.FLAG_RSS = false --refresh sort string (CLASS.Item)
Genie.FLAG_GBILC = false -- guild bank item lock changed
Genie.FLAG_ERR = false -- error occurred
Genie.FLAG_GBOOS = 0
Genie.FLAG_IC = false -- in combat
Genie.FLAG_OC = true -- out of combat

--///////////////////////////////////////////////////////////////////////////////////
-- WOW API
--///////////////////////////////////////////////////////////////////////////////////
local BANK_CONTAINER = BANK_CONTAINER
local KEYRING_CONTAINER = KEYRING_CONTAINER
local BACKPACK_CONTAINER = BACKPACK_CONTAINER
--/////////////////////////////////////////////////////////////////////]]

-- available classes
Genie.CLASS = {}
Genie.CLASS.Bag = {}
Genie.CLASS.GuildBag = setmetatable({}, {__index = Genie.CLASS.Bag})
Genie.CLASS.Container = {}
Genie.CLASS.Family = {}
Genie.CLASS.Item = {}
Genie.UTILS = {}

local delay = 0
local printMemory = {}
local guildProfile

local debug = false
--@alpha@
debug = true
--@end-alpha@

--[[	UTILS	///////////////////////////////////////////////////////////////////////////////////
--]]
function Genie.UTILS.pairsByKeys(t, f)
--[[
	function Genie.UTILS.pairsByKeys
	http://www.lua.org/pil/19.3.html
--]]
	local func = {}
		func[false] = function(a,b)
				if type(a) ~= 'number' or type(b) ~= 'number' then
					return tostring(a) < tostring(b)
				else
					return a < b
				end
		end

		func[true] = function(a,b)
				if type(a) ~= 'number' or type(b) ~= 'number' then
					return tostring(a) > tostring(b)
				else
					return a > b
				end
		end

	local a = {}
	if t ~= nil then
	for n in pairs(t) do
		table.insert(a, n)
	end
	end

	if type(f) == 'function' then
		table.sort(a, f)
	elseif type(f) == 'boolean' then
		table.sort(a, func[f])
	else
		table.sort(a, func[false])
	end

	local i = 0      -- iterator variable
	local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	end
	return iter
end
function Genie.UTILS.MergeTable(t1, t2, priority)
	if type(t1) == "table" and type(t2) == "table" then
		for k,v in pairs(t2) do
			if priority == 2 or t1[k] == nil then
				t1[k] = v
			end
		end
	end
	return t1
end
function Genie.UTILS.ConcatTable(t1, t2, key)
	if type(t1) == "table" and type(t2) == "table" then
		for k,v in pairs(t2) do
			if key then
                table.insert(t1, k)
            else 
                table.insert(t1, v)
			end
		end
    end    
end
function Genie.UTILS.purgeText(text, complete)
	if text == nil then return '' end
	local str = string.lower(text):gsub('%d', '') -- all chars
	str = str:gsub('  ', ' '):trim() -- remove unneeded
	if complete == true then
		str = str:gsub('%c', ''):gsub('%p', ''):gsub('%s','')
	end
	return str
end
function Genie.UTILS.findPattern(text, pattern, start)
	if text~= nil and strlen(text) > 0 and string.find(text, pattern, start) ~= nil then
		return string.sub(text, string.find(text, pattern, start))
	end
	return ''
end
function Genie.UTILS.CopyTable(t)
    local tnew = {}
    if t then
        for i, e in pairs(t) do
            if type(e) == "table" then
                tnew[i] = Genie.UTILS.CopyTable(e)
            else
                tnew[i] = e
            end
        end
    end
	return tnew
end
function Genie.UTILS.FamilyInput(input)
	--[[ accepted inputs:
		<name with spaces> <itemlink|itemid>
		<name with spaces> !<item>!<item>!<item>
		or	<nr of family> instead of <name with spaces>
	--]]
	local output = {}
	local pattern = '^[^!%|]+'
	local name = Genie.UTILS.findPattern(input, pattern):trim()
	local other = ''
	if strlen(name) > 0 then
		local number = tonumber(name)
		if tostring(number) == name then
			if number <= 0 then return output end
			other = gsub(input, name, '', 1)
			if number == 1 then
				output[1] = string.lower(L['Ignore'])
			else
				number = number - 1
				local count = 1
				for rank, values in pairs(Genie.db.profile.classranking) do
					if values['type'] == 'family' then
						if number == count then
							output[1] = values['name']
							break
						end
						count = count +1
					end
				end
			end
		else
			output[1] = name
			other = gsub(input, output[1], '', 1)
		end
	end
	if strlen(other) > 0 then
		local params = { strsplit("!", other)}
		count = 2
		for i, v in pairs(params) do
			if v ~= nil and strlen(v:trim()) > 0 then
				local tmp = { strsplit('|', v:trim())}
				local items = {}
				local itemCount = 0
				for i, e in pairs(tmp) do
					if string.match(e, 'Hitem:([^:]+)') ~= nil then
						itemCount = itemCount+1
						table.insert(items, string.match(e, 'Hitem:([^:]+)'))
					end
				end
				if itemCount > 1 then
					for i, itemId in pairs(items) do
						output[count] = itemId
						count=count+1
					end
				else
					output[count] = v:trim()
					count=count+1
				end
			end
		end
	end
	return output
end
function Genie.UTILS.CalcGBDelay()
	local delay = tonumber(Genie:GetDB().global.GB_SlotCooldown) or 0
	local down, up, lag = GetNetStats()
	if lag > 0 then	lag = (3*lag/1000)+ 0.2+ delay
		else lag = 2 --failsave
	end
	return lag
end
function Genie.UTILS.GetTStID(t, sub)
	if not t then return nil end
	local itemClasses = { GetAuctionItemClasses() } --get all AIC's
	if #itemClasses > 0 then
		t = string.lower(t)
		local id, i, itemClass
		for i, itemClass in pairs(itemClasses) do
			if string.lower(itemClass) == t then
				id = 'aic' .. string.format("%.2d", i)
				if sub then
					-- we found the type
					sub = string.lower(sub)
					local itemSubClasses = { GetAuctionItemSubClasses(i) }
					if #itemSubClasses > 0 then
						-- there exist subclasses and a subclass was provided
						-- if type is empty, then this will return the first class/subclass pair found
						local j, itemSubClass
						for j, itemSubClass in pairs(itemSubClasses) do
							if string.lower(itemSubClass) == sub then
								id = id	.. string.format("%.2d", j)
								return id
							end
						end
						--if we arrive here, then the specified subclass doesn't exist, ergo this is no aic
						return nil
					elseif sub == t then
						--[[
							there's no subclass; like blizz does, create one sub class with the same name. ( quest->quest)
							use 00 as id, just in case blizz adds subclasses with a patch
						--]]
						id = id .. '00'
					else
						-- this can't be an aic
						return nil
					end
				end
				return id
			end
		end
	end
	return nil
end
function Genie.UTILS.SetGuildBankOption(tab)
    if Genie.currentGuild and tab then
        --first time
        if not rawget(Genie.db.factionrealm, 'gb') then Genie.db.factionrealm.gb = {} end
        if not rawget(Genie.db.factionrealm.gb, Genie.currentGuild) then Genie.db.factionrealm.gb[Genie.currentGuild] = {} end
        if not rawget(Genie.db.factionrealm.gb[Genie.currentGuild], tab) then Genie.db.factionrealm.gb[Genie.currentGuild][tab] = {}  end

        --clean
        Genie.db.factionrealm.gb[Genie.currentGuild][tab] = {}
        
        local git = GetGuildBankText(tab);        
        if git then
		git = string.lower(git)
		local guildBankOptions = string.match(git, '<genie>(.*)<\/genie>')
		if guildBankOptions and string.find(guildBankOptions, '@') then

            --set
            guildBankOptions = string.gsub(guildBankOptions,"%s","")
			guildBankOptions = {strsplit('@', guildBankOptions)}
			for _, option in pairs( guildBankOptions ) do
                if strlen(option) > 0 then
                    local setting = gsub(option, ':.*', '')  
                    local values = gsub(option,'[^:]*:?', '', 1)
                    if strlen(setting) > 0 then
                        Genie:DebugPrint(tab, setting, 1) 
                        if strlen(values) > 0 then
                            Genie.db.factionrealm.gb[Genie.currentGuild][tab][setting] = values
                        else
                            Genie.db.factionrealm.gb[Genie.currentGuild][tab][setting] = tab
                        end
                    end
                end
            end
        end
        end
    
    end
end
function Genie.UTILS.GetGuildBankOption(gbo, find)
	local function handleValueSearch(setting, values)
        --Genie:DebugPrint('UTILS.GetGuildBankOption.handleValueSearch', setting, values)    
        if string.lower(setting) == string.lower(gbo) and values then
            
			-- the option was found
			if find then
				-- we want to know if 'find' is part of this option
				for i, value in pairs({strsplit('!', values)}) do
                    if value == string.lower(tostring(find)) then 
                        return true 
                    end
				end
			else
				--we want to handle the values somewhere else
				return values
			end
		end
    end   
    
    if gbo then
        --Genie:DebugPrint('UTILS.GetGuildBankOption', 'gbo', gbo, find)
        -- search whitin the guildinfotext
		local guildBankOptions = string.match( string.lower(GetGuildInfoText()), '<genie>(.*)<\/genie>')          
		if guildBankOptions and string.find(guildBankOptions, '@') then
			guildBankOptions = string.gsub(guildBankOptions,"%s","")
			guildBankOptions = {strsplit('@', guildBankOptions)}
			for _, option in pairs( guildBankOptions ) do
                if string.len(option) > 0 then
                    local params = {strsplit(':', option)}
                    local result = handleValueSearch(params[1], params[2])
                    if result then 
                        return result 
                    end
                end
            end
		end
        --we want infos about a specific guildbanktab    
        if Genie.db.factionrealm.gb[Genie.currentGuild] then
            local pos = {strsplit(':', gbo)}
            if pos[2] then
                --search a specific tab
                return handleValueSearch(pos[1], Genie.db.factionrealm.gb[Genie.currentGuild][tonumber(pos[2])][pos[1]])
            else
                --search the currently selected tab
                for setting, value in pairs(Genie.db.factionrealm.gb[Genie.currentGuild][GetCurrentGuildBankTab()]) do
                    local result = handleValueSearch(setting, value)
                    if result then return result end
                end
            end
        end
    end
    
    return nil
end
function Genie.UTILS.GetAvailableBags(bagtype)
	local diff = {}
	if bagtype and bagtype.BAGSLOTS and bagtype.SHORT then
		if not rawget(Genie.db.profile, "bags") then Genie.db.profile.bags = {} end
		if not rawget(Genie.db.profile.bags, "ignore") then Genie.db.profile.bags.ignore = {} end	
		for _, slot in pairs(bagtype.BAGSLOTS) do
			if not Genie.db.profile.bags.ignore[bagtype.SHORT .. slot] then
				table.insert(diff, slot)
			end
		end
	end	
	return diff
end

function Genie.UTILS.substituteNumber(string, number, replacement)
    local function createPatterns(num, repl)  
        local patterns = {}
            patterns[repl..'%1'] = '^'.. num ..'([^0-9]+)'
            patterns['%1'..repl..'%2'] = '([^0-9]+)'.. num ..'([^0-9]+)'
            patterns['%1'..repl]= '([^0-9><=]+)'.. num ..'$' --remove ><= if you want to substitute everey number; this does allows parameters to be preserved
            patterns[repl]= '^'.. num ..'$'
  		return patterns
    end

    if string then
        for replace, pattern in pairs(createPatterns(number, replacement)) do
            local new, number = string:gsub(pattern, replace)
			if number > 0 then
				string = new
			end
		end
    end
    return string
end
function Genie.UTILS.moneyStringToCopper(money)
    gold = (string.match(money, '[^0-9]*(%d+)g') or 0)
    silver = (string.match(money, '[^0-9]*(%d+)s') or 0)
    copper = (string.match(money, '[^0-9]*(%d+)c?$') or 0)        
    return copper + (silver + gold*100) *100
end
function Genie.UTILS.tobool(bool)
    local translateBool = {}
        translateBool['1'] = true
        translateBool['true'] = true
 
    if type(bool) == 'boolean' then return bool end
    if translateBool[tostring(bool)] then
        return true
    else
        return false
    end
end


function Genie.UTILS.RegisterEventWithGui(event)
    if event then
        event = tostring(event)
        for index in pairs(Genie.OPT) do
            if Genie.OPT[index].args.events_select then
                Genie.OPT[index].args.events_select.values[index ..':'.. event] = L[event]
            end
        end
    end
end
--[[  CONSTANTS  //////////////////////////////////////////////////////////////////////////////////
]]--
Genie.CONSTANT = {
    --[[ todo: complete transition to Genie.Container ]]--
	BAGS = {
    -- todo: use Genie.Container
        TYPE = 1,
		SHORT = 'S',
		BAGSLOTS = {KEYRING_CONTAINER, 0, 1, 2, 3, 4},
	},
	BANK = {
    -- todo: use Genie.Container    
		TYPE = 2,
		SHORT = 'B',
		BAGSLOTS = {BANK_CONTAINER, 5, 6, 7, 8, 9, 10, 11},
	},
	GUILDBANK = {	
    -- todo: use Genie.Container    
		TYPE = 3,
		SHORT = 'G',		
		BAGSLOTS = {1, 2, 3, 4, 5, 6}, --not needed currently
		--@alpha@
		--BAGSLOTS = {2}, --for testing
		--@end-alpha@
	},
	--[[ not used
    -- todo: use Genie.Container    
	KEYRING = {
		TYPE = 4,
		SHORT = 'K',		
		BAGSLOTS = {KEYRING_CONTAINER}
	},
	--]]
    --[[ // transition ]]--

	FAMILY = {
		0, --1 Unspecified
		1,--2 Quiver
		2,--3 Ammo Pouch
		4,--4 Soul Bag
		8,--5 Leatherworking Bag
		16,--6 Inscription Bag
		32,--7 Herb Bag
		64,--8 Enchanting Bag
		128,--9 Engineering Bag
		256,--10 Keyring
		512,--11 Gem Bag
		1024,--12 Mining Bag
		2048,--13 Unknown
		4096, --14 Vanity Pets
	},
	NUMBER_MAX = 2147483647,
	CHAT_PREFIX = '('.. L['Genie'] ..'): ',
	CHAT_PREFIX_COLORED = "|cff33ff99".. L['Genie'] .."|r: ",
    AUTOMATIC_DELAY = 2.7,
    CHAT_TYPES = {PARTY=true, GUILD=true, OFFICER=true, EMOTE=true},--allowed printtochat chattypes
    COM = {
        SYNC = 'GENIE_SYNC',
        DATA = 'GENIE_DATA',
        TIME = 'GENIE_TIME',
        DBSET = 'GENIE_DB_SETTING_CHANGED',
    },
    

    BOOL_AND = '\038', --TODO: m.g.a
    BOOL_OR = '\124', 
    BOOL_NOT = '\126',
    SEPARATOR = '!',
    
    --allowed operators when creating a filter
    OP = {
        ['string'] = {'~=', '=', '=='},
        ['bool'] = {'~=', '=' },
        ['number'] = {'>', '>=', '~=', '=', '<=', '<' }
    },
}

--[[  Database defaults ///////////////////////////////////////////////////////////////////////////
--]]
local db
local defaults = {
    global = {
		GB_SlotCooldown = 0,
		GB_SwapsPerCycle = 1,
		GB_PermissionsSave	= {},
	},
    factionrealm = {
        ['**'] = {
            gbank = { lock = true, },
            sync = false,
            useProfile = false,
            switchProfile = false,
        },
    },
	profile = {
		customFamilies = {
			['**'] = {
				['enabled'] = true,
				['ignore'] = false,
			},
		},
		sortalgo = 'sort_quick3',
		invert = false,
		bags = {
			['**'] = false,
		},
		mode = {
			['**'] = false,
            ['waitAfterCombat'] = 15,
		},
        events = {
            ['**'] = '',
        },
	},
}
local defaultClassRanking = {
		[1] = {
			criteria = 'QuestItem',
			name = ITEM_BIND_QUEST,
			enabled = true,
			type = 'bool',
		},
		[2] = {
			criteria = 'Soulbound',
			name = L['Soulbound'],
			enabled = true,
			type = 'bool',
		},
		[3] = {
			criteria = 'Rarity',
			name = L['Rarity'],
			enabled = true,
			type = 'number',
			invert = true,
			max = 9,
		},
		[4] = {
			criteria = 'TStID',
			name = L['TStID'],
			enabled = true,
			max = 9999,
			type = 'number',
			invert = false,
		},
		[5] = {
			--todo: create a customizable ranking
			criteria = 'EquipLoc',
			name = L['EquipLoc'],
			enabled = true,
			type = 'string',
		},
		[6] = {
			criteria = 'Name',
			name = L['Name'],
			enabled = true,
			type = 'string',
		},
		[7] = {
			criteria = 'Count',
			name = L['Count'],
			enabled = true,
			type = 'number',
			max = 9999,
		},
		[8] = {
			criteria = 'Unique',
			name = L['Unique'],
			enabled = false,
			type = 'bool',
			invert = true,
		},
		[9] = {
			criteria = 'iLvl',
			name = L['iLvl'],
			enabled = false,
			type = 'number',
			max = 999,
		},
		[10] = {
			criteria = 'MinLevel',
			name = L['MinLevel'],
			enabled = false,
			type = 'number',
			max = 99,
		},
		[11] = {
			criteria = 'StackCount',
			name = L['StackCount'],
			enabled = false,
			type = 'number',
			max = 9999,
		},
		[12] = {
			criteria = 'Texture',
			name = L['Texture'],
			enabled = false,
			type = 'string',
		},
		[13] = {
			criteria = 'Type',
			name = L['Type'],
			enabled = false,
			type = 'string',
		},
		[14] = {
			criteria = 'SubType',
			name = L['SubType'],
			enabled = false,
			type = 'string',
		},
		[15] = {
			criteria = 'boe',
			name = ITEM_BIND_ON_EQUIP,
			enabled = false,
			type = 'bool',
		},
		[16] = {
			criteria = 'bop',
			name = ITEM_BIND_ON_PICKUP,
			enabled = false,
			type = 'bool',
		},
		[17] = {
			criteria = 'bou',
			name = ITEM_BIND_ON_USE,
			enabled = false,
			type = 'bool',
		},
		[18] = {
			criteria = 'boa',
			name = ITEM_BIND_TO_ACCOUNT,
			enabled = false,
			type = 'bool',
		},
		[19] = {
			criteria = 'ItemID',
			name = L['ItemID'],
			enabled = false,
			type = 'number',
			max = 999999,
			invert = true,
		},
		[20] = {
			criteria = 'Price',
			name = L['Price'],
			enabled = false,
			type = 'number',
			max = 9999999999,
			invert = true,
		},
		[21] = {
			criteria = 'SkillLvl',
			name = CHAT_MSG_SKILL,
			enabled = false,
			type = 'number',
			max = 999,
			invert = true,
		},
		
		
		
		--[[
		-- template //////////////////
		{
			criteria = '',
			name = L[''],
			enabled = true,
			type = 'string', -- bool, family
		},
		{
			criteria = '',
			name = L[''],
			enabled = true,
			type = 'number',
			max = 999, -- only available with number-type
		},
		--]]
		}

--[[ available bagtypes
    idea: allow the user to define containers
--]]

--///////////////////////////////////////////////////////////////////////////////////
-- Genie.Container
--///////////////////////////////////////////////////////////////////////////////////
Genie.Container = {
    --api
	_B = { --the default bank slots
		BAGS = {BANK_CONTAINER},
        api = true,
	},
    _BC = {
        api = true,
        BAGS = {}, --injected
    },
	_K = {
        api = true,
		BAGS = {KEYRING_CONTAINER},
	},
    _I = {
        BAGS = {},
        api = true,
    },
    _SB = {
        api = true,
        --backpack
        BAGS = {BACKPACK_CONTAINER},
    },
	_SC = {
        api = true,   
        BAGS = {}, --injected
	},
    --internal only; use at your own risk
    _S = {
        api = true,
        GROUP = {_SB = '_SB', _SC = '_SC'},
    },
    _C = { 
        api = true,
        GROUP = {_SB = '_SB', _SC = '_SC', _BC = '_BC'},        
    },    
    -- visible to the user
	S = {
        NAME = L.Bags,       
        GROUP = { '_K', '_SB', '_SC'},
    },
	B = {
        NAME = L.Bank, 
        GROUP = {'_B', '_BC'},        
        
	},
    G = {
        NAME = L.Guildbank,
        GROUP = {}, --injected
        guild = true,
    },
}        
-- Genie.Container injection
--_SC
for i=1, NUM_BAG_SLOTS do
    table.insert(Genie.Container._SC.BAGS, i)
end
--_BC
for i=NUM_BAG_SLOTS+1, NUM_BAG_SLOTS+NUM_BANKBAGSLOTS do
    table.insert(Genie.Container._BC.BAGS, i)
end
--G, _G<#tab>T
for i=1, MAX_GUILDBANK_TABS, 1 do
    local current = '_G' .. i .. 'T'
    Genie.Container[current] = {}
    Genie.Container[current].api = true
    Genie.Container[current].NAME = L.Guildbank ..' '.. i
    Genie.Container[current].BAGS = {i}
    table.insert(Genie.Container.G.GROUP, current)
end
--/////////////////////////////////////////////////////////////////////]]
 
--///////////////////////////////////////////////////////////////////////////////////
-- GroupUtils
-- todo rename and move to own class/file
--///////////////////////////////////////////////////////////////////////////////////
function Genie.UTILS.getContainerAndInteralID(bagID)
    return string.match(tostring(bagID), '^(_%w*)(%d+)$')
end
function Genie.UTILS.convertToWowBagID(bagID)
    local gC = Genie.Container
    local container, interalID = Genie.UTILS.getContainerAndInteralID(bagID)
    if gC[container] and gC[container].BAGS then
        return gC[container].BAGS[tonumber(interalID)], container
    end
    return bagID --todo:remove, and test
end

function Genie.UTILS.convertToGenieBagID(bagID, short)
    if not string.match(bagID, '%a(%d+)') then
        local bagID = tostring(bagID)
        local short = tostring(short or 'c'):upper()
    
        if Genie.Container[short] then
            for internalID, apiBagID in Genie.UTILS.pairsByKeys(Genie.Container[short].BAGSLOTS) do
                if apiBagID == tonumber(bagID) then
                    bagID = short .. internalID
                    return bagID, short
                end
            end
        end
        return
    end
    return bagID, short
end


function Genie.UTILS.GroupGetParent(group)
    local gC = Genie.Container
    if gC[group] then
        if gC[group].GROUP then 
            return group 
        end
        for short, container in pairs(gC) do
            if container.GROUP and string.find(table.concat(container.GROUP, '#'), group) then
                return short
            end
        end
    end
end


function Genie.UTILS.GroupGetBags(group, parent, all, find)
	local diff = {}
    local gC = Genie.Container
    if gC[group] then
        if gC[group].BAGS then
            if not rawget(Genie.db.profile, "bags") then Genie.db.profile.bags = {} end
            if not rawget(Genie.db.profile.bags, "ignore") then Genie.db.profile.bags.ignore = {} end	
            local parent = parent or Genie.UTILS.GroupGetParent(group)
            for number, slot in ipairs(gC[group].BAGS) do
                if all or (not Genie.db.profile.bags.ignore[group .. number]) then
                    if find then
                        if slot == tonumber(find) then
                            return group..number
                        end
                    else
                        table.insert(diff, group .. number)
                    end
                end
            end
        elseif gC[group].GROUP then
            if find then
                local found
                for _, sub in pairs(gC[group].GROUP) do
                    found = Genie.UTILS.GroupGetBags(sub, group, all, find)
                    if found then return found end
                end
            else
                for _, sub in pairs(gC[group].GROUP) do
                    Genie.UTILS.ConcatTable(diff, Genie.UTILS.GroupGetBags(sub, group, all, find))
                end
            end
        end
    else
        Genie:DebugPrint(group,"doesn't exist")
    end
    if not find then
        return diff
    end
end

function Genie.UTILS.GroupGetAllBags(group)
    return Genie.UTILS.GroupGetBags(group, nil, true)
end
function Genie.UTILS.GroupGetName(group)
    local gC = Genie.Container
    if gC[group] and gC[group].NAME then
        return gC[group].NAME
    end
end

function Genie.UTILS.GroupGetVisibleUser()
    local visible = {}
    for short, def in pairs(Genie.Container) do
        if not def.api then
            table.insert(visible, short)
        end
    end
    return visible
end

function Genie.UTILS.GroupFindBag(group, bagslot)
    return Genie.UTILS.GroupGetBags(group, nil, true, tostring(bagslot))
end
--/////////////////////////////////////////////////////////////////////]]
 
Genie.CMD = {
    name = L['Genie'],
    handler = Genie,
    type = 'group',
    args = {
		inspect = {
			order = 30,
			type = "input",
			name = L['Inspect'],
			set = "Inspect",
		},
		dev = {
			order = 99,
			type = "input",
			hidden = true,
			name = 'develop',
			desc = 'Don\'t use this! this command is for internal use only',
			set="Develop",
		},
		auto = {
			order = 5,
			type = 'execute',
			name = L['Automatic'],
			func = 'SetAuto',
		},
		stop = {
			order = 29,
			type = 'execute',
			name = L['Stop'],
			func = 'Stop',
		},
		work = {
			order = 1,
			type = 'execute',
			name = L['Work'],
			desc = L['Stack, move and sort your X']:gsub('X', L['bag/ bank or guildbank']),
			func = 'PreWorks',
		},
		bag = {
			order = 2,
			type = 'group',
			name = L['Bag'],
			args = {
				move = {
					type = 'execute',
					name = L['Move all items'],
					func = 'DoBagMove',
					order = 2,
				},
				stack = {
					type = 'execute',
					name = L['Stack all items'],
					func = 'DoBagStack',
					order = 3,
				},
				sort = {
					type = 'execute',
					name = L['Sort all items'],
					func = 'DoBagSort',
					order = 4,
				},
				work = {
					type = 'execute',
					name = L['Stack, move and sort your X']:gsub('X', L['Bags']),
					func = 'DoBagWorks',
					order = 1,
				},

			},
		},
		bank = {
			order = 3,
			type = "group",
			name = L['Bank'],
			args = {
				move = {
					type = 'execute',
					name = L['Move all items'],
					func = 'DoBankMove',
					order = 2,
				},
				stack = {
					type = 'execute',
					name = L['Stack all items'],
					func = 'DoBankStack',
					order = 3,
				},
				sort = {
					type = 'execute',
					name = L['Sort all items'],
					func = 'DoBankSort',
					order = 4,
				},
				work = {
					type = 'execute',
					name = L['Stack, move and sort your X']:gsub('X', L['Bank']),
					func = 'DoBankWorks',
					order = 1,
				},
			},
		},
		guildbank = {
			order = 3,
			type = "group",
			hidden = true,
			disabled = true,
			name = L['Guildbank'],
			args = {
				move = {
					type = 'execute',
					name = L['Move all items'],
					func = 'DoGuildbankMove',
					order = 2,
				},
				stack = {
					type = 'execute',
					name = L['Stack all items'],
					func = 'DoGuildbankStack',
					order = 3,
				},
				sort = {
					type = 'execute',
					name = L['Sort all items'],
					func = 'DoGuildbankSort',
					order = 4,
				},
				work = {
					type = 'execute',
					name = L['Stack, move and sort your X']:gsub('X', L['Guildbank']),
					func = 'DoGuildbankWorks',
					order = 1,
				},
			},
		},
		rank = {
			order = 10,
			type="group",
			name=L['Classranking'],
			args = {
				show = {
					type = "execute",
					name = L['Show'] ..' '.. L['Classranking'],
					func = "ClassRankingShow",
				},
				update = {
					type = "input",
					name = L['Update a class'],
					set = "ClassRankingUpdate",
				},
				enable = {
					type = "input",
					name = L['Enable a class'],
					set = "ClassRankingEnable",
				},
				disable = {
					type = "input",
					name = L['Disable a class'],
					set = "ClassRankingDisable",
				},
				invert = {
					type = "input",
					name = L['Invert a class'],
					set = "ClassRankingInvert",
				},
				reset = {
					type = "execute",
					name = L['Reset the classranking'],
					func = "ClassRankingReset",
				},
                combine = {
                    type = "input",
                    name = L['Combine one or more ranks'],
                    set = "ClassRankingCombine",
                },
                delete = {
                    type = "input",
                    name = L['Delete a combined rank'],
                    set = "ClassRankingDelete",
                },
                details = {
                    type = "input",
                    name = L['Display detailed infos about a rank'],
                    set = "ClassRankingDetails",
                },                
            },
		},
		family = {
			order = 20,
			type = "group",
			name = L['Family'],
			args = {
				show = {
					type = "input",
					name = L['Show'] ..' '.. L['Family'],
					set = "FamilyShow",
				},
				update = {
					type="input",
					name=L['Update'],
					set= "FamilyUpdate",
				},
				rename = {
					type = "input",
					name=L['Rename'],
					desc=L['Rename'] ..' '.. L['Family'],
					set="FamilyRename",
				},
				ignore = {
					type="input",
					name= L['Ignore'],
					desc= L['Ignore all elements of this X']:gsub('X', L['Family']),
					set="FamilyIgnore",
				},
				--[[
				enable = {
					type = "input",
					name = L['Enable'] ..'/ '..L['Disable']..' '.. L['Family'],
					set = "FamilyEnable",
				},
				--]]
				delete = {
					type="input",
					name=L['Delete']..' '..L['Family'],
					set= "FamilyDelete",
				},

			},
		},
		ignore = {
			order = 21,
			type = "input",
			name = L['Ignore'],
			set = "Ignore",
		},
	},
}

--add shortcuts
Genie.CMD.args.f = Genie.UTILS.CopyTable(Genie.CMD.args.family)
Genie.CMD.args.f.hidden = true
Genie.CMD.args.r = Genie.UTILS.CopyTable(Genie.CMD.args.rank)
Genie.CMD.args.r.hidden = true
Genie.CMD.args.i = Genie.UTILS.CopyTable(Genie.CMD.args.ignore)
Genie.CMD.args.i.hidden = true
Genie.CMD.args.gb = Genie.UTILS.CopyTable(Genie.CMD.args.guildbank)
Genie.CMD.args.gb.hidden = true

Genie.OPT = {}
Genie.OPT.Genie = {
    name = L['Genie'],
    handler = Genie,
    type = 'group',
    args = {
		silent = {
			order=3,
			type="multiselect",
			name=L['Silent'],
			values = {
				silent_sound = L['Sound'],
				silent_text = L['Text'],
			},		
			get = "IsMode",
			set = "ToggleMode",		
		},
		reverse = {
			order = 2,
			type = "multiselect",
			name = L['Reverse'],
			desc = L["Reverse the order in which your bags and/or bagslots will be accsessed"],
			values = {
				reversebags = L['Bags'],
				reverseslots = L['Slots'],
			},
			get = "IsMode",
			set = "ToggleMode",
		},
        automatic = {
            order = 1,
            type = 'group',
            inline = true,
            name = L['Automatic'],
            args = {
                enabled = {
                    order = 1,
                    type = "toggle",
                    name = L['Enabled'],
                    get = "IsAuto",
                    set = "ToggleAuto",
                },            
                waitAfter = {
                    order = 4,
                    type = 'range',
                    name = L['waitAfter'],
                    min = 1,
                    max = 60,
                    step = 1,
                    set = "SetWaitAfterCombat",
                    get = "GetWaitAfterCombat",
                },           
            },
        },       
	},
}
Genie.OPT.Sort = {
    name = L['Sorting'],
    handler = Genie,
    type = 'group',
    args = {
		sortalgo = {
			order= 10,
			type = 'select',
			name = L['Sorting algorithm'],
			style = 'radio',
			values = {
				sort_select = L['sort_select'],
				sort_quick3 = L['sort_quick3'],
				sort_heap = L['sort_heap'],
				sort_insert = L['sort_insert'],
			},
			set="SetSortAlgorithm",
			get="GetSortAlgorithm",
		},
		invert = {
			order = 11,
			type = "toggle",
			name = L['Invert the sorting order'],
			get = "IsInvert",
			set = "ToggleInvert",
		},
		events_select = {
			order = 16,
			type = 'multiselect',
			--disabled = false,
			width = 'full',
			name = L['Automatic X events']:gsub('X', L['Sorting']),
			values = {},
			set = 'ToggleEvent',
			get = 'IsEvent',
		},
	},
}
Genie.OPT.Move = {
    name = L['Moving'],
    handler = Genie,
    type = 'group',
    args = {
		events_select = {
			order = 16,
			disabled = false,
			type = 'multiselect',
			--disabled = false,
			width = 'full',
			name = L['Automatic X events']:gsub('X', L['Moving']),
			values = {},
			set = 'ToggleEvent',
			get = 'IsEvent',
		},
	}
}
Genie.OPT.Stack = {
    name = L['Stacking'],
    handler = Genie,
    type = 'group',
    args = {
		events_select = {
			order = 16,
			type = 'multiselect',
			--disabled = true,
			width = 'full',
			name = L['Automatic X events']:gsub('X', L['Stacking']),
			values = {},


			set = 'ToggleEvent',
			get = 'IsEvent',
		},
	}
}
Genie.OPT.Bags = {
    name = L['Bags'],
    handler = Genie,
    type = 'group',
    args = {
		bagslots = {
			order = 1,
			type = 'description',
			name = 'If you need more info about bagslots look at http://www.wowwiki.com/BagId',	
		},	
		ignore_header = {
			type = 'header',
			name = L['Ignore'],
			order = 13,			
		},
		bag_select = {
			order = 16,
			type = 'multiselect',
			--disabled = true,
			name = L['Bags'],
            values = function()
                local b = {}
                local bag
                for nr, bagID in pairs(Genie.UTILS.GroupGetAllBags('S')) do
                    bag = Genie.CLASS.Container:NewBag(bagID)
                    if bag then
                        b[bagID] = nr .. ' ('.. bag:GetName() ..')' 
                    else
						b[bagID] = nr
                    end
                end
                return b
            end,
			set = 'ToggleBagslot',
			get = 'IsIgnoredBagslot',
		},
		bank_select = {
			order = 17,
			type = 'multiselect',
			--disabled = true,
			name = L['Bank'],
            values = function()
                local b = {}
                local bag
                for nr, bagID in pairs(Genie.UTILS.GroupGetAllBags('B')) do
                    bag = Genie.CLASS.Container:NewBag(bagID)
                    if bag then
                        b[bagID] = nr .. ' ('.. bag:GetName() ..')' 
                    else
						b[bagID] = nr
                    end
                end
                return b
            end,
			set = 'ToggleBagslot',
			get = 'IsIgnoredBagslot',
		},			
	},
}

Genie.OPT.Guildbank = {
    name = L['Guildbank'],
    handler = Genie,
    disabled = function() if Genie.currentGuild then return false else return true end end,
    type = 'group',
    args = {
		GB_SlotCooldown = {
			order = 1,
			type = 'input',
			name = L['SlotCooldown'],
			desc = L['SlotCooldown:desc'],
            set = 'GBInputsSet',
            get = 'GBInputsGet',
        },
        GB_SwapsPerCycle = {
			order = 2,
			type = 'input',
			name = L['SwapsPerCycle'],
			desc = L['SwapsPerCycle:desc'],
			set = 'GBInputsSet',
			get = 'GBInputsGet',
		},
		GB_LockGuildBank = {
            order = 3,
            type = 'toggle',
            disabled = function() return not IsGuildLeader(UnitName("player")) end,
            hidden = function() return not IsGuildLeader(UnitName("player")) end,
            width = 'full',
			name = L['Lock the Guildbank'],
			desc = L['Lock the Guildbank:desc'],
			set = 'GBInputsSet',
			get = 'GBInputsGet',
		},    
        useProfile = {
            name = L["UseProfile"],
            type = 'select',
            values = function() local profiles = {} profiles["__FALSE"]='' for _,v in pairs(Genie.db:GetProfiles()) do profiles[v] = v end return profiles end,
			set = function(info, input) 
                Genie:DebugPrint(type(input), input)
                if Genie.currentGuild then --just to be sure ;)
                    if input ~= "__FALSE" then
                        Genie.db.factionrealm[Genie.currentGuild].useProfile = input 
                    else
                        Genie.db.factionrealm[Genie.currentGuild].useProfile = false                     
                        Genie.db.factionrealm[Genie.currentGuild].sync = false                    
                    end 
                end
            end,
			get = function() if Genie.currentGuild and Genie.db.factionrealm[Genie.currentGuild].useProfile then return Genie.db.factionrealm[Genie.currentGuild].useProfile end end,            
			order = 20,            
        },
        sync = {
            type = 'toggle',
			name = L["Sync"],
            disabled = function() 
                if Genie.currentGuild and Genie.db.factionrealm[Genie.currentGuild].useProfile then 
                    return false 
                else 
                    return true 
                end
            end,
			get = function() if Genie.currentGuild then return Genie.db.factionrealm[Genie.currentGuild].sync end end,
			set = function(info, input) if Genie.currentGuild then Genie.db.factionrealm[Genie.currentGuild].sync = input end end,            
			order = 21,                    
        },
    },
}



   
--[[  GUI OptionsFrame ////////////////////////////////////////////////////////////////////////////
--]]
function Genie:IsEvent(info, value)
	--return db.events[value]
	local action, event = strsplit(':', value)
	local found, one
		if db.events[event] ~= nil then
			one, found = string.find(db.events[event], action)
		end
		if found ~= nil then return true else return false end
end
function Genie:ToggleEvent(info, value)
	--db.events[value] = not db.events[value]
	local action, event = strsplit(':', value)
	if db.events[event] ~= nil then
		local new, found = string.gsub(db.events[event], action, '')
		if found == 0 then
			--enable
			db.events[event] = db.events[event] .. action .. ','
		else
			--disable
			new = gsub(new, '^,', '')
			new = gsub(new, ',,', ',')
			db.events[event] = new
		end
	else
		db.events[event] = action
	end
end
function Genie:GetSortAlgorithm(info)
	return db.sortalgo
end
function Genie:SetSortAlgorithm(info, value)
	db.sortalgo = value
end
function Genie:IsMode(info, value)
    return db.mode[value]
end
function Genie:ToggleMode(info, value)
	db.mode[value] = not db.mode[value]
end
function Genie:IsInvert(info)
	return db.invert
end
function Genie:ToggleInvert(info, value)
	db.invert = value

end

function Genie:IsAuto()
    return db.mode.automatic
end
function Genie:ToggleAuto()
    db.mode.automatic = not db.mode.automatic
end


function Genie:SetAuto()
	local function activateEvent(doAtEvent)
		local todo, event = strsplit(':', doAtEvent)
		if db.events[event] == nil then db.events[event] = '' end
		if string.find(db.events[event], todo) == nil then
			db.events[event] = db.events[event] .. todo .. ','
		end
	end
	if db.mode.automatic == true then
		db.mode.automatic = false
		self:SilentPrint(L["Automatic mode"], ':', L["Disabled"])
	else
		db.mode.automatic = true
        for index in pairs(Genie.OPT) do
            if Genie.OPT[index].args.events_select then
                for doAtEvent in pairs(Genie.OPT[index].args.events_select.values) do activateEvent(doAtEvent) end
            end
        end
		self:SilentPrint(L["Automatic mode"], ':', L["Enabled"])
	end
end


function Genie:GBInputsSet(info, value)
    self.db.global[info[1]] = value
end
function Genie:GBInputsGet(info, value)
    return self.db.global[info[1]]
end
function Genie:ToggleBagslot(info, value)
    local value, short = gsub(value, '^%d*', '')
	if rawget(db.bags.ignore, value) then
		db.bags.ignore[value] = nil
	else
		db.bags.ignore[value] = true
	end
end
function Genie:IsIgnoredBagslot(info, value)
    local value, short = gsub(value, '^%d*', '')
	if not db.bags then db.bags = {} end
	if not db.bags.ignore then db.bags.ignore = {} end
	
	return db.bags.ignore[value]
end

function Genie:SetWaitAfterCombat(info, value)
    db.mode.waitAfterCombat = tonumber(value)
end
function Genie:GetWaitAfterCombat(info, value)
    return db.mode.waitAfterCombat
end

--[[  Genie ///////////////////////////////////////////////////////////////////////////////////////
--]]
function Genie:OnInitialize()
    self.VERSION = GetAddOnMetadata('Genie', 'Version')

	--variables
	self.atBank = false
	self.atGuildBank = false
    
    -- database -----------------------------------------------------------------------------
    self.db = LibStub("AceDB-3.0"):New("GenieDB", defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	db = self.db.profile --shortcut to the current profile
	--check if the selected profile has a classranking, otherwise fill with the default classranking
	if not rawget(db, 'classranking') then
		db.classranking = defaultClassRanking
	end

	local ac = LibStub("AceConfig-3.0")
	--[[	Slashcommands --------------------------------------------------------------------]]
	--cmd
	ac:RegisterOptionsTable(L["Genie"]..": SlashCommands", Genie.CMD)
    self:RegisterChatCommand("genie", "ChatCommand")

	--[[	AddonOptions ----------------------------------------------------------------------]]

	-- general
	ac:RegisterOptionsTable('Genie', Genie.OPT.Genie)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie', "Genie")
	-- sorting
	ac:RegisterOptionsTable(Genie.OPT.Genie.name..": "..Genie.OPT.Sort.name, Genie.OPT.Sort)
	self.optionsFrame.Sort = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..Genie.OPT.Sort.name, Genie.OPT.Sort.name, "Genie")
	-- moving
	ac:RegisterOptionsTable(Genie.OPT.Genie.name..": "..Genie.OPT.Move.name, Genie.OPT.Move)
	self.optionsFrame.Move = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..Genie.OPT.Move.name, Genie.OPT.Move.name, "Genie")
	-- stacking
	ac:RegisterOptionsTable(Genie.OPT.Genie.name..": "..Genie.OPT.Stack.name, Genie.OPT.Stack)
	self.optionsFrame.Stack = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..Genie.OPT.Stack.name, Genie.OPT.Stack.name, "Genie")
	-- bags
	ac:RegisterOptionsTable(Genie.OPT.Genie.name..": "..Genie.OPT.Bags.name, Genie.OPT.Bags)
	self.optionsFrame.Bags = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..Genie.OPT.Bags.name, Genie.OPT.Bags.name, "Genie")
	-- guildbank
	ac:RegisterOptionsTable(Genie.OPT.Genie.name..": "..Genie.OPT.Guildbank.name, Genie.OPT.Guildbank)
	self.optionsFrame.Guildbank = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..Genie.OPT.Guildbank.name, Genie.OPT.Guildbank.name, "Genie")
	-- profiles
	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	ac:RegisterOptionsTable(L["Genie"]..": ".. profiles.name, profiles)
	self.optionsFrame.Profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions('Genie: '..profiles.name, profiles.name, "Genie")

	self:Print(L['Version'], self.VERSION)

	self:Update()
    
    --@alpha@
        self.db.global.gC = Genie.Container
    --@end-alpha@
end

function Genie:GetDB()
    return self.db
end

function Genie:ChatCommand(input)
  if (not input or input:trim() == "") and API.ToggleOptionsFrame then
    API:ToggleOptionsFrame()
  elseif (input:trim() == "r" or input:trim() == "rank") and API.ToggleUI then
    API:ToggleUI()
  else
    LibStub("AceConfigCmd-3.0").HandleCommand(Genie, "genie", L["Genie"]..": SlashCommands", input)
  end
end


function Genie:OnEnable()
	-- Register Events
	self:RegisterEvent('GUILD_ROSTER_UPDATE')
    self:RegisterEvent('PLAYER_GUILD_UPDATE')
    
	self:RegisterEvent('UI_ERROR_MESSAGE')
    self:RegisterEvent('ADDON_ACTION_FORBIDDEN')
    
	self:RegisterEvent('GUILDBANK_ITEM_LOCK_CHANGED')
	self:RegisterEvent('GUILDBANK_UPDATE_TABS')
	self:RegisterEvent('GUILDBANK_TEXT_CHANGED')    
    
    self:RegisterEvent('LOOT_CLOSED')
        self.UTILS.RegisterEventWithGui('LOOT_CLOSED')
	self:RegisterEvent('BAG_CLOSED') -- internal
	--self:RegisterEvent('BAG_UPDATE')
	self:RegisterEvent('MAIL_CLOSED')
        self.UTILS.RegisterEventWithGui('MAIL_CLOSED')
	self:RegisterEvent('TRADE_CLOSED')
        self.UTILS.RegisterEventWithGui('TRADE_CLOSED')
	self:RegisterEvent('MERCHANT_CLOSED')
        self.UTILS.RegisterEventWithGui('MERCHANT_CLOSED')
	self:RegisterEvent('BANKFRAME_CLOSED')
        self.UTILS.RegisterEventWithGui('BANKFRAME_CLOSED')    
	--self:RegisterEvent('ITEM_PUSH')
	--self:RegisterEvent('ITEM_LOCK_CHANGED')
	self:RegisterEvent('BANKFRAME_OPENED')
        self.UTILS.RegisterEventWithGui('BANKFRAME_OPENED')
	--self:RegisterEvent('PLAYERBANKBAGSLOTS_CHANGED')
	--self:RegisterEvent('PLAYERBANKSLOTS_CHANGED') -- internal
	self:RegisterEvent('GUILDBANKFRAME_OPENED')
        self.UTILS.RegisterEventWithGui('BANKFRAME_OPENED')
	self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
	self:RegisterEvent('GUILDBANKFRAME_CLOSED')
        self.UTILS.RegisterEventWithGui('GUILDBANKFRAME_CLOSED')
    self:RegisterEvent('GUILDBANK_UPDATE_TEXT')
	
	self:RegisterEvent('PLAYER_ENTER_COMBAT')
	self:RegisterEvent('PLAYER_LEAVE_COMBAT')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
    self:RegisterEvent('PLAYER_DEAD')
    
    --Equipment Sets
    self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
    self:RegisterEvent('EQUIPMENT_SWAP_FINISHED')
        self.UTILS.RegisterEventWithGui('EQUIPMENT_SWAP_FINISHED')
        
	-- Create a tooltip to get iteminfos from; isn't used for anything else
	CreateFrame( "GameTooltip", "GenieScanningTooltip" ) -- Tooltip name cannot be nil
	GenieScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" )
	-- Allow tooltip SetX() methods to dynamically add new lines based on these
	GenieScanningTooltip:AddFontStrings(
		GenieScanningTooltip:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
		GenieScanningTooltip:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" )
		)
	delay = tonumber(Genie.db.global.GB_SlotCooldown)
	
    if IsInGuild() then 
        GuildRoster() 
	    self:RegisterComm(Genie.CONSTANT.COM.SYNC)
    	self:RegisterComm(Genie.CONSTANT.COM.DATA)
    	self:RegisterComm(Genie.CONSTANT.COM.TIME)
        Genie:LookForNewGuildProfile()        
    end
    
    --[[ MOVED TO: LDB+I.lua
	if LibStub:GetLibrary('LibDataBroker-1.1', true) then
		self:LoadDataBrokerPlugin()
	end
    --]]
end
function Genie:OnDisable()
    -- Called when the addon is disabled
	self:UnregisterAllEvents()
	self:CancelAllTimers()
    
    -- Unload and disable all LoD- Modules
    for name, module in Genie:IterateModules() do
        module:Disable()
        if IsAddOnLoadOnDemand(tostring(module)) then
            DisableAddOn(tostring(module))
        end
    end      
end
function Genie:RefreshConfig(event, database, profilekey)
	db = database.profile
	--check if the selected profile has a classranking, otherwise fill with the default classranking
	if not rawget(db, 'classranking') then
		db.classranking = Genie.UTILS.CopyTable(defaultClassRanking)
	end
   
    self:Update()
end
function Genie:Update()
	-- get the current profile-db-version
	local currentDBVersion = tonumber(db.version);
		if not currentDBVersion then currentDBVersion = 0 end
	-- get the new db version (which the profile will be after the update)
	local newDBVersion = self.VERSION:gsub('_.*', ''):gsub('[^0-9]', '')
		newDBVersion = tonumber(newDBVersion)

	-- update if necessary
	if currentDBVersion < newDBVersion or debug then
		if currentDBVersion < 3043 then
			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if classdef.type == 'ranking' then
					db.classranking[classrank] = nil
				end
			end
		end

		if currentDBVersion < 3048 then
			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if classdef.criteria == "Level" then
					db.classranking[classrank].name = L['iLvl']
					db.classranking[classrank].criteria = 'iLvl'
				end
			end
		end

		if currentDBVersion < 3049 then
			if not db.bags then 
				db.bags = {} 
				db.bags['**'] = false	
			end
			if not db.bags.ignore then db.bags.ignore = {} end
		end		
		
		if currentDBVersion < 3050 then
			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if classdef.criteria == "Questitem" then
					db.classranking[classrank].criteria = 'QuestItem'
				end
			end			
		end
        
        if currentDBVersion < 3051 then
            for index, family in pairs(db.customFamilies) do
                if db.customFamilies[index].ignore == true then
                    db.customFamilies[index].ignore = {}
                end
                if db.customFamilies[index].set then
                    db.customFamilies[index] = nil
                else
                    for id in Genie.UTILS.pairsByKeys(family) do
                        if tonumber(id) and db.customFamilies[index][id] and not db.customFamilies[index][tonumber(id)] then
                            db.customFamilies[index][id] = nil
                            db.customFamilies[index][tonumber(id)] = true
                        end
                    end			
                end
            end
        end
		
        if currentDBVersion < 3052 then
  			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if string.lower(classdef.criteria) == "id" then
                    db.classranking[classrank].criteria = 'ItemID'
				end
                if string.lower(classdef.criteria) == "tstid" then
                    db.classranking[classrank].name = L.TStID
                end
			end          
        end
        
		-- add new entries/ update changed ones
		for defaultClassrank, defaultClassdef in Genie.UTILS.pairsByKeys(defaultClassRanking) do
			local new = true
			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if defaultClassdef.criteria == classdef.criteria then
					if classdef.type ~= defaultClassdef.type then classdef.type = defaultClassdef.type end
					if classdef.max ~= defaultClassdef.max then classdef.max = defaultClassdef.max end
					new = false
					break
				end
			end
			if new then
				table.insert(db.classranking, defaultClassdef)
			end
		end
		
		db.version = newDBVersion
	end
end
--[[ MOVED TO: LDB+I.lua
function Genie:LoadDataBrokerPlugin()
	LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(L['Genie'], {
		type = 'launcher',
		text = L['Genie'],
		icon = Genie.ICONS.default,

		OnClick = function(_, button)
			if button == 'LeftButton' then
                if IsAltKeyDown() then
					if self.atGuildBank then
						self:DoGuildbankWorks()
					end
				elseif IsControlKeyDown() then
                    if self.atBank then
						self:DoBankWorks()
					end
				elseif IsShiftKeyDown() then
					self:DoBagWorks()
				else
					self:PreWorks()
				end
			elseif button == 'RightButton' then
                if IsAltKeyDown() then
                    self:Stop()
				elseif IsControlKeyDown() then
                    self:DebugPrint('TODO:RankingGui')
                elseif IsShiftKeyDown() then
                    self:DebugPrint('TODO:FamilyGui')                    
                else
                    InterfaceOptionsFrame_OpenToCategory(L["Genie"])
                end
			end
		end,

		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine(L['Genie']..' '..self.VERSION)
			tooltip:AddLine(' ')
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'>|r '.. Genie.CMD.args.work.name)
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Shift..'>|r '.. Genie.CMD.args.bag.args.work.name)
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Strg..'>|r '.. Genie.CMD.args.bank.args.work.name)
            tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Alt..'>|r '.. Genie.CMD.args.guildbank.args.work.name)            
			tooltip:AddLine(' ')
			tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'>|r '.. L['Open the optionsmenu'])
            tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'+'.. L.Alt..'>|r '.. Genie.CMD.args.stop.name)                        
		end,
	})
end
--]]
function Genie:Print(...)
	local text = "|cff33ff99"..tostring( self ).."|r: "
	for i=1, select("#", ...) do
		text = text .. tostring( select( i, ...) ) .." "
	end
	text = text:trim()
	if not printMemory[text] or (time()-tonumber(printMemory[text])) > 5 then
		printMemory[text] = time()
		DEFAULT_CHAT_FRAME:AddMessage( text )
	end
end
function Genie:SilentPrint(...)
	if not db.mode.silent_text then
        if debug then self:Print('_S', ...) 
        else self:Print(...)
        end
	end
end
function Genie:DebugPrint(...)
	if debug then
		self:Print('_D', ...)
	end
end
function Genie:PrintToChat(msg, chat)
	if (msg ~= nil) then
		local id = 0
        id = GetChannelName(tostring(chat) )

        if (id > 0) then
            SendChatMessage(Genie.CONSTANT.CHAT_PREFIX..tostring(msg), "CHANNEL", nil, id);
        elseif Genie.CONSTANT.CHAT_TYPES[chat] then
            SendChatMessage(Genie.CONSTANT.CHAT_PREFIX..tostring(msg), chat);        
        else
  			DEFAULT_CHAT_FRAME:AddMessage(Genie.CONSTANT.CHAT_PREFIX_COLORED..tostring(msg));
  		end
  	end
end
function Genie:SilentPrintToChat(msg, chat)
	--print only if silent mode is disabled
    if db.mode.silent_text ~= true then
		self:PrintToChat(msg, chat)
	end
end
function Genie:AtBank()
	return self.atBank
end
function Genie:AtGuildBank()
	return self.atGuildBank
end
function Genie:Stack(container)
	if container == nil then container = Genie.theWorks.container end

	local itemgroup = {}
	for _, bag in Genie.UTILS.pairsByKeys(container.bags, Genie.db.profile.mode['reversebags']) do
		for i, item in Genie.UTILS.pairsByKeys(bag:GetItems(), Genie.db.profile.mode['reverseslots']) do
			if item:GetIgnore() == false then
				if itemgroup[item:GetId()] == nil then itemgroup[item:GetId()] = {} end
				if item.Count < item.StackCount then table.insert(itemgroup[item:GetId()], item) end
			end
		end
	end

	for i, items in pairs(itemgroup) do
		if #items > 1 then
			local currentItem
			for _, item in Genie.UTILS.pairsByKeys(items) do
				if currentItem ~= nil and currentItem.Count < currentItem.StackCount then
					local newCount = currentItem.Count + item.Count
					if newCount < item.StackCount then
						-- continue with the merged stack
						currentItem.Count = 0
							container:Swap(currentItem, item, true, true)
						currentItem = item
						currentItem.Count = newCount
					elseif newCount == item.StackCount then
						-- get a new stack
						currentItem.Count = 0 --nothing remains
						item.Count = newCount
							container:Swap(currentItem, item, true, true)
						currentItem = item
					else
						item.Count = item.StackCount
						currentItem.Count = newCount-item.StackCount
							container:Swap(currentItem, item, true, true)
					end

				else
					currentItem = item
				end
			end
		end
	end

	Genie:TheWorks()
end
function Genie:Move(container)
	if container == nil then container = Genie.theWorks.container end
	-- initialize; create a list of items that could be put into special bags
	-- and are currently in a general purpose bag
	local sI = {}
	for _, bag in Genie.UTILS.pairsByKeys(container.familyToBag[0], Genie.db.profile.mode['reversebags']) do
		for i, item in Genie.UTILS.pairsByKeys(container.bags[bag]:GetItems(), (not Genie.db.profile.mode['reverseslots'])) do
			if item:GetFamily() ~= 0 and item:GetIgnore() == false then
				table.insert(sI, item)
			end
		end
	end

	for family, bags in Genie.UTILS.pairsByKeys(container.familyToBag, true) do
			local baggroup = {}
			local maxSlots = 0
			local delta = 0
			for _, bag in Genie.UTILS.pairsByKeys(bags, Genie.db.profile.mode['reversebags']) do
				if Genie.db.profile.mode['reverseslots'] == true then
				while maxSlots-delta < container.bags[bag]:GetSize() do
					maxSlots = maxSlots +1
					baggroup[maxSlots] = {}
					baggroup[maxSlots].Item = container.bags[bag]:GetItem(container.bags[bag]:GetSize() - (maxSlots - delta)+1)
					baggroup[maxSlots].Bag = container.bags[bag].bagSlot
					baggroup[maxSlots].Slot = (container.bags[bag]:GetSize() - (maxSlots - delta)) +1
					baggroup[maxSlots].ignore = false
					if baggroup[maxSlots].Item ~= nil then
						baggroup[maxSlots].ignore = baggroup[maxSlots].Item:GetIgnore()
					end
				end
				delta = delta + container.bags[bag]:GetSize()
				else
				while maxSlots-delta < container.bags[bag]:GetSize() do
					maxSlots = maxSlots +1
					baggroup[maxSlots] = {}
					baggroup[maxSlots].Bag = container.bags[bag].bagSlot
					baggroup[maxSlots].Slot = maxSlots - delta
					baggroup[maxSlots].Item = container.bags[bag]:GetItem(maxSlots - delta)
					baggroup[maxSlots].ignore = false
					if baggroup[maxSlots].Item ~= nil then
						baggroup[maxSlots].ignore = baggroup[maxSlots].Item:GetIgnore()
					end
				end
				delta = delta + container.bags[bag]:GetSize()
				end
			end

			-- move special items
			-- todo: integrate into the above for
			if family ~= 0 then
			local freeSlot = 1;
			while freeSlot <= maxSlots do
				--pick the first free slot
				while baggroup[freeSlot] ~= nil and baggroup[freeSlot].Item ~= nil do
					freeSlot = freeSlot +1
				end
				if freeSlot > maxSlots then break end
				local target = Genie.CLASS.Item:New('', 0, baggroup[freeSlot].Bag, baggroup[freeSlot].Slot)
				for i, item in pairs(sI) do
					if item:IsPartOfFamily(family) then
						container:Swap(target, item, false, true)
						baggroup[freeSlot].Item = item
						table.remove(sI, i)
						lastItem = item
						break
					end
				end
				freeSlot = freeSlot + 1
			end
			end

			--[[ compact ]]
			local freeSlot = 1;
			local filledSlot = maxSlots
			while freeSlot < filledSlot do
				--pick the first free slot
				while baggroup[freeSlot] ~= nil and baggroup[freeSlot].Item ~= nil do
					freeSlot = freeSlot +1
				end
				if freeSlot > filledSlot then break end
				local target = Genie.CLASS.Item:New('', 0, baggroup[freeSlot].Bag, baggroup[freeSlot].Slot)
				-- pick the last item
				while baggroup[filledSlot] ~= nil and (baggroup[filledSlot].Item == nil or baggroup[filledSlot].ignore == true) do
					filledSlot = filledSlot -1
				end
				--  put it into the free slot
				if	freeSlot < filledSlot then
						container:Swap(target, baggroup[filledSlot].Item, false, true)
						table.remove(baggroup, filledSlot)
						filledSlot = filledSlot -1
				end
				freeSlot = freeSlot + 1
			end
			--]]
	end

	Genie:TheWorks()
end
function Genie:Sort(container)
	local swapsNeeded = 0
	local timeNeeded = GetTime()
	local items = {}

	local function Swap(pos1, pos2)
		if items[pos1] ~= items[pos2] then
			swapsNeeded = swapsNeeded+1
			-- 'virtually' swap the items
			local tmp = items[pos1]
				items[pos1] = items[pos2]
				items[pos2] = tmp
			-- tell the container about
			container:Swap(items[pos1], items[pos2], false, false)
		end
	end

	-- QuickSort with 3 partitioning
	local function QuickSort3(l, r)
		if (l < r) then
		--initialize
			local i = l-1; local p = l
			local j = r; local q = r-1
			local pivot = r
				while (i <= j) do
					repeat i=i+1
						until items[i] >= items[pivot]
					repeat j=j-1
						until items[j] <= items[pivot] or j == l
					if (i >= j) then break end
					Swap(i,j)
					if items[i] == items[pivot] then Swap(p,i); p=p+1 end
					if items[j] == items[pivot] then Swap(j,q); q=q-1 end
				end
			Swap(pivot, i)

			local next_r = i-1
			local next_l = i+1

			local k = l
				while k < p do
					Swap(k,next_r);
					k=k+1; next_r=next_r-1
				end
			local k = r-1
				while k > q do
					Swap(next_l, k);
					k=k-1; next_l=next_l+1
				end
			QuickSort3(l, next_r)
			QuickSort3(next_l, r)
		end
	end
	-- InsertionSort
	local function InsertionSort()
		for i=2, #items do
			local k = i
			while k > 1 and items[k] < items[k-1] do
				Swap(k, k-1)
				k= k-1
			end
		end
	end
	-- SelectionSort
	local function SelectionSort()
		for i=1, #items do
			local minimal = i
				for j=i+1, #items do
					if items[j] < items[minimal] then
						minimal = j
					end
				end
				if i ~= min then Swap(i, min) end
		end
	end
	-- HeapSort
	local function HeapSort()
		local function Sink(i, n)
			while i <= floor(n/2) do
				local child = i*2 --leftChild
				if child+1 <= n then -- right child exists
					if items[child] < items[child+1] then
						child = child+1 --switch to the rightChild
					end
				end
				if items[i] < items[child] then
					Swap(i, child)
					i=child
				else
					break
				end
			end
		end
		local function GenerateMaxHeap()
			for i= floor(#items/2), 1, -1 do
				Sink(i, #items)
			end
		end

		GenerateMaxHeap()
		for i= floor(#items), 2, -1 do
			Swap(1, i)
			Sink(1,i-1)
		end
	end

	--[[
		the user can pick one; they all work,
		although selectionsort may work the best as it has the least swaps
	--]]
	if container == nil then container = Genie.theWorks.container end

	--[[ testing only
	items = {0,1,2,5,7,8,1,2,2,6,9}
		-- for i=1, 10 do items[i] = math.random(10) end
	--]]
	--[[ get all items ]]
	for family, bags in pairs(container.familyToBag) do
		for i, item in pairs(container:GetItems(bags)) do
			if item:GetIgnore() == false then
				if Genie.FLAG_RSS == true then
					 --refresh the sortstring because the user has changed the ranking since the last /ReloadUI
					Genie.SortStringCache[item:GetId()] = nil
                    item:GenerateSortString()
				end
				table.insert(items, item)
			end
		end
	--[[
		Sorting
		1. virtually sort the container
		2. while doing so, protocoll which swaps were made
	--]]
		if Genie.db.profile.sortalgo == 'sort_insert' then
			InsertionSort()
		elseif Genie.db.profile.sortalgo == 'sort_heap' then
			HeapSort()
		elseif Genie.db.profile.sortalgo == 'sort_select' then
			SelectionSort()
		else --default
			QuickSort3(1, #items)
		end

		items = {}
	end

	timeNeeded = GetTime() - timeNeeded
	Genie.FLAG_RSS = false

	-- 3. tell genie to really sort the container
	--Generate FastSwapGrid
	for i, item in pairs(container:GetItems()) do
		if container.SwapGrid[item.Bag] == nil then container.SwapGrid[item.Bag] = {} end
		container.SwapGrid[item.Bag][item.Slot] = item:GetTarget()
        if Genie.atGuildBank then
            container.SwapGrid[item.Bag][item.Slot][3] = GetTime() + (i % 2)*Genie.UTILS.CalcGBDelay()
        end
        item:SetPosition(item:GetTarget()[1], item:GetTarget()[2])
	end
	Genie:TheWorks()
end
function Genie:DoGBSwapAlternative(container)
	--seems to work; needs confirmation
	local changesThisRound = false
	for bag, contents in pairs(container.SwapGrid) do
		for slot, target in pairs(contents) do
			local tBag = container.SwapGrid[bag][slot][1]
			local tSlot = container.SwapGrid[bag][slot][2]
			if bag ~= tBag or slot ~= tSlot then
				if (Genie.FLAG_GBOOS%3) == 0 then
				ClearCursor()
				local bBag = container:GetBag(bag)
				local bTBag = container:GetBag(tBag)

				bBag:PickupItem(slot)
					if Genie.FLAG_GBILC then
						bTBag:PickupItem(tSlot)
							if not Genie.FLAG_GBILC then
								-- 'virtual swap'
								local tmp = container.SwapGrid[tBag][tSlot]
									container.SwapGrid[tBag][tSlot] = container.SwapGrid[bag][slot]
									container.SwapGrid[bag][slot] = tmp

							end
					end
				end
				changesThisRound = true
			end
		end
	end

	if not changesThisRound then return true end
	return false
end
function Genie:DoGBSwap(container)
    --todo: rewrite...
	--seems to work; needs confirmation
	local changesThisRound = false
	local limitSwaps = Genie.db.global.GB_SwapsPerCycle
	local delay = Genie.UTILS.CalcGBDelay()

	for bag, contents in pairs(container.SwapGrid) do
		for slot, target in pairs(contents) do
			local tBag = container.SwapGrid[bag][slot][1]
			local tSlot = container.SwapGrid[bag][slot][2]

			if bag ~= tBag or slot ~= tSlot then
				if (GetTime()- container.SwapGrid[bag][slot][3]) > delay and (GetTime()- container.SwapGrid[tBag][tSlot][3]) > delay then
					limitSwaps = limitSwaps-1
					local bBag = container:GetBag(bag)
					local bTBag = container:GetBag(tBag)

						-- now checked directly in PickupItem
						--local locked1 = select(3, bBag:GetContainerItemInfo(slot))
						--local locked2 = select(3, bTBag:GetContainerItemInfo(tSlot))

						if not locked1 and not locked2 then
						bBag:PickupItem(slot)

						if Genie.FLAG_GBILC then
							container.SwapGrid[bag][slot][3] = GetTime()+Genie.db.global.GB_SlotCooldown*(1+Genie.db.global.GB_SlotCooldown/2)
							bTBag:PickupItem(tSlot)
							if not Genie.FLAG_GBILC then
								container.SwapGrid[tBag][tSlot][3] = GetTime()+Genie.db.global.GB_SlotCooldown*(1+Genie.db.global.GB_SlotCooldown/2)
								-- 'virtual swap'
								local tmp = container.SwapGrid[tBag][tSlot]
									container.SwapGrid[tBag][tSlot] = container.SwapGrid[bag][slot]
									container.SwapGrid[bag][slot] = tmp
							end
						else
							--Genie.FLAG_GBILC = false
							ClearCursor()
						end
						else
							changesThisRound = true
						end


					if limitSwaps == 0 then return false end
				end
				changesThisRound = true
			end
		end
	end

	if not changesThisRound then return true end
	return false
end
function Genie:DoFastSwap(container)
	local changesThisRound = false
	local blockedThisRound = false
	for bag, contents in pairs(container.SwapGrid) do
		for slot, target in pairs(contents) do
            if Genie.FLAG_IC then 
                Genie:DebugPrint('DoFastSwap.Genie.FLAG_IC', Genie.FLAG_IC)
                ClearCursor()
                return false 
            elseif bag ~= container.SwapGrid[bag][slot][1] or slot ~= container.SwapGrid[bag][slot][2] then
				--targetBag, targetSlot
				local tBag = container.SwapGrid[bag][slot][1]
				local tSlot = container.SwapGrid[bag][slot][2]
				--[[see if either item slot is currently locked]]
				local locked1 = select(3, container:GetBag(bag):GetContainerItemInfo(slot))
				local locked2 = select(3, container:GetBag(tBag):GetContainerItemInfo(tSlot))
				if locked1 or locked2 then
					blockedThisRound = true
				else
					container:GetBag(bag):PickupItem(slot)
					if CursorHasItem() ~= nil then
						container:GetBag(tBag):PickupItem(tSlot)
						if CursorHasItem() == nil then
						-- 'virtual swap'
							local tmp = container.SwapGrid[tBag][tSlot]
							container.SwapGrid[tBag][tSlot] = container.SwapGrid[bag][slot]
							container.SwapGrid[bag][slot] = tmp
						end
					end
					changesThisRound = true
				end
			end
        end
	end

	if not changesThisRound and not blockedThisRound then
		ClearCursor()
		container.SwapGrid = {}
		return true
	end
	return false
end
function Genie:DoSwap(container)
	local function ChI(bag, slot)
		local hasItem
		if Genie.atGuildBank and Genie.FLAG_GBILC then
				hasItem= true
		else
			hasItem= CursorHasItem()
		end
		return hasItem
	end

	ClearCursor()
	if container == nil then container = Genie.theWorks.container end
	if container == nil or #container.SwapList == 0 then return true end

	--(for readability)
	local iBag, iSlot  = container.SwapList[1][1], container.SwapList[1][2]
	local tBag, tSlot = container.SwapList[1][3], container.SwapList[1][4]
	local trys = container.SwapList[1][5]

	-- see if slots are blocked
	local _,_,locked1 = container:GetBag(iBag):GetContainerItemInfo(iSlot)
	local _,_,locked2 = container:GetBag(tBag):GetContainerItemInfo(tSlot)

	if locked1 or locked2 then
		--blocked
		trys = trys +1
		container.SwapList[1][5] = trys
	else
		--swap
		container:GetBag(iBag):PickupItem(iSlot)
		if ChI(iBag, iSlot) then
			container:GetBag(tBag):PickupItem(tSlot)
			if ChI(iBag, iSlot) == nil then
				table.remove(container.SwapList, 1)
			end
		else
			-- the spot is empty, try the other way arround
			container:GetBag(tBag):PickupItem(tSlot)
			if ChI(tBag, tSlot) then
				container:GetBag(iBag):PickupItem(iSlot)
					if ChI(tBag, tSlotB) == nil then
						table.remove(container.SwapList, 1)
					end
			else
				-- there is something wrong with this entry, remove it
				table.remove(container.SwapList, 1)
			end
			--]]
			table.remove(container.SwapList, 1)
		end
	end

	return false
end
function Genie:DoUpdateContainer(container)
	if container == nil then container = Genie.theWorks.container end
	if container == nil then return end
    if Genie.FLAG_IC then 
        if Genie.db.profile.mode.silent_sound then Genie:EnableSFX(true) end    
        Genie:DebugPrint('DoUpdateContainer.Genie.FLAG_IC', Genie.FLAG_IC)
        return false 
    end    
	ClearCursor()

	if db.mode.silent_sound == true then self:EnableSFX(false) end
	if not Genie:DoSwap(container) then
		if Genie.atGuildBank and Genie.theWorks.useGBSwap then
			self:ScheduleTimer("DoUpdateContainer", Genie.UTILS.CalcGBDelay(), container)
		else
			self:ScheduleTimer("DoUpdateContainer", 0.2, container)
		end
	elseif Genie.theWorks.useGBSwap and not Genie:DoGBSwap(container) then
		self:ScheduleTimer("DoUpdateContainer", Genie.UTILS.CalcGBDelay(), container)
	elseif not Genie:DoFastSwap(container) then
		self:ScheduleTimer("DoUpdateContainer", 0.2, container)
	else
		if not Genie.FLAG_AutoStart then
			local timeNeeded = GetTime() - Genie.theWorks.startTime
			local txt = gsub(L["I've done what you requested in X seconds"], 'X', string.format('%.3f',timeNeeded))
			Genie:SilentPrint(txt)
		end
		self:SilentHalt()
	end
end

--[[  EVENTS  /////////////////////////////////////////////////////////////////////////////////////
]]--
function Genie:PLAYER_GUILD_UPDATE()
    if (IsInGuild()) then
        self.currentGuild = GetGuildInfo("player")
    else
        self.currentGuild = nil
    end
end
function Genie:GUILD_ROSTER_UPDATE()
    local hide = not IsGuildLeader(UnitName("player"))
	Genie.OPT.Guildbank.args.GB_LockGuildBank.disabled = hide
    if (IsInGuild()) then
        self.currentGuild = GetGuildInfo("player")
    else
        self.currentGuild = nil
    end
end
function Genie:GUILDBANK_ITEM_LOCK_CHANGED()
	Genie.FLAG_GBILC = not Genie.FLAG_GBILC
end
function Genie:UI_ERROR_MESSAGE()
	if arg1 == ERR_ITEM_NOT_FOUND and Genie.theWorks.container then
		UIErrorsFrame:Clear()
		Genie:Retry()
	end
end
function Genie:LOOT_CLOSED()
	self:Automatic('LOOT_CLOSED')
end
function Genie:MAIL_CLOSED()
	self:Automatic('MAIL_CLOSED')
end
function Genie:BAG_UPDATE()
	self:Automatic('BAG_UPDATE')
end
function Genie:BAG_CLOSED()
	self:Automatic('BAG_CLOSED')
end
function Genie:TRADE_CLOSED()
	self:Automatic('TRADE_CLOSED')
end
function Genie:MERCHANT_CLOSED()
	self:Automatic('MERCHANT_CLOSED')
end
function Genie:CRAFT_CLOSE()
	self:Automatic('CRAFT_CLOSE')
end
function Genie:BANKFRAME_OPENED()
	self.atBank = true
	self:Automatic('BANKFRAME_OPENED')
end
function Genie:BANKFRAME_CLOSED()
	self.atBank = false
	self:CancelAllTimers()
	if Genie.db.profile.mode.silent_sound then Genie:EnableSFX(true) end
	self:Automatic('BANKFRAME_CLOSED')
end
function Genie:ITEM_PUSH()
	self:Automatic('ITEM_PUSH')
end
function Genie:ITEM_LOCK_CHANGED(arg1, arg2)
	self:Automatic('ITEM_LOCK_CHANGED')
end
function Genie:PLAYERBANKBAGSLOTS_CHANGED()
	self:Automatic('PLAYERBANKBAGSLOTS_CHANGED')
end
function Genie:PLAYERBANKSLOTS_CHANGED()
end
function Genie:GUILDBANKFRAME_OPENED()
	self.atGuildBank = true
    for i=1, GetNumGuildBankTabs(), 1 do QueryGuildBankText(i) end
    if self.db.factionrealm[Genie.currentGuild] and self.db.factionrealm[Genie.currentGuild].useProfile and self.db.factionrealm[Genie.currentGuild].useProfile ~= self.db:GetCurrentProfile() then
        Genie:DebugPrint('switch_to', self.db.factionrealm[Genie.currentGuild].useProfile)
        self.db.factionrealm[Genie.currentGuild].switchProfile = self.db:GetCurrentProfile()
        self.db:SetProfile(self.db.factionrealm[Genie.currentGuild].useProfile)
    end
	self:Automatic('GUILDBANKFRAME_OPENED')
end
function Genie:GUILDBANKBAGSLOTS_CHANGED()
	if Genie.theWorks.container then
		Genie.FLAG_GBOOS = Genie.FLAG_GBOOS +1
		if Genie.FLAG_GBOOS == 3 then Genie.FLAG_GBOOS = 0 end
	end
end
function Genie:GUILDBANKFRAME_CLOSED()
	self.atGuildBank = false
	self:CancelAllTimers()
	if Genie.FLAG_GBLOCKED then Genie:GBLock(false) end
	if Genie.db.profile.mode.silent_sound then Genie:EnableSFX(true) end
    if self.db.factionrealm[Genie.currentGuild] and self.db.factionrealm[Genie.currentGuild].switchProfile then
        Genie:DebugPrint('switch_back', self.db.factionrealm[Genie.currentGuild].switchProfile)
        self.db:SetProfile(self.db.factionrealm[Genie.currentGuild].switchProfile)
        self.db.factionrealm[Genie.currentGuild].switchProfile = false
    end
	self:Automatic('GUILDBANKFRAME_CLOSED')
end
function Genie:GUILDBANK_UPDATE_TABS()
    Genie:DebugPrint('GUILDBANK_UPDATE_TABS()')
end
function Genie:GUILDBANK_TEXT_CHANGED(_, tab)
    Genie:DebugPrint('GUILDBANK_TEXT_CHANGED', tab)
    Genie.UTILS.SetGuildBankOption(tab)    
end
function Genie:GUILDBANK_UPDATE_TEXT(_, tab)
    Genie.UTILS.SetGuildBankOption(tab)
end
function Genie:PLAYER_ENTER_COMBAT()
	Genie:CombatEnter()
end
function Genie:PLAYER_LEAVE_COMBAT()
    Genie:CombatLeave()
end
function Genie:PLAYER_REGEN_DISABLED()
    Genie:CombatEnter()	
end
function Genie:PLAYER_REGEN_ENABLED()
    Genie:CombatLeave()
end
function Genie:PLAYER_DEAD()
    Genie:CombatLeave()
end
function Genie:ADDON_ACTION_FORBIDDEN(arg1, arg2)
    self:DebugPrint('ActionForbidden', arg1, arg2)
end


function Genie:EQUIPMENT_SETS_CHANGED()
    self:UpdateEquipmentSets()
end

function Genie:EQUIPMENT_SWAP_FINISHED(successful, changedSet)
    self:Automatic('EQUIPMENT_SWAP_FINISHED')
end

--[[  UI execute   ////////////////////////////////////////////////////////////////////////////////
--]]
--///////////////////////////////////////////////////////////////////////////////////
-- Combat handling
--///////////////////////////////////////////////////////////////////////////////////
function Genie:CombatEnter()
    Genie.FLAG_IC = true
    Genie.FLAG_OC = false
	self:SilentHalt()
end
function Genie:CombatLeave()
    Genie.FLAG_OC = true
    if db.mode.waitAfterCombat then
        self:ScheduleTimer("CombatLeaveNotify", tonumber(db.mode.waitAfterCombat))
    else
        self:CombatLeaveNotify()
    end
end
function Genie:CombatLeaveNotify()
    if Genie.FLAG_IC and Genie.FLAG_OC then
        Genie.FLAG_IC = false

        if Genie.Queue["_queue"] then
            ClearCursor()
            self:Automatic(Genie.Queue["_queue"])
        end
    end
end

--///////////////////////////////////////////////////////////////////////////////////
-- Routines
--///////////////////////////////////////////////////////////////////////////////////
function Genie:TheWorks()
	local function getNextTask(task)
		if not task then task = '' end
		return self.UTILS.findPattern(Genie.theWorks.todolist, '[^,]+', tonumber(string.find(Genie.theWorks.todolist, task)+strlen(task)))
	end
	if Genie.theWorks.todolist then
		if Genie.db.profile.mode.silent_sound then Genie:EnableSFX(false) end

		Genie.theWorks.currentTask = getNextTask(Genie.theWorks.currentTask)
		if strlen(Genie.theWorks.currentTask) > 0 then
			Genie[Genie.theWorks.currentTask]()
		else
			--all tasks completed, now stack/move and sort for real
			Genie.FLAG_ERR = false
			if Genie.theWorks.container and #Genie.theWorks.container.SwapList == 0 then
				--the swaplist is empty
				local todo = false
				for b in pairs(Genie.theWorks.container.SwapGrid) do
					for s in pairs(Genie.theWorks.container.SwapGrid[b]) do
						if b ~= Genie.theWorks.container.SwapGrid[b][s][1] or s ~= Genie.theWorks.container.SwapGrid[b][s][2] then
							if Genie.theWorks.container:GetBag(b):GetItem(s) ~= Genie.theWorks.container:GetBag(Genie.theWorks.container.SwapGrid[b][s][1]):GetItem(Genie.theWorks.container.SwapGrid[b][s][2]) then
								todo = true
								break
							end
						end
					end
				end

				if not todo then
					if not Genie.FLAG_AutoStart then
						Genie:SilentPrint(L["Master, there's nothing (more) to do"])
					end
					self:SilentHalt()
					return true
				else
					self:DoUpdateContainer()
				end
			else
				self:DoUpdateContainer()
			end
		end
	end
end
function Genie:PreWorks(info, value)
	Genie.theWorks.todolist = 'Stack,Move,Sort,'
	if not Genie.FLAG_AutoStart then
		self:SilentPrint(L['I will try to read your mind master'])
	end
	if self.atGuildBank then
		self:DoGuildbank()
	elseif self.atBank then
		self:DoBank()
	else
		self:DoBag()
	end
end
function Genie:EnableSFX(value)
	if value then SetCVar("Sound_EnableSFX", 1)
		else SetCVar("Sound_EnableSFX", 0)
	end
end
function Genie:SilentHalt()
	self:CancelAllTimers()
    if Genie.FLAG_OC then Genie:CombatLeaveNotify() end --just to be sure we didn't miss this because of cancelalltimers()   
    ClearCursor()
	Genie.FLAG_AutoStart = nil
	Genie.theWorks.todolist = nil
	Genie.theWorks.container = nil
	if Genie.db.profile.mode.silent_sound then Genie:EnableSFX(true) end
	if Genie.FLAG_GBLOCKED then Genie:GBLock(false) end
end
function Genie:Stop()
	self:SilentHalt()
	self:Print(L["As you wish master"])
end
function Genie:Retry()
	if not Genie.FLAG_ERR then
		Genie.FLAG_ERR = true
		self:SilentHalt()
		local down, up, lag = GetNetStats()
		self:Print(L["Master i apologize, there where some errors. I had to stop"] .. ' ('.. Genie.UTILS.CalcGBDelay().. ', '.. Genie.db.global.GB_SwapsPerCycle ..')')
	end
end
function Genie:Automatic(event)
    if Genie.Queue[event] then self:CancelTimer(Genie.Queue[event],true) end
    Genie.Queue[event] = self:ScheduleTimer("QueueExecute",  Genie.CONSTANT.AUTOMATIC_DELAY, event)
end
function Genie:QueueExecute(event)
    if not Genie.FLAG_IC then
        Genie:AutomaticExecute(event)
    else
        -- retry
        Genie.Queue["_queue"] = event
    end
end

function Genie:AutomaticExecute(event)
	if db.mode.automatic == true then
		--[[if event == 'ITEM_PUSH' or event == 'ITEM_LOCK_CHANGED' then
		--	Genie.updateNeeded = true
		--elseif not Genie.FLAG_IC then ]]
            if Genie.Queue["_queue"] == event then Genie.Queue["_queue"] = nil end
            if db.events[event] ~= '' then
            --if db.events[event] ~= '' and Genie.updateNeeded == true then --ONLY IF SOMETHING HAS CHANGED
				-- build the todolist
				Genie.FLAG_AutoStart = true
				Genie.theWorks.todolist = ''
				if string.find(string.lower(db.events[event]), 'stack') then Genie.theWorks.todolist = 'Stack,' end
				if string.find(string.lower(db.events[event]), 'move') then Genie.theWorks.todolist = Genie.theWorks.todolist .. 'Move,' end
				if string.find(string.lower(db.events[event]), 'sort') then Genie.theWorks.todolist = Genie.theWorks.todolist .. 'Sort,' end
				-- do the works
				self:PreWorks()
				Genie.updateNeeded = false
            end
        --[[
        else 
            Genie.Queue["_queue"] = event
		end
        --]]
	end
end
function Genie:Do()
    if not Genie.FLAG_IC or not Genie.FLAG_AutoStart then
        if Genie.theWorks.container and #Genie.theWorks.container.bags > 0 then
            Genie.theWorks.startTime = GetTime()+1
            self:ScheduleTimer("TheWorks", 1)
        else
            self:Print(L["Master, i can't work with an empty container"])
            self:SilentHalt()
        end
    elseif not Genie.FLAG_OC then
        self:SilentPrintToChat(L["Oh, you're in combat"])
        self:SilentHalt()
    else
        self:DebugPrint(L['You told me to wait'])
    end
end
function Genie:DoBag()
    local tW = Genie.theWorks
	tW.useGBSwap = false
	tW.container = Genie.CLASS.Container:New('S')
    tW.container:Fill()
    self:Do()
end
function Genie:DoBagWorks(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,Move,Sort,'
	self:DoBag()
end
function Genie:DoBagMove(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Move,'
	self:DoBag()
end
function Genie:DoBagStack(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,'
	self:DoBag()
end
function Genie:DoBagSort(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Sort,'
	self:DoBag()
end
function Genie:DoBank()
    local tW = Genie.theWorks
	tW.useGBSwap = false
	tW.container = Genie.CLASS.Container:New('B')
    tW.container:Fill()
	self:Do()
end
function Genie:DoBankWorks(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,Move,Sort,'
	self:DoBank()
end
function Genie:DoBankMove(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Move,'
	self:DoBank()
end
function Genie:DoBankStack(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,'
	self:DoBank()
end
function Genie:DoBankSort(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Sort,'
	self:DoBank()
end
function Genie:DoGuildbank()
	if Genie.atGuildBank then
        -- should i move on? yes if:
        -- a) this char is the guildleader 
        -- b) @GBA is set to allow him AND @GBT is set for the current tab
		if IsGuildLeader(UnitName("player")) 
            or (Genie.UTILS.GetGuildBankOption('gba', UnitName("player")) and Genie.UTILS.GetGuildBankOption('gbt', GetCurrentGuildBankTab())) then
			
            Genie.FLAG_GBOOS = 0
			local tW = Genie.theWorks
			tW.useGBSwap = true
	        tW.container = Genie.CLASS.Container:New('_G' .. GetCurrentGuildBankTab() .. 'T')
			tW.container:Fill()
			
			if Genie.db.global.GB_LockGuildBank and self.atGuildBank then
				Genie:GBLock()
				self:ScheduleTimer("Do", 3)
			else
				self:Do()
			end
		else
			self:Print(L["Master, that's one thing i'm not allowed to do"])
		end
	end
end
function Genie:DoGuildbankWorks(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,Move,Sort,'
	self:DoGuildbank()
end
function Genie:DoGuildbankStack(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Stack,'
	self:DoGuildbank()
end
function Genie:DoGuildbankMove(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Move,'
	self:DoGuildbank()
end
function Genie:DoGuildbankSort(info, value)
	self:SilentPrint(L['As you wish master'])
	Genie.theWorks.todolist = 'Sort,'
	self:DoGuildbank()
end

--///////////////////////////////////////////////////////////////////////////////////
-- UI/Cmd classranking wrapper
--///////////////////////////////////////////////////////////////////////////////////
function Genie:GetClassRanking(info, value)
	local rank = value:gsub('[^0-9]+', '') -- use all numbers present
	return db.classranking[rank] or 0
end
function Genie:ClassRankingShow()
	local txt = L['Show current X']:gsub('X', L['Classranking'])
	self:Print(txt)
		for rank, class in Genie.UTILS.pairsByKeys(db.classranking) do
			local status = ''
			if not class.enabled then status = status .. '|cFF999933' .. L['Disabled:short'] .. '|r' end
			if class.invert  then status = status .. '|cFFFF9933' .. L['Inverted:short'] .. '|r' end
			self:Print(string.format("%.3d", tostring(rank)),'|cFFFFFF00', tostring(class.name),  status)
		end
end

function Genie:ClassRankingDate()
	Genie.FLAG_RSS = true
    db.date = time()
end
function Genie:ClassRankingEnable(info, value)
	local rank = gsub(value, '[^0-9]+', '') -- use all numbers present
	value = string.lower(value)
	if db.classranking[tonumber(rank)] ~= nil and rank == value then
		db.classranking[tonumber(rank)].enabled = true
		--[[
		if Genie.CLASS.Family:Exists(db.classranking[tonumber(rank)].criteria) then
			local f = Genie.CLASS.Family:New(db.classranking[tonumber(rank)].criteria)
			f:ToggleProperty('enabled', true)
		end
		--]]
		self:SilentPrint(db.classranking[tonumber(rank)].name, string.lower(L['Enabled']))
        self:ClassRankingDate()
    else
		for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
			if string.lower(classdef.name) == value or string.lower(classdef.criteria) == value then
				classdef.enabled = true
				self:SilentPrint(classdef.name, string.lower(L['Enabled']))
                self:ClassRankingDate()
				break
			end
		end
	end
end
function Genie:ClassRankingDisable(info, value)
	local rank = gsub(value, '[^0-9]+', '') -- use all numbers present
	value = string.lower(value)
	if db.classranking[tonumber(rank)] ~= nil and rank == value then
		db.classranking[tonumber(rank)].enabled = false
		self:SilentPrint(db.classranking[tonumber(rank)].name, string.lower(L['Disabled']))
        self:ClassRankingDate()
    else
		for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
			if string.lower(classdef.name) == value or string.lower(classdef.criteria) == value then
				classdef.enabled = false
				self:SilentPrint(classdef.name, string.lower(L['Disabled']))
                self:ClassRankingDate()                
				break
			end
		end
	end
end
function Genie:ClassRankingUpdate(info, value)
	if strlen(tostring(value)) > 0 then
		local params = { strsplit(" ", string.lower(value))}
		if #params < 2 then return false end
		-- param 1 ..N-1= class; param N = rank

		local class = params[1]
		for i=2, #params-1 do
			class = class .. ' ' .. params[i]
		end
		local rank = tonumber(params[#params])
		local updateClass, oldRank
			for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
				if string.lower(classdef.name) == class or tonumber(classrank) == tonumber(class) then
					updateClass = classdef
					oldRank = classrank
					break
				end
			end
			if updateClass and rank ~= oldRank then
				-- the class was found, now update
				if rank > 0 and rank <= #db.classranking then
                    local value = db.classranking[oldRank]
                    table.remove(db.classranking, oldRank)
                    table.insert(db.classranking, rank, value)

					local txt = gsub(L['X has been updated'], 'X', updateClass.name)
						self:SilentPrint(txt)
                        self:ClassRankingDate()
				end
			end
	end
end
function Genie:ClassRankingReset()
	Genie:Print(L['As you wish master'])
	for rank, class in Genie.UTILS.pairsByKeys(db.classranking) do
		class.enabled = false
	end
    self:ClassRankingDate()    
end
function Genie:ClassRankingInvert(info, value)
	local class, invert
	local rank = gsub(value, '[^0-9]+', '') -- use all numbers present
	value = string.lower(value)

	if db.classranking[tonumber(rank)] ~= nil and rank == value then
		db.classranking[tonumber(rank)].invert = not db.classranking[tonumber(rank)].invert
		invert = db.classranking[tonumber(rank)].invert
		class = db.classranking[tonumber(rank)].name
        self:ClassRankingDate()
	else
		for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
			if string.lower(classdef.name) == value or string.lower(classdef.criteria) == value then
				classdef.invert = not classdef.invert
				invert = classdef.invert
				class = classdef.name
				break
			end
		end
	end
	if class then
		if invert then
			self:SilentPrint(class, string.lower(L['Reverse'])..':', L['Enabled'])
		else
			self:SilentPrint(class, string.lower(L['Reverse'])..':', L['Disabled'])
		end
        self:ClassRankingDate()
	end
end




function Genie:ClassRankingCombine(info, value)
    --[[
        expected input: something like (3|4:>value)&!5
        expected output: something like (Quest Item_bool|Count_number:>value)&!Soulbound_bool
    --]]
    value = tostring(value)
    if strlen(strtrim(value)) > 0 then
        local class = {}
        class.type = 'combined'
        class.name = value
        class.criteria = value
        
        -- check if every enterd rank exists
        for rank in string.gmatch(value:gsub('%:[^0-9:]?[^0-9:]?%w+', ''), "%d+") do
            local cDef = db.classranking[tonumber(rank)]
            if not cDef then
                self:DebugPrint('fail')
                return nil
            else--if db.classranking[tonumber(rank)].type == 'combined' then
            	--//////////////////////////////
            	if cDef.type ~= 'combined' then
					class.criteria = Genie.UTILS.substituteNumber(class.criteria, rank, cDef.criteria ..'_'.. cDef.type)        	
            	else
					class.criteria = Genie.UTILS.substituteNumber(class.criteria, rank, cDef.criteria)        	
            	end
				class.name = Genie.UTILS.substituteNumber(class.name, rank, cDef.name)
            	--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\     
        	end
        end

        class.criteria = '('.. class.criteria ..')'
        class.enabled = true
        
        table.insert(db.classranking, 1, class)

        self:SilentPrint(class.name, string.lower(L['Created']))
        self:DebugPrint(class.criteria)
    end
end

function Genie:ClassRankingDelete(info, value)
	local rank = gsub(value, '[^0-9]+', '') -- use all numbers present
	value = string.lower(value)
	if db.classranking[tonumber(rank)] ~= nil and rank == value then
        if db.classranking[tonumber(rank)].type == 'combined' then
            self:SilentPrint(db.classranking[tonumber(rank)].name, string.lower(L['Deleted']))
            table.remove(db.classranking, tonumber(rank))
        end
    else
		for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
			if string.lower(classdef.name) == value or string.lower(classdef.criteria) == value then
                if classdef.type == 'combined' then
                    self:SilentPrint(classdef.name, string.lower(L['Deleted']))
                    table.remove(db.classranking, classrank)
                end
				break
			end
		end
	end
	Genie.FLAG_RSS = true
end

function Genie:ClassRankingDetails(info, value)
	--detail
    --output: type, max, allowed operators
    local rank = gsub(value, '[^0-9]+', '') -- use all numbers present
    local output = ''
	value = string.lower(value)
    if db.classranking[tonumber(rank)] ~= nil and rank == value then
        local classdef = db.classranking[tonumber(rank)]
        output = classdef.name .. ': ' .. classdef.type:upper()
        if classdef.max then
            output = output .. ', ' .. classdef.max
        end
        if Genie.CONSTANT.OP[classdef.type] then
            output = output .. ', ' .. Genie.CONSTANT.OP[classdef.type]:gsub('|', ' ')
        end
    else
		for classrank, classdef in Genie.UTILS.pairsByKeys(db.classranking) do
			if string.lower(classdef.name) == value or string.lower(classdef.criteria) == value then
                output = classdef.name .. ': ' .. classdef.type:upper()
                if classdef.max then
                    output = output .. ', ' .. classdef.max
                end
                if Genie.CONSTANT.OP[classdef.type] then
                    output = output .. ', ' .. Genie.CONSTANT.OP[classdef.type]:gsub('|', ' ')
                end
				break
			end
		end
	end
    self:PrintToChat(output)
end
--///////////////////////////////////////////////////////////////////////////////////
-- UI/Cmd family wrapper
--///////////////////////////////////////////////////////////////////////////////////
function Genie:FamilyUpdate(info, value)
	--create a family, add or remove items
	if value == nil then return false end
    local f
	-- extract the needed informations from the input
	local params = Genie.UTILS.FamilyInput(value)
	if #params > 0 then
		--a name was specified
		local classTStID = Genie.UTILS.GetTStID(params[1], params[2])
		if classTStID then
			-- a Type, Subtype or (Type and Subtype) where provided
			local name = params[1]
			if params[2] then name = name .. '>' .. params[2] end
			f = Genie.CLASS.Family:New(name, classTStID)
				for i=3, #params do
					f:UpdateContent(Genie.CLASS.Item:New(params[i]))
				end
		else
			if params[1] == '' and #params == 2 then
				local item = Genie.CLASS.Item:New(params[2])
					if item~=nil and item:GetId() ~= 0 then
						f = Genie.CLASS.Family:New(item:GetName())
						f:UpdateContent(item)
					end
			else
				f = Genie.CLASS.Family:New(params[1])
					for i=2, #params do
						f:UpdateContent(Genie.CLASS.Item:New(params[i]))
					end
			end
        end
    end
    if f then 
        Genie.FLAG_RSS = true       
        return f 
    end
end
function Genie:FamilyIgnore(info, value)
	if value == nil then return false end
	local params = Genie.UTILS.FamilyInput(value)
	if Genie.CLASS.Family:Exists(params[1]) then
        local f = Genie.CLASS.Family:New(params[1])
        local txt = gsub(L["Ignore all elements of X"],'X', f.name)
        local typeName = (params[2] and gsub(params[2]:upper(), '%d', '')) or ''
        local enable = Genie.UTILS.tobool(params[3])
        if #params == 2 then enable = Genie.UTILS.tobool(params[2]) end
            for short, data in pairs(Genie.Container) do
                if strlen(typeName) == 0 or (short:upper() == typeName) then
                    f:SetIgnore(short, (enable or not f:GetIgnore(short)))
                    if not string.match(short, '^_') then
                    	if f:GetIgnore(short) then
                        	self:Print(txt, '['.. (data.NAME or short) ..']:', L['Enabled'])
                    	else
                        	self:Print(txt, '['.. (data.NAME or short) ..']:', L['Disabled'])
                    	end        
                    end
                    Genie.FLAG_RSS = true                    
                end
            end
    end
end

function Genie:FamilyDelete(info, value)
	if value == nil then return false end
	local params = Genie.UTILS.FamilyInput(value)
	if #params == 1 and Genie.CLASS.Family:Exists(params[1]) then
		local f = Genie.CLASS.Family:New(params[1])
		self:Print(f.name, string.lower(L['Deleted']))
		f:Delete()
        Genie.FLAG_RSS = true        
	end
end
function Genie:FamilyRename(info, value)
	if value == nil then return false end
	local params = Genie.UTILS.FamilyInput(value)
	if #params == 2 and Genie.CLASS.Family:Exists(params[1]) then
		local f = Genie.CLASS.Family:New(params[1])
		if f:Rename(params[2]) then
            Genie.FLAG_RSS = true
			local txt = L["X renamed to Y"]:gsub('X', '"'.. params[1] ..'"'):gsub('Y', '"'.. params[2] ..'"')
			self:Print(txt)
            return true
		end
	end
    return false
end
function Genie:FamilyShow(info, value)
	if value == nil then return false end
	-- extract the needed informations from the input
	local params = Genie.UTILS.FamilyInput(value)

	if #params == 0 then
		--show all
		Genie.CLASS.Family:ShowAll()
	elseif Genie.CLASS.Family:Exists(params[1]) then
		local f = Genie.CLASS.Family:New(params[1])
		f:PrettyPrint()
	end
end
--///////////////////////////////////////////////////////////////////////////////////
-- Misc
--///////////////////////////////////////////////////////////////////////////////////
function Genie:UpdateEquipmentSets()
    local removeSets = Genie.CLASS.Family.GetAllSets()
    local f, set
    for i=1, GetNumEquipmentSets() do
        set = GetEquipmentSetInfo(i);
        f = Genie.CLASS.Family:New(set) -- load the set
        if f then
            f:SetEquipmentSet(GetEquipmentSetItemIDs(set))
            f:ToggleProperty('set', set)
            removeSets[f:GetName()] = nil
        end
    end

    for name, count in pairs(removeSets) do
        self:FamilyDelete(nil, name)
    end
end

function Genie:Ignore(info, value)
	if strlen(value) > 0 then
		local ignoreFamily = Genie.CLASS.Family:New(string.lower(L['Ignore']))
		Genie:FamilyUpdate(nil, string.lower(L['Ignore'])..'!'..value)
		ignoreFamily:SetIgnore(nil, {})
	end
end
function Genie:Inspect(info, value)
	local function searchItem(search)
		search = select(2, GetItemInfo(search))
		if search == nil then return nil end
		if self.atGuildBank then
			--also search the current guilbanktab
			for slot = 1, 98 do
				local item = GetGuildBankItemLink(GetCurrentGuildBankTab(), slot)
				if item == search then
					return Genie.CLASS.Item:New(value, select(2, GetGuildBankItemInfo(GetCurrentGuildBankTab(), slot)), GetCurrentGuildBankTab(), slot)
				end
			end
		end
		if self.atBank then
			--also search the bank
			for _, bagslot in pairs(Genie.UTILS.GetAvailableBags(Genie.CONSTANT.BANK)) do
				for slot = 1,GetContainerNumSlots(bagslot) do
					local item = GetContainerItemLink(bagslot,slot)
					if item == search then
						return Genie.CLASS.Item:New(value, select(2, GetContainerItemInfo(bagslot, slot)), bagslot, slot)
					end
				end
			end
		end
		for _, bagslot in pairs(Genie.UTILS.GetAvailableBags(Genie.CONSTANT.BAGS)) do
			for slot = 1,GetContainerNumSlots(bagslot) do
				local item = GetContainerItemLink(bagslot,slot)
				if item == search then
					return Genie.CLASS.Item:New(value, select(2, GetContainerItemInfo(bagslot, slot)), bagslot, slot)
				end
			end
		end
	end

    local item
    if type(value) == "table" then
        item = value
    elseif strlen(value) > 0 then
        item = searchItem(tostring(value))        
    end
    if item ~= nil then
        Genie:Print('--------------------------------------')
		for name,desc  in Genie.UTILS.pairsByKeys(item) do
			if type(desc) == "table" then
				local tmp = ''
				for key, val in pairs(desc) do
					tmp = tmp .. tostring(key) ..'='.. tostring(val) .. ', '
				end
				desc = tmp:gsub(',+$', '')
			end

			Genie:Print(name,'=',tostring(desc))
		end
		Genie:Print('--------------------------------------')
	end
end

--[[  NEWFEATURES  ////////////////////////////////////////////////////////////////////////////////
]]--


--/////////////////////////////////////////////////////////
function Genie:GBLock(lock)
	local currentTab = GetCurrentGuildBankTab()
	local function lock()
		local numRanks = GuildControlGetNumRanks()
		for rank=2, GuildControlGetNumRanks() do --do not touch the guildmaster (rank == 1)
			GuildControlSetRank(rank)
			local canView = GetGuildBankTabPermissions(currentTab)
			if canView then
				if not Genie.db.global['GB_PermissionsSave'][currentTab] then Genie.db.global['GB_PermissionsSave'][currentTab] = {} end
				if not Genie.db.global['GB_PermissionsSave'][currentTab][rank] then Genie.db.global['GB_PermissionsSave'][currentTab][rank] = {} end
				SetGuildBankTabPermissions(currentTab, 1, false)
				Genie.db.global['GB_PermissionsSave'][currentTab][rank][1] = true
				Genie.db.global['GB_PermissionsSave'][currentTab][rank][2] = GetGuildBankWithdrawLimit()
				GuildControlSaveRank(GuildControlGetRankName(rank))
			end
		end
	end
	local function unlock()
		local numRanks = GuildControlGetNumRanks()
		for rank=2, GuildControlGetNumRanks() do --do not touch the guildmaster (rank == 1)
			GuildControlSetRank(rank)
			if Genie.db.global['GB_PermissionsSave'][currentTab] and Genie.db.global['GB_PermissionsSave'][currentTab][rank] then
				SetGuildBankTabPermissions(currentTab, 1, Genie.db.global['GB_PermissionsSave'][currentTab][rank][1])
				SetGuildBankWithdrawLimit(Genie.db.global['GB_PermissionsSave'][currentTab][rank][2])
				GuildControlSaveRank(GuildControlGetRankName(rank))
			end
		end
		Genie.db.global['GB_PermissionsSave'][currentTab] = nil
	end
	if IsGuildLeader(UnitName("player")) and Genie.db.global.GB_LockGuildBank and Genie.atGuildBank then
		if lock ~= false then
			if Genie.FLAG_GBLOCKED then
				Genie.FLAG_GBLOCKED = false
				unlock()
				--if not Genie.db.profile.mode.silent_text then
					local txt = L["Guildbank-Tab 'X' unlocked. You're welcome."]:gsub("X", tostring(select(1, GetGuildBankTabInfo(currentTab))))
					self:SilentPrintToChat(txt, 'GUILD')
				--end
			else
				if GuildControlGetNumRanks() > 0 then
					Genie.FLAG_GBLOCKED = true
					--if not Genie.db.profile.mode.silent_text then
					local txt = L["I'm locking Guildbank-Tab 'X'. Step back!"]:gsub("X", tostring(select(1, GetGuildBankTabInfo(currentTab))))
					self:SilentPrintToChat(txt, 'GUILD')
					--end
					lock()
				end
			end
		else
			unlock()
		end
	end
end

function Genie:LookForNewGuildProfile()
    if Genie.currentGuild and self.db.factionrealm[Genie.currentGuild].sync then
        self:SendCommMessage(Genie.CONSTANT.COM.SYNC, 'REQUEST', "GUILD")
    end
end
function Genie:RequestProfileSync()
    if Genie.currentGuild and self.db.profiles[Genie.db.factionrealm[Genie.currentGuild].useProfile] then
        self:SendCommMessage(Genie.CONSTANT.COM.DATA, Genie.CONSTANT.COM.SYNC, "WHISPER", Genie.db.factionrealm[Genie.currentGuild].syncWith)  
    end
end
function Genie:OnCommReceived(prefix, message, distribution, sender)
    -- process the incoming message
    if self.db.factionrealm[Genie.currentGuild].sync and sender ~= UnitName("player") then    
        guildProfile = self.db.profiles[Genie.db.factionrealm[Genie.currentGuild].useProfile]
        if (prefix == Genie.CONSTANT.COM.SYNC) and distribution == "GUILD" then
            --incoming sync request
            if guildProfile and guildProfile.date then
                self:SendCommMessage(Genie.CONSTANT.COM.TIME, self:Serialize(guildProfile.date), "GUILD")
            end
        end
        if (prefix == Genie.CONSTANT.COM.TIME) then
            --process
            local success, time = self:Deserialize(message)       
            local guildName, guildRankName, guildRankIndex = GetGuildInfo(sender)
            if success and guildProfile and guildProfile.date < time and guildName == Genie.currentGuild then
                guildProfile.date = time
                Genie.db.factionrealm[Genie.currentGuild].syncWith = sender
                self:ScheduleTimer("RequestProfileSync", 5)
            end
        end
        if (prefix == Genie.CONSTANT.COM.DATA) then       
            if message == Genie.CONSTANT.COM.SYNC then
                --send
                self:SendCommMessage(Genie.CONSTANT.COM.DATA, self:Serialize(self.db.profiles[Genie.db.factionrealm[Genie.currentGuild].useProfile]), "WHISPER", sender)
                Genie:DebugPrint('Profile synced with:', sender)            
            else 
                local success, profile = self:Deserialize(message)       
                if success and sender == Genie.db.factionrealm[Genie.currentGuild].syncWith then
                --recieve
                    local syncedProfile = {}
                    for rank, values in paris(profile) do
                        syncedProfile[rank] = values
                        if L[values.criteria] then syncedProfile[rank].name = L[values.criteria] end
                    end
                
                    self.db.profiles[Genie.db.factionrealm[Genie.currentGuild].useProfile] = syncedProfile
                    Genie.db.factionrealm[Genie.currentGuild].syncWith = false
                    Genie:DebugPrint('Profile recieved from:', sender)     
                end
            end
        end
    end
end



--[[////////////////////////////////////////////////////////////////
    finalized
--]]




function Genie:Develop(info, input)
	--do new stuff
	self:DebugPrint("Genie:Develop #################")
	self:DebugPrint("Genie:Develop #END#############")
end

--[[	CLASS DEFINITIONS	////////////////////////////////////////////////////////////////////////
		todo: decide > move to separate files
]]--
--[[  Bag  ////////////////////////////////////////////////////////////////////////////]]
function Genie.CLASS.Bag:New(bagID, group)
	local self = setmetatable({}, { __index = Genie.CLASS.Bag, __tostring = Genie.CLASS.Bag.ToString })
        self.BagID = bagID
        self.bagSlot, self.Group = Genie.UTILS.convertToWowBagID(bagID)
        self.size = 0
        if self.bagSlot then
            self.size = GetContainerNumSlots(self.bagSlot) -- size
        end
        if self.size == 0 then return end
        
		-- handle special cases : bank and keyring
		self.name = self:GetName()
		self.items = {} --initialize self.items
		self.Overwrite = false -- enable: write once
		self.FreeSlots = self.size
		self.MinimumGap = 0.05
		self:SetFamily()
		self:SetCustomFamilies()
	return self
end
function Genie.CLASS.Bag:ToString()
	local it = ''
	local f = ''
	for i, item in Genie.UTILS.pairsByKeys(self.items) do it = it .. ', ' .. i ..':'.. item:ToString() end
	return self.name .. it or ''
end
function Genie.CLASS.Bag:SetFamily()
	if self.bagSlot == KEYRING_CONTAINER then
		self.family = 256
	elseif self.bagSlot == BANK_CONTAINER or self.bagSlot == 0 then
		self.family = 0
	else
		self.family = GetItemFamily(self.name)
	end
end
function Genie.CLASS.Bag:SetCustomFamilies()
	self.families = Genie.CLASS.Family.GetAllContaining(self)
end
function Genie.CLASS.Bag:GetId()
    return self.BagID
end
function Genie.CLASS.Bag:SetFamilies(families)
	if families ~= nil and type(families) == "table" then
		self.Families = families
		return true
	end
	--reset the current setting
	self.Families = {}
	--every item can be placed into a general purpose bag
	local tmpFamily = self:GetFamily()
	--iterate through all default itemfamilies
	for i = getn(Genie.CONSTANT.FAMILY), 1, -1 do
		if (tmpFamily - Genie.CONSTANT.FAMILY[i] >= 0) then
			self.Families[Genie.CONSTANT.FAMILY[i]] = true
			tmpFamily = tmpFamily - Genie.CONSTANT.FAMILY[i]
		end
	end
	return true
end
function Genie.CLASS.Bag:GetFamilies()
	if self.Families == nil then self:SetFamilies() end
	return self.Families
end
function Genie.CLASS.Bag:GetFamily()
	if self.family == nil then self:SetFamily() end
	return self.family
end
function Genie.CLASS.Bag:GetCustomFamilies()
	if self.families == nil then self:SetCustomFamilies() end
	return self.families
end
function Genie.CLASS.Bag:GetGroup()
	return self.Group
end
function Genie.CLASS.Bag:GetName()
	--todo: splitup
	if self.name ~= nil then return self.name
	else
		if self.bagSlot == KEYRING_CONTAINER then self.name = L['Keyring']
			elseif self.bagSlot == BANK_CONTAINER then self.name = L['Bank']
			else self.name = GetBagName(self.bagSlot) or L['Unknown']
		end
		return self.name
	end
end
function Genie.CLASS.Bag:Fill(items, preserve)
	self.items = {}
	if items ~= nil and #items <= self.size then
		for _, item in Genie.UTILS.pairsByKeys(items) do
			self:Add(item, preserve)
		end
		return true
	elseif self:GetSize() > 0 then
		for position=1, self:GetSize() do
			local itemLink = GetContainerItemLink(self.bagSlot, position)
			--slot not empty and not ignored
			if itemLink ~= nil then
				local count = select(2, GetContainerItemInfo(self.bagSlot, position))
				self:Add(Genie.CLASS.Item:New(itemLink, count, self.bagSlot, position), true)
			end
		end
		return true
	end
	return false
end
function Genie.CLASS.Bag:GetSize()
	--todo: does not work currently
	if (self.Group == Genie.CONSTANT.BANK and Genie.atBank == false) or
	   (self.Group == Genie.CONSTANT.GUILDBANK and Genie.atGuildBank == false)
	then return 0
	elseif self.bagSlot == -2 then
		--[[
			the real size of the keybag can't be determined through wow-api functions,
			because the api function always has a return value of 32 (//3.1.0)
		--]]
		return GetContainerNumSlots(self.bagSlot)
	end
	return self.size
end
function Genie.CLASS.Bag:GetItems()
	return self.items
end
function Genie.CLASS.Bag:GetItem(slot)
	return self.items[slot]
end
function Genie.CLASS.Bag:Add(item, preserve, finalize)
	if item ~= nil and item:IsPlacableInto(self) then
        item:SetContainer(self.Group)
		if  preserve == true then
			--if self:GetOverwrite() or self.items[item.Slot] == nil then
			if self:GetOverwrite() or self.items[item:GetTarget()[2]] == nil then
				if self.items[item.Slot] == nil then
					self.FreeSlots = self.FreeSlots -1
				end
				if finalize == true then item:SetPosition(self.bagSlot, item:GetTarget()[2]) end
				self.items[item:GetTarget()[2]] = item
				return true
			end
			return false
		elseif self.FreeSlots > 0 then
			item:SetPosition(self.bagSlot, #self.items)
			table.insert(self.items, item)
			self.FreeSlots = self.FreeSlots -1
			return {true, item}
		end
	end
	return false
end
function Genie.CLASS.Bag:Del(item)
	if item ~= nil and item:GetTarget()[1] == self.bagSlot then
		--table.remove(self.items, item.Slot)
		self.items[item:GetTarget()[2]] = nil
		self.FreeSlots = self.FreeSlots+1

		return true
	end
	return false
end
function Genie.CLASS.Bag:SetOverwrite(over)
	self.Overwrite = over
end
function Genie.CLASS.Bag:GetOverwrite()
	return self.Overwrite
end
function Genie.CLASS.Bag:PickupItem(slot)
    if not Genie.FLAG_IC then
        PickupContainerItem(self.bagSlot, slot)
    elseif CursorHasItem()then
        ClearCursor()
    end
end
function Genie.CLASS.Bag:GetContainerItemInfo(slot)
	return GetContainerItemInfo(self.bagSlot, slot)
end
function Genie.CLASS.Bag:IsPlacableInto(item)
	return item:IsPlacableInto(self.family)
end
function Genie.CLASS.Bag:HasSpace(preserve, item)
	if preserve == true then
		if self.items[item.Slot] == nil or self.Overwrite == true then return true end
	else
		if self.FreeSlots > 0 then return true end
	end
	return false
end
function Genie.CLASS.Bag:GetNextFreeSlot(currentSlot)
	if self.FreeSlots > 0 then
		local i
		if Genie.db.profile.mode['reverseslot'] == true then
			if currentSlot == nil then i = self:GetSize() else i = currentSlot-1 end
				while self.items[i] ~= nil do
					i = i-1
				end
		else
			if currentSlot == nil then i = 1 else i = currentSlot+1 end
				while self.items[i] ~= nil do
					i = i+1
				end
		end

		if i > 0 and i <= self:GetSize() then
			return i
		end
	end
	return 0
end
function Genie.CLASS.Bag:GetLastItem()
	return self.items[#self.items]
end
function Genie.CLASS.Bag:GetFreeSlots()
	local free = {}
	if self.FreeSlots > 0 then
		for i=1, self.size, 1 do
			if self.items[i] == nil then
				table.insert(free, i)
			end
		end
	end
	return free
end
function Genie.CLASS.Bag:GetFilledSlots()
	local filled = {}
	for i, item in pairs(self.items) do
		table.insert(filled, item.Slot)
	end
	return filled
end

--[[  GuildBag  ///////////////////////////////////////////////////////////////////////]]
function Genie.CLASS.GuildBag:New(bagSlot, group)
	local self = setmetatable({}, { __index = Genie.CLASS.GuildBag, __tostring = Genie.CLASS.GuildBag.ToString })
	if Genie.atGuildBank == false then return nil end
 	self.bagSlot = bagSlot --tab
	self.Group = group
	self.size = size or MAX_GUILDBANK_SLOTS_PER_TAB -- fixed size
	self.name = GetGuildBankTabInfo(self.bagSlot)
	self.family = 0
	self.items = {}
	self.FreeSlots = self.size
	self.MinimumGap = 0.8
    return self
end
function Genie.CLASS.GuildBag:ToString()
	local it = ' items: '
	for i, item in Genie.UTILS.pairsByKeys(self.items) do it = it .. ', ' .. i ..':'.. item:ToString() end
	return self.name ..'('.. self.family ..')'.. it or ''
end
function Genie.CLASS.GuildBag:Fill(items, preserve)
	self.items = {}
	if items ~= nil and #items <= self.size then
		for _, item in Genie.UTILS.pairsByKeys(items) do
			self:Add(item, preserve)
		end
		return true
	elseif self:GetSize() > 0 then
		for position=1, self:GetSize() do
			local itemLink = GetGuildBankItemLink(self.bagSlot, self:TranslatePosition(position))
			--slot not empty and not ignored
			if itemLink ~= nil then
				local count = select(2, GetGuildBankItemInfo(self.bagSlot, self:TranslatePosition(position)))
				self:Add(Genie.CLASS.Item:New(itemLink, count, self.bagSlot, position), true)
			end
		end
		return true
	end
	return false
end
function Genie.CLASS.GuildBag:GetName()
	return self.name
end
function Genie.CLASS.GuildBag:PickupItem(slot, amount)
	if Genie.atGuildBank then
		local locked = select(3, self:GetContainerItemInfo(slot))
		if not locked then
			if amount == nil then
				PickupGuildBankItem(self.bagSlot, self:TranslatePosition(slot))
			else
				SplitGuildBankItem(self.bagSlot, self:TranslatePosition(slot), amount)
			end
		end
	end
end
function Genie.CLASS.GuildBag:GetContainerItemInfo(slot)
	return GetGuildBankItemInfo(self.bagSlot, self:TranslatePosition(slot))
end
function Genie.CLASS.GuildBag:IsPlacableInto(item)
	if item.Soulbound then return false end
	return item:IsPlacableInto(self.family)
end
function Genie.CLASS.GuildBag:TranslatePosition(pos)
	local function calcLeftToRight(pos)
		local totalRows = NUM_GUILDBANK_COLUMNS
		local totalCols = NUM_SLOTS_PER_GUILDBANK_GROUP

		local row = (math.floor((pos-1)/totalCols)+1)
		local col = pos % totalCols
		if col == 0 then col = totalCols end

		return (col-1)*totalRows+row
	end

	if not Genie.UTILS.GetGuildBankOption('gbh', self.bagSlot) then return pos 
        else return calcLeftToRight(pos)
    end
	
end

--[[  CONTAINER  ///////////////////////////////////////////////////////////////////////]]
function Genie.CLASS.Container:New(name)
    local self = setmetatable({}, { __index = self, __tostring = self.ToString })  
        if Genie.Container[name] and Genie.Container[name].NAME then
            self.name = Genie.Container[name].NAME
            self.Group = name
        else
            Genie:DebugPrint('ERROR', name)
            return
        end 
        self.bags = {}
        self.size = 0
        self.familyToBag = {}
        self.SwapList = {}
        self.SwapGrid = {}
        self.MinimumGap = 0.5
    return self
end

function Genie.CLASS.Container:NewBag(bagID, deprecated)
    if deprecated then
        Genie:DebugPrint('use bagID instead')
        return
    end
    local slot, group = Genie.UTILS.convertToWowBagID(bagID)
    local gC, parent = Genie.Container, Genie.UTILS.GroupGetParent(group)
    if gC[group] then
        if gC[group].guild or (gC[parent] and gC[parent].guild) then
            return Genie.CLASS.GuildBag:New(slot, group) 
        end
        return Genie.CLASS.Bag:New(slot, group)
    end
end

function Genie.CLASS.Container:ToString()
	return self.name
end
function Genie.CLASS.Container:Add(bag)
	if bag ~= nil then
		-- add the bag
		local nr = #self.bags+1
		self.bags[nr] = bag
		-- update containersize
		self.size = self.size + bag:GetSize()
		-- update list of bagfamilies
		if self.familyToBag[bag:GetFamily()] == nil then self.familyToBag[bag:GetFamily()] = {} end
		table.insert(self.familyToBag[bag:GetFamily()], #self.bags)
		--[[
		for family in pairs(bag:GetFamilies()) do
			if self.familyToBag[family] == nil then self.familyToBag[family] = {} end
			table.insert(self.familyToBag[family], #self.bags)
		end
		--]]
	end
	return false
end
function Genie.CLASS.Container:Del(bag)
	local removeIndex = 0
	for i, containerBag in pairs(self.bags) do
		if containerBag == bag then
			removeIndex = i
			break
		end
	end
	if removeIndex > 0 then
		self.size = self.size - self.bags[removeIndex]:GetSize()
		self.bags[removeIndex] = nil
		return true
	else
		return false
	end
end


function Genie.CLASS.Container:Fill()
    self:FillWith(self.Group)
end

function Genie.CLASS.Container:FillWith(container)
    local gC = Genie.Container 
    if gC[container] then     
        for nr, bagID in Genie.UTILS.pairsByKeys(Genie.UTILS.GroupGetBags(container)) do
            bag = self:NewBag(bagID)
            if bag then
                bag:Fill()
                self:Add(bag)
            end 
        end
    end
end
function Genie.CLASS.Container:DisplayBags()
	local txt = L['Current contents of X']:gsub('X', self.name)
	Genie:Print(txt)
	for i, bag in Genie.UTILS.pairsByKeys(self.bags) do
		Genie:Print(i..' >> '.. bag:ToString())
	end
end
function Genie.CLASS.Container:GetSize(baggroup)
	local size = 0
	if baggroup ~= nil then
		-- get the size of a specific baggroup
		for i, bag in pairs(baggroup) do
			size = size + self.bags[bag]:GetSize()
		end
	else
		--get the size of the whole container
		for i, bag in pairs(self.bags) do
			size = size + bag:GetSize()
		end
	end
	return size
end
function Genie.CLASS.Container:GetItems(baggroup)
	local selectedBags = {}
	if baggroup ~= nil then
		for i, bag in pairs(baggroup) do
			selectedBags[i] = self.bags[bag]
		end
	else
		selectedBags = self.bags
	end

	local items = {}; local index = 1
	for _, bag in Genie.UTILS.pairsByKeys(selectedBags, Genie.db.profile.mode['reversebags']) do
		for _, item in Genie.UTILS.pairsByKeys(bag:GetItems(), Genie.db.profile.mode['reverseslots']) do
			table.insert(items, index, item)
			index = index +1
		end
	end

	return items
end
function Genie.CLASS.Container:ConPos2BagPos(position)
	local currentBag = next(self.bags)
	while self.bags[currentBag] ~= nil and position > self.bags[currentBag]:GetSize() do
		position = position - self.bags[currentBag]:GetSize()
		currentBag = next(self.bags)
	end
	return currentBag, position
end
function Genie.CLASS.Container:GetItem(position, slot)
	local item
	if position == nil or position > self:GetSize() then return nil end
	if slot == nil then
		--in this case bagslot equals the slotnumber of the entire container
		position, slot = self:ConPos2BagPos(position)
		return self.bags[position]:GetItem(slot)
	end
	return self:GetBag(position):GetItem(slot)
end
function Genie.CLASS.Container:GetBag(bagslot)
	local foundBag
	for i, bag in pairs(self.bags) do
		if bag.bagSlot == bagslot then
			foundBag = bag
			break
		end
	end
	return foundBag
end
function Genie.CLASS.Container:PickupItem(bag, slot)
--[[
	if CursorHasItem() then
		-- Putdown
		-- do some fancy stuff here
		return self:GetBag(item.Bag):PickupItem(item)
	else
		return self:GetBag(item.Bag):PickupItem(item)
	end
--]]
	return self:GetBag(bag):PickupItem(slot)
end
function Genie.CLASS.Container:GetContainerItemInfo(item)
	if item ~= nil then
		return self:GetBag(item.Bag):GetContainerItemInfo(item.Slot)
	end
end
function Genie.CLASS.Container:Swap(item1, item2, checkPosition, finalize)
	local function AddToSwapList(item1, item2, finalize)
		-- prepare items for virtual swap
		local target = item1:GetTarget()
			item1:SetTarget(item2:GetTarget()[1], item2:GetTarget()[2])
			item2:SetTarget(target[1], target[2])

		if item1.Count > 0 then
			local newBag = self:GetBag(item1:GetTarget()[1])
			newBag:SetOverwrite(true)
			newBag:Add(item1, true, finalize)
			newBag:SetOverwrite(false)
		else
			self:GetBag(item1:GetTarget()[1]):Del(item1)
		end
		if item2.Count > 0 then
			local newBag = self:GetBag(item2:GetTarget()[1])
			newBag:SetOverwrite(true)
			newBag:Add(item2, true, finalize)
			newBag:SetOverwrite(false)
		else
			self:GetBag(item2:GetTarget()[1]):Del(item2)
		end

		-- add the change to the swaplist
		if finalize then
		table.insert(self.SwapList, {item1:GetTarget()[1], item1:GetTarget()[2], item2:GetTarget()[1], item2:GetTarget()[2], 0})
		end
	end

	if item1 and item2 then
		if item1 ~= item2 then
			AddToSwapList(item1, item2, finalize)
		elseif checkPosition == true and (item1.Bag ~= item2.Bag or item1.Slot ~= item2.Slot )then
			AddToSwapList(item1, item2, finalize)
		end
	end
end
function Genie.CLASS.Container:Compact()
	--todo: revisit; the function basically works, but is buggy

	local function ConPos2BagPos(position, bags)
		if bags == nil then bags = self.bags end
			local currentBag = next(bags)
			while self.bags[bags[currentBag]] ~= nil and position > self.bags[bags[currentBag]]:GetSize() do
				position = position - self.bags[bags[currentBag]]:GetSize()
				currentBag = next(bags, currentBag)
			end
		return currentBag , position
	end


	local function GetItem(position, bags)
		local bag, slot = ConPos2BagPos(position, bags)
		return self.bags[bag]:GetItem(slot)
	end
	--[[	iterate through all bags,
			try to move items to their special bag
	--]]
	local function GetEmptySlot(bags)
		for _, bag in Genie.UTILS.pairsByKeys(bags) do
			local empty = self.bags[bag]:GetFirstFreeSlot()
			if empty ~= nil then
				return self.bags[bag].bagSlot, empty
			end
		end
	end

	local function compactNeeded(i1, i2)
		if i1.Bag < i2.Bag
		or (i1.Bag == i2.Bag and i1.Slot < i2.Slot)
		then return true
		else return false
		end
	end

	for family, bags in Genie.UTILS.pairsByKeys(self.familyToBag) do
		--for each family = baggroup
		local  j = self:GetSize(bags)
		local item
		while j > 1 do
			-- find the last filled slot
			item = GetItem(j, bags)
			if item ~= nil then
				local bag, slot
				if (family ~= 0 and item:IsPartOf(family)) or (item:GetFamily() == family) then
					--the item belongs to this baggroup
					bag, slot = GetEmptySlot(bags)
				else
					--iterate through all suitableBags
					bag, slot = GetEmptySlot(self:GetSuitableBags(item))
				end

				local target = Genie.CLASS.Item:New('', 0, bag, slot)
				if compactNeeded(target, item) then
					self:Swap(target, item)
				end
			end
			j=j-1 -- goto the next baggroupslot
		end
	end

	Genie:DoSwap(self)

end
function Genie.CLASS.Container:GetSuitableBags(item)
	if item ~= nil and item:GetFamily() ~= nil then
		-- the item can be placed only into one type of bags
		-- and we have a such a (spacial) bag
		if self.familyToBag[item:GetFamily()] ~= nil then
			return self.familyToBag[item:GetFamily()]
		end
		-- maybe the item can be placed into more than one bag
		local suitableBags = {}
		for family, enabled in Genie.UTILS.pairsByKeys(item:GetFamilies(), function(a,b) return a > b end) do
			if self.familyToBag[family] ~= nil then
				for i, bag in pairs(self.familyToBag[family]) do
					if self:GetSize({bag}) > 0 then
						table.insert(suitableBags, bag)
					end
				end
			end
		end
		return suitableBags
	end
	return nil
end

--[[  ITEM  ////////////////////////////////////////////////////////////////////////////]]
function Genie.CLASS.Item:Create(slot, bagID, container)
    Genie:DebugPrint('Item:Create', slot, bagID, container)
    if slot then
        local container, link, count, bag = container
        if bagID then bag, container = Genie.UTILS.convertToWowBagID(bagID) end
        Genie:DebugPrint('slot, bagID, container', slot, bagID, container)
        if Genie.Container._C.GROUP[container] then
            link = GetContainerItemLink(bag, slot)
            count = select(2, GetContainerItemInfo(bag, slot))
        elseif Genie.Container._G.GROUP[container] then
            link = GetGuildBankItemLink(bag, slot)
            count = select(2, GetGuildBankItemInfo(bag, slot))
        elseif container == '_B' then
            link = GetInventoryItemLink("player", BankButtonIDToInvSlotID(slot))
            count = GetInventoryItemCount("player", BankButtonIDToInvSlotID(slot))           
        else --default
            link = GetInventoryItemLink("player", slot)
            count = GetInventoryItemCount("player", slot)
        end
        return self:New(link, count, bag, slot, container)
    end
end
function Genie.CLASS.Item:New(item, count, bag, slot, container)
    if not item then return end
	local self = setmetatable({},
		{	__index = self,
			__tostring = self.ToString,
			__eq = self.Eq,
			__lt = self.Lt,
			__le = self.Le
		})
		self.TStID = 'ACI0000'
		self.ItemID = 0
        self.Family = 0
		self.SortString = ''
		self.Ignore = false
        self.Count = 0

        self.Name, self.Link, self.Rarity, self.iLvl, self.MinLevel,
		self.Type, self.SubType, self.StackCount, self.EquipLoc, self.Texture, self.Price = GetItemInfo(item)

        self:SetCount(count)
        
        if self:SetPosition(bag, slot) and self.Bag then
            self:GetToolTipInfo()    
            local item, id, active = GetContainerItemQuestInfo(self.Bag, self.Slot)
            self:SetQuestItem(item or id or acitve)			
        end        
       
        if self.Link then
            self.ItemID = tonumber(select(3, string.find(self.Link, "Hitem%:(.-)%:.+")))
            self.SkillLvl = 0
			self:SetTStID() --todo: call self:SetFamilies within; has to be executed before self:SetFamilies()
			if (GetItemFamily(self.Link) <= 4096) then -- itemFamily
                self.Family = GetItemFamily(self.Link)
            end
			self:SetPrice(self.Price) --adjust the price as we always get that for a single item, not the whole stack
			self:SetFamilies() -- Item can be placed into those Families
            if container then
                self:SetContainer(container) -- self:SetIgnore() is automatically called when setting a new container
            else
       			self:SetIgnore()
            end            

			self:GenerateSortString()            
		end
	return self
end

function Genie.CLASS.Item:SetQuestItem(isQuestItem)
    self.QuestItem = isQuestItem or false
end
function Genie.CLASS.Item:SetCount(count)
	local newCount = tonumber(count)
	if newCount and newCount >= 0 then
		self.Count = newCount
		return true
	end
	return false
end

function Genie.CLASS.Item:SetTradeSkill(skill)
    local skill = skill:gsub('%D', '')
    if skill then 
        self.SkillLvl = tonumber(skill)
    end
end
function Genie.CLASS.Item:SetPrice(priceSingleItem)
	if priceSingleItem then
		self.Price = priceSingleItem * self.Count
	else
		local price = select(11, GetItemInfo(self.Link))
		self.Price = tonumber(price) * self.Count
	end
end
function Genie.CLASS.Item:GetToolTipInfo()
    local tradeSkillTip = '%(%d+%)'

        self.Soulbound = false
        self.QuestItem = false
        self.Unique = false
        self.boe = false
        self.bop = false
        self.bou = false
        self.boa = false    
    
	GenieScanningTooltip:ClearLines()
	if self.Bag == BANK_CONTAINER then
		GenieScanningTooltip:SetInventoryItem("player", BankButtonIDToInvSlotID(self.Slot, nil));
	elseif self.Bag == KEYRING_CONTAINER then
		GenieScanningTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(self.Slot));
	else
		GenieScanningTooltip:SetBagItem(self.Bag, self.Slot)		
	end
	for i=2, math.min(3, GenieScanningTooltip:NumLines()) do -- scan the first 3 lines (at least)
		local mytext = getglobal("GenieScanningTooltipTextLeft" .. i)
		local text = mytext:GetText()
		if text ~= nil then
            if string.find(text, tradeSkillTip) then self:SetTradeSkill(text) end
			if text == ITEM_UNIQUE then self.Unique = true end
			if text == ITEM_BIND_QUEST then self.QuestItem = true end
			if text == ITEM_SOULBOUND then	self.Soulbound = true
				-- those items will turn into soulbound ones
				elseif text == ITEM_BIND_ON_EQUIP then self.boe = true
				elseif text == ITEM_BIND_ON_PICKUP then self.bop = true
				elseif text == ITEM_BIND_ON_USE then self.bou = true
				-- accountbound items
				-- in order to distinguish them, boa remains set
				elseif text == ITEM_BIND_TO_ACCOUNT then self.boa = true
				elseif text == ITEM_ACCOUNTBOUND then
					self.boa = true
					self.Soulbound = true
			end
            
		end
	end
end
function Genie.CLASS.Item:ToString()
    local _,_,_, hex = GetItemQualityColor(self.Rarity or 1) --get the right color or default to 1 (== white)
        if hex then
             return hex .. self:GetName() .. '|r' .. ' ['.. self:GetId() ..']'
        else
             return self:GetName() .. '|r' .. ' ['.. self:GetId() ..']'
        end
end
function Genie.CLASS.Item:Eq(a)
	--todo: expand
	return self.SortString == a.SortString
	--return self.Count == a.Count
end
function Genie.CLASS.Item:Lt(a)
	if Genie.db.profile.invert == true then
		return self.SortString > a.SortString
	else
		return self.SortString < a.SortString
	end
end
function Genie.CLASS.Item:Le(a)
	return self:Lt(a) or self:Eq(a)
end
function Genie.CLASS.Item:GenerateSortString()
    if Genie.SortStringCache[self.ItemID] then self.SortString = Genie.SortStringCache[self.ItemID] else

	local sortstring = ''
	local translateBool = {}
		translateBool[true] = '1'
		translateBool[false] = '0'
	for ranking, criteria in Genie.UTILS.pairsByKeys(Genie.db.profile.classranking) do
			repeat
				if criteria['enabled'] == false then
					break
				end
				if criteria['type'] == 'string' and self[criteria['criteria']] then
				    local s = self[criteria['criteria']]
				    if criteria['invert'] == true then
				    	local tmp = ''
				    	for _, word in ipairs({ strsplit(' ', s) }) do
				    		tmp = word .. ' ' .. tmp
				    	end
				        s = tmp
				    end
					sortstring = sortstring .. Genie.UTILS.purgeText(s, true)
					break
				end
				if criteria['type'] == 'number' then
					local defAdjust = 0
					local defMax = 1
					if criteria['max'] then
						while defMax < criteria['max'] do
							defMax = defMax * 10
							defAdjust = defAdjust +1
						end
						if criteria['max'] > Genie.CONSTANT.NUMBER_MAX then
							--catch the overflow
							criteria['max'] = Genie.CONSTANT.NUMBER_MAX
						end					
					else
						criteria['max'] = 9
					end
					local value = 0
					if self[criteria['criteria']] then
						value = gsub(self[criteria['criteria']], '[^0-9]', '')
						value = tonumber(value)
					end
					if criteria['invert'] == true then
						sortstring = sortstring .. string.format('%.' .. defAdjust ..'d', tostring(tonumber(criteria['max']) - value))
					else
						sortstring = sortstring .. string.format('%.'.. defAdjust ..'d', tostring(value))
					end
					break
				end
				if criteria['type'] == 'bool' then
					local b = not self[criteria['criteria']]
					if criteria['invert'] == true then b = not b end
					sortstring = sortstring .. tostring(translateBool[b])
					break
				end
				if criteria['type'] == 'family' then
					local family = Genie.CLASS.Family:New(criteria['name'])
					local b = true
					if family then
						b = family:Contains(self)
					end
					if criteria['name'] ~= criteria['criteria'] then b = not b end
					if criteria['invert'] == true then b = not b end
					sortstring = sortstring .. tostring(translateBool[b])
					break
				end
                --/////////////////////////////////////////////////////////////////////////////////
                if criteria['type'] == 'combined' then
                    local b = not Genie.UTILS.tobool(self:Search(criteria['criteria']))
                    if criteria['invert'] == true then b = not b end
                    sortstring = sortstring .. tostring(translateBool[b])
                    break
                end
                --/////////////////////////////////////////////////////////////////////////////////]]
				break --just for safety, in case somethings wrong with the itemranking definition
			until true
		end
        Genie.SortStringCache[self.ItemID] = sortstring
        self.SortString = Genie.SortStringCache[self.ItemID]
    end
end
function Genie.CLASS.Item:GetFamily()
	return self.Family
end
function Genie.CLASS.Item:GetLink(item)
    return self.Link or ''
end
function Genie.CLASS.Item:GetId(item)
    if item then
        local id = select(3, string.find(tostring( select(2, GetItemInfo(item)) or ''), "Hitem%:(.-)%:.+"))
        if id then return tonumber(id) else return 0 end
    else
        return self.ItemID
    end
end
function Genie.CLASS.Item:SetSortString(sortstring)
	if sortstring ~= nil then self.sortstring = sortstring end
end
function Genie.CLASS.Item:SetFamilies(families)
	if families ~= nil and type(families) == "table" then
		self.Families = families
		return true
	end
	--reset the current setting
	self.Families = {}
	local tmpFamily = self:GetFamily()
	--every item can be placed into a general purpose bag
	-- bags can only be placed into general puropse bags, regardless of their family
	self.Families[0] = true
	if self.EquipLoc ~= 'INVTYPE_BAG' and self.EquipLoc ~= 'INVTYPE_QUIVER' and tmpFamily ~= 0 then
		--iterate through all default itemfamilies
		for i = getn(Genie.CONSTANT.FAMILY), 1, -1 do
			if (tmpFamily - Genie.CONSTANT.FAMILY[i] >= 0) then
				self.Families[Genie.CONSTANT.FAMILY[i]] = true
				tmpFamily = tmpFamily - Genie.CONSTANT.FAMILY[i]
			end
		end
	end
	--iterate through all custom itemfamilies
	local customFamilies = Genie.CLASS.Family.GetAllContaining(self)
	Genie.UTILS.MergeTable(self.Families, customFamilies, 2)
	return true
end
function Genie.CLASS.Item:GetFamilies()
	return self.Families or {}
end
function Genie.CLASS.Item:IsPlacableInto(bag)
	return self:IsPartOfFamily(bag:GetFamily())
end
function Genie.CLASS.Item:IsPartOfFamily(name)
	if type(name) == "table" then
		--expected: table[family] == true
		local partOf = false
		for family, _ in pairs(name) do
			partOf = self.Families[family] or self:IsPartOfCustomFamily(family)
			if partOf == true then break end
		end
		return partOf
	elseif self.Families then
		return self.Families[name] or self:IsPartOfCustomFamily(name)
	else
		return self:IsPartOfCustomFamily(name)
	end
end
function Genie.CLASS.Item:IsPartOfCustomFamily(name)
	if name ~= nil and Genie.CLASS.Family:Exists(name) == true then
		local family = Genie.CLASS.Family:New(name)
		return family:Contains(self)
	end
	return false
end
function Genie.CLASS.Item:SetPosition(bag, slot)
	if slot == nil then return false end
        self.Bag = bag
        self.Slot = slot
	return true
end
function Genie.CLASS.Item:GetName()
	if not self.Name then return '' end
	return self.Name
end
function Genie.CLASS.Item:GetIgnore()
	return self.Ignore
end
function Genie.CLASS.Item:SetIgnore()
	self.Ignore = false
	for name in pairs(self:GetFamilies()) do
		local family = Genie.CLASS.Family:New(name)
		if family ~= nil and family:GetIgnore(self.Container) then
            self.Ignore = true
			break
		end
	end
end
function Genie.CLASS.Item:SetContainer(container)
    self.Container = container
    self:SetIgnore()
end
function Genie.CLASS.Item:SetTarget(bag, slot)
	self.TBag = bag
	self.TSlot = slot
end
function Genie.CLASS.Item:GetTarget()
	if self.TBag ~= nil and self.TSlot ~= nil then
		return {self.TBag, self.TSlot}
	end
	return {self.Bag, self.Slot}
end
function Genie.CLASS.Item:GetTStID()
	return self.TStID
end
function Genie.CLASS.Item:SetTStID(id)
	if not id then
		self.TStID = Genie.UTILS.GetTStID(self.Type, self.SubType)
	else
		self.TStID = id
	end
end

function Genie.CLASS.Item:Search(find)
    -- always sync with Genie.CONSTANT.OP
    local handle = {}
        handle['string'] = function (value, invert, comp, op)
		    if invert then
				local tmp = ''
				  	for _, word in ipairs({ strsplit(' ', value) }) do
				   		tmp = word .. ' ' .. tmp
				   	end
                    value = tmp
			end
            value = Genie.UTILS.purgeText(value, false)
            comp = Genie.UTILS.purgeText(comp, false)
            --[[if not comp then
                return true
            else--]]if op == '==' and string.find(value, comp) then
                return true
            elseif op == '~=' and not string.find(value, '^'.. comp .. '$') then
                return true
            elseif op == '=' and string.find(value, '^'.. comp .. '$') then
                return true
            end      
            return false            
        end
        handle['bool'] = function (value, invert, comp, op)
            local b = false
            comp = Genie.UTILS.tobool(comp)
            if op == '~=' then
                b = (value ~= comp)
            else
                b = (value == comp)
            end                    
            if invert then b = not b end
            return b
        end
        handle['family'] = function (value, invert, comp, op)
            return false
        end
        handle['number'] = function (value, invert, comp, op)
            comp = Genie.UTILS.moneyStringToCopper(comp)
            if op == '>' then return (value > comp)
            elseif op == '>=' then return (value >= comp)
            elseif op == '<=' then return (value <= comp)
            elseif op == '<' then return (value < comp)            
            elseif op == '~=' then return (value ~= comp)                    
            else return (value == comp) end
        end
        
    local function getParams(paramString)
        local op, comp, invert
        local vPos, cPos, treatas = string.find(paramString, '_([^:_]+):?')
        local value = string.sub(paramString, 1, vPos-1)
        if cPos < strlen(paramString) then 
            op, comp = string.sub(paramString, cPos+1):match('([~=<>!]*)([^~=<>!]+)')
        end
        invert, value = value:match('(~?)([^~]+)')
        return tostring(treatas):lower(), value, (strlen(invert) > 0), comp, op
    end

    local function eval(compare)
        if compare == 'true' or compare == 'false' then
            --already evaluated
            return Genie.UTILS.tobool(compare)
        else
            --some work needs to be done
            --[[//////////////////////////////////////////////////////////////////////
                <negate><criteria>_<treatas>:<op><value>
                <negate> ... ~|''
                <criteria> ... Item.<attribute>
                <op> ... |>|>=|=|<=|<|==|~=
                <treatas> ... bool|number|string|?family
            --//////////////////////////////////////////////////////////////////////]]            
            local treatas, value, invert, comp, op = getParams(compare)
            if self[value] ~= nil then
                return handle[treatas](self[value], invert, comp, op)
            else
                return false
            end
        end
    end

	local function split(find)
		local f = find:match('[^()]+')
		if f then
			if f:match('\124') then
                -- \124 == |
                local p = {strsplit('\124', f)}
				return eval(p[1]) or eval(p[2])
			elseif f:match('\038') then
                -- \038 == &        
                local p = {strsplit('\038', f)}
				return eval(p[1]) and eval(p[2])
			else
                return eval(f)
            end
		end
		return false --failsave
	end

	local pattern = '%([^()]+%)'
	local match = string.match(find, pattern)	
	while match do
		find = find:gsub(pattern, tostring(split(match)))
		match = string.match(find, pattern)	
	end
	find = tostring(split(find))
    return find
end


--[[  FAMILY  //////////////////////////////////////////////////////////////////////////]]
function Genie.CLASS.Family:New(name, criteria)
	-- creates a new family or loads the Family called 'name'
	local self = setmetatable({}, { __index = self, __tostring = self.ToString })
	if name == '' then return nil end --don't allow empty names
	if tostring(tonumber(name)) == tostring(name) then
		return nil
	end --don't allow numbers as name
	self.name = string.lower(name)
    self.Set = Genie.db.profile.customFamilies[self.name].set
    self.itemDB = Genie.db.profile.customFamilies[self.name]
    self.TStID  = self:GetTStID()    
    if self:Exists() == false then
		-- that's a new family
        -- todo: don't change db.classranking directly, create/use genie-classranking-functions
		Genie.db.profile.customFamilies[self.name] = {}
		if self.name ~= string.lower(L['Ignore']) then
            local rank = #Genie.db.profile.classranking+1
			Genie.db.profile.classranking[rank] = {}
			if criteria then
				Genie.db.profile.classranking[rank]["criteria"] = criteria
			else
				Genie.db.profile.classranking[rank]["criteria"] = self.name
			end
			Genie.db.profile.classranking[rank]["type"] = 'family'
			Genie.db.profile.classranking[rank]["name"] = self.name
			Genie.db.profile.classranking[rank]["enabled"] = false
            Genie.db.profile.classranking[rank].invert = true
		end
	end
	return self
end
function Genie.CLASS.Family:ToString()
	local items = ''
	if Genie.db.profile.customFamilies[self.name] ~= nil then
		for id, enabled in pairs(Genie.db.profile.customFamilies[self.name]) do items = items .. id .. ', ' end
		return self.name .. ' '.. L['contains'] ..' '.. items
	end
	return L['X is empty']:gsub('X', self.name)
end
function Genie.CLASS.Family:GetEnabled()
	--currently all families are enabled
	return true
	--return Genie.db.profile.customFamilies[self.name].enabled
end
function Genie.CLASS.Family:ShowAll()
	local count = 1
	local txt = L["Current content of X"]:gsub('X', L["Custom family"])
	Genie:Print(txt)
		-- the default ignore-list always comes first
		local f = Genie.CLASS.Family:New(string.lower(L['Ignore']))
		if f:GetEnabled() then
			if f:GetIgnore() then
				Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name),  '('..string.lower(L['Ignore'])..')')
			else
				Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name))
			end
		else
			Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name),  '('..string.lower(L['Disabled'])..')')
		end

		for rank, values in Genie.UTILS.pairsByKeys(Genie.db.profile.classranking) do
			if values['type'] == "family" then
				count = count +1
				local f = Genie.CLASS.Family:New(values['name'])
					if f:GetEnabled() then
						if f:GetIgnore() then
							Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name),  '('..string.lower(L['Ignore'])..')')
						else
							Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name))
						end
					else
						Genie:Print(string.format("%.3d", tostring(count)) .. '|cFFFFFF00', tostring(f.name),  '('..string.lower(L['Disabled'])..')')
					end
			end
		end
end
function Genie.CLASS.Family:HasSpecificIgnore()
    if Genie.db.profile.customFamilies[self.name].ignore then
        return next(Genie.db.profile.customFamilies[self.name].ignore)
    end
    return false
end

function Genie.CLASS.Family:GetIgnore(container)
    --globally ignored
    if self.name == string.lower(L.Ignore) then return true end
    --ignored by family
    local cf = Genie.db.profile.customFamilies    
    local gC = Genie.Container
    if cf[self.name].ignore then
        if not cf[self.name].ignore.enabled then
            if container then return cf[self.name].ignore[container] end
            return true
        else
            for rank, class in pairs(Genie.db.profile.classranking) do
                if class.name == self.name then
                    if class.enabled then
                        if container then return cf[self.name].ignore[container] end
                        return true
                    else
                        return false
                    end
                end
            end
        end
    end
    return false
end

function Genie.CLASS.Family:SetIgnore(container, bool)
    local cf = Genie.db.profile.customFamilies
    local gC = Genie.Container
    if container and gC[container] then
        if not cf[self.name].ignore then cf[self.name].ignore = {} end
        --ignore the container
        cf[self.name].ignore[container] = bool or nil
        --ignore all subcontainers
        if gC[container].GROUP then
            for _, sub in pairs(gC[container].GROUP) do
                cf[self.name].ignore[sub] = bool or nil
            end
        end
    end
end

function Genie.CLASS.Family:GetName()
    return self.name
end
function Genie.CLASS.Family:ToggleProperty(property, enable)
	if property ~= nil and strlen(tostring(property)) > 0 then
        if enable ~= nil then
            Genie.db.profile.customFamilies[self.name][property] = enable
        else
            Genie.db.profile.customFamilies[self.name][property] = not Genie.db.profile.customFamilies[self.name][property]
        end
	end
end
function Genie.CLASS.Family:UpdateContent(item, append, silent)
    if type(item) == "table" and item:GetId() > 0 then
		if Genie.db.profile.customFamilies[self.name][item:GetId()] ~= nil then
			Genie.db.profile.customFamilies[self.name][item:GetId()] = nil
            if not silent then
                local txt = L['X removed from Y']:gsub('X', item:GetLink()):gsub('Y', '"'..self.name..'"')
                Genie:SilentPrint(txt)
            end
		else
            if append then
                Genie.db.profile.customFamilies[self.name][item:GetId()] = item:GetName() .. ':' .. append
            else
                Genie.db.profile.customFamilies[self.name][item:GetId()] = true
            end
            if not silent then
                local txt = L['X added to Y']:gsub('X', item:GetLink()):gsub('Y', '"'..self.name..'"')
                Genie:SilentPrint(txt)
            end
		end
		return true
	end
	return false
end
function Genie.CLASS.Family:Delete()
	--remove the class from the ranking
	for rank, values in pairs(Genie.db.profile.classranking) do
		if values['name'] == self.name and values['type'] == 'family' then
			table.remove( Genie.db.profile.classranking, rank)
            break
        end
	end
	--delete the class from the database
    Genie.db.profile.customFamilies[self.name] = nil
	self = nil
end
function Genie.CLASS.Family:Rename(newName)
    newName = Genie.UTILS.purgeText(newName)
    if strlen(newName) > 0 and not self:Exists(newName) then    
	-- update the name in the classranking
	local renamed = false
	if self.name == string.lower(L['Ignore']) then
		Genie.CLASS.Family:New(newName)
		renamed = true
	else
		for rank, values in pairs(Genie.db.profile.classranking) do
			if values['name'] == self.name and values['type'] == 'family' then
				if newName == string.lower(L['Ignore']) then
					Genie.db.profile.classranking[rank] = nil
				else
					if Genie.db.profile.classranking[rank]["criteria"] == Genie.db.profile.classranking[rank]["name"] then
						--this is a custom family
						Genie.db.profile.classranking[rank]["criteria"] = newName
						Genie.db.profile.classranking[rank]["name"] = newName
					else
						--this is a 'category' family
						Genie.db.profile.classranking[rank]["name"] = newName
					end
				end
				renamed = true
				break
			end
		end
	end
	-- update the database
	if renamed == true then
		Genie.db.profile.customFamilies[newName] = Genie.db.profile.customFamilies[self.name]
		Genie.db.profile.customFamilies[self.name] = nil
		return true
	end
    end
    return false
end
function Genie.CLASS.Family:PrettyPrint()
	local txt = gsub(L['Current content of X'], 'X', self.name)
	Genie:Print(txt)
	local entrys = 0
		for item in pairs(Genie.db.profile.customFamilies[self.name]) do
			current = Genie.CLASS.Item:New(item)
			if current ~= nil and current:GetName() ~= '' then
				entrys = entrys +1
				Genie:Print('|cFFFFFF00'..string.format("%.5d", tostring(current:GetId()))..'|r:', current:GetName())
			end
		end
	if self:GetIgnore() then
		Genie:Print(L['All items are beeing ignored'])
	elseif self:HasSpecificIgnore() then
        local containerList = {}
        for name, v in pairs(Genie.CONSTANT) do
            --[[ todo: replace Genie.CONSTANT
                    with the container array, once it's possible to define containers by the user
            --]]
            if type(v) == "table" and v.TYPE and Genie.db.profile.customFamilies[self.name].ignore[v.TYPE] then
                if L[name:lower():gsub("^%l", string.upper)] then
                    containerList[#containerList+1] = L[name:lower():gsub("^%l", string.upper)]
                else
                    containerList[#containerList+1] = tostring(v.TYPE)
                end
            end
        end
        Genie:Print(L['All items are beeing ignored'], '[',table.concat(containerList,", "), ']')
        
        --[[
        for k in pairs(Genie.db.profile.customFamilies[self.name]) do
            containerList[#t+1] = str:lower():gsub("^%l", string.upper)
        end
        --]]
    end
	if entrys == 0 then
		local txt = L['X is empty']:gsub('X', L['Family'])
		Genie:Print(txt)
	end
end
function Genie.CLASS.Family:Contains(item)
	if item ~= nil and item:GetId() ~= nil then
		if Genie.db.profile.customFamilies[self.name][item:GetId()] then
            --does this item belong to the set
            local _, pos = strsplit(':', tostring(Genie.db.profile.customFamilies[self.name][item:GetId()]))
            if pos then
                local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(GetEquipmentSetLocations(self.Set)[tonumber(pos)])
                if (player and bags) or (bank and bags) then
                    return ((item.Bag == bag) and (item.Slot == slot))
                elseif (bank and not bags) then
                    return ((item.Bag == BANK_CONTAINER) and (item.Slot == slot))
                end
            end
			-- this item was directly added to the family
			return true
        else 
            return self:ContainsTStID(item:GetTStID())
		end
	end
	return false
end
function Genie.CLASS.Family:Exists(name)
	if name == nil then name = self.name end
    name = string.lower(name)
	if name == string.lower(L['Ignore']) then return true end
	local exists = false
	for rank, values in pairs(Genie.db.profile.classranking) do
		if values['type'] == 'family' and (values.criteria == name or values.name == name) then
			exists = true
			break
		end
	end
	return exists
end
function Genie.CLASS.Family:SetEquipmentSet(itemTable)
    local toRemove = Genie.UTILS.CopyTable(Genie.db.profile.customFamilies[self.name])
    for inventorySlot, id in pairs(itemTable) do
        if type(id) == "number" then
            if Genie.db.profile.customFamilies[self.name][id] then
                --keep this item, update the position
                toRemove[id] = nil
				Genie.db.profile.customFamilies[self.name][id] = nil
                self:UpdateContent(Genie.CLASS.Item:New(id), inventorySlot, true)
            else
                --add this item
                self:UpdateContent(Genie.CLASS.Item:New(id), inventorySlot)
            end
        end
    end   
    --remove items
    for id in pairs(toRemove) do
        if type(id) == "number" then
           self:UpdateContent(Genie.CLASS.Item:New(id))
        end
    end
end

function Genie.CLASS.Family.GetAllSets()
    local sets = {}
    for name, values in pairs(Genie.db.profile.customFamilies) do
        if values['set'] then
            sets[name] = table.getn(values) -1
        end
    end
    return sets
end
--- Searches through all families
--@param entry can be anything that has a GetId() function. 
--if entry isn't a table then it will try to create an item
--@return all families the entry is part of as table[family] = true
function Genie.CLASS.Family.GetAllContaining(entry)
	local entry = entry
    if not type(entry) == 'table' then
		entry = Genie.CLASS.Item:New(item)
	end
	if entry then
		local custom = {}
        --directly added
        if entry.GetId then
		for name, family in pairs(Genie.db.profile.customFamilies) do
            if family[entry:GetId()] then 
                custom[name] = true 
            end
		end
        end
        --search within 'aic-famlies'
        if entry.GetTStID then
        for _, class in pairs(Genie.db.profile.classranking) do
            if class.type == 'family' and string.match(entry:GetTStID(), class.criteria .. '.*') then
                custom[class.name] = true
            end
        end
        end
		return custom
	end
	return false
end
function Genie.CLASS.Family:GetAllItems(container)
    local items = {}
    for id in pairs(self.itemDB) do
        if type(id) == 'number' then
            local item = Genie.CLASS.Item:New(id)
            if item then
                table.insert(items, item)
            end
        end
    end
    
    if #items == 0 and container then
        local c = Genie.CLASS.Container:New(container)
        if c then
            c:Fill()
            for index, item in pairs(c:GetItems()) do
                if self:ContainsTStID(item:GetTStID()) then
                    table.insert(items, item)
                end
            end
        end
    end    
    
    return items
end

function Genie.CLASS.Family:ContainsTStID(TStID)
    if self.TStID then
        return string.match(tostring(TStID), '^' .. self.TStID)
    end    
end
function Genie.CLASS.Family:GetTStID()
    if self.TStID then return self.TStID else
        for rank, values in pairs(Genie.db.profile.classranking) do
            if values['type'] == 'family' and values['name'] == self.name then
                return values.criteria
            end
        end
    end
end