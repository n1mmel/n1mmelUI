local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. CLASS COLORING LOGIC
---------------------------------------------------------
function ns.ApplyUnitClassColor(statusbar, unit)
    if not unit or not statusbar.unit or statusbar.unit ~= unit then return end
    if unit ~= "target" and unit ~= "player" then return end

    local tex = statusbar:GetStatusBarTexture()
    if N1mmelUIDB.targetClassColor and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if class then
            local color = RAID_CLASS_COLORS[class]
            if color then
                if tex then tex:SetDesaturated(true) end
                statusbar:SetStatusBarColor(color.r, color.g, color.b)
                return
            end
        end
    end

    if tex then tex:SetDesaturated(false) end
    if unit == "player" then
        statusbar:SetStatusBarColor(0, 1, 0)
    elseif unit == "target" and UnitExists("target") then
        if UnitIsEnemy("player", "target") then
            statusbar:SetStatusBarColor(1, 0, 0)
        elseif UnitCanAttack("player", "target") then
            statusbar:SetStatusBarColor(1, 1, 0)
        else
            statusbar:SetStatusBarColor(0, 1, 0)
        end
    end
end

---------------------------------------------------------
-- 2. THE ULTIMATE FONT RECURSION (Deep Scan)
---------------------------------------------------------
local function SkinAllTexts(frame, size, reset)
    if not frame then return end
    
    -- NEU: Sicherheitsfilter 1 (Namen ignorieren)
    -- Wenn der Frame für Kampftext zuständig ist, brechen wir ab.
    if frame.GetName and frame:GetName() then
        local name = frame:GetName()
        if string.find(name, "HitIndicator") or string.find(name, "Feedback") then
            return 
        end
    end

    -- Wenn das Objekt ein FontString ist
    if frame:IsObjectType("FontString") then
        -- NEU: Sicherheitsfilter 2 (Riesige Schriften ignorieren)
        local _, currentSize = frame:GetFont()
        if currentSize and currentSize > 20 then
            -- Wir machen nichts! Dieser Text ist absichtlich so groß für Animationen.
        else
            if reset then
                frame:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
            else
                ns.SetUIFont(frame, size, "OUTLINE")
            end
        end
    end

    -- Rekursion für Kinder
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        SkinAllTexts(child, size, reset)
    end
    
    -- Rekursion für Regionen
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region:IsObjectType("FontString") then
            local _, currentSize = region:GetFont()
            -- Auch bei Regionen den Größen-Filter anwenden
            if not (currentSize and currentSize > 20) then
                if reset then
                    region:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
                else
                    ns.SetUIFont(region, size, "OUTLINE")
                end
            end
        end
    end
end

function ns.UpdateUnitFrameFonts()
    local targets = { PlayerFrame, TargetFrame, FocusFrame }
    local chosenSize = N1mmelUIDB.unitFrameFontSize or 13
    
    -- Wir prüfen hier, ob der Haken aus ist
    local shouldReset = not N1mmelUIDB.unitFrameFonts

    for _, frame in ipairs(targets) do
        if frame then
            -- Wir übergeben 'shouldReset' an die Skin-Funktion
            SkinAllTexts(frame, chosenSize, shouldReset)
        end
    end
end

---------------------------------------------------------
-- 3. INITIALIZATION & HOOKS
---------------------------------------------------------
function ns.ForceTargetColorUpdate()
    if PlayerFrame and PlayerFrame.healthbar then ns.ApplyUnitClassColor(PlayerFrame.healthbar, "player") end
    if TargetFrame and TargetFrame.healthbar then ns.ApplyUnitClassColor(TargetFrame.healthbar, "target") end
    ns.UpdateUnitFrameFonts()
end

hooksecurefunc("UnitFrameHealthBar_Update", ns.ApplyUnitClassColor)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
    if self.unit == "target" or self.unit == "player" then
        ns.ApplyUnitClassColor(self, self.unit)
    end
end)

-- Event handling for fonts
local fontEventFrame = CreateFrame("Frame")
fontEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
fontEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
-- DIE ZEILE MIT "UNIT_HEALTH" WURDE HIER GELÖSCHT!
fontEventFrame:SetScript("OnEvent", function()
    ns.UpdateUnitFrameFonts()
end)

-- Initial Timers
C_Timer.After(1, ns.UpdateUnitFrameFonts)
C_Timer.After(3, ns.UpdateUnitFrameFonts)