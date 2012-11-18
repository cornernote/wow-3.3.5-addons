--
-- AutoBar Change List
--
-- Maintained by Azethoth / Toadkiller of Proudmoore.  Original author Saien of Hyjal
-- http://code.google.com/p/autobar/


--
-- Ideas:
--

-- Set operations / calculated categories.
-- Exchange profiles
-- Inventory & Instance checks
-- Buff detection: Don't show buff items if buffed already
-- Hide button option
-- Food Blend for pets.
-- Deal with charges: display them use smaller charged items first.
-- Cryolysis: (Left = use, right = conjure, middle = trade stack with current target.) If the stack is not full it conjures till it is.  Ctrl-force trade.
-- Mmm drag & drop between the bar and bags / trade etc. ?
-- A button specific checkbox to always show the popups


--[[
= What will slip till after release? =
 * Conditonal Bars / Buttons
  * Popup on shift.  There is just one more bug to iron out in the test state machine then this can be incorporated.
  * Stance, form and macro conditional bars / buttons.
  * Boss based Buttons, Bars
  * Modifier key support for buttons
 * Reset Button for built in Bars
 * Reset Button for built in Buttons
 * Reset Button for AutoBar
 * Documentation Plugin.  Basically http://code.google.com/p/autobar/wiki/Usage, cleaned up and localized.
 * Switch to GetItemIcon(itemId or itemName or itemLink or itemString) for category icons
--]]


--[[
= What is not working right now? =
 * Drag & Drop
  * Items need to be draggable onto the category in the tree part of the config.
  * Categories in a button & items inside a category need to be draggable to rearrange them
 * !LibStickyFrames-2.0
  * Fine movement controls for a selected frame (say temporary arrow keys + modifiers for 1 or 5 pixel or grid movement)
  * Grouped moving
  * Sticky Parent selection even with multiple overlapping frames.
 * Plugin architecture for buttons so this can become more of a framework
 * Buttons
  * !AutoBarButtonClassPet: for hunters(break19: left click summon, right click revive)
  * !AutoBarButtonBuffSpell would need multiple keybinds (3+ ?)
  * !AutoBarButtonER: castsequence reset = 600, Last Stand, category x, category y, button n, etc.  ER - Emergency Response.  NS heals for healers, Iceblock for mages, --> Shieldwall, Bubble for pallies
  * !AutoBarButtonFishing: Keeps track of swapped gear, equips them on combat or some kind of ctrl-click or something.  First clicks equips fishing gear then pole then applies best lure when its missing.  Then casts a line.
  * Note Petfood needs an ug to be a rightclick hunter eats & left click pet eats.
 * Categories:
   * Allow GetItemInfo type / subType specification for a category
   * Allow direct selection of a [http://www.wowace.com/wiki/LibPeriodicTable-3.1 LibPeriodicTable-3.1] set
   * Optional priority set (that takes precedence over the regular set for a particular item's value.  For example conjured food over regular)
   * Split out !ItemList as a translation / grouping / priority layer on top of PT3.
--]]

--
-- Releases
--

--[[
= What is still planned for the new version? =
--]]

--[[
[b]Report missing items:[/b] [url=http://code.google.com/p/autobar/issues/list?q=label%3AMissingItem&can=1]List of reported missing items[/url]
[COLOR="Purple"][b]Official web site for documentation: [/b][/COLOR] http://code.google.com/p/autobar
[url=http://code.google.com/p/autobar/wiki/FAQ]FAQ[/url]
[url=http://code.google.com/p/autobar/issues/list]Bug Reports, Feature or Documentation Requests[/url]
[url=http://code.google.com/p/autobar/wiki/ErrorsBugs]Errors Bugs[/url]

[url=http://www.wowace.com/wiki/Debugging]Debugging[/url]

"$Revision: 760 $"

print

--]]
-- Trelis: disable/enable bar during move bars or buttons orphans it and other glitches.
-- Shuffle: handle locations and cooldowns and equipped items.
-- Shuffle: swap popup icons properly.
-- Finish LibStickyFrames: needs grouped dragging.

-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua ClassSpell.Druid.Restoration
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Misc.Usable.Starts
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Consumable
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Gear
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Misc
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Tradeskill


-- v3.00.08.18 beta (r)
-- Fix Viper Sting
-- Fix missing nocombat from Travel Button for regular flight form

-- v3.00.08.17 beta (r746)
-- Consumable.Food.Feast -> category "Food: Feast"
-- Feast added to the clickable button.  (Need to split it into multiple buttons, its getting unwieldy).
-- In move button mode, Button name is now the tooltip once more.
-- Misc.Openable -> category "Openable"
-- Openable button.  Still missing mussels and clams atm.  Need to get wowhead to classify them right.
-- Drag setting.  Allows dragging of certain types off the button using the cursor.
-- For instance the new Openable Button, you can drag a locked box into will not trade for a Rogue to pick.

-- v3.00.08.16 beta (r741)
-- Handle LibBabble changes

-- v3.00.08.15 beta (r738)
-- Disable minimap button setting added to gui config.
-- Warlock Soul Link added to Shield Button
-- Titanium Seal of Dalaran
-- Fix custom bars not showing up in Button Location popup
-- Upgrade "Add Button" for Bar options to select from all buttons now that it is scrollable.
-- Fix Button Moving issues in Bar options.
-- Some fixes for the patch.

-- v3.00.03.14 beta (r728)
-- Upgrade database to match Ace3 Config requirements (no spaces in custom object names)

-- v3.00.03.13 beta (r726)
-- Fix ButtonFacade options call to its new Blizzard Panel interface
-- Horn of Winter added to class buffs
-- AutoBar version info added to the AutoBar tab of options.
-- DK potion added.
-- Various quest items etc.

-- v3.00.02.12 beta (r718)
-- Fix logEvents and logPerformance not saving in config
-- Starts Quest category created and added to Quest Button
-- Cooldown.Mana / Health.Anywhere sets + categories added.
-- Fix endless mana and health potions
-- Fix German high level Kochen and Alchemie
-- Add Misc.Usable.Fun to Quest button
-- Shields Button.  This is for short duration damage prevention / avoidance / mitigation during combat.

-- v3.00.02.11 beta (r708)
-- Mostly working Ace3 Config.  No dropdown yet.

-- 3.00.02.10 alpha (r702)
-- Rewrite options UI in Ace3Config
-- Fix UpdateUsable to make pets always display as usable and mounts outside of combat.
-- Feral Spirit added to Shaman pets
-- Stop disabling spell based weapon buffs for Offhand Weapon Buff Button.  Makes it useful for Shamans.
-- Dalaran teleport and portal for Mages.
-- Warlock stones
-- Conjure Refreshment
-- Aspect of the Dragonhawk
-- Runic mana / health + injectors
-- Added the 5 new rogue poisons
-- Crippling and mind numbing reduced to just one poison
-- Runeforging & Death Gate
-- Wrath Elixir
-- Bone Shield added to Class Buff Button

--- Fix always popup
--- Shift popup - rightclick not working.
--- Buttons 3-5 for various actions like no execute (currently), no move for a popup.
--- Range feedback
--- per button event registration etc.
--- Feast
--- Unshapeshift Button
--- Raise Dead Button

-- 3.00.02.09 beta (r660)
-- Fix Tooltip not going away for popup buttons or macro buttons
-- Fix mount button to properly remember ground and flying mounts across login
-- LibDataBroker-1.1 support
-- Fix direct drag onto a button
-- Switch from fubarplugin to LibDBIcon-1.0 for minimap icon support
-- Remove Sanctity Aura
-- Suppress noob spells like Demon Skin and Frost Armor if Ice and and Demon Armor are available
-- Show grid when dragging usable items / spells / macros
-- Fix potion cooldowns in combat: disable on use, show cooldown only out of combat.

-- 3.00.02.08 beta (r644)
-- Actually added Blessing of Sanctuary back for real.  Honest.
-- Proper mount tooltip
-- A Letter from the Keeper of the Rolls 22723
-- Rework tooltip scheme a bit.
-- Fix KeyBound mode bug that kills popups
-- Fix Show Tooltips in Combat
-- Split popups longer than 8 buttons into a wide block instead of a single row
-- Fix modifier-clicks
-- New pets and trinkets according to wowhead
-- Critters now featured on the pet button
-- Pickled Egg 38427
-- Grim Guzzler Boar 11444
-- Rock-Salted Pretzel 38428
-- Blackrock Fortified Water 38431
-- Blackrock Mineral Water 38430
-- Blackrock Spring Water 38429

-- 3.00.02.07 beta (r635)
-- Sync PT3 error fix.

-- 3.00.02.06 beta (r633)
-- Focus Magic
-- LibKeyBound calls fixed.  You should once more be able to bind keys in KeyBound mode (alt-click on the AutoBar button)
-- Remove "doubled" buttons when the Button is not Arrange on Use.
-- LibKeyBoundExtra works again.  This lets you go into KeyBound mode and hover over and bind keys to items in the macro and spell books.
-- Aspect of Neptulon 17310
-- Popup on Shift (requires relog / ReloadUI).  Button specific setting only.
-- Make "Show Tooltip" work again.
-- Consumable.Weapon Buff.Firestone
-- Consumable.Weapon Buff.Spellstone
-- Ice Barrier 11426
-- New Food items thanks to Gazmik of Feed-O-Matic fame
-- Temporarily force existing configs to recognize DEATHKNIGHT (Basic & Extra bars should show up)

-- 3.00.00.05 beta (r627)
-- Blessing of Sanctuary added back
-- Scroll of Recall 37118,44314,44315
-- Fix fadeout
-- Support Death Knight
-- Fix Arrange on Use
-- Add Mount Names to Tooltip

-- 3.00.00.04 alpha (r616)
-- Tooltips
-- Inscription and Milling added to crafting button
-- Fixed Curse of Elements, Curse of Tongues, Curse of Weakness
-- Removed Curse of Shadow
-- Fixed invalid tooltip link error for shuffle buttons

-- 3.00.00.03 alpha ()
-- ButtonFacade button size fix
-- Divine Shield now only single rank adjustment
-- AutoBarButtonER fix for druids: use NS Healing Touch, not Regrowth since you can stay in tree now.
-- Mounts first cut.  Dimmed out till they are properly supported.
-- Remove Grace of Air Totem, Tranquil Air Totem, Windwall Totem
-- Support spells like critters & mounts that do not obey regular GetSpellInfo api
-- Fix shaman weapon spells.
-- Add Earthliving Weapon
-- Adjust Shadowmeld spellId
-- Handle nil case when no mounts have been converted yet.

-- 3.00.00.02 alpha ()
-- Fix anchor button not working for popup buttons
-- Fix padding between buttons

-- 3.00.00.01 alpha ()
-- Blizzcon checkin.

-- 3.00.00.00 alpha ()
-- First cut at 3.0.  Popups flaky unless padding set to 0.

-- 2.04.03.01 release (79885)
-- Fix Stealth button not working for mages.
-- Restore deleted keys in ruRU
-- For spell counts dont display right click count if it is the same spell as left click.
-- Vengeful Nether Drake 37676
-- Swift Zhevra Mount
-- Gold Medal 37297, Empty Thaumaturgy Vessel 7866

-- 2.04.02.56 beta (78817)
-- Switch to GetSpellCount.  0 or # reagent thingies left.
-- Fix LibStub call
-- Fix InCombat SPELLS_CHANGED calls to be delayed
-- Add Cancel (Revert) and Okay (Commit) to LibKeyBound.  Remove close box.  Toggling Commits as well.
-- Inner Fire added for Priests
-- Fix nil value in SetCount
-- Allow dragging spells from AutoBar to regular action bars during Move Button Mode.
-- Fix one source of popups staying open
-- AutoBarButtonCooldownPotionCombat (Heroic Potion, Destruction Potion ...)
-- AutoBarButtonCooldownStoneCombat (Nightmare Seed, Flamecap, Fel Blossom, ...)
-- ruRU, esMX
-- For Blizzard macros, use name, not number to index them.
-- Drop setting - if checked allows items to be dragged onto the custom button at any time
-- Always Popup setting for buttons
-- Water Breathing and Water Walking for Shaman Class Buff Button
-- Bat Bites 27636 Meat.Bonus -> Meat.Basic
-- Hyjal Nectar 18300
-- Scourgebane Draught 22779
-- Scourgebane Infusion 22778
-- Various Summer Festival Items
-- Nether Ray Fry, Tainted Core, Naj'entus Spine
-- Fix New Category Item Button

-- 2.04.02.55 beta ()
-- Added GridLayoutFrame to list of stuff u can stick bars to
-- Finally do a proper mount button (a Macro Button) including form switching, automatic flying vs ground selection, etc.
-- StartsQuest added back in to Quest Button
-- FadeOut Delay added.
-- Bulletproof LibStickyFrame callbacks
-- Simplify FadeOut code
-- Right click totem button destroys that totem type.
-- Remove AutoBarButtonStealth from Priests.  They do not have stealth.
-- Add all conjured foods to Pet Food including biscuits.
-- Class Buff: Shaman Water Shield, Earth Shield, Lightning Shield
-- Fixed flaw in the shared layout settings when switching from class back to account
-- Fixed update bug when switching shared for Bar Position
-- Fix initial condition and update issues with flyable
-- Rework custom categories.  Spells had issues and need to be redragged from your spellbook.
-- LibKeyBoundExtra-1.0.  Allows binding to spells and macros right in the spell book and macro UI

-- 2.04.02.54 beta (75476)
-- Added bar location dropdown to buttons for easy movement or assignment to a bar
-- Use LibKeyBound:ToShortKey for AutoBar key display
-- AutoBarButtonStealth: added Rogue Priest Mage. Shadowmeld added if present for other classes.  Need to figure out how the two combine for NE Druid, Rogue Priest Mage.
-- Seal category added for Paladins
-- Integrate AutoBar custom bindings with LibKeyBound callbacks so Blizzard bindings get set as well.  First Cut.
-- Amplify Magic, Dampen Magic added to Class Buff Button.
-- Debuff: Multiple category - faerie fires, insect swarm, curses, Hex of Weakness
-- Debuff: Single category - hunter stings, mage slow spell
-- AutoBarButtonDebuff: Debuff: Multiple and Debuff: Single categories.
-- Fix CompactBars.  Upgrade RemoveDuplicateButtons to handle duplicates within a bar.
-- Show keybinds for Custom Buttons

-- 2.04.02.53 beta (75141)
-- Minimap / FuBar Button overhaul:
-- Left-Click: Open Options GUI. This toggles GUI now. Needs waterfall-1.0.
-- Right-Click: Open Dropdown UI
-- Alt-Click: Key Bindings. -> LibKeyBound-1.0  (yellow background)
-- Ctrl-Shift-Click: Skin the Buttons. Needs ButtonFacade.
-- Ctrl-Click: Move the Buttons
-- Shift-Click: Move the Bars
-- AutoBarButtonCharge Shadowstep added for Rogues
-- Fix locale issues with Charge Button.  Tx SunTsu!
-- AutoBarButtonTravel Ghost Wolf added for Shamans
-- AutoBarButtonER added for all classes except locks
-- Handle Colors for ButtonFacade, as well as settings at AutoBar level.
-- Category Boss Items added, Misc.Usable.Permanent.  On priority, Tears of the Goddess so far.  Eventually needs boss detection.
-- Remove remaining skinning of Blizzard buttons code from AutoBar.
-- Protovoltaic Magneto Collector 30656
-- Amani Hex Stick 33865
-- Repolarized Magneto Sphere 30818
-- Multi-Spectrum Light Trap 30852
-- Temporal Phase Modulator 30742
-- Voodoo Skull 33081
-- Medicinal Drake Essence 31437
-- Condensed Mana Powder 23386
-- Add LibKeyBound-1.0 to toc dependencies and embeds
-- Tarkumi's tooltip changes
-- Remove category from cooldown stone rejuv, not potion rejuv.
-- Move to LibStickyFrames-2.0 for dragging.
-- Switch to teal for keybind mode.
-- Most of the modes are now exclusive, and will turn off others that are on when activated.
-- Make AutoBar and Bar level BF Colors default to {}
-- Remove Style settings from AutoBar.  Skinning is now exclusively from ButtonFacade
-- Fix bar position saving and callback errors.
-- Add cooldowns for totem buttons based on totems not gcd
-- Implement dbVersion = 1.  Deletes old bars and customBarList tables. Fixes crash on Button or Bar create for non-resetted SVs.
-- Inferno and RitualOfDoom added to warlock class pet button
-- fix gaping buttons
-- Add Eagle Eye to pet skills.  It isn't but it sounds like it is.
-- Added some missing keys for LibKeyBound:ToShortKey
-- Localize the shortened versions of the keys
-- Remove the macro ui and spell book code
-- Switch the /keybound to /libkeybound so the lib and the old code can be used together.

-- 2.04.01.52 beta (74135)
-- Actually set popupHeader frame to DIALOG, dont just talk about doing it.
-- Adjust bar FrameStrata immediately
-- frFR: Upgraded some escaped characters to the actual ones.
-- itIT: Mostly a clone of frFR since it doesnt have bogus escape sequences in it.  Needs actual translation
-- Allow Drum Rotation button to be disabled again.
-- Implement gloss & background hiding / showing for popups.
-- 33079 Murloc Costume
-- Expose the hide attribute of a Bar.  This is what gets toggled on when you are in Move Buttons mode and click a bar from green to red.
-- Only Generate The Top Level Options By Default.  Generate Full Options Only When Opening Gui Or Drop Down List.  Saves About 500K Of Memory When Not Changing Options.
-- Fix drag frames when Moving Bars
-- Give Move Bars coloring precedence over Move Buttons
-- New PT3.1 File for AutoBar.  It loads subsets of Misc, Gear and Tradeskill.
-- The other 3 set groups are now added to their respective file, but with an unchangeable rev number from the dawn of PT3.1.
-- Any loading of Misc, Gear or Tradeskill will thus replace them
-- Fix right click on Bar during Move the Bars.
-- Add option to disable conjure button on food and water.  Empty food & empty water will still conjure.
-- Use button Name not key for Add Button
-- Start switching to LibStickyFrames-2.0
-- Internationalize {star} & {skull} used in Rotation Drums Button
-- Arrange on use for spells and macros.  Issue with not showing regular items when mixed with spells in a category remains.
-- Fix outlining issue when clicking on popups.  Introduce equipped green border scaling issue instead.
-- Fix tooltip error during Move the Buttons
-- Save ButtonFacade Colors
-- Consolidate UpdateUsable code for both button types.
-- Obey Category location settings for usable display
-- ZONE_CHANGED_NEW_AREA: Add 3 second update delay for sorted because Zone info is not available when ZONE_CHANGED_NEW_AREA fires.  Wtf is the point of firing it?
-- Location specific items should now work.  For example Nethergon Energy.
-- Fix stonard portal + reagent counts for new teleports and portals
-- Brewfest Brew 33929
-- Don Carlos Tequila 28284
-- First cut of Shuffle (<Button>/Shuffle):
--- It shuffles consumable items for a particular button during combat.
--- If you move items around on it, you may need to click twice to actually get something to click on in the click spot of your bag.
--- This version does not yet care about cooldown or location or anything other than Blizzard API saying it is usable.
-- Drop out of Move Buttons mode at start of combat.
-- Right click on buttons to change their settings during Move Buttons mode
-- Added the less verbose Log Events debug setting.
-- Babble-Zone-2.2 --> LibBabble-Zone-3.0
-- Add Show Extended Tooltips setting.  Enabled allows comparison tooltips and extended tips by other mods.
-- Remove AceLocale 2.2
-- AutoBarButtonCharge A Charge / Intercept / Intervene / Sprint Button for druids, warriors

-- 2.04.01.51 beta (72832)
-- Switch to ButtonFacade.  This completely drops cyCircled support for AutoBar.
-- Include the ButtonFacade and associated skin you like.  Use the ButtonFacade interface to set the skin, including DreamLayout.
-- If you still use cyCircled for other mods you will need to update to r72825+.
-- Dump Style.lua, add ButtonFacade as optional dependency.
-- Allow skinning changes from the Bar settings.
-- Added settings to announce Drum Rotation to Say, Party, Raid

-- 2.04.01.50 beta (72681)
-- Consumable.Buff Type.Both -> Consumable.Buff Type.Flask
-- Change clumsy and ambiguous "Buff: Both Battle and Guardian Elixir" to "Buff: Flask"
-- All hail bobbyblade who found the crash wow error: Using "|" in a string followed by numbers is bad M'Kay.
-- Update Button Category name when changed.
-- Tarkumi: fix for right click spell tooltip.
-- Remove empty Consumable.Buff.Mana.Self, it breaks the multiset iterator
-- Fix custom category keys & upgrade incorrect ones
-- Fix Category renaming
-- Implement dragging Blizzard macros to a Custom Category, first cut
-- New Macro button for Category Items to create a Custom Macro item, first cut
-- Editable Name and macro text field.

-- 2.04.01.49 beta (72480)
-- Reagent counts for select spells.  Specifically did not do all the soulshard spells of warlocks, nor rogue poisons.
-- GameTooltip:SetOwner(self, "ANCHOR_PRESERVE").  Perhaps this will clear up tooltip position issues?
-- AutoBarButtonRotationDrums: this is the first cut at it.
-- The left click spell + the right click spell counts are split into <left click spell count>/<right click spell count>
-- For quantity over 99 show * in the count
-- Only show one count if left & right click spell is the same.
-- AutoBarButton.lua:1481: attempt to concatenate local 'itemName' fixed
-- AutoBarDB.lua:1203: attempt to index local 'barDB' (a nil value) fix
-- New underlying architecture for Macros.  Convert Macro buttons to use it.
-- WaterfallDragLink support for built in macros, rip out LibBabbleSpell, fix icons for items, spells and macros.
-- Drag & drop of built in macros to a custom category
-- Clean up icon texture code.  This should solve the empty button issue in at least some cases.
-- Do not allow empty string for custom names, nor double quote or period
-- Cancel Fade while hovering over popups as well.
-- Add warning for unknown PT3.1 sets
-- Add tooltip if right clicking will cast a spell
-- Trinket2 now equips correctly.  Still has cosmetic issues.
-- Fix some code necrosis
-- Dump the obsolete category rearrange code.
-- Delete drag handle icons
-- X-51 Nether-Rocket & X-TREME X-51 35225:60, 35226:280
-- 7307:75 Flesh Eating Worm
-- Redcap Toadstool 25550:70, drops in Zangar, assuming its lvl 70 viable.

-- 2.04.01.48 beta (71858)
-- Remove Armor & WeaponSmith Popups
-- Fix bad global reference barPositionDBList -> AutoBar.barPositionDBList
-- Fix hitRectPadding for negative padding values
-- Increase minimum hitRectPadding to 4
-- Bar frame padding >= 0 only
-- Added holy water code to combat the undead zombie buttons that kept returning after removal.
-- Fix Tracking button
-- Fix removal of Buttons from disabled Bar
-- Fix spellCrusaderAura, _, spellCrusaderAuraIcon = GetSpellInfo(32223)
-- Fix Button Delete and Remove using layout instead of buttons share.
-- Fix crash when enabling a bar during Move mode.
-- Fix Travel Form case for outland and in combat to use Cheeta and not Flight Form
-- Consumable.Cooldown.Drums
-- Fix some PT3.1 out of sync sets
-- AutoBarButtonCooldownDrums drums, nets, other drum cooldown stuff
-- Upgrade Remove and Delete Button description text
-- Add Babble-Zone-2.2 dependency to toc
-- Make ClampedToScreen an AutoBar option.  Requires reload to take effect / disable for now. Default is false.
-- Add specific cancel fadeOut in combat setting

-- 2.04.01.47 beta (71664)
-- Add FadeOut Time and FadeOut Alpha
-- Increase fadeOut update frequency
-- Bar.frame:SetClampedToScreen(true).  This should prevent Bars from getting scaled or moved offscreen.
-- Popups now have the same padding as the bar.  HitRectInsets adjusted to compensate.
-- Adjust for padding on bars.  Bars with padding will now have buttons centered inside them with padding space around the buttons (Move Bar mode illustrates this).
-- Add option to show tooltips in combat.  Requires showTooltips to be set.
-- ButtonPaste can no longer duplicate buttons in cross bar drags.
-- Added code to remove duplicate buttons due to sharing changes or dragging from class to account bars.
-- Syncronize Button's placement info with actual placement
-- Fix default Tracking Button icon

-- 2.04.01.46 beta (71475)
-- Create Paper Airplane, Flying Machine 45131,45135  --> 34497, 34499
-- Remove spells from PT3.1 Throw Paper Airplane Impact 45130,45134
-- Switch to GetSpellInfo based spell handling: name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName or spellLink)
-- Rip out LibBabble-Spell-3.0
-- GameTooltip_ShowCompareItem() added for item links in tooltip
-- Initial work on custom attributes for Buttons
-- Dragging to bar drop spot now appends button instead of putting it into position 1
-- spellSummonFelsteed = GetSpellInfo(5784) fixed
-- Pure Energy 31451
-- spellRitualOfSouls, _, spellRitualOfSoulsIcon = GetSpellInfo(29893) fixed

-- 2.04.01.45 beta (71069)
-- Fix the tooltip for charged items to show charges on first found item (item that will be used on click).
-- Fix cooldown for spells not showing up
-- Remove reset options till they are implemented.
-- Fix rename of Custom Buttons from the Bar Button List.
-- Add SetInventoryItem("player", slot) to item tooltip code to handle equipped stuff
-- Detectar Invisibilidad --> Detectar invisibilidad for esES
-- Switch texture code from BabbleSpell to GetSpellInfo
-- Allow dropping of spells onto a Button with a custom category in Move Button mode.
-- Add individual Ctrl, Alt, Shift settings to cancel fadeOut with.
-- Fix texture path issue for spell categories.
-- Tears of the Goddess 24494
-- lanatha: Switch all of AutoBarButton to SpellInfo
-- Bring back green border for equipped items
-- Fix locale issue with custom categories and spells.  Thanks to StiviS.
-- Fix broken AutoBar:GetSharedBarDB(barKey, sharedVar) function.  Inspired by Thorlin.

-- 2.04.01.44 beta
-- Update Button & Bar's shared sections, as well as the unplaced Button list before creating options.  This avoids possible corrupting double placement of buttons.
-- Only set Offhand Weapon Buff Button to enabled on creation.

-- 2.04.01.43 alpha
-- Fix sharing for Buttons

-- 2.04.01.42 alpha
-- Documentation for the Alpha is now on  http://code.google.com/p/autobar
-- Set AutoBar to active if it is not.
-- Add additional porting items to Hearth.  BT attunement, Legendary Staff kara.
-- Fix custom Categories to be keyed not indexed
-- lanatha: Fix AutoBar.Class.Button.prototype:GetIconTexture() for "showEmptyButtons" or "alwaysShow"

-- 2.04.01.41 alpha
-- Adjust to "LibBabble-Spell-3.0" changes
-- Hide bar buttons on delete
-- Avoid reusing keys in same session to avoid issues with Blizzard frame names associated with Bars & Buttons
-- Bear Flank, Charred Bear Kabobs, Juicy Bear Burger

-- 2.04.01.40 alpha
-- Orb of Murloc Control 34483
-- Razorthorn Flayer Gland 34255
-- Fixed a bunch of issues with renaming and deleting buttons.
-- Fixed the AutoBarClassButton.lua:984 global ref error
-- Fixed the AutoBarSearch.lua:964 failure to remove data for deleted buttons

-- 2.04.01.39 alpha
-- Update waterfall options after a button move.

-- 2.04.01.38 alpha
-- Syncronize keys to names for Custom Bars & Buttons on rename across all characters and classes in the db
-- Fix bar alignment --> bar disapearance
-- AutoBarButtonFoodCombo: Prioritize conjured biscuits
-- Split out new localized strings
-- Fix trinket button to use equipped item

-- 2.04.01.37 alpha
-- Conjured Manna Biscuit missing from Pet Food
-- Unchecking enable now makes the Bar disapear
-- During combat start using next stack of a particular item once the first stack is used up.
-- During combat grey out unusable bag and inventory items
-- Display macro buttons
-- Tooltip for macro buttons displays Button Name and the macro text
-- Fix French (& other locale) druid buttons

-- 2.04.01.36 alpha
-- Fix rearrangeOnUse for hunter aspects, traps, etc.  Remember the last used item across logins.  Button only property now, no longer on categories.
-- Bar renaming
-- Remove obsolete Profile stuff
-- Ata'mal Armaments 34500
-- Afrazi Forest Strider Drumstick 33254
-- Tradeskill.Tool.Fishing.Other: Rumseys Lager 34832

-- 2.04.01.35 alpha
-- Fix perma greyout of buttons
-- Holding modifier cancels fadeOut
-- Implement both cases of Add, Delete and Remove of buttons: Directly on a Bar and in the Buttons section
-- Ritual of refreshment
-- Sharing Bar Buttons
-- Sharing Bar Layout
-- Sharing Bar Location

-- 2.04.01.34 alpha
-- fadeOut
-- Populate Extras
-- selfCastRightClick check disabled for AutoBarButtonClassBuff, this should allow group buffs to be cast on non party groups (GotW etc)
-- Fixed PT3.1 set names for bullets & arrows categories.
-- Toothy's Bucket 33816
-- Chuck's Bucket 35350
-- Muckbreath's Bucket 33818
-- Snarly's Bucket 35349
-- Luminous Bluetail 35287
-- Giant Sunfish 35285:7500
-- Blessed Weapon Coating 34538
-- Righteous Weapon Coating 34539

-- 2.04.00.33 alpha
-- Added "Remove" button so you can remove buttons from a bar.
-- Fixed Categories addition and deletion
-- Fixed Hunter AutoBarButtonAura not being placed
-- AutoBarButtonWarlockStones (All non health stones)
-- Naaru Ration 34780
-- Reins of the Black War Elekk 35906
-- Phoenix Hatchling 35504
-- Dragon Kite 34493
-- Brogg's Totem 33088
-- Energized Totem 33091
-- StoneMaul Banner 33095
-- Gift of Naias 23680
-- Zapthrottle Mote Extractor 23821
-- Toxic Fogger - 5638
-- Salt Shaker 15846
-- Sharpened Fish Hook 34861
-- Warstrider & White Hawkstrider 34129:100,35513:100

-- 2.04.00.32 alpha
-- Ditch AceLocale & roll own again.  This allows adding more translations on the fly.
-- Synchronized all locales, using English for missing translations.
-- AutoBarButtonWarlockStones Button for warlock non-health stones
-- Keybind added for crafting so u can de & prospect more better
-- SPELL_PICK_LOCK = BS["Pick Lock"], this should actually pick locks then, thanks Hoern
-- Demon Skin & Fel Armor added to Warlock Class Buff Button
-- Consumable.Cooldown.Potion.Rejuvenation.Regular
-- Consumable.Cooldown.Potion.Rejuvenation.Dreamless Sleep
-- Consumable.Food.Buff.Hit Rating
-- Zeppit's Crystal - 31815
-- 11412 Nagmara's Vial
-- Rod of Purification - 31610
-- Protectorate Disruptor - 29618
-- 34493 Dragon Kite
-- 34492 Rocket Chicken
-- Orb Collecting Totem - 31668
-- Bloodthistle 22710
-- Nimboya's Pikes 9319, 15002
-- Blessed Medallion of Karabor - 32757
-- New dailies

-- 2.03.00.31 beta (55463)
-- AutoBarButtonStance: Stances for warriors.  First cut at it.
--	Right clicking it swaps to Defensive if not in it, or Berserker if in Defensive.
--	There is a keybinding but it does nothing since you are already in that stance.  open for suggestions.  Maybe left click switches to 1 other stance, right click to the other?
--  My first mod treated aspects / auras / shadowfrom / stealth / stances / forms the same way.  Possibly see if that still makes sense & thus add support for those classes.
-- Mostly working button drag between bars.
-- 33999 Cenarion War Hippogryph
-- 33072 Tabetha's Torch
-- 33101 Captured Totem

-- 2.03.00.30 beta (55335)
-- Prayer of Shadow Protection added to priest buff button
-- Fix Pick Lock button & add seaforium & skeleton keys to it.
-- Make Freezing trap the default one.
-- Mechanical Yeti 15778
-- 16991 Triage Bandage
-- 24008 Dried Mushroom Rations
-- 33113 Witchbane Torch
-- 6807 Frog Leg Stew

-- 2.03.00.29 beta (55235)
-- Eye of Kilrogg added to Class Pet
-- Shift key disables snapping.
-- Added a bunch of beast spells to Hunter Class Pet.  Tx, roy7.
-- Turn off arrange on use for Fishing, and make casting have priority.
-- fix alpha setting
-- Misc.Usable.StartsQuest added to LibPeriodicTable-3.1-Misc.lua
-- AutoBarButtonClassBuff: Class Buff, so Mark of The Wild left click, Gift of the Wild right, etc.
--    Special note: Warriors can choose from commanding left battle right or battle left & commanding right.
-- AutoBarButtonHearth: Portals on the Hearth button upgraded to do teleport on left click, portal on right click.
-- Notice that the right click spell support defaults to the more expensive operation being on right click.
-- That means a keybind is to the option you are likely to cast during combat.
-- 6635 Earth Sapta, 27317 Elemental Sapta, 6636 Fire Sapta, 6637 Water Sapta
-- 23819 Heavy Seaforium
-- 33825 Skullfish Soup
-- 23123 Blessed Wizard Oil
-- Crystal Charge 11566, Gorishi Queen Lure 11833, Kibler's Bits 33874, Broiled Bloodfin 33867
-- 33837,33851,33852 Cooking Pots

-- 2.03.00.28 beta (54721)
-- Move to LibPeriodicTable-3.1, some items may not make the transition, just report them again.
-- Moved the mining for trinkets & StartsQuest over from PeriodicTable-3.0
-- 34478 Tiny Spore Bat
-- 34062 Mana biscuits
-- "Find Fish" icon added to LibBabbleSpell-3.0
-- 34060, 34061 Engineer Mounts
-- 33934 Crystal Healing Potion, 33935 Crystal Mana Potion

-- 2.02.03.27 beta (54547)
-- The Fire Resistance Totem --> Water Totems, Frost Resistance Totem --> Fire Totems
-- Cooldowns now working for spells.
-- 6635 Earth Sapta
-- AutoBarButtonClassPet: "Class Pet" for hunters mages shamans warlocks priests druids.
-- Toc change
-- Add PT3 Gear set so Trinkets can show up
-- * There is a StickyMode that is set via stickyModeFunc and LibStickyFrames:StickyMode()
-- * For all participating frames in StickyMode:
-- ** Frames are colored so they can be seen using standard colors in LibStickyFrames.Color*
-- ** Snapping and sticking can be to some select Blizzard frames

-- 2.02.03.26 beta (54353)
-- Fix the defaults button insertion code so water can live next to food once more after a reset.
-- LibStickyFrames-1.0
--		Dragging while holding ctrl lets you stick to a frame as well as snap to it (no x & y offsets yet)
-- Change Refresh to not reset but to just do refresh + some corruption checks
-- Upgraded form buttons to use cancelform.  this should make them usable on PTR for now:
--	/cancelform [stance:1/2/4/5/6]
--	/dismount [mounted]
--	/cast [nostance] Cat Form; [stealth] Prowl
-- 32768 Reins of the Raven Lord
-- 33053:7500 moved to fish.combo
-- ornate spyglass-5507, explosive sheep-4384, Colossal Parachute-10684, edit2:Horn of Hatetalon-9530
-- 16114 Foreman's Blackjack

-- 2.02.03.25 beta (54230)
-- The Cipher of Damnation 30657
-- LibStickyFrames-1.0
--		Registering mechanism for subscribing mods
-- Default the all in one heal & mana / rage / energy buttons to disabled in favour of the cooldown based buttons.

-- 2.02.03.24 beta (54095)
-- Poisons added to crafting button.  Note that Alchemy button just will not & can not work for now so its commented out.
-- Fixed an issue where skinning stops for buttons after disabled buttons after a reload.
-- Fix issue where disabling buttons makes bar disapear after relog.
-- Fixed an issue with enabling a button after login needing a couple of extra clicks on enable to show up.
-- Added rage & energy to the cooldown potion mana button.
-- Fixed the entire Custom Category -> Custom Button cycle.

-- 2.02.03.23 beta (53918)
-- Reins of the Swift Spectral Tiger
-- AutoBarButtonPickLock: Locked containers and it auto-picks on right click.  Untested, no rogue.
-- AutoBarButtonFishing: Added the fishing spell to the list.
-- Keybinds for buttons: Potion & Stone cooldown, PickLock, Totems, Petfood, Sting, Trap
--   Note Petfood needs an ug to be a rightclick

-- 2.02.03.22 beta (53845)
-- Fix profile reset & bar reset to work without errors & to actually just update like they should.

-- 2.02.03.21 beta (53845)
-- AutoBarButtonBuffWeapon2: Offhand buff weapon button for Hunters as well.
-- Fix tooltip setting to work outside Move Buttons mode which auto enables it.
-- Arrange on use default true for Hunter / Paladin Aura button.
-- Button highlighting in move mode: green active, blue empty, red otherwise.
-- "Always Show" added to button options.
--   This prevents a button from following the collapse setting.
--   If the button has no categories, enabling this will create a spacer button.
-- Potion & Stone cooldown buttons: Mana, Health, Rejuvenation.  Note that you need to pick between these & the regular all in one Recovery & Healing Buttons.
-- Extend row & column max visible to 32.  Note you can get up to 64 per bar by varying rows & columns.
-- 34440 Mad Alchemist's Potion

-- 2.02.03.20 beta (53633)
-- Learning new spells now updates buttons.
-- Adding or deleting a new Button updates it in the bar immediately.
-- In Move the Buttons mode you can now drop items onto a button with a custom category & it will be added to the custom category.
-- Only items supported atm, not spells or macros.

-- 2.02.03.19 beta (53552)
-- Switch from swapping buttons to moving them
-- Show Empty Buttons now shows Category icons if available
-- Show Button Name while in move mode
-- Autocreate default (Hearth) category for new custom buttons
-- Destruction potion & some other missing buffs
-- Fixed data rot issues with how I was using AceDB.
-- This fixes buttons mysteriously not remembering settings or gaining settings from other buttons etc.
-- Also fixes the chronic Houdini Syndrome some buttons had.
-- Legacy Custom1-6 buttons removed.

-- 2.02.03.18 beta (53340)
-- Create Spellstone added to Conjure for warlocks
-- Fix keybinds to work on login
-- Fixed Custom Button frame names to "AutoBarButtonCustom<MyCustomButtonName>Frame" for custom buttons
-- Fixed Named Button frame names to "AutoBarButton<ButtonName>Frame" for regular buttons

-- 2.02.03.17 beta (53164)
-- Fix issues with deleting and moving regular buttons or causing them to be moved.
-- Trinket1 & Trinket2 buttons.  Trinket 2 can not equip until I fix it & the Alchemy button.
-- More messing with keybinds
-- Fixed the issue with last item from top used & button disapears even though it has other items.

-- 2.02.03.16 beta ()
-- Fix issues with deleting and moving buttons with custom categories or causing them to be moved.
-- Fix cyCircled init problems & initial style not setting.
-- Fix issue with conjured food & water buttons disapearing even though they have a summon button
-- Fix issue with enabling a button not having keybind.
-- Refresh Button upgraded to actually refresh.  Should be better & faster than reload unless you have errors.
-- Sense Undead added to tracking for Paladins
-- Commented out Disenchant added for home hacking
-- Fix green/red moveable bar insets so sticky drag matches edges
-- Fix issue with wrong names due to old drag code incorrectly moving hasCustomCategories attribute.

-- 2.02.03.15 beta (52930)
-- Broom mounts, some BE quest items.
-- Stealth Button (Druid only), Priest, Rogue & Night Elf mia
-- Sting Button & Category
-- Oil of Immolation (buff), Goblin Fishing Pole (explosives)
-- Fel Blossom (buff)
-- Shield & Chest buffs added to Consumable.Buff Group.General.Self.  Targeting issues remain.
-- Fix layout centered options.  (TOP LEFT CENTER RIGHT BOTTOM)
-- Fix green bar location & size to match buttons
-- Fix Setpoint error when moving buttons.
-- Cranked up button order slider to 64.
-- Fix an update style timing issue
-- Removed Button Width & Height settings.  Use scale instead.

-- 2.02.03.14 beta (52761)
-- Fix button rearranging via waterfall options
-- Add "Move the Buttons" option (ctrl-click AutoBar icon).  Allows direct drag & drop of buttons on the bar.
-- In "Move the Buttons" mode the tooltip is the Button name
-- Make a Bar's rows * columns limit number of active Buttons displayed.
-- 30480 Fiery Warhorse's Reins
-- 33808 The Horseman's Helm
-- Ritual of Souls added to Conjure Button

-- 2.02.03.13 beta (52608)
-- Consumable.Quest.Usable -> ["Misc.Usable.Permanent"] = "Permanently Usable Items"; ["Misc.Usable.Quest"] = "Usable Quest Items";	["Misc.Usable.Replenished"] = "Replenished Items";
-- Separate Categories for these 3 sets as well.
-- Fixed issue with popups when using an item then gaining another item not showing the last item
-- Fix Create Healthstone & Create Soulstone categories

-- 2.02.03.12 beta ()
-- Fix right click on popup button not firing
-- Soulstones added to conjure button
-- Fixed an update issue on last use

-- 2.02.03.11 beta (r52346)
-- Lop off extra chunk in LibBabble-Spell-3.0 externals path

-- 2.02.03.10 beta
-- Revision property test + externals fix

-- 2.02.03.9 beta
-- Remove bindings display for old 1-24 buttons
-- Fix AutoBar/Bars Frame Level
-- Crafting buttons category.  Just to bring up the dialogs.  For actual crafting use a crafting mod that deals with the horrible API.
-- LibBabble-Spell-3.0
-- Tracking button
-- Paladin Aura / Hunter Aspect button
-- Hunter trap Button
-- Trinket category
-- Added rightClickTargetsPet true as default for PetFood
-- Rewrote Update Hierarchy
-- Fixed bars staying in move mode when changing profiles
-- Firestones added to conjure button
-- Changed X-Category from Interface Enhancements to Action Bars which is probably more appropriate for where AutoBar is headed.

-- 2.02.03.8 beta
-- Windfury Weapon not Windfury, for shaman weapon buffs.
-- Fix failure to launch style at start
-- Wafer thin improvement to rearranging buttons.  Can create phantom duplicates that go away on reset.

-- 2.02.03.7 beta
-- Added "Buff Spells: Weapon" category.  Shaman only right now.  If your class has a weapon buffing spell post it.
-- Apply styles to popup buttons as well.
-- Fix AutoBar/Bars Button Width / Height / Alpha / Rows / Columns / Popup Direction
-- Fix AutoBar/Show Count Text & AutoBar/Show Hotkey Text settings
-- Fix battleground only items to only show in BG.  Specifically fixes battle standards.
-- Deleted obsolete "Clear this Slot" category
-- Probably fixed the main / offhand button issue.

-- 2.02.03.6 beta
-- Make Custom button categories show up again
-- Buttons are reorderable now.  May cause error & needs reload.
-- Changed config title to AutoBar + version + (build number)
-- Cut back on global variables created
-- Can now create Custom Buttons from the bar options.
-- Deletion of Custom buttons ... causes error & needs reload.

-- 2.02.03.5 beta
-- Fix button update issues / leak during updates & settings changes
-- Disabling then reenabling a button needs reload to get popup again.

-- 2.02.03.4 beta
-- Key binding added for AutoBarButtonWater
-- Fix highlight on red bar

-- 2.02.03.3 beta
-- Right Click on the moveable (green) bar now works & brings up the bar's options.
-- Added a "Move the Bars" option on the fuBar & miniMap dropdown options.
-- Style settings working, including cyCircled
-- Padding still needs reload

-- 2.02.03.2 beta
-- Invert buttons for off hand buff button
-- First cut at popup direction fix (requires reload to take effect)
-- Still some refresh issues during combat

-- 2.02.03.1 beta
-- Wrangled some localization strings
-- Clean up update code a bit

-- 2.02.02.15 alpha
-- Some bug fixes.  Popups should be working now along with arrange on use of them including spells.
-- Some under the cover work on macro buttons.
-- Multiple bars working.  Only Druids will see an extra bar for now.

-- 2.02.02.14 alpha
-- Arrange on use fixed
-- Button Disabling now immediate & not till after reload
-- Custom Category name change now immediate as well
-- Started removal of old bar.

-- 2.02.00.13 alpha
-- Guardian / Battle / Both Elixir Categories added.
-- Guardian / Battle / Both Buttons added.
-- ["Consumable.Leatherworking.Drums"] = "Drums" Category added.
-- ["Consumable.Tailor.Net"] = "Nets" Category added.
-- Consumable.Leatherworking.Drums set list fixed in PT
-- Added Air, Earth, Fire & Water Totem buttons for Shamans.
-- Popup Buttons for new bars.
-- Tooltip fixed for new bars.

-- 2.02.00.12 alpha
-- Each bar has a fadeOut setting that lets the bar disapear when not hovered over.
-- Item count & hotkey & cooldown now working.
-- cyCircled will not break anymore.  (needs latest cyCircled)

-- 2.02.00.11 alpha
-- Split into bars working.  These show up in addition to the old bar.
-- Bars can be dragged & hidden / shown BT3 style.
-- Buttons on bars showing with tooltips & clickable
-- Keybinds under the AutoBar Named Buttons section bind directly to named buttons. Button order can thus be changed without messing up the keybindings for that button.
-- Dumped old config stuff.
-- Fix issues with pet feeding

-- 2.02.00.10 alpha
-- Fix startup error.  This should allow brand new people to get buttons.
-- Under the cover progress on splitting out into multiple bars.

-- 2.02.00.09 alpha
-- toc change
-- Hack for tooltips
-- Make items click again

-- 2.01.03.08 alpha
-- First cut of dragging spells into Custom Categories

-- 2.01.03.07 alpha
-- FuBar Plugin
-- Waterfall preferences
-- First cut at named buttons, much work remains

-- 2.02.00.06 beta
-- toc change
-- Make items click again

-- 2.01.02.05 beta
-- Dos Ogris & various other missing items & quest items
-- 32453:7200 Star's Tears,
-- Moved Pet Food Slot, it was obscuring Quest items for hunters
-- Infrastructure for Named Buttons

-- 2.01.02.04 beta
-- Removed a bunch of redundant categories, shifted all non spell ones to PT3, partway through being completely PT3 based.
-- Spell categories converted
-- Bottled Nethergon Energy (32902) and Bottled Nethergon Vapor (32905)
-- 11562:670 Ungoro Restore, 11952:425 Night Dragon's Breath
-- 19183 Hourglass Sand
-- Consumable.Buff.Spell Reflect.Self 20080 Sheen of Zanza
-- Misc.Hearth : Hearthsone & Ruby Slippers
-- Consumable.Buff.Free Action : 20008,5634
-- Consumable.Buff.Speed.Self added 20081:20 Swiftness of Zanza, 2459:50 Swiftness Potion
-- Misc.Battle Standard.Battleground : 18606,18607
-- Misc.Battle Standard.Alterac Valley : 19045,19046
-- Consumable.Cooldown.Stone.Mana.Other : 20520:1200,12662:1200
-- 32503 Yazzil's Poison Mutton
-- 30616 Bundle of Bloodthistle, 31360 Unfinished Headpiece, 30639 Blood Elf disguise, 32467 Vim'gol's Grimoire
-- 32686 Mingo's Fortune Giblets, 32685 Ogri'la Chicken Fingers
-- 31386 Staff of Parshah, 32578:2000 Charged Crystal Focus
-- 32680 Booterang
-- Consumable.Recovery.Stone.Other : 11951:800 Whipper Root
-- Consumable.Recovery.Stone.Warlock
-- Consumable.Buff.Water Breathing : 24421:30
-- Fix AutoBarSearch:CanCastSpell
-- Fiery Warhorse's Reins (30480), Banishing Crystal (32696)
-- 30853,29443,30175 & other quest items
-- Fix Attempt to call method 'GetProfile' (a nil value)
-- 33042:7200 Black Coffee, Buttered Trout & Fishermans Feast
-- Fix cyCircled timing issue
-- Fix weapon buff to be arrange on use again

-- 2.01.00.03 beta
-- 22850:2200 Super Rejuvenation
-- 31677:3200 Fel Mana
-- Consumable.Weapon Buff.Misc 3829 Frost Oil
-- clamlette surprise and spider sausage 17222:12,16971:12
-- Druid Swift Flight Form added to mount button
-- Use items by itemlink.  Fixes stack problems during combat.
-- Fix tooltip bug
-- Add script support
-- Consumable.Buff Group.General Caster & Melee
-- 32721:20 Skyguard Rations
-- 729 Stringy Vulture Meat
-- Consumable.Quest.Usable
-- Rumsey Rum Dark
-- AutoBarCategory.lua + BabbleZone-2.2
-- Coilfang & Tempest Keep potions
-- 32698 Wrangling Rope
-- New Elixers: 32067 Draenic Wisdom, 32062 Major Fortitude
-- Consumable.Buff.Absorb.Self.Damage 32063 Earthen Shield
-- Consumable.Buff.Resilience.Self 32068 Ironskin
-- 22849 Ironshield Potion added, bogus 22927 Recipe for it removed.
-- "Toggle the config panel" & other localizations by helium
-- Consumable.Potion.Recovery.[Healing | Mana].Blades Edge
-- Nether Ray Mounts

-- 2.01.00.02 beta
-- TOC update 20100
-- Ace2 lib update
-- Fix Consumable.Weapon Buff.Stone.Sharpening Stone
-- Move Create Healthstone to a separate button with its own category.
-- Babble-2.2 frFR Summon Dreadsteed: fix case
-- Remove some Data Rot from AutoBar.xml
-- Fix missing keybindings

-- 2.00.00.37 beta
-- Add Summon Warhorse and Summon Felsteed
-- Only parent anchor, dont specify relpoint so tinytip will be happy
-- Consumable.Buff.Shadow Power added to Caster Buffs
-- Remove unused PreClick call
-- Fix doubleclick effect
-- Cleared slot 6: protection potions.  They are all in the buff slot already.
-- Fix Shadow Power cut & paste error
-- Add support for bandaging pets.  Tx Tarkumi.
-- Remove auto added spell slots.  Spell slots now only show if explicitly added.  This should move all conjure items to the conjure slot.
-- Note that food & water have a conjure button set as lowest priority so you can just click it to make more when you run out.
-- Fix bug in pet bandage code.
-- Merge in LaoTseu's Quest Items
-- Fix Mana Citrine & Jade order
-- Fix arrangeOnUse
-- Clearer AutoBarConfig load error message.

-- 2.00.00.36 beta
-- Add missing sets to PT3 consumable

-- 2.00.00.35 beta
-- Switch from PT3 alldata to consumable, misc & tradeskill
-- Add links to Google Code Project Page

-- 2.00.00.34 beta
-- Bug Fix for 2.1.
-- Fix update issue after flying
-- Fixed bug in Sorted items Reset()
-- Fix the square glitch with cyCircled and AutoBar
-- Update AutoBar when cyCircled skin changes
-- ["Consumable.Buff.Fire Power"] = "6373:10,21546:40,22833:65",
-- ["Consumable.Buff.Frost Power"] = "17708:15,22827:55",
-- ["Consumable.Buff.Shadow Power"] = "9264:40,22835:65",
-- 28112:4410 Underspore Pod
-- 23822:2000 23823:2400 Healing and Mana Injectors
-- 30360 Lurky's Egg
-- Drums 29528:60/30 29530:15 29531:750 29529:80 29532
-- ["Consumable.Leatherworking.Drums"]		= "29528:1 29530:2 29531:3 29529:4 29532:5"
-- 22797:2000 Nightmare Seed
-- Fixed a bug in Spell scanning code that incorrectly disabled spells when scanning with low mana.
-- All weapon buffs now have a single category.
-- All classes get a weapon buff slot.  Dual wielding classes get an extra one.
-- Rogue poisons are all in the 2 weapon buff slots.
-- The weapon buff slots & category are arrange on use so the last used item becomes the default.
-- As usual, do a reset on the profile page to pick up the changes

-- 2.00.00.33 beta
-- Split out Mana Stone conjure buttons for Mages
-- Fix bg mana & heal potion categories.  Requires Reset on the profile tab.
-- Localization fix for deDE Teleport: Moonglade and Conjure Mana Stones.  Tx
-- Portals & Teleports category added.  Includes Druid, Mage, Shaman and Warlock spells
-- Edit the Class layer to get rid of it.  Needs Reset on Profile Tab to pick up the changes.
-- Mess with event delays.
-- Fix cyCircled AutoBar code to avoid skinning 288 buttons on every update

-- 2.00.00.32 beta
-- crash fix in update
-- Sort weapon poisons
-- Remove deprecated "Alterac Valley" potions.  Use PvP potions instead.
-- Reinstated Anesthetic poison category.  It is like instant but has no extra aggro & is cheaper apparently.
-- 18045:12 Tender Wolf Steak
-- Flying Mount localization
-- Spells now have their own buttons.
-- Conjure Mana Emerald added.  Babble-Spell-2.2 needs translations.  Spanish & German may have some lucky guesses
-- Druid Flight Form added
-- zhTW locale: tx helium_wong
-- 21151:15 Rumsey Rum Black Label
-- Added some performance profiling support: checkbox on profile tab to activate

-- 2.00.00.31 beta
-- New bag scan code, integrated, likely some issues left
-- 30360 Murky pet
-- 28102:60 Onslaught Elixer
-- 22927:2500 Ironshield Potion
-- 28103 Adept's Elixir
-- 31679:120 Fel Strength
-- 22837:75 Heroic Potion
-- 22828:120 Insane Strength Potion
-- 27553 Red Bull .. er Steer

-- 2.00.00.30 beta
-- Added more stuff to caster buffs.  Requires Profile tab reset.
-- Attack Power, Healing and Spell Damage Foods.  Requires Profile tab reset.
-- New bag scan code, not integrated yet but tested

-- 2.00.00.29 beta
-- Consumable.Warlock.Health Stone -> Consumable.Cooldown.Stone.Health.Warlock
-- Jeweler Stone Statues added
-- First cut at new buffs.  Default categories are buffs general, melee, caster and other.
-- Targeted buffs have lower default priority
-- More specific categories are available as well by buff type.
-- Requires a reset on the Profile Tab or manual adding of buff categories
-- Disable arrange on use for first popup button
-- Removed bogus instance dependency for flying mounts.  Awaiting patch 2.1 "canfly" or something property for final flying mount support.
-- Reorganize buff foods a bit.  Added warp burgers.
-- Add Chest and Shield Buffs

-- 2.00.00.28 beta
-- Mini Pets: Gurky [Pink Murloc Egg] itemid = 22114, Murky [Blue Murloc Egg] itemid = 20371
-- Major Combat Potions
-- Fixed right click Conjure Food for mages
-- PT3.  This is a reworked item database, if you are missing an item see above for how to report it.
-- Code to add priority to certain items.  eg. conjured food.  Not used everywhere yet.
-- New conjured food & water added

-- 2.00.00.27 beta
-- Dont lock size for cyCircled buttons
-- Dont show annoying ugly borders around buttons
-- Slightly better button click feedback

-- 2.00.00.26 beta
-- Kill the keybind tab & switch back to Blizzard KeyBind UI based keys.
-- Keys tab keys are not preserved, old ones still bound from Blizzard UI will be reused.
-- Barring bugs that finalizes the key bindings feature.
-- Allow gapping of -1
-- CanCastSpell -> AutoBarProfile:CanCastSpell
-- Zorbin's Ultra-Shrinker

-- 2.00.00.25 beta
-- Fix cyCircled code
-- Add flying mounts to defaults.  Needs reset to pick up change.
-- Extend icon gapping minimum down to 0

-- 2.00.00.24 beta
-- Chinese New Year prep: Fireworks added.
-- Dragging items from bag or character sheet now supported.
-- Can now drag items directly to the edit slots on the Slots Tab; category slots on the slot edit view;

-- 2.00.00.23 beta
-- Move Summon Charger and Summon Warhorse to the mount slot.

-- 2.00.00.22 beta
-- Split Out the button code
-- Switch to Bartender3 style buttons
-- Check for BG needed items.

-- 2.00.00.21 beta
-- TOC fix
-- Possibly fixed right click to feed pet.
-- Fixed alpha of standalone icon for spell casts (mounts etc.)
-- First cut at support for equipped items.
-- Partial fix for layout centering issues.

-- 2.00.00.20 beta
-- Removed alt & ctrl self cast in options.  Use blizz interface instead.
-- Alt / Ctrl selfcast changed to use blizz code.
-- Note that autoSelfCast is via blizzard interface options / basic / Auto Self Cast
-- Unless there are bugs Self Cast should now be a fully implemented feature.
-- Do not show a count of just 1
-- Fixed show category icons
-- Fixed one issue with the cast spells migrating to the left click.

-- 2.00.00.19 beta
-- Added "Summon Warhorse" & "Summon Felsteed" for low level pallies & locks.
-- Replaced "smartSelfCast" in config with automatic right click selfcast, as well as alt or ctrl - self cast.

-- 2.00.00.18 beta
-- Update cooldown & counts during combat.

-- 2.00.00.17 beta
-- Upgraded right click spell casts to show spell icon if no such item in inventory.  Should now work for all summoned mounts and travel forms, mana & health stones, conjured food & water.  Needs a reset.
-- Right Click to feed pet for Food: Pet Bread / Cheese / Fish / Fruit / Fungus / Meat added.  No hunter so not tested...
-- Right Click to target pet option for slot should now work again as well.  No hunter so not tested...
-- Renamed profile "Single Setup" to "Single (Classic) Setup"
-- Extra InCombatLockdown() checks in case 3rd parties call update functions or delayed callbacks get triggered during combat lockdown.
-- Fixed bug with resetting not showing basic layer slots.
-- Dock to Bartender bar 6 option

-- 2.00.00.16 beta
-- IsUsableItem check added.  Thanks turkoid.
-- Back out the callback update mechanism for buttons that are not action items.  This should fix the lag.

-- 2.00.00.15 beta
-- May have successfully added Conjure Food and Conjure Water on right click on food & water item / category.
-- Changed the Manastone code to look for the first castable one in order (on init so far only).
-- Upgraded deDE to have all the entries of the enUS locale.  Should fix use of deDE with enGB.
-- Mana Emerald 22044:1250
-- Conjured Mountain Spring Water 30703:5100
-- Candy Cane 17344:61
-- Graccu's Meat Pie 17407:874

-- 2.00.00.14 beta
-- Selectable strata level Config/Bar/High Frame Strata

-- 2.00.00.13 beta
-- Fixed bug in the casting code when the slot is empty
-- Partial lag fix.  Added delay timers to avoid multiple bag scans.

-- 2.00.00.12 beta
-- Change strata to always be high
-- Right clicking healthstone by warlock, or mana stone by mage should cast it.
-- Right click mount by druid / shaman will cast travel form
-- Right click mount by pally or warlock casts summon mount
-- Only tested for a druid...
-- More mounts added

-- 2.00.00.11 beta
-- Espanol or something!  Tx shiftos!
-- Fixed illegal use of Show();
-- Right Click self targets
-- Removed obsolete option to disable popups
-- Popup on shift is broken for now
-- Only tested for a druid...

-- 2.00.00.10 beta
-- Just fixing externals for ace

-- 2.00.00.09 beta
-- Switch to PeriodicTable-2.0
-- mana & hp thresholds now based on PT so wont get out of sync again
-- Set header framestrata to DIALOG so popups dont popunder
-- Booze category added.  Temporary until buffs are overhauled.
-- HideTooltips checkbox works again
-- Docking adjusted a bit but not completely redone yet
-- Add ItemId to tooltip so missing items can be reported easily!

-- 2.00.00.08 beta
-- Reduced the key bindings in Blizzards Keybind UI to only the config toggle.
-- Added basic Tooltip support.
-- Update bar after binding changes

-- 2.00.00.07 beta
-- Alt self target support added
-- Close & disable config during combat
-- Cooldown support added
-- Hotkey display support added to bar buttons

-- 2.00.00.06 beta
-- Fixed lib path issue

-- 2.00.00.05 beta
-- Left & Right clicking a button fixed.  Should target offhand weapon for right click once more.
-- Fixed at least one instance of the itemCount error.
-- Draghandle can be hidden once more
-- First cut at fixing docking.  It works & is tested only for the chat frame.  Offsets still need adjusting and new anchor frames used or hilarity does ensue.
-- More keybinding progress.  Now saves for single & shared profile.

-- 2.00.00.04 beta
-- Unbind button now actually unbinds key binding
-- Revert button will now revert key binds made since the last time done or revert was pressed or the mod loaded. Escaping out of config neither reverts nor commits.

-- 2.00.00.03
-- Fixed popups
-- Quest category added.  Slot 24 for non-rogues.
-- Disable health & mana change updates.  No point since we can't change items during combat anymore & out of combat you can just eat something.
-- First cut at Key binding tab.  Mostly works, left click to set left mouse button binding, right click to set right mouse button binding.

-- 2.00.00.02
-- Some gimped keybindings workaround.  It sort of works off the blizz interface but you can lose bindings if u open it during combat.
-- It may be unstable in some other ways, I seem to lose the bindings from time to time but haven't noticed why yet.
-- This will have to do for now.  I may add explicit per slot binding if this is too lame for real use.
-- Show category icons for 0 item slots works again
-- Show empty slots kinda works but still some strangeness when used with category icons off.

-- 2.00.00.01
-- Make blizz clock cooldown show up again
-- Some progress on drag handle
-- Got rid of Compost

-- 2.00.00.00
-- First rough cut.  Using Secure State Header & Buttons for the bar & popups.
-- Hacking around the lack of an inventory item button with itemId other than direct bag slot & by name.
-- Oops, didnt ship the config.  Doh!


-- 1.12.07.07
-- Final Ace Locale conversions

-- 1.12.07.06
-- Pet Food fruits now have 4 kinds of kimchi.  Seems like a vegetable to me.  Do pets eat delicious kimchi?
-- Almost done integrating with PeriodicTable.
-- Some new bonus foods: Spirit, Well Fed (sta & spi), Other (Dragonbreath Chili for now), Stamina (just stamina)
-- Will need to manually edit food slot or reset to pick up this change.  Existing Stamina items changed to the jsut stamina ones.

-- 1.12.07.05
-- Actually sort the PeriodicTable sets
-- ArrangeOnUse inside a category as well.  Not persistent across reloads yet.  Only Mounts & Pets so far.
-- Added a Checkbox for ActionBar buttons locking when AutoBar is locked.
-- Fix drag & drop error caused by table.getn not returning anything remotely close to number of elements in the array.

-- 1.12.07.04
-- Heavy Crocolisk Stew
-- Switched all but food to use PeriodicTable
-- Rearranged some more of the localization strings.  Much less spam in global space now.
-- Fishing slot modified a bit so it lists fishing pole and some gear. (Requires reset or manual slot edit)
-- Clicking it equips the pole then lucky fishing hat then click to use lures.
-- Naturally you want to add your enchanted fishing gloves to the slot as well.

-- 1.12.07.03
-- French!  Thank you so much Cinedelle!
-- Config is now load on demand.
-- Added rest of the percent foods for Halloween.  (Requires reset or manual slot edit)
-- Pets added, (Rogues need to manually add Pets / Holiday Pets)

-- 1.12.07.02
-- Restored lost changes to character & shared display edit.
-- Acelocale 2.2
-- Some more Ace Locale conversion

-- 1.12.07.01
-- Fixed error with smartSelfCast on the profile tab.

-- 1.12.07
-- Official Ace2 release.
-- Chinese: PDI175

-- 1.12.06.10 beta
-- Make Drag Handle hideable again
-- Dock to bottom right action bar, left or right side of it.

-- 1.12.06.09
-- Switch to Ace Event for timers
-- Upgrade align buttons option to have any combination of vertical and horizontal alignment (9 options).
-- Fix toc for Ace svn

-- 1.12.06.08
-- Korean + some more incremental ACE Locale changes for all languages.

-- 1.12.06.07
-- Renamed files ACE Locale style + some incremental ACE Locale changes for all languages.
-- Deleted obsolete dependencies and files.
-- Toc changes to support ace & ace wiki.

-- 1.12.06.06
-- Actually separate display editing from slots editing for Character vs Shared.
-- This clears up a crasher & some non-obvious behavior after a reset.

-- 1.12.06.05
-- Lock all bars option for drag handle + 30 second timeout on the unlock.  No more accidentally dragging action bar items around!
-- Cleared up a case of algorithm necrosis
-- Looks like Character layout got broken.  Will be fixed next version.  Use Shared layout for now.

-- 1.12.06.04
-- Fixed some Compost library issues.
-- Fixed a couple of spots where non tables were fed into the slots list again.

-- 1.12.06.03
-- Remove single item slot option.  Its pretty pointless & prevents all kinds of options.
-- Compost-2.0
-- oSkin support checkbox on profile tab.  Random results on choose category / view category dialog though.

-- 1.12.06.02
-- Fix embedded library issue

-- 1.12.06.01
-- Ace 2
-- Dewdrop-2.0
-- Boiled clams moved to bonus category
-- Do not flash the popup when using keybinding
-- Harvest festival foods
-- Korean, tx Sayclub!

-- 1.12.05
-- Ok, here it is: the release version of the profiling system.
-- Changed defaults so profile is Single for people with existing Character layer buttons, and Standard profile if not.
-- Dense Dynamite
-- Default noPopup for mount changed to arrangeOnUse.  A better way to go now that mounts are cheap.

-- 1.12.04.12
-- Korean
-- Label Combined Layer View & Layer Edit Sections.
-- Hide edit layer buttons that are not enabled.
-- Config Tooltips.

-- 1.12.04.11
-- View Slot now has a red background and appropriate title and the errant button is now properly hidden.
-- Added some text directing you to the Slots tab for editing as well.
-- Edit Slot dialog has a slightly green background to indicate editing is possible.

-- 1.12.04.10
-- Winterfall Firewater
-- Removed some duplicates in the pet food meat section
-- Revert Button for config so you can undo unintended changes & experiment more freely
-- Basic and Class layers now editable as well
-- Quick Setup & Reset buttons: Single, Shared, Custom as well as blank slate button.

-- 1.12.04.09
-- Chinese & Korean courtesy of the usual suspects
-- Runes added to potion slot

-- 1.12.04.08
-- Fixed dragging slots around on the slots tab.
-- Can now drag from the slot view at the top to the slots being edited at the bottom as well.
-- Fixed slot view not updating when selecting profile layers in the profile

-- 1.12.04.07
-- Added a zeroing out category called "Clear Slot" as well as a button for it on the edit slot dialog.

-- 1.12.04.06
-- Simplified profile interface
-- Now has 4 shared profiles, selectable under profile tab
-- Fixed Smart Self Cast bug.
-- Added Smart Self Cast to defaults
-- Smart Self Cast remains partly broken in its current implementation until it gets a rewrite
-- You can turn the individual ones on but not necessarily off if they are part of the defaults etc.

-- 1.12.04.05
-- Added Clear Slot category.

-- 1.12.04.04
-- Fixed warrior rage potion slot conflicting with heal potions

-- 1.12.04.03
-- Class default bug fix
-- Arathi Basin Food upgrade, tx Ghoschdi
-- Korean, tx Sayclub
-- Expanded slot list to 16.  Removed the clunky movement buttons.  Use drag & drop to reorder instead.
-- Split out more code for the various frames
-- Fixed autoselfcast for now.  Needs a better implementation.
-- Slot View area has tooltips again & clicking them brings up a non-editable Slot View.

-- 1.12.04.01
-- Profile Tab: 4 layers, current edit layer picked at top of dialog.  Class & Basic defaults (not editable)
-- Display settings are either character specific or shared.  No layering.
-- Fixed frame strata for bar & popup
-- Seperated code for ChooseCategory and ConfigSlot.
-- Some lua changes for 2.0
-- Hourglass Sand
-- Casting Cursor used for button interaction
-- Removed custom item insertion.  Cumbersome and not needed if u can drag & drop.
-- Align center button is not functional.  Renamed from "reverse buttons"
-- Slots tab for editing character or shared slots.  Old slots section is now display only, still needs work.

-- 1.12.03
-- Korean thanks to Sayclub
-- Disabled code that hid character buttons when docking to main menu.  These have unintended side effects.

-- 1.12.02.05
-- Chinese Simplified & Traditional (Thanks PDI175)
-- Fixed some typos in localization.

-- 1.12.02.04
-- Pet feed on right click should now work.  Tx Kerrang.  Still need to upgrade the pet food category handling itself.

-- 1.12.02.03
-- Fixed onload issue that broke slash commands
-- AutoBar now dismisses with the escape key as it should
-- Added click for config show / hide

-- 1.12.02.02
-- New 1.12 function ClearCursor() called after drag & drop.
-- Juju
-- First cut of tabbed interface for config
-- 24 buttons
-- Arathi Basin Field Ration
-- Config dialog is now draggable
-- Hunter Pet Food & Feeding
-- First cut at blizzard style dialog.  A frustrating thing as texcoords don't act as expected.

-- 1.12.02
-- Dock to is now list based with a drop down.  I will make the drop down pretty some other time.  Needs settings for various bars.
-- Empty Slot button added.
-- Popup Z order increased so its in front of other mods

-- 1.12.01
-- Chinese Simplified & Traditional (Thanks PDI175)
-- TOC updated.
-- Fixed plain buttons bug
-- Improved config layout for Korean.

-- 1.11.16.01
-- Fixed popup click bug.  Apparently mouseup events do not allow casting like click events.  Strange.
-- Disabled some config checkboxes for single category slots.  Fixes crash.
-- Fixed keybinding screwup.
-- Some more hunter pet foods added.  meats aren't done yet.
-- Added a drag handle for the bar.  Left click to lock right click to bring up options.  Handle can be hidden.
-- Slot specific option to disable popup.
-- Slot specific option to rearrange category priority on use.
-- Increased max popup buttons to 12.

-- 1.11.15.04
-- Done button on config panel to avoid confusion.
-- Option to show Category Icon for slots with 0 item count.  Displayed dark & with -- to distinguish them from regular slots.
-- Scale item count, hotKey and Cooldown Clock text beyond size 36 and up to size 72
-- First cut at a popup list for slots with 2 or more available items
-- Added some unsorted items to pet foods.  These will be broken till sorted.
-- Config for popup direction
-- Fixed popup button scaling
-- Popup on modifier key
-- Popup disable
-- Tooltip for popup buttons
-- Added Jungle Remedy
-- Popup hit rect overlap fixed

-- 1.11.14.03
-- New User / deleted wtf config file bug fix.  tx Xavior for finding it.
-- Ahn Qirajh translation for Chinese. Thanks PDI175.
-- Typo fixed
-- Working Korean I think.  Thanks to Sayclub

-- 1.11.13
-- Deutch! Ser gut Teodred!

-- 1.11.12
-- Korean thanks to Sayclub!

-- 1.11.11
-- Ooh, Traditional Chinese thanks to PDI175
-- Roasted Quail added to pet meats
-- Use the highest priority item for the icon.  (ie. the bottom one in the category list).

-- 1.11.10
-- More Drag & Drop: rearrange button categories now as well
-- Drag from inventory into a button's items (or click on an item then click on category button)
-- Potions: Holy Protection, Agility, Strength, Fortitude, Intellect, Wisdom, Defense, Troll Blood

-- 1.11.09
-- Anti-Venom
-- Global smart self cast checkbox
-- Scrolls of Agility, Intellect, Protection, Stamina, Strength, Spirit
-- Food categories for no bonus food so hunters can feed themselves

-- 1.11.08
-- Drag & Drop to rearrange slot category order in the config dialog.
-- Close button added to config
-- Updated some category icons.

-- 1.11.07
-- Row & column sliders in the config panel are now freely slideable.

-- 1.11.06
-- Fixed glitch at 6 columns

-- 1.11.05
-- Friendship Bread, Freshly Squeezed Lemonade, Wildvine Potion, Sagefish Delight, Smoked Sagefish
-- Dirge's Kickin' Chimaerok Chops,
-- Fixed: Essence Mango,

-- 1.11.04
-- Reset to default button for the buttons
-- Hide tooltips option
-- Demonic and Dark Runes, Battle Standards, Invulnerability Potions

-- 1.11.03.01
-- Deathcharger's Reins, Qiraji Mounts
-- Reworked defaults a bit.

-- 1.11.02
-- Mojos of Zanza & essence mangos; arcane, fire, frost, nature, shadow, spell Protection Potions.
-- Dreamless sleep
-- First cut of cooldown.

-- 1.11.01
-- Added new AD oil & sharpening stone.
-- Expand up to 18 buttons.
-- Rolled in the nurfed version's changes for pvp potions
-- Chocolate Square

-- 2006.03.31
-- Minor category changes
-- Last version by Saien
