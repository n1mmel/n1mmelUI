local addonName, ns = ...
local L = ns.L

if GetLocale() ~= "frFR" then return end

L.TITLE = "n1mmelUI"
L.LOAD_MSG = "%s chargé ! |cFFFFFFFF(/n1 pour le menu, /rl pour recharger)|r"
L.GUI_ERROR = "|cFFFF0000n1mmelUI:|r L'interface n'est pas encore chargée."
L.LEFTCLICK_MINIMAP = "|cffffffffClic-Gauche:|r Ouvrir le menu"
L.DURABILITY = "Durabilité :"
L.DURABILITY_WARNING = "Durabilité critique :"
L.TOOLTIP_TARGET = "Cible :"
L.ROLE_TANK = "Rôle : Tank"
L.ROLE_HEALER = "Rôle : Soigneur"
L.ROLE_DAMAGER = "Rôle : DPS"

L.TAB_SETTINGS = "Général"
L.TAB_GEAR = "Équipement"
L.TAB_PERF = "Performance"
L.TAB_MINIMAP = "Carte et Minicarte"
L.TAB_MYTHIC = "Mythique+"
L.TAB_UI = "Interface"
L.TAB_CHAT = "Discussion"

L.CB_CHAT = "Message de chargement dans la discussion"
L.CB_MAP_COORDS = "Afficher les coordonnées sur la carte du monde"
L.CB_MINIMAP = "Afficher les coordonnées sur la minicarte"
L.CB_SQUARE_MINIMAP = "Activer la minicarte carrée et agrandie"
L.CB_REPAIR = "Réparation automatique chez les marchands"
L.CB_SELL = "Vendre automatiquement les objets gris"
L.CB_CLASSCOLOR = "Couleur de classe pour les barres de vie (joueur et cible)"
L.CB_SKIP_CINEMATICS = "Passer les cinématiques automatiquement"
L.CB_HIDE_TALKINGHEAD = "Masquer la fenêtre de dialogue (Talking Head)"
L.CB_AFK_SCREEN = "Activer l'économiseur d'écran AFK"
L.CB_CREST_FRAME = "Suivi des blasons flottant"
L.CB_MINIMAP_ICON = "Afficher l'icône de la minicarte"

L.MINIMAP_OPEN = "Ouvrir n1mmelUI"
L.MINIMAP_HIDE = "Masquer l'icône"
L.MINIMAP_TOOLTIP_L = "|cffffffffClic-Gauche:|r Ouvrir le menu"
L.MINIMAP_TOOLTIP_R = "|cffffffffClic-Droit:|r Options"

L.POS_LABEL = "Coordonnées de la carte du monde :"
L.TOP_LEFT = "En haut à gauche"
L.TOP_RIGHT = "En haut à droite"
L.BOTTOM_LEFT = "En bas à gauche"
L.BOTTOM_RIGHT = "En bas à droite"
L.PLAYER = "Joueur"
L.CURSOR = "Curseur"

L.ILVL_CHAR = "Niveau d'objet sur la fiche de personnage"
L.ILVL_BAGS = "Niveau d'objet dans les sacs et la banque"
L.ILVL_COLOR_LABEL = "Couleur du texte :"
L.COLOR_QUALITY = "Par qualité d'objet"
L.COLOR_WHITE = "Toujours blanc"
L.COLOR_YELLOW = "Toujours jaune"

L.BTN_CHECK = "Vérifier l'équipement"
L.CHECK_OUTPUT = "Sortie de la vérification :"
L.OUTPUT_CHAT = "Dans la discussion"
L.OUTPUT_WINDOW = "Dans une fenêtre"
L.MISSING_ENCHANT = "Enchantement manquant !"
L.MISSING_GEM = "Gemme(s) manquante(s) !"
L.ALL_PERFECT = "Parfait ! Tout est enchanté et serti."
L.CHECK_DESC = "Vérifie si votre équipement actuel a des enchantements\nou des chasses vides. Le résultat sera affiché en conséquence."

L.GARBAGE_COLLECT_TEXT = "Souvenir clair"
L.MOSTMEMORY_TEXT = "Les 3 principaux utilisateurs de mémoire:"
L.TOTALMEM_TEXT = "Mémoire totale (tous modules complémentaires):"
L.FPS_TEXT = "Images par seconde (FPS) :"
L.LATENCY_TEXT = "Latence (Ping) :"
L.RAM_TEXT = "Mémoire utilisée par l'addon :"
L.FONT_LABEL = "Police globale :"
L.FONT_RELOAD_WARN = "Un /rl est requis pour appliquer la police partout."

L.SELL_TRASH = "Objets gris vendus pour "
L.REPAIR_GEAR = "Équipement réparé pour "
L.REPAIR_NO_GOLD = "|cFFFF0000Pas assez d'or pour réparer !|r"

L.WHISPER_ALERT_TITLE = "Alerte de chuchotement"
L.CB_WHISPER_ALERT = "Son lors d'un chuchotement (Perso & BNet)"
L.SOUND_LABEL = "Son sélectionné :"

L.CB_SHORT_CHANNELS = "Raccourcir les noms des canaux (ex: [G] pour Guilde)"
L.CB_CHAT_CLASS_COLORS = "Noms des joueurs en couleur de classe"
L.CB_CHAT_URLS = "Rendre les liens URL cliquables"
L.URL_COPY_TEXT = "Copier le lien (Ctrl+C)"

L.CHAT_GUILD = "Guilde"
L.CHAT_PARTY = "Groupe"
L.CHAT_PARTY_LEADER = "Chef de groupe"
L.CHAT_RAID = "Raid"
L.CHAT_RAID_LEADER = "Chef de raid"
L.CHAT_RAID_WARNING = "Avertissement raid"
L.CHAT_OFFICER = "Officier"
L.CHAT_INSTANCE = "Instance"
L.CHAT_INSTANCE_LEADER = "Chef d'instance"

L.TAB_INFO = "|cff00ffffInfo|r"
L.INFO_BY = "par"
L.INFO_CONTENT = "Bienvenue dans votre assistant d'interface personnel !\n\n" ..
    "|cffffd100Fonctionnalités & Raccourcis :|r\n\n" ..
    "|cff00ff00- Canaux courts :|r Raccourcit les noms comme [Guilde] en [G].\n" ..
    "|cff00ff00- Support URL :|r Cliquez sur les liens dans le chat pour les copier.\n" ..
    "|cff00ff00- Couleurs d'info-bulle :|r Les joueurs s'affichent aux couleurs de leur classe.\n" ..
    "|cff00ff00- Durabilité :|r Survolez le bouton de la minicarte pour les infos.\n\n" ..
    "|cffff0000- ASTUCE PRO (Supprimer un objet) :|r\n" ..
    "Maintenez |cffffd100[MAJ]|r en supprimant un objet " ..
    "pour ne pas avoir à taper 'SUPPRIMER' !"
L.COPY_CURSE_LINK = "Appuyez sur Ctrl+C (ou Cmd+C) pour copier le lien :"
L.WELCOME_TITLE = "Bienvenue sur %s"