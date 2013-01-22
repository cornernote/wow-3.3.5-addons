--------------------------------------------------------
--        Spellsteal Monitor
--		Kritologist - Malorne

--Widget Event Handlers
local function SSMonitorMouseDown(self)
	if not MageFever3_Options.Lock then
		self:StartMoving()
		self.IsMoving = true
	end
end
local function SSMonitorMouseUp(self)
		self:StopMovingOrSizing()
		self.IsMoving = false
end
local function SSMonitorOnUpdate(self, elapsed)
			self.StolenFade  = self.StolenFade + elapsed
			if self.StolenFade > 3.9 then
				self:Hide()
				self.StolenFade = 0
			else
				self.StolenText:SetText(self.StolenSpell)
				self.StolenText:SetTextColor(1,1,1, 1-(self.StolenFade/4))
				self:SetBackdropColor(1,0,0, 1-(self.StolenFade/4))
			end
end
local function SSSubMonitorOnUpdate(self, elapsed)
	if self.SpellName == "DummySpell" then
			self:Hide()
		else
			local SSspell = UnitBuff("target", self.SpellName)
			if SSspell == nil then
				SSspell =  UnitDebuff("target", self.SpellName)
			end
			if SSspell == nil and not(MF.MageFeverSSActiveNames[self.SpellName] == nil) and MF.MageFeverSScount > 0 then
				self:Hide()
				MF.MageFeverSSActiveNames[self.SpellName] = nil
				self.SpellName = "DummySpell"
				MF.MageFeverSScount = MF.MageFeverSScount - 1
				MageFeverRefreshSSframes()
			else
				local expTime = self.ExpirationTime - GetTime()
				if expTime < 60 and expTime > 0 then
					self.back.TimerText:SetText(format("%.1f",(expTime)))
				else
					self.back.TimerText:SetText(" ")	
				end
				self.back.DisplayText:SetText(self.SpellName)
				self.back:SetValue((self.ExpirationTime - GetTime()))
				
			end
		end
end
local function SSMonitorOnEvent(self,event,...)
	if (event == "UNIT_AURA") and ((arg1 == "player") or (arg1 == "target")) or event == "PLAYER_TARGET_CHANGED" then	
		if MageFever3_Options.SSmonitorShowing then
				for i=1,40 do
					local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("target", i)
					--if isStealable then
					if isStealable and (MF.MageFeverSSActiveNames[name] == nil) then
					--if name then
						MF.MageFeverSScount = MF.MageFeverSScount + 1
						MageFeverSetSSframe(name, icon, duration, expirationTime)
						MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount]:Show()
						MF.MageFeverSSActiveNames[name] = 1	
					end
				end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then	
		if (arg3 == UnitGUID("player") and arg2 == "SPELL_STOLEN") then
			MF.MageFeverStolenFrame.StolenSpell = arg13
			MF.MageFeverStolenFrame:Show()
		end
	end
end

--Widget Creation
function MageFeverCreateSSMonitor()
	local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}

	MF.MageFeverSSMonitorFrame = CreateFrame("Button", "MageFeverSSMonitor", UIParent, "SecureActionButtonTemplate")
	MF.MageFeverSSMonitorFrame:SetClampedToScreen(true)
	MF.MageFeverSSMonitorFrame:SetFrameStrata("HIGH")
	MF.MageFeverSSMonitorFrame:SetBackdrop(backdrop)
	MF.MageFeverSSMonitorFrame:SetBackdropColor(0,0,0,1)
	MF.MageFeverSSMonitorFrame:SetWidth(180)
	MF.MageFeverSSMonitorFrame:SetHeight(15) 
	MF.MageFeverSSMonitorFrame:SetPoint("CENTER",0,0)
	MF.MageFeverSSMonitorFrame:EnableMouse(true)
	MF.MageFeverSSMonitorFrame:SetMovable(true)
	MF.MageFeverSSMonitorFrame:RegisterForDrag("RightButton")
	MF.MageFeverSSMonitorFrame:SetScale(MageFever3_Options.SSScale)
	MF.MageFeverSSMonitorFrame:SetAttribute("type", "macro")
	MF.MageFeverSSMonitorFrame:SetAttribute("macrotext", "/Cast Spellsteal")
	
	MF.SSMonitorCreated = true

	MF.MageFeverSSMonitorFrame:RegisterEvent("UNIT_AURA")
	MF.MageFeverSSMonitorFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	MF.MageFeverSSMonitorFrame:RegisterEvent("COMBAT_LOG_EVENT")
	MF.MageFeverSSMonitorFrame:SetScript("OnEvent", SSMonitorOnEvent)
	MF.MageFeverSSMonitorFrame:SetScript('OnMouseDown', SSMonitorMouseDown)
	MF.MageFeverSSMonitorFrame:SetScript('OnMouseUp', SSMonitorMouseUp)
	
	MageFeverSSMonitorTitle = MF.MageFeverSSMonitorFrame:CreateFontString("MFSSMonitortitletext", "OVERLAY")
	MageFeverSSMonitorTitle:SetFont("Fonts\\FRIZQT__.TTF", 12)
	MageFeverSSMonitorTitle:SetText("Spellsteal")
	MageFeverSSMonitorTitle:SetPoint("CENTER", 0, 0)
	
	MF.MageFeverStolenFrame = CreateFrame("Frame", "MageFeverSSstolen", MF.MageFeverSSMonitorFrame)
	MF.MageFeverStolenFrame:SetClampedToScreen(true)
	MF.MageFeverStolenFrame:SetFrameStrata("HIGH")
	MF.MageFeverStolenFrame:SetBackdrop(backdrop)
	MF.MageFeverStolenFrame:SetBackdropColor(1,0,0,1)
	MF.MageFeverStolenFrame:SetAllPoints()
	MF.MageFeverStolenFrame:SetScale(MageFever3_Options.SSScale)
	
	MF.MageFeverStolenFrame.StolenText = MF.MageFeverStolenFrame:CreateFontString("MFSSspelltext", "OVERLAY")
	MF.MageFeverStolenFrame.StolenText:SetFont("Fonts\\FRIZQT__.TTF", 12)
	MF.MageFeverStolenFrame.StolenText:SetText("Spellsteal")
	MF.MageFeverStolenFrame.StolenText:SetPoint("CENTER", 0, 0)
	MF.MageFeverStolenFrame:Hide()
	
	MF.MageFeverStolenFrame.StolenSpell = "None"
	MF.MageFeverStolenFrame.StolenFade = 0
	
	MF.MageFeverStolenFrame:SetScript('OnUpdate', SSMonitorOnUpdate)
	
	MageFeverAddSSsubframes()
	
	if MageFever3_Options.SSmonitorShowing then
		MF.MageFeverSSMonitorFrame:Show()
	else
		MF.MageFeverSSMonitorFrame:Hide()
	end
end
function MageFeverRepositionSSframes()
	local i = 1
	for k,v in pairs(MF.MageFeverSSActiveSpellFrames) do
		if MageFever3_Options.SSGrowUp then
			v:SetPoint("TOPLEFT", 15, i * 15)
		else
			v:SetPoint("TOPLEFT", 15, i * -15)
		end	
		i = i + 1
	end
end
function MageFeverRefreshSSframes()
	local SScount = 1
	for k,v in pairs(MF.MageFeverSSActiveSpellFrames) do
		if not(v.SpellName == "DummySpell") then
			v:Hide()
			MF.MageFeverSSActiveSpellFrames[SScount].SpellName = v.SpellName
			MF.MageFeverSSActiveSpellFrames[SScount].icon = v.icon
			MF.MageFeverSSActiveSpellFrames[SScount].IconFrame.Icon:SetTexture(v.icon)
			MF.MageFeverSSActiveSpellFrames[SScount].Duration = v.Duration
			MF.MageFeverSSActiveSpellFrames[SScount].ExpirationTime = v.ExpirationTime
			MF.MageFeverSSActiveSpellFrames[SScount].back:SetMinMaxValues(0, v.Duration)
			MF.MageFeverSSActiveSpellFrames[SScount].back:SetValue((v.ExpirationTime - GetTime()))
			MF.MageFeverSSActiveSpellFrames[SScount]:Show()
			
			if not (v.ID == MF.MageFeverSSActiveSpellFrames[SScount].ID) then
				v.SpellName = "DummySpell"
			end
				
			SScount = SScount + 1
		end
	end
end
function MageFeverSetSSframe(name, icon, duration, expirationTime)
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].SpellName = name
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].icon = icon
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].IconFrame.Icon:SetTexture(icon)
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].Duration = duration
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].ExpirationTime = expirationTime	
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].back:SetMinMaxValues(0, duration)
	MF.MageFeverSSActiveSpellFrames[MF.MageFeverSScount].back:SetValue(expirationTime - GetTime())
end
function MageFeverScaleSS(self)
	MageFever3_Options.SSScale = self:GetValue()
	if MF.SSMonitorCreated then
		MF.MageFeverSSMonitorFrame:SetScale(self:GetValue())
	end
	
end
function MageFever_ToggleSSmonitor(self)
	MageFever3_Options.SSmonitorShowing = self:GetChecked()
	if MF.SSMonitorCreated then
		if self:GetChecked() then
			MF.MageFeverSSMonitorFrame:Show()
		else
			MF.MageFeverSSMonitorFrame:Hide()
		end
	end
end
function MageFever_ToggleSSGrowUp(self)
	MageFever3_Options.SSGrowUp = self:GetChecked()
	if MF.SSMonitorCreated then
		MageFeverRepositionSSframes()
	end
end
function pairsByKeys (t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
end
function MageFeverAddSSsubframes()
		for i=1,20 do
		local backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,  left=2, right=2, top=2, bottom=2}
		local frame = CreateFrame("Frame", i.."MageFeverSSSpell", MF.MageFeverSSMonitorFrame)
		
		if MageFever3_Options.SSGrowUp then
			frame:SetPoint("TOPLEFT", 15, i * 15)
		else
			frame:SetPoint("TOPLEFT", 15, i * -15)
		end	
		
		frame:SetFrameStrata("HIGH")
		frame:SetWidth(165)
		frame:SetHeight(15)
		frame:SetBackdrop(backdrop)
		frame:SetBackdropColor(0,0,0,1)
		frame:SetBackdropBorderColor(0,0,0,0)
		
		frame.ID = i
		frame.SpellName = "DummySpell"
		frame.Duration = 1
		frame.ExpirationTime = 0
		frame.icon = "icon"
		
		frame.IconFrame = CreateFrame("Frame", i.."SSIcon", frame)
		frame.IconFrame :SetHeight(15)
		frame.IconFrame :SetWidth(15)
		frame.IconFrame :SetPoint("TOPLEFT", -15, 0)
		frame.IconFrame.Icon = frame.IconFrame:CreateTexture()
		frame.IconFrame.Icon:SetTexture(icon)
		frame.IconFrame.Icon:SetAllPoints(frame.IconFrame)
			
		frame.back = CreateFrame("StatusBar", i.."MageFeverSSTimeStatus", frame)
		frame.back:SetAllPoints(frame)
		frame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar", "OVERLAY")
		frame.back:SetStatusBarColor(0,0,1,1)
		frame.back:SetMinMaxValues(0, 1)
		frame.back:SetValue(1)
		
		frame.back.DisplayText = frame.back:CreateFontString(i.."SSMonitorSpellName", "OVERLAY", frame)
		frame.back.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
		frame.back.DisplayText:SetJustifyH("LEFT")
		frame.back.DisplayText:SetPoint("TOPLEFT", 5, 0)
		
		frame.back.TimerText = frame.back:CreateFontString(i.."SSMonitorSpellTime", "OVERLAY", frame)
		frame.back.TimerText:SetFont("Fonts\\FRIZQT__.TTF", 10)
		frame.back.TimerText:SetJustifyH("RIGHT")
		frame.back.TimerText:SetPoint("TOPRIGHT", 0, 0)
		
		frame:SetScript("OnUpdate", SSSubMonitorOnUpdate)
		
		MF.MageFeverSSActiveSpellFrames[i]= frame
	end
end