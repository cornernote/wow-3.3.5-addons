SellOMatic = LibStub("AceAddon-3.0"):NewAddon("Sell-O-Matic", "AceEvent-3.0", "AceConsole-3.0");
local SellOMatic = _G.SellOMatic
local L = LibStub("AceLocale-3.0"):GetLocale("SellOMatic");
local abacus = LibStub("LibAbacus-3.0");
local item_tooltip = LibStub("LibGratuity-3.0");

local function getOption(info)
	return (info.arg and SellOMatic.db.profile[info.arg] or SellOMatic.db.profile[info[#info]]);
end;

local function setOption(info, value)
	local key = info.arg or info[#info];
	SellOMatic.db.profile[key] = value;
end;

local options = {
	name = "Sell-O-Matic",
	handler = SellOMatic,
	type = "group",
	args = {
		general = {
			type = "group",
			name = L["General Options"],
			guiInline = true,
			args = {
				autoSell = {
					name = L["Auto sell"],
					desc = L["Toggle ON/OFF automatic mode."],
					order = 1,
					type = "toggle",
					get = getOption,
					set = setOption,
				},
				showFullInfo = {
					name = L["Information type"],
					desc = L["Choose the type of information"],
					order = 2,
					type = "select",
					values = {
						["1-FULL"] = L["FULL"],
						["2-SUMMARY"] = L["SUMMARY"],
						["3-LITE"] = L["LITE"],
					},
					style = "dropdown",
					get = getOption,
					set = setOption,
				},
				showDetail = {
					name = L["Show detail"],
					desc = L["Toggle ON/OFF item sell detail."],
					order = 3,
					type = "toggle",
					get = getOption,
					set = setOption,
				},
				showAdditionalButtons = {
					name = L["Show +/- buttons"],
					desc = L["Toggle ON/OFF showing add/del buttons."],
					order = 10,
					type = "toggle",
					get = getOption,
					set = setOption,
				},
			},
		},
		actions = {
			type = "group",
			name = L["Actions"],
			guiInline = true,
			args = {
				-- sellItem function deprecated.
				showList = {
					name = L["Show list"],
					desc = L["Shows the sell/save lists."],
					order = 1,
					type = "execute",
					func = "ShowSOMList",
					width = "full",
				},
				addItem = {
					name = L["Add item"],
					desc = L["Adds item to sell/save list."],
					order = 2,
					type = "execute",
					func = "SOMListAdd",
				},
				delItem = {
					name = L["Del item"],
					desc = L["Deletes item from sell/save list."],
					order = 3,
					type = "execute",
					func = "SOMListDel",
				},
				importSellList = {
					name = L["Import sell list"],
					desc = L["Imports the old sell list."],
					order = 4,
					hidden = true,
					type = "execute",
					func = "ImportSellList",
					width = "full",
				},
				resetSellList = {
					name = L["Reset sell list"],
					desc = L["Resets the sell list."],
					order = 5,
					type = "execute",
					func = "ResetSellList",
				},
				resetSaveList = {
					name = L["Reset save list"],
					desc = L["Resets the save list."],
					order = 6,
					type = "execute",
					func = "ResetSaveList",
				},
				addText = {
					name = L["Add item"],
					order = 7,
					hidden = true,
					type = "input",
					set = "SOMListAddLink",
					get = false,
				},
				delText = {
					name = L["Del item"],
					order = 8,
					hidden = true,
					type = "input",
					set = "SOMListDelLink",
					get = false,
				},
				destroy = {
					name = L["Destroy junk"],
					desc = L["Destroys all gray items on inventory"],
					order = 9,
					type = "execute",
					func = "Destroy",
				},
			},
		},
		showList = {
			name = L["Show list"],
			hidden = true,
			type = "execute",
			func = "ShowSOMList",
		},
		addItem = {
			name = L["Add item"],
			hidden = true,
			type = "execute",
			func = "SOMListAdd",
		},
		delItem = {
			name = L["Del item"],
			hidden = true,
			type = "execute",
			func = "SOMListDel",
		},
		importSellList = {
			name = L["Import sell list"],
			hidden = true,
			type = "execute",
			func = "ImportSellList",
		},
		resetSellList = {
			name = L["Reset sell list"],
			hidden = true,
			type = "execute",
			func = "ResetSellList",
		},
		resetSaveList = {
			name = L["Reset save list"],
			hidden = true,
			type = "execute",
			func = "ResetSaveList",
		},
		addText = {
			name = L["Add item"],
			hidden = true,
			type = "input",
			set = "SOMListAddLink",
			get = false,
		},
		delText = {
			name = L["Del item"],
			hidden = true,
			type = "input",
			set = "SOMListDelLink",
			get = false,
		},
		destroy = {
			name = L["Destroy junk"],
			hidden = true,
			type = "execute",
			func = "Destroy",
		},
	},
}

local item_options = {
	type = "group",
	name = L["Item Options"],
	args = {
		allowBoP = {
			name = L["Sell BoP"],
			desc = L["Toggle ON/OFF selling green soulbound items."],
			order = 1,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		allowBoE = {
			name = L["Sell BoE"],
			desc = L["Toggle ON/OFF selling green bind on equip items."],
			order = 2,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		allowWhite = {
			name = L["Sell common"],
			desc = L["Toggle ON/OFF selling common (white) items."],
			order = 3,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		allowBlue = {
			name = L["Allow Blue"],
			desc = L["Toggle ON/OFF selling blue quality items."],
			order = 4,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		allowEpic = {
			name = L["Allow Epic"],
			desc = L["Toggle ON/OFF selling epic quality items."],
			order = 5,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		useILevel = {
			name = L["Use iLevel"],
			desc = L["Toggles ON/OFF selling items by iLevel."],
			order = 6,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		iLevelValue = {
			name = L["iLevel value"],
			desc = L["Items below the iLevel value set will be sold"],
			order = 7,
			type = "range",
			min = 1,
			max = 200,
			step = 1,
			get = getOption,
			set = setOption,
		},
	},
}

local list_options = {
	type = "group",
	name = L["List Options"],
	args = {
		useList = {
			name = L["Use list"],
			desc = L["Toggle ON/OFF the sell/save list."],
			order = 1,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		caseSensitiveList = {
				name = L["Case sensitive list"],
				desc = L["Toggle ON/OFF case sensitive lists."],
				order = 2,
				type = "toggle",
				get = getOption,
				set = setOption,
		},
		list_allowBoP = {
			name = L["Sell BoP"],
			desc = L["Toggle ON/OFF selling green soulbound items."],
			order = 3,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_allowBoE = {
			name = L["Sell BoE"],
			desc = L["Toggle ON/OFF selling green bind on equip items."],
			order = 4,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_allowWhite = {
			name = L["Sell common"],
			desc = L["Toggle ON/OFF selling common (white) items."],
			order = 5,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_allowBlue = {
			name = L["Allow Blue"],
			desc = L["Toggle ON/OFF selling blue quality items."],
			order = 6,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_allowEpic = {
			name = L["Allow Epic"],
			desc = L["Toggle ON/OFF selling epic quality items."],
			order = 7,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_useILevel = {
			name = L["Use iLevel"],
			desc = L["Toggles ON/OFF selling items by iLevel."],
			order = 8,
			type = "toggle",
			get = getOption,
			set = setOption,
		},
		list_iLevelValue = {
			name = L["iLevel value"],
			desc = L["Items below the iLevel value set will be sold"],
			order = 9,
			type = "range",
			min = 1,
			max = 200,
			step = 1,
			get = getOption,
			set = setOption,
		},
	},
}

local help_options = {
	name = "Sell-O-Matic Help",
	type = "group",
	args = {
		commands = {
			name = L["Commands"],
			type = "group",
			guiInline = true,
			order = 1,
			args = {
				commands_help = {
					type = "description",
					name = "|cFFFFFF55/sellomatic |r -- "..L["this menu."].."\n"..
						"|cFFFFFF55/som |r -- "..L["same as /sellomatic."].."\n"..
						"|cFFFFFF55/som additem |r -- "..L["opens add item box."].."\n"..
						"|cFFFFFF55/som delitem |r -- "..L["opens del item box."].."\n"..
						"|cFFFFFF55/som showlist |r -- "..L["prints sell/save list if used."].."\n"..
						"|cFFFFFF55/som addtext |cFF8888FF#text |r -- "..L["add #text to the sell list if used."].."\n"..
						"|cFFFFFF55/som deltext |cFF8888FF#text |r -- "..L["delete #text from the sell list if used."].."\n"..
						"|cFFFFFF55/som importselllist |r -- "..L["imports old sell list if available."].."\n"..
						"|cFFFFFF55/som resetselllist |r -- "..L["deletes all sell list data."].."\n"..
						"|cFFFFFF55/som resetsavelist |r -- "..L["deletes all save list data."].."\n"..
						"|cFFFFFF55/som destroy |r -- "..L["Destroys all junk items in your inventory"].."\n"..
						"|cFFFFFF55/som destroy |cFF8888FFN |r -- "..L["Destroys n junk items in your inventory"].."\n"..
						"|cFFFFFF55/som destroy |cFF8888FFXYZ |r -- "..L["Destroys the item(s) containing the string XYZ"]
				},
			},
		},
		-- list_tips = {
			-- name = L["List tips"],
			-- type = "group",
			-- order = 2,
			-- args = {
				-- list_tips_help = {
					-- type = "description",
					-- name = L["Some tips and clues to maximize the use of lists"]..":\n"..
						-- "- "..L["tip #1"].."\n"..
						-- "- "..L["tip #2"].."\n"..
						-- "- "..L["tip #3"].."\n"..
						-- "- "..L["tip #4"].."\n"..
						-- "- "..L["tip #5"].."\n"
				-- },
			-- },
		-- },
	},
}

local profile_options = {
	name = "Sell-O-Matic Profiles",
	type = "group",
	args = {
	},
}

-- Default
local defaults = {
	profile = {
		autoSell = false,
		showFullInfo = L["FULL"],
		showDetail = false,
		useList = false,
		sellList = {},
		saveList = {},
		allowWhite = false,
		allowBlue = false,
		allowEpic = false,
		allowBoP = false,
		allowBoE = false,
		showAdditionalButtons = false,
		caseSensitiveList = false,
		iLevelValue = 1,
		useILevel = false,
		list_allowBoP = false,
		list_allowBoE = false,
		list_allowWhite = false,
		list_allowBlue = false,
		list_allowEpic = false,
		list_useILevel = false,
		list_iLevelValue = 1,
	},
}

function SellOMatic:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("SellOMaticDB", defaults, "Default");
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SellOMatic", options);
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SellOMatic Item", item_options);
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SellOMatic List", list_options);
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SellOMatic Help", help_options);
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SellOMatic Profiles", profile_options);
	profile_options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SellOMatic", "Sell-O-Matic");
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SellOMatic Item", "Item Options", "Sell-O-Matic");
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SellOMatic List", "List Options", "Sell-O-Matic");
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SellOMatic Help", "Help", "Sell-O-Matic");
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SellOMatic Profiles", "Profiles", "Sell-O-Matic");
	self:RegisterChatCommand("sellomatic", "ChatCommand");
	self:RegisterChatCommand("som", "ChatCommand");
	SellButton:Hide()
	AddButton:Hide()
	DelButton:Hide()
end;

function SellOMatic:OnEnable()
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("MERCHANT_CLOSED");
	profit = 0;
	profit_item = 0;
end;

function SellOMatic:ChatCommand(input)
	if not input or input:trim() == "" then
		InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
	else
		local arg1, arg2 = self:GetArgs(input, 2, 1, input)
		if arg1 == "destroy" and arg2 ~= nil and arg2:trim() ~= "" then
			SellOMatic:Destroy(arg2);
		elseif arg1 == "destroyitem" and arg2 ~= nil and arg2:trim() ~= "" then
			SellOMatic:DestroyItem(arg2);
		else
			LibStub("AceConfigCmd-3.0").HandleCommand(SellOMatic, "SellOMatic", "SellOMatic", input);
		end;
	end;
end;

function SellOMatic:MERCHANT_SHOW()
	SellButton:Show()
	if self.db.profile.showAdditionalButtons then
		AddButton:Show();
		DelButton:Show();
	end;
	--SellOMatic:ShowMerchantButton();
	if self.db.profile.autoSell then
		self:Sell();
	end;
end;

function SellOMatic:MERCHANT_CLOSED()
	SellButton:Hide()
	if self.db.profile.showAdditionalButtons then
		AddButton:Hide();
		DelButton:Hide();
	end;
	--SellOMatic:HideMerchantButton();
end;

-- Function SELL
-- Checks to use save/sell list, sell acording to the options.
function SellOMatic:Sell()
	num = 0;
	detail = "";
	if self.db.profile.useList then
		-- SELL ITEMS USING SELL/SAVE LIST
		for bag = 0,4,1 do
			for slot = 1, GetContainerNumSlots(bag),1 do
				name = GetContainerItemLink(bag,slot);
				if name then
					itemName, itemLink, itemRarity, itemLevel = GetItemInfo("\""..name.."\"");
					-- Sell iLevel items
					if self.db.profile.list_useILevel then
						num = self:SellItemLevel(num,name,bag,slot);
					end;
					-- Sell epic items
					if self.db.profile.list_allowEpic and itemRarity == 4 then
						num = self:SellItemList(name,bag,slot,num);
					end;
					-- Sell blue items
					if self.db.profile.list_allowBlue and itemRarity == 3 then
						num = self:SellItemList(name,bag,slot,num);
					end;
					-- Sell soulbound items
					if self.db.profile.list_allowBoP and itemRarity >= 2 then
						num = self:SellBindItems(ITEM_SOULBOUND,num,name,bag,slot);
					end;
					-- Sell bind on equip items
					if self.db.profile.list_allowBoE and itemRarity >= 2 then
						num = self:SellBindItems(ITEM_BIND_ON_EQUIP,num,name,bag,slot);
					end;
					-- Sell quality items
					if itemRarity == 1 or itemRarity == 2 then
						num = self:SellItemList(name,bag,slot,num);
					end;
					-- Sell common items
					if self.db.profile.list_allowWhite and itemRarity == 1 then
						num = self:SellItemCheck(name,bag,slot,num);
					end;
					-- Sell unquality items
					if itemRarity == 0 then
						num = self:SellItemCheck(name,bag,slot,num);
					end;
				end;
			end;
		end;
	else
		-- ONLY SELL GRAY ITEMS
		num = self:SellTrash(num)
		-- Sell iLevel items
		if self.db.profile.useILevel then
			num = self:SellItemLevel(num);
		end;
		-- Sell soulbound items
		if self.db.profile.allowBoP then
			num = self:SellBindItems(ITEM_SOULBOUND,num);
		end;
		-- Sell bind on equip items
		if self.db.profile.allowBoE then
			num = self:SellBindItems(ITEM_BIND_ON_EQUIP,num);
		end;
	end;

	if num > 0 then
		self:ShowProfit(num);
		profit = 0;
	end;
end;

function SellOMatic:SellItemList(name,bag,slot,num)
	local list_i;
	for i,v in ipairs(self.db.profile.sellList) do
		if self.db.profile.caseSensitiveList then
			name = string.lower(name);
			list_i = string.lower(self.db.profile.sellList[i]);
		else
			list_i = self.db.profile.sellList[i];
		end;
		if name and string.find(name,list_i) or name == v then
			SellOMatic_Tooltip:SetBagItem(bag, slot);
			if self.db.profile.showDetail then detail = ": "..abacus:FormatMoneyFull(profit_item); end;
			if self.db.profile.showFullInfo == "1-FULL" then
				SellOMatic:Print(L["Selling "]..name..detail);
			end;
			UseContainerItem(bag,slot);
			num = num + 1;
		end;
	end;
	return num;
end;

function SellOMatic:SellItem(name,bag,slot,num)
	SellOMatic_Tooltip:SetBagItem(bag, slot);
	if self.db.profile.showDetail then detail = ": "..abacus:FormatMoneyFull(profit_item); end;
	if self.db.profile.showFullInfo == "1-FULL" then
		SellOMatic:Print(L["Selling "]..name..detail);
	end;
	UseContainerItem(bag,slot);
	num = num + 1;
	return num;
end;

function SellOMatic:SellItemName(name,num)
	for nBag = 0,4,1 do
		for nSlot = 1, GetContainerNumSlots(nBag), 1 do
			iNameLink = GetContainerItemLink(bag,slot);
			if iNameLink then
				local iName = GetItemInfo("\""..iNameLink.."\"");
				if self.db.profile.caseSensitiveList then
					iName = string.lower(iName);
					name = string.lower(name);
				end;
				if iName == name then
					self:SellItem(name,bag,slot,num);
				end;
			end;
		end;
	end;
	return num;
end;

function SellOMatic:SellItemCheck(name,bag,slot,num)
	local save = 0;
	local list_i;
	for i,v in ipairs(self.db.profile.saveList) do
		if self.db.profile.caseSensitiveList then
			name = string.lower(name);
			list_i = string.lower(self.db.profile.saveList[i]);
		else
			list_i = self.db.profile.saveList[i];
		end;
		if name and string.find(name,list_i) or name == v then
			save = 1;
		end;
	end;
	if save == 0 then
		num = self:SellItem(name,bag,slot,num);
	end;
	return num;
end;

function SellOMatic:SellTrash(num)
	for bag = 0,4,1 do
		for slot = 1, GetContainerNumSlots(bag),1 do
			name = GetContainerItemLink(bag,slot);
			if name ~= nil then
			itemName, itemLink, itemRarity = GetItemInfo(name);
				if itemRarity == 0 then
					SellOMatic_Tooltip:SetBagItem(bag, slot);
					if self.db.profile.showDetail then detail = ": "..abacus:FormatMoneyFull(profit_item); end;
					if self.db.profile.showFullInfo == "1-FULL" then
						SellOMatic:Print(L["Selling "]..name..detail);
					end;
					UseContainerItem(bag,slot);
					num = num + 1;
				end;
			end;
		end;
	end;
	return num;
end;

function SellOMatic:SellBindItems(item_type,num,name,bag,slot)
	-- Using list
	if name then
		local list_i;
		local save = 0;
		item_tooltip:SetBagItem(bag,slot);
		if item_tooltip:Find(item_type,1,3) then
			for i,v in ipairs(self.db.profile.saveList) do
				if self.db.profile.caseSensitiveList then
					name = string.lower(name);
					list_i = string.lower(self.db.profile.saveList[i]);
				else
					list_i = self.db.profile.saveList[i];
				end;
				if name and string.find(name,list_i) or name == v then
					save = 1;
				end;
			end;
			if save == 0 then
				local _,_,iRarity,_,_,_,_,_,_ = GetItemInfo(GetContainerItemLink(bag,slot));
				if iRarity == 2 or self.db.profile.list_allowBlue and iRarity == 3 or self.db.profile.list_allowEpic and iRarity == 4 then
					num = self:SellItem(name,bag,slot,num);
				end;
			end;
		end;
	-- NOT using list
	else
		local sLink
		for sBag = 0,4,1 do
			for sSlot = 1,GetContainerNumSlots(sBag),1 do
				sLink = GetContainerItemLink(sBag,sSlot);
				if sLink then
					local _,_,iRarity,_,_,_,_,_,_ = GetItemInfo(sLink);
					item_tooltip:SetBagItem(sBag,sSlot);
					if item_tooltip:Find(item_type,1,3) and iRarity == 2 or self.db.profile.allowBlue and iRarity == 3 or self.db.profile.allowEpic and iRarity == 4  then
						num = self:SellItem(sLink,sBag,sSlot,num);
					end;
				end;
			end;
		end;
	end;
	return num;
end;

function SellOMatic:SellItemLevel(num,name,bag,slot)
	-- Using list
	if name then
		local list_i;
		local save = 0;
		for i,v in ipairs(self.db.profile.saveList) do
			if self.db.profile.caseSensitiveList then
				name = string.lower(name);
				list_i = string.lower(self.db.profile.saveList[i]);
			else
				list_i = self.db.profile.saveList[i];
			end;
			if name and string.find(name,list_i) or name == v then
				save = 1;
			end;
		end;
		if save == 0 then
			local _,_,iRarity,iLevel = GetItemInfo(GetContainerItemLink(bag,slot));
			if iLevel >= 1 and iLevel <= self.db.profile.list_iLevelValue then
				item_tooltip:SetBagItem(bag,slot);
				if item_tooltip:Find(ITEM_BIND_ON_EQUIP,1,3) and self.db.profile.allowBoE or item_tooltip:Find(ITEM_SOULBOUND,1,3) and self.db.profile.list_allowBoP then
					if iRarity == 2 or self.db.profile.list_allowBlue and iRarity == 3 or self.db.profile.list_allowEpic and iRarity == 4 then
						num = self:SellItem(name,bag,slot,num);
					end;
				end;
			end;
		end;
	-- NOT using list
	else
		local sLink
		for sBag = 0,4,1 do
			for sSlot = 1,GetContainerNumSlots(sBag),1 do
				sLink = GetContainerItemLink(sBag,sSlot);
				if sLink then
					local _,_,iRarity,iLevel = GetItemInfo(sLink);
					if iLevel >= 1 and iLevel <= self.db.profile.iLevelValue then
						item_tooltip:SetBagItem(sBag,sSlot);
						if item_tooltip:Find(ITEM_BIND_ON_EQUIP,1,3) and self.db.profile.allowBoE or item_tooltip:Find(ITEM_SOULBOUND,1,3) and self.db.profile.list_allowBoP then
							if iRarity == 2 or self.db.profile.allowBlue and iRarity == 3 or self.db.profile.allowEpic and iRarity == 4 then
								num = self:SellItem(sLink,sBag,sSlot,num);
							end;
						end;
					end;
				end;
			end;
		end;
	end;
	return num;
end;

function SellOMatic:ShowProfit()
	if self.db.profile.showFullInfo == "3-LITE" then
		SellOMatic:Print(num.." "..L["item(s) sold for"].." "..abacus:FormatMoneyFull(profit));
	else
		if self.db.profile.autoSell then
			SellOMatic:Print("## SOM Auto Sell ##");
		end;
		SellOMatic:Print(num.." "..L["item(s) sold"]);
		SellOMatic:Print(L["You've earned "]..abacus:FormatMoneyExtended(profit));
	end;
end;

function SellOMatic_SetProfit()
	if (arg1) then
		profit = profit + arg1;
		profit_item = arg1;
	end;
end;

-- Function DESTROY
-- Clears your bags of grey items
function SellOMatic:Destroy(input)
	local num;
	local itemNum = 0;
	if input ~= nil then
		itemNum = tonumber(input);
	end;
	if itemNum ~= nil and itemNum > 0 then
		num = self:DeleteNumTrash(itemNum);
		if num ~= input then
			SellOMatic:Print(num.." "..L["junk item(s) deleted"]);
		else
			SellOMatic:Print(itemNum.." "..L["junk item(s) deleted"]);
		end;
	else
		num = self:DeleteTrash();
		SellOMatic:Print(num.." "..L["junk item(s) deleted"]);
	end;
end;

function SellOMatic:DeleteTrash()
	local num = 0;
	for bag = 0,4,1 do
		for slot = 1, GetContainerNumSlots(bag),1 do
			name = GetContainerItemLink(bag,slot);
			if name ~= nil then
			itemName, itemLink, itemRarity = GetItemInfo(name);
				if itemRarity == 0 then
					PickupContainerItem(bag,slot);
					DeleteCursorItem();
					num = num + 1;
				end;
			end;
		end;
	end;
	return num;
end;

function SellOMatic:DeleteNumTrash(inputNum)
	local trashList = {}
	trashList = self:CheckTrash();
	trashList = self:SortTrash(trashList);
	local tableSize, itemNum = 100;
	if inputNum ~= nil then
		itemNum = tonumber(inputNum);
	end;
	if itemNum > #trashList then
		itemNum = #trashList;
	end;
	for i=1,itemNum,1 do
		PickupContainerItem(trashList[i][2],trashList[i][3]);
		DeleteCursorItem();
	end;
	return itemNum;
end;

function SellOMatic:CheckTrash()
	local trashList = {};
	local index = 1;
	for bag = 0,4,1 do
		for slot = 1, GetContainerNumSlots(bag),1 do
			name = GetContainerItemLink(bag,slot);
			if name ~= nil then
			itemName,_,itemRarity,_,_,_,_,_,_,_,itemSellPrice = GetItemInfo(name);
				if itemRarity == 0 then
					trashList[index] = { itemSellPrice, bag, slot };
					index = index + 1;
				end;
			end;
		end;
	end;
	return trashList;
end;

function SellOMatic:SortTrash(trashList)
	local trashItem = { 0, 0, 0};
	for x=1,#trashList,1 do
		for y=x+1,#trashList-1,1 do
			if trashList[x][1] > trashList[y][1] then
				trashItem = trashList[x];
				trashList[x] = trashList[y];
				trashList[y] = trashItem;
			end;
		end;
	end;
	return trashList;
end;

-- Function DESTROYITEM
-- Destroys all items matching the input string
function SellOMatic:DestroyItem(input)
	local destroy_list = {};
	local destroy_item = { "", 0, 0};
	-- Check item
	for bag = 0,4,1 do
		for slot = 1,GetContainerNumSlots(bag),1 do
			name = GetContainerItemLink(bag,slot);
			if self.db.profile.caseSensitiveList then
				input = string.lower(input);
				name = string.lower(name);
			end;
			if name and string.find(name,input) then
				destroy_item = { name, bag, slot };
				table.insert(destroy_list,destroy_item);
			end;
		end;
	end;
	-- Warn user
	SellOMatic:ShowDestroyFrame(destroy_list);
end;

function SellOMatic:ShowDestroyList(destroy_list)
	for i=1,#destroy_list,1 do
		SellOMatic:Print(destroy_list[i][1]);
	end;
end;

function SellOMatic:DestroyItemList(destroy_list)
	local num = 0;
	-- Destroy item
	for i=1,#destroy_list,1 do
		PickupContainerItem(destroy_list[i][2],destroy_list[i][3]);
		DeleteCursorItem();
		num = num + 1;
	end;
	SellOMatic:Print(num.." item(s) destroyed");
end;

-- Function SHOWSOMLIST
-- Prints the sell/save list
function SellOMatic:ShowSOMList()
	if self.db.profile.useList then
		SellOMatic:Print(L["#### Sell List ####"]);
		if self.db.profile.sellList[1] ~= nil then
			--SHOW SELL LIST
			for i,v in ipairs(self.db.profile.sellList) do
				SellOMatic:Print("\["..i.."\] "..v);
			end;
		else
			SellOMatic:Print(L["Sell list empty!"]);
		end;
		SellOMatic:Print("-------------------");
		SellOMatic:Print(L["#### Save List ####"]);
		if self.db.profile.saveList[1] ~= nil then
			--SHOW SAVE LIST
			for i,v in ipairs(self.db.profile.saveList) do
				SellOMatic:Print("\["..i.."\] "..v);
			end;
		else
			SellOMatic:Print(L["Save list empty!"]);
		end;
		SellOMatic:Print("-------------------");
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

function SellOMatic:SellListAdd(itemName)
	local isInList = 0;
	if itemName ~= nil and string.len(itemName) > 0 then
		for i,v in ipairs(self.db.profile.sellList) do
			if itemName and string.find(self.db.profile.sellList[i], itemName) or itemName == v then
				isInList = 1;
			end;
		end;
		if isInList == 0 then
			if self:CheckListItem(itemName) then
				table.insert(self.db.profile.sellList, itemName);
				SellOMatic:Print(itemName.." "..L["added to sell list."]);
			else
				SellOMatic:Print(itemName.." "..L["is not valid."]);
			end;
		else
			SellOMatic:Print(itemName.." "..L["already on sell list."]);
		end;
	end;
end;

function SellOMatic:SaveListAdd(itemName)
	local isInList = 0;
	if itemName ~= nil and string.len(itemName) > 0 then
		for i,v in ipairs(self.db.profile.saveList) do
			if itemName and string.find(self.db.profile.saveList[i], itemName) or itemName == v then
				isInList = 1;
			end;
		end;
		if isInList == 0 then
			if self:CheckListItem(itemName) then
				table.insert(self.db.profile.saveList, itemName);
				SellOMatic:Print(itemName.." "..L["added to save list."]);
			else
				SellOMatic:Print(itemName.." "..L["is not valid."]);
			end;
		else
			SellOMatic:Print(itemName.." "..L["already on save list."]);
		end;
	end;
end;

function SellOMatic:SellListDel(itemName)
	local num = 0;
	if itemName ~= nil and string.len(itemName) > 0 then
		for i,v in ipairs(self.db.profile.sellList) do
			if itemName and string.find(self.db.profile.sellList[i],itemName) or itemName == v then
				num = num + 1;
				table.remove(self.db.profile.sellList, i);
			end;
		end;
		if num > 0 then
			SellOMatic:Print(itemName.." "..L["removed from sell list."]);
		else
			SellOMatic:Print(itemName.." "..L["not found on sell list."]);
		end;
	end;
end;

function SellOMatic:SaveListDel(itemName)
	local num = 0;
	if itemName ~= nil and string.len(itemName) > 0 then
		for i,v in ipairs(self.db.profile.saveList) do
			if itemName and string.find(self.db.profile.saveList[i],itemName) or itemName == v then
				num = num + 1;
				table.remove(self.db.profile.saveList, i);
			end;
		end;
		if num > 0 then
			SellOMatic:Print(itemName.." "..L["removed from save list."]);
		else
			SellOMatic:Print(itemName.." "..L["not found on save list."]);
		end;
	end;
end;

function SellOMatic:CheckListItem(text)
	valid = 1
	-- Search for spaces
	if string.find(text, "%s")==1 then
		valid = 0;
	end;
	-- Search special chars
	if string.find(text, "[^%s%w%-']")~=nil then
		valid = 0;
	end;
	return valid;
end;

function SellOMatic:ResetSellList()
	if self.db.profile.useList then
		self.db.profile.sellList = {};
		SellOMatic:Print(L["Sell list reset."]);
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

function SellOMatic:ResetSaveList()
	if self.db.profile.useList then
		self.db.profile.saveList = {};
		SellOMatic:Print(L["Save list reset."]);
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

function SellOMatic:SOMListAdd(itemName)
	if self.db.profile.useList then
		SellOMatic:ShowAddFrame();
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

function SellOMatic:SOMListAddLink(info,text)
	if text ~= nil then
		name = GetItemInfo(text);
		isInList = 0;
		if name ~= nil then
			itemName = name;
		else
			itemName = text;
		end;
		if self:CheckListItem(text) then
			for i,v in ipairs(self.db.profile.sellList) do
				if itemName and string.find(self.db.profile.sellList[i], itemName) or itemName == v then
					isInList = 1;
				end;
			end;
		end;
		if isInList == 0 then
			table.insert(self.db.profile.sellList, itemName);
			SellOMatic:Print(itemName.." "..L["added to sell list."]);
		else
			SellOMatic:Print(itemName.." "..L["already on sell list."]);
		end;
	end;
end;

function SellOMatic:SOMListDel(itemName)
	if self.db.profile.useList then
		SellOMatic:ShowDelFrame();
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

function SellOMatic:SOMListDelLink(info,text)
	if text ~= nil then
		name = GetItemInfo(text);
		if name ~= nil then
			itemName = name;
		else
			itemName = text;
		end;
		local num = 0;
		for i,v in ipairs(self.db.profile.sellList) do
			if text and string.find(self.db.profile.sellList[i], itemName) or itemName == v then
				num = num + 1;
				table.remove(self.db.profile.sellList, i);
				SellOMatic:Print(v.." "..L["removed from sell list."]);
			end;
		end;
		if num == 0 then
			SellOMatic:Print(itemName.." "..L["not found on sell list."]);
		end;
	end;
end;

function SellOMatic:ImportSellList()
	if self.db.profile.useList then
		if self.db.profile.sellItems ~= nil then
			for i,v in ipairs(self.db.profile.sellItems) do
				self:SellListAdd(self.db.profile.sellItems[i]);
			end;
			SellOMatic:Print(L["Old data imported to list."]);
		else
			SellOMatic:Print(L["No import data found."]);
		end;
	else
		SellOMatic:Print(L["You're not using any list. Use list option is off."]);
	end;
end;

-- For Titan Sell-O-Matic
function SellOMatic:UpdateTitanSOM()
	if TitanSOMExists then
		TitanPanelSellOMaticButton_ForceUpdate();
	end;
end;
