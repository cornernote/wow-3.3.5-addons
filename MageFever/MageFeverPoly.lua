--------------------------------------------------------
--			Polymorph Monitor
--			Kritologist - Malorne

--Widget Event Handlers
local function MageFeverPolyUpdate(self, elapsed)
		local PolyName,_,_,_,_,PolyDuration,PolExpTime = UnitAura("focus", "Polymorph")
		if not (PolyName == nil) then
			self.IconFrame.DisplayText:SetText(format(".%0f", (PolExpTime - GetTime())))
		else
			self:Hide()
		end
end

local function MageFeverPolyMouseDown(self, button)
		if (not (MageFever3_Options.Lock) ) then
			self:StartMoving();
			self.isMoving = true;
		end
end

local function MageFeverPolyMouseUp(self, button)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
end

local function MageFeverPolyHide(self)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
end

function CreatePolyTracker()
	local backdrop = {bgFile = "Interface\\Glues\\LoadingBar\\Loading-BarBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,
	}
	MF.MageFeverPolyFrame = CreateFrame("Frame", "MFPolyWatcher",  UIParent)
	MF.MageFeverPolyFrame:SetPoint("TOPLEFT", 400, 400)
	MF.MageFeverPolyFrame:SetMovable(true)
	MF.MageFeverPolyFrame:RegisterForDrag("RightButton")
	MF.MageFeverPolyFrame:EnableMouse(true)
	MF.MageFeverPolyFrame:SetClampedToScreen(true)
	MF.MageFeverPolyFrame:SetFrameStrata("HIGH")	
	MF.MageFeverPolyFrame:SetWidth(50)
	MF.MageFeverPolyFrame:SetHeight(50)
	MF.MageFeverPolyFrame:SetScale(1)
	MF.MageFeverPolyFrame:SetBackdrop(backdrop)
	MF.MageFeverPolyFrame:SetBackdropColor(0,0,0,1)
	MF.MageFeverPolyFrame:SetBackdropBorderColor(0,0,0,0)
		
	MF.MageFeverPolyFrame.IconFrame = CreateFrame("Frame", "MFPolyIcon", MF.MageFeverPolyFrame)
	MF.MageFeverPolyFrame.IconFrame :SetHeight(48)
	MF.MageFeverPolyFrame.IconFrame :SetWidth(48)
	MF.MageFeverPolyFrame.IconFrame :SetAllPoints(MF.MageFeverPolyFrame)
	MF.MageFeverPolyFrame.IconFrame.Icon = MF.MageFeverPolyFrame.IconFrame:CreateTexture()
	MF.MageFeverPolyFrame.IconFrame.Icon:SetAllPoints(MF.MageFeverPolyFrame.IconFrame)
	
	local _,_, icon = GetSpellInfo("Polymorph")
	MF.MageFeverPolyFrame.IconFrame.Icon:SetTexture(icon)
	
	MF.MageFeverPolyFrame.IconFrame.DisplayText = MF.MageFeverPolyFrame.IconFrame:CreateFontString("MFPolyProcText", "ARTWORK", MF.MageFeverPolyFrame)
	MF.MageFeverPolyFrame.IconFrame.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 30)
	MF.MageFeverPolyFrame.IconFrame.DisplayText:SetPoint("CENTER", 0, 0)
	MF.MageFeverPolyFrame.IconFrame.DisplayText:SetTextColor(1, 0,0,1)
	
	MF.MageFeverPolyFrame.MyGUID = TheGUID
	MF.MageFeverPolyFrame.StartTimer = 0
	MF.MageFeverPolyFrame.EndTimer = 0
	MF.MageFeverPolyFrame.UpdateTimer = 0
		
	MF.MageFeverPolyFrame:Hide()
	
	MF.MageFeverPolyFrame:SetScript("OnUpdate", MageFeverPolyUpdate)	
	MF.MageFeverPolyFrame:SetScript("OnMouseDown", MageFeverPolyMouseDown)		
	MF.MageFeverPolyFrame:SetScript("OnMouseUp", MageFeverPolyMouseUp)		
	MF.MageFeverPolyFrame:SetScript("OnHide", MageFeverPolyHide)
end