local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. GLOBAL VARIABLES & UTILITIES
---------------------------------------------------------
local _, classTag = UnitClass("player")
-- Store RGB values globally (ns.classColor.r, ns.classColor.g, ns.classColor.b)
ns.classColor = RAID_CLASS_COLORS[classTag] or { r = 1, g = 1, b = 1 }
-- Store the hex code for text formatting (e.g., "|c" .. ns.classHex .. "Text|r")
ns.classHex = string.format("ff%02x%02x%02x", ns.classColor.r * 255, ns.classColor.g * 255, ns.classColor.b * 255)

---------------------------------------------------------
-- 2. DATABASE INITIALIZATION
---------------------------------------------------------
-- Creates the database on first load or adds missing keys after an update
function ns.InitDB()
    -- Create default DB if it doesn't exist
    if N1mmelUIDB == nil then
        N1mmelUIDB = {
            minimapZoom = 0,
            showLoadMessage = true,
            coordPos = "BOTTOMLEFT",
            showMapCoords = true,
            showMinimapCoords = true,
            squareMinimap = false,
            ilvlChar = true,
            ilvlBags = true,
            ilvlColorMode = "QUALITY",
            globalFont = "STANDARD",
            autoRepair = false,
            autoSell = false,
            checkOutput = "CHAT",
            targetClassColor = false,
            skipCinematics = false,
            hideTalkingHead = false,
            afkScreen = true,
            ilvlCharSize = 13,
            ilvlBagsSize = 13,
            whisperAlert = false,
            whisperSound = "Bell",
            shortChannels = true,
            chatClassColors = true,
            chatURLs = true,
            showCrestFrame = false,
            crestFramePos = {"CENTER", nil, "CENTER", 0, 0},
            crestFontSize = 11,
            infoWindow = false
        }
    end

    -- Maintenance check for existing DBs (Fallback for old users)
    N1mmelUIDB.minimapIcon = N1mmelUIDB.minimapIcon or { hide = false }
    if N1mmelUIDB.crestFontSize == nil then N1mmelUIDB.crestFontSize = 11 end
    if N1mmelUIDB.showCrestFrame == nil then N1mmelUIDB.showCrestFrame = false end
    if N1mmelUIDB.crestFramePos == nil then N1mmelUIDB.crestFramePos = {"CENTER", nil, "CENTER", 0, 0} end
    if N1mmelUIDB.minimapZoom == nil then N1mmelUIDB.minimapZoom = 0 end
    if N1mmelUIDB.showMapCoords == nil then N1mmelUIDB.showMapCoords = true end
    if N1mmelUIDB.ilvlChar == nil then N1mmelUIDB.ilvlChar = true end
    if N1mmelUIDB.ilvlBags == nil then N1mmelUIDB.ilvlBags = true end
    if N1mmelUIDB.squareMinimap == nil then N1mmelUIDB.squareMinimap = false end
    if N1mmelUIDB.targetClassColor == nil then N1mmelUIDB.targetClassColor = false end
    if N1mmelUIDB.skipCinematics == nil then N1mmelUIDB.skipCinematics = false end
    if N1mmelUIDB.hideTalkingHead == nil then N1mmelUIDB.hideTalkingHead = false end
    if N1mmelUIDB.afkScreen == nil then N1mmelUIDB.afkScreen = false end
    if N1mmelUIDB.ilvlCharSize == nil then N1mmelUIDB.ilvlCharSize = 13 end
    if N1mmelUIDB.ilvlBagsSize == nil then N1mmelUIDB.ilvlBagsSize = 13 end
    if N1mmelUIDB.whisperAlert == nil then N1mmelUIDB.whisperAlert = false end
    if N1mmelUIDB.whisperSound == nil then N1mmelUIDB.whisperSound = "Bell" end
    if N1mmelUIDB.shortChannels == nil then N1mmelUIDB.shortChannels = true end
    if N1mmelUIDB.chatClassColors == nil then N1mmelUIDB.chatClassColors = true end
    if N1mmelUIDB.chatURLs == nil then N1mmelUIDB.chatURLs = true end
    if N1mmelUIDB.unitFrameFonts == nil then N1mmelUIDB.unitFrameFonts = true end
    if N1mmelUIDB.unitFrameFontSize == nil then N1mmelUIDB.unitFrameFontSize = 13 end
    if N1mmelUIDB.debugMode == nil then N1mmelUIDB.debugMode = false end
    if N1mmelUIDB.infoWindow == nil then N1mmelUIDB.infoWindow = false end
end

---------------------------------------------------------
-- 3. MINIMAP BUTTON (LibDataBroker)
---------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
    type = "launcher",
    text = "n1mmelUI",
    icon = "Interface\\AddOns\\n1mmelUI\\media\\images\\icon.png",

    -- Handle Clicks (Open GUI on left click)
    OnClick = function(self, button)
        if button == "LeftButton" then
            ns.ToggleGUI()
        end
    end,

    -- Build the Tooltip when hovering over the minimap icon
    OnTooltipShow = function(tooltip)
        -- Title in Class Color (Using the global utility from section 1)
        tooltip:AddLine("n1mmelUI", ns.classColor.r, ns.classColor.g, ns.classColor.b)
        tooltip:AddLine(" ", 1, 1, 1)
        tooltip:AddLine(L.LEFTCLICK_MINIMAP)

        -- Calculate overall durability
        local currentDurability, maxDurability = 0, 0

        -- Iterate through all 18 possible equipment slots
        for i = 1, 18 do
            local current, max = GetInventoryItemDurability(i)
            if current and max then
                currentDurability = currentDurability + current
                maxDurability = maxDurability + max
            end
        end

        -- Calculate percentage and determine color (Green, Yellow, Red)
        if maxDurability > 0 then
            local durabilityPercent = math.floor((currentDurability / maxDurability) * 100)

            local r, g, b = 0, 1, 0 -- Default: Green
            if durabilityPercent < 30 then
                r, g, b = 1, 0, 0 -- Red (Critical)
            elseif durabilityPercent < 70 then
                r, g, b = 1, 1, 0 -- Yellow (Warning)
            end

            tooltip:AddLine(" ") -- Empty line for spacing
            tooltip:AddDoubleLine(L.DURABILITY or "Durability:", durabilityPercent .. "%", 1, 1, 1, r, g, b)
        end
    end
})
local icon = LibStub("LibDBIcon-1.0")

---------------------------------------------------------
-- 4. LFG INVITE TRACKER (Mythic+ Info)
---------------------------------------------------------
local lfgFrame = CreateFrame("Frame")
lfgFrame:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED")

-- A tiny, invisible cache for pending invites
local pendingInvites = {}

lfgFrame:SetScript("OnEvent", function(self, event, searchResultID, newStatus, oldStatus)

    if newStatus == "invited" then
        -- Step 1: Invite received! Silently store the data.
        local searchInfo = C_LFGList.GetSearchResultInfo(searchResultID)

        -- Check for activityIDs (newer API structure)
        if searchInfo and searchInfo.activityIDs and searchInfo.activityIDs[1] then
            local activityID = searchInfo.activityIDs[1]
            local activityInfo = C_LFGList.GetActivityInfoTable(activityID)

            if activityInfo then
                pendingInvites[searchResultID] = {
                    dungeon = activityInfo.fullName or "Unknown Instance",
                    leader = searchInfo.leaderName or "Unknown",
                    title = searchInfo.name or ""
                }
            end
        end

    elseif newStatus == "inviteaccepted" then
        -- Step 2: You clicked "Accept"!
        local data = pendingInvites[searchResultID]
        if data then
            print(" ")
            -- Title line with localization and class color
            print("|c" .. ns.classHex .. L.LFG_HEADER .. "|r")

            -- The three info lines with icons (12x12, no offset)
            print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\leader.png:12:12:0:0|t " .. L.LEADER .. " |cffffd100" .. data.leader .. "|r")
            print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\dungeon.png:12:12:0:0|t " .. L.INSTANCE .. " |cff00ff00" .. data.dungeon .. "|r")

            if data.title ~= "" then
                print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\title.png:12:12:0:0|t " .. L.TITLE .. " |cffffffff" .. data.title .. "|r")
            end
            print(" ")
        end
        -- Clear memory for this ID
        pendingInvites[searchResultID] = nil

    elseif newStatus == "invitedeclined" or newStatus == "timedout" or newStatus == "declined" then
        -- Step 3: Clean up memory on decline or timeout
        pendingInvites[searchResultID] = nil
    end
end)

---------------------------------------------------------
-- 5. GLOBAL SLASH COMMANDS
---------------------------------------------------------
-- Quick reload command (/rl)
SLASH_N1MMELRELOAD1 = "/rl"
SlashCmdList["N1MMELRELOAD"] = function()
    ReloadUI()
end

-- Test command for the invite layout (/n1invite)
SLASH_N1MMELINVITE1 = "/n1invite"
SlashCmdList["N1MMELINVITE"] = function()
    -- Fake data for testing
    local testLeader = "TestLeiter-Blackrock"
    local testDungeon = "Die Nekrotische Schneise"
    local testTitle = "+10 Big Pumper WM OFF"

    print(" ")
    -- Title line with localization and class color
    print("|c" .. ns.classHex .. L.LFG_HEADER .. "|r")

    -- The three info lines with icons (12x12, no offset)
    print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\leader.png:12:12:0:0|t " .. L.LEADER .. " |cffffd100" .. testLeader .. "|r")
    print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\dungeon.png:12:12:0:0|t " .. L.INSTANCE .. " |cff00ff00" .. testDungeon .. "|r")
    print("  |TInterface\\AddOns\\n1mmelUI\\media\\images\\title.png:12:12:0:0|t " .. L.TITLE .. " |cffffffff" .. testTitle .. "|r")
    print(" ")
end

-- Slash command to toggle the info window (/n1info)
SLASH_N1MMELINFO1 = "/n1info"
SlashCmdList["N1MMELINFO"] = function()
    if ns.infoWindow then
        -- 1. Invert the saved value (Toggle)
        N1mmelUIDB.infoWindow = not N1mmelUIDB.infoWindow

        -- 2. Adjust the window according to the new value
        if N1mmelUIDB.infoWindow then
            ns.infoWindow:Show()
            print("|c" .. ns.classHex .. "n1mmelUI:|r Info-Fenster |cff00ff00Aktiviert|r")
        else
            ns.infoWindow:Hide()
            print("|c" .. ns.classHex .. "n1mmelUI:|r Info-Fenster |cffff0000Deaktiviert|r")
        end
    end
end

---------------------------------------------------------
-- 6. BOOT SEQUENCE (Addon Loaded & Player Login)
---------------------------------------------------------
-- This is the main engine starting all modules
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN") -- Waits until the character has loaded!

eventFrame:SetScript("OnEvent", function(self, event, arg1)

    -- PHASE 1: Load database
    if event == "ADDON_LOADED" and arg1 == addonName then
        ns.InitDB()

        -- Register Minimap Icon
        icon:Register(addonName, LDB, N1mmelUIDB.minimapIcon)
        if N1mmelUIDB.minimapIcon.hide then
            icon:Hide(addonName)
        end

    -- PHASE 2: Build UI (Player is now 100% loaded)
    elseif event == "PLAYER_LOGIN" then

        -- Trigger Chat Module Functions
        if ns.UpdateChatClassColors then ns.UpdateChatClassColors() end
        if ns.SetupChatModifications then ns.SetupChatModifications() end

        -- Print Welcome Message safely
        local coloredName = "|c" .. ns.classHex .. "n1mmelUI|r"
        if N1mmelUIDB.showLoadMessage then
            print(string.format(ns.L.LOAD_MSG, coloredName))
        end

        -- Build Options GUI
        if ns.BuildStandaloneGUI then ns.BuildStandaloneGUI() end

        -- Trigger Map & Minimap Module Functions
        if ns.UpdateCoordPosition then ns.UpdateCoordPosition() end
        if ns.UpdateMapCoordsVisibility then ns.UpdateMapCoordsVisibility() end
        if ns.UpdateMinimapStyle then ns.UpdateMinimapStyle() end

        if ns.mmCoordsFrame then
            if N1mmelUIDB.showMinimapCoords then
                ns.mmCoordsFrame:Show()
            else
                ns.mmCoordsFrame:Hide()
            end
        end

        -- Apply Global Fonts
        if ns.UpdateAllFonts then ns.UpdateAllFonts() end
    end
    
    -- Apply Unit Frame Fonts & Colors
    if ns.UpdateUnitFrameFonts then ns.UpdateUnitFrameFonts() end
    if ns.ForceTargetColorUpdate then ns.ForceTargetColorUpdate() end

    -- Check Info Window status
    if ns.infoWindow then
        if N1mmelUIDB.infoWindow then
            ns.infoWindow:Show()
        else
            ns.infoWindow:Hide()
        end
    end
end)