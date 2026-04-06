local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. CLASS COLORING LOGIC (Healthbars)
---------------------------------------------------------
function ns.ApplyUnitClassColor(statusbar, unit)
    -- Exit if no unit exists or it doesn't match the statusbar's target
    if not unit or not statusbar.unit or statusbar.unit ~= unit then return end
    -- Only apply to player and target frames
    if unit ~= "target" and unit ~= "player" then return end

    local tex = statusbar:GetStatusBarTexture()
    
    -- Option: Class Colors enabled and target is a player
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

    -- Default Reaction Colors (Option disabled or target is an NPC)
    if tex then tex:SetDesaturated(false) end
    
    if unit == "player" then
        statusbar:SetStatusBarColor(0, 1, 0) -- Green
    elseif unit == "target" and UnitExists("target") then
        if UnitIsEnemy("player", "target") then
            statusbar:SetStatusBarColor(1, 0, 0) -- Red (Hostile)
        elseif UnitCanAttack("player", "target") then
            statusbar:SetStatusBarColor(1, 1, 0) -- Yellow (Neutral)
        else
            statusbar:SetStatusBarColor(0, 1, 0) -- Green (Friendly)
        end
    end
end

---------------------------------------------------------
-- 2. THE ULTIMATE FONT RECURSION (Deep Scan)
---------------------------------------------------------
local function SkinAllTexts(frame, size, reset)
    if not frame then return end
    
    -- Safety Filter 1: Ignore combat text (HitIndicators)
    -- If the frame is responsible for taking damage text on the portrait, we abort.
    if frame.GetName and frame:GetName() then
        local name = frame:GetName()
        if string.find(name, "HitIndicator") or string.find(name, "Feedback") then
            return 
        end
    end

    -- If the object is a FontString
    if frame:IsObjectType("FontString") then
        -- Safety Filter 2: Ignore oversized fonts
        local _, currentSize = frame:GetFont()
        if currentSize and currentSize > 20 then
            -- Do nothing! This text is intentionally huge for Blizzard animations.
        else
            if reset then
                frame:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
            else
                ns.SetUIFont(frame, size, "OUTLINE")
            end
        end
    end

    -- Recursion for all children frames
    local children = {frame:GetChildren()}
    for _, child in ipairs(children) do
        SkinAllTexts(child, size, reset)
    end
    
    -- Recursion for all regions (where textures and fontstrings live)
    local regions = {frame:GetRegions()}
    for _, region in ipairs(regions) do
        if region:IsObjectType("FontString") then
            local _, currentSize = region:GetFont()
            -- Apply the size filter to regions as well
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
    
    -- Check if the database option for custom fonts is turned off
    local shouldReset = not N1mmelUIDB.unitFrameFonts

    for _, frame in ipairs(targets) do
        if frame then
            -- Pass the 'shouldReset' flag to the skinning function
            SkinAllTexts(frame, chosenSize, shouldReset)
        end
    end
end

---------------------------------------------------------
-- 3. INITIALIZATION & HOOKS
---------------------------------------------------------
-- Force an immediate update (used by the GUI options)
function ns.ForceTargetColorUpdate()
    if PlayerFrame and PlayerFrame.healthbar then ns.ApplyUnitClassColor(PlayerFrame.healthbar, "player") end
    if TargetFrame and TargetFrame.healthbar then ns.ApplyUnitClassColor(TargetFrame.healthbar, "target") end
    ns.UpdateUnitFrameFonts()
end

-- Hook into Blizzard's native healthbar updates
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
-- Note: "UNIT_HEALTH" was deliberately removed here to prevent FPS drops during combat!

fontEventFrame:SetScript("OnEvent", function()
    ns.UpdateUnitFrameFonts()
end)

-- Initial Timers to ensure everything is caught during the login sequence
C_Timer.After(1, ns.UpdateUnitFrameFonts)
C_Timer.After(3, ns.UpdateUnitFrameFonts)