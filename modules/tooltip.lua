local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- TOOLTIP CLASS COLORS, ROLES & TARGET
---------------------------------------------------------
local issecret = issecretvalue or function() return false end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    local _, unit = tooltip:GetUnit()
    
    -- Wenn es keine Einheit gibt oder sie von Blizzard versteckt wird -> Abbruch!
    if not unit or issecret(unit) then return end

    -- 1. Klassenfarbe für Spielernamen
    if UnitIsPlayer(unit) then
        local _, classTag = UnitClass(unit)
        local color = RAID_CLASS_COLORS[classTag]
        
        if color then
            local tooltipName = tooltip:GetName()
            local nameLine = _G[tooltipName .. "TextLeft1"]
            if nameLine then
                nameLine:SetTextColor(color.r, color.g, color.b)
            end
        end
        
        -- 2. Rollenerkennung (Funktioniert für Gruppen- und Raidmitglieder)
        local role = UnitGroupRolesAssigned(unit)
        if role and role ~= "NONE" then
            local roleText = ""
            local r, g, b = 1, 1, 1
            
            if role == "TANK" then
                roleText = L.ROLE_TANK or "Rolle: Tank"
                r, g, b = 0.4, 0.6, 1 -- Helles Blau
            elseif role == "HEALER" then
                roleText = L.ROLE_HEALER or "Rolle: Heiler"
                r, g, b = 0.4, 1, 0.4 -- Helles Grün
            elseif role == "DAMAGER" then
                roleText = L.ROLE_DAMAGER or "Rolle: DD"
                r, g, b = 1, 0.4, 0.4 -- Helles Rot
            end
            
            tooltip:AddLine(roleText, r, g, b)
        end
    end

    -- 3. Ziel des Ziels (Target of Target)
    local targetUnit = unit .. "target"
    
    -- Auch hier prüfen, ob die Ziel-Einheit eventuell geschützt ist
    if not issecret(targetUnit) and UnitExists(targetUnit) then
        local targetName = UnitName(targetUnit)
        local hexColor = "ffffffff" -- Standard Weiß
        
        if UnitIsPlayer(targetUnit) then
            -- Wenn das Ziel ein Spieler ist -> Klassenfarbe
            local _, classTag = UnitClass(targetUnit)
            local c = RAID_CLASS_COLORS[classTag]
            if c then
                hexColor = string.format("ff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
            end
        else
            -- Wenn das Ziel ein NPC ist -> Reaktionen auslesen (Feindlich/Neutral/Freundlich)
            local reaction = UnitReaction(targetUnit, "player")
            if reaction then
                if reaction < 4 then
                    hexColor = "ffff2222" -- Rot (Feindlich)
                elseif reaction == 4 then
                    hexColor = "ffffff22" -- Gelb (Neutral)
                else
                    hexColor = "ff22ff22" -- Grün (Freundlich)
                end
            end
        end
        
        if targetName then
            tooltip:AddLine(" ")
            tooltip:AddLine((L.TOOLTIP_TARGET or "Ziel:") .. " |c" .. hexColor .. targetName .. "|r")
            tooltip:AddLine(" ")
        end
    end
end)