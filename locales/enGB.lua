local addonName, ns = ...
ns.L = {}
local L = ns.L

L.TITLE = "n1mmelUI"
L.LOAD_MSG = "%s loaded! |cFFFFFFFF(/n1 for menu, /rl to reload)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r GUI not loaded yet."
L.LEFTCLICK_MINIMAP = "|cffffffffLeftclick:|r Open Menu"
L.DURABILITY = "Durability:"
L.DURABILITY_WARNING = "Durability critical:"
L.TOOLTIP_TARGET = "Target:"
L.ROLE_TANK = "Role: Tank"
L.ROLE_HEALER = "Role: Healer"
L.ROLE_DAMAGER = "Role: DPS"
L.EMPTYSLOTS = "Empty Slots:"
L.GOLD = "Gold:"

L.TAB_SETTINGS = "General"
L.TAB_GEAR = "Equipment"
L.TAB_PERF = "Performance"
L.TAB_MINIMAP = "Map & Minimap"
L.TAB_MYTHIC = "Mythic+"
L.TAB_UI = "UI"
L.TAB_CHAT = "Chat"

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
L.CB_CREST_FRAME = "Show Floating Crest Tracker"
L.CB_MINIMAP_ICON = "Show Minimap Icon"

L.MINIMAP_OPEN = "Open n1mmelUI"
L.MINIMAP_HIDE = "Hide Icon"
L.MINIMAP_TOOLTIP_L = "|cffffffffLeft-Click:|r Open Menu"
L.MINIMAP_TOOLTIP_R = "|cffffffffRight-Click:|r Options"

L.POS_LABEL = "World Map Coordinates:"
L.TOP_LEFT = "Top Left"
L.TOP_RIGHT = "Top Right"
L.BOTTOM_LEFT = "Bottom Left"
L.BOTTOM_RIGHT = "Bottom Right"
L.PLAYER = "Player"
L.CURSOR = "Cursor"

L.ILVL_CHAR = "Show Item Level on Character Screen"
L.ILVL_BAGS = "Show Item Level in Bags & Bank"
L.ILVL_COLOR_LABEL = "Text Color:"
L.COLOR_QUALITY = "By Item Quality (Epic, Rare, etc.)"
L.COLOR_WHITE = "Always White"
L.COLOR_YELLOW = "Always Yellow"

L.BTN_CHECK = "Item Check"
L.CHECK_OUTPUT = "Item Check Output:"
L.OUTPUT_CHAT = "In Chat"
L.OUTPUT_WINDOW = "In Window"
L.MISSING_ENCHANT = "Missing Enchant!"
L.MISSING_GEM = "Missing Gem(s)!"
L.ALL_PERFECT = "Perfect! All items enchanted & socketed."
L.CHECK_DESC =
    "Checks your equipped gear for missing enchantments\nand empty socket slots. The result will be output accordingly."

L.GARBAGE_COLLECT_TEXT = "Garbage Collection"
L.MOSTMEMORY_TEXT = "Top 3 Memory Usage:"
L.TOTALMEM_TEXT = "Total memory (all add-ons):"
L.FPS_TEXT = "Frames per Second (FPS):"
L.LATENCY_TEXT = "Latency (Ping):"
L.RAM_TEXT = "Addon RAM Usage:"
L.FONT_LABEL = "Global Font:"
L.FONT_RELOAD_WARN = "A reload with /rl is required to apply the font everywhere."

L.SELL_TRASH = "Gray items sold for "
L.REPAIR_GEAR = "Gear repaired for "
L.REPAIR_NO_GOLD = "|cFFFF0000Not enough gold to repair!|r"

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

L.TAB_INFO = "|cff00ffffInfo|r"
L.INFO_BY = "by"
L.INFO_CONTENT = "Welcome to your personal Interface Buddy!\n\n" .. "|cffffd100Features & Shortcuts:|r\n\n" ..
                     "|cff00ff00- Short Channels:|r Shortens chat names like [Guild] to [G].\n" ..
                     "|cff00ff00- URL Support:|r Click on links in chat to copy them.\n" ..
                     "|cff00ff00- Tooltip Colors:|r Players are shown in their class colors.\n" ..
                     "|cff00ff00- Target of Target:|r You are able to see the Target of Target in Tooltip.\n" ..
                     "|cff00ff00- Durability:|r Hover over the minimap button for info.\n\n" ..
                     "|cffff0000- PRO TIP (Delete Item):|r\n" ..
                     "Hold |cffffd100[SHIFT]|r while deleting an epic or rare item " .. "to skip typing 'DELETE'!"
L.COPY_CURSE_LINK = "Press Ctrl+C (or Cmd+C) to copy the link:"
L.WELCOME_TITLE = "Welcome to %s"