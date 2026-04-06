local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- INFO WINDOW 
---------------------------------------------------------

ns.infoWindow = CreateFrame("Frame", "n1mmelUI_InfoWindow", UIParent, "BackdropTemplate")
-- Nur noch einmal SetSize (breit genug für den Text)
ns.infoWindow:SetSize(130, 100)
ns.infoWindow:SetPoint("CENTER")

-- Fenster verschiebbar machen
ns.infoWindow:SetMovable(true)
ns.infoWindow:EnableMouse(true)
ns.infoWindow:RegisterForDrag("LeftButton")
ns.infoWindow:SetScript("OnDragStart", ns.infoWindow.StartMoving)
ns.infoWindow:SetScript("OnDragStop", ns.infoWindow.StopMovingOrSizing)

-- 2. Modernes, flaches Backdrop (Minimalistisch)
ns.infoWindow:SetBackdrop({
    -- Wir nutzen einen reinen weißen Pixel als Basis für Hintergrund UND Rahmen
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 1, -- Ein hauchdünner 1-Pixel-Rahmen
    insets = { left = 1, right = 1, top = 1, bottom = 1 } -- Verhindert, dass der Rahmen überlappt
})

-- 3. Die Farben setzen (Rot, Grün, Blau, Deckkraft)
-- Hintergrund: Sehr dunkles Grau (fast schwarz wie in deinem Hauptmenü), 90% deckend
ns.infoWindow:SetBackdropColor(0.05, 0.05, 0.05, 0.4)

-- Rahmen: Ein dezentes Mittel-/Dunkelgrau, 100% deckend
ns.infoWindow:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Titel
local titleInfo = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleInfo:SetPoint("TOP", 0, -10)
titleInfo:SetText("Info")
if ns.SetUIFont then
    ns.SetUIFont(titleInfo, 14, "OUTLINE")
end

-- Divider (Trennlinie) in der neuen, globalen Klassenfarbe!
local infoDivider = ns.infoWindow:CreateTexture(nil, "ARTWORK")
infoDivider:SetSize(90, 1)
infoDivider:SetPoint("TOP", titleInfo, "BOTTOM", 0, -5) -- Etwas näher an den Titel gerückt
-- Hier greifen wir auf die r, g und b Werte aus der core.lua zu:
infoDivider:SetColorTexture(ns.classColor.r, ns.classColor.g, ns.classColor.b, 0.8)


-- Textfeld für Haltbarkeit
local durText = ns.infoWindow:CreateFontString(nil, "OVERLAY")
-- Zentriert unter dem Divider aufhängen
durText:SetPoint("TOP", infoDivider, "BOTTOM", 0, -10)
durText:SetJustifyH("CENTER")
if ns.SetUIFont then
    ns.SetUIFont(durText, 12, "OUTLINE")
end

-- Textfeld für Taschenplätze
local bagText = ns.infoWindow:CreateFontString(nil, "OVERLAY")
-- Zentriert unter dem Haltbarkeits-Text aufhängen
bagText:SetPoint("TOP", durText, "BOTTOM", 0, -5)
bagText:SetJustifyH("CENTER")
if ns.SetUIFont then
    ns.SetUIFont(bagText, 12, "OUTLINE")
end

-- Gold-Textfeld 
local goldText = ns.infoWindow:CreateFontString(nil, "OVERLAY")
-- Zentriert unter dem Taschen-Text aufhängen
goldText:SetPoint("TOP", bagText, "BOTTOM", 0, -5)
goldText:SetJustifyH("CENTER")
if ns.SetUIFont then
    ns.SetUIFont(goldText, 12, "OUTLINE")
end

-- Update-Funktion für die Daten
local function UpdateInfoData()
    if not ns.infoWindow:IsShown() then return end


    -- Aktuelles Gold abrufen
    local copper = GetMoney()
    local gold = math.floor(copper / 10000)
    local formattedGold = BreakUpLargeNumbers(gold) -- Fügt Tausendertrennzeichen hinzu
    goldText:SetText(L.GOLD .. " |cffffffff" .. formattedGold .. "g|r")


    -- Haltbarkeit berechnen
    local currentDur, maxDur = 0, 0
    for i = 1, 18 do
        local cur, max = GetInventoryItemDurability(i)
        if cur and max then
            currentDur = currentDur + cur
            maxDur = maxDur + max
        end
    end

    local durPercent = 100
    if maxDur > 0 then
        durPercent = math.floor((currentDur / maxDur) * 100)
    end

    -- Farbe der Haltbarkeit bestimmen
    local r, g, b = 0, 1, 0
    if durPercent < 30 then
        r, g, b = 1, 0, 0
    elseif durPercent < 70 then
        r, g, b = 1, 1, 0
    end

    durText:SetText(string.format(L.DURABILITY .. " |cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, durPercent))

    -- Freie Taschenplätze berechnen
    local freeSlots = 0
    for i = 0, 4 do
        freeSlots = freeSlots + C_Container.GetContainerNumFreeSlots(i)
    end
    bagText:SetText(L.EMPTYSLOTS .. " |cffffffff" .. freeSlots .. "|r")
end

-- Timer für Live-Updates
ns.infoWindow:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 3.0 then
        UpdateInfoData()
        self.timer = 0
    end
end)

ns.infoWindow:Hide()