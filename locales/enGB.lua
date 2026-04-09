local addonName, ns = ...
ns.L = {}
local L = ns.L

---------------------------------------------------------
-- 1. GENERAL & CORE MESSAGES
---------------------------------------------------------
L.ADDON_TITLE = "n1mmelUI"
L.WELCOME_TITLE = "Welcome to %s"
L.LOAD_MSG = "%s loaded! |cFFFFFFFF(/n1 for menu, /rl to reload)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r GUI not loaded yet."

---------------------------------------------------------
-- 2. INFO WINDOW & MINIMAP
---------------------------------------------------------
L.MINIMAP_OPEN = "Open n1mmelUI"
L.MINIMAP_HIDE = "Hide Icon"
L.LEFTCLICK_MINIMAP = "|cffffffffLeftclick:|r Open Menu"
L.MINIMAP_TOOLTIP_L = "|cffffffffLeft-Click:|r Open Menu"
L.MINIMAP_TOOLTIP_R = "|cffffffffRight-Click:|r Options"
L.DURABILITY = "Durability:"
L.DURABILITY_WARNING = "Durability critical:"
L.EMPTYSLOTS = "Empty Slots:"
L.GOLD = "Gold:"
L.PING = "Ping:"

---------------------------------------------------------
-- 3. TOOLTIPS & UNIT ROLES
---------------------------------------------------------
L.TOOLTIP_TARGET = "Target:"
L.TOOLTIP_ROLE = "Role:"
L.TOOLTIP_HP = "HP:"
L.TOOLTIP_ILVL = "Item Level:"
L.ROLE_TANK = "Role: Tank"
L.ROLE_HEALER = "Role: Healer"
L.ROLE_DAMAGER = "Role: DPS"

---------------------------------------------------------
-- 4. LFG TRACKER (Mythic+)
---------------------------------------------------------
L.LFG_HEADER = "[ n1mmelUI ] - Group Joined:"
L.LEADER = "Leader:"
L.INSTANCE = "Instance:"
L.TITLE = "Title:"

---------------------------------------------------------
-- 5. AUTOMATION (Vendor & Repair)
---------------------------------------------------------
L.SELL_TRASH = "Gray items sold for "
L.REPAIR_GEAR = "Gear repaired for "
L.REPAIR_NO_GOLD = "|cFFFF0000Not enough gold to repair!|r"

---------------------------------------------------------
-- 6. ITEM CHECK & GEAR
---------------------------------------------------------
L.BTN_CHECK = "Item Check"
L.CHECK_DESC = "Checks your equipped gear for missing enchantments\nand empty socket slots. The result will be output accordingly."
L.CHECK_OUTPUT = "Item Check Output:"
L.OUTPUT_CHAT = "In Chat"
L.OUTPUT_WINDOW = "In Window"
L.MISSING_ENCHANT = "Missing Enchant!"
L.MISSING_GEM = "Missing Gem(s)!"
L.ALL_PERFECT = "Perfect! All items enchanted & socketed."
L.ILVL_CHAR = "Show Item Level on Character Screen"
L.ILVL_BAGS = "Show Item Level in Bags & Bank"
L.ILVL_COLOR_LABEL = "Text Color:"
L.COLOR_QUALITY = "By Item Quality (Epic, Rare, etc.)"
L.COLOR_WHITE = "Always White"
L.COLOR_YELLOW = "Always Yellow"

---------------------------------------------------------
-- 7. PERFORMANCE & MEMORY
---------------------------------------------------------
L.GARBAGE_COLLECT_TEXT = "Garbage Collection"
L.MOSTMEMORY_TEXT = "Top 3 Memory Usage:"
L.TOTALMEM_TEXT = "Total memory (all add-ons):"
L.FPS_TEXT = "Frames per Second (FPS):"
L.LATENCY_TEXT = "Latency (Ping):"
L.RAM_TEXT = "Addon RAM Usage:"

---------------------------------------------------------
-- 8. CHAT & WHISPERS
---------------------------------------------------------
L.WHISPER_ALERT_TITLE = "Whisper Alert"
L.CB_WHISPER_ALERT = "Play sound on whisper messages (Char & BNet)"
L.SOUND_LABEL = "Selected Sound:"
L.CB_SHORT_CHANNELS = "Shorten channel names (e.g. [Guild] to [G])"
L.CB_CHAT_CLASS_COLORS = "Show player names in chat in class color"
L.CB_CHAT_URLS = "Make web URLs in chat clickable"
L.URL_COPY_TEXT = "Copy Link (Ctrl+C)"
L.CHAT_GUILD = "Guild"
L.CHAT_PARTY = "Party"
L.CHAT_PARTY_LEADER = "Party Leader"
L.CHAT_RAID = "Raid"
L.CHAT_RAID_LEADER = "Raid Leader"
L.CHAT_RAID_WARNING = "Raid Warning"
L.CHAT_OFFICER = "Officer"
L.CHAT_INSTANCE = "Instance"
L.CHAT_INSTANCE_LEADER = "Instance Leader"

---------------------------------------------------------
-- 9. OPTIONS GUI: TABS
---------------------------------------------------------
L.TAB_SETTINGS = "General"
L.TAB_GEAR = "Equipment"
L.TAB_PERF = "Performance"
L.TAB_MINIMAP = "Map & Minimap"
L.TAB_MYTHIC = "Mythic+"
L.TAB_UI = "UI"
L.TAB_CHAT = "Chat"
L.TAB_INFO = "|cff00ffffInfo|r"

---------------------------------------------------------
-- 10. OPTIONS GUI: CHECKBOXES & LABELS
---------------------------------------------------------
L.CB_CHAT = "Show load message in chat"
L.CB_MAP_COORDS = "Show coordinates on World Map"
L.CB_MINIMAP = "Show coordinates at the Minimap"
L.CB_SQUARE_MINIMAP = "Enable square and larger Minimap"
L.CB_REPAIR = "Auto-repair gear at merchants"
L.CB_SELL = "Auto-sell gray junk at merchants"
L.CB_CLASSCOLOR = "Color player and target health bars by class"
L.CB_SKIP_CINEMATICS = "Auto-skip cinematics and movies"
L.CB_HIDE_TALKINGHEAD = "Hide Talking Head"
L.CB_AFK_SCREEN = "Enable AFK screensaver with spinning camera"
L.CB_CURSOR_ENHANCER = "Show ring around cursor (better visibility)"
L.CURSOR_COLOR_LABEL = "Ring color:"
L.CURSOR_COLOR_CLASS = "Class Color"
L.CURSOR_COLOR_WHITE = "White"
L.CB_INTERRUPT_TRACKER = "Show spell/interrupt tracker (ideal for Mythic+)"
L.INTERRUPT_SPELL_LABEL = "Interrupt Spell Name:"
L.INTERRUPT_SPELL_HINT = "Enter the spell name as shown in your spellbook, then press Enter. The tracker is draggable."
L.INTERRUPT_READY = "READY!"
L.INTERRUPT_NO_SPELL = "No spell set"
L.CB_CREST_FRAME = "Show Floating Crest Tracker"
L.CB_MINIMAP_ICON = "Show Minimap Icon"
L.POS_LABEL = "World Map Coordinates:"
L.TOP_LEFT = "Top Left"
L.TOP_RIGHT = "Top Right"
L.BOTTOM_LEFT = "Bottom Left"
L.BOTTOM_RIGHT = "Bottom Right"
L.PLAYER = "Player"
L.CURSOR = "Cursor"
L.FONT_LABEL = "Global Font:"
L.FONT_RELOAD_WARN = "A reload with /rl is required to apply the font everywhere."
L.BTN_RELOAD = "Reload UI"
L.RELOAD_DESC = "If there is any problem, try reloading the UI with\n /reload or by clicking the button to your right ->"
L.CB_INFO_WINDOW = "Show Info Window"
L.CB_UNITFRAME_FONTS = "Customize Unit Frame Fonts"
L.SESSION_GOLD = "Session (Gold)"
L.CURSE_LINK_TEXT = "n1mmelUI on CurseForge"
L.HIGHEST_KEY = "Highest Weekly Key:"

---------------------------------------------------------
-- 11. OPTIONS GUI: INFO PANEL
---------------------------------------------------------
L.INFO_BY = "by"
L.INFO_CONTENT = "Welcome to your personal Interface Buddy!\n\n" .. 
    "|cffffd100Core Features:|r\n" ..
    "|cff00ff00• Item Level & Gear:|r Displays iLvl on Character, Bags, and Inspect frames.\n" ..
    "|cff00ff00• Chat & Tooltips:|r Short channels, clickable URLs, and class-colored names & roles.\n" ..
    "|cff00ff00• Automation:|r Auto-repair, auto-sell junk, and auto-skip cinematics.\n" ..
    "|cff00ff00• Modernization:|r Square minimap, custom fonts, class-colored health bars, and an AFK Screen.\n" ..
    "|cff00ff00• Tracker:|r Mythic+ rating, keys, and currency tracker built right in.\n\n" ..
    "|cffffd100Shortcuts & Pro Tips:|r\n" ..
    "|cff00ffff[SHIFT]|r + Item Delete: Skips typing 'DELETE'.\n" ..
    "|cff00ffff[LEFT-CLICK]|r Minimap: Opens the n1mmelUI options menu.\n" ..
    "|cff00ffff[HOVER]|r Info Window Gold: Shows your current session profit/loss."
L.COPY_CURSE_LINK = "Press Ctrl+C (or Cmd+C) to copy the link:"