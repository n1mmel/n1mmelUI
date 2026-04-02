local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

L.TITLE = "n1mmelUI"
L.LOAD_MSG = "%s cargado! |cFFFFFFFF(/n1 para menú, /rl para recargar)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r La interfaz aún no se ha cargado."
L.LEFTCLICK_MINIMAP = "|cffffffffClic-Izquierdo:|r Abrir menú"
L.DURABILITY = "Durabilidad:"
L.DURABILITY_WARNING = "Durabilidad crítica:"
L.TOOLTIP_TARGET = "Objetivo:"
L.ROLE_TANK = "Rol: Tanque"
L.ROLE_HEALER = "Rol: Sanador"
L.ROLE_DAMAGER = "Rol: DPS"
L.KEYSTONE_INSERTED = "Piedra angular insertada automáticamente:"

L.TAB_SETTINGS = "General"
L.TAB_GEAR = "Equipo"
L.TAB_PERF = "Rendimiento"
L.TAB_MINIMAP = "Mapa y Minimapa"
L.TAB_MYTHIC = "Mítico+"
L.TAB_UI = "Interfaz"
L.TAB_CHAT = "Chat"

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
L.CB_CREST_FRAME = "Rastreador de blasones flotante"
L.CB_MINIMAP_ICON = "Mostrar icono del minimapa"

L.MINIMAP_OPEN = "Abrir n1mmelUI"
L.MINIMAP_HIDE = "Ocultar icono"
L.MINIMAP_TOOLTIP_L = "|cffffffffClic-Izquierdo:|r Abrir menú"
L.MINIMAP_TOOLTIP_R = "|cffffffffClic-Derecho:|r Opciones"

L.POS_LABEL = "Coordenadas del mapa mundial:"
L.TOP_LEFT = "Arriba a la izquierda"
L.TOP_RIGHT = "Arriba a la derecha"
L.BOTTOM_LEFT = "Abajo a la izquierda"
L.BOTTOM_RIGHT = "Abajo a la derecha"
L.PLAYER = "Jugador"
L.CURSOR = "Cursor"

L.ILVL_CHAR = "Nivel de objeto en la pantalla de personaje"
L.ILVL_BAGS = "Nivel de objeto en bolsas y banco"
L.ILVL_COLOR_LABEL = "Color del texto:"
L.COLOR_QUALITY = "Por calidad de objeto"
L.COLOR_WHITE = "Siempre blanco"
L.COLOR_YELLOW = "Siempre amarillo"

L.BTN_CHECK = "Verificar equipo"
L.CHECK_OUTPUT = "Resultado de la verificación:"
L.OUTPUT_CHAT = "En el chat"
L.OUTPUT_WINDOW = "En ventana"
L.MISSING_ENCHANT = "¡Falta encantamiento!"
L.MISSING_GEM = "¡Faltan gema(s)!"
L.ALL_PERFECT = "¡Perfecto! Todo está encantado y engarzado."
L.CHECK_DESC = "Verifica si tu equipo actual tiene encantamientos\no ranuras vacías. El resultado se mostrará en consecuencia."

L.GARBAGE_COLLECT_TEXT = "Memoria limpia"
L.MOSTMEMORY_TEXT = "Los 3 principales usos de memoria:"
L.TOTALMEM_TEXT = "Memoria total (todos los complementos):"
L.FPS_TEXT = "Cuadros por segundo (FPS):"
L.LATENCY_TEXT = "Latencia (Ping):"
L.RAM_TEXT = "Memoria usada por el addon:"
L.FONT_LABEL = "Fuente global:"
L.FONT_RELOAD_WARN = "Se requiere /rl para aplicar la fuente en todas partes."

L.SELL_TRASH = "Objetos grises vendidos por "
L.REPAIR_GEAR = "Equipo reparado por "
L.REPAIR_NO_GOLD = "|cFFFF0000¡No hay suficiente oro para reparar!|r"

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

L.TAB_INFO = "|cff00ffffInfo|r"
L.INFO_BY = "por"
L.INFO_CONTENT = "¡Bienvenido a tu compañero de interfaz personal!\n\n" ..
    "|cffffd100Características y Atajos:|r\n\n" ..
    "|cff00ff00- Canales cortos:|r Acorta los nombres de chat como [Hermandad] a [G].\n" ..
    "|cff00ff00- Soporte URL:|r Haz clic en los enlaces del chat para copiarlos.\n" ..
    "|cff00ff00- Colores de clase:|r Los jugadores se muestran con el color de su clase.\n" ..
    "|cff00ff00- Durabilidad:|r Pasa el ratón sobre el botón del minimapa para más info.\n\n" ..
    "|cffff0000- CONSEJO PRO (Borrar objeto):|r\n" ..
    "¡Mantén pulsado |cffffd100[SHIFT]|r al borrar un objeto " ..
    "para no tener que escribir 'BORRAR'!"
L.COPY_CURSE_LINK = "Presiona Ctrl+C (o Cmd+C) para copiar el enlace:"
L.WELCOME_TITLE = "Bienvenido a %s"