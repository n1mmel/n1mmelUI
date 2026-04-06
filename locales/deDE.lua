local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "deDE" then return end

L.TITLE = "n1mmelUI"
L.LOAD_MSG = "%s geladen! |cFFFFFFFF(/n1 für Menü, /rl zum Neuladen)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r GUI wurde noch nicht geladen."
L.LEFTCLICK_MINIMAP = "|cffffffffLinks-Klick:|r Menü öffnen"
L.DURABILITY = "Haltbarkeit:"
L.DURABILITY_WARNING = "Haltbarkeit kritisch:"
L.TOOLTIP_TARGET = "Ziel:"
L.ROLE_TANK = "Rolle: Tank"
L.ROLE_HEALER = "Rolle: Heiler"
L.ROLE_DAMAGER = "Rolle: DD"
L.EMPTYSLOTS = "Freie Plätze:"
L.GOLD = "Gold:"

L.TAB_SETTINGS = "Allgemein"
L.TAB_GEAR = "Ausrüstung"
L.TAB_PERF = "Leistung"
L.TAB_MINIMAP = "Karte & Minikarte"
L.TAB_MYTHIC = "Mythic+"
L.TAB_UI = "Interface"
L.TAB_CHAT = "Chat"

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

L.MINIMAP_OPEN = "n1mmelUI öffnen"
L.MINIMAP_HIDE = "Icon ausblenden"
L.MINIMAP_TOOLTIP_L = "|cffffffffLinks-Klick:|r Menü öffnen"
L.MINIMAP_TOOLTIP_R = "|cffffffffRechts-Klick:|r Optionen"

L.POS_LABEL = "Weltkarte Koordinaten:"
L.TOP_LEFT = "Oben Links"
L.TOP_RIGHT = "Oben Rechts"
L.BOTTOM_LEFT = "Unten Links"
L.BOTTOM_RIGHT = "Unten Rechts"
L.PLAYER = "Spieler"
L.CURSOR = "Cursor"

L.ILVL_CHAR = "Item Level auf Charakterbildschirm anzeigen"
L.ILVL_BAGS = "Item Level in Taschen & Bank anzeigen"
L.ILVL_COLOR_LABEL = "Textfarbe:"
L.COLOR_QUALITY = "Nach Item-Qualität (Lila, Blau, etc.)"
L.COLOR_WHITE = "Immer Weiß"
L.COLOR_YELLOW = "Immer Gelb"

L.BTN_CHECK = "Item Check"
L.CHECK_OUTPUT = "Ausgabe Item Check:"
L.OUTPUT_CHAT = "Im Chat"
L.OUTPUT_WINDOW = "Im Fenster"
L.MISSING_ENCHANT = "Verzauberung fehlt!"
L.MISSING_GEM = "Edelstein(e) fehlen!"
L.ALL_PERFECT = "Perfekt! Alle Items sind verzaubert & gesockelt."
L.CHECK_DESC = "Überprüft deine angelegte Ausrüstung auf fehlende Verzauberungen\nund leere Sockelplätze. Das Ergebnis wird entsprechend ausgegeben."

L.GARBAGE_COLLECT_TEXT = "Speicher leeren"
L.MOSTMEMORY_TEXT = "Top 3 Speicherfresser:"
L.TOTALMEM_TEXT = "Gesamtspeicher (alle Addons):"
L.FPS_TEXT = "Bilder pro Sekunde (FPS):"
L.LATENCY_TEXT = "Latenz (Ping):"
L.RAM_TEXT = "Addon RAM-Verbrauch:"
L.FONT_LABEL = "Globale Schriftart:"
L.FONT_RELOAD_WARN = "Ein reload mit /rl ist nötig, um die Schrift überall zu übernehmen."

L.SELL_TRASH = "Graue Items verkauft für "
L.REPAIR_GEAR = "Ausrüstung repariert für "
L.REPAIR_NO_GOLD = "|cFFFF0000Nicht genug Gold zum Reparieren!|r"

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

L.TAB_INFO = "|cff00ffffInfo|r"
L.INFO_BY = "von"
L.INFO_CONTENT = "Willkommen bei deinem persönlichen Interface-Buddy!\n\n" ..
    "|cffffd100Features & Kurzbefehle:|r\n\n" ..
    "|cff00ff00- Abgekürzte Kanäle:|r Verkürzt Chatnamen wie [Gilde] zu [G].\n" ..
    "|cff00ff00- URL Support:|r Klicke auf Links im Chat, um sie zu kopieren.\n" ..
    "|cff00ff00- Tooltip-Farben:|r Spieler werden in Klassenfarben angezeigt.\n" ..
    "|cff00ff00- Haltbarkeit:|r Hover über den Minimap-Button für Infos.\n\n" ..
    "|cffff0000- PRO TIPP (Item Löschen):|r\n" ..
    "Halte |cffffd100[SHIFT]|r gedrückt, während du ein Item löschst, " ..
    "um das Tippen von 'LÖSCHEN' zu überspringen!"
L.COPY_CURSE_LINK = "Drücke Strg+C (oder Cmd+C) zum Kopieren:"
L.WELCOME_TITLE = "Willkommen bei %s"