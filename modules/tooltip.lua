local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- TOOLTIP MODIFICATIONS
-- - Class colored player names
-- - Role icon (Tank/Healer/DPS)
-- - Item Level (players only)
-- - Mythic+ Score with GUID-based cache (2h expiry)
-- - Shift+Hover: auto-inspect for players outside group
-- - Target of Target
---------------------------------------------------------

local issecret = issecretvalue or function() return false end

---------------------------------------------------------
-- M+ SCORE CACHE
-- Key: player name (Ambiguate'd), Value: { score, time }
-- GUID is secret in M+ for group members, so we use name.
-- Expires after 2 hours, cleared on zone change.
-- Max 200 entries.
---------------------------------------------------------
local CACHE_DURATION = 7200
local CACHE_MAX      = 200
local scoreCache     = {}  -- [playerName] = { score, time }

local function ScoreCacheSet(name, score)
    if not name or not score then return end
    scoreCache[name] = { score = score, time = GetTime() }
    local count = 0
    for _ in pairs(scoreCache) do count = count + 1 end
    if count > CACHE_MAX then
        local oldest, oldestKey = math.huge, nil
        for k, v in pairs(scoreCache) do
            if v.time < oldest then oldest, oldestKey = v.time, k end
        end
        if oldestKey then scoreCache[oldestKey] = nil end
    end
end

local function ScoreCacheGet(name)
    if not name then return nil end
    local entry = scoreCache[name]
    if not entry then return nil end
    if (GetTime() - entry.time) > CACHE_DURATION then
        scoreCache[name] = nil
        return nil
    end
    return entry.score
end

-- Clear on zone change (not on login/reload)
local cacheFrame = CreateFrame("Frame")
cacheFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
cacheFrame:SetScript("OnEvent", function(self, event, isLogin, isReload)
    if not isLogin and not isReload then
        scoreCache = {}
    end
end)

---------------------------------------------------------
-- ITEM LEVEL (no cache needed - Blizzard handles this)
---------------------------------------------------------
local function GetUnitItemLevel(unit)
    if unit == "player" then
        local avg = GetAverageItemLevel()
        if avg and not issecret(avg) then return math.floor(avg) end
        return nil
    end
    if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
        local ilvl = C_PaperDollInfo.GetInspectItemLevel(unit)
        if ilvl and not issecret(ilvl) and ilvl > 0 then
            return math.floor(ilvl)
        end
    end
    local total, count = 0, 0
    for slot = 1, 17 do
        if slot ~= 4 then
            local itemLink = GetInventoryItemLink(unit, slot)
            if itemLink and not issecret(itemLink) then
                local ilvl = C_Item.GetDetailedItemLevelInfo(itemLink)
                if ilvl and not issecret(ilvl) and ilvl > 0 then
                    total = total + ilvl
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then return math.floor(total / count) end
    return nil
end

---------------------------------------------------------
-- SHIFT+HOVER INSPECT
-- On INSPECT_READY: read M+ score, write to cache,
-- refresh tooltip instantly.
---------------------------------------------------------
local inspectCooldown = 0

local inspectFrame = CreateFrame("Frame")
inspectFrame:RegisterEvent("INSPECT_READY")
inspectFrame:SetScript("OnEvent", function(self, event, guid)
    if not GameTooltip:IsShown() then return end
    local _, unit = GameTooltip:GetUnit()
    if not unit or issecret(unit) then return end
    -- Check GUID match via pcall (can be secret)
    local ok, unitGuid = pcall(UnitGUID, unit)
    if ok and unitGuid and not issecret(unitGuid) and unitGuid ~= guid then return end
    -- Read fresh score and cache by name
    if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
        local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
        if summary and not issecret(summary) then
            local s = summary.currentSeasonScore
            if s and not issecret(s) and s > 0 then
                local unitName = UnitName(unit)
                if unitName and not issecret(unitName) then
                    local key = Ambiguate(unitName, "none")
                    ScoreCacheSet(key, math.floor(s))
                end
            end
        end
    end
    GameTooltip:SetUnit(unit)
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit or issecret(unit) then return end

    if UnitIsPlayer(unit) then

        -- Class color for name
        local _, classTag = UnitClass(unit)
        local color = RAID_CLASS_COLORS[classTag]
        if color then
            local nameLine = _G[tooltip:GetName() .. "TextLeft1"]
            if nameLine then
                nameLine:SetTextColor(color.r, color.g, color.b)
            end
        end

        -- Role icon
        local role = UnitGroupRolesAssigned(unit)
        if role and role ~= "NONE" and not issecret(role) then
            local iconPath
            if role == "TANK" then
                iconPath = "Interface\\AddOns\\n1mmelUI\\media\\images\\Tank.tga"
            elseif role == "HEALER" then
                iconPath = "Interface\\AddOns\\n1mmelUI\\media\\images\\Healer.tga"
            elseif role == "DAMAGER" then
                iconPath = "Interface\\AddOns\\n1mmelUI\\media\\images\\DPS.tga"
            end
            if iconPath then
                tooltip:AddLine(
                    (L.TOOLTIP_ROLE or "Role:") .. " |T" .. iconPath .. ":16:16|t",
                    1, 1, 1
                )
            end
        end

        -- Item Level (Blizzard caches this, no extra cache needed)
        local ilvl = GetUnitItemLevel(unit)
        if ilvl and ilvl > 0 then
            tooltip:AddLine(
                (L.TOOLTIP_ILVL or "Item Level:") .. " |cffffd100" .. ilvl .. "|r",
                1, 1, 1
            )
        end

        -- Mythic+ Score: name-based cache (GUID is secret in M+)
        local cacheKey = nil
        local unitName = UnitName(unit)
        if unitName and not issecret(unitName) then
            cacheKey = Ambiguate(unitName, "none")
        end

        local score = cacheKey and ScoreCacheGet(cacheKey)
        if not score then
            -- Try live API
            if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
                local summary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
                if summary and not issecret(summary) then
                    local s = summary.currentSeasonScore
                    if s and not issecret(s) and s > 0 then
                        score = math.floor(s)
                        if cacheKey then ScoreCacheSet(cacheKey, score) end
                    end
                end
            end
        end

        if score and score > 0 then
            local ratingColor = C_ChallengeMode and
                C_ChallengeMode.GetDungeonScoreRarityColor and
                C_ChallengeMode.GetDungeonScoreRarityColor(score)
            local hex
            if ratingColor and not issecret(ratingColor) then
                hex = string.format("|cff%02x%02x%02x",
                    ratingColor.r * 255,
                    ratingColor.g * 255,
                    ratingColor.b * 255)
            else
                hex = "|cffa335ee"
            end
            tooltip:AddLine(
                (L.TOOLTIP_MPLUS or "Mythic+ Score:") ..
                " " .. hex .. score .. "|r",
                1, 1, 1
            )
        end

        -- Shift+Hover: always available for players outside group
        if IsShiftKeyDown() and unit ~= "player"
        and not UnitInParty(unit) and not UnitInRaid(unit) then
            local now = GetTime()
            if now - inspectCooldown >= 2 then
                inspectCooldown = now
                NotifyInspect(unit)
            end
        end
    end

    ---------------------------------------------------------
    -- Target of Target
    ---------------------------------------------------------
    local targetUnit = unit .. "target"
    local targetExists = UnitExists(targetUnit)
    if not targetExists or issecret(targetExists) then return end

    local targetName = UnitName(targetUnit)
    if not targetName or issecret(targetName) then return end

    local hexColor = "ffffffff"
    if UnitIsPlayer(targetUnit) then
        local _, classTag = UnitClass(targetUnit)
        local c = RAID_CLASS_COLORS[classTag]
        if c then
            hexColor = string.format("ff%02x%02x%02x",
                c.r * 255, c.g * 255, c.b * 255)
        end
    else
        local reaction = UnitReaction(targetUnit, "player")
        if reaction and not issecret(reaction) then
            if reaction < 4 then
                hexColor = "ffff2222"
            elseif reaction == 4 then
                hexColor = "ffffff22"
            else
                hexColor = "ff22ff22"
            end
        end
    end

    tooltip:AddLine(" ")
    tooltip:AddLine(
        (L.TOOLTIP_TARGET or "Target:") ..
        " |c" .. hexColor .. targetName .. "|r"
    )
end)