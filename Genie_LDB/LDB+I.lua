--[[///////////////////////////////////////////////////////////////////////////////////////
    GENIE r214
        LDB 198; Provides a LDB-Plugin and a Minimap-Icon based on LDBI

    Author: adjo
    Website: http://wow.curseforge.com/projects/genie
    Feedback: http://wow.curseforge.com/projects/genie/tickets/
    Localization: http://wow.curseforge.com/addons/genie/localization/
    
	adjo 2010-10-06T21:24:33Z
    
	This document may be redistributed as a whole, 
    provided it is unaltered and this copyright notice is not removed. 
    
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.    
    
--///////////////////////////////////////////////////////////////////////////////////////]]

local Genie = LibStub("AceAddon-3.0"):GetAddon("Genie")
local Module = Genie:NewModule("LDB", "AceComm-3.0", "AceSerializer-3.0")
local API = Genie.API

local L = LibStub("AceLocale-3.0"):GetLocale("Genie")
local API = Genie.API

--[[
Genie.ICONS = {}
Genie.ICONS.editMode = 'Interface\\AddOns\\Genie\\Media\\icon_editmode' 
Genie.ICONS.default = 'Interface\\AddOns\\Genie\\Media\\icon_default'
Genie.ICONS[false] = Genie.ICONS.default
Genie.ICONS[true] = Genie.ICONS.editMode
--]]

local LDB = LibStub('LibDataBroker-1.1'):NewDataObject('Genie', {
                type = "data source",
                text = L.Genie,
                icon = Genie.ICONS.default,
            })             
local icon = LDB and LibStub("LibDBIcon-1.0", true)

--[[  LDB  ////////////////////////////////////////////////////////////////////////////////
--]]
function LDB.OnClick(self, button)
			if button == 'LeftButton' then
                if IsAltKeyDown() then
					if Genie.atGuildBank then
						Genie:DoGuildbankWorks()
					end
				elseif IsControlKeyDown() then
                    if Genie.atBank then
						Genie:DoBankWorks()
					end
				elseif IsShiftKeyDown() then
					Genie:DoBagWorks()
				else
					Genie:PreWorks()
				end
			elseif button == 'RightButton' then
                if IsAltKeyDown() then
                    Genie:Stop()
				elseif IsControlKeyDown() then
                    API:ToggleOptionsFrame()
                elseif IsShiftKeyDown() then
                    API:ToggleEditmode()
                 else
                    API:ToggleUI()
                end
			end
		end

function LDB:Update()
    self.icon = Genie.ICONS[Genie.db.global.edit]
end

function LDB.OnTooltipShow(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine(L['Genie']..' '..Genie.VERSION)
			tooltip:AddLine(' ')
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'>|r '.. Genie.CMD.args.work.name)
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Shift..'>|r '.. Genie.CMD.args.bag.args.work.name)
			tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Strg..'>|r '.. Genie.CMD.args.bank.args.work.name)
            tooltip:AddLine('|cFFFFFFFF <'..L.LeftClick..'+'.. L.Alt..'>|r '.. Genie.CMD.args.guildbank.args.work.name)            
			tooltip:AddLine(' ')
            tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'>|r '.. L.Classranking)
            if Genie.db.global.edit then
                tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'+'.. L.Shift..'>|r '.. L.Configmode .. ':' .. L.Disable)
			else
                tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'+'.. L.Shift..'>|r '.. L.Configmode .. ':' .. L.Enable)
            end
            tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'+'.. L.Strg..'>|r '.. L['Open the optionsmenu'])
            tooltip:AddLine('|cFFFFFFFF <'..L.RightClick..'+'.. L.Alt..'>|r '.. Genie.CMD.args.stop.name)                        
end


--[[  MODULE  /////////////////////////////////////////////////////////////////////////////
--]]

local defaults = {
    profile = {
        attachTo = {
            minimap = true,
        },
    },
}
--todo:use prototype instead
local function tableInsert(tab, options)
    if type(options) == 'table' then
        for k,v in pairs(options) do
            if tab[k] then
                tableInsert(tab[k], v)
            elseif tab[k] == nil then
                tab[k] = v
            end
        end
    elseif tab == nil then
        tab = options
    end
end

function Module:OnInitialize()
    self.db = Genie.db   
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
    
    if not GenieUI_IconDB then GenieUI_IconDB = {} end
end

function Module:RefreshConfig()
    tableInsert(self.db, defaults)
    self:RegisterDBI()    
end

function Module:OnEnable()
    self:RegisterComm(Genie.CONSTANT.COM.DBSET)      
    self:RefreshConfig()
end

function Module:OnCommReceived(prefix, message, distribution, sender)
    local success, message = self:Deserialize(message)       
    if prefix == Genie.CONSTANT.COM.DBSET and message == 'profile.attachTo' then
        self:RegisterDBI()
    end
end

function Module:RegisterDBI()
    if icon then
        if not icon:IsRegistered('Genie') and self.db.profile.attachTo.minimap then          
            icon:Register('Genie', LDB, GenieUI_IconDB)
        end
    
        if self.db.profile.attachTo.minimap == true then
            icon:Show('Genie')
        else
            icon:Hide('Genie')
        end        
    end
end

--[[  API  ////////////////////////////////////////////////////////////////////////////////
--]]
function API:ToggleUI()
    local mod, modAddon = "UI", "Genie_UI"
		if not Genie.UI then
			Genie.UI = Genie:GetModule(mod, true)
		end

		if Genie.UI then
            InterfaceOptionsFrame:Hide()
            Genie.UI:ShowUI()   
		else
			EnableAddOn(modAddon)
			local loaded, reason = LoadAddOn(modAddon)
			if not loaded then
				Genie:Print(string.format(L["Cannot load %s! Reason: %s"], modAddon, reason))
			else
				Genie.UI = Genie:GetModule(mod, true)
				if Genie.UI then
                    InterfaceOptionsFrame:Hide()
                    Genie.UI:CreateUI()
					Genie.UI:ShowUI()
				elseif not Genie.UI then
					Genie:Print(string.format(L["LoadOnDemand of %s failed"], modAddon))
				end
			end
		end 
end
function API:ToggleOptionsFrame()
    if Genie.UI then Genie.UI:HideUI() end
    InterfaceOptionsFrame_OpenToCategory(L["Genie"])
end
function API:ToggleEditmode()
    API:SetEditmode(not Genie.db.global.edit)
end
function API:SetEditmode(enabled)
    if enabled then
        Genie.db.global.edit = true
    else
        Genie.db.global.edit = false
    end
    API:RefreshIcon()    
end

function API:RefreshIcon()
    LDB:Update()
end
