--------------------------------------------------------
--			Mage Fever Options  
--			Kritologist - Malorne


--Widget event handlers
local function EnterPress(self)
local val = self:GetText() 
		self:SetText("") 
		self:ClearFocus() 
		if val ~= "" then 
			return MFcreateproc(val)
		end 
end
local function AddProcClick(self)
		local val = MageFeverNewProc:GetText() 
		MageFeverNewProc:SetText("") 
		MageFeverNewProc:ClearFocus() 
		if val ~= "" then 
			return MFcreateproc(val)
		end 
end
local function RemoveProcClick(self)
	if not (MF.SelectedProc == nil) then
			MageFeverHideInfo()
			MF.MageFeverProcFrames[MF.SelectedProc]:Hide()
			MF.MageFeverProcFrames[MF.SelectedProc] = nil
			MageFeverProcNames[MF.SelectedProc] = nil
			MF.MageFeverProcOptionFrames[MF.SelectedProc]:Hide()
			MF.MageFeverProcOptionFrames[MF.SelectedProc] = nil
			MF.SelectedProc = nil
			collectgarbage()
			MFprocoptionsrefresh()
		end
end
local function TTWEditEnterPress(self)
	local val = self:GetText() 
		self:SetText("") 
		self:ClearFocus() 
		if val ~= "" then 
			MFcreatettwspell(val)
			MFttwspellsrefresh()
		end 
end
local function TTWAddClick(self)
	local val = self:GetText() 
		self:SetText("") 
		self:ClearFocus() 
		if val ~= "" then 
			return MFcreatettwspell(val)
		end 
end
local function TTWRemoveClick(self)
		if not (MF.SelectedTTWspell == nil) then
			MFTTWSpells[MF.SelectedTTWspell] = nil
			MF.MFttwoptionframes[MF.SelectedTTWspell]:Hide()
			MF.MFttwoptionframes[MF.SelectedTTWspell] = nil
			MF.SelectedTTWspell = nil
			collectgarbage()
			MFttwspellsrefresh()
		end
end
local function AddProcOptionClick(self)
if not (self.ProcName == nil ) then
			MageFeverShowInfo()
			MageFeverProcColor:SetBackdropColor(MFgetvalue("R", self.Info),MFgetvalue("G", self.Info),MFgetvalue("B", self.Info),MFgetvalue("A", self.Info))
			for k,v in pairs(MF.MageFeverProcOptionFrames) do
				v.Text:SetTextColor(1,1,1,1)
			end
			
			MF.SelectedProc = self.ProcName
			getglobal("SelectedProcLabel"):SetText(MF.SelectedProc)
			self.Text:SetTextColor(1,0,0,1)
			
			if MFgetvalue("Unit", self.Info) == "player" then
				getglobal("MageFeverUnitMe"):SetChecked(true)
				getglobal("MageFeverUnitTarget"):SetChecked(false)
			else
				getglobal("MageFeverUnitMe"):SetChecked(false)
				getglobal("MageFeverUnitTarget"):SetChecked(true)
			end
			
			if MFgetvalue("BuffType", self.Info) == "Buff" then
				getglobal("MageFeverBuff"):SetChecked(true)
				getglobal("MageFeverDebuff"):SetChecked(false)
			else
				getglobal("MageFeverBuff"):SetChecked(false)
				getglobal("MageFeverDebuff"):SetChecked(true)
			end
			
			MageFeverProcShow:SetChecked(MFgetvalue("Show", self.Info), MageFeverProcNames[MF.SelectedProc])
			MageFeverProcTimer:SetChecked(MFgetvalue("Timer", self.Info), MageFeverProcNames[MF.SelectedProc])
			MageFeverProcCount:SetChecked(MFgetvalue("Count", self.Info), MageFeverProcNames[MF.SelectedProc])
			MageFeverProcMine:SetChecked(MFgetvalue("Mine", self.Info), MageFeverProcNames[MF.SelectedProc])
			
			MageFeverScaleSlider:SetValue(MFgetvalue("Scale", self.Info), MageFeverProcNames[MF.SelectedProc])
			MageFeverHeightSlider:SetValue(MFgetvalue("Height", self.Info), MageFeverProcNames[MF.SelectedProc])
			MageFeverWidthSlider:SetValue(MFgetvalue("Width", self.Info), MageFeverProcNames[MF.SelectedProc])
			
		end
end

--Widget creation
function MageFeverOptions_Initialize()
	local editbox = CreateFrame("EditBox", "MageFeverNewProc", getglobal("myTabPage1"), "InputBoxTemplate")
	editbox:SetPoint("TOPLEFT",getglobal("myTabPage1"),25,-40)
	editbox:SetHeight(20)
	editbox:SetWidth(75)
	editbox:SetAutoFocus(false)
	editbox:SetScript("OnEscapePressed", function() editbox:ClearFocus() end)
	editbox:SetScript("OnEnterPressed", EnterPress)
	
	local AddButton = CreateFrame("Button","MFAddProc",getglobal("myTabPage1"))
	AddButton:SetHeight(20)
	AddButton:SetWidth(20)
	AddButton:SetPoint("TOPLEFT", 105,-40)
	AddButton:SetText("+")
	AddButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	AddButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	AddButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	AddButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	AddButton:SetNormalFontObject("GameFontNormal")
	AddButton.texture = AddButton:GetNormalTexture()
	AddButton.texture:SetTexCoord(0,.625,0,.6875)
	
	AddButton:SetScript("OnClick", AddProcClick)
	
	local RemoveButton = CreateFrame("Button","MFRemoveProc",getglobal("myTabPage1"))
	RemoveButton:SetHeight(20)
	RemoveButton:SetWidth(20)
	RemoveButton:SetPoint("TOPLEFT", 130,-40)
	RemoveButton:SetText("-")
	RemoveButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	RemoveButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	RemoveButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	RemoveButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	RemoveButton:SetNormalFontObject("GameFontNormal")
	RemoveButton.texture = RemoveButton:GetNormalTexture()
	RemoveButton.texture:SetTexCoord(0,.625,0,.6875)
	
	RemoveButton:SetScript("OnClick", RemoveProcClick)
	
	local ttweditbox = CreateFrame("EditBox", "MageFeverNewTTWProc", getglobal("MageFeverTTWConfig"), "InputBoxTemplate")
	ttweditbox:SetPoint("TOPLEFT",getglobal("MageFeverTTWConfig"),25,-20)
	ttweditbox:SetHeight(20)
	ttweditbox:SetWidth(100)
	ttweditbox:SetAutoFocus(false)
	ttweditbox:SetScript("OnEscapePressed", function() ttweditbox:ClearFocus() end)
	ttweditbox:SetScript("OnEnterPressed", TTWEditEnterPress)
	
	local ttwAddButton = CreateFrame("Button","MFAddttwProc",getglobal("MageFeverTTWConfig"))
	ttwAddButton:SetHeight(20)
	ttwAddButton:SetWidth(20)
	ttwAddButton:SetPoint("TOPLEFT", 130,-20)
	ttwAddButton:SetText("+")
	ttwAddButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	ttwAddButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	ttwAddButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	ttwAddButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	ttwAddButton:SetNormalFontObject("GameFontNormal")
	ttwAddButton.texture = ttwAddButton:GetNormalTexture()
	ttwAddButton.texture:SetTexCoord(0,.625,0,.6875)
	
	ttwAddButton:SetScript("OnClick", TTWAddClick)
	
	local ttwRemoveButton = CreateFrame("Button","MFRemovettwProc",getglobal("MageFeverTTWConfig"))
	ttwRemoveButton:SetHeight(20)
	ttwRemoveButton:SetWidth(20)
	ttwRemoveButton:SetPoint("TOPLEFT", 155,-20)
	ttwRemoveButton:SetText("-")
	ttwRemoveButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
	ttwRemoveButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
	ttwRemoveButton:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
	ttwRemoveButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight", "ADD")
	ttwRemoveButton:SetNormalFontObject("GameFontNormal")
	ttwRemoveButton.texture = ttwRemoveButton:GetNormalTexture()
	ttwRemoveButton.texture:SetTexCoord(0,.625,0,.6875)
	
	ttwRemoveButton:SetScript("OnClick", TTWRemoveClick)
	MageFeverHideInfo()
end
function MFcreateproc(ID)
	local NewProc = GetSpellInfo(ID)
	
	if not (NewProc == nil) then
	--{ R , G , B , A , Buff/Debuff , Target/Player , Timer , Counter , Height , Width , Scale ,  Show , X , Y}
		MageFeverProcNames[NewProc] = {0,0,1,1,"Buff","player",0,0,20,218, 1.2,1, 300, -300}
		CreateNewProcFrame(NewProc, MageFeverProcNames[NewProc])
		if MageFever3_Options.Showing then
			MF.MageFeverProcFrames[NewProc]:Show()
		end
		MFprocoptionsrefresh()
	end
end
function MFPopulateProcs()
	MF.ProcFrameCount = 0
	for k,v in pairsByKeys(MageFeverProcNames) do
		MF.MageFeverProcOptionFrames[k] = AddProcOptionFrame(k, v)
	end
end
function AddProcOptionFrame(k, v)
	local frame = CreateFrame("Frame", MF.ProcFrameCount.."ProcOption", getglobal("MFProcScrollerChildFrame"))
	frame:SetHeight(15)
	frame:SetWidth(300)
	frame:EnableMouse(true)
	frame:SetPoint("TOPLEFT", 0, MF.ProcFrameCount * -16)
	
	frame.Number = MF.ProcFrameCount
	frame.ProcName = k
	frame.Info = v
	
	frame.Text = frame:CreateFontString(k.."OptionText", "OVERLAY", frame)
	frame.Text:SetFont("Fonts\\FRIZQT__.TTF", 10)
	frame.Text:SetPoint("LEFT", 3, 0)
	frame.Text:SetJustifyH("LEFT")
	frame.Text:SetText(k)
	
	frame:SetScript("OnMouseDown", AddProcOptionClick)
	MF.ProcFrameCount = MF.ProcFrameCount +1
	return frame
end
function MFprocoptionsrefresh()
	MF.ProcFrameCount = 0
	for k,v in pairs(MF.MageFeverProcOptionFrames) do
		v:Hide()
		v=nil
	end
	MF.MageFeverProcOptionFrames= {}
	
	for k,v in pairsByKeys(MageFeverProcNames) do
		MF.MageFeverProcOptionFrames[k] = AddProcOptionFrame(k, v)
	end
end
function MFcreatettwspell(ID)
	local NewProc = GetSpellInfo(ID)
	if not (NewProc == nil) then
		MFTTWSpells[NewProc] = 1
		AddTTWSpellFrame(NewProc)
	end
end
function MageFever_Toggle(self)
	MageFever3_Options.Showing = self:GetChecked()
   if not ( MageFever3_Options.Showing ) then
		for k,v in pairs(MF.MageFeverProcFrames) do
			v:Hide()
		end
		MF.MageFeverMI_Frame:Hide()
		MF.MageFeverTTW_Frame:Hide()
   else
	for k,v in pairs(MF.MageFeverProcFrames) do
		v:Show()
		v.back:SetValue(v:GetWidth())
		v.SparkFrame.Spark:SetPoint("TOPLEFT", v:GetWidth() - (16), v:GetHeight() / 2)
	end

	MF.MageFeverMI_Frame.back:SetValue(MF.MageFeverMI_Frame:GetWidth())
	MF.MageFeverMI_Frame.SparkFrame.Spark:SetPoint("TOPLEFT", MF.MageFeverMI_Frame:GetWidth() - (16), MF.MageFeverMI_Frame:GetHeight() / 2)
	MF.MageFeverMI_Frame:Show()
	
	
	MF.MageFeverTTW_Frame:Show()
   end
end
function MageFever_Classic(self)
	if self:GetChecked() then
		MageFeverHeightSlider:Disable()
		MageFeverWidthSlider:Disable()
	else
		MageFeverHeightSlider:Enable()
		MageFeverWidthSlider:Enable()
	end
	MageFever3_Options.ClassicFrames = self:GetChecked()
	MFRefreshProcFrames()
end
function MageFever_Lock(self)
	MageFever3_Options.Lock = not MageFever3_Options.Lock
	self:SetChecked(MageFever3_Options.Lock)
end
function MageFeverOptions_Toggle()
	MageFeverOptions_Frame:Hide()
end
function MFPopulateTTWspells()
	MF.MTTWFrameCount = 0
	for k,v in pairsByKeys(MFTTWSpells) do
		MF.MFttwoptionframes[k] = AddTTWSpellFrame(k, v)
	end
end
function MFttwspellsrefresh()
	MF.MTTWFrameCount = 0
	for k,v in pairs(MF.MFttwoptionframes) do
		v:Hide()
		v=nil
	end
	collectgarbage()
	MF.MFttwoptionframes= {}
	
	for k,v in pairsByKeys(MFTTWSpells) do
		MF.MFttwoptionframes[k] = AddTTWSpellFrame(k, v)
	end
end
function MageFever_ToggleProcShow(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Show", MageFeverProcNames[MF.SelectedProc], self:GetChecked())
	end
end
function MageFever_ToggleProcTimer(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Timer", MageFeverProcNames[MF.SelectedProc], self:GetChecked())
	end
end
function MageFever_ToggleProcCount(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Count", MageFeverProcNames[MF.SelectedProc], self:GetChecked())
	end
end
function MageFever_ToggleProcMine(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Mine", MageFeverProcNames[MF.SelectedProc], self:GetChecked())
	end
end
function MageFever_ToggleProcIcon(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Icon", MageFeverProcNames[MF.SelectedProc], self:GetChecked())
	end
end
function MageFever_ToggleUnitMe(self)
	if not (MF.SelectedProc == nil) then
		getglobal("MageFeverUnitMe"):SetChecked(true)
		MFsetvalue("Unit", MageFeverProcNames[MF.SelectedProc], "player")
		getglobal("MageFeverUnitTarget"):SetChecked(false)
	end
end
function MageFever_ToggleUnitTarget(self)
	if not (MF.SelectedProc == nil) then
		getglobal("MageFeverUnitTarget"):SetChecked(true)
		MFsetvalue("Unit", MageFeverProcNames[MF.SelectedProc], "target")
		getglobal("MageFeverUnitMe"):SetChecked(false)
	end
end
function MageFever_ToggleBuff(self)
	if not (MF.SelectedProc == nil) then
		getglobal("MageFeverBuff"):SetChecked(true)
		MFsetvalue("BuffType", MageFeverProcNames[MF.SelectedProc], "Buff")
		getglobal("MageFeverDebuff"):SetChecked(false)
	end
end
function MageFever_ToggleDebuff(self)
	if not (MF.SelectedProc == nil) then
		getglobal("MageFeverDebuff"):SetChecked(true)
		MFsetvalue("BuffType", MageFeverProcNames[MF.SelectedProc], "Debuff")
		getglobal("MageFeverBuff"):SetChecked(false)
	end
end

--Widget appearance
function MageFever_Scale(self)
	if not (MF.SelectedProc == nil) then
		MFsetvalue("Scale", MageFeverProcNames[MF.SelectedProc], self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc]:SetScale(self:GetValue())
	end
end
function MageFever_Height(self)
	if not (MF.SelectedProc == nil) and not MageFever3_Options.ClassicFrames then
		MFsetvalue("Height", MageFeverProcNames[MF.SelectedProc], self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc]:SetHeight(self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc].IconFrame:SetHeight(self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc].IconFrame:SetWidth(self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc].back:SetHeight(self:GetValue()) -- *.49 for frame with background border
		--MF.MageFeverProcFrames[MF.SelectedProc].Border:SetHeight(self:GetValue())  --*1.2 for frame with background border
		MF.MageFeverProcFrames[MF.SelectedProc].IconFrame:SetPoint("TOPLEFT", -self:GetValue(),0)
		MF.MageFeverProcFrames[MF.SelectedProc].SparkFrame.Spark:SetHeight(self:GetValue()* 2)
		MF.MageFeverProcFrames[MF.SelectedProc].SparkFrame.Spark:SetPoint("TOPLEFT", MF.MageFeverProcFrames[MF.SelectedProc]:GetWidth() - 16 , self:GetValue() / 2 )
  	end
end
function MageFever_Width(self)
	if not (MF.SelectedProc == nil) and not MageFever3_Options.ClassicFrames then
		MFsetvalue("Width", MageFeverProcNames[MF.SelectedProc], self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc]:SetWidth(self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc].back:SetWidth(self:GetValue())
		MF.MageFeverProcFrames[MF.SelectedProc].SparkFrame.Spark:SetPoint("TOPLEFT", self:GetValue() - 16, MF.MageFeverProcFrames[MF.SelectedProc]:GetHeight() / 2 )
		--MF.MageFeverProcFrames[MF.SelectedProc].Border:SetWidth(self:GetValue())  -- * 1.2 for frame with background border
	end
end
function MageFeverSelectColor(self)
	ColorPickerFrame:SetColorRGB(MFgetvalue("R", MageFeverProcNames[MF.SelectedProc]),MFgetvalue("G", MageFeverProcNames[MF.SelectedProc]),MFgetvalue("B", MageFeverProcNames[MF.SelectedProc]))
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (MFgetvalue("A", MageFeverProcNames[MF.SelectedProc]) ~= nil), MFgetvalue("A", MageFeverProcNames[MF.SelectedProc]);
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = MFColorChanged, MFColorChanged, MFColorChanged;
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end
function MFColorChanged(restore)
	local newR, newG, newB, newA;
	if restore then
		newR, newG, newB, newA = unpack(restore);
	else
		newA, newR, newG, newB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	end
	MFsetvalue("R", MageFeverProcNames[MF.SelectedProc], newR)
	MFsetvalue("G", MageFeverProcNames[MF.SelectedProc], newG)
	MFsetvalue("B", MageFeverProcNames[MF.SelectedProc], newB)
	MFsetvalue("A", MageFeverProcNames[MF.SelectedProc], newA)
	
	MF.MageFeverProcFrames[MF.SelectedProc].back:SetStatusBarColor(newR, newG, newB, newA)
	if MageFever3_Options.ClassicFrames then
		MF.MageFeverProcFrames[MF.SelectedProc]:SetBackdropColor(newR, newG, newB, newA)
	end
end
function MageFeverHideInfo()
	MageFeverScaleSliderFrame:Hide()
	MageFeverHeightSliderFrame:Hide()
	MageFeverWidthSliderFrame:Hide()
	MageFeverUnitMe:Hide()
	MageFeverUnitTarget:Hide()
	MageFeverBuff:Hide()
	MageFeverDebuff:Hide()
	MageFeverProcShow:Hide()
	MageFeverProcTimer:Hide()
	MageFeverProcCount:Hide()
	MageFeverFrame1:Hide()
	MageFeverFrame2:Hide()
	ProcColorLabel:Hide()
	MageFeverProcColor:Hide()
	MageFeverProcMine:Hide()
	MageFeverProcIcon:Hide()
end
function MageFeverShowInfo()
	MageFeverScaleSliderFrame:Show()
	MageFeverHeightSliderFrame:Show()
	MageFeverWidthSliderFrame:Show()
	MageFeverUnitMe:Show()
	MageFeverUnitTarget:Show()
	MageFeverBuff:Show()
	MageFeverDebuff:Show()
	MageFeverProcShow:Show()
	MageFeverProcTimer:Show()
	MageFeverProcCount:Show()
	MageFeverFrame1:Show()
	MageFeverFrame2:Show()
	ProcColorLabel:Show()
	MageFeverProcColor:Show()
	MageFeverProcMine:Show()
	MageFeverProcIcon:Show()
end