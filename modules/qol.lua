local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. HIDE TALKING HEAD (Taint-safe)
---------------------------------------------------------
local thFrame = CreateFrame("Frame")
thFrame:RegisterEvent("ADDON_LOADED")
thFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
thFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon ~= "Blizzard_TalkingHeadUI" then
        return
    end

    local function UpdateTalkingHead()
        if not TalkingHeadFrame then
            return
        end
        if N1mmelUIDB.hideTalkingHead then
            TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_REQUESTED")
            TalkingHeadFrame:Hide()
        else
            TalkingHeadFrame:RegisterEvent("TALKINGHEAD_REQUESTED")
        end
    end
    UpdateTalkingHead()
    ns.UpdateTalkingHead = UpdateTalkingHead
end)

---------------------------------------------------------
-- 2. AFK SCREENSAVER (with spinning camera)
---------------------------------------------------------
local issecret = issecretvalue or function()
    return false
end

local afkFrame = CreateFrame("Frame", "N1mmelUIAFKFrame", nil)
afkFrame:SetAllPoints()
afkFrame:SetFrameStrata("FULLSCREEN_DIALOG")
afkFrame:Hide()

local afkBg = afkFrame:CreateTexture(nil, "BACKGROUND")
afkBg:SetAllPoints()
afkBg:SetColorTexture(0, 0, 0, 0.7)

local afkText = afkFrame:CreateFontString(nil, "OVERLAY")
afkText:SetPoint("TOP", afkFrame, "TOP", 0, -200)
ns.SetUIFont(afkText, 50, "OUTLINE")
afkText:SetText("AFK")
afkText:SetTextColor(0.8, 0.8, 0.8)

local afkPlayerInfo = afkFrame:CreateFontString(nil, "OVERLAY")
afkPlayerInfo:SetPoint("CENTER", afkFrame, "CENTER", 0, 20)
ns.SetUIFont(afkPlayerInfo, 26, "OUTLINE")

local afkClock = afkFrame:CreateFontString(nil, "OVERLAY")
afkClock:SetPoint("TOP", afkPlayerInfo, "BOTTOM", 0, -15)
ns.SetUIFont(afkClock, 24, "OUTLINE")

local afkZone = afkFrame:CreateFontString(nil, "OVERLAY")
afkZone:SetPoint("TOP", afkClock, "BOTTOM", 0, -15)
ns.SetUIFont(afkZone, 18, "OUTLINE")
afkZone:SetTextColor(0.8, 0.8, 0.8)

afkFrame:SetScript("OnUpdate", function(self)
    local clockText = date("%H:%M:%S")
    if type(clockText) ~= "string" then
        clockText = ""
    end
    afkClock:SetText(clockText)
end)

local isAFK = false
local afkEventFrame = CreateFrame("Frame")
afkEventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
afkEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
afkEventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
afkEventFrame:RegisterEvent("LFG_PROPOSAL_SHOW")
afkEventFrame:RegisterEvent("READY_CHECK")
afkEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

local function UpdateAFKInfo()
    afkZone:SetText(GetMinimapZoneText())

    local _, classTag = UnitClass("player")
    local color = RAID_CLASS_COLORS[classTag] or {
        r = 1,
        g = 1,
        b = 1
    }
    local classHex = string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local playerName = UnitName("player")
    local specIndex = GetSpecialization()
    local specName = specIndex and select(2, GetSpecializationInfo(specIndex)) or ""
    local avgIlvl = string.format("%.2f", select(2, GetAverageItemLevel()))

    local infoString = "|c" .. classHex .. playerName
    if specName ~= "" then
        infoString = infoString .. " - " .. specName
    end
    infoString = infoString .. "|r |cFFFFFFFF(iLvl: " .. avgIlvl .. ")|r"

    afkPlayerInfo:SetText(infoString)
end

afkEventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
        return
    end
    if not N1mmelUIDB.afkScreen then
        return
    end

    if event == "PLAYER_LEAVING_WORLD" or event == "LFG_PROPOSAL_SHOW" or event == "READY_CHECK" or event ==
        "PLAYER_REGEN_DISABLED" then
        if isAFK then
            isAFK = false
            afkFrame:Hide()
            UIParent:Show()
            MoveViewRightStop()
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, function()
            if not N1mmelUIDB.afkScreen then
                return
            end
            local afkState = UnitIsAFK("player")
            if not issecret(afkState) and afkState then
                if not isAFK then
                    isAFK = true
                    UpdateAFKInfo()
                    afkFrame:Show()
                    UIParent:Hide()
                    MoveViewRightStart(0.03)
                end
            end
        end)
        return
    end

    local afkState = UnitIsAFK("player")
    if issecret(afkState) then
        return
    end

    if afkState then
        if not isAFK then
            isAFK = true
            UpdateAFKInfo()
            afkFrame:Show()
            UIParent:Hide()
            MoveViewRightStart(0.03)
        end
    else
        if isAFK then
            isAFK = false
            afkFrame:Hide()
            UIParent:Show()
            MoveViewRightStop()
        end
    end
end)

function ns.ToggleAFKScreen()
    if not N1mmelUIDB.afkScreen and isAFK then
        isAFK = false
        afkFrame:Hide()
        UIParent:Show()
        MoveViewRightStop()
    elseif N1mmelUIDB.afkScreen then
        local afkState = UnitIsAFK("player")
        if not issecret(afkState) and afkState then
            isAFK = true
            UpdateAFKInfo()
            afkFrame:Show()
            UIParent:Hide()
            MoveViewRightStart(0.03)
        end
    end
end

---------------------------------------------------------
-- 3. DURABILITY WARNING
---------------------------------------------------------
local hasWarnedDurability = false
local durabilityEventFrame = CreateFrame("Frame")

durabilityEventFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
durabilityEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

durabilityEventFrame:SetScript("OnEvent", function(self, event)
    local currentDurability = 0
    local maxDurability = 0

    for i = 1, 18 do
        local current, max = GetInventoryItemDurability(i)
        if current and max then
            currentDurability = currentDurability + current
            maxDurability = maxDurability + max
        end
    end

    if maxDurability > 0 then
        local durabilityPercent = math.floor((currentDurability / maxDurability) * 100)

        if durabilityPercent <= 30 then
            if not hasWarnedDurability then
                print("----------------------------------------------")
                print("|cFFFF0000[ n1mmelUI ]: " .. (L.DURABILITY_WARNING or "Haltbarkeit kritisch:") .. " " ..
                          durabilityPercent .. "%|r")
                print("----------------------------------------------")
                PlaySoundFile("Interface\\AddOns\\n1mmelUI\\media\\sounds\\Xylo.ogg", "Master")
                hasWarnedDurability = true
            end
        else
            hasWarnedDurability = false
        end
    end
end)

---------------------------------------------------------
-- 5. Debug & Testing
---------------------------------------------------------

