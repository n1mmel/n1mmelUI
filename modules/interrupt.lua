local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- INTERRUPT TRACKER
-- Shows a small frame that indicates when your interrupt
-- spell is ready, on cooldown, or not available (e.g. GCD).
-- Spell name is read from the DB so it works for any class.
---------------------------------------------------------

-- The frame itself
local interruptFrame = CreateFrame("Frame", "N1mmelInterruptFrame", UIParent, "BackdropTemplate")
interruptFrame:SetSize(120, 34)
interruptFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
interruptFrame:SetMovable(true)
interruptFrame:EnableMouse(true)
interruptFrame:RegisterForDrag("LeftButton")
interruptFrame:SetScript("OnDragStart", interruptFrame.StartMoving)
interruptFrame:SetScript("OnDragStop", interruptFrame.StopMovingOrSizing)
interruptFrame:SetFrameStrata("MEDIUM")
interruptFrame:SetClampedToScreen(true)

interruptFrame:SetBackdrop({
    bgFile   = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    edgeSize = 2,
    insets   = { left = 2, right = 2, top = 2, bottom = 2 }
})
interruptFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.85)
interruptFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

-- Spell icon on the left
local iconTex = interruptFrame:CreateTexture(nil, "ARTWORK")
iconTex:SetSize(26, 26)
iconTex:SetPoint("LEFT", interruptFrame, "LEFT", 4, 0)
iconTex:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim default icon border

-- Status text on the right
local statusText = interruptFrame:CreateFontString(nil, "OVERLAY")
statusText:SetPoint("LEFT", iconTex, "RIGHT", 6, 0)
statusText:SetPoint("RIGHT", interruptFrame, "RIGHT", -4, 0)
statusText:SetJustifyH("CENTER")
if ns.SetUIFont then ns.SetUIFont(statusText, 13, "OUTLINE") end

-- Cooldown indicator bar along the bottom
local cdBar = interruptFrame:CreateTexture(nil, "OVERLAY")
cdBar:SetHeight(3)
cdBar:SetPoint("BOTTOMLEFT",  interruptFrame, "BOTTOMLEFT",  2, 2)
cdBar:SetPoint("BOTTOMRIGHT", interruptFrame, "BOTTOMRIGHT", -2, 2)
cdBar:SetColorTexture(0.2, 0.6, 1, 0.9)

-- Hide by default; shown only when the feature is enabled
interruptFrame:Hide()

---------------------------------------------------------
-- CORE LOGIC
---------------------------------------------------------
local spellID       = nil   -- resolved once per session
local spellName     = nil
local lastCDStart   = 0     -- GetTime() when the CD started (local fallback)
local lastCDTotal   = 0     -- known total CD duration (local fallback)
local knownCDTotal  = 0     -- pre-cached CD duration read outside combat

-- Interrupt spell data per class: { spellID, baseCooldown, talentID, talentCooldown }
-- Talent reduces the CD if the player has learned it.
-- This mirrors exactly what Plater's interrupt tracker does.
local CLASS_INTERRUPT_DATA = {
    [1]  = { id = 6552,   cd = 15 },                          -- Warrior: Pummel
    [2]  = { id = 96231,  cd = 15 },                          -- Paladin: Rebuke
    [3]  = { id = 147362, cd = 24, alt = 187707, altcd = 15 }, -- Hunter: Counter Shot / Muzzle
    [4]  = { id = 1766,   cd = 15 },                          -- Rogue: Kick
    [5]  = { id = 15487,  cd = 45 },                          -- Priest: Silence (Shadow)
    [6]  = { id = 47528,  cd = 15 },                          -- Death Knight: Mind Freeze
    [7]  = { id = 57994,  cd = 12 },                          -- Shaman: Wind Shear
    [8]  = { id = 2139,   cd = 25, talent = 382297, tcd = 20 }, -- Mage: Counterspell (Quick Witted)
    [9]  = { id = 19647,  cd = 24 },                          -- Warlock: Spell Lock
    [10] = { id = 116705, cd = 15 },                          -- Monk: Spear Hand Strike
    [11] = { id = 106839, cd = 15, alt = 78675, altcd = 60 }, -- Druid: Skull Bash / Solar Beam
    [12] = { id = 183752, cd = 15 },                          -- Demon Hunter: Disrupt
    [13] = { id = 351338, cd = 20 },                          -- Evoker: Quell
}

-- Calculate the effective cooldown duration for the configured spell.
-- Checks talents that reduce the CD. Called outside combat only.
local function CalculateEffectiveCooldown()
    if not spellID then return 0 end

    -- Find the class data entry matching our spellID
    local _, _, classID = UnitClass("player")
    local data = CLASS_INTERRUPT_DATA[classID]

    if data then
        -- Check if our spellID matches this class entry
        local matchedCD = nil
        if data.id == spellID then
            matchedCD = data.cd
            -- Check for talent that reduces CD
            if data.talent and C_SpellBook and C_SpellBook.IsSpellKnown then
                if C_SpellBook.IsSpellKnown(data.talent) then
                    matchedCD = data.tcd or matchedCD
                end
            end
        elseif data.alt and data.alt == spellID then
            matchedCD = data.altcd or data.cd
        end

        if matchedCD then
            return matchedCD
        end
    end

    -- Unknown spell: try GetSpellInfo baseCooldown (milliseconds)
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info and info.baseCooldown and info.baseCooldown > 1500 then
            return info.baseCooldown / 1000
        end
    end

    return 0
end

-- Update knownCDTotal from calculated duration (call outside combat)
local function CacheSpellDuration()
    if not spellID then return end
    local dur = CalculateEffectiveCooldown()
    if dur > 1.5 then
        knownCDTotal = dur
        lastCDTotal  = dur
    end
end

-- Resolve the spell ID by searching the player's own spellbook.
-- This is the most reliable method: language-independent, no API name lookup needed.
local function ResolveSpell()
    local input = N1mmelUIDB.interruptSpell
    if not input or input == "" then
        spellID   = nil
        spellName = nil
        iconTex:SetTexture(nil)
        return
    end

    spellID   = nil
    spellName = input

    -- Case 1: Input is a numeric ID – use directly
    local numericID = tonumber(input)
    if numericID and numericID > 0 then
        spellID = numericID
    end

    -- Case 2: Input is a spell name – search the player's spellbook
    -- This works regardless of client language or API availability
    if not spellID then
        local inputLower = input:lower()
        local bookType = "spell"

        -- Iterate through all spellbook tabs
        local numTabs = C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines
            and C_SpellBook.GetNumSpellBookSkillLines() or 0

        for tab = 1, numTabs do
            local tabInfo = C_SpellBook.GetSpellBookSkillLineInfo(tab)
            if tabInfo then
                local offset = tabInfo.itemIndexOffset
                local numSpells = tabInfo.numSpellBookItems
                for i = 1, numSpells do
                    local slotIndex = offset + i
                    local spellInfo = C_SpellBook.GetSpellBookItemInfo(slotIndex, Enum.SpellBookSpellBank.Player)
                    if spellInfo and spellInfo.spellID then
                        local info = C_Spell.GetSpellInfo(spellInfo.spellID)
                        if info and info.name and info.name:lower() == inputLower then
                            spellID = spellInfo.spellID
                            break
                        end
                    end
                end
            end
            if spellID then break end
        end

        -- Fallback: try C_Spell.FindSpellOverrideByName if spellbook search failed
        if not spellID and C_Spell and C_Spell.FindSpellOverrideByName then
            local id = C_Spell.FindSpellOverrideByName(input)
            if id and id > 0 then spellID = id end
        end
    end

    -- Get icon and canonical name from resolved ID
    if spellID then
        local info = C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
        if info then
            spellName = info.name or input
            -- Always store the canonical (localized) spell name in DB
            if N1mmelUIDB and info.name then
                N1mmelUIDB.interruptSpell = info.name
            end
            if info.iconID then
                iconTex:SetTexture(info.iconID)
            end
        end
        -- Cache the CD duration now while we are (likely) outside combat
        CacheSpellDuration()
        return
    else
        iconTex:SetTexture(134400)
    end
end

local function UpdateDisplay()
    if not N1mmelUIDB or not N1mmelUIDB.interruptTracker then
        interruptFrame:Hide()
        return
    end
    interruptFrame:Show()

    if not spellID then
        statusText:SetText(L.INTERRUPT_NO_SPELL or "No spell set")
        statusText:SetTextColor(0.6, 0.6, 0.6)
        cdBar:SetTexCoord(0, 0, 0, 0)
        interruptFrame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
        return
    end

    -- Pure self-timer approach (same as Plater's first script):
    -- We track lastCDStart (set by UNIT_SPELLCAST_SUCCEEDED) and
    -- lastCDTotal (the known duration, cached before combat).
    -- We never read Blizzard's CD API during combat to avoid secret value errors.

    local now       = GetTime()
    local remaining = 0
    local duration  = lastCDTotal

    if lastCDStart > 0 and lastCDTotal > 1.5 then
        remaining = (lastCDStart + lastCDTotal) - now
        if remaining < 0 then remaining = 0 end
    end

    -- Outside combat, also sync with Blizzard's API to catch
    -- edge cases (e.g. CD already running when tracker is enabled)
    if not InCombatLockdown() and C_Spell and C_Spell.GetSpellCooldown then
        local cdInfo = C_Spell.GetSpellCooldown(spellID)
        local issecret = issecretvalue or function() return false end
        if cdInfo then
            local startTime = cdInfo.startTime
            local dur       = cdInfo.duration
            if not issecret(startTime) and not issecret(dur)
            and type(startTime) == "number" and type(dur) == "number" then
                if startTime > 0 and dur > 1.5 then
                    -- Real CD is running – sync our timer
                    lastCDStart = startTime
                    lastCDTotal = dur
                    knownCDTotal = dur
                    duration  = dur
                    remaining = (startTime + dur) - now
                    if remaining < 0 then remaining = 0 end
                elseif lastCDStart > 0 and remaining <= 0 then
                    -- CD expired – reset
                    lastCDStart = 0
                    remaining   = 0
                end
            end
        end
    end

    if remaining > 0 then
        local safeDuration = (duration > 0) and duration or 1
        local pct = math.max(0, math.min(1, remaining / safeDuration))
        cdBar:SetPoint("BOTTOMRIGHT", interruptFrame, "BOTTOMLEFT",
            2 + ((interruptFrame:GetWidth() - 4) * (1 - pct)), 2)
        statusText:SetText(string.format("%.1fs", remaining))
        statusText:SetTextColor(1, 0.3, 0.3)
        interruptFrame:SetBackdropBorderColor(0.6, 0.1, 0.1, 1)
    else
        cdBar:SetPoint("BOTTOMRIGHT", interruptFrame, "BOTTOMRIGHT", -2, 2)
        statusText:SetText(L.INTERRUPT_READY or "READY!")
        statusText:SetTextColor(0.2, 1, 0.2)
        interruptFrame:SetBackdropBorderColor(0.1, 0.8, 0.1, 1)
    end
end

-- OnUpdate ticker (only runs when frame is shown)
local ticker = 0
interruptFrame:SetScript("OnUpdate", function(self, elapsed)
    ticker = ticker + elapsed
    if ticker >= 0.1 then
        ticker = 0
        UpdateDisplay()
    end
end)

---------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------
function ns.UpdateInterruptTracker()
    if not N1mmelUIDB then return end
    if N1mmelUIDB.interruptTracker then
        ResolveSpell()
        interruptFrame:Show()
        UpdateDisplay()
    else
        interruptFrame:Hide()
    end
end

function ns.SetInterruptSpell(name)
    N1mmelUIDB.interruptSpell = name or ""
    ResolveSpell()
    UpdateDisplay()
end

function ns.GetInterruptSpellID()
    return spellID
end

-- Position save/restore
interruptFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    N1mmelUIDB.interruptPos = { point, nil, relPoint, x, y }
end)

---------------------------------------------------------
-- INIT
---------------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
initFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")    -- talent changes
initFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
initFrame:SetScript("OnEvent", function(self, event, unit, _, castSpellID)

    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        if unit == "player" and spellID and castSpellID == spellID then
            -- Record cast time immediately.
            -- We use knownCDTotal which was cached BEFORE combat via CacheSpellDuration().
            -- We never call GetSpellCooldown() here because it returns secret values in combat.
            lastCDStart = GetTime()
            if knownCDTotal > 1.5 then
                lastCDTotal = knownCDTotal
            end
            -- If knownCDTotal is still 0 (first ever cast, no pre-cache),
            -- try reading out-of-combat API one frame later as last resort.
            if lastCDTotal <= 1.5 then
                C_Timer.After(0.5, function()
                    if not InCombatLockdown() then
                        CacheSpellDuration()
                    end
                end)
            end
        end
        return
    end

    if event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")

        -- Restore saved position
        if N1mmelUIDB and N1mmelUIDB.interruptPos then
            local p = N1mmelUIDB.interruptPos
            interruptFrame:ClearAllPoints()
            interruptFrame:SetPoint(p[1] or "CENTER", nil, p[3] or "CENTER", p[4] or 0, p[5] or 0)
        end

        ns.UpdateInterruptTracker()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        -- Second attempt: spell lookup APIs are fully available now.
        if not spellID and N1mmelUIDB and N1mmelUIDB.interruptTracker then
            ResolveSpell()
            UpdateDisplay()
        end
        -- Always re-cache duration on zone change (outside combat)
        CacheSpellDuration()

        local box = _G["N1mmelInterruptSpellBox"]
        if box and N1mmelUIDB and N1mmelUIDB.interruptSpell then
            box:SetText(N1mmelUIDB.interruptSpell)
        end
        return
    end

    if event == "PLAYER_REGEN_ENABLED" or event == "TRAIT_CONFIG_UPDATED" then
        -- Combat ended or talents changed – recalculate effective CD duration
        CacheSpellDuration()
        return
    end
end)