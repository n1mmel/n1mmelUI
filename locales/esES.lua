local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

---------------------------------------------------------
-- 1. GENERAL & CORE MESSAGES
---------------------------------------------------------
L.ADDON_TITLE = "n1mmelUI"
L.WELCOME_TITLE = "Bienvenido a %s"
L.LOAD_MSG = "%s cargado! |cFFFFFFFF(/n1 para menú, /rl para recargar)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r La interfaz aún no se ha cargado."

---------------------------------------------------------
-- 2. INFO WINDOW & MINIMAP
---------------------------------------------------------
L.MINIMAP_OPEN = "Abrir n1mmelUI"
L.MINIMAP_HIDE = "Ocultar icono"
L.LEFTCLICK_MINIMAP = "|cffffffffClic-Izquierdo:|r Abrir menú"
L.MINIMAP_TOOLTIP_L = "|cffffffffClic-Izquierdo:|r Abrir menú"
L.MINIMAP_TOOLTIP_R = "|cffffffffClic-Derecho:|r Opciones"
L.DURABILITY = "Durabilidad:"
L.DURABILITY_WARNING = "Durabilidad crítica:"
L.EMPTYSLOTS = "Espacios vacíos:"
L.GOLD = "Oro:"
L.PING = "Ping:"

---------------------------------------------------------
-- 3. TOOLTIPS & UNIT ROLES
---------------------------------------------------------
L.TOOLTIP_TARGET = "Objetivo:"
L.ROLE_TANK = "Rol: Tanque"
L.ROLE_HEALER = "Rol: Sanador"
L.ROLE_DAMAGER = "Rol: DPS"

---------------------------------------------------------
-- 4. LFG TRACKER (Mythic+)
---------------------------------------------------------
L.LFG_HEADER = "[ n1mmelUI ] - Grupo unido:"
L.LEADER = "Líder:"
L.INSTANCE = "Instancia:"
L.TITLE = "Título:"

---------------------------------------------------------
-- 5. AUTOMATION (Vendor & Repair)
---------------------------------------------------------
L.SELL_TRASH = "Objetos grises vendidos por "
L.REPAIR_GEAR = "Equipo reparado por "
L.REPAIR_NO_GOLD = "|cFFFF0000¡No hay suficiente oro para reparar!|r"

---------------------------------------------------------
-- 6. ITEM CHECK & GEAR
---------------------------------------------------------
L.BTN_CHECK = "Verificar equipo"
L.CHECK_DESC = "Verifica si tu equipo actual tiene encantamientos\no ranuras vacías. El resultado se mostrará en consecuencia."
L.CHECK_OUTPUT = "Resultado de la verificación:"
L.OUTPUT_CHAT = "En el chat"
L.OUTPUT_WINDOW = "En ventana"
L.MISSING_ENCHANT = "¡Falta encantamiento!"
L.MISSING_GEM = "¡Faltan gema(s)!"
L.ALL_PERFECT = "¡Perfecto! Todo está encantado y engarzado."
L.ILVL_CHAR = "Nivel de objeto en la pantalla de personaje"
L.ILVL_BAGS = "Nivel de objeto en bolsas y banco"
L.ILVL_COLOR_LABEL = "Color del texto:"
L.COLOR_QUALITY = "Por calidad de objeto"
L.COLOR_WHITE = "Siempre blanco"
L.COLOR_YELLOW = "Siempre amarillo"

---------------------------------------------------------
-- 7. PERFORMANCE & MEMORY
---------------------------------------------------------
L.GARBAGE_COLLECT_TEXT = "Memoria limpia"
L.MOSTMEMORY_TEXT = "Los 3 principales usos de memoria:"
L.TOTALMEM_TEXT = "Memoria total (todos los complementos):"
L.FPS_TEXT = "Cuadros por segundo (FPS):"
L.LATENCY_TEXT = "Latencia (Ping):"
L.RAM_TEXT = "Memoria usada por el addon:"

---------------------------------------------------------
-- 8. CHAT & WHISPERS
---------------------------------------------------------
L.WHISPER_ALERT_TITLE = "Alerta de susurro"
L.CB_WHISPER_ALERT = "Sonido al recibir susurros (Perso y BNet)"
L.SOUND_LABEL = "Sonido seleccionado:"
L.CB_SHORT_CHANNELS = "Abreviar nombres de canales (ej: [H] para Hermandad)"
L.CB_CHAT_CLASS_COLORS = "Nombres de jugadores en color de clase"
L.CB_CHAT_URLS = "Hacer clic en los enlaces URL"
L.URL_COPY_TEXT = "Copiar enlace (Ctrl+C)"
L.CHAT_GUILD = "Hermandad"
L.CHAT_PARTY = "Grupo"
L.CHAT_PARTY_LEADER = "Líder de grupo"
L.CHAT_RAID = "Banda"
L.CHAT_RAID_LEADER = "Líder de banda"
L.CHAT_RAID_WARNING = "Advertencia de banda"
L.CHAT_OFFICER = "Oficial"
L.CHAT_INSTANCE = "Estancia"
L.CHAT_INSTANCE_LEADER = "Líder de estancia"

---------------------------------------------------------
-- 9. OPTIONS GUI: TABS
---------------------------------------------------------
L.TAB_SETTINGS = "General"
L.TAB_GEAR = "Equipo"
L.TAB_PERF = "Rendimiento"
L.TAB_MINIMAP = "Mapa y Minimapa"
L.TAB_MYTHIC = "Mítico+"
L.TAB_UI = "Interfaz"
L.TAB_CHAT = "Chat"
L.TAB_INFO = "|cff00ffffInfo|r"

---------------------------------------------------------
-- 10. OPTIONS GUI: CHECKBOXES & LABELS
---------------------------------------------------------
L.CB_CHAT = "Mostrar mensaje de carga en el chat"
L.CB_MAP_COORDS = "Mostrar coordenadas en el mapa mundial"
L.CB_MINIMAP = "Mostrar coordenadas en el minimapa"
L.CB_SQUARE_MINIMAP = "Activar minimapa cuadrado y más grande"
L.CB_REPAIR = "Reparación automática en mercaderes"
L.CB_SELL = "Vender chatarra automáticamente"
L.CB_CLASSCOLOR = "Color de clase en barras de vida (jugador y objetivo)"
L.CB_SKIP_CINEMATICS = "Omitir cinemáticas automáticamente"
L.CB_HIDE_TALKINGHEAD = "Ocultar marco de diálogo (Talking Head)"
L.CB_AFK_SCREEN = "Activar protector de pantalla AFK"
L.CB_CURSOR_ENHANCER = "Mostrar anillo alrededor del cursor (mejor visibilidad)"
L.CURSOR_COLOR_LABEL = "Color del anillo:"
L.CURSOR_COLOR_CLASS = "Color de clase"
L.CURSOR_COLOR_WHITE = "Blanco"
L.CB_INTERRUPT_TRACKER = "Mostrar tracker de hechizo/interrupción (ideal para Mítico+)"
L.INTERRUPT_SPELL_LABEL = "Hechizo de interrupción:"
L.INTERRUPT_SPELL_HINT = "Escribe el nombre del hechizo como aparece en el grimorio y pulsa Enter. El tracker es arrastrable."
L.INTERRUPT_READY = "¡LISTO!"
L.INTERRUPT_NO_SPELL = "Sin hechizo definido"
L.CB_CREST_FRAME = "Rastreador de blasones flotante"
L.CB_MINIMAP_ICON = "Mostrar icono del minimapa"
L.POS_LABEL = "Coordenadas del mapa mundial:"
L.TOP_LEFT = "Arriba a la izquierda"
L.TOP_RIGHT = "Arriba a la derecha"
L.BOTTOM_LEFT = "Abajo a la izquierda"
L.BOTTOM_RIGHT = "Abajo a la derecha"
L.PLAYER = "Jugador"
L.CURSOR = "Cursor"
L.FONT_LABEL = "Fuente global:"
L.FONT_RELOAD_WARN = "Se requiere /rl para aplicar la fuente en todas partes."
L.BTN_RELOAD = "Recargar UI"
L.RELOAD_DESC = "Si hay algún problema, recarga la UI con\n /reload o el botón de la derecha ->"
L.CB_INFO_WINDOW = "Mostrar ventana de información"
L.CB_UNITFRAME_FONTS = "Personalizar fuentes de marcos de unidad"
L.SESSION_GOLD = "Sesión (Oro)"
L.CURSE_LINK_TEXT = "n1mmelUI en CurseForge"
L.HIGHEST_KEY = "Clave semanal más alta:"

---------------------------------------------------------
-- 11. OPTIONS GUI: INFO PANEL
---------------------------------------------------------
L.INFO_BY = "por"
L.INFO_CONTENT = "¡Bienvenido a tu compañero de interfaz personal!\n\n" ..
    "|cffffd100Características Principales:|r\n" ..
    "|cff00ff00• Nivel de Objeto:|r Muestra el iLvl en bolsas, banco y panel de personaje.\n" ..
    "|cff00ff00• Chat y Descripciones:|r Canales cortos, URLs clicables, colores de clase y roles.\n" ..
    "|cff00ff00• Automatización:|r Reparación y venta automática, y omitir cinemáticas.\n" ..
    "|cff00ff00• Modernización:|r Minimapa cuadrado, fuentes, barras de vida por clase y pantalla AFK.\n" ..
    "|cff00ff00• Rastreador:|r Puntuación Mítica+, llaves y monedas integradas.\n\n" ..
    "|cffffd100Atajos y Consejos Pro:|r\n" ..
    "|cff00ffff[SHIFT]|r + Borrar Objeto: Omite tener que escribir 'BORRAR'.\n" ..
    "|cff00ffff[CLIC-IZQ]|r Minimapa: Abre el menú de opciones de n1mmelUI.\n" ..
    "|cff00ffff[HOVER]|r Oro (Ventana Info): Muestra las ganancias/pérdidas de la sesión."
L.COPY_CURSE_LINK = "Presiona Ctrl+C (o Cmd+C) para copiar el enlace:"