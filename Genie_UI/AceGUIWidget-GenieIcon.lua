--[[////////////////////////////////////////////
Icon Widget
////////////////////////////////////////////--]]
local Type, Version = "GenieIcon", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs, print = select, pairs, print

-- WoW APIs
local CreateFrame, UIParent, GetBuildInfo = CreateFrame, UIParent, GetBuildInfo

--[[////////////////////////////////////////////
Scripts
////////////////////////////////////////////--]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Button_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--[[////////////////////////////////////////////
Methods
////////////////////////////////////////////--]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(110)
		self:SetWidth(110)
		self:SetLabel()
		self:SetImage(nil)
		self:SetImageSize(64, 64)
		self:SetDisabled(false)     
	end,

	-- ["OnRelease"] = nil,

	["SetLabel"] = function(self, text)
		if text and text ~= "" then
            if self.quality then
                text = select(4, GetItemQualityColor(self.quality)) .. text .. '|r'
            end
			self.label:Show()
			self.label:SetText(text)
			self:SetHeight(self.image:GetHeight() + 25)
		else
			self.label:Hide()
			self:SetHeight(self.image:GetHeight() + 10)
		end
	end,

	["SetImage"] = function(self, path, ...)
		local image = self.image
		image:SetTexture(path)
		
		if image:GetTexture() then
			local n = select("#", ...)
			if n == 4 or n == 8 then
				image:SetTexCoord(...)
			else
				image:SetTexCoord(0, 1, 0, 1)
			end
		end
	end,

	["SetImageSize"] = function(self, width, height)
        self.image:SetWidth(width)
		self.image:SetHeight(height)

		self.border:SetWidth(width + 28)
        self.border:SetHeight(height + 28)
        
		if self.label:IsShown() then
			self:SetHeight(height + 26)
            self:SetWidth(width + 16)
		else
            self:SetWidth(width + 6)
            self:SetHeight(height + 6)
		end
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if disabled then
			self.frame:Disable()
			self.label:SetTextColor(0.5, 0.5, 0.5)
			self.image:SetVertexColor(0.5, 0.5, 0.5, 0.5)
		else
			self.frame:Enable()
			self.label:SetTextColor(1, 1, 1)
			self.image:SetVertexColor(1, 1, 1)
		end
	end,
    
    ["GetName"] = function(self)
        return self.frame:GetName()
    end,
    
    ["SetQuality"] = function(self, quality)
        if quality then 
            self.quality = quality 
            self:SetGlow(self.quality)
            self:SetLabel(self.label:GetText())
        end
    end,
    
    ["SetMinQualityForGlow"] = function(self, quality)
        self.minQuality = tonumber(quality)
    end,
    
    ["SetGlow"] = function(self, quality, alpha)
        if self.minQuality and quality > self.minQuality then
            local r, g ,b = GetItemQualityColor(quality)
            self.border:SetVertexColor(r, g, b, alpha or self.border:GetAlpha())
            self.border:Show()
        else
            self.border:Hide()
        end
    end,
}

--[[////////////////////////////////////////////
Constructor
////////////////////////////////////////////--]]
local function Constructor()
    local name = "AceGUI30GenieIcon" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnClick", Button_OnClick)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("BOTTOMLEFT")
	label:SetPoint("BOTTOMRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetHeight(18)

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(image)
	highlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
	highlight:SetTexCoord(0, 1, 0.23, 0.77)
	highlight:SetBlendMode("ADD")
    
    local border = frame:CreateTexture(nil, 'BORDER')
	border:SetWidth(94)
	border:SetHeight(94)
	border:SetPoint('CENTER', image)
	border:SetTexture([[Interface\Buttons\UI-ActionButton-Border]])
	border:SetBlendMode('ADD')
    border:SetAlpha(0.7)
    border:Hide()

    --TODO: ?TEXTURE_ITEM_QUEST_BORDER

	local widget = {
		label = label,
		image = image,
        border = border,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
