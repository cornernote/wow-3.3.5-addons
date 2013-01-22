--------------------------------------------------------
--			Torment the Weak
--			Kritologist - Malorne

--Widget Event Handlers
local function TTWMouseDown(self, button)
	if (not (MageFever3_Options.Lock) ) then
			self:StartMoving();
			self.isMoving = true;
		end
end
local function TTWMouseUp(self, button)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
			MageFeverTTW_Options["X"] = self:GetLeft()
			MageFeverTTW_Options["Y"] =  self:GetTop()
		end
end
local function TTWOnHide(self)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
end
local function AddTTWClick(self)
	if not (self.ProcName == nil ) then
			for k,v in pairs(MF.MFttwoptionframes) do
				v.Text:SetTextColor(1,1,1,1)
			end
			
			MF.SelectedTTWspell = self.ProcName
			self.Text:SetTextColor(1,0,0,1)		
		end
end
local function TTWOnEvent(self,event,...)
	if (event == "UNIT_AURA") and ((arg1 == "player") or (arg1 == "target")) or event == "PLAYER_TARGET_CHANGED" then	
		--If the mage is specced for Torment of the Weak, check the target for each possible slow effect.
		if MF.TTWspecced then
			for k,v in pairs(MFTTWSpells) do
				local CheckTTW = UnitDebuff("target", k)
				if CheckTTW then
					MF.TTW = true
				end
			end
		end
		if MF.TTW then
			if MageFeverTTW_Options["Show"] then
				self:Show()
			end
		else
			self:Hide()
		end
		MF.TTW = false
	elseif (event == "PLAYER_TALENT_UPDATE") then 
		local TTWnameTalent, TTWiconPath, tier, TTWcolumn, TTWcurrentRank, TTWmaxRank, TTWisExceptional, TTWmeetsPrereq = GetTalentInfo(1, 14)
		if TTWcurrentRank > 0 then
			if TTWnameTalent == MF.TTWname then
				MF.TTWspecced = true
			end
		end	
	end
end

--Widget Creation
function MageFever_ToggleTTW(self)
	 MageFeverTTW_Options["Show"] = self:GetChecked()
end
function MageFeverTTWScale(self)
	if MF.MageFeverLoaded then
		MageFeverTTW_Options["Scale"] = self:GetValue()
		MF.MageFeverTTW_Frame:SetScale(self:GetValue())
	end
end
function AddTTWSpellFrame(k, v)
	local frame = CreateFrame("Frame", MF.MTTWFrameCount.."TTWOption", getglobal("TTWScrollerChildFrame"))
	frame:SetHeight(15)
	frame:SetWidth(300)
	frame:EnableMouse(true)
	frame:SetPoint("TOPLEFT", 0, MF.MTTWFrameCount * -16)
	
	frame.Number = MF.MTTWFrameCount
	frame.ProcName = k
	
	frame.Text = frame:CreateFontString(k.."TTWOptionText", "OVERLAY", frame)
	frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.Text:SetPoint("LEFT", 3, 0)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetText(k)
	
	frame:SetScript("OnMouseDown", AddTTWClick)
	MF.MTTWFrameCount = MF.MTTWFrameCount + 1
	return frame
end
function MageFever_CreateTTWframe()
	local backdrop = {bgFile = "Interface\\Glues\\LoadingBar\\Loading-BarBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,
	}
	MF.MageFeverTTW_Frame = CreateFrame("Frame", "MF.MageFeverTTW_Frame",  UIParent)
	MF.MageFeverTTW_Frame:SetPoint("TOPLEFT", MageFeverTTW_Options["X"], MageFeverTTW_Options["Y"])
	MF.MageFeverTTW_Frame:SetMovable(true)
	MF.MageFeverTTW_Frame:RegisterForDrag("RightButton")
	MF.MageFeverTTW_Frame:EnableMouse(true)
	MF.MageFeverTTW_Frame:SetClampedToScreen(true)
	MF.MageFeverTTW_Frame:SetFrameStrata("HIGH")	
	MF.MageFeverTTW_Frame:SetWidth(MageFeverTTW_Options["Width"])
	MF.MageFeverTTW_Frame:SetHeight(MageFeverTTW_Options["Height"])
	MF.MageFeverTTW_Frame:SetScale(MageFeverTTW_Options["Scale"])
	MF.MageFeverTTW_Frame:SetBackdrop(backdrop)
	MF.MageFeverTTW_Frame:SetBackdropColor(MageFeverTTW_Options["R"],MageFeverTTW_Options["G"],MageFeverTTW_Options["B"],MageFeverTTW_Options["A"])
	MF.MageFeverTTW_Frame:SetBackdropBorderColor(0,0,0,0)
		
	MF.MageFeverTTW_Frame.IconFrame = CreateFrame("Frame", "TTWIcon", MF.MageFeverTTW_Frame)
	MF.MageFeverTTW_Frame.IconFrame :SetHeight(MageFeverTTW_Options["Height"])
	MF.MageFeverTTW_Frame.IconFrame :SetWidth(MageFeverTTW_Options["Height"])
	MF.MageFeverTTW_Frame.IconFrame :SetAllPoints(MF.MageFeverTTW_Frame)
	MF.MageFeverTTW_Frame.IconFrame.Icon = MF.MageFeverTTW_Frame.IconFrame:CreateTexture()
	MF.MageFeverTTW_Frame.IconFrame.Icon:SetAllPoints(MF.MageFeverTTW_Frame.IconFrame)
	
	local _, icon = GetTalentInfo(1, 14)
	MF.MageFeverTTW_Frame.IconFrame.Icon:SetTexture(icon)
	
	MF.MageFeverTTW_Frame.DisplayText = MF.MageFeverTTW_Frame:CreateFontString("TTWProcText", "OVERLAY", MF.MageFeverTTW_Frame)
	MF.MageFeverTTW_Frame.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	MF.MageFeverTTW_Frame.DisplayText:SetPoint("LEFT", 10, 0)
	MF.MageFeverTTW_Frame.DisplayText:SetText("MF.TTW")
		
	MF.MageFeverTTW_Frame:Hide()
	MF.MageFeverTTW_Frame:RegisterEvent("UNIT_AURA")
	MF.MageFeverTTW_Frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	MF.MageFeverTTW_Frame:SetScript("OnEvent", TTWOnEvent)
	MF.MageFeverTTW_Frame:SetScript("OnMouseDown", TTWMouseDown)
	MF.MageFeverTTW_Frame:SetScript("OnMouseUp", TTWMouseUp)
	MF.MageFeverTTW_Frame:SetScript("OnHide", TTWOnHide)
end