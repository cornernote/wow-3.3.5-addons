local SellOMatic = _G.SellOMatic;
local L = LibStub("AceLocale-3.0"):GetLocale("SellOMatic");
local se={};

function se:CreateAddWindow()

	se.AddFrame = CreateFrame("Frame","SOMAddFrame",UIParent);
	local theFrame = se.AddFrame;

	theFrame:ClearAllPoints();
	theFrame:SetPoint("CENTER",UIParent);
	theFrame:SetHeight(160);
	theFrame:SetWidth(300);
	theFrame:SetFrameStrata("FULLSCREEN_DIALOG");

	theFrame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", tile = true,
	insets = {left = 10, right = 10, top = 10, bottom = 10},
	});
	theFrame:SetBackdropBorderColor(1.0,1.0,1.0);
	theFrame:SetBackdropColor(25/255, 25/255, 25/255);

	theFrame:EnableMouse(true);
	theFrame:SetMovable(true);

	theFrame:SetScript("OnMouseDown", function(this)
		if not this.isLocked or this.isLocked == 0 and arg1 == "LeftButton" then
			this:StartMoving();
			this.isMoving = true;
		end;
	end);

	theFrame:SetScript("OnMouseUp", function(this)
		if this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end;
	end);

	tinsert(UISpecialFrames, theFrame);

	theFrame.Text = theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal");
	theFrame.Text:SetPoint("CENTER",theFrame,"TOP",0,-30);
	theFrame.Text:SetTextColor(1.0,1.0,1.0);
	theFrame.Text:SetText(L["Type the item/part of the item text box."]);

	theFrame.EditBoxBack = CreateFrame("Frame",nil,theFrame);
	theFrame.EditBoxBack:SetWidth(250);
	theFrame.EditBoxBack:SetHeight(24);
	theFrame.EditBoxBack:SetPoint("CENTER",theFrame,"CENTER",0,0);
	theFrame.EditBoxBack:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = false, tileSize = 0, edgeSize = 10,
		insets = {left = 2, right = 2, top = 1, bottom = 1},
	});
	theFrame:SetBackdropColor(25/255, 25/255, 25/255);

	theFrame.EditBox = CreateFrame("EditBox",nil,theFrame);
	theFrame.EditBox:SetWidth(240);
	theFrame.EditBox:SetHeight(24);
	theFrame.EditBox:SetPoint("CENTER",theFrame,"CENTER",0,0);
	theFrame.EditBox:SetFontObject(GameFontNormal);
	theFrame.EditBox:SetAutoFocus(false);
	theFrame.EditBox:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	});
	theFrame.EditBox:SetBackdropColor(25/255, 25/255, 25/255);

	theFrame.SellButton = CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate");
	theFrame.SellButton:SetWidth(130);
	theFrame.SellButton:SetHeight(24);
	theFrame.SellButton:SetPoint("BOTTOMRIGHT",theFrame,"BOTTOM",-5,15);
	theFrame.SellButton:SetScript("OnClick",function()
		SellOMatic:SellListAdd(theFrame.EditBox:GetText());
		theFrame.EditBox:SetText("");
		theFrame:Hide();
	end);
	theFrame.SellButton:SetText(L["Add to sell list"]);

	theFrame.SaveButton = CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate");
	theFrame.SaveButton:SetWidth(130);
	theFrame.SaveButton:SetHeight(24);
	theFrame.SaveButton:SetPoint("BOTTOMLEFT",theFrame,"BOTTOM",5,15);
	theFrame.SaveButton:SetScript("OnClick",function()
		SellOMatic:SaveListAdd(theFrame.EditBox:GetText());
		theFrame.EditBox:SetText("");
		theFrame:Hide();
	end);
	theFrame.SaveButton:SetText(L["Add to save list"]);

	theFrame:Hide();
end;

function SellOMatic:ShowAddFrame()
	if se.AddFrame == nil then se:CreateAddWindow(); end;
	se.AddFrame:Show();
end;
