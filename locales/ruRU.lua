local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "ruRU" then return end

L.TITLE = "n1mmelUI"
L.LOAD_MSG = "%s загружен! |cFFFFFFFF(/n1 для меню, /rl для перезагрузки)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r Интерфейс еще не загружен."
L.LEFTCLICK_MINIMAP = "|cffffffffЛКМ:|r Открыть меню"
L.DURABILITY = "Прочность:"
L.DURABILITY_WARNING = "Критическая прочность:"
L.TOOLTIP_TARGET = "Цель:"
L.ROLE_TANK = "Роль: Танк"
L.ROLE_HEALER = "Роль: Лекарь"
L.ROLE_DAMAGER = "Роль: Урон"

L.TAB_SETTINGS = "Общее"
L.TAB_GEAR = "Экипировка"
L.TAB_PERF = "Производительность"
L.TAB_MINIMAP = "Карта и миникарта"
L.TAB_MYTHIC = "Эпохальный+"
L.TAB_UI = "Интерфейс"
L.TAB_CHAT = "Чат"

L.CB_CHAT = "Показывать сообщение при загрузке"
L.CB_MAP_COORDS = "Показывать координаты на карте мира"
L.CB_MINIMAP = "Показывать координаты на миникарте"
L.CB_SQUARE_MINIMAP = "Квадратная и увеличенная миникарта"
L.CB_REPAIR = "Автоматический ремонт у торговцев"
L.CB_SELL = "Автоматическая продажа серого хлама"
L.CB_CLASSCOLOR = "Цвет класса для полос здоровья (игрок и цель)"
L.CB_SKIP_CINEMATICS = "Автоматический пропуск роликов"
L.CB_HIDE_TALKINGHEAD = "Скрыть окно диалогов (Talking Head)"
L.CB_AFK_SCREEN = "Активировать AFK-экран"
L.CB_CREST_FRAME = "Парящий трекер гребней"
L.CB_MINIMAP_ICON = "Показать иконку у миникарты"

L.MINIMAP_OPEN = "Открыть n1mmelUI"
L.MINIMAP_HIDE = "Скрыть иконку"
L.MINIMAP_TOOLTIP_L = "|cffffffffЛКМ:|r Открыть меню"
L.MINIMAP_TOOLTIP_R = "|cffffffffПКМ:|r Настройки"

L.POS_LABEL = "Координаты на карте мира:"
L.TOP_LEFT = "Сверху слева"
L.TOP_RIGHT = "Сверху справа"
L.BOTTOM_LEFT = "Снизу слева"
L.BOTTOM_RIGHT = "Снизу справа"
L.PLAYER = "Игрок"
L.CURSOR = "Курсор"

L.ILVL_CHAR = "Уровень предметов в окне персонажа"
L.ILVL_BAGS = "Уровень предметов в сумках и банке"
L.ILVL_COLOR_LABEL = "Цвет текста:"
L.COLOR_QUALITY = "По качеству предмета"
L.COLOR_WHITE = "Всегда белый"
L.COLOR_YELLOW = "Всегда желтый"

L.BTN_CHECK = "Проверить экипировку"
L.CHECK_OUTPUT = "Место вывода проверки:"
L.OUTPUT_CHAT = "В чат"
L.OUTPUT_WINDOW = "В окно"
L.MISSING_ENCHANT = "Чары отсутствуют!"
L.MISSING_GEM = "Гнезда пусты!"
L.ALL_PERFECT = "Идеально! Все предметы зачарованы и сокетированы."
L.CHECK_DESC = "Проверяет надетую экипировку на наличие чар\nи пустых гнезд. Результат будет выведен соответствующим образом."

L.GARBAGE_COLLECT_TEXT = "Чистая память"
L.MOSTMEMORY_TEXT = "Три самых используемых источника памяти:"
L.TOTALMEM_TEXT = "Общий объем памяти (со всеми дополнениями):"
L.FPS_TEXT = "Кадров в секунду (FPS):"
L.LATENCY_TEXT = "Задержка (Ping):"
L.RAM_TEXT = "Память, используемая аддоном:"
L.FONT_LABEL = "Общий шрифт:"
L.FONT_RELOAD_WARN = "Требуется /rl для применения шрифта везде."

L.SELL_TRASH = "Серые предметы проданы за "
L.REPAIR_GEAR = "Экипировка отремонтирована за "
L.REPAIR_NO_GOLD = "|cFFFF0000Недостаточно золота для ремонта!|r"

L.WHISPER_ALERT_TITLE = "Оповещение о шепоте"
L.CB_WHISPER_ALERT = "Звук при получении шепота (Личный и BNet)"
L.SOUND_LABEL = "Выбранный звук:"

L.CB_SHORT_CHANNELS = "Сокращать названия каналов (напр. [Г] для Гильдии)"
L.CB_CHAT_CLASS_COLORS = "Имена игроков цветом класса"
L.CB_CHAT_URLS = "Сделать ссылки кликабельными"
L.URL_COPY_TEXT = "Копировать ссылку (Ctrl+C)"

L.CHAT_GUILD = "Гильдия"
L.CHAT_PARTY = "Группа"
L.CHAT_PARTY_LEADER = "Лидер группы"
L.CHAT_RAID = "Рейд"
L.CHAT_RAID_LEADER = "Лидер рейда"
L.CHAT_RAID_WARNING = "Объявление рейду"
L.CHAT_OFFICER = "Офицер"
L.CHAT_INSTANCE = "Подземелье"
L.CHAT_INSTANCE_LEADER = "Лидер подземелья"

L.TAB_INFO = "|cff00ffffИнфо|r"
L.INFO_BY = "от"
L.INFO_CONTENT = "Добро пожаловать в ваш личный помощник по интерфейсу!\n\n" ..
    "|cffffd100Особенности и ярлыки:|r\n\n" ..
    "|cff00ff00- Короткие каналы:|r Сокращает названия, например [Гильдия] до [G].\n" ..
    "|cff00ff00- Поддержка URL:|r Нажмите на ссылку в чате, чтобы скопировать ее.\n" ..
    "|cff00ff00- Цвета классов:|r Игроки отображаются в цветах своего класса.\n" ..
    "|cff00ff00- Прочность:|r Наведите на кнопку у миникарты для информации.\n\n" ..
    "|cffff0000- ПРО-СОВЕТ (Удаление предмета):|r\n" ..
    "Удерживайте |cffffd100[SHIFT]|r при удалении предмета, " ..
    "чтобы пропустить ввод слова 'УДАЛИТЬ'!"
L.COPY_CURSE_LINK = "Нажмите Ctrl+C (или Cmd+C), чтобы скопировать ссылку:"
L.WELCOME_TITLE = "Добро пожаловать в %s"