--------------------------------------------------------
--			Mage Fever Proc Frames

--Widget Event Handlers
local function MageFeverProcOnUpdate(self, elapsed)
	local Buffname, rank, icon, count, debuffType, duration, expirationTime, caster
			local isMine = caster == "player"
			
		if self.ProcName == MF.FPname then

		else
			if MFgetvalue("BuffType", self.Info) == "Cooldown" then
				local start, duration, enabled = GetSpellCooldown(k)
				local _,_,icon = GetSpellInfo(k)
				if duration <= 0 then 
					start, duration, enabled = GetItemCooldown(k) 
					_,_,icon = GetItemIcon(k)
				end
				if duration > 0 then
					self.IconFrame.Icon:SetTexture(icon)
					self.Timer = format("%.1f",-10*(duration))
					self.back:SetMinMaxValues(0, self.TotalTime)
					self.back:SetValue(self.Timer)
					self.SparkFrame.Spark:SetPoint("TOPLEFT", (self.Timer / self.TotalTime) * self:GetWidth(), self:GetHeight() / 2) 
					self.back.TimerText:SetText(format("%.1f",self.Timer / 10))
					self.back.DisplayText:SetText(self.ProcName)
				else
					self.Active = false
					self:Hide()
				end
			else
				if MFgetvalue("BuffType", self.Info) == "Debuff" then
					Buffname, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(MFgetvalue("Unit", self.Info), self.ProcName)
				elseif MFgetvalue("BuffType", self.Info) == "Buff" then
					Buffname, rank, icon, count, debuffType, duration, expirationTime, caster = UnitBuff(MFgetvalue("Unit", self.Info), self.ProcName)
				end
				if MFgetvalue("Icon", self.Info) == 1 then
					self.IconFrame:Show()
					self.IconFrame.Icon:SetTexture(icon)
				else
					self.IconFrame:Hide()
				end
				
				if not (Buffname == nil) then
					self.Timer = format("%.1f",-10*(GetTime()-expirationTime))
					if not (count == nil) then
						self.Active = true
						self.back:SetMinMaxValues(0, self.TotalTime)
						if MFgetvalue("Timer", self.Info) == 1 then
							self.back:SetValue(self.Timer)
							self.SparkFrame.Spark:SetPoint("TOPLEFT", (self.Timer / self.TotalTime) * self:GetWidth() - 16, self:GetHeight() / 2) 
						else
							self:SetBackdropColor(MFgetvalue("R", self.Info),MFgetvalue("G", self.Info),MFgetvalue("B", self.Info),MFgetvalue("A", self.Info))
							self.back:SetValue(0)
						end
						local ProcText
						if  MFgetvalue("Timer", self.Info) == 1 then
							ProcText =  format("%.1f",self.Timer / 10)
						else
							ProcText = " "
						end
						self.back.TimerText:SetText(ProcText)
						
						local DisplayText = self.ProcName
						if MFgetvalue("Count", self.Info) == 1 then
							DisplayText = self.ProcName.." x "..count
						end
						self.back.DisplayText:SetText(DisplayText)
					end
				else
					if not (MFgetvalue("Show", self.Info) == 1 ) then
						self.Active = false
						self:Hide()
					end
				end
			end	
			end			
end
local function MageFeverProcMouseDown(self, button)
	if (not (MageFever3_Options.Lock) ) then
				self:StartMoving();
				self.isMoving = true;
			end
end
local function MageFeverProcMouseUp(self, button)
	if ( self.isMoving ) then
				self:StopMovingOrSizing();
				self.isMoving = false;
				MFsetvalue("X", MageFeverProcNames[self.ProcName], self:GetLeft())
				MFsetvalue("Y", MageFeverProcNames[self.ProcName], self:GetTop())
			end
end
local function MageFeverProcOnHide(self)
	if ( self.isMoving ) then
				self:StopMovingOrSizing();
				self.isMoving = false;
			end
end
local function MageFeverProcOnEvent(self,event,...)
	if (event == "UNIT_AURA") and ((arg1 == "player") or (arg1 == "target")) or event == "PLAYER_TARGET_CHANGED" then
			local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable
			local isMine
			if MFgetvalue("BuffType", self.Info) == "Debuff" then
				name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff(MFgetvalue("Unit", self.Info), self.ProcName)
				isMine = caster == "player"
			else
				name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(MFgetvalue("Unit", self.Info), self.ProcName)
				isMine = caster == "player"
			end
			
			if not (name == nil) and (MFgetvalue("Show", self.Info) == 1) then
				if (MFgetvalue("Mine", self.Info) == 1) then
					if (isMine) then
						if not self.Active then self.TotalTime = -10*(GetTime()-expirationTime) end
						self.Timer = format("%.1f",-10*(GetTime()-expirationTime))
						self:Show()
					else
						self:Hide()
					end
				else
					if not self.Active then self.TotalTime = -10*(GetTime()-expirationTime) end
					self.Timer = format("%.1f",-10*(GetTime()-expirationTime))
					self:Show()
				end
			else
				if not (MageFever3_Options.Showing ) then
					self:Hide()
				end
			end
		return
	end
	if (event == "UNIT_HEALTH") and (arg1 == "player") then
			--local nameTalent, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 22)
			--if currentRank >= 1 then
				if UnitHealth("player") / UnitHealthMax("player") < .35 then
					--if nameTalent == MF.FPname then
						self:Show()
					--end
				else
					self:Hide()
				end
			--end
	end
end
function MFRefreshProcFrames()
	for k,v in pairs(MF.MageFeverProcFrames) do
		 v:Hide()
		 MF.MageFeverProcFrames[k] = nil
	end	

	collectgarbage()

	for k,v in pairs(MageFeverProcNames) do
		 CreateNewProcFrame(k,v)
	end	
	
	for k,v in pairs(MF.MageFeverProcFrames) do
		 v:Show()
	end	
end
function CreateProcFrames()
	for k,v in pairs(MageFeverProcNames) do
		 CreateNewProcFrame(k,v)
	end	
end
function CreateNewProcFrame(k,v)
		local ClassicWidth = 120
		local ClassicHeight = 50
		if k == MF.TTWname then
			ClassicWidth = 50
		end
		local backdrop
		if MageFever3_Options.ClassicFrames then
			backdrop = {bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
				insets = {
					left = 4,
					right = 4,
					top = 4,
					bottom = 4
				}
			}
		else
			backdrop = {bgFile = "Interface\\Glues\\LoadingBar\\Loading-BarBackground",
				edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,		
			}
		end
		
		local frame = CreateFrame("Frame", k.."Proc",  UIParent)
		frame:SetPoint("TOPLEFT", MFgetvalue("X", v), MFgetvalue("Y", v))
		frame:SetMovable(true)
		frame:RegisterForDrag("RightButton")
		frame:EnableMouse(true)
		frame:SetClampedToScreen(true)
		frame:SetFrameStrata("HIGH")	
		if MageFever3_Options.ClassicFrames then
			frame:SetWidth(ClassicWidth)
			frame:SetHeight(ClassicHeight)
			frame:SetScale(MFgetvalue("Scale", v))
			frame:SetBackdrop(backdrop)
			frame:SetBackdropColor(MFgetvalue("R", v),MFgetvalue("G", v),MFgetvalue("B", v),MFgetvalue("A", v))
			frame:SetBackdropBorderColor(1,1,1,.7)
			frame.BarWidth = ClassicWidth
		else
			frame:SetWidth(MFgetvalue("Width", v))
			frame:SetHeight(MFgetvalue("Height", v))
			frame:SetScale(MFgetvalue("Scale", v))
			frame:SetBackdrop(backdrop)
			frame:SetBackdropColor(MFgetvalue("R", v),MFgetvalue("G", v),MFgetvalue("B", v),MFgetvalue("A", v))
			frame:SetBackdropBorderColor(0,0,0,0)
			frame.BarWidth = MFgetvalue("Width", v)
		end
		
		frame.Active = false
		frame.TotalTime = 0
		frame.Info = v
		frame.Timer = 0
		frame.ProcName = k
		frame.Debug = false
		frame.SparkPosition = 0
		
		frame.back = CreateFrame("StatusBar", k.."Status", frame)
		frame.back:SetPoint("CENTER")
		if MageFever3_Options.ClassicFrames then
			frame.back:SetPoint("TOPLEFT", 5, -5)
			frame.back:SetPoint("BOTTOMRIGHT", -5, 5)
			frame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
			frame.back:SetStatusBarColor(MFgetvalue("R", v),MFgetvalue("G", v),MFgetvalue("B", v),MFgetvalue("A", v))
			frame.back:SetMinMaxValues(0, ClassicWidth)
			frame.back:SetValue(ClassicWidth)
		else
			frame.back:SetWidth(MFgetvalue("Width", v))
			frame.back:SetHeight(MFgetvalue("Height", v)) --*.49 for frame with background border
			frame.back:SetStatusBarTexture("Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar")
			frame.back:SetStatusBarColor(MFgetvalue("R", v),MFgetvalue("G", v),MFgetvalue("B", v),MFgetvalue("A", v))
			frame.back:SetMinMaxValues(0, 120)
			frame.back:SetValue(120)
		end	
		
		frame.IconFrame = CreateFrame("Frame", k.."Icon", frame)
		frame.IconFrame :SetHeight(MFgetvalue("Height", v))
		frame.IconFrame :SetWidth(MFgetvalue("Height", v))
		frame.IconFrame :SetPoint("TOPLEFT", -MFgetvalue("Height", v),0)
		frame.IconFrame.Icon = frame.IconFrame:CreateTexture()
		if MFgetvalue("Icon", v) == 1 and not MageFever3_Options.ClassicFrames then
			frame.IconFrame.Icon:SetAllPoints(frame.IconFrame)
		end
					
			frame.SparkFrame = CreateFrame("Frame", k.."Spark", frame)
			frame.SparkFrame:SetAllPoints(frame)
			frame.SparkFrame.Spark = frame.SparkFrame:CreateTexture(k.."SparkTexture", "ARTWORK")
			frame.SparkFrame.Spark:SetPoint("TOPLEFT", 0, 0)
			frame.SparkFrame.Spark:SetAlpha(.5)
			frame.SparkFrame.Spark:SetHeight(frame:GetHeight() * 2) -- * 2 for frame with background border
			if not MageFever3_Options.ClassicFrames and k ~= MF.FPname then
				frame.SparkFrame.Spark:SetTexture("Interface\\Glues\\LoadingBar\\UI-LoadingBar-Spark", "ARTWORK")
			end
			
		frame.back.DisplayText = frame.back:CreateFontString(k.."ProcText", "OVERLAY", frame.back)
		frame.back.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 10)
		
		frame.back.DisplayText:SetText(k)
		
		frame.back.TimerText = frame.back:CreateFontString(k.."ProcTimer", "OVERLAY", frame.back)
		frame.back.TimerText:SetFont("Fonts\\FRIZQT__.TTF", 10)
		
		if k ~= MF.FPname then frame.back.TimerText:SetText(frame.Timer) end
		
		if MageFever3_Options.ClassicFrames then
			frame.back.DisplayText:SetPoint("TOP", 0, -5)
			frame.back.TimerText:SetPoint("BOTTOM", 0, 5)
		else
			frame.back.DisplayText:SetPoint("LEFT", 10, 0)
			frame.back.TimerText:SetPoint("RIGHT", -5, 0)
		end	
		
		frame:Hide()		
	
		
		if k == MF.FPname then
			frame:RegisterEvent("UNIT_HEALTH")
		else
			frame:RegisterEvent("UNIT_AURA")
			frame:RegisterEvent("PLAYER_TARGET_CHANGED")
			frame:SetScript("OnUpdate", MageFeverProcOnUpdate)		
		end
		frame:SetScript("OnEvent", MageFeverProcOnEvent)
		frame:SetScript("OnMouseDown", MageFeverProcMouseDown)
		frame:SetScript("OnMouseUp", MageFeverProcMouseUp)
		frame:SetScript("OnHide", MageFeverProcOnHide)
		
		MF.MageFeverProcFrames[k] = frame
end
function MFgetvalue(Value, Proc)
--  0   1    2   3          4                     5              6           7           8         9        10      11      12    13   14
--{ R , G , B , A , Buff/Debuff , Target/Player , Timer , Counter , Height , Width , Scale, Show,    X,   Y, Mine}
	if Value == "R" then --print("R"..Proc[1])
		return Proc[1]
	elseif Value == "G" then --print("G "..Proc[2])
		return Proc[2]
	elseif Value == "B" then --print("B "..Proc[3])
		return Proc[3]
	elseif Value == "A" then --print("A "..Proc[4])
		return Proc[4]
	elseif Value == "BuffType" then --print("BuffType "..Proc[5])
		return Proc[5]
	elseif Value == "Unit" then --print("Unit "..Proc[6])
		return Proc[6]
	elseif Value == "Timer" then --print("Timer "..Proc[7])
		return Proc[7]
	elseif Value == "Count" then --print("Count "..Proc[8])
		return Proc[8]
	elseif Value == "Height" then --print("Height "..Proc[9])
		return Proc[9]
	elseif Value == "Width" then --print("Width "..Proc[10])
		return Proc[10]
	elseif Value == "Scale" then --print("Scale "..Proc[11])
		return Proc[11]
	elseif Value == "Show" then --print("Show "..Proc[12])
		return Proc[12]
	elseif Value == "X" then --print("X "..Proc[13])
		return Proc[13]
	elseif Value == "Y" then --print("Y"..Proc[14])
		return Proc[14]
	elseif Value == "Mine" then
		if Proc[15] == nil then
			return 0
		else
			return Proc[15]
		end
	elseif Value == "Icon" then
		if Proc[16] == nil then
			return 0
		else
			return Proc[16]
		end
	end
end
function MFsetvalue(Value, Proc, NewValue)
--  0   1    2   3          4                     5              6           7           8         9        10      11      12    13
--{ R , G , B , A , Buff/Debuff , Target/Player , Timer , Counter , Height , Width , Scale, Show,    X,   Y}
	if Value == "R" then
		Proc[1] = NewValue
	elseif Value == "G" then
		 Proc[2] = NewValue
	elseif Value == "B" then
		 Proc[3] = NewValue
	elseif Value == "A" then
		 Proc[4] = NewValue
	elseif Value == "BuffType" then
		 Proc[5] = NewValue
	elseif Value == "Unit" then
		 Proc[6] = NewValue
	elseif Value == "Timer" then
		 if NewValue then
			Proc[7] = 1
		else
			Proc[7] = 0
		end
	elseif Value == "Count" then
		if NewValue then
			Proc[8] = 1
		else
			Proc[8] = 0
		end
	elseif Value == "Height" then
		 Proc[9] = NewValue
	elseif Value == "Width" then
		 Proc[10] = NewValue
	elseif Value == "Scale" then
		 Proc[11] = NewValue
	elseif Value == "Show" then
		if NewValue then
			Proc[12] = 1
		else
			Proc[12] = 0
		end
	elseif Value == "X" then
		 Proc[13] = NewValue
	elseif Value == "Y" then
		 Proc[14] = 0-NewValue
	elseif Value == "Mine" then
		if NewValue then
			Proc[15] = 1
		else
			Proc[15] = 0
		end
	elseif Value == "Icon" then
		if NewValue then
			Proc[16] = 1
		else
			Proc[16] = 0
		end
	end
end