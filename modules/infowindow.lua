local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. SESSION DATA (Save on Login)
---------------------------------------------------------
-- Save the initial gold amount exactly when the player logs in
-- Default to 0 until PLAYER_LOGIN fires and we have a valid value
local sessionStartCopper = 0
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    sessionStartCopper = GetMoney() or 0
end)

---------------------------------------------------------
-- 2. MAIN INFO WINDOW
---------------------------------------------------------
ns.infoWindow = CreateFrame("Frame", "n1mmelUI_InfoWindow", UIParent, "BackdropTemplate")
ns.infoWindow:SetSize(130, 110)
ns.infoWindow:SetPoint("CENTER")

-- Make the window draggable
ns.infoWindow:SetMovable(true)
ns.infoWindow:EnableMouse(true)
ns.infoWindow:RegisterForDrag("LeftButton")
ns.infoWindow:SetScript("OnDragStart", ns.infoWindow.StartMoving)
ns.infoWindow:SetScript("OnDragStop", ns.infoWindow.StopMovingOrSizing)

-- Modern, flat backdrop styling
ns.infoWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 3, 
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})

ns.infoWindow:SetBackdropColor(0.05, 0.05, 0.05, 0.6)
ns.infoWindow:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Title ("Info" uses GameFontNormalLarge for the default yellow/orange color)
local titleInfo = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleInfo:SetPoint("TOP", 0, -10)
titleInfo:SetText(L.TAB_INFO and L.TAB_INFO:gsub("|c........", ""):gsub("|r", "") or "Info") -- Strip color codes if present, or fallback
if ns.SetUIFont then ns.SetUIFont(titleInfo, 14, "OUTLINE") end

-- Divider line below the title
local infoDivider = ns.infoWindow:CreateTexture(nil, "ARTWORK")
infoDivider:SetSize(90, 1)
infoDivider:SetPoint("TOP", titleInfo, "BOTTOM", 0, -5) 
infoDivider:SetColorTexture(ns.classColor.r, ns.classColor.g, ns.classColor.b, 0.8)

-- Update divider color once class colors are known (PLAYER_LOGIN)
local colorUpdateFrame = CreateFrame("Frame")
colorUpdateFrame:RegisterEvent("PLAYER_LOGIN")
colorUpdateFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    infoDivider:SetColorTexture(ns.classColor.r, ns.classColor.g, ns.classColor.b, 0.8)
end)

-- Durability text (GameFontHighlight = White)
local durText = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
durText:SetPoint("TOP", infoDivider, "BOTTOM", 0, -5)
durText:SetJustifyH("CENTER")
if ns.SetUIFont then ns.SetUIFont(durText, 12, "OUTLINE") end

-- Bag slots text (GameFontHighlight = White)
local bagText = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
bagText:SetPoint("TOP", durText, "BOTTOM", 0, -5)
bagText:SetJustifyH("CENTER")
if ns.SetUIFont then ns.SetUIFont(bagText, 12, "OUTLINE") end

-- Gold text (GameFontHighlight = White)
local goldText = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
goldText:SetPoint("TOP", bagText, "BOTTOM", 0, -5)
goldText:SetJustifyH("CENTER")
if ns.SetUIFont then ns.SetUIFont(goldText, 12, "OUTLINE") end

-- Ping text (GameFontHighlight = White)
local pingText = ns.infoWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
pingText:SetPoint("TOP", goldText, "BOTTOM", 0, -5)
pingText:SetJustifyH("CENTER")
if ns.SetUIFont then ns.SetUIFont(pingText, 12, "OUTLINE") end
pingText:SetText(L.PING .. " |cffffffff... ms|r")

---------------------------------------------------------
-- 3. CUSTOM GOLD HOVER TOOLTIP
---------------------------------------------------------
local customGoldTooltip = CreateFrame("Frame", nil, ns.infoWindow, "BackdropTemplate")
customGoldTooltip:SetSize(110, 45) 
customGoldTooltip:SetFrameStrata("TOOLTIP") 
customGoldTooltip:Hide()

-- Matches the main window styling but with thinner borders
customGoldTooltip:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
customGoldTooltip:SetBackdropColor(0.05, 0.05, 0.05, 0.6) 
customGoldTooltip:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Tooltip Title text
local ttTitle = customGoldTooltip:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
ttTitle:SetPoint("TOP", 0, -6)
if ns.SetUIFont then ns.SetUIFont(ttTitle, 11, "OUTLINE") end
ttTitle:SetText(L.SESSION_GOLD or "Session (Gold)") 

-- Tooltip Value text
local ttValue = customGoldTooltip:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
ttValue:SetPoint("TOP", ttTitle, "BOTTOM", 0, -4)
if ns.SetUIFont then ns.SetUIFont(ttValue, 12, "OUTLINE") end

-- Invisible frame over the gold text to catch mouse events
local goldHoverFrame = CreateFrame("Frame", nil, ns.infoWindow)
goldHoverFrame:SetAllPoints(goldText) 
goldHoverFrame:EnableMouse(true)

goldHoverFrame:SetScript("OnEnter", function(self)
    -- Calculate profit/loss
    local currentCopper = GetMoney()
    local diffCopper = currentCopper - sessionStartCopper
    local diffGold = math.floor(math.abs(diffCopper) / 10000) 
    local formattedDiff = BreakUpLargeNumbers(diffGold)
    
    -- Colorize output
    if diffCopper > 0 then
        ttValue:SetText("|cff00ff00+" .. formattedDiff .. "g|r")
    elseif diffCopper < 0 then
        ttValue:SetText("|cffff0000-" .. formattedDiff .. "g|r")
    else
        ttValue:SetText("|cffffffff 0g|r")
    end
    
    -- Anchor and show the custom tooltip
    customGoldTooltip:ClearAllPoints()
    customGoldTooltip:SetPoint("LEFT", ns.infoWindow, "RIGHT", 5, 0)
    customGoldTooltip:Show()
end)

goldHoverFrame:SetScript("OnLeave", function(self)
    customGoldTooltip:Hide()
end)

---------------------------------------------------------
-- 4. UPDATE FUNCTION & TIMER
---------------------------------------------------------
local function UpdateInfoData()
    if not ns.infoWindow:IsShown() then return end

    -- 1. Gold Update
    local copper = GetMoney()
    local gold = math.floor(copper / 10000)
    local formattedGold = BreakUpLargeNumbers(gold)
    goldText:SetText(L.GOLD .. " |cffffffff" .. formattedGold .. "g|r")

    -- 2. Durability Update
    local currentDur, maxDur = 0, 0
    for i = 1, 18 do
        local cur, max = GetInventoryItemDurability(i)
        if cur and max then
            currentDur = currentDur + cur
            maxDur = maxDur + max
        end
    end
    
    local durPercent = (maxDur > 0) and math.floor((currentDur / maxDur) * 100) or 100
    local r, g, b = 0, 1, 0
    if durPercent < 30 then r, g, b = 1, 0, 0
    elseif durPercent < 70 then r, g, b = 1, 1, 0 end
    durText:SetText(string.format(L.DURABILITY .. " |cff%02x%02x%02x%d%%|r", r * 255, g * 255, b * 255, durPercent))

    -- 3. Free Bag Slots Update
    local freeSlots = 0
    for i = 0, 4 do
        freeSlots = freeSlots + C_Container.GetContainerNumFreeSlots(i)
    end
    bagText:SetText(L.EMPTYSLOTS .. " |cffffffff" .. freeSlots .. "|r")

    -- 4. Ping Update 
    local _, _, _, worldPing = GetNetStats()
    if worldPing > 0 then
        local pr, pg, pb = 0, 1, 0
        if worldPing > 150 then pr, pg, pb = 1, 0, 0
        elseif worldPing > 80 then pr, pg, pb = 1, 1, 0 end
        pingText:SetText(string.format("%s |cff%02x%02x%02x%d ms|r", L.PING, pr * 255, pg * 255, pb * 255, worldPing))
    end
end

-- Timer for live updates (ticks every 3 seconds)
ns.infoWindow:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer > 3.0 then
        UpdateInfoData()
        self.timer = 0
    end
end)

-- Start hidden by default
ns.infoWindow:Hide()