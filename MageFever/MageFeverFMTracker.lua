-------------------------------------------------------------------------------
--			Focus Magic Tracker
--			Kritologist

--Widget Event Handlers
local function MageFeverFMMouseDown(self, button)
		self:StartMoving()
		self.IsMoving = true
end
local function MageFeverFMMouseUp(self, button)
		self:StopMovingOrSizing()
		self.IsMoving = false
end
local function MageFeverFMUpdate(self, elapsed)
		if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 and not (self.TargetName == "-") then
			local SSspell, rank, icon, count, debuffType, duration, expirationTime = UnitAura(self.TargetName, MF.FMname)
			if not (SSspell == nil)  then
				local expTime = expirationTime - GetTime()
				self.back.DisplayText:SetText(format("%.1f",(expTime / 60)) .. " - " ..self.TargetName)
				self.back:SetStatusBarColor(0,0,0.6,1)
				self.back:SetMinMaxValues(0, 30)
				self.back:SetValue(expTime / 60)
				if IsSpellInRange(MF.FMname) == 0 then
					self.back:SetStatusBarColor(self.RedVal,0,0,.3)
				end	
			else
				if self.RedVal > 1 then
					self.RedDelta = 0
				elseif self.RedVal < 0 then
					self.RedDelta = 1
				end
				if self.RedDelta == 0 then
					self.RedVal = self.RedVal - .1
				elseif self.RedDelta == 1 then
					self.RedVal = self.RedVal + .1
				end
				self.back:SetStatusBarColor(self.RedVal,0,0,1)
				self.back:SetMinMaxValues(0, 1)
				self.back:SetValue(1)
				if IsSpellInRange(MF.FMname) == 1 then
					self.back.DisplayText:SetText(self.TargetName .. " - Recast FM")
				else
					self.back:SetStatusBarColor(self.RedVal,0,0,.3)
					self.back.DisplayText:SetText(self.TargetName .. " - Out of range ")
				end		
			end	
		else
			if not InCombatLockdown() then
				self:Hide()
			end
		end
end
local function MageFeverDesignateFMTarget(self)
	
end
local function MageFeverFMOnEvent(self,event, ...)
	if event == "CHAT_MSG_ADDON" then
		if arg1 == "MAGEFEVER" then
			local message = arg2
			MF.MageFeverFMTrackerFrame.TargetSuggester = arg4
		
			MF.MageFeverFMTrackerFrame.SuggestedTarget = strsub(message, 2) 
			MageFeverFMTargetText:SetText(MF.MageFeverFMTrackerFrame.TargetSuggester .. " suggests " .. MF.MageFeverFMTrackerFrame.SuggestedTarget)
			MageFeverFMTargetFrame:Show()
		end
	elseif ((event == "UNIT_AURA") and (arg1 == "player") or (arg1 == "target")) or event == "PLAYER_TARGET_CHANGED" then	
		local FMname, FMrank, FMicon, FMcount, FMdebuffType, FMduration, FMexpirationTime, FMcaster = UnitAura("target", MF.FMname)
		local FMisMine = caster == "player"	
		if FMcaster == "player" and not InCombatLockdown() then
			self:SetAttribute("macrotext", "/target "..UnitName("target").. "\n/Cast Focus Magic")
			self.TargetName = UnitName("target")
			self:Show()
		end
	end		
end
function MageFeverAcceptFM()
	MF.MageFeverFMTrackerFrame.TargetName = MF.MageFeverFMTrackerFrame.SuggestedTarget
	MF.MageFeverFMTrackerFrame.back.DisplayText:SetText(MF.MageFeverFMTrackerFrame.TargetName)
	MF.MageFeverFMTrackerFrame:SetAttribute("macrotext", "/target "..MF.MageFeverFMTrackerFrame.TargetName.. "\n/Cast Focus Magic")
	SendChatMessage(UnitName("player").. " accepted " .. MF.MageFeverFMTrackerFrame.TargetName .. " as their FM target.", "WHISPER",nil , MF.MageFeverFMTrackerFrame.TargetSuggester)
	MageFeverFMTargetFrame:Hide()
	MF.MageFeverFMTrackerFrame:Show()
end

function MageFeverDenyFM()
	SendChatMessage(UnitName("player").. " denied " .. MF.MageFeverFMTrackerFrame.SuggestedTarget .. " as their FM target.", "WHISPER",nil , MF.MageFeverFMTrackerFrame.TargetSuggester)
	MageFeverFMTargetFrame:Hide()
end

function CreateFMTrackerFrame()
	local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,  left=2, right=2, top=2, bottom=2}
	
	MF.MageFeverFMTrackerFrame = CreateFrame("Button", "MageFeverFMTracker", UIParent, "SecureActionButtonTemplate")
	MF.MageFeverFMTrackerFrame:SetClampedToScreen(true)
	MF.MageFeverFMTrackerFrame:SetPoint("CENTER")
	MF.MageFeverFMTrackerFrame:SetFrameStrata("HIGH")
	MF.MageFeverFMTrackerFrame:SetWidth(165)
	MF.MageFeverFMTrackerFrame:SetHeight(20)
	MF.MageFeverFMTrackerFrame:EnableMouse(true)
	MF.MageFeverFMTrackerFrame:SetMovable(true)
	MF.MageFeverFMTrackerFrame:RegisterForDrag("RightButton")
	MF.MageFeverFMTrackerFrame:SetBackdrop(backdrop)
	MF.MageFeverFMTrackerFrame:SetBackdropColor(0,0,0,1)
	MF.MageFeverFMTrackerFrame:SetBackdropBorderColor(0,0,0,0)
	MF.MageFeverFMTrackerFrame:SetAttribute("type", "macro")
	
	MF.MageFeverFMTrackerFrame.TargetSuggester = "-"
	MF.MageFeverFMTrackerFrame.SuggestedTarget = "-"
	MF.MageFeverFMTrackerFrame.TargetName = "-"
	MF.MageFeverFMTrackerFrame.RedVal = 0
	MF.MageFeverFMTrackerFrame.RedDelta = 1
	
	MF.MageFeverFMTrackerFrame.IconFrame = CreateFrame("Frame", "FMIcon", MF.MageFeverFMTrackerFrame)
	MF.MageFeverFMTrackerFrame.IconFrame:SetHeight(20)
	MF.MageFeverFMTrackerFrame.IconFrame:SetWidth(20)
	MF.MageFeverFMTrackerFrame.IconFrame:SetPoint("TOPLEFT", -20, 0)
	MF.MageFeverFMTrackerFrame.IconFrame.Icon = MF.MageFeverFMTrackerFrame.IconFrame:CreateTexture()
	local _,_,icon = GetSpellInfo(MF.FMname)
	MF.MageFeverFMTrackerFrame.IconFrame.Icon:SetTexture(icon)
	MF.MageFeverFMTrackerFrame.IconFrame.Icon:SetAllPoints(MF.MageFeverFMTrackerFrame.IconFrame)
		
	MF.MageFeverFMTrackerFrame.back = CreateFrame("StatusBar", "MageFeverFMTimeStatus", MF.MageFeverFMTrackerFrame)
	MF.MageFeverFMTrackerFrame.back:SetAllPoints(MF.MageFeverFMTrackerFrame)
	MF.MageFeverFMTrackerFrame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", "OVERLAY")
	MF.MageFeverFMTrackerFrame.back:SetStatusBarColor(0,0,1,1)
	MF.MageFeverFMTrackerFrame.back:SetMinMaxValues(0, 1)
	MF.MageFeverFMTrackerFrame.back:SetValue(1)
	
	MF.MageFeverFMTrackerFrame.back.DisplayText = MF.MageFeverFMTrackerFrame.back:CreateFontString("MFFMTarget", "OVERLAY", MF.MageFeverFMTrackerFrame)
	MF.MageFeverFMTrackerFrame.back.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	MF.MageFeverFMTrackerFrame.back.DisplayText:SetJustifyH("LEFT")
	MF.MageFeverFMTrackerFrame.back.DisplayText:SetPoint("TOPLEFT", 5, -5)
	
	MF.MageFeverFMTrackerFrame:SetScript('OnMouseDown', MageFeverFMMouseDown)
	MF.MageFeverFMTrackerFrame:SetScript('OnMouseUp', MageFeverFMMouseUp)
	MF.MageFeverFMTrackerFrame:SetScript("OnUpdate", MageFeverFMUpdate)
	
	--Designate target button
	MF.MageFeverFMTrackerFrame.AddButton = CreateFrame("Button","MFDesignateTarget", MF.MageFeverFMTrackerFrame, "SecureActionButtonTemplate")
	MF.MageFeverFMTrackerFrame.AddButton:SetHeight(20)
	MF.MageFeverFMTrackerFrame.AddButton:SetWidth(20)
	MF.MageFeverFMTrackerFrame.AddButton:SetPoint("TOPLEFT", 165,0)
	MF.MageFeverFMTrackerFrame.AddButton:SetText("T")
	MF.MageFeverFMTrackerFrame.AddButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	MF.MageFeverFMTrackerFrame.AddButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	MF.MageFeverFMTrackerFrame.AddButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	MF.MageFeverFMTrackerFrame.AddButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	MF.MageFeverFMTrackerFrame.AddButton:SetNormalFontObject("GameFontNormal")
	MF.MageFeverFMTrackerFrame.AddButton.texture = MF.MageFeverFMTrackerFrame.AddButton:GetNormalTexture()
	MF.MageFeverFMTrackerFrame.AddButton.texture:SetTexCoord(0,.625,0,.6875)
	
	MF.MageFeverFMTrackerFrame:RegisterEvent("CHAT_MSG_ADDON")
	MF.MageFeverFMTrackerFrame:RegisterEvent("UNIT_AURA")
	MF.MageFeverFMTrackerFrame:SetScript("OnEvent", MageFeverFMOnEvent)
    MF.MageFeverFMTrackerFrame.AddButton:SetScript("OnClick", MageFeverDesignateFMTarget)
    
    MF.MageFeverFMTrackerFrame:Hide()
    if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local FMname, FMrank, FMicon, FMcount, FMdebuffType, FMduration, FMexpirationTime, FMcaster = UnitAura("raid"..i, MF.FMname)
			local FMisMine = caster == "player"
			if FMcaster == "player" and not InCombatLockdown() then
				MF.MageFeverFMTrackerFrame:SetAttribute("macrotext", "/target "..UnitName("target").. "\n/Cast Focus Magic")
				MF.MageFeverFMTrackerFrame.TargetName = UnitName("target")
				MF.MageFeverFMTrackerFrame:Show()
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local FMname, FMrank, FMicon, FMcount, FMdebuffType, FMduration, FMexpirationTime, FMcaster = UnitAura("party"..i, MF.FMname)
			local FMisMine = caster == "player"
			if FMcaster == "player" and not InCombatLockdown() then
				MF.MageFeverFMTrackerFrame:SetAttribute("macrotext", "/target "..UnitName("party"..i).. "\n/Cast Focus Magic")
				MF.MageFeverFMTrackerFrame.TargetName = UnitName("party"..i)
				MF.MageFeverFMTrackerFrame:Show()
			end
		end
	end
	
end


-------------------------------------------------------
--    FM Rotation
function PrintFMRotation()
	local PreviousMage = "-"
	local M = "-"
	local r = ""
	for i=1,GetNumRaidMembers()  do
		local n,_,_,_,c = GetRaidRosterInfo(i) 
		if c == "Mage" then
			if M == "-" then 
				M = n 
				r = n.."->"
				PreviousMage = M
			else
				--if not PreviousMage == UnitName("player") then
					--SendAddonMessage("MAGEFEVER", "fm"..n, "WHISPER", PreviousMage)
				--else
					--MF.MageFeverFMTrackerFrame:SetAttribute("macrotext", "/target "..n.. "\n/Cast Focus Magic")
					--MF.MageFeverFMTrackerFrame.TargetName = n
				--end
				
				r = r..n.."->" 
				PreviousMage = n
			end 
		end 
	end
	--if r ~= nil then
		--SendChatMessage("FM Rotation: "..r..M,"RAID")
	--end
end