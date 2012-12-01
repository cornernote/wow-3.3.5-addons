-------------------------------------------------------------------------------
-- Chinese localization (Taiwan)
-------------------------------------------------------------------------------

if (GetLocale() == "zhTW" or GetLocale() == "zhCN") then


-- Debuff types
SMARTDEBUFF_DISEASE = "Disease";
SMARTDEBUFF_MAGIC   = "Magic";
SMARTDEBUFF_POISON  = "Poison";
SMARTDEBUFF_CURSE   = "Curse";
SMARTDEBUFF_CHARMED = "Mind Control";
SMARTDEBUFF_HEAL    = "Heal";


-- Creatures
SMARTDEBUFF_HUMANOID  = "人形";
SMARTDEBUFF_DEMON     = "惡魔";
SMARTDEBUFF_BEAST     = "野獸";
SMARTDEBUFF_ELEMENTAL = "元素";
SMARTDEBUFF_IMP       = "小鬼";
SMARTDEBUFF_FELHUNTER = "地獄犬";
SMARTDEBUFF_DOOMGUARD = "惡魔守衛";

-- 職業
SMARTDEBUFF_CLASSES = { ["DRUID"] = "德魯伊", ["HUNTER"] = "獵人", ["MAGE"] = "法師", ["PALADIN"] = "圣騎士", ["PRIEST"] = "牧師", ["ROGUE"] = "盜賊"
                      , ["SHAMAN"] = "薩滿", ["WARLOCK"] = "術士", ["WARRIOR"] = "戰士", ["DEATHKNIGHT"] = "死亡騎士", ["HPET"] = "獵人寵物", ["WPET"] = "法師寵物"};

-- Bindings
BINDING_NAME_SMARTDEBUFF_BIND_OPTIONS = "選項";

SMARTDEBUFF_KEYS = {["L"]  = "左",
                    ["R"]  = "右",
                    ["M"]  = "中",
                    ["SL"] = "Shift 左",
                    ["SR"] = "Shift 右",
                    ["SM"] = "Shift 中",
                    ["AL"] = "Alt 左",
                    ["AR"] = "Alt 右",
                    ["AM"] = "Alt 中",
                    ["CL"] = "Ctrl 左",
                    ["CR"] = "Ctrl 右",
                    ["CM"] = "Ctrl 中"
                    };

-- Messages
SMARTDEBUFF_MSG_LOADED         = "已加載";
SMARTDEBUFF_MSG_SDB            = "SmartDebuff 選項框體";

-- 框體 text
SMARTDEBUFF_FT_MODES           = "按鍵/模式";
SMARTDEBUFF_FT_MODENORMAL      = "普通";
SMARTDEBUFF_FT_MODETARGET      = "目標";


-- 選項 框體 text
SMARTDEBUFF_OFT                = "顯示/隱藏選項框體";
SMARTDEBUFF_OFT_HUNTERPETS     = "獵人寵物";
SMARTDEBUFF_OFT_WARLOCKPETS    = "術士寵物";
SMARTDEBUFF_OFT_DEATHKNIGHTPETS= "死亡騎士寵物";
SMARTDEBUFF_OFT_HP             = "生命";
SMARTDEBUFF_OFT_MANA           = "魔法";
SMARTDEBUFF_OFT_INVERT         = "反轉";
SMARTDEBUFF_OFT_CLASSVIEW      = "職業視圖";
SMARTDEBUFF_OFT_CLASSCOLOR     = "職業顏色";
SMARTDEBUFF_OFT_SHOWLR         = "L / R / M";
SMARTDEBUFF_OFT_HEADERS        = "標題";
SMARTDEBUFF_OFT_GROUPNR        = "組號";
SMARTDEBUFF_OFT_SOUND          = "聲音";
SMARTDEBUFF_OFT_TOOLTIP        = "提示";
SMARTDEBUFF_OFT_TARGETMODE     = "目標模式";
SMARTDEBUFF_OFT_HEALRANGE      = "法術距離";
SMARTDEBUFF_OFT_SHOWAGGRO      = "戰斗";
SMARTDEBUFF_OFT_VERTICAL       = "垂直排列";
SMARTDEBUFF_OFT_VERTICALUP     = "垂直向上";
SMARTDEBUFF_OFT_HEADERROW      = "標題條";
SMARTDEBUFF_OFT_BACKDROP       = "背景";
SMARTDEBUFF_OFT_SHOWGRADIENT   = "漸變";
SMARTDEBUFF_OFT_INFOFRAME      = "摘要框體";
SMARTDEBUFF_OFT_AUTOHIDE       = "自動隱藏";
SMARTDEBUFF_OFT_COLUMNS        = "列";
SMARTDEBUFF_OFT_INTERVAL       = "間隔";
SMARTDEBUFF_OFT_FONTSIZE       = "字體大小";
SMARTDEBUFF_OFT_WIDTH          = "寬";
SMARTDEBUFF_OFT_HEIGHT         = "高";
SMARTDEBUFF_OFT_BARHEIGHT      = "格子高";
SMARTDEBUFF_OFT_OPACITYNORMAL  = "距離內透明度";
SMARTDEBUFF_OFT_OPACITYOOR     = "距離外透明度";
SMARTDEBUFF_OFT_OPACITYDEBUFF  = "debuff透明度";
SMARTDEBUFF_OFT_NOTREMOVABLE   = "Debuff保護";

SMARTDEBUFF_AOFT_SORTBYCLASS   = "按職業排序";
SMARTDEBUFF_NRDT_TITLE         = "不可驅散的Debuffs";


-- Tooltip text
SMARTDEBUFF_TT                 = "Shift-左拖動: 移動框體\n|cff20d2ff- S 按鈕 -|r\n左點擊: 按職業顯示\nShift-左點擊: 職業顏色\nAlt-左點擊: 高亮 L/R\n右點擊: 背景";
SMARTDEBUFF_TT_TARGETMODE      = "在目標模式\n|cff20d2ff左點擊|r選擇單位\n|cff20d2ff右點擊|r釋放最快的治療法術。\n|cff20d2ffAlt-左/右點擊|r驅除debuff.";
SMARTDEBUFF_TT_NOTREMOVABLE    = "顯示重大 debuff\n即便是無法驅除.";
SMARTDEBUFF_TT_HP              = "顯示真實生命";
SMARTDEBUFF_TT_MANA            = "顯示真實魔法";
SMARTDEBUFF_TT_INVERT          = "反轉顯示生命魔法";
SMARTDEBUFF_TT_CLASSVIEW       = "按職業顯示單位按鈕";
SMARTDEBUFF_TT_CLASSCOLOR      = "單位按鈕上顯示職業顏色";
SMARTDEBUFF_TT_SHOWLR          = "有debuff時\n顯示對應的按鈕 (L/R/M), ";
SMARTDEBUFF_TT_HEADERS         = "顯示職業名稱\n作為行標題";
SMARTDEBUFF_TT_GROUPNR         = "顯示小組編號\n在單位名字前";
SMARTDEBUFF_TT_SOUND           = "播放聲音, 當\n有單位獲得debuff.";
SMARTDEBUFF_TT_TOOLTIP         = "顯示提示信息,\n不在戰斗中時";
SMARTDEBUFF_TT_HEALRANGE       = "顯示紅色邊框,\n如果你的法術超出距離";
SMARTDEBUFF_TT_SHOWAGGRO       = "顯示那個\n單位在戰斗中";
SMARTDEBUFF_TT_VERTICAL        = "顯示單位\n垂直排列";
SMARTDEBUFF_TT_VERTICALUP      = "顯示單位\n從下至上";
SMARTDEBUFF_TT_HEADERROW       = "顯示標題條,\n包括菜單按鈕";
SMARTDEBUFF_TT_BACKDROP        = "顯示黑色\n背景框體.";
SMARTDEBUFF_TT_SHOWGRADIENT    = "顯示單位按鈕\n使用彩色漸變效果";
SMARTDEBUFF_TT_INFOFRAME       = "顯示摘要框體,\n只在隊伍或團隊中時";
SMARTDEBUFF_TT_AUTOHIDE        = "自動隱藏單位按鈕\n在非戰斗狀態 \n且無人有debuff時";

--SMARTDEBUFF_TT_COLUMNS         = "Columns";
--SMARTDEBUFF_TT_INTERVAL        = "Interval";
--SMARTDEBUFF_TT_FONTSIZE        = "Font size";
--SMARTDEBUFF_TT_WIDTH           = "Width";
--SMARTDEBUFF_TT_HEIGHT          = "Height";
--SMARTDEBUFF_TT_BARHEIGHT       = "Bar height";
--SMARTDEBUFF_TT_OPACITYNORMAL   = "Opacity in range";
--SMARTDEBUFF_TT_OPACITYOOR      = "Opacity out of range";
--SMARTDEBUFF_TT_OPACITYDEBUFF   = "Opacity debuff";

-- Tooltip text key bindings
SMARTDEBUFF_TT_DROP            = "釋放";
SMARTDEBUFF_TT_DROPINFO        = "釋放書和背包中的法術/物品/宏\n\n|cff00ff00左點擊設置目標功能";
SMARTDEBUFF_TT_DROPSPELL       = "法術點擊:\n左 拾取\nShift-左 復制\n右 刪除";
SMARTDEBUFF_TT_DROPITEM        = "物品點擊:\n左 拾取\nShift-左 復制\n右 刪除";
SMARTDEBUFF_TT_DROPMACRO       = "宏 點擊:\n左 拾取\nShift-左 復制\n右 刪除";
SMARTDEBUFF_TT_TARGET          = "目標";
SMARTDEBUFF_TT_TARGETINFO      = "選擇指定單位\n作為當前目標.";
SMARTDEBUFF_TT_DROPTARGET      = "單位點擊:\n刪除";
SMARTDEBUFF_TT_DROPACTION      = "寵物行動:\n不能刪除!";

-- Tooltip support
SMARTDEBUFF_FUBAR_TT           = "\n左點擊: 打開選項\nShift-左點擊: On/Off";

-- izayoi 2009-5-30
end