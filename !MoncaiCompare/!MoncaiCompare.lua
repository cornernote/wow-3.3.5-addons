local ItemRefTooltip = ItemRefTooltip

ItemRefTooltip.UpdateTooltip = function(self)
	if ( not self.comparing) then
		GameTooltip_ShowCompareItem(self);
		self.comparing = true;
--~ 	elseif ( self.comparing and false) then
--~ 		for _, frame in pairs(self.shoppingTooltips) do
--~ 			frame:Hide();
--~ 		end
--~ 		self.comparing = false;
	end
end

ItemRefTooltip:SetScript("OnTooltipSetItem", function(self)
	if (self:IsMouseOver()) then
		GameTooltip_ShowCompareItem(self, 1);
		self.comparing = true;
	end
end 
)

ItemRefTooltip:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing();
	ValidateFramePosition(self);
--~ 	if ( true ) then --We do this to choose where the comparison is shown
		GameTooltip_ShowCompareItem(self, 1);
		self.comparing = true;
--~ 	end
end
)

GameTooltip:SetScript("OnTooltipSetItem", function(self)
	if ( IsModifiedClick("COMPAREITEMS") or
	     (not self:IsEquippedItem()) ) then
		GameTooltip_ShowCompareItem(self, 1);
	end
end
)