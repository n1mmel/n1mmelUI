local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "deDE" then return end

---------------------------------------------------------
-- 1. GENERAL & CORE MESSAGES
---------------------------------------------------------
L.ADDON_TITLE = "n1mmelUI"
L.WELCOME_TITLE = "Willkommen bei %s"
L.LOAD_MSG = "%s geladen! |cFFFFFFFF(/n1 für Menü, /rl zum Neuladen)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r GUI wurde noch nicht geladen."

---------------------------------------------------------
-- 2. INFO WINDOW & MINIMAP
---------------------------------------------------------
L.MINIMAP_OPEN = "n1mmelUI öffnen"
L.MINIMAP_HIDE = "Icon ausblenden"
L.LEFTCLICK_MINIMAP = "|cffffffffLinks-Klick:|r Menü öffnen"
L.MINIMAP_TOOLTIP_L = "|cffffffffLinks-Klick:|r Menü öffnen"
L.MINIMAP_TOOLTIP_R = "|cffffffffRechts-Klick:|r Optionen"
L.DURABILITY = "Haltbarkeit:"
L.DURABILITY_WARNING = "Haltbarkeit kritisch:"
L.EMPTYSLOTS = "Freie Plätze:"
L.GOLD = "Gold:"
L.PING = "Ping:"

---------------------------------------------------------
-- 3. TOOLTIPS & UNIT ROLES
---------------------------------------------------------
L.TOOLTIP_TARGET = "Ziel:"
L.ROLE_TANK = "Rolle: Tank"
L.ROLE_HEALER = "Rolle: Heiler"
L.ROLE_DAMAGER = "Rolle: DD"

---------------------------------------------------------
-- 4. LFG TRACKER (Mythic+)
---------------------------------------------------------
L.LFG_HEADER = "[ n1mmelUI ] - Gruppe beigetreten:"
L.LEADER = "Leiter:"
L.INSTANCE = "Instanz:"
L.TITLE = "Titel:"

---------------------------------------------------------
-- 5. AUTOMATION (Vendor & Repair)
---------------------------------------------------------
L.SELL_TRASH = "Graue Items verkauft für "
L.REPAIR_GEAR = "Ausrüstung repariert für "
L.REPAIR_NO_GOLD = "|cFFFF0000Nicht genug Gold zum Reparieren!|r"

---------------------------------------------------------
-- 6. ITEM CHECK & GEAR
---------------------------------------------------------
L.BTN_CHECK = "Item Check"
L.CHECK_DESC = "Überprüft deine angelegte Ausrüstung auf fehlende Verzauberungen\nund leere Sockelplätze. Das Ergebnis wird entsprechend ausgegeben."
L.CHECK_OUTPUT = "Ausgabe Item Check:"
L.OUTPUT_CHAT = "Im Chat"
L.OUTPUT_WINDOW = "Im Fenster"
L.MISSING_ENCHANT = "Verzauberung fehlt!"
L.MISSING_GEM = "Edelstein(e) fehlen!"
L.ALL_PERFECT = "Perfekt! Alle Items sind verzaubert & gesockelt."
L.ILVL_CHAR = "Item Level auf Charakterbildschirm anzeigen"
L.ILVL_BAGS = "Item Level in Taschen & Bank anzeigen"
L.ILVL_COLOR_LABEL = "Textfarbe:"
L.COLOR_QUALITY = "Nach Item-Qualität (Lila, Blau, etc.)"
L.COLOR_WHITE = "Immer Weiß"
L.COLOR_YELLOW = "Immer Gelb"

---------------------------------------------------------
-- 7. PERFORMANCE & MEMORY
---------------------------------------------------------
L.GARBAGE_COLLECT_TEXT = "Speicher leeren"
L.MOSTMEMORY_TEXT = "Top 3 Speicherfresser:"
L.TOTALMEM_TEXT = "Gesamtspeicher (alle Addons):"
L.FPS_TEXT = "Bilder pro Sekunde (FPS):"
L.LATENCY_TEXT = "Latenz (Ping):"
L.RAM_TEXT = "Addon RAM-Verbrauch:"

---------------------------------------------------------
-- 8. CHAT & WHISPERS
---------------------------------------------------------
L.WHISPER_ALERT_TITLE = "Flüster-Benachrichtigung"
L.CB_WHISPER_ALERT = "Sound bei Flüsternachrichten abspielen (Char & BNet)"
L.SOUND_LABEL = "Ausgewählter Sound:"
L.CB_SHORT_CHANNELS = "Kanalnamen im Chat abkürzen (z.B. [Gilde] zu [G])"
L.CB_CHAT_CLASS_COLORS = "Spielernamen im Chat in Klassenfarbe anzeigen"
L.CB_CHAT_URLS = "Internet-Links im Chat anklickbar machen"
L.URL_COPY_TEXT = "Link kopieren (Strg+C)"
L.CHAT_GUILD = "Gilde"
L.CHAT_PARTY = "Gruppe"
L.CHAT_PARTY_LEADER = "Gruppenanführer"
L.CHAT_RAID = "Schlachtzug"
L.CHAT_RAID_LEADER = "Schlachtzugsleiter"
L.CHAT_RAID_WARNING = "Schlachtzugswarnung"
L.CHAT_OFFICER = "Offizier"
L.CHAT_INSTANCE = "Instanz"
L.CHAT_INSTANCE_LEADER = "Instanzanführer"

---------------------------------------------------------
-- 9. OPTIONS GUI: TABS
---------------------------------------------------------
L.TAB_SETTINGS = "Allgemein"
L.TAB_GEAR = "Ausrüstung"
L.TAB_PERF = "Leistung"
L.TAB_MINIMAP = "Karte & Minikarte"
L.TAB_MYTHIC = "Mythic+"
L.TAB_UI = "Interface"
L.TAB_CHAT = "Chat"
L.TAB_INFO = "|cff00ffffInfo|r"

---------------------------------------------------------
-- 10. OPTIONS GUI: CHECKBOXES & LABELS
---------------------------------------------------------
L.CB_CHAT = "Lade-Nachricht im Chat anzeigen"
L.CB_MAP_COORDS = "Koordinaten auf der Weltkarte anzeigen"
L.CB_MINIMAP = "Koordinaten an der Minimap anzeigen"
L.CB_SQUARE_MINIMAP = "Eckige und größere Minimap aktivieren"
L.CB_REPAIR = "Beim Händler automatisch reparieren"
L.CB_SELL = "Beim Händler grauen Schrott verkaufen"
L.CB_CLASSCOLOR = "Spieler- und Ziel-Lebensleiste in Klassenfarbe färben"
L.CB_SKIP_CINEMATICS = "Zwischensequenzen automatisch überspringen"
L.CB_HIDE_TALKINGHEAD = "Talking Head (Sprechender Kopf) ausblenden"
L.CB_AFK_SCREEN = "AFK-Bildschirm mit drehender Kamera aktivieren"
L.CB_CREST_FRAME = "Schwebender Crest Tracker"
L.CB_MINIMAP_ICON = "Minimap Icon anzeigen"
L.POS_LABEL = "Weltkarte Koordinaten:"
L.TOP_LEFT = "Oben Links"
L.TOP_RIGHT = "Oben Rechts"
L.BOTTOM_LEFT = "Unten Links"
L.BOTTOM_RIGHT = "Unten Rechts"
L.PLAYER = "Spieler"
L.CURSOR = "Cursor"
L.FONT_LABEL = "Globale Schriftart:"
L.FONT_RELOAD_WARN = "Ein reload mit /rl ist nötig, um die Schrift überall zu übernehmen."

---------------------------------------------------------
-- 11. OPTIONS GUI: INFO PANEL
---------------------------------------------------------
L.INFO_BY = "von"
L.INFO_CONTENT = "Willkommen bei deinem persönlichen Interface-Buddy!\n\n" .. 
    "|cffffd100Hauptfunktionen:|r\n" ..
    "|cff00ff00• Itemlevel & Ausrüstung:|r Zeigt das iLvl in Taschen, Bank und Charakterfenstern.\n" ..
    "|cff00ff00• Chat & Tooltips:|r Kurze Kanäle, klickbare URLs, Klassenfarben und Rollen.\n" ..
    "|cff00ff00• Automation:|r Auto-Reparieren, Auto-Verkaufen und Auto-Cinematics überspringen.\n" ..
    "|cff00ff00• Modernisierung:|r Eckige Minimap, eigene Schriften, klassenfarbige Lebensbalken & AFK-Screen.\n" ..
    "|cff00ff00• Tracker:|r Mythisch+ Wertung, Keys und Abzeichen-Tracker integriert.\n\n" ..
    "|cffffd100Shortcuts & Pro-Tipps:|r\n" ..
    "|cff00ffff[SHIFT]|r + Item Löschen: Überspringt die 'LÖSCHEN' Eingabe.\n" ..
    "|cff00ffff[LINKSKLICK]|r Minimap-Icon: Öffnet das n1mmelUI Optionsmenü.\n" ..
    "|cff00ffff[HOVER]|r Info-Fenster Gold: Zeigt den Gewinn/Verlust der aktuellen Sitzung."
L.COPY_CURSE_LINK = "Drücke Strg+C (oder Cmd+C) um den Link zu kopieren:"