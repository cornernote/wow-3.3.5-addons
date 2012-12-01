--[[///////////////////////////////////////////////////////////////////////////////////////
    GENIE r218

    Author: adjo
    Website: http://wow.curseforge.com/projects/genie
    Feedback: http://wow.curseforge.com/projects/genie/tickets/
    Localization: http://wow.curseforge.com/addons/genie/localization/
    
	adjo 2010-10-06T21:23:24Z   
    
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

local L = LibStub("AceLocale-3.0"):NewLocale("Genie", "deDE")
if not L then return end
--[[///////////////////////////////////////////////////////////////////////////////////////
    Automatic translation injection
--///////////////////////////////////////////////////////////////////////////////////////]]
L["Add"] = "Hinzufügen"
L["Add a class/family to the ranking"] = "Füge eine Klasse/Familie zum Ranking hinzu"
L["Add an element to this X"] = "Füge ein Element zu X hinzu"
L["AddonNotes"] = "Genie hilft dir deine Taschen, Bank und/oder Gildenbank ordentlich zu halten"
L["All items are beeing ignored"] = "Alle Elemente werden ignoriert"
L["Alt"] = "Alt"
L["Always"] = "Always" -- Requires localization
L["And"] = "And" -- Requires localization
L["As you wish master"] = "Wie du wünschst Meister"
L["AttachTo"] = "AttachTo" -- Requires localization
L["Automatic"] = "Automatisch"
L["Automatic X events"] = "Automatische X Ereignisse"
L["Automatic mode"] = "Automatischer Modus"
L["BANKFRAME_CLOSED"] = "Die Bank besucht"
L["BANKFRAME_OPENED"] = "Sobald die Bank geöffnet wird"
L["Bag"] = "Taschen"
L["Bags"] = "Taschen"
L["Bank"] = "Bank"
L["Bool"] = "Bool" -- Requires localization
L["Classranking"] = "Klassen- Ranking"
L["Colors"] = "Colors" -- Requires localization
L["Combine"] = "Combine" -- Requires localization
L["Combine one or more ranks"] = "Einen oder Mehrere Ränge zusammenfassen" -- Needs review
L["Combined"] = "Combined" -- Requires localization
L["Configmode"] = "Configmode" -- Requires localization
L["Contains"] = "Enthält"
L["Count"] = "Anzahl"
L["Create"] = "Erzeuge"
L["Created"] = "Erstellt"
L["Criteria"] = "Criteria" -- Requires localization
L["Current content of X"] = "Aktueller Inhalt von"
L["Custom family"] = "Eigene Familie"
L["Custom family:short"] = "EF"
L["Delete"] = "Lösche"
L["Delete a combined rank"] = "Lösch einen Zusammengefassten Rang" -- Needs review
L["Deleted"] = "Gelöscht"
L["Disable"] = "Deaktiviere"
L["Disable a class"] = "Deaktiviere eine Klasse"
L["Disabled"] = "Deaktiviert"
L["Disabled:short"] = "D"
L["Display detailed infos about a rank"] = "Zeige Detailinformationen über einen Rang"
L["EQUIPMENT_SWAP_FINISHED"] = "Ausrüstung gewechselt"
L["Enable"] = "Aktiviere"
L["Enable a class"] = "Aktiviere eine Klasse"
L["Enabled"] = "Aktiviert"
L["EquipLoc"] = "Ausrüstungsplatz"
L["Events"] = "Ereignisse"
L["Family"] = "Familie"
L["Fast"] = "Schnell"
L["Filter"] = "Filter" -- Requires localization
L["Finished"] = "Fertig"
L["GUI"] = "GUI" -- Requires localization
L["GUILDBANKFRAME_CLOSED"] = "Die Gildenbank besucht"
L["Genie"] = "Genie"
L["Guildbank"] = "Gildenbank"
L["Guildbank-Tab 'X' unlocked. You're welcome."] = "Gildenbankfach 'X' entsperrt. Viel Spaß"
L["Highlight"] = "Highlight" -- Requires localization
L["I need to know on which tabs i'm allowed to work"] = "Ich muss wissen mit welchen Gildenbankfächern ich arbeiten kann"
L["I will try to read your mind master"] = "Ich werde versuchen deine Gedanken zu lesen Meister"
L["I'm locking Guildbank-Tab 'X'. Step back!"] = "Ich sperre gerade Gildenbankfach 'X'. Tretet zurück!"
L["I've done what you requested in X seconds"] = "Ich habe alles gewünschte in insgesamt X Sekunden erledigt"
L["Ignore"] = "Ignoriere"
L["Ignore all elements of X"] = "Ignoriere alle Elemente von X"
L["Ignore all elements of this X"] = "Ignoriere alle Elemente von X"
L["Inspect"] = "Untersuchen"
L["Inventory"] = "Taschen"
L["Invert"] = "Invert" -- Requires localization
L["Invert a class"] = "Invertiere eine Klasse"
L["Invert the sorting order"] = "Kehre die Sortierreihenfolge um"
L["Inverted:short"] = "I"
L["ItemID"] = "GegenstandsID"
L["Keyring"] = "Schlüsselbund"
L["LOOT_CLOSED"] = "Nachm Loot"
L["LeftClick"] = "LinksClick"
L["Lock the Guildbank"] = "Sperre die Gildenbank"
L["Lock the Guildbank:desc"] = "Sperre das ausgewählte Gildbankfach während Genie daran arbeitet"
L["MAIL_CLOSED"] = "Mails abgerufen"
L["MERCHANT_CLOSED"] = "Einen Händler aufgesucht"
L["Master i apologize, there where some errors. I had to stop"] = "Meister bitte entschuldige, es gab einige Fehler. Ich musste aufhören"
L["Master, i can't work with an empty container"] = "Meister, ich kann nicht mit einem leeren Behälter arbeiten"
L["Master, that's one thing i'm not allowed to do"] = "Meister, das darf ich nicht"
L["Master, there's nothing (more) to do"] = "Meister, es ist nichts (mehr) zu tun"
L["MinLevel"] = "Mindeststufe"
L["Minimap"] = "Minimap" -- Requires localization
L["Mode"] = "Modus"
L["Move all items"] = "Bewege alle Elemente"
L["Moving"] = "Bewegen"
L["Name"] = "Name"
L["New"] = "Neu"
L["No X defined"] = "Kein(e) X vorhanden"
L["Number"] = "Number" -- Requires localization
L["Open the optionsmenu"] = "Öffne das Konfigurationsmenü"
L["Or"] = "Or" -- Requires localization
L["Price"] = "Verkaufspreis"
L["Questitem"] = "Questitem"
L["Rarity"] = "Qualität"
L["Remove"] = "Entfernen"
L["Remove an element from this X"] = "Entferne ein Element aus X"
L["Rename"] = "Umbenennen"
L["Reset the classranking"] = "Deaktiviere alle Klassen"
L["Reverse"] = "Invertiert"
L["Reverse the order in which your bags and/or bagslots will be accsessed"] = "Invertiert die Reihenfolge in der Taschen und/oder Taschenplätze betrachtet werden"
L["RightClick"] = "RechtsClick"
L["Shift"] = "Shift"
L["Show"] = "Zeige"
L["Show current X"] = "Zeige aktelle X"
L["Silent"] = "Still"
L["SlotCooldown"] = "Taschenplatz-Abklingzeit"
L["SlotCooldown:desc"] = "Zeit in Sekunden die Genie warten soll, bevor es einen Taschenplatz wiederverwendet. Setze den Wert auf 0 (Null), wenn es keine Verzögerung geben soll."
L["Slots"] = "Platz"
L["Sort all items"] = "Sortiere alle Elemente"
L["Sorting"] = "Sortieren"
L["Sorting algorithm"] = "Sortieralgorithmus"
L["Soulbound"] = "Seelengebunden"
L["Sound"] = "Sound"
L["Stack all items"] = "Stapel alle Elemente"
L["Stack, move and sort your X"] = "Staple, Bewege und Sortiere deine X"
L["StackCount"] = "Maximale Stapelgröße"
L["Stacking"] = "Stapeln"
L["Stop"] = "Stop"
L["Strg"] = "Strg"
L["String"] = "String" -- Requires localization
L["SubType"] = "Untergruppe"
L["SwapsPerCycle"] = "Vertauschungen pro Zyklus"
L["SwapsPerCycle:desc"] = "In jedem Zyklus vertauscht Genie eine bestimmte Anzahl von Gegenständen. Setze den Wert auf 0(Null), wenn Genie alle Gegenstände auf einmal vertauschen soll."
L["Sync"] = "Sync"
L["TRADE_CLOSED"] = "Mit jemandem gehandelt"
L["TStID"] = "Agk" -- Needs review
L["Text"] = "Text"
L["Texture"] = "Symbol"
L["Tooltip"] = "Tooltip" -- Requires localization
L["Type"] = "Gruppe"
L["Unique"] = "Einzigartig"
L["Unknown"] = "Unbekannt"
L["Update"] = "Aktualisieren"
L["Update a class"] = "Aktualisiere eine Klasse"
L["Updated"] = "Aktualisiert"
L["UseProfile"] = "Benutze Profil"
L["Version"] = "Version"
L["When"] = "When" -- Requires localization
L["Work"] = "Arbeite"
L["X added to Y"] = "X zu Y hinzugefügt"
L["X has been updated"] = "X wurde aktualisiert"
L["X is empty"] = "X ist leer"
L["X removed from Y"] = "X aus Y entfernt"
L["X renamed to Y"] = "X umbenannt zu Y"
L["bag/ bank or guildbank"] = "Taschen/ Bank oder Gildenbank"
L["iLvl"] = "Gegenstands Stufe"
L["sort_heap"] = "Heapsort"
L["sort_insert"] = "Insertionsort"
L["sort_quick3"] = "Quicksort3"
L["sort_select"] = "Selectionsort"
L["waitAfter"] = "Warte nach dem Kampf"


--[[///////////////////////////////////////////////////////////////////////////////////////
	translated auctionitemclasses

    Usage: L[L['Weapon']()] to get the translated type
    Note: Update if auctionitemclasses are added/removed
--///////////////////////////////////////////////////////////////////////////////////////]]
L["Weapon"] = function() return "aic01" end
L["Armor"] = function() return "aic02" end
L["Container"] = function() return "aic03" end
L["Consumable"] = function() return "aic04" end
L["Glyph"] = function() return "aic05" end
L["Trade Goods"] = function() return "aic06" end
L["Projectile"] = function() return "aic07" end
L["Quiver"] = function() return "aic08" end
L["Recipe"] = function() return "aic09" end
L["Gem"] = function() return "aic10" end
L["Miscellaneous"] = function() return "aic11" end
L["Quest"] = function() return "aic12" end

local itemClasses = { GetAuctionItemClasses() }
if #itemClasses > 0 then
	for i, itemClass in pairs(itemClasses) do
        local icString = "aic".. string.format('%.2d',i)
    
		L[icString] = itemClass
		local itemSubClasses = { GetAuctionItemSubClasses(i) }
		if #itemSubClasses > 0 then
			for j, itemSubClass in pairs(itemSubClasses) do
				L[icString..string.format('%.2d',j)] = itemClass .. '>' .. itemSubClass
			end
		else
			L[icString.. "00"] = itemClass
		end
	end
end
