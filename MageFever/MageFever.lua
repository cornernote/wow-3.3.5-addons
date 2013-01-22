--------------------------------------------------------
--          Mage Fever Core  
--			Kritologist - Malorne

--Saved variables
MageFever3_Options = {
   Lock = true,
   Showing = false,
   LBTrackerShowing = false,
   LBGrowUp = false,
   LBTrackerScale = 1,
   SSScale = 1,
   SSmonitorShowing = false,
   FMTrackerShowing = true,
   ClassicFrames = false,
   SSGrowUp = false,
   BGBomberShowing = false,
   BGBomberLocation = {}
}
MageFeverMI_Options = {
	["R"] = 0,
	["G"] = 0,
	["B"] = 1,
	["A"] = 1,
	["Timer"] = true,
	["Height"] = 25,
	["Width"] = 200,
	["Scale"] = 1,
	["Show"] = true,
	["X"] = 400,
	["Y"] = 400
}
MageFeverProcNames = {
--{ R , G , B , A , Buff/Debuff , Target/Player , Timer , Counter , Height , Width , Scale ,  Show , X , Y, Mine, Icon}
}
MageFeverTTW_Options = {
	["R"] = 0,
	["G"] = 1,
	["B"] = 1,
	["A"] = 1,
	["Timer"] = true,
	["Height"] = 50,
	["Width"] = 50,
	["Scale"] = 1,
	["Show"] = true,
	["X"] = 600,
	["Y"] = 400
}

MF = {}

MFTTWSpells = {}

MF.FPname = GetSpellInfo(64357)
MF.MageFeverLoaded = false
MF.ProcFrameCount = 0
MF.MageFeverProcFrames = {}
MF.MageFeverProcOptionFrames = {}
--MF.SelectedProc = ""

MF.LBname = GetSpellInfo(55360)
MF.LBtracker = {}
MF.LBtrackertotal = 0
MF.LBsecuretrackertotal = 0
MF.LBtrackerFrames = {}
MF.LBspecced = false
MF.LB = false

MF.SSMonitorCreated = false
MF.MageFeverSSMonitorFrame = {}
MF.MageFeverSSActiveSpellFrames = {}
MF.MageFeverSSActiveNames = {}
MF.MageFeverStolenFrame = {}
MF.MageFeverSScount = 0

MF.FMname = GetSpellInfo(54646)
MF.MageFeverFMTrackerFrame = {}
--MF.MageFeverFMtarget = ""

MF.MageFeverMI_Frame = {}
MF.MIcasttime = 0
MF.MIupdatetime = 0
MF.MIname = GetSpellInfo(58832)

MF.MTTWFrameCount = 0
MF.MFttwoptionframes = {}
MF.MageFeverTTW_Frame = {}
--MF.SelectedTTWspell = ""
MF.TTWspecced = false
MF.TTW = false
MF.TTWname = GetSpellInfo(55340)

MF.MageFeverPolyFrame = {}
MF.PolyName = GetSpellInfo(12826)
    
function MageFever_OnLoadOptions(self)
	SLASH_MAGEFEVER1 = "/mfever"
   	SlashCmdList["MAGEFEVER"] = MageFever_SlashCommand
   	self:RegisterEvent("ADDON_LOADED")
   	self:RegisterEvent("UNIT_HEALTH")
end	
function MageFever_SlashCommand(msg)
	msg = string.lower(msg)
	local args = {}
	
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(args, word)
	end
		
	if ( args[1] ) then
		if ( args[1] == "options" ) then
			MageFeverOptions_Frame:Show();
		elseif ( args[1] == "show" ) then
			MageFever_Toggle();
		elseif ( args[1] == "lock" ) then
			MageFever3_Options.Lock = not MageFever3_Options.Lock
		elseif ( args[1] == "classic" ) then
			if args[2] then
				if args[2] == "on" then
					MageFever3_Options.ClassicFrames = true
					MFRefreshProcFrames()
				elseif args[2] == "off" then
					MageFever3_Options.ClassicFrames = false
					MFRefreshProcFrames(true)
				end
			end
		elseif ( args[1] == "fm") then
			PrintFMRotation()
		elseif ( args[1] == "reset") then
			if args[2] then
				if args[2] == "procs" then
					MageFeverResetProcs()
				elseif args[2] == "ttw" then
					MageFeverResetTTW(true)
				end
			end
		elseif ( args[1] == "debug") then
			print(MF.MageFeverLoaded())
		else
			DEFAULT_CHAT_FRAME:AddMessage("-- Mage Fever: Unknown command.")
			DEFAULT_CHAT_FRAME:AddMessage("-- Use </mfever> for options.")
			DEFAULT_CHAT_FRAME:AddMessage("-- Use </mfever classic on|off> to toggle classic mode.")
			DEFAULT_CHAT_FRAME:AddMessage("-- Use </mfever fm> to post Focus Magic rotation to raid.")
			DEFAULT_CHAT_FRAME:AddMessage("-- Use </mfever reset procs> to reset procs and restore originals.")
			DEFAULT_CHAT_FRAME:AddMessage("-- Use </mfever reset ttw> to reset ttw trigger spells and restore originals.")
		end
	else
		MageFeverOptions_Frame:Show();
	end
end
function MageFeverResetProcs(slash)
		MageFeverProcNames = {}
		MageFeverProcNames[GetSpellInfo(44543)] = {0,0,1,1,"Buff","player",1,0,20,218, 1.2,1, 300, -200, 0, 1}  --Fingers of Frost
		MageFeverProcNames[GetSpellInfo(57761)] = {1,0,0,1,"Buff","player",1,0,20,218, 1.2,1, 300, -220, 0, 1} --Brain Freeze
		MageFeverProcNames[GetSpellInfo(48108)] = {1,0,0,1,"Buff","player",1,0,20,218, 1.2,1, 300, -240, 0, 1} --Hot Streak
		MageFeverProcNames[GetSpellInfo(44401)] = {0,0,0,1,"Buff","player",1,1,20,218, 1.2,1, 300, -260, 0, 1} --Missile Barrage
		MageFeverProcNames[GetSpellInfo(44443)] = {1,0,0,1,"Buff","player",1,0,20,218, 1.2,1, 300, -280, 0, 1} -- Firestarter
		MageFeverProcNames[GetSpellInfo(12536)] = {0,0,0,1,"Buff","player",1,0,20,218, 1.2,1, 300, -300, 0, 1}-- Clear Casting
		MageFeverProcNames[GetSpellInfo(64343)] = {1,1,0,1,"Buff","player",1,0,20,218, 1.2,1, 300, -320, 0, 1} -- Impact
		MageFeverProcNames[GetSpellInfo(55360)] = {1,0,0,1,"Debuff","target",1,0,20,218, 1.2,1, 300, -340, 0, 1} -- Living Bomb
		MageFeverProcNames[GetSpellInfo(22959)] = {0,0,1,1,"Debuff","target",1,1,20,218, 1.2,1, 300, -360, 0, 1}-- Scorch
		MageFeverProcNames[GetSpellInfo(36032)] = {0,0,0,1,"Debuff","player",1,1,20,218, 1.2,1, 300, -380, 0, 1} -- Arcane Blast
		MageFeverProcNames[GetSpellInfo(70753)] = {123,104,238,1,"Buff","player",1,0,20,218, 1.2,1, 300, -400, 0, 1} --Pushing the Limit
		
		if slash then 
			DEFAULT_CHAT_FRAME:AddMessage("Mage Fever: Procs have been reset.") 
			DEFAULT_CHAT_FRAME:AddMessage("Mage Fever: Please reload your UI for the changes to apply.") 
		end
end
function MageFeverResetTTW(slash)
		MFTTWSpells = {
				[GetSpellInfo(31589)] = 1, --Slow
				[GetSpellInfo(47502)]= 1, --Thunderclap
				[GetSpellInfo(53696)]= 1, --Judgment of the Just
				[GetSpellInfo(55095)]= 1, --Frost Fever
				[GetSpellInfo(48485)]= 1, --Infect Wounds
				[GetSpellInfo(45524)]= 1, --Chains of Ice
				[GetSpellInfo(50259)]= 1, --Feral Charge - Cat (Dazed)
				[GetSpellInfo(19675)]= 1, --Feral Charge Effect
				[GetSpellInfo(2974)]= 1, --Wing Clip
				[GetSpellInfo(13809)]= 1, -- Frost Trap
				[GetSpellInfo(5116)]= 1, --Concussive Shot
				[GetSpellInfo(42842)]= 1, --Frost Bolt
				[GetSpellInfo(42931)]= 1, --Cone of Cold
				[GetSpellInfo(42945)]= 1, --Blast Wave
				[GetSpellInfo(48156)]= 1, -- Mind Flay
				[GetSpellInfo(25809)]= 1, --Crippling Poison
				[GetSpellInfo(48674)]= 1, --Deadly Throw
				[GetSpellInfo(49236)]= 1, --Frost Shock
				[GetSpellInfo(3600)]= 1, --Earth Bind
				[GetSpellInfo(18223)]= 1, --Curse of Exhaustion
				[GetSpellInfo(1715)]= 1, -- Hamstring
				[GetSpellInfo(12323)]= 1, --Piercing Howl
				[GetSpellInfo(47610)]=1 --Frost Fire Bolt
			}
		if slash then 
			DEFAULT_CHAT_FRAME:AddMessage("Mage Fever: TTW trigger spells have been reset.") 
			DEFAULT_CHAT_FRAME:AddMessage("Mage Fever: Please reload your UI for the changes to apply.") 
		end
end
function MageFever_OnEvent(self,event, ...)
	if (event == "ADDON_LOADED" and arg1=="MageFever") then
		
		local MFcount = 0
		for k,v in pairs(MageFeverProcNames) do
			MFcount = MFcount + 1
		end
		
		if MageFever3_Options.BGBomberLocation == nil then
			MageFever3_Options.BGBomberLocation = {400, -400}
		end
		
		if MFcount == 0 then
			local BFClass = UnitClass("player")
			if BFClass == "Mage" then
				MageFeverResetProcs()
			end
		end
		
		MFcount = 0
		for k,v in pairs(MFTTWSpells) do
			MFcount = MFcount + 1
		end	
		
		if MFcount == 0 then
			MageFeverResetTTW()
		end
		
		local TTWnameTalent, TTWiconPath, tier, TTWcolumn, TTWcurrentRank, TTWmaxRank, TTWisExceptional, TTWmeetsPrereq = GetTalentInfo(1, 14)
		if TTWcurrentRank > 0 then
			if TTWnameTalent == MF.TTWname then
				MF.TTWspecced = true
			end
		end	
		
		MageFeverOptions_Initialize()
		MageFever_CreateMIframe()
		MageFever_CreateTTWframe()

		if not (MF.LBtracker == nil) then
			MageFever3_Options.LBTrackerScale = MageFeverLBTrackerScale:GetValue()
			MF.LBtracker:SetScale(MageFever3_Options.LBTrackerScale)
		end
		
		if MageFever3_Options.LBTrackerShowing then
			MF.LBtracker:Show()	
		else
			MF.LBtracker:Hide()
		end
		
		if MageFever3_Options.SSmonitorShowing then
			MF.MageFeverSSMonitorFrame:Show()
		else
			MF.MageFeverSSMonitorFrame:Hide()
		end
		
		MageFeverRepositionSSframes()
		MF.MageFeverSSMonitorFrame:SetScale(MageFever3_Options.SSScale)
		
		CreateProcFrames()
		MFPopulateProcs()
		MFPopulateTTWspells()
		
		if not MageFever3_Options.Showing then
			MageFeverOptions_Frame:Hide()
		end
		MageFeverFMTargetFrame:Hide()
		MF.MageFeverLoaded = true
	return
	end
end
