local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- TOOLTIP MODIFICATIONS
-- - Class colored player names
-- - Role icon (Tank/Healer/DPS)
-- - Item Level (players only)
-- - Shift+Hover: auto-inspect for players outside group
-- - Target of Target
---------------------------------------------------------

local issecret = issecretvalue or function() return false end

-- Get item level for a unit, fully guarded against secret values
local function GetUnitItemLevel(unit)
    if unit == "player" then
        local avg = GetAverageItemLevel()
        if avg and not issecret(avg) then return math.floor(avg) end
        return nil
    end

    -- C_PaperDollInfo.GetInspectItemLevel can return a secret value in M+
    if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
        local ilvl = C_PaperDollInfo.GetInspectItemLevel(unit)
        if ilvl and not issecret(ilvl) and ilvl > 0 then
            return math.floor(ilvl)
        end
    end

    -- Fallback: sum item slots via itemLinks (links are strings, never secret)
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
-- SHIFT+HOVER: auto-inspect for players outside group
-- Party/raid members: Blizzard caches data automatically.
-- Others: hold Shift while hovering to trigger NotifyInspect.
-- INSPECT_READY fires ~0.5s later and refreshes the tooltip.
---------------------------------------------------------
local inspectCooldown = 0

local inspectFrame = CreateFrame("Frame")
inspectFrame:RegisterEvent("INSPECT_READY")
inspectFrame:SetScript("OnEvent", function(self, event, guid)
    if not GameTooltip:IsShown() then return end
    local _, unit = GameTooltip:GetUnit()
    if not unit or issecret(unit) then return end
    -- UnitGUID can be secret in M+ for enemy units - use pcall
    local ok, unitGuid = pcall(UnitGUID, unit)
    if ok and unitGuid and unitGuid == guid then
        GameTooltip:SetUnit(unit)
    end
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit or issecret(unit) then return end

    ---------------------------------------------------------
    -- 2. Players only: class color + role icon + item level
    ---------------------------------------------------------
    if UnitIsPlayer(unit) then

        -- 2a. Class color for the name line
        local _, classTag = UnitClass(unit)
        local color = RAID_CLASS_COLORS[classTag]
        if color then
            local nameLine = _G[tooltip:GetName() .. "TextLeft1"]
            if nameLine then
                nameLine:SetTextColor(color.r, color.g, color.b)
            end
        end

        -- 2b. Role icon
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

        -- 2c. Item level (guarded: GetInspectItemLevel can be secret in M+)
        local ilvl = GetUnitItemLevel(unit)
        if ilvl and ilvl > 0 then
            tooltip:AddLine(
                (L.TOOLTIP_ILVL or "Item Level:") .. " |cffffd100" .. ilvl .. "|r",
                1, 1, 1
            )
        end

        -- 2d. Shift+Hover: request inspect for players outside our group
        -- so item level becomes available on next tooltip refresh (~0.5s)
        if IsShiftKeyDown()
        and not UnitInParty(unit) and not UnitInRaid(unit)
        and unit ~= "player" then
            local now = GetTime()
            if now - inspectCooldown >= 2 then
                inspectCooldown = now
                NotifyInspect(unit)
            end
        end
    end

    ---------------------------------------------------------
    -- 3. Target of Target
    --    UnitName(xTarget) and UnitExists(xTarget) ARE
    --    protected in Midnight -> full issecretvalue guards
    ---------------------------------------------------------
    local targetUnit = unit .. "target"

    -- UnitExists can return a secret value for enemy targets in M+
    local targetExists = UnitExists(targetUnit)
    if targetExists and issecret(targetExists) then return end
    if not targetExists then return end

    local targetName = UnitName(targetUnit)
    -- UnitName for non-party targets is protected in M+
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