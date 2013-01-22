----------------------------------
--		Mage Fever Ignite Watch
--		Kritologist - Malorne

MageFeverIgniter = {}


function MageFeverIgniter:UpdateText(self)
	local MunchPercent = 0
	if not (self.RegisteredDamage == 0) then
		MunchPercent = format("%.2f",(1-(self.RegisteredDamage / self.CastedDamage)))
	end
	print(MunchPercent)
	self.Frame.DisplayText:SetText(MunchPercent.."%")
	--self.Frame.DisplayText:SetText(self.CastedDamage.."    "..self.RegisteredDamage)
end

function CreateIgniteWatchFrame()
	local backdrop = {bgFile = "Interface\\Glues\\LoadingBar\\Loading-BarBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 0,
	}
	
	local frame = CreateFrame("Frame", "MFIgniteWatch",  UIParent)
	frame:SetPoint("TOPLEFT", 400, 400)
	frame:SetMovable(true)
	frame:RegisterForDrag("RightButton")
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("HIGH")	
	frame:SetWidth(50)
	frame:SetHeight(50)
	frame:SetScale(1)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0,0,0,1)
	frame:SetBackdropBorderColor(0,0,0,0)
	
	frame.TitleText = frame:CreateFontString("IgniteTitleText", "ARTWORK", frame)
	frame.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.TitleText:SetText("Ignite Munch")
	frame.TitleText:SetPoint("CENTER", 0, 30)
	frame.TitleText:SetTextColor(1, 0,0,1)
	
	frame.DisplayText = frame:CreateFontString("IgniteText", "ARTWORK", frame)
	frame.DisplayText:SetFont("Fonts\\FRIZQT__.TTF", 20)
	frame.DisplayText:SetPoint("CENTER", 0, 0)
	frame.DisplayText:SetTextColor(1, 0,0,1)
		
	frame:Hide()
	
	frame:SetScript("OnMouseDown", function(self, button)
		if (not (MageFever3_Options.Lock) ) then
			self:StartMoving();
			self.isMoving = true;
		end
	end)
		
	frame:SetScript("OnMouseUp", function(self, button)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end)
		
	frame:SetScript("OnHide", function(self)
		if ( self.isMoving ) then
			self:StopMovingOrSizing();
			self.isMoving = false;
		end
	end)
	
	return frame
end

MageFeverIgniter.Frame = CreateIgniteWatchFrame()
MageFeverIgniter.CastedDamage = 0
MageFeverIgniter.RegisteredDamage = 0