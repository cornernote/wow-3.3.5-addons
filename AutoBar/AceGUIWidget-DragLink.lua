local AceGUI = LibStub("AceGUI-3.0")

--------------
-- DragLink --
--------------

-- Global to track drags
DragLinkFrame = nil

do
	local Type = "DragLink"
	local Version = 1

	local function Aquire(self)

	end

	local function Release(self)
		self.frame:ClearAllPoints()
		self.frame:Hide()
	end


	local function SetLabel(self, text)
--		self.text:SetText(text)
	end

	local function PickupItem(link)
		local name = GetItemInfo(link)
		for bag = 0, 4 do
			for slot = 1, GetContainerNumSlots(bag) do
				local slotlink = GetContainerItemLink(bag, slot)
				if (slotlink) then
					local slotname = GetItemInfo(slotlink)
					if slotname == name then
						PickupContainerItem(bag, slot)
						return
					end
				end
			end
		end
	end

	local function DragLinkGetTexture(self)
		if (self.dragLinkType == "item") then
			local texture = select(10, GetItemInfo(self.value))
			if (texture) then
				return texture
			end
		elseif (self.dragLinkType == "spell") then
			local texture = GetSpellTexture(self.value)
			if (texture) then
				return texture
			end
		elseif (self.dragLinkType == "macro") then
			local name, texture = GetMacroInfo(strsub(self.value, 7))
			return texture
		elseif (self.dragLinkType == "macroCustom") then
			local texture = strsub(self.value, 13)
			if (not texture or texture == "") then
				texture = "Interface\\Icons\\INV_Misc_Gift_05"
			end
			return texture
		end
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end

	local function GetValueFromParams(dragLinkType, info1, info2)
		if (dragLinkType == "item") then
			--for items use the link
			return "item:" .. info1
		elseif (dragLinkType == "spell") then
			if (info1 ~= 0) then	-- Avoid pet/crtter bug
				local name, rank = GetSpellName(info1, info2)
				if (rank ~= "") then
					name = name .. "(" .. rank .. ")"
				end
				return name
			else
				return nil
			end
		elseif (dragLinkType == "macro") then
			return "macro:" .. GetMacroInfo(info1)
		end
	end

	local function DragLinkOnDragStart(frame)
		local self = frame.obj
		DragLinkFrame = frame
		if (self.dragLinkType == "item") then
			PickupItem(self.value)
		elseif (self.dragLinkType == "spell") then
			PickupSpell(self.value)
		elseif (self.dragLinkType == "macro") then
			PickupMacro(strsub(self.value, 7))
		end
	end

	local function DragLinkOnReceiveDrag(frame)
		local self = frame.obj

		if (DragLinkFrame) then
			-- Swap content of two DragLinks
			local sourceIndex = DragLinkFrame.obj.userdata.option.arg.itemIndex
			self:Fire("OnEnterPressed", "SWAP", sourceIndex)

			ClearCursor()
			DragLinkFrame = nil
		else
			local dragLinkType, info1, info2 = GetCursorInfo()

			if (dragLinkType == "item" or dragLinkType == "spell" or dragLinkType == "macro") then
				local value = GetValueFromParams(dragLinkType, info1, info2)
--print("DragLinkOnReceiveDrag value:", value, "GetCursorInfo", GetCursorInfo())
				if (value) then	-- Temporary while pet/critter returns garbage in 3.0.3
					self.value = value
					self.dragLinkType = dragLinkType
					local texture = DragLinkGetTexture(self)
					self:Fire("OnEnterPressed", self.value, dragLinkType, info1, info2, texture)
					self.dragLinkIcon:SetTexture(DragLinkGetTexture(self))

					ClearCursor()
					DragLinkFrame = nil
				end
			end
		end
			ClearCursor()
			DragLinkFrame = nil
	end

	local function DragLinkOnClick(frame, ...)
		local self = frame.obj
--print("DragLinkOnClick", frame, ...)
--print("DragLinkOnClick", frame.obj.userdata)

		if (IsControlKeyDown()) then
			self:Fire("OnEnterPressed", "DELETE")

			ClearCursor()
			DragLinkFrame = nil
		else
			DragLinkOnReceiveDrag(frame, ...)
		end
	end

	local function DragLinkOnEnter(frame)
		local self = frame.obj
		if (self.dragLinkType == "item") then
			GameTooltip:SetOwner(self.frame, "ANCHOR_PRESERVE")
			GameTooltip:SetHyperlink(self.value)
		elseif (self.dragLinkType == "spell") then
--			PickupSpell(self.value)
		elseif (self.dragLinkType == "macro") then
			local name, icon, body = GetMacroInfo(strsub(self.value, 7))
			if (name) then
				GameTooltip:SetOwner(self.frame, "ANCHOR_PRESERVE")
				GameTooltip:AddLine(tostring(name), 0.2, 0.8, 0.8, 1)
				GameTooltip:AddTexture(icon)
				GameTooltip:AddLine(tostring(body), 1, 1, 1, 1)
				GameTooltip:Show()
			end
		end
	end

	local function DragLinkOnLeave()
		GameTooltip:Hide()
	end

	local function SetText(self, text)
		if (text:find("item:%d+")) then
			self.dragLinkType = "item"
			self.value = text
		elseif (strsub(text, 1, 6) == "macro:") then
			self.dragLinkType = "macro"
			self.value = text
		elseif (strsub(text, 1, 12) == "macroCustom:") then
			self.dragLinkType = "macroCustom"
			self.value = text
		elseif (text ~= "") then
			self.dragLinkType = "spell"
			self.value = text
		end
		self.dragLinkIcon:SetTexture(DragLinkGetTexture(self))
	end

	local function SetDisabled(self, disabled)
	end

	local spacerWidth = 5
	local function OnWidthSet(self, width)
		if (width > self.iconWidth + spacerWidth + 0.1) then
			self:SetWidth(self.iconWidth + spacerWidth)
		end
	end

	local function Constructor()
		local frame = CreateFrame("Button", nil, UIParent)
		local self = {}
		self.type = Type

		self.Release = Release
		self.Aquire = Aquire
		self.SetLabel = SetLabel
		self.SetText = SetText
		self.SetDisabled = SetDisabled
		self.UpdateValue = UpdateValue
		self.OnWidthSet = OnWidthSet

		self.frame = frame
		frame.obj = self

		frame:SetScript("OnDragStart", DragLinkOnDragStart)
		frame:SetScript("OnReceiveDrag", DragLinkOnReceiveDrag)
		frame:SetScript("OnClick", DragLinkOnClick)
		frame:SetScript("OnEnter", DragLinkOnEnter)
		frame:SetScript("OnLeave", DragLinkOnLeave)

		frame:EnableMouse()
		frame:RegisterForDrag("LeftButton")
		frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

		local dragLinkIcon = frame:CreateTexture(nil, "OVERLAY")
		if (not self.iconWidth) then
			self.iconWidth = 32
		end
		if (not self.iconHeight) then
			self.iconHeight = 32
		end
		dragLinkIcon:SetWidth(self.iconWidth)
		dragLinkIcon:SetHeight(self.iconHeight)
		dragLinkIcon:SetPoint("LEFT", frame, "LEFT", 0, 0)
		dragLinkIcon:SetTexture(DragLinkGetTexture(self))
		dragLinkIcon:SetTexCoord(0, 1, 0, 1)
		dragLinkIcon:Show()
		self.dragLinkIcon = dragLinkIcon

		frame:SetHeight(self.iconWidth)
		frame:SetWidth(self.iconHeight)

		local text = frame:CreateFontString(nil,"BACKGROUND","GameFontHighlight")
		text:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 10)
		text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 10)
		text:SetJustifyH("CENTER")
		text:SetJustifyV("TOP")
		text:SetHeight(18)
		self.text = text

		--Container Support
		--local content = CreateFrame("Frame",nil,frame)
		--self.content = content

		--AceGUI:RegisterAsContainer(self)
		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(Type, Constructor, Version)
end