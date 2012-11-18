--[[
	Auctioneer
	Version: 5.9.4960 (WhackyWallaby)
	Revision: $Id: CorePost.lua 4960 2010-10-19 21:00:30Z Nechckn $
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
	Auctioneer Posting Engine.

	This code helps modules that need to post things to do so in an extremely easy and
	queueable fashion.

	This code takes "sigs" as input to most of it's functions. A "sig" is a string containing
	a colon seperated concatenation of itemId:suffixId:suffixFactor:enchantId
	A sig must be shortened by truncating trailing 0's - this is required for equality testing
	Any missing values at the end will be set to zero when the sig is decoded
	The function AucAdvanced.API.GetSigFromLink(link) may be used to construct a valid sig
]]
if not AucAdvanced then return end
local coremodule, internal = AucAdvanced.GetCoreModule("CorePost")
-- internal is a shared space only accessible to code that can call GetCoreModule,
-- which is only the .lua files in Auc-Advanced.  Basically, we have an internal use only area.
if not coremodule then return end -- Someone has explicitely broken us
if (not AucAdvanced.Post) then AucAdvanced.Post = {} end

local lib = AucAdvanced.Post
local private = {}
lib.Private = private

local aucPrint = AucAdvanced.Print
local Const = AucAdvanced.Const
local debugPrint = AucAdvanced.Debug.DebugPrint
local _TRANS = AucAdvanced.localizations
local DecodeSig -- to be filled with AucAdvanced.API.DecodeSig when it has loaded

-- local versions of API globals
local floor = floor
local type = type
local GetItemInfo = GetItemInfo

-- Local tooltip for getting soulbound line from tooltip contents
local ScanTip = CreateFrame("GameTooltip", "AppraiserTip", UIParent, "GameTooltipTemplate")
local ScanTip2 = _G["AppraiserTipTextLeft2"]
local ScanTip3 = _G["AppraiserTipTextLeft3"]

-- control constants used in the posting mechanism
local LAG_ADJUST = (4 / 1000)
local SIGLOCK_TIMEOUT = 8 -- seconds timeout waiting for bags to update after auction created
local POST_TIMEOUT = 8 -- seconds general timeout after starting an auction, before deciding the auction has failed
local POST_ERROR_PAUSE = 5 -- seconds pause after an error before trying next request
local POST_THROTTLE = 0.1 -- time before starting to post the next item in the queue
local POST_TIMER_INTERVAL = 0.5 -- default interval of updates from the timer
local MINIMUM_DEPOSIT = 100 -- 1 silver minimum deposit
local PROMPT_HEIGHT = 120
local PROMPT_MIN_WIDTH = 400

local BindTypes = {
	[ITEM_SOULBOUND] = "Bound",
	[ITEM_BIND_QUEST] = "Quest",
	[ITEM_BIND_ON_PICKUP] = "Bound",
	[ITEM_CONJURED] = "Conjured",
	[ITEM_ACCOUNTBOUND] = "Accountbound",
	[ITEM_BIND_TO_ACCOUNT] = "Accountbound",
}

local UIAuctionErrors = {
	[ERR_NOT_ENOUGH_MONEY] = "ERR_NOT_ENOUGH_MONEY",
	[ERR_AUCTION_BAG] = "ERR_AUCTION_BAG",
	[ERR_AUCTION_BOUND_ITEM] = "ERR_AUCTION_BOUND_ITEM",
	[ERR_AUCTION_CONJURED_ITEM] = "ERR_AUCTION_CONJURED_ITEM",
	[ERR_AUCTION_DATABASE_ERROR] = "ERR_AUCTION_DATABASE_ERROR",
	[ERR_AUCTION_ENOUGH_ITEMS] = "ERR_AUCTION_ENOUGH_ITEMS",
	[ERR_AUCTION_HOUSE_DISABLED] = "ERR_AUCTION_HOUSE_DISABLED",
	[ERR_AUCTION_LIMITED_DURATION_ITEM] = "ERR_AUCTION_LIMITED_DURATION_ITEM",
	[ERR_AUCTION_LOOT_ITEM] = "ERR_AUCTION_LOOT_ITEM",
	[ERR_AUCTION_QUEST_ITEM] = "ERR_AUCTION_QUEST_ITEM",
	[ERR_AUCTION_REPAIR_ITEM] = "ERR_AUCTION_REPAIR_ITEM",
	[ERR_AUCTION_USED_CHARGES] = "ERR_AUCTION_USED_CHARGES",
	[ERR_AUCTION_WRAPPED_ITEM] = "ERR_AUCTION_WRAPPED_ITEM",
}

-- todo: in OnLoad auto-replace values with translations based on table key: "ADV_Help_PostError"..key - e.g. "ADV_Help_PostErrorBound"
-- Some of these errors are only of use when debugging, so should probably not be translated. i.e. the "InvalidX" codes
local ErrorText = {
	Bound = "Cannot auction a Soulbound item",
	Accountbound = "Cannot auction an Account Bound item",
	Conjured = "Cannot auction a Conjured item",
	Quest = "Cannot auction a Quest item",
	Lootable = "Cannot auction a Lootable item",
	Damaged = "Cannot auction a Damaged item",
	InvalidBid = "Bid value is invalid",
	InvalidBuyout = "Buyout value is invalid",
	InvalidDuration = "Duration value is invalid",
	InvalidSig = "Function requires a valid item sig",
	InvalidSize = "Size value is invalid",
	InvalidMultiple = "Multiple stack value is invalid",
	UnknownItem = "Item is unknown",
	MaxSize = "Item cannot be stacked that high",
	NotFound = "Item was not found in inventory",
	NotEnough = "Not enough of item available",
	PayDeposit = "Not enough money to pay the deposit",
	FailTimeout = "Timed out while waiting for confirmation of posting",
	FailSlot = "Unable to place item in the Auction slot",
	FailStart = "Failed to start auction",
	FailMultisell = "Multisell failed to post all requested stacks",
}
lib.ErrorText = ErrorText

-- local constants to index the posting request tables (deprecated)
local REQ_SIG = 1
local REQ_COUNT = 2
local REQ_BID = 3
local REQ_BUYOUT = 4
local REQ_DURATION = 5
local REQ_NUMSTACKS = 6
-- function to create a new posting request table; keep sync'd with the above constants
-- todo: when we stop using these deprecated constants, remove private.NewRequestTable and streamline into queueing function
private.lastPostId = 0
function private.NewRequestTable(sig, count, bid, buyout, duration, numStacks)
	local postId = private.lastPostId + 1
	private.lastPostId = postId
	local request = {
		-- backward compatibility indexed values (deprecated)
		sig, --REQ_SIG
		count, --REQ_COUNT
		bid, --REQ_BID
		buyout, --REQ_BUYOUT
		duration, --REQ_DURATION
		numStacks, --REQ_NUMSTACKS
		-- new style values
		sig = sig,
		count = count,
		bid = bid,
		buy = buyout,
		duration = duration,
		stacks = numStacks,
		id = postId,
		posted = 0,
	}
	return request
end

do
--[[
	Functions to safely handle the Post Request queue
]]
	local postRequests = {}
	local lastReported = 0
	local reportLock = 0
	local lastCountSig, lastCountRequests, lastCountItems, lastCountAuctions
	function private.QueueReport()
		lastCountSig = nil
		if reportLock ~= 0 then return end
		local queuelength = #postRequests
		if lastReported ~= queuelength then
			lastReported = queuelength
			AucAdvanced.SendProcessorMessage("postqueue", queuelength)
		end
	end
	--[[ not used in current version
	function private.SetQueueReports(activate)
		if activate then
			if reportLock > 0 then
				reportLock = reportLock - 1
			end
			private.QueueReport()
		else
			reportLock = reportLock + 1
		end
	end
	--]]
	function private.QueueInsert(request)
		tinsert(postRequests, request)
		private.QueueReport()
	end
	function private.QueueRemove(index)
		index = index or 1
		if postRequests[index] then
			local request = tremove(postRequests, index)
			private.QueueReport()
			return request
		end
	end
	function private.QueueReorder(indexfrom, indexto)
		-- removes the request at position indexfrom and reinserts it at position indexto
		-- when indexto > indexfrom, be aware that the remove operation reindexes the table positions after indexfrom, before the reinsert occurs
		local queuelen = #postRequests
		if queuelen < 2 then return end
		indexfrom = indexfrom or 1
		if not indexto or indexto > queuelen then
			indexto = queuelen
		end
		if indexfrom == indexto then return end
		local request = tremove(postRequests, indexfrom)
		if not request then return end
		tinsert(postRequests, indexto, request)
		private.QueueReport()
		return true
	end
	function private.GetQueueIndex(index)
		return postRequests[index]
	end
	function private.GetQueueIterator()
		return ipairs(postRequests)
	end

	--[[ GetQueueLen()
		Return number of requests remaining in the Post Queue
	--]]
	function lib.GetQueueLen()
		return #postRequests
	end

	--[[ GetQueueItemCount(sig)
		Return number of requests, total number of items and total number of auctions matching the sig
	--]]
	function lib.GetQueueItemCount(sig)
		if sig and sig == lastCountSig then
			-- "last item" cache: this function tends to get called multiple times for the same sig
			return lastCountRequests, lastCountItems, lastCountAuctions
		end
		local requestCount, itemCount, auctionCount = 0, 0, 0
		for _, request in ipairs(postRequests) do
			if request.sig == sig then
				local numstacks = request.stacks
				requestCount = requestCount + 1
				itemCount = itemCount + request.count * numstacks
				auctionCount = auctionCount + numstacks
			end
		end
		lastCountSig = sig
		lastCountRequests = requestCount
		lastCountItems = itemCount
		lastCountAuctions = auctionCount
		return requestCount, itemCount, auctionCount
	end

	--[[ CancelPostQueue()
		Safely removes all possible Post requests from the Post queue
		If we are in the process of posting an auction, that request cannot be removed
	--]]
	function lib.CancelPostQueue()
		if #postRequests > 0 then
			local request = postRequests[1] -- save the first request
			wipe(postRequests)
			if request.posting then
				if request.prompt then
					private.HidePrompt()
				elseif request.time then
					-- request is currently being posted, put it back in the queue until the posting resolves
					tinsert(postRequests, request)
					CancelSell() -- abort current Multisell operation
				end
			end
			private.QueueReport()
		end
	end
end --of Post Request Queue section

local AuctionDurationCode = {
	1, --[1]
	2, --[2]
	3, --[3]
	[12] = 1, -- hours
	[24] = 2,
	[48] = 3,
	[720] = 1, -- minutes
	[1440] = 2,
	[2880] = 3,
}
function lib.ValidateAuctionDuration(duration)
	return AuctionDurationCode[duration]
end

function private.GetRequest(sig, size, bid, buyout, duration, multiple)
	local id = DecodeSig(sig)
	if not id then
		return nil, "InvalidSig"
	elseif type(size) ~= "number" or size < 1 then
		return nil, "InvalidSize"
	elseif type(bid) ~= "number" or bid < 1 then
		return nil, "InvalidBid"
	elseif type(buyout) ~= "number" or (buyout < bid and buyout ~= 0) then
		return nil, "InvalidBuyout"
	end
	duration = AuctionDurationCode[duration]
	if not duration then
		return nil, "InvalidDuration"
	end

	local name, link,_,_,_,_,_, maxSize,_, texture = GetItemInfo(id)
	if not name then
		return nil, "UnknownItem"
	elseif size > maxSize then
		return nil, "MaxSize"
	end

	multiple = tonumber(multiple) or 1
	if multiple < 1 or multiple ~= floor(multiple) then
		return nil, "InvalidMultiple"
	end
	local available, total, _, _, _, reason = lib.CountAvailableItems(sig)
	if total == 0 then
		return nil, "NotFound"
	elseif available == 0 and reason then
		return nil, reason
	elseif available < size * multiple then
		return nil, "NotEnough"
	end

	local request = private.NewRequestTable(sig, size, bid, buyout, duration, multiple)

	return request
end

--[[
    PostAuction(sig, size, bid, buyout, duration, [multiple])

	Places the request to post a stack of the "sig" item, "size" high
	into the auction house for "bid" minimum bid, and "buy" buyout and
	posted for "duration" minutes. The request will be posted
	"multiple" number of times.

	This is the main entry point to the Post library for other AddOns, so has the strictest parameter checking
	"multiple" is optional, defaulting to 1. All other parameters are required.

	If successful it returns a request id; the id will be included in the "postresult" Processor message for each request
	If a problem is detected it returns nil, reason
		reason is an internal short text code; it can be converted to a displayable text message using lib.ErrorCodes[reason]
]]
function lib.PostAuction(sig, size, bid, buyout, duration, multiple)
	local request, reason = private.GetRequest(sig, size, bid, buyout, duration, multiple)
	if not request then
		return nil, reason
	end
	private.QueueInsert(request)
	private.Wait(0) -- delay until next OnUpdate
	return request.id
end

--[[ PostAuctionClick(sig, size, bid, buyout, duration, multiple)
	As PostAuction, except that this function will attempt to post the auction immediately if possible
	May only be called from an OnClick handler
--]]
function lib.PostAuctionClick(sig, size, bid, buyout, duration, multiple)
	local request, reason = private.GetRequest(sig, size, bid, buyout, duration, multiple)
	if not request then
		return nil, reason
	end
	local noqueue = false -- placeholder for a Setting to block queueing when CorePost is busy

	local isEmpty = lib.GetQueueLen() == 0
	if not isEmpty and noqueue then
		return nil, "Busy"
	end
	private.QueueInsert(request)
	local id = request.id

	if isEmpty then
		-- Attempt to post the auction immediately
		private.Wait(0)
		private.SigLockUpdate()
		if not private.IsSigLocked(request.sig) then
			if private.ClearAuctionSlot() then
				local bag, slot = private.SelectStack(request)
				if bag then
					if private.LoadAuctionSlot(request, bag, slot) then
						private.StartAuction(request)
						return id
					end
				end
			end
		end
	end
	if noqueue then
		-- posting failed, noqueue is flagged, so remove the request we just queued
		-- todo: consider using/modifying SetQueueReports for this eventuality
		lib.QueueRemove(lib.GetQueueLen())
		return nil, "Busy"
	else
		return id
	end
end

--[[
    DecodeSig(sig)
    DecodeSig(itemid, suffix, factor, enchant)
    Returns: itemid, suffix, factor, enchant
	Deprecated. Retained for library compatibility
	Real function moved to AucAdvanced.API, with the other sig functions
]]
function lib.DecodeSig(matchId, matchSuffix, matchFactor, matchEnchant)
	if (type(matchId) == "string") then
		return DecodeSig(matchId)
	end
	matchId = tonumber(matchId)
	if not matchId or matchId == 0 then return end
	matchSuffix = tonumber(matchSuffix) or 0
	matchFactor = tonumber(matchFactor) or 0
	matchEnchant = tonumber(matchEnchant) or 0

	return matchId, matchSuffix, matchFactor, matchEnchant
end

--[[
    IsAuctionable(bag, slot)
    Returns:
		true : if the item is (probably) auctionable.
		false, reason : if the item is not auctionable
			reason is an internal (non-localized) string code, use lib.ErrorText[errorcode] for a printable text string

    This function does not check everything, but if it says no,
    then the item is definately not auctionable.
]]
function lib.IsAuctionable(bag, slot)
	local _,_,_,_,_,lootable = GetContainerItemInfo(bag, slot)
	if lootable then
		return false, "Lootable"
	end

	ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
	ScanTip:ClearLines()
	ScanTip:SetBagItem(bag, slot)
	local test = BindTypes[ScanTip2:GetText()] or BindTypes[ScanTip3:GetText()]
	ScanTip:Hide()
	if test then
		return false, test
	end

	-- Check for 'fixable' conditions only after checking all 'unfixable' conditions

	local damage, maxdur = GetContainerItemDurability(bag, slot)
	if damage and damage ~= maxdur then
		return false, "Damaged"
	end

	return true
end

--[[
	CountAvailableItems(sig)
	Returns: availableCount, totalCount, unpostableCount, queuedCount, postedCount, unpostableError
	The Posting modules need to know how many items are available to be posted;
	this is not the same as the number of items currently in the bags
--]]
function lib.CountAvailableItems(sig)
	local matchId, matchSuffix, matchFactor, matchEnchant = DecodeSig(sig)
	if not matchId then return end
	local totalCount, unpostableCount = 0, 0
	local unpostableError

	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, itemId, itemSuffix, itemFactor, itemEnchant = AucAdvanced.DecodeLink(link)
				if itemId == matchId
				and itemSuffix == matchSuffix
				and itemFactor == matchFactor
				and itemEnchant == matchEnchant then
					local _, count = GetContainerItemInfo(bag, slot)
					if not count or count < 1 then count = 1 end
					totalCount = totalCount + count
					local test, code = lib.IsAuctionable(bag, slot)
					if not test then
						unpostableCount = unpostableCount + count
						if unpostableError ~= "Damaged" then -- if there are both "Damaged" and "Soulbound" items, we want to report the "Damaged" code here
							unpostableError = code
						end
					end
				end
			end
		end
	end

	-- any items queued to be posted are unavailable
	local _, queuedCount = lib.GetQueueItemCount(sig)

	-- any items under SigLock are unavailable, still appear in bags, but are not included in queue count
	local siglockCount = private.GetSigLockCount(sig)

	return (totalCount - unpostableCount - queuedCount - siglockCount), totalCount, unpostableCount, queuedCount, siglockCount, unpostableError
end

--[[
    FindMatchesInBags(sig)
    FindMatchesInBags(itemId, [suffix, [factor, [enchant, [seed] ] ] ])
    Returns: { {bag, slot, count}, ... }, itemCount, blankBagId, blankSlotNumber, foundLink, foundLocked
	Library wrapper for the internal version, to check parameters (and to support anticipated future changes)
]]
function lib.FindMatchesInBags(...)
	return private.FindMatchesInBags(lib.DecodeSig(...))
end
-- Internal implementation of FindMatchesInBags
-- This is no longer used by ProcessPosts, and is likely to become deprecated
function private.FindMatchesInBags(matchId, matchSuffix, matchFactor, matchEnchant)
	if not matchId then return end
	local matches = {}
	local total = 0
	local blankBag, blankSlot, foundLink, foundLocked

	local itemtype = GetItemFamily(matchId) or 0
	if itemtype > 0 then
		-- check to see if item is itself a bag
		local _,_,_,_,_,_,_,_,equiploc = GetItemInfo(matchId)
		if equiploc == "INVTYPE_BAG" then
			itemtype = 0 -- can only be placed in general-purpose bags
		end
	end

	for bag = 0, 4 do
		local slots = GetContainerNumSlots(bag)
		if slots > 0 then
			local _, bagtype = GetContainerNumFreeSlots(bag)
			-- can this bag contain the item we're looking for?
			if bagtype == 0 or bit.band(bagtype, itemtype) ~= 0 then
				for slot = 1, slots do
					local link = GetContainerItemLink(bag,slot)
					if link then
						local texture, itemCount, locked, quality, readable = GetContainerItemInfo(bag,slot)
						local itype, itemId, suffix, factor, enchant = AucAdvanced.DecodeLink(link)
						if itype == "item"
						and itemId == matchId
						and suffix == matchSuffix
						and factor == matchFactor
						and enchant == matchEnchant
						and lib.IsAuctionable(bag, slot) then
							if not itemCount or itemCount < 1 then itemCount = 1 end
							tinsert(matches, {bag, slot, itemCount})
							total = total + itemCount
							foundLink = link
							if locked then
								foundLocked = true
							end
						end
					else -- blank slot
						if not blankBag then
							blankBag = bag
							blankSlot = slot
						end
					end
				end
			end
		end
	end
	return matches, total, blankBag, blankSlot, foundLink, foundLocked
end

-- lookup table used by GetDepositCost to avoid a large if/elseif block
local depositDurationMultiplier = {
	3,	--[1]
	6,	--[2]
	12,	--[3]
	[12] = 3,
	[24] = 6,
	[48] = 12,
	[720] = 3,
	[1440] = 6,
	[2880] = 12,
}
--[[
    GetDepositCost(item, duration, faction, count)
    item: itemID or "itemString" or "itemName" or "itemLink" [Required]
	duration: 1, 2, 3 (Blizzard auction duration codes), 12, 24, 48 (hours), 720, 1440, 2880 (minutes) [defaults to 2]
	faction: "home" or "neutral" or "Neutral" [defaults to home]
    count: <stacksize> [defaults to 1]
]]
function GetDepositCost(item, duration, faction, count)
	if not item then return end
	--[[
	Deposit Cost = RoundDown(VendorPrice * FactionMultiplier * StackSize, 3) * DurationMultiplier
	FactionMultiplier = (0.15 for Home, 0.75 for Neutral)
	DurationMultiplier = (1 for 12hrs, 2 for 24hrs, 4 for 48hrs)
	However as there is no lua function for "round down to the nearest multiple of 3",
	we shall implement this by dividing the FactionMultiplier by 3 (0.05 and 0.25)
	using 'floor' to round down to the nearest integer
	and then multiplying the DurationMultiplier by 3 (3, 6 and 12) - [see lookup table above]
	--]]

	-- Set up function defaults if not specifically provided
	duration = depositDurationMultiplier[duration] or 6
	if faction == "neutral" or faction == "Neutral" then faction = .25 else faction = .05 end
	count = count or 1

	local _,_,_,_,_,_,_,_,_,_,gsv = GetItemInfo(item)
	if not gsv and GetSellValue then
		-- if item is not in local cache, fallback to GetSellValue
		-- some people may still be using a GetSellValue provider with a saved price database
		gsv = GetSellValue(item)
	end
	if gsv then
		local deposit = floor(faction * gsv * count) * duration
		if deposit < MINIMUM_DEPOSIT then
			deposit = MINIMUM_DEPOSIT
		end
		return deposit
	end
end

do
--[[ SigLock
	'Locks' a sig to prevent ProcessPosts from posting it until certain conditions apply
	This attempts to avoid Internal Auction Errors, which can sometimes be caused by
	trying to post multiple requests of the same item before the bags are updated
--]]
	local lockedsigs
	local lastlocktime
	function private.IsSigLocked(sig)
		if lockedsigs and lockedsigs[sig] then
			return true
		end
	end
	function private.GetSigLockCount(sig)
		-- return count of items posted for locked sig
		if lockedsigs and lockedsigs[sig] then
			return lockedsigs[sig].postedcount
		end
		return 0
	end
	function private.LockSig(request)
		local sig = request.sig
		local postedcount = request.count * request.posted
		local expectedcount = request.totalcount - postedcount
		lastlocktime = GetTime()
		if not lockedsigs then lockedsigs = {} end
		lockedsigs[sig] = {
			expectedcount = expectedcount,
			postedcount = postedcount,
		}
	end
	function private.SigLockClear()
		-- called when the posting timer is deactivated
		lockedsigs = nil
	end
	function private.SigLockBagUpdate()
		if not lockedsigs then return end
		-- BAG_UPDATE events often occur in batches
		-- so throttle our checks by delaying until the next OnUpdate
		private.Wait(0)
	end
	function private.SigLockUpdate()
		if not lockedsigs then return end
		-- use longer timeout delays if connectivity is bad, but always at least 1 second
		local _,_, lag = GetNetStats()
		lag = max(lag * LAG_ADJUST, 1)
		if GetTime() > lastlocktime + lag * SIGLOCK_TIMEOUT then
			-- global timeout for all SigLocks based on when the last item was locked
			lockedsigs = nil
			debugPrint("All SigLocks cleared due to timeout", "CorePost", "SigLock Timeout", "Info")
			return
		end

		-- count items in bags (only for locked sigs)
		local sigcounts = {}
		for bag = 0, NUM_BAG_FRAMES do
			for slot = 1, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link then
					local sig = AucAdvanced.API.GetSigFromLink(link)
					if lockedsigs[sig] then
						local _, count = GetContainerItemInfo(bag, slot)
						if not count or count < 1 then count = 1 end
						sigcounts[sig] = (sigcounts[sig] or 0) + count
					end
				end
			end
		end
		-- test each sig to see if it can be unlocked
		for sig, data in pairs(lockedsigs) do
			if not sigcounts[sig] or sigcounts[sig] <= data.expectedcount then
				-- number of items in bags now matches (or less than) expected count
				lockedsigs[sig] = nil
			end
		end
		if not next(lockedsigs) then lockedsigs = nil end -- delete table if empty
	end
end -- SigLock

--[[ PRIVATE: RequestDisplayString(request [, link])
	Generates a display string for use in printout
--]]
function private.RequestDisplayString(request, link)
	local msg = link or request.link or AucAdvanced.API.GetLinkFromSig(request.sig) or "|cffff0000[Unknown]|r"
	local count = request.count
	local numstacks = request.stacks
	if count > 1 then
		msg = msg.."x"..count
	end
	if numstacks > 1 then
		msg = numstacks.." * "..msg
	end
	return msg
end

function private.TrackPostingSuccess()
	local request = private.GetQueueIndex(1)
	if not (request and request.posting) then return end
	local posted = request.posted + 1
	request.posted = posted
	if posted >= request.stacks then -- all stacks posted
		ClearCursor()
		ClickAuctionSellItemButton() -- Clear Auction slot
		ClearCursor()
		private.LockSig(request)
		private.QueueRemove()
		private.Wait(POST_THROTTLE)
	else
		request.time = GetTime() -- renew timeout for the next stack
	end
	AucAdvanced.SendProcessorMessage("postresult", true, request.id, request)
end

function private.TrackPostingMultisellFail()
	ClearCursor()
	ClickAuctionSellItemButton() -- Clear Auction slot
	ClearCursor()
	local request = private.GetQueueIndex(1)
	if not (request and request.posting) then return end
	local link = request.link
	if not link then return end
	private.LockSig(request)
	private.QueueRemove()
	private.Wait(POST_ERROR_PAUSE)
	AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "FailMultisell")

	if request.cancelled and not private.lastUIError then
		-- cancelled by user: display a chat message instead of throwing an error
		aucPrint(("Multisell batch of %s was cancelled. %d were posted."):format(private.RequestDisplayString(request, link), request.posted))
	else
		local msg = ("Failed to post all requested auctions of %s (posted %d)"):format(private.RequestDisplayString(request, link), request.posted)
		if private.lastUIError then
			msg = msg.."\nAdditional info: "..private.lastUIError
		end
		debugPrint(msg, "CorePost", "Posting Failure", "Warning")
		geterrorhandler()(msg)
	end
end

function private.TrackCancelSell()
	local request = private.GetQueueIndex(1)
	if not request or not request.posting then return end
	-- flag to suppress error messages when the cancelled Multisell 'fails'
	request.cancelled = true
end

--[[ PRIVATE: ClearAuctionSlot()
	Clears the cursor and the AuctionSellItem slot, and confirms that the clearing was successful
	Called before starting posting process
	In most other places we use a shorter inline code sequence, without the confirmations
--]]
function private.ClearAuctionSlot()
	-- cursor needs to be clear before we can attempt posting
	ClearCursor()
	if GetCursorInfo() or SpellIsTargeting() then
		return
	end

	-- auction slot needs to be clear
	if GetAuctionSellItemInfo() then
		ClickAuctionSellItemButton()
		ClearCursor()
		if GetAuctionSellItemInfo() then
			-- it's locked, wait for it to clear
			private.waitBagUpdate = true -- watch for bag changes too
			return
		end
	end

	return true
end

--[[ PRIVATE: SelectStack(request)
	Decide which stack to put into the Auction Slot for posting
--]]
function private.SelectStack(request)
	local sig, count = request.sig, request.count
	local matchId, matchSuffix, matchFactor, matchEnchant = DecodeSig(sig)
	local foundBag, foundSlot, foundStop, foundSize

	--[[ Selection algorithm version 4

		Only useful when posting a single stack, as Multisell mode will ignore our selection

		Ignore un-auctionable stacks
		Return nil, nil if any matching stacks are locked
		Find the first stack of the exact size
		Otherwise find the smallest stack larger than the requested size
		Otherwise use the first stack found
	--]]

	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, itemId, itemSuffix, itemFactor, itemEnchant = AucAdvanced.DecodeLink(link)
				if itemId == matchId
				and itemSuffix == matchSuffix
				and itemFactor == matchFactor
				and itemEnchant == matchEnchant
				and lib.IsAuctionable(bag, slot) then
					local _, thiscount, locked = GetContainerItemInfo(bag,slot)
					if locked then
						return -- return immediately if we find a locked stack
					elseif not foundStop then
						if thiscount == count then
							-- found a stack the correct size
							foundBag = bag
							foundSlot = slot
							foundStop = true
						elseif thiscount > count and (not foundSize or thiscount < foundSize) then
							-- find the smallest stack larger than the requested size
							foundSize = thiscount
							foundBag = bag
							foundSlot = slot
						elseif not foundBag then
							-- record the first bag/slot, if none of the above cases apply
							foundBag = bag
							foundSlot = slot
						end
					end
				end
			end
		end
	end

	if foundBag then
		return foundBag, foundSlot
	end

	return nil, "NotFound"
end

--[[ PRIVATE: LoadAuctionSlot(request, bag, slot)
	Loads the item in bag/slot into AuctionSellItem slot
	AuctionSellItem slot and cursor must be clear
	Performs numerous checks to verify the item is loaded correctly and is postable
--]]
function private.LoadAuctionSlot(request, bag, slot)
	local link = GetContainerItemLink(bag, slot)
	local checkname = GetItemInfo(link)
	assert(link and checkname)

	PickupContainerItem(bag, slot)
	if not CursorHasItem() then
		-- failed to pick up from bags, probably due to some unfinished operation; wait for another cycle
		private.waitBagUpdate = true -- watch for bag changes too
		return
	end

	private.waitBagUpdate = nil
	private.lastUIError = nil
	if not AuctionFrameAuctions.duration then
		-- Fix in case Blizzard_AuctionUI hasn't set this value yet (causes an error otherwise)
		-- todo: periodically check if this is still needed
		AuctionFrameAuctions.duration = 2
	end
	ClickAuctionSellItemButton()

	-- verify that the contents of the Auction slot are what we expect
	local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount = GetAuctionSellItemInfo()
	if name ~= checkname then
		-- failed to drop item in auction slot, probably because item is not auctionable (but was missed by our checks)
		local msg = ("Unable to create auction for %s: %s"):format(private.RequestDisplayString(request, link), ErrorText["FailSlot"])
		if private.lastUIError then
			msg = msg.."\nAdditional info: "..private.lastUIError
		end
		debugPrint(msg, "CorePost", "Posting Failure", "Warning")
		private.QueueRemove()
		private.Wait(POST_ERROR_PAUSE)
		AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "FailSlot")
		if private.lastUIError then
			geterrorhandler()(msg)
		else
			message(msg)
		end
		return
	end
	if totalCount < request.count * request.stacks then
		-- not enough items to complete this request; abort whole request
		ClickAuctionSellItemButton()
		ClearCursor() -- Put it back in the bags
		local msg = ("Unable to create auction for %s: %s"):format(private.RequestDisplayString(request, link), ErrorText["NotEnough"])
		debugPrint(msg, "CorePost", "Posting Failure", "Warning")
		private.QueueRemove()
		private.Wait(POST_ERROR_PAUSE)
		AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "NotEnough")
		message(msg)
		return
	end
	if GetMoney() < CalculateAuctionDeposit(request.duration, request.count) * request.stacks then
		-- not enough money to pay the deposit
		ClickAuctionSellItemButton()
		ClearCursor() -- Put it back in the bags
		local msg = ("Unable to create auction for %s: %s"):format(private.RequestDisplayString(request, link), ErrorText["PayDeposit"])
		debugPrint(msg, "CorePost", "Posting Failure", "Warning")
		private.QueueRemove()
		private.Wait(POST_ERROR_PAUSE)
		AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "PayDeposit")
		message(msg)
		return
	end
	-- todo: should we check private.lastUIError at this point for unknown errors?

	request.link = link -- store specific link (uniqueID)
	request.totalcount = totalCount -- this will be used by the SigLock mechanism
	request.selectedcount = count -- used by the Prompt sanity checks
	request.name = name -- used by the Prompt sanity checks
	request.texture = texture

	return true
end

--[[ PRIVATE: VerifyAuctionSlot(request)
	Checks that the item in the AuctionSellItem slot still matches the item in 'request' and is still sellable
	Used while the Prompt is open to see if something has changed
--]]
function private.VerifyAuctionSlot(request)
	local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount = GetAuctionSellItemInfo()
	if name ~= request.name or count ~= request.selectedcount then
		-- Either slot has been cleared, or has been replaced with something else
		return
	end
	if totalCount < request.count * request.stacks then
		return
	end
	if GetMoney() < CalculateAuctionDeposit(request.duration, request.count) * request.stacks then
		return
	end

	return true
end

--[[ PRIVATE: PerformPosting()
	Called from the Prompt Yes/Continue button
	Note: silently does nothing when prompt is hidden, to handle macro spam
--]]
function private.PerformPosting()
	local request = private.promptRequest
	private.HidePrompt()
	if not request then return end
	request.posting = nil -- temporarily unflag until we complete the checks

	-- Sanity checks
	if request ~= private.GetQueueIndex(1) then return end
	if not private.VerifyAuctionSlot(request) then return end

	private.StartAuction(request)
end

--[[ PRIVATE: CancelPosting()
	Called from the Prompt No/Cancel button
--]]
function private.CancelPosting()
	local request = private.promptRequest
	private.HidePrompt()
	if request and request == private.GetQueueIndex(1) then
		ClearCursor()
		ClickAuctionSellItemButton() -- Clear Auction slot
		ClearCursor()
		private.QueueRemove()
	end
end

--[[ PRIVATE: ShowPrompt(request)
	Display the confirmation prompt
	Item must already be loaded in AuctionSellItem slot
--]]
function private.ShowPrompt(request)
	if private.promptRequest then
		error("CorePost:ShowPrompt - private.promptRequest is not nil")
	end
	if private.Prompt:IsShown() then
		error("CorePost:ShowPrompt - Prompt is already shown")
	end
	private.promptRequest = request
	request.prompt = true
	request.posting = true
	private.Prompt:Show()
	private.Prompt.Text1:SetText("Ready to post "..private.RequestDisplayString(request))
	private.Prompt.Text2:SetText("Min Bid "..AucAdvanced.Coins(request.bid, true)..", Buyout "..AucAdvanced.Coins(request.buy, true))
	private.Prompt.Item.tex:SetTexture(request.texture)
	local headwidth = (private.Prompt.Heading:GetStringWidth() or 0) + 70
	local width1 = (private.Prompt.Text1:GetStringWidth() or 0) + 70
	local width2 = (private.Prompt.Text2:GetStringWidth() or 0) + 70
	private.Prompt.Frame:SetWidth(max(headwidth, width1, width2, PROMPT_MIN_WIDTH))
end

--[[ PRIVATE: HidePrompt()
	Close the prompt and tidy up flags
	May be safely called at any time
--]]
function private.HidePrompt()
	local request = private.promptRequest
	private.Prompt:Hide()
	private.promptRequest = nil
	if request then
		request.prompt = nil
	end
end


--[[ PRIVATE: StartAuction(request)
	Starts the auction
	Item must already be loaded in AuctionSellItem slot
	In WoW4.0 or later must only be called from within an OnClick handler (hardware event required)
--]]
function private.StartAuction(request)
	debugPrint("Starting auction "..private.RequestDisplayString(request), "CorePost", "Starting Auction", "Info")
	private.lastUIError = nil
	StartAuction(request.bid, request.buy, request.duration, request.count, request.stacks)
	if UIAuctionErrors[private.lastUIError] then
		-- UI Error is one of the known Auction errors that prevent posting
		ClearCursor()
		ClickAuctionSellItemButton()
		ClearCursor() -- Put it back in the bags
		local msg = ("Unable to create auction for %s: %s"):format(private.RequestDisplayString(request), ErrorText["FailStart"])
		msg = msg.."\nAdditional info: "..private.lastUIError
		debugPrint(msg, "CorePost", "Posting Failure", "Warning")
		private.QueueRemove()
		private.Wait(POST_ERROR_PAUSE)
		AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "FailStart")
		--message(msg)
		geterrorhandler()(msg)
		return
	end
	request.time = GetTime() -- record time of posting for calculating timeout
	request.posting = true

	return true
end

--[[
	ProcessPosts()
	This function is responsible for maintaining and processing the post queue.
	Only called from OnUpdate.
	Use private.Wait(0) to trigger ProcessPosts on next update.
]]
local function ProcessPosts()
	if lib.GetQueueLen() <= 0 or not (AuctionFrame and AuctionFrame:IsVisible()) then
		private.Wait() -- put timer to sleep
		return
	end

	private.Wait(POST_TIMER_INTERVAL) -- set default wait time (overwritten later in certain cases)

	local request = private.GetQueueIndex(1)

	if request.posting then
		-- This request is being posted. Check for timeout
		-- (Other success/fail situations are handled by the TrackPostingX functions)
		-- use longer timeout delays if connectivity is bad, but always at least 1 second
		if request.prompt or not request.time then return end
		local _,_, lag = GetNetStats()
		lag = max(lag * LAG_ADJUST, 1)
		if GetTime() > request.time + lag * POST_TIMEOUT then
			local msg = ("Unable to confirm auction for %s: %s"):format(private.RequestDisplayString(request), ErrorText["FailTimeout"])
			if private.lastUIError then
				msg = msg.."\nAdditional info: "..private.lastUIError
			end
			debugPrint(msg, "CorePost", "Posting timeout", "Warning")
			private.QueueRemove()
			private.Wait(POST_ERROR_PAUSE)
			AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, "FailTimeout")
			if private.lastUIError then
				geterrorhandler()(msg)
			else
				message(msg)
			end
		end
		return
	end

	private.SigLockUpdate() -- check the status of any SigLocks
	if private.IsSigLocked(request.sig) then
		-- see if we can find a request in the queue that is not SigLocked
		for index, req in private.GetQueueIterator() do
			if not private.IsSigLocked(req.sig) then
				private.QueueReorder(index, 1) -- move to the front of the queue
				private.Wait(0) -- wait for next OnUpdate
				return
			end
		end
		-- otherwise wait for the SigLock(s) to clear
		return
	end

	if not private.ClearAuctionSlot() then
		return
	end

	local bag, slot = private.SelectStack(request)
	if bag then
		if not private.LoadAuctionSlot(request, bag, slot) then
			return
		end
		private.ShowPrompt(request)
	elseif slot then -- bag == nil
		-- 'slot' contains the error code
		private.Wait(POST_ERROR_PAUSE)
		local msg = ("Aborting post request for %s: %s"):format(private.RequestDisplayString(request), ErrorText[slot])
		debugPrint(msg, "CorePost", "Post request aborted", "Warning")
		private.QueueRemove()
		AucAdvanced.SendProcessorMessage("postresult", false, request.id, request, slot)
		message(msg)
		return
	else
		-- both bag and slot are nil: wait for another cycle
		-- no errors but for some reason we cannot post this request at this time
		-- (in current implementation, only occurs if we have found a locked stack)
		private.waitBagUpdate = true -- flag to trigger for bag changes too
	end
end


--[[
	Frame for OnUpdate and OnEvent handlers
]]

local EventFrame = CreateFrame("Frame")
local EventFrameTimer -- Countdown timer
EventFrame:Hide() -- Timer is initially stopped
EventFrame:SetScript("OnUpdate", function(self, elapsed)
	EventFrameTimer = EventFrameTimer - elapsed
	if EventFrameTimer <= 0 then
		ProcessPosts() -- EventFrameTimer will be updated by ProcessPosts via a call to private.Wait()
	end
end)

--[[
	PRIVATE: Wait(delay)
	Used to control the timer and event handler
	Use delay = nil to stop the timer
	Use delay >= 0 to start the timer and set the delay length
--]]
function private.Wait(delay)
	if delay then
		if not EventFrameTimer then
			EventFrame:Show()
		end
		EventFrameTimer = delay
	else
		if EventFrameTimer then
			EventFrame:Hide()
			EventFrameTimer = nil
		end
		private.SigLockClear()
	end
end

local function EventHandler(self, event, arg1, arg2)
	if not EventFrameTimer then
		if event == "AUCTION_HOUSE_SHOW" then
			if lib.GetQueueLen() > 0 then
				private.Wait(0) -- wake up timer
			end
		end
		return
	end
	if event == "CHAT_MSG_SYSTEM" then
		if arg1 == ERR_AUCTION_STARTED then
			private.TrackPostingSuccess()
		end
	elseif event == "UI_ERROR_MESSAGE" then
		private.lastUIError = arg1
	elseif event == "AUCTION_MULTISELL_START" then
		if AuctionProgressFrame.fadeOut then
			-- stop the fade and set alpha back to full
			-- AuctionProgressFrame is a global defined in Blizzard_AuctionUI
			AuctionProgressFrame.fadeOut = nil
			AuctionProgressFrame:SetAlpha(1)
		end
	--elseif event == "AUCTION_MULTISELL_UPDATE" then
	elseif event == "AUCTION_MULTISELL_FAILURE" then
		private.TrackPostingMultisellFail()
	elseif event == "ITEM_LOCK_CHANGED" then
		if private.waitBagUpdate then
			private.waitBagUpdate = nil
			private.Wait(0)
		end
	elseif event == "BAG_UPDATE" then
		private.SigLockBagUpdate()
		if private.waitBagUpdate then
			private.waitBagUpdate = nil
			private.Wait(0)
		end
	elseif event == "AUCTION_HOUSE_CLOSED" then
		if lib.GetQueueLen() > 0 then
			private.HidePrompt()
			if AucAdvanced.Settings.GetSetting("post.clearonclose") then
				if AucAdvanced.Settings.GetSetting("post.confirmonclose") then
					StaticPopup_Show("POST_CANCEL_QUEUE_AH_CLOSED")
				else
					lib.CancelPostQueue()
				end
			end
			-- if currently multiselling, it will fail - treat as deliberate cancel to suppress error
			private.TrackCancelSell()
		end
	end
end
EventFrame:SetScript("OnEvent", EventHandler)
EventFrame:RegisterEvent("CHAT_MSG_SYSTEM")
EventFrame:RegisterEvent("UI_ERROR_MESSAGE")
EventFrame:RegisterEvent("AUCTION_MULTISELL_START")
--EventFrame:RegisterEvent("AUCTION_MULTISELL_UPDATE")
EventFrame:RegisterEvent("AUCTION_MULTISELL_FAILURE")
EventFrame:RegisterEvent("ITEM_LOCK_CHANGED")
EventFrame:RegisterEvent("BAG_UPDATE")
EventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
EventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")

function coremodule.OnLoad(addon)
	if addon == "auc-advanced" then
		-- Install values into locals/tables, that are not available until Auctioneer is fully loaded
		DecodeSig = AucAdvanced.API.DecodeSig
		for code, text in pairs(ErrorText) do
			local transkey = "ADV_Help_PostError"..code
			local transtext = _TRANS(transkey)
			if transtext ~= transkey then -- _TRANS returns transkey if there is no available translation
				ErrorText[code] = transtext
			end
		end
	end
end

-- Other hooks
private.hook_CancelSell = CancelSell
CancelSell = function(...)
	private.TrackCancelSell() -- needs to be pre-hooked
	return private.hook_CancelSell(...)
end

StaticPopupDialogs["POST_CANCEL_QUEUE_AH_CLOSED"] = {
  text = "The Auctionhouse has closed. Do you want to clear the Posting queue?",
  button1 = YES,
  button2 = NO,
  OnAccept = lib.CancelPostQueue,
  timeout = 20,
  whileDead = true,
  hideOnEscape = true,
}

--[[ Prompt Frame ]]--
-- (Cloned and modified from CoreBuy)

--this is a anchor frame that never changes size
private.Prompt = CreateFrame("Frame", "AuctioneerPostPrompt", UIParent)
private.Prompt:Hide()
private.Prompt:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
private.Prompt:SetFrameStrata("DIALOG")
private.Prompt:SetHeight(PROMPT_HEIGHT)
private.Prompt:SetWidth(PROMPT_MIN_WIDTH)
private.Prompt:SetMovable(true)
private.Prompt:SetClampedToScreen(true)

--The "graphic" frame and backdrop that we resize
private.Prompt.Frame = CreateFrame("Frame", nil, private.Prompt)
private.Prompt.Frame:SetPoint("CENTER", private.Prompt, "CENTER" )
private.Prompt.Frame:SetFrameLevel(private.Prompt:GetFrameLevel() - 1) -- lower level than parent (backdrop)
private.Prompt.Frame:SetHeight(PROMPT_HEIGHT)
private.Prompt.Frame:SetWidth(PROMPT_MIN_WIDTH)
private.Prompt.Frame:SetClampedToScreen(true)
private.Prompt.Frame:SetBackdrop({
	bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 9, right = 9, top = 9, bottom = 9 }
})
private.Prompt.Frame:SetBackdropColor(0,0,0,0.8)

-- Helper functions
local function ShowTooltip()
	local link = private.promptRequest and private.promptRequest.link
	if link then
		GameTooltip:SetOwner(private.Prompt.Item, "ANCHOR_TOPRIGHT")
		GameTooltip:SetHyperlink(link)
	end
end
local function HideTooltip()
	GameTooltip:Hide()
end
local function DragStart()
	private.Prompt:StartMoving()
end
local function DragStop()
	private.Prompt:StopMovingOrSizing()
end

private.Prompt.Item = CreateFrame("Button", nil, private.Prompt) -- todo: does this really need to be a button?
private.Prompt.Item:SetNormalTexture("Interface\\Buttons\\UI-Slot-Background")
private.Prompt.Item:GetNormalTexture():SetTexCoord(0,0.640625, 0, 0.640625)
private.Prompt.Item:SetPoint("TOPLEFT", private.Prompt.Frame, "TOPLEFT", 15, -15)
private.Prompt.Item:SetHeight(37)
private.Prompt.Item:SetWidth(37)
private.Prompt.Item:SetScript("OnEnter", ShowTooltip)
private.Prompt.Item:SetScript("OnLeave", HideTooltip)
private.Prompt.Item.tex = private.Prompt.Item:CreateTexture(nil, "OVERLAY")
private.Prompt.Item.tex:SetPoint("TOPLEFT", private.Prompt.Item, "TOPLEFT", 0, 0)
private.Prompt.Item.tex:SetPoint("BOTTOMRIGHT", private.Prompt.Item, "BOTTOMRIGHT", 0, 0)

private.Prompt.Heading = private.Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
private.Prompt.Heading:SetPoint("CENTER", private.Prompt.Frame, "CENTER", 20, 30)
--private.Prompt.Heading:SetPoint("TOPRIGHT", private.Prompt, "TOPRIGHT", -15, -20)
--private.Prompt.Heading:SetJustifyH("CENTER")
private.Prompt.Heading:SetText("Auctioneer needs a confirmation to continue posting")

private.Prompt.Text1 = private.Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
private.Prompt.Text1:SetPoint("CENTER", private.Prompt.Frame, "CENTER", 20, 10)

private.Prompt.Text2 = private.Prompt:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
private.Prompt.Text2:SetPoint("CENTER", private.Prompt.Frame, "CENTER", 20, -10)

-- Yes and No buttons are named to allow macros to /click them
private.Prompt.Yes = CreateFrame("Button", "AuctioneerPostPromptYes", private.Prompt, "OptionsButtonTemplate")
private.Prompt.Yes:SetText(CONTINUE)
--private.Prompt.Yes:SetPoint("BOTTOMRIGHT", private.Prompt, "BOTTOMRIGHT", -100, 10)
private.Prompt.Yes:SetPoint("BOTTOMLEFT", private.Prompt, "BOTTOMLEFT", 100, 10)
private.Prompt.Yes:SetScript("OnClick", private.PerformPosting)

private.Prompt.No = CreateFrame("Button", "AuctioneerPostPromptNo", private.Prompt, "OptionsButtonTemplate")
private.Prompt.No:SetText(CANCEL)
--private.Prompt.No:SetPoint("BOTTOMRIGHT", private.Prompt.Yes, "BOTTOMLEFT", -60, 0)
private.Prompt.No:SetPoint("BOTTOMLEFT", private.Prompt.Yes, "BOTTOMRIGHT", 60, 0)
private.Prompt.No:SetScript("OnClick", private.CancelPosting)

private.Prompt.DragTop = CreateFrame("Button", nil, private.Prompt)
private.Prompt.DragTop:SetPoint("TOPLEFT", private.Prompt, "TOPLEFT", 10, -5)
private.Prompt.DragTop:SetPoint("TOPRIGHT", private.Prompt, "TOPRIGHT", -10, -5)
private.Prompt.DragTop:SetHeight(6)
private.Prompt.DragTop:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
private.Prompt.DragTop:SetScript("OnMouseDown", DragStart)
private.Prompt.DragTop:SetScript("OnMouseUp", DragStop)

private.Prompt.DragBottom = CreateFrame("Button", nil, private.Prompt)
private.Prompt.DragBottom:SetPoint("BOTTOMLEFT", private.Prompt, "BOTTOMLEFT", 10, 5)
private.Prompt.DragBottom:SetPoint("BOTTOMRIGHT", private.Prompt, "BOTTOMRIGHT", -10, 5)
private.Prompt.DragBottom:SetHeight(6)
private.Prompt.DragBottom:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
private.Prompt.DragBottom:SetScript("OnMouseDown", DragStart)
private.Prompt.DragBottom:SetScript("OnMouseUp", DragStop)


AucAdvanced.RegisterRevision("$URL: http://svn.norganna.org/auctioneer/branches/5.9/Auc-Advanced/CorePost.lua $", "$Rev: 4960 $")
