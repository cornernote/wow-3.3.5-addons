local SellOMatic = _G.SellOMatic;
local L = LibStub("AceLocale-3.0"):GetLocale("SellOMatic");
local se={};
local num_items = 0;

function se:CreateDestroyWindow(items)

	se.DestroyFrame = CreateFrame("Frame",nil,UIParent);
	local theFrame = se.DestroyFrame;

	theFrame:ClearAllPoints();
	theFrame:SetPoint("CENTER",UIParent);
	theFrame:SetHeight(100);
	theFrame:SetWidth(250);
	theFrame:SetFrameStrata("HIGH");

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

	theFrame.Text = theFrame:CreateFontString(nil,"OVERLAY","GameFontNormal");
	theFrame.Text:SetPoint("CENTER",theFrame,"TOP",0,-30);
	theFrame.Text:SetTextColor(1.0,1.0,1.0);
	theFrame.Text:SetText(L["Delete"].." "..#items.." "..L["item(s) from inventory?"]);

	theFrame.YesButton = CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate");
	theFrame.YesButton:SetWidth(70);
	theFrame.YesButton:SetHeight(24);
	theFrame.YesButton:SetPoint("BOTTOMRIGHT",theFrame,"BOTTOM",-40,15);
	theFrame.YesButton:SetScript("OnClick",function()
		SellOMatic:DestroyItemList(items);
		theFrame:Hide();
	end);
	theFrame.YesButton:SetText(L["Yes"]);

	theFrame.NoButton = CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate");
	theFrame.NoButton:SetWidth(70);
	theFrame.NoButton:SetHeight(24);
	theFrame.NoButton:SetPoint("BOTTOMLEFT",theFrame,"BOTTOM",40,15);
	theFrame.NoButton:SetScript("OnClick",function()
		theFrame:Hide();
	end);
	theFrame.NoButton:SetText(L["No"]);

	theFrame.ShowButton = CreateFrame("Button",nil,theFrame,"OptionsButtonTemplate");
	theFrame.ShowButton:SetWidth(80);
	theFrame.ShowButton:SetHeight(24);
	theFrame.ShowButton:SetPoint("BOTTOM",theFrame,"BOTTOM",0,15);
	theFrame.ShowButton:SetScript("OnClick",function()
		SellOMatic:ShowDestroyList(items);
	end);
	theFrame.ShowButton:SetText(L["Show"]);

	theFrame:Hide();
end;

function SellOMatic:ShowDestroyFrame(item_list)
	if se.DestroyFrame == nil or num_items ~= #item_list then
		num_items = #item_list;
		se:CreateDestroyWindow(item_list);
	end

	se.DestroyFrame:Show();

end
