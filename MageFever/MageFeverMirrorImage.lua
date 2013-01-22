--------------------------------------------------------
--				Mage Fever Mirror Image
--				Kritologist - Malorne

--Widget Event Handlers
local function MirrorImageOnUpdate(self, elapsed)
		if not MageFever3_Options.Showing then
			MF.MIupdatetime = MF.MIupdatetime + elapsed
			self.back:SetMinMaxValues(MF.MIcasttime, MF.MIcasttime + 30)
			self.back:SetValue((MF.MIcasttime + 30) - MF.MIupdatetime)
			self.SparkFrame.Spark:SetPoint("TOPLEFT", (self.back:GetValue() / (MF.MIcasttime + 30)) * self.back:GetWidth(), self:GetHeight() / 2) 
			self.back.TimerText:SetText(format("%.1f",(MF.MIcasttime + 30)-(MF.MIcasttime + MF.MIupdatetime)))
		end
end
local function MirrorImageMouseDown(self, button)
		if (not (MageFever3_Options.Lock) ) then
			self:StartMoving();
			self.isMoving = true;
		end
end
local function MirrorImageMouseUp(self, button)
	if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
			MageFeverMI_Options["X"] = self:GetLeft()
			MageFeverMI_Options["Y"] =  -self:GetTop()
		end
end
local function MirrorImageOnHide(self)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
end

local function MirrorImageOnEvent(self,event,...)
	if (event == "COMBAT_LOG_EVENT") then	
			if (arg3 == UnitGUID("player") and (arg2 == "SPELL_AURA_APPLIED" or arg2 == "SPELL_AURA_REFRESH")) then
			if arg10 == MF.MIname and MageFeverMI_Options["Show"] then
				MF.MIcasttime = GetTime()
				MF.MIupdatetime = 0
				self:Show()
			end
		end
		if (arg3 == UnitGUID("player") and arg2 == "SPELL_AURA_REMOVED") then
			if arg10 == MF.MIname then
				self:Hide()
			end
		end
	end
end

--Widget Creation
function MageFever_CreateMIframe()
	local backdrop = {bgFile = "Interface\\Glues\\LoadingBar\\Loading-BarBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,
	}
	MF.MageFeverMI_Frame = CreateFrame("Frame", "MF.MageFeverMI_Frame",  UIParent)
	MF.MageFeverMI_Frame:SetPoint("TOPLEFT", MageFeverMI_Options["X"], MageFeverMI_Options["Y"])
	MF.MageFeverMI_Frame:SetMovable(true)
	MF.MageFeverMI_Frame:RegisterForDrag("RightButton")
	MF.MageFeverMI_Frame:EnableMouse(true)
	MF.MageFeverMI_Frame:SetClampedToScreen(true)
	MF.MageFeverMI_Frame:SetFrameStrata("HIGH")	
	MF.MageFeverMI_Frame:SetWidth(MageFeverMI_Options["Width"])
	MF.MageFeverMI_Frame:SetHeight(MageFeverMI_Options["Height"])
	MF.MageFeverMI_Frame:SetScale(MageFeverMI_Options["Scale"])
	MF.MageFeverMI_Frame:SetBackdrop(backdrop)
	MF.MageFeverMI_Frame:SetBackdropColor(MageFeverMI_Options["R"],MageFeverMI_Options["G"],MageFeverMI_Options["B"],MageFeverMI_Options["A"])
	MF.MageFeverMI_Frame:SetBackdropBorderColor(0,0,0, 0)
		
	MF.MageFeverMI_Frame.BarWidth = MageFeverMI_Options["Width"]
	MF.MageFeverMI_Frame.SparkPosition = 0
		
	MF.MageFeverMI_Frame.IconFrame = CreateFrame("Frame", "MIIcon", MF.MageFeverMI_Frame)
	MF.MageFeverMI_Frame.IconFrame :SetHeight(MageFeverMI_Options["Height"])
	MF.MageFeverMI_Frame.IconFrame :SetWidth(MageFeverMI_Options["Height"])
	MF.MageFeverMI_Frame.IconFrame :SetPoint("TOPLEFT", -MageFeverMI_Options["Height"],0)
	MF.MageFeverMI_Frame.IconFrame.Icon = MF.MageFeverMI_Frame.IconFrame:CreateTexture()
	MF.MageFeverMI_Frame.IconFrame.Icon:SetAllPoints(MF.MageFeverMI_Frame.IconFrame)
	
	local _,_,icon = GetSpellInfo(55342)
	MF.MageFeverMI_Frame.IconFrame.Icon:SetTexture(icon)
		
	MF.MageFeverMI_Frame.back = CreateFrame("StatusBar", "MIStatus", MF.MageFeverMI_Frame)
	MF.MageFeverMI_Frame.back:SetPoint("CENTER")
	MF.MageFeverMI_Frame.back:SetWidth(MageFeverMI_Options["Width"])
	MF.MageFeverMI_Frame.back:SetHeight(MageFeverMI_Options["Height"]) 
	MF.MageFeverMI_Frame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
	MF.MageFeverMI_Frame.back:SetStatusBarColor(MageFeverMI_Options["R"],MageFeverMI_Options["G"],MageFeverMI_Options["B"],MageFeverMI_Options["A"])
	MF.MageFeverMI_Frame.back:SetMinMaxValues(0, 120)
	MF.MageFeverMI_Frame.back:SetValue(120)
		
	MF.MageFeverMI_Frame.SparkFrame = CreateFrame("Frame", "MISpark", MF.MageFeverMI_Frame)
	MF.MageFeverMI_Frame.SparkFrame:SetAllPoints(MF.MageFeverMI_Frame)
	MF.MageFeverMI_Frame.SparkFrame.Spark = MF.MageFeverMI_Frame.SparkFrame:CreateTexture("MISparkTexture", "ARTWORK")
	MF.MageFeverMI_Frame.SparkFrame.Spark:SetPoint("TOPLEFT", 0, 0)
	MF.MageFeverMI_Frame.SparkFrame.Spark:SetAlpha(.5)
	MF.MageFeverMI_Frame.SparkFrame.Spark:SetHeight(MF.MageFeverMI_Frame:GetHeight() * 2) 

				
	MF.MageFeverMI_Frame.back.DisplayText = MF.MageFeverMI_Frame.back:CreateFontString("MIProcText", "OVERLAY", MF.MageFeverMI_Frame.back)
	MF.MageFeverMI_Frame.back.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	MF.MageFeverMI_Frame.back.DisplayText:SetPoint("LEFT", 10, 0)
	MF.MageFeverMI_Frame.back.DisplayText:SetText(MF.MIname)
		
	MF.MageFeverMI_Frame:Hide()
	
	MF.MageFeverMI_Frame.back.TimerText = MF.MageFeverMI_Frame.back:CreateFontString("MIProcTimer", "OVERLAY", MF.MageFeverMI_Frame.back)
	MF.MageFeverMI_Frame.back.TimerText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	MF.MageFeverMI_Frame.back.TimerText:SetPoint("RIGHT", -5, 0)
	MF.MageFeverMI_Frame.back.TimerText:SetText("0")
	
	MF.MageFeverMI_Frame:RegisterEvent("COMBAT_LOG_EVENT")
	MF.MageFeverMI_Frame:SetScript("OnEvent", MirrorImageOnEvent)
	MF.MageFeverMI_Frame:SetScript("OnUpdate", MirrorImageOnUpdate)	
	MF.MageFeverMI_Frame:SetScript("OnMouseDown", MirrorImageMouseDown)
	MF.MageFeverMI_Frame:SetScript("OnMouseUp", MirrorImageMouseUp)	
	MF.MageFeverMI_Frame:SetScript("OnHide", MirrorImageOnHide)
end
function MageFever_ToggleMI(self)
	 MageFeverMI_Options["Show"] = self:GetChecked()
end
function MageFeverMIWidth(self)
	if MF.MageFeverLoaded then
		MF.MageFeverMI_Frame:SetWidth(self:GetValue())
		MageFeverMI_Options["Width"] = self:GetValue()
		MF.MageFeverMI_Frame.back:SetWidth(self:GetValue())
		MF.MageFeverMI_Frame.SparkFrame.Spark:SetPoint("TOPLEFT", self:GetValue() - 16, MF.MageFeverMI_Frame:GetHeight() / 2 )
	end
end
function MageFeverMIHeight(self)
	if MF.MageFeverLoaded then
	
		MF.MageFeverMI_Frame:SetHeight(self:GetValue())
		MageFeverMI_Options["Height"] = self:GetValue()
		MF.MageFeverMI_Frame.IconFrame:SetHeight(self:GetValue())
		MF.MageFeverMI_Frame.IconFrame:SetWidth(self:GetValue())
		MF.MageFeverMI_Frame.back:SetHeight(self:GetValue()) -- *.49 for frame with background border
		MF.MageFeverMI_Frame.SparkFrame.Spark:SetHeight(self:GetValue()* 2)
		MF.MageFeverMI_Frame.SparkFrame.Spark:SetPoint("TOPLEFT", MF.MageFeverMI_Frame:GetWidth() - 16 , self:GetValue() / 2 )
	end
end
function MageFeverMIScale(self)
		if MF.MageFeverLoaded then
			MageFeverMI_Options["Scale"] = self:GetValue()
			MF.MageFeverMI_Frame:SetScale(self:GetValue())
		end
end