local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. TOOLTIP MODIFICATIONS (Class Colors, Roles, Target)
---------------------------------------------------------
-- Fallback for Blizzard's secret value API changes
local issecret = issecretvalue or function() return false end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
    local _, unit = tooltip:GetUnit()
    
    -- Exit if there is no unit or if it is protected by Blizzard's anti-taint system
    if not unit or issecret(unit) then return end

    if UnitIsPlayer(unit) then
        -- 1a. Class Color for Player Names
        local _, classTag = UnitClass(unit)
        local color = RAID_CLASS_COLORS[classTag]
        
        if color then
            local tooltipName = tooltip:GetName()
            local nameLine = _G[tooltipName .. "TextLeft1"]
            if nameLine then
                nameLine:SetTextColor(color.r, color.g, color.b)
            end
        end
        
        -- 1b. Role Detection (Works for party and raid members)
        local role = UnitGroupRolesAssigned(unit)
        if role and role ~= "NONE" then
            local roleText = ""
            local r, g, b = 1, 1, 1
            
            if role == "TANK" then
                roleText = L.ROLE_TANK or "Role: Tank"
                r, g, b = 0.4, 0.6, 1 -- Light Blue
            elseif role == "HEALER" then
                roleText = L.ROLE_HEALER or "Role: Healer"
                r, g, b = 0.4, 1, 0.4 -- Light Green
            elseif role == "DAMAGER" then
                roleText = L.ROLE_DAMAGER or "Role: DPS"
                r, g, b = 1, 0.4, 0.4 -- Light Red
            end
            
            tooltip:AddLine(roleText, r, g, b)
        end
    end

    -- 2. Target of Target (ToT)
    local targetUnit = unit .. "target"
    
    -- Check if the target unit exists and is not protected
    if not issecret(targetUnit) and UnitExists(targetUnit) then
        local targetName = UnitName(targetUnit)
        local hexColor = "ffffffff" -- Default White
        
        if UnitIsPlayer(targetUnit) then
            -- If target is a player -> Use Class Color
            local _, classTag = UnitClass(targetUnit)
            local c = RAID_CLASS_COLORS[classTag]
            if c then
                hexColor = string.format("ff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
            end
        else
            -- If target is an NPC -> Use Reaction Color (Hostile/Neutral/Friendly)
            local reaction = UnitReaction(targetUnit, "player")
            if reaction then
                if reaction < 4 then
                    hexColor = "ffff2222" -- Red (Hostile)
                elseif reaction == 4 then
                    hexColor = "ffffff22" -- Yellow (Neutral)
                else
                    hexColor = "ff22ff22" -- Green (Friendly)
                end
            end
        end
        
        if targetName then
            -- Add an empty line for spacing, then the target info
            tooltip:AddLine(" ")
            tooltip:AddLine((L.TOOLTIP_TARGET or "Target:") .. " |c" .. hexColor .. targetName .. "|r")
        end
    end
end)