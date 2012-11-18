-------------------------------------------------------------------------------
-- Taiwan Localization 
-------------------------------------------------------------------------------
if (GetLocale() == "zhTW") then

-- Whats new info
SMARTBUFF_WHATSNEW = "|cffffffff更新說明:|r\n\n"
  .."- 新增支援Parrot插件, 警告訊息將轉由Parrot提供\n\n"
  .."- 新增buffs: 法師 (達拉然智力/光輝), 牧師 (漂浮術)\n\n"
  .."- 更新施法材料清單\n\n"
  ;


-- Mage
SMARTBUFF_MAGE_PATTERN = {"%a+甲術$"};

-- Warlock
SMARTBUFF_WARLOCK_PATTERN = {"^惡魔%a+"};

-- Hunter
SMARTBUFF_HUNTER_PATTERN = {"^%a+守護$"};

-- Shaman
SMARTBUFF_SHAMAN_PATTERN = {"%a+之盾$"};

-- Paladin
SMARTBUFF_PALADIN_PATTERN = {"^%a+聖印$"};

-- Death Knight
SMARTBUFF_DEATHKNIGHT_PATTERN = {"%a+領域$"};

-- Druid
-- Priest
-- Warrior
-- Rogue

-- Weapon types
SMARTBUFF_WEAPON_STANDARD = {"匕首", "斧", "劍", "錘", "法杖", "拳套", "長柄武器"};
SMARTBUFF_WEAPON_BLUNT = {"魔杖", "法杖", "拳套"};
SMARTBUFF_WEAPON_BLUNT_PATTERN = "平衡石$";
SMARTBUFF_WEAPON_SHARP = {"匕首", "斧", "劍", "長柄武器"};
SMARTBUFF_WEAPON_SHARP_PATTERN = "磨刀石$";

-- Creature types
SMARTBUFF_HUMANOID  = "人型生物";
SMARTBUFF_DEMON     = "惡魔";
SMARTBUFF_BEAST     = "野獸";
SMARTBUFF_ELEMENTAL = "元素生物";
SMARTBUFF_DEMONTYPE = "小鬼";

-- Classes
SMARTBUFF_CLASSES = {"德魯伊", "獵人", "法師", "聖騎士", "牧師", "盜賊", "薩滿", "術士", "戰士", "死亡騎士", "獵人寵物", "術士寵物"};

-- Templates and Instances
SMARTBUFF_TEMPLATES = {"自我", "隊伍", "團隊", "戰場", "MC", "Ony", "BWL", "Naxx", "AQ", "ZG", "自定義 1", "自定義 2", "自定義 3", "自定義 4", "自定義 5"};
SMARTBUFF_INSTANCES = {"熔火之心", "奧妮克希亞的巢穴", "黑翼之巢", "安其拉", "祖爾格拉布", "奧特蘭克山谷", "阿拉希盆地", "戰歌峽谷", "劍刃競技場", "納葛蘭競技場"};

-- Mount
SMARTBUFF_MOUNT = "速度提高(%d+)%%.";

-- Bindings
BINDING_NAME_SMARTBUFF_BIND_TRIGGER = "觸發";
BINDING_NAME_SMARTBUFF_BIND_TARGET  = "目標";
BINDING_NAME_SMARTBUFF_BIND_OPTIONS = "選項視窗";
BINDING_NAME_SMARTBUFF_BIND_RESETBUFFTIMERS = "重置 Buff 時間";

-- Options Frame Text
SMARTBUFF_OFT                = "SmartBuff 開/關";
SMARTBUFF_OFT_MENU           = "選項視窗 顯示/隱藏";
SMARTBUFF_OFT_AUTO           = "啟用提示";
SMARTBUFF_OFT_AUTOTIMER      = "檢查週期";
SMARTBUFF_OFT_AUTOCOMBAT     = "戰鬥";
SMARTBUFF_OFT_AUTOCHAT       = "聊天";
SMARTBUFF_OFT_AUTOSPLASH     = "閃爍";
SMARTBUFF_OFT_AUTOSOUND      = "聲音";
SMARTBUFF_OFT_AUTOREST       = "城市內停用";
SMARTBUFF_OFT_HUNTERPETS     = "Buff獵人寵物";
SMARTBUFF_OFT_WARLOCKPETS    = "Buff術士寵物";
SMARTBUFF_OFT_ARULES         = "進階規則";
SMARTBUFF_OFT_GRP            = "監控團隊中小隊";
SMARTBUFF_OFT_SUBGRPCHANGED  = "開啟選項視窗";
SMARTBUFF_OFT_BUFFS          = "Buff項目";
SMARTBUFF_OFT_TARGET         = "Buff目標";
SMARTBUFF_OFT_DONE           = "確定";
SMARTBUFF_OFT_APPLY          = "套用";
SMARTBUFF_OFT_GRPBUFFSIZE    = "隊伍觸發人數";
SMARTBUFF_OFT_CLASSBUFFSIZE  = "職業觸發人數";
SMARTBUFF_OFT_MESSAGES       = "關閉訊息";
SMARTBUFF_OFT_MSGNORMAL      = "一般";
SMARTBUFF_OFT_MSGWARNING     = "警告";
SMARTBUFF_OFT_MSGERROR       = "錯誤";
SMARTBUFF_OFT_HIDEMMBUTTON   = "隱藏小地圖按鈕";
SMARTBUFF_OFT_REBUFFTIMER    = "重新buff計時器";
SMARTBUFF_OFT_AUTOSWITCHTMP  = "自動切換方案";
SMARTBUFF_OFT_SELFFIRST      = "自己優先";
SMARTBUFF_OFT_SCROLLWHEEL    = "滑鼠滾輪觸發";
SMARTBUFF_OFT_SCROLLWHEELUP  = "滑鼠滾輪向上";
SMARTBUFF_OFT_SCROLLWHEELDOWN= "下";
SMARTBUFF_OFT_TARGETSWITCH   = "目標改變觸發";
SMARTBUFF_OFT_BUFFTARGET     = "Buff 目標";
SMARTBUFF_OFT_BUFFPVP        = "Buff PvP";
SMARTBUFF_OFT_AUTOSWITCHTMPINST = "副本";
SMARTBUFF_OFT_CHECKCHARGES   = "次數檢查";
SMARTBUFF_OFT_RBT            = "重置計時器";
SMARTBUFF_OFT_BUFFINCITIES   = "在城市內buff";
SMARTBUFF_OFT_UISYNC         = "UI同步";
SMARTBUFF_OFT_ADVGRPBUFFCHECK = "團隊buff檢查";
SMARTBUFF_OFT_ADVGRPBUFFRANGE = "團隊範圍檢查";
SMARTBUFF_OFT_BLDURATION     = "忽略";
SMARTBUFF_OFT_COMPMODE       = "相容模式";
SMARTBUFF_OFT_MINIGRP        = "小團隊";
SMARTBUFF_OFT_ANTIDAZE       = "防眩暈";
SMARTBUFF_OFT_HIDESABUTTON   = "隱藏動作按鈕";
SMARTBUFF_OFT_INCOMBAT       = "戰鬥中";
SMARTBUFF_OFT_SMARTDEBUFF    = "SmartDebuff";
SMARTBUFF_OFT_INSHAPESHIFT   = "變身型態下";

-- Options Frame Tooltip Text
SMARTBUFF_OFTT               = "SmarBuff 開/關";
SMARTBUFF_OFTT_AUTO          = "Buff提示 開/關";
SMARTBUFF_OFTT_AUTOTIMER     = "Buff監視時間的間隔";
SMARTBUFF_OFTT_AUTOCOMBAT    = "戰鬥時保持監視";
SMARTBUFF_OFTT_AUTOCHAT      = "Buff消失訊息 - 聊天視窗訊息";
SMARTBUFF_OFTT_AUTOSPLASH    = "Buff消失訊息 - 螢幕中央閃爍訊息";
SMARTBUFF_OFTT_AUTOSOUND     = "Buff消失訊息 - 聲音提示";
SMARTBUFF_OFTT_AUTOREST      = "在主城內停用訊息提示";
SMARTBUFF_OFTT_HUNTERPETS    = "Buff獵人寵物";
SMARTBUFF_OFTT_WARLOCKPETS   = "Buff術士寵物,除了" .. SMARTBUFF_DEMONTYPE .. ".";
SMARTBUFF_OFTT_ARULES        = "設定以下情況不施法:\n法師、牧師和術士不施放荊棘術,                    \n無魔法職業不施放秘法智慧、神聖之靈.";
SMARTBUFF_OFTT_SUBGRPCHANGED = "所在小隊變動後,自動開啟Smartbuff選項視窗.";
SMARTBUFF_OFTT_GRPBUFFSIZE   = "小隊補充群體buff的人數門檻.";
SMARTBUFF_OFTT_HIDEMMBUTTON  = "隱藏小地圖按鈕.";
SMARTBUFF_OFTT_REBUFFTIMER   = "Buff消失前多少秒,\n提示你重新施法.\n0 = 不提示";
SMARTBUFF_OFTT_SELFFIRST     = "優先對自己施放buff";
SMARTBUFF_OFTT_SCROLLWHEELUP = "當滑鼠滾輪向前滾動時buff";
SMARTBUFF_OFTT_SCROLLWHEELDOWN = "當滑鼠滾輪向後滾動時buff.";
SMARTBUFF_OFTT_TARGETSWITCH  = "當你改變目標時buff.";
SMARTBUFF_OFTT_BUFFTARGET    = "當目標為友好狀態時,優先buff該目標";
SMARTBUFF_OFTT_BUFFPVP       = "自身非PVP時,也buff PvP玩家";
SMARTBUFF_OFTT_AUTOSWITCHTMP = "依團體狀態自動切換方案";
SMARTBUFF_OFTT_AUTOSWITCHTMPINST = "切換副本時,自動切換方案";
SMARTBUFF_OFTT_CHECKCHARGES  = "當buff次數過低時警告.";
SMARTBUFF_OFTT_BUFFINCITIES  = "當你在城市內仍然buff.\n如果你在PvP狀態下,不論任何情況皆會buff";
SMARTBUFF_OFTT_UISYNC        = "啟動UI同步自身施放給其他玩家的buff剩餘時間.";
SMARTBUFF_OFTT_ADVGRPBUFFCHECK = "檢查團體buff會一併檢查單體buff.";
SMARTBUFF_OFTT_ADVGRPBUFFRANGE = "檢查施放團隊中,\n是否每個人都在有效範圍內";
SMARTBUFF_OFTT_BLDURATION    = "忽略玩家秒數\n0 = 停用";
SMARTBUFF_OFTT_COMPMODE      = "相容模式\n警示!!!\n除非無法buff自己,否則不勾選";
SMARTBUFF_OFTT_MINIGRP       = "以獨立可移動小視窗顯示Raid各小隊設定.";
SMARTBUFF_OFTT_ANTIDAZE      = "若小隊中有人眩暈,\n自動取消獵豹/豹群守護";
SMARTBUFF_OFTT_SPLASHSTYLE   = "更換 buff 訊息字型.";
SMARTBUFF_OFTT_HIDESABUTTON  = "隱藏SmartBuff動作按鈕.";
SMARTBUFF_OFTT_INCOMBAT      = "只對自己作用.\n被勾選為'戰鬥中'的第一個buff會在戰鬥前被設定在按鈕上,\n並能在戰鬥中使用.\n注意: 戰鬥中禁用邏輯判斷.";
SMARTBUFF_OFTT_SMARTDEBUFF   = "顯示SmartDebuff視窗.";
SMARTBUFF_OFTT_SPLASHDURATION= "閃爍訊息持續秒數.";
SMARTBUFF_OFTT_INSHAPESHIFT  = "在變身型態下是否也施放buff.";

-- Buffsetup Frame Text
SMARTBUFF_BST_SELFONLY       = "僅對自己施法";
SMARTBUFF_BST_SELFNOT        = "不對自己施法";
SMARTBUFF_BST_COMBATIN       = "戰鬥狀態觸發";
SMARTBUFF_BST_COMBATOUT      = "非戰鬥狀態觸發";
SMARTBUFF_BST_MAINHAND       = "主手";
SMARTBUFF_BST_OFFHAND        = "副手";
SMARTBUFF_BST_REMINDER       = "通知";
SMARTBUFF_BST_MANALIMIT      = "力能底線";--力能是技能施放來源,如怒氣、能量、法力

-- Buffsetup Frame Tooltip Text
SMARTBUFF_BSTT_SELFONLY      = "僅對自己施法,不對其他隊友施法.";
SMARTBUFF_BSTT_SELFNOT       = "除了自己,也buff所有勾選職業.";
SMARTBUFF_BSTT_COMBATIN      = "在戰鬥狀態時保持自動觸發技能.";
SMARTBUFF_BSTT_COMBATOUT     = "在非戰鬥狀態時保持自動觸發技能.";
SMARTBUFF_BSTT_MAINHAND      = "Buff主手.";
SMARTBUFF_BSTT_OFFHAND       = "Buff副手.";
SMARTBUFF_BSTT_REMINDER      = "顯示提示訊息.";
SMARTBUFF_BSTT_REBUFFTIMER   = "Buff消失前多少秒,\n發出警告訊息.0 = 不提示";
SMARTBUFF_BSTT_MANALIMIT     = "設定魔法/怒氣/能量保留門檻.";

-- Playersetup Frame Tooltip Text
SMARTBUFF_PSTT_RESIZE        = "最小化/最大化 設定視窗";

-- Messages
SMARTBUFF_MSG_LOADED         = "已載入";
SMARTBUFF_MSG_DISABLED       = "SmarBuff已停用!";
SMARTBUFF_MSG_SUBGROUP       = "你已經加入一個新的小隊,請檢查你的設定!";
SMARTBUFF_MSG_NOTHINGTODO    = "不需執行任何指令";
SMARTBUFF_MSG_BUFFED         = "已施放";
SMARTBUFF_MSG_OOR            = "不在施法範圍內!";
--SMARTBUFF_MSG_CD             = "冷卻中!";
SMARTBUFF_MSG_CD             = "公共CD時間已到!";
SMARTBUFF_MSG_CHAT           = "沒有發現任何聊天視窗!";
SMARTBUFF_MSG_SHAPESHIFT     = "變身形態不能施法!";
SMARTBUFF_MSG_NOACTIONSLOT   = "需要動作條按鈕才能正常運作!";
SMARTBUFF_MSG_GROUP          = "隊伍";
SMARTBUFF_MSG_NEEDS          = "需要加buff:";
SMARTBUFF_MSG_OOM            = "沒有足夠的魔法/怒氣/能量!";
SMARTBUFF_MSG_STOCK          = "目前庫存的";
SMARTBUFF_MSG_NOREAGENT      = "沒有施法材料:";
SMARTBUFF_MSG_DEACTIVATED    = "停用!";
SMARTBUFF_MSG_REBUFF         = "Rebuff:";
SMARTBUFF_MSG_LEFT           = "剩餘";
SMARTBUFF_MSG_CLASS          = "職業";
SMARTBUFF_MSG_CHARGES        = "次";

-- Support
SMARTBUFF_MINIMAP_TT         = "左鍵: 選項視窗\n右鍵: 開/關\nAlt-左鍵: SmartDebuff\nShift拖曳: 移動按鈕";
SMARTBUFF_TITAN_TT           = "左鍵: 開啟選項\n右鍵: 開/關\nAlt-左鍵: SmartDebuff";
SMARTBUFF_FUBAR_TT           = "\n左鍵: 開啟選項\nShift-左鍵: 開/關\nAlt-左鍵: SmartDebuff";

SMARTBUFF_DEBUFF_TT          = "Shift-左鍵拖曳: 移動視窗\n|cff20d2ff- S 按鈕 -|r\n左鍵: 依職業顯示\nShift-左鍵: 職業顏色\nAlt-左鍵: 高亮度 L/R\n|cff20d2ff- P 按鈕 -|r\n左鍵: 隱藏寵物 開/關";


-- Code table
--  : \195\160     : \195\168     : \195\172     : \195\178     : \195\185
--  : \195\161     : \195\169     : \195\173     : \195\179     : \195\186
--  : \195\162     : \195\170     : \195\174     : \195\180     : \195\187
--  : \195\163     : \195\171     : \195\175     : \195\181     : \195\188
--  : \195\164                     : \195\177     : \195\182
--  : \195\166                                     : \195\184
--  : \195\167                                     : \197\147
-- 
--  : \195\132
--  : \195\150
--  : \195\156
--  : \195\159
end