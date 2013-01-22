--------------------------------------------------------
--			Mage Fever Living Bomb Tracker
--			Kritologist - Malorne

--Widget Event Handlers
local function AddTrackerClick(self)
	local TheTarget = UnitName("target")
		if not(TheTarget==nil) then
			local TheGUID = UnitGUID("target")
			local TrackerFrame = getglobal("LBTimeLeft"..TheGUID)
			   if MF.LBtrackerFrames[TheGUID] == nil then
				 MF.LBtracker = getglobal("MageFeverLBTracker")
				AddLBTracker(true, MF.LBtracker, TheGUID, TheTarget)
			end
		end
end
local function TrackerMouseDown(self)
		self:StartMoving()
		self.IsMoving = true
end
local function TrackerMouseUp(self)
		self:StopMovingOrSizing()
		self.IsMoving = false
end
local function RemoveTrackerClick(self, arg1)
	RemoveLBTracker(self.MyGUID,true)
end
local function TrackerOnUpdate(self, elapsed)
		if UnitIsDead(self.MyGUID) then
			RemoveLBTracker(self.MyGUID,false)
		elseif not (self.StartTimer == 0) then	
			local TimeStamp = GetTime();
			self.UpdateTimer = self.UpdateTimer + elapsed
			self.back:SetMinMaxValues(self.StartTimer, self.EndTimer)
			self.back:SetValue(self.EndTimer - self.UpdateTimer)
		end
		
		if (self.EndTimer - self.UpdateTimer) < self.back:GetMinMaxValues() then
			RemoveLBTracker(self.MyGUID,false)
		end
end
local function MageFeverLBTrackerEvent(self,event,...)
	if (event == "UNIT_AURA") and ((arg1 == "player") or (arg1 == "target"))  then
		local Debuffname, LBrank, LBicon, LBcount, LBdebuffType, LBduration, LBexpirationTime, caster = UnitDebuff("target", GetSpellInfo(55360))
		local LBisMine = caster == "player"
		if not (Debuffname == nil) then
			if LBisMine then
				MF.LB = true
				LBtimer = format("%.1f",-1*(GetTime()-LBexpirationTime))
				if MageFever3_Options.LBTrackerShowing then
					if not (MF.LBtrackerFrames[UnitGUID("target")]==nil) then
						if MF.LBtrackerFrames[UnitGUID("target")].UpdateTimer == 0 then
							MF.LBtrackerFrames[UnitGUID("target")].StartTimer = GetTime()
							MF.LBtrackerFrames[UnitGUID("target")].EndTimer = MF.LBtrackerFrames[UnitGUID("target")].StartTimer + LBtimer
						end
					end
				end
			end
		end
	elseif event == "COMBAT_LOG_EVENT" then
		 if arg2 ==  "UNIT_DIED" then
		 	if not (MF.LBtrackerFrames[arg6] == nil) then
				if MF.LBtrackerFrames[arg6].IsSecure then
					MF.LBtrackerFrames[arg6].back.DisplayText:SetText(MF.LBtrackerFrames[arg6].back.DisplayText:GetText().." DEAD")
					MF.LBtrackerFrames[arg6]:SetBackdropColor(0,0,0,.5)
				else
					RemoveLBTracker(arg6,false)
				end
			end
		 end
		 
		 if (arg3 == UnitGUID("player") and arg2 == "SPELL_AURA_REMOVED") then
			if (arg10 == MF.LBname ) then
				RemoveLBTracker(arg6,false)
			end
		end
		 if (arg3 == UnitGUID("player") and arg2 == "SPELL_AURA_APPLIED") then
			if MageFever3_Options.LBTrackerShowing and arg10 == MF.LBname then
				if not (MF.LBtrackerFrames[arg6]==nil) then
					if MF.LBtrackerFrames[arg6].UpdateTimer == 0 then
						MF.LBtrackerFrames[arg6].StartTimer = GetTime()
						MF.LBtrackerFrames[arg6].EndTimer = MF.LBtrackerFrames[arg6].StartTimer +12
					end
				else
					AddLBTracker(false, MF.LBtracker, arg6,arg7)
				end
			end	
		end
	elseif event == "PLAYER_TALENT_UPDATE" then
		local LBnameTalent, LBiconPath, tier, LBWcolumn, LBcurrentRank, LBmaxRank, LBisExceptional, LBmeetsPrereq = GetTalentInfo(2, 28)
		if LBcurrentRank > 0 then
			if LBnameTalent == MF.LBname then
				MF.LBspecced = true
				if MageFever3_Options.LBTrackerShowing then
					MF.LBtracker:Show()	
				else
					MF.LBtracker:Hide()
				end
			else
				MF.LBspecced = false
				MF.LBtracker:Hide()
			end
		else
			MF.LBspecced = false
			MF.LBtracker:Hide()
		end	
	end
end

--Widget Creation
function MageFever_ToggleLBGrowUp(self)
	 MageFever3_Options.LBGrowUp = self:GetChecked()
	 
end
function MageFever_ToggleLBTracker(self)
	 MageFever3_Options.LBTrackerShowing = self:GetChecked()
	 if MageFever3_Options.LBTrackerShowing then
		MF.LBtracker:Show()
	 else
		MF.LBtracker:Hide()
	 end
end
function CreateLBtrackerFrame()
	local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"}
		
	MF.LBtracker = CreateFrame("Frame", "MageFeverLBTracker", UIParent)
	MF.LBtracker:SetClampedToScreen(true)
	MF.LBtracker:SetFrameStrata("HIGH")
	MF.LBtracker:SetBackdrop(backdrop)
	MF.LBtracker:SetBackdropColor(0,0,0,1)
	MF.LBtracker:SetWidth(220)
	MF.LBtracker:SetHeight(20) 
	MF.LBtracker:SetPoint("CENTER",0,0)
	MF.LBtracker:EnableMouse(true)
	MF.LBtracker:SetMovable(true)
	MF.LBtracker:RegisterForDrag("RightButton")

	MF.LBtracker:SetScript('OnMouseDown', TrackerMouseDown)
	MF.LBtracker:SetScript('OnMouseUp', TrackerMouseUp)
	
	LBtrackertitle = MF.LBtracker:CreateFontString("LBtrackertitletext", "OVERLAY")
	LBtrackertitle:SetFont("Fonts\\FRIZQT__.TTF", 12)
	LBtrackertitle:SetJustifyH("LEFT")
	LBtrackertitle:SetText("Living Bomb Tracker")
	LBtrackertitle:SetPoint("TOPLEFT", 0, -4)

	MF.LBtracker.AddButton = CreateFrame("Button","LBTrackerAdd", MF.LBtracker)
	MF.LBtracker.AddButton:SetHeight(20)
	MF.LBtracker.AddButton:SetWidth(20)
	MF.LBtracker.AddButton:SetPoint("TOPLEFT", 200,0)
	MF.LBtracker.AddButton:SetText("+")
	MF.LBtracker.AddButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	MF.LBtracker.AddButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	MF.LBtracker.AddButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	MF.LBtracker.AddButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	MF.LBtracker.AddButton:SetNormalFontObject("GameFontNormal")
	MF.LBtracker.AddButton.texture = MF.LBtracker.AddButton:GetNormalTexture()
	MF.LBtracker.AddButton.texture:SetTexCoord(0,.625,0,.6875)
	
	MF.LBtracker:RegisterEvent("UNIT_AURA")
	MF.LBtracker:RegisterEvent("COMBAT_LOG_EVENT")
	MF.LBtracker:RegisterEvent("PLAYER_TALENT_UPDATE")
	MF.LBtracker:SetScript("OnEvent", MageFeverLBTrackerEvent)
    MF.LBtracker.AddButton:SetScript("OnClick", AddTrackerClick)
end
function AddLBTracker(Secure,TimeLeft,TheGUID,TheTarget)
	if Secure and  InCombatLockdown() then
		return
	end
	
		local TrackerFrame = getglobal("LBTimeLeft"..TheGUID)
		if MF.LBtrackerFrames[TheGUID] == nil then
			 MF.LBtracker = getglobal("MageFeverLBTracker")
			MF.LBtrackerFrames[TheGUID]=MF_CreateLBTrackerFrame(Secure, MF.LBtracker, TheGUID, TheTarget)
			MF.LBtrackerFrames[TheGUID]:Show()
		end
end
function RemoveLBTracker(TheGUID,RemoveSecure)
	if not (MF.LBtrackerFrames[TheGUID]==nil) then
		local FrameOrderNum = MF.LBtrackerFrames[TheGUID].OrderNum
		if MF.LBtrackerFrames[TheGUID].IsSecure then
			MF.LBtrackerFrames[TheGUID].StartTimer = 0
			MF.LBtrackerFrames[TheGUID].EndTimer = 0
			MF.LBtrackerFrames[TheGUID].UpdateTimer = 0
			MF.LBtrackerFrames[TheGUID].back:SetValue(0)
			if RemoveSecure and not (InCombatLockdown()) then
				MF.LBtrackerFrames[TheGUID]:Hide()
				MF.LBtrackerFrames[TheGUID] = nil
				MF.LBsecuretrackertotal = MF.LBsecuretrackertotal - 1
			end
		else
			MF.LBtrackerFrames[TheGUID].StartTimer = 0
			MF.LBtrackerFrames[TheGUID].EndTimer = 0
			MF.LBtrackerFrames[TheGUID].UpdateTimer = 0
			MF.LBtrackerFrames[TheGUID].back:SetValue(0)
			MF.LBtrackerFrames[TheGUID]:Hide()
			MF.LBtrackerFrames[TheGUID] = nil
			MF.LBtrackertotal = MF.LBtrackertotal - 1
			MageFeverRefreshTrackers(FrameOrderNum)
		end
	end
end
function MageFeverRefreshTrackers(OrderNum)
	for k,v in pairs(MF.LBtrackerFrames) do
		if v.OrderNum > OrderNum then
			v.OrderNum = v.OrderNum - 1
		end
		if MageFever3_Options.LBGrowUp then
			v:SetPoint("TOPLEFT", 0, v.OrderNum * 21)
		else
			v:SetPoint("TOPLEFT", 0, v.OrderNum * -21)
		end
	end
end
function MF_CreateLBTrackerFrame(Secure, Parent, TheGUID, TheTarget)	
	if Secure then
		MF.LBsecuretrackertotal = MF.LBsecuretrackertotal + 1
	else
		MF.LBtrackertotal = MF.LBtrackertotal + 1
	end
	
	local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 3, left=2, right=2, top=2, bottom=2}
	local frame = CreateFrame("Frame", "LBTimeLeft"..TheGUID, Parent)
	frame:SetFrameStrata("HIGH")
	
	if MageFever3_Options.LBGrowUp then
		frame:SetPoint("TOPLEFT", 0, (MF.LBtrackertotal + MF.LBsecuretrackertotal) * 21)
	else
		frame:SetPoint("TOPLEFT", 0, (MF.LBtrackertotal + MF.LBsecuretrackertotal) * -21)
	end	
	frame:SetWidth(220)
	frame:SetHeight(20)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(1,0,0,.5)
	frame:SetBackdropBorderColor(0,0,0)
	
	if Secure then
		frame.RemoveButton = CreateFrame("Button","LBTrackerRemove",frame)
		frame.RemoveButton.MyGUID = TheGUID
		frame.RemoveButton:SetHeight(20)
		frame.RemoveButton:SetWidth(20)
		frame.RemoveButton:SetPoint("TOPLEFT", -20,0)
		frame.RemoveButton:SetText("-")
		frame.RemoveButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
		frame.RemoveButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
		frame.RemoveButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
		frame.RemoveButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
		frame.RemoveButton:SetNormalFontObject("GameFontNormal")
		frame.RemoveButton.texture = frame.RemoveButton:GetNormalTexture()
		frame.RemoveButton.texture:SetTexCoord(0,.625,0,.6875)
		
		frame.RemoveButton:SetScript("OnClick", RemoveTrackerClick)
	end
    
	frame.MyGUID = TheGUID
	frame.StartTimer = 0
	frame.EndTimer = 0
	frame.UpdateTimer = 0
	frame.IsSecure = Secure
	frame.OrderNum = MF.LBtrackertotal + MF.LBsecuretrackertotal
	
	frame.back = CreateFrame("StatusBar", "LBTimeStatus", frame)
	frame.back:SetAllPoints(frame)
	frame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", "OVERLAY")
	frame.back:SetStatusBarColor(1,.3,0)
	frame.back:SetMinMaxValues(0, 1)
	frame.back:SetValue(0)
			
	frame.back.DisplayText = frame.back:CreateFontString("LBtrackerTargetText"..TheGUID, "OVERLAY", frame)
	frame.back.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.back.DisplayText:SetJustifyH("LEFT")
	frame.back.DisplayText:SetPoint("LEFT")
	frame.back.DisplayText:SetText(TheTarget)
	
	if Secure then
		frame.LBbutton = CreateFrame("Button", "MageFeverTestButton"..TheGUID, frame, "SecureActionButtonTemplate")
		frame.LBbutton:SetWidth(220)
		frame.LBbutton:SetHeight(20)
		frame.LBbutton:SetAttribute("type", "macro")
		frame.LBbutton:SetAttribute("macrotext", "/Target "..TheTarget.."\n/Cast Living Bomb\n/targetlasttarget")
		frame.LBbutton:SetPoint("TOPLEFT",0, 0)
		frame.LBbutton:SetAlpha(1)	
	end
	
	frame:SetScript("OnUpdate", TrackerOnUpdate)
	return frame
end
function MageFever_LBTrackerScale(self)
	if not (MF.LBtracker == nil) then
		MageFever3_Options.LBTrackerScale = self:GetValue()
		MF.LBtracker:SetScale(MageFever3_Options.LBTrackerScale)
	end	
end