local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- RUN REPORT
-- End-of-run summary: name, iLvl, M+ score, loot.
-- Persistent history (max 20 runs) in N1mmelUIDB.
--
-- Debug mode: /n1mpdebug  (toggle on/off)
-- Logs all events, loot captures and data reads to chat.
---------------------------------------------------------

local issecret = issecretvalue or function() return false end
local MAX_RUNS = 20

-- iLvl/spec cache filled by INSPECT_READY during the run
-- Key: fullKey (see GetFullKey below), Value: ilvl/specName
local ilvlCache  = {}
local specCache  = {}
local scoreBefore = {}  -- [fullKey] = score before the run, for delta calculation

-- Debug helper – logs to chat AND to N1mmelCharDB.debugLog (max 200 lines)
local debugMode = false
local function DBG(...)
    if not debugMode then return end
    local parts = { date("%H:%M:%S") }
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    local line = table.concat(parts, " ")
    print("|cff00ccff[n1mUI-Debug]|r " .. line)
    if N1mmelUIDB then
        if not N1mmelCharDB.debugLog then N1mmelCharDB.debugLog = {} end
        table.insert(N1mmelCharDB.debugLog, 1, line)
        while #N1mmelCharDB.debugLog > 200 do table.remove(N1mmelCharDB.debugLog) end
    end
end

---------------------------------------------------------
-- NAME HELPERS
-- Single source of truth: always use "Name-Realm" as key.
-- UnitFullName guarantees realm is always present.
-- For display we use just the short name without realm.
---------------------------------------------------------
local function GetFullKey(unitToken)
    -- UnitFullName always returns realm, even for same-realm players
    local name, realm = UnitFullName(unitToken)
    if not name then return nil end
    if not realm or realm == "" then
        realm = GetRealmName() or ""
    end
    -- Remove spaces and hyphens from realm (same as Details)
    realm = realm:gsub("[%s%-]", "")
    return name .. "-" .. realm
end

local function GetDisplayName(unitToken)
    return UnitName(unitToken)
end

-- Convert an event unitName (e.g. "Reaxwarr-Silvermoon") to full key format
local function EventNameToKey(unitName)
    if not unitName then return nil end
    -- If already has realm
    if unitName:find("-") then
        local name, realm = unitName:match("^([^%-]+)-(.+)$")
        if name and realm then
            realm = realm:gsub("[%s%-]", "")
            return name .. "-" .. realm
        end
    end
    -- No realm in name - append own realm
    local realm = GetRealmName() or ""
    realm = realm:gsub("[%s%-]", "")
    return unitName .. "-" .. realm
end

-- Runtime state
local lootTable = {}  -- [fullKey] = { itemLink, ... }
local runInfo   = nil

---------------------------------------------------------
-- HISTORY HELPERS
---------------------------------------------------------
local function GetHistory()
    if not N1mmelCharDB then return {} end
    if not N1mmelCharDB.runHistory then N1mmelCharDB.runHistory = {} end
    return N1mmelCharDB.runHistory
end

local function SaveRun(info, loot)
    if not N1mmelCharDB then return end
    local history = GetHistory()

    local entry = {
        time    = time(),
        dungeon = info.dungeonName or "",
        level   = info.level or 0,
        runTime = info.time or 0,
        onTime  = info.onTime or false,
        upgrade = info.upgrade or 0,
        members = {},
    }

    local partyTokens = { "player","party1","party2","party3","party4" }
    for _, token in ipairs(partyTokens) do
        if UnitExists(token) then
            local fullKey    = GetFullKey(token)
            local displayName = GetDisplayName(token)
            if fullKey and displayName and not issecret(displayName) then
                local ilvl, score, classTag, specName = 0, 0, nil, nil

                if token == "player" then
                    ilvl = math.floor(select(2, GetAverageItemLevel()) or 0)
                    local specIdx = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization
                        and C_SpecializationInfo.GetSpecialization() or GetSpecialization()
                    if specIdx then specName = select(2,
                        (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo
                        or GetSpecializationInfo)(specIdx)) end
                else
                    ilvl     = ilvlCache[fullKey] or 0
                    specName = specCache[fullKey] or nil
                    -- Fallback: live GetInspectItemLevel
                    if ilvl == 0 and C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
                        local v = C_PaperDollInfo.GetInspectItemLevel(token)
                        if v and not issecret(v) and v > 0 then ilvl = math.floor(v) end
                    end
                end

                local _, ct = UnitClass(token)
                classTag = ct

                if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
                    local sum = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(token)
                    if sum and not issecret(sum) then
                        local s = sum.currentSeasonScore
                        if s and not issecret(s) then score = math.floor(s) end
                    end
                end

                table.insert(entry.members, {
                    name     = displayName,
                    fullKey  = fullKey,
                    ilvl     = ilvl,
                    score    = score,
                    classTag = classTag,
                    spec     = specName,
                    loot     = loot[fullKey] or {},
                })
            end
        end
    end

    table.insert(history, 1, entry)
    while #history > MAX_RUNS do table.remove(history) end
end

local function ClearHistory()
    if N1mmelCharDB then N1mmelCharDB.runHistory = {} end
end

local function FormatTime(ms)
    local s = math.floor((ms or 0) / 1000)
    return string.format("%d:%02d", math.floor(s/60), s%60)
end

local function FormatDate(t)
    return date("%d.%m.%y %H:%M", t)
end

---------------------------------------------------------
-- FRAME
---------------------------------------------------------
local reportFrame = CreateFrame("Frame","N1mmelRunReport",UIParent,"BackdropTemplate")
reportFrame:SetSize(540, 360)
reportFrame:SetPoint("CENTER")
reportFrame:SetFrameStrata("DIALOG")
reportFrame:SetFrameLevel(60)
reportFrame:SetScript("OnShow", function(self) self:Raise() end)
reportFrame:SetMovable(true)
reportFrame:EnableMouse(true)
reportFrame:RegisterForDrag("LeftButton")
reportFrame:SetScript("OnDragStart", reportFrame.StartMoving)
reportFrame:SetScript("OnDragStop",  reportFrame.StopMovingOrSizing)
reportFrame:SetClampedToScreen(true)
reportFrame:SetBackdrop({
    bgFile  = "Interface\\Buttons\\WHITE8X8",
    edgeFile= "Interface\\Buttons\\WHITE8X8",
    edgeSize= 1,
    insets  = {left=1,right=1,top=1,bottom=1},
})
reportFrame:SetBackdropColor(0.05,0.05,0.08,0.97)
reportFrame:SetBackdropBorderColor(0.3,0.3,0.4,1)
reportFrame:Hide()
tinsert(UISpecialFrames,"N1mmelRunReport")

-- Title bar
local titleBar = reportFrame:CreateTexture(nil,"BACKGROUND")
titleBar:SetHeight(30)
titleBar:SetPoint("TOPLEFT"); titleBar:SetPoint("TOPRIGHT")
titleBar:SetColorTexture(0.08,0.08,0.14,1)

-- Close button
local closeBtn = CreateFrame("Button",nil,reportFrame,"UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT",-2,-2)
closeBtn:SetScript("OnClick", function() reportFrame:Hide() end)

-- Title text (dungeon + key level)
local titleText = reportFrame:CreateFontString(nil,"OVERLAY")
titleText:SetPoint("TOP",reportFrame,"TOP",0,-8)
if ns.SetUIFont then ns.SetUIFont(titleText,14,"OUTLINE") end

-- Sub line: time – 6px more spacing below title
local dungeonLine = reportFrame:CreateFontString(nil,"OVERLAY")
dungeonLine:SetPoint("TOP",reportFrame,"TOP",0,-37)
if ns.SetUIFont then ns.SetUIFont(dungeonLine,11) end
dungeonLine:SetTextColor(0.7,0.7,0.7)

---------------------------------------------------------
-- HISTORY DROPDOWN + CLEAR BUTTON (top-left)
---------------------------------------------------------
local historyLabel = reportFrame:CreateFontString(nil,"OVERLAY")
historyLabel:SetPoint("BOTTOMLEFT",reportFrame,"BOTTOMLEFT",12,12)
if ns.SetUIFont then ns.SetUIFont(historyLabel,10) end
historyLabel:SetTextColor(0.5,0.5,0.5)
historyLabel:SetText("History:")

local historyDrop = CreateFrame("DropdownButton","N1mmelRunReportDrop",
    reportFrame,"WowStyle1DropdownTemplate")
historyDrop:SetPoint("LEFT",historyLabel,"RIGHT",4,0)
historyDrop:SetWidth(240)

local clearBtn = CreateFrame("Button",nil,reportFrame,"UIPanelButtonTemplate")
clearBtn:SetSize(60,20)
clearBtn:SetPoint("LEFT",historyDrop,"RIGHT",6,0)
clearBtn:SetText("Clear")

local currentEntry = nil
local function PopulateReport(entry) end

local function RefreshDropdown()
    local history = GetHistory()
    historyDrop:SetupMenu(function(dropdown, rootDescription)
        if #history == 0 then
            rootDescription:CreateTitle("No runs yet")
            return
        end
        for i, entry in ipairs(history) do
            local label = string.format("[%s] %s +%d",
                FormatDate(entry.time),
                entry.dungeon ~= "" and entry.dungeon or "Unknown",
                entry.level)
            local captured_entry = entry
            rootDescription:CreateRadio(label,
                function() return currentEntry == captured_entry end,
                function()
                    currentEntry = captured_entry
                    PopulateReport(captured_entry)
                end
            )
        end
    end)
end

StaticPopupDialogs["N1MMEL_CLEAR_RUN_HISTORY"] = {
    text           = "Delete all saved run history?\nThis cannot be undone.",
    button1        = "Yes",
    button2        = "No",
    OnAccept       = function()
        ClearHistory()
        currentEntry = nil
        RefreshDropdown()
        titleText:SetText("|cffaaaaaa(No runs yet)|r")
        dungeonLine:SetText("")
        if reportFrame.ClearRows then reportFrame.ClearRows() end
    end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
}

clearBtn:SetScript("OnClick", function()
    StaticPopup_Show("N1MMEL_CLEAR_RUN_HISTORY")
end)

local bottomDiv = reportFrame:CreateTexture(nil,"ARTWORK")
bottomDiv:SetHeight(1)
bottomDiv:SetPoint("BOTTOMLEFT",reportFrame,"BOTTOMLEFT",10,36)
bottomDiv:SetPoint("BOTTOMRIGHT",reportFrame,"BOTTOMRIGHT",-10,36)
bottomDiv:SetColorTexture(0.3,0.3,0.4,0.6)

local divider = reportFrame:CreateTexture(nil,"ARTWORK")
divider:SetHeight(1)
divider:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",10,-56)
divider:SetPoint("TOPRIGHT",reportFrame,"TOPRIGHT",-10,-56)
divider:SetColorTexture(0.3,0.3,0.4,0.8)

local headerDefs = {
    {text="Player",   x=15  },
    {text="iLvl",     x=200 },
    {text="M+ Score", x=260 },
    {text="Loot",     x=437 },
}
for _, h in ipairs(headerDefs) do
    local hf = reportFrame:CreateFontString(nil,"OVERLAY")
    hf:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",h.x,-62)
    if ns.SetUIFont then ns.SetUIFont(hf,10) end
    hf:SetTextColor(0.5,0.8,1)
    hf:SetText(h.text)
end

local headerDiv = reportFrame:CreateTexture(nil,"ARTWORK")
headerDiv:SetHeight(1)
headerDiv:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",10,-76)
headerDiv:SetPoint("TOPRIGHT",reportFrame,"TOPRIGHT",-10,-76)
headerDiv:SetColorTexture(0.3,0.3,0.4,0.5)

---------------------------------------------------------
-- ROW POOL
---------------------------------------------------------
local rows = {}
for i = 1, 5 do
    local rowY = -90 - (i-1)*48
    local r = {}

    r.icon = reportFrame:CreateTexture(nil,"ARTWORK")
    r.icon:SetSize(28,28)
    r.icon:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",12,rowY+1)
    r.icon:SetTexCoord(0.07,0.93,0.07,0.93)

    r.name = reportFrame:CreateFontString(nil,"OVERLAY")
    r.name:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",45,rowY)
    if ns.SetUIFont then ns.SetUIFont(r.name,12,"OUTLINE") end

    r.spec = reportFrame:CreateFontString(nil,"OVERLAY")
    r.spec:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",45,rowY-16)
    if ns.SetUIFont then ns.SetUIFont(r.spec,9) end
    r.spec:SetTextColor(0.6,0.6,0.6)

    r.ilvl = reportFrame:CreateFontString(nil,"OVERLAY")
    r.ilvl:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",200,rowY-6)
    if ns.SetUIFont then ns.SetUIFont(r.ilvl,13,"OUTLINE") end
    r.ilvl:SetTextColor(1,0.82,0)

    r.score = reportFrame:CreateFontString(nil,"OVERLAY")
    r.score:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",260,rowY-6)
    if ns.SetUIFont then ns.SetUIFont(r.score,13,"OUTLINE") end

    r.loot = reportFrame:CreateFontString(nil,"OVERLAY")
    r.loot:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",370,rowY-2)
    r.loot:SetWidth(155)
    if ns.SetUIFont then ns.SetUIFont(r.loot,10) end

    r.lootFrame = CreateFrame("Frame",nil,reportFrame)
    r.lootFrame:SetSize(155,44)
    r.lootFrame:SetPoint("TOPLEFT",reportFrame,"TOPLEFT",370,rowY)

    rows[i] = r
end

local CLASS_ICONS = {
    WARRIOR="WARRIOR",PALADIN="PALADIN",HUNTER="HUNTER",ROGUE="ROGUE",
    PRIEST="PRIEST",DEATHKNIGHT="DEATHKNIGHT",SHAMAN="SHAMAN",MAGE="MAGE",
    WARLOCK="WARLOCK",MONK="MONK",DRUID="DRUID",DEMONHUNTER="DEMONHUNTER",
    EVOKER="EVOKER",
}

local function ClearRows()
    for i = 1,5 do
        local r = rows[i]
        r.icon:Hide()
        r.name:SetText("")
        r.spec:SetText("")
        r.ilvl:SetText("")
        r.score:SetText("")
        r.loot:SetText("")
        r.lootFrame:SetScript("OnEnter",nil)
        r.lootFrame:SetScript("OnLeave",nil)
    end
end
reportFrame.ClearRows = ClearRows

---------------------------------------------------------
-- POPULATE from a history entry
---------------------------------------------------------
PopulateReport = function(entry)
    ClearRows()
    if not entry then return end

    local dungName = entry.dungeon ~= "" and entry.dungeon or "Unknown"
    local upgradeStr = ""
    if entry.upgrade and entry.upgrade > 0 then
        local stars = string.rep("+", entry.upgrade)
        upgradeStr = " |cff00ff00(" .. stars .. ")|r"
    elseif entry.onTime == false then
        upgradeStr = " |cffff4444(depleted)|r"
    end
    titleText:SetText("|cff00ccff" .. dungName .. "|r  +" .. entry.level .. upgradeStr)

    local timeStr = FormatTime(entry.runTime)
    local col = entry.onTime and "|cff44ff44" or "|cffff4444"
    local label = entry.onTime and " (In time)" or " (Depleted)"
    dungeonLine:SetText("Time: " .. col .. timeStr .. label .. "|r"
        .. "  |cffaaaaaa" .. FormatDate(entry.time) .. "|r")

    for i, m in ipairs(entry.members) do
        if i > 5 then break end
        local r = rows[i]

        r.name:SetText(m.name)
        if m.classTag and RAID_CLASS_COLORS[m.classTag] then
            local c = RAID_CLASS_COLORS[m.classTag]
            r.name:SetTextColor(c.r,c.g,c.b)
            local tag = CLASS_ICONS[m.classTag]
            if tag then
                r.icon:SetTexture("Interface\\Icons\\ClassIcon_"..tag)
                r.icon:Show()
            end
        else
            r.name:SetTextColor(1,1,1)
        end

        r.spec:SetText(m.spec or "")
        r.ilvl:SetText(m.ilvl and m.ilvl > 0 and m.ilvl or "?")

        if m.score and m.score > 0 then
            local rc = C_ChallengeMode and C_ChallengeMode.GetDungeonScoreRarityColor
                and C_ChallengeMode.GetDungeonScoreRarityColor(m.score)
            if rc and not issecret(rc) then
                r.score:SetTextColor(rc.r,rc.g,rc.b)
            else
                r.score:SetTextColor(0.67,0.2,0.93)
            end
            local scoreText = tostring(m.score)
            if m.delta and m.delta > 0 then
                scoreText = scoreText .. " |cff00ff00(+" .. m.delta .. ")|r"
            end
            r.score:SetText(scoreText)
        else
            r.score:SetTextColor(0.4,0.4,0.4)
            r.score:SetText("-")
        end

        local pl = m.loot
        if pl and #pl > 0 then
            local firstLink = pl[1]
            local itemID = firstLink:match("item:(%d+)")
            local iconStr = ""
            if itemID then
                local icon = C_Item.GetItemIconByID(tonumber(itemID))
                if icon then
                    iconStr = "|T" .. icon .. ":16:16:0:0|t "
                else
                    -- Item not cached yet – request it and refresh shortly
                    C_Item.RequestLoadItemDataByID(tonumber(itemID))
                    C_Timer.After(1, function()
                        if reportFrame:IsShown() and currentEntry then
                            PopulateReport(currentEntry)
                        end
                    end)
                end
            end
            local display = iconStr .. firstLink
            if #pl > 1 then display = display .. " |cffaaaaaa(+" .. (#pl-1) .. ")|r" end
            r.loot:SetText(display)
            local lootCopy = pl
            r.lootFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:SetHyperlink(lootCopy[1])
                if #lootCopy > 1 then
                    GameTooltip:AddLine(" ")
                    for j = 2, #lootCopy do
                        GameTooltip:AddLine(lootCopy[j],1,1,1)
                    end
                end
                GameTooltip:Show()
            end)
            r.lootFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
        else
            r.loot:SetTextColor(0.4,0.4,0.4)
            r.loot:SetText("No loot")
        end
    end
end

---------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------

-- Simulate Mythic+ events for testing without running a real key.
-- Usage via /n1mt start / end / loot
function ns.SimulateMythicEvent(eventType)
    if eventType == "START" then
        ilvlCache = {}
        lootTable = {}
        DBG("SIMULATE: CHALLENGE_MODE_START")

    elseif eventType == "COMPLETED" then
        lootTable = {}
        -- Build fake runInfo from current instance or dummy data
        runInfo = {
            dungeonName = GetRealZoneText() or "Test Dungeon",
            level       = 12,
            time        = 1320000, -- 22:00
            onTime      = true,
            members     = {},
        }
        DBG("SIMULATE: CHALLENGE_MODE_COMPLETED")
        -- Show window after 2s just like real event
        C_Timer.After(2, function()
            if not N1mmelUIDB then return end
            local liveEntry = {
                time    = time(),
                dungeon = runInfo.dungeonName,
                level   = runInfo.level,
                runTime = runInfo.time,
                onTime  = runInfo.onTime,
                members = {},
            }
            for _, token in ipairs({"player","party1","party2","party3","party4"}) do
                if UnitExists(token) then
                    local fullKey     = GetFullKey(token)
                    local displayName = GetDisplayName(token)
                    if fullKey and displayName and not issecret(displayName) then
                        local ilvl = 0
                        if token == "player" then
                            ilvl = math.floor(select(2, GetAverageItemLevel()) or 0)
                        else
                            ilvl = ilvlCache[fullKey] or 0
                        end
                        local _, ct = UnitClass(token)
                        local score = 0
                        if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
                            local sum = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(token)
                            if sum and not issecret(sum) then
                                local s = sum.currentSeasonScore
                                if s and not issecret(s) then score = math.floor(s) end
                            end
                        end
                        table.insert(liveEntry.members, {
                            name=displayName, fullKey=fullKey, ilvl=ilvl, score=score, classTag=ct, loot={}
                        })
                    end
                end
            end
            currentEntry = liveEntry
            PopulateReport(liveEntry)
            reportFrame:Show()
        end)

    elseif eventType == "LOOT" then
        local fakeLink = "|cffa335ee|Hitem:12345::::::::90:::::|h[Simulated Epic Item]|h|r"
        local fullKey = GetFullKey("player")
        if not fullKey then return end
        if not lootTable[fullKey] then lootTable[fullKey] = {} end
        table.insert(lootTable[fullKey], fakeLink)
        DBG("SIMULATE: LOOT for", fullKey)
        if reportFrame:IsShown() and currentEntry then
            for _, m in ipairs(currentEntry.members) do
                if m.fullKey == fullKey then
                    if not m.loot then m.loot = {} end
                    table.insert(m.loot, fakeLink)
                    PopulateReport(currentEntry)
                    break
                end
            end
        end
    end
end

function ns.ToggleRunReportDebug()
    debugMode = not debugMode
    if debugMode then
        print("|cff00ccff[n1mUI-Debug]|r Run Report debug |cff00ff00ENABLED|r")
        print("|cff00ccff[n1mUI-Debug]|r |cffaaaaaa/n1mpdebug|r        – toggle on/off")
        print("|cff00ccff[n1mUI-Debug]|r |cffaaaaaa/n1mplog|r           – print saved log to chat")
        print("|cff00ccff[n1mUI-Debug]|r |cffaaaaaa/n1mplog clear|r     – clear saved log")
    else
        print("|cff00ccff[n1mUI-Debug]|r Run Report debug |cffff0000DISABLED|r")
        print("|cff00ccff[n1mUI-Debug]|r Log is still saved – use |cffaaaaaa/n1mplog|r to read it.")
    end
end

-- Log viewer window (created once, reused)
local logWindow = nil
local function CreateLogWindow()
    if logWindow then return logWindow end

    local f = CreateFrame("Frame", "N1mmelLogWindow", UIParent, "BackdropTemplate")
    f:SetSize(600, 400)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(80)
    f:SetScript("OnShow", function(self) self:Raise() end)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
        insets   = {left=1,right=1,top=1,bottom=1},
    })
    f:SetBackdropColor(0.05,0.05,0.08,0.97)
    f:SetBackdropBorderColor(0.3,0.3,0.4,1)
    f:Hide()
    tinsert(UISpecialFrames, "N1mmelLogWindow")

    -- Title bar
    local titleBar = f:CreateTexture(nil,"BACKGROUND")
    titleBar:SetHeight(26)
    titleBar:SetPoint("TOPLEFT"); titleBar:SetPoint("TOPRIGHT")
    titleBar:SetColorTexture(0.08,0.08,0.14,1)

    local title = f:CreateFontString(nil,"OVERLAY")
    title:SetPoint("TOP",f,"TOP",0,-6)
    if ns.SetUIFont then ns.SetUIFont(title,12,"OUTLINE") end
    title:SetText("|cff00ccffn1mmelUI|r Debug Log  |cffaaaaaa– Ctrl+A to select all, Ctrl+C to copy|r")

    local closeBtn = CreateFrame("Button",nil,f,"UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT",-2,-2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Clear button
    local clearBtn = CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
    clearBtn:SetSize(80,20)
    clearBtn:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-8,8)
    clearBtn:SetText("Clear Log")
    clearBtn:SetScript("OnClick", function()
        if N1mmelCharDB then N1mmelCharDB.debugLog = {} end
        f.editBox:SetText("")
        print("|cff00ccff[n1mUI-Debug]|r Log cleared.")
    end)

    -- ScrollFrame
    local scroll = CreateFrame("ScrollFrame","N1mmelLogScroll",f,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",f,"TOPLEFT",8,-32)
    scroll:SetPoint("BOTTOMRIGHT",f,"BOTTOMRIGHT",-28,36)

    -- EditBox inside scroll (read-only style, but selectable/copyable)
    local eb = CreateFrame("EditBox",nil,scroll)
    eb:SetMultiLine(true)
    eb:SetMaxLetters(0)
    eb:SetWidth(scroll:GetWidth() - 4)
    eb:SetAutoFocus(false)
    eb:SetFontObject(GameFontNormalSmall)
    eb:SetTextColor(0.85,0.85,0.85)
    eb:SetScript("OnEscapePressed", function() f:Hide() end)
    -- Prevent editing while still allowing selection/copy
    eb:SetScript("OnChar", function(self) end)
    eb:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then f:Hide() end
    end)
    scroll:SetScrollChild(eb)
    f.editBox = eb

    logWindow = f
    return f
end

function ns.PrintRunReportLog(clear)
    if not N1mmelUIDB then
        print("|cffff9900n1mmelUI:|r DB not ready.")
        return
    end
    if clear then
        N1mmelCharDB.debugLog = {}
        if logWindow then logWindow.editBox:SetText("") end
        print("|cff00ccff[n1mUI-Debug]|r Log cleared.")
        return
    end
    local log = N1mmelCharDB.debugLog
    if not log or #log == 0 then
        print("|cff00ccff[n1mUI-Debug]|r Log is empty. Enable debug with /n1mpdebug and run a key.")
        return
    end

    local f = CreateLogWindow()
    -- Build text newest-first (already stored that way)
    local lines = {}
    for _, line in ipairs(log) do
        lines[#lines+1] = line
    end
    f.editBox:SetText(table.concat(lines, "\n"))
    -- Scroll to top
    f.editBox:SetCursorPosition(0)
    f:Show()
end

function ns.ShowRunReport(testMode)
    RefreshDropdown()

    if testMode then
        local fakeEntry = {
            time    = time(),
            dungeon = "Cinderbrew Meadery",
            level   = 12,
            runTime = 1918000,
            onTime  = true,
            upgrade = 2,
            members = {
                {name="Mattress",    ilvl=269, score=2747, classTag="MAGE",    spec="Frost",
                 loot={"|cffa335eeItem: Frostweave Gloves of the Invoker|r"}},
                {name="Gimlly",      ilvl=271, score=3399, classTag="WARRIOR", spec="Protection",
                 loot={"|cffff8000Legendary Axe of Doom|r","|cffa335eePurple Ring|r"}},
                {name="Badockledock",ilvl=270, score=3431, classTag="PALADIN", spec="Holy",   loot={}},
                {name="Moolinrouge", ilvl=268, score=3399, classTag="DRUID",   spec="Balance",
                 loot={"|cff0070ddBlue Boots of Speed|r"}},
                {name="Spectétör",  ilvl=272, score=3416, classTag="HUNTER",  spec="Beast Mastery", loot={}},
            },
        }
        currentEntry = fakeEntry
        PopulateReport(fakeEntry)
        reportFrame:Show()
        return
    end

    local history = GetHistory()

    -- If currentEntry is set and is the live run (not yet in history),
    -- show it directly without overwriting with history[1]
    if currentEntry and (not history[1] or history[1] ~= currentEntry) then
        PopulateReport(currentEntry)
        reportFrame:Show()
        return
    end

    if #history == 0 then
        print("|c" .. ns.classHex .. "n1mmelUI:|r " .. L.NO_RUN_DATA)
        return
    end

    currentEntry = history[1]
    PopulateReport(history[1])
    reportFrame:Show()
end

---------------------------------------------------------
-- EVENT HANDLING
---------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("CHALLENGE_MODE_START")
eventFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
eventFrame:RegisterEvent("INSPECT_READY")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "INSPECT_READY" then
        local guid = ...
        if not guid then return end

        -- Try all party tokens and cache whoever has fresh data using fullKey
        for _, token in ipairs({"party1","party2","party3","party4"}) do
            if UnitExists(token) then
                local fullKey = GetFullKey(token)
                if fullKey then
                    -- Cache iLvl
                    if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
                        local ilvl = C_PaperDollInfo.GetInspectItemLevel(token)
                        if ilvl and not issecret(ilvl) and ilvl > 0 then
                            if not ilvlCache[fullKey] or ilvlCache[fullKey] ~= math.floor(ilvl) then
                                ilvlCache[fullKey] = math.floor(ilvl)
                                DBG("INSPECT_READY: cached iLvl for", fullKey, "=", ilvlCache[fullKey])
                            end
                        end
                    end
                    -- Cache Spec
                    if GetInspectSpecialization then
                        local specID = GetInspectSpecialization(token)
                        if specID and specID > 0 then
                            local _, sName = GetSpecializationInfoByID(specID)
                            if sName and sName ~= specCache[fullKey] then
                                specCache[fullKey] = sName
                                DBG("INSPECT_READY: cached spec for", fullKey, "=", sName)
                            end
                        end
                    end
                end
            end
        end
        return
    end
    if event == "CHALLENGE_MODE_START" then
        DBG("CHALLENGE_MODE_START fired – scheduling inspects")
        ilvlCache   = {}
        specCache   = {}
        scoreBefore = {}

        -- Cache current M+ score for all party members before the run starts
        for _, token in ipairs({"player","party1","party2","party3","party4"}) do
            if UnitExists(token) then
                local fullKey = GetFullKey(token)
                if fullKey and C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
                    local sum = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(token)
                    if sum and not issecret(sum) then
                        local s = sum.currentSeasonScore
                        if s and not issecret(s) then
                            scoreBefore[fullKey] = math.floor(s)
                            DBG("Score before run for", fullKey, "=", scoreBefore[fullKey])
                        end
                    end
                end
            end
        end
        local delay = 5.0
        for _, token in ipairs({"party1","party2","party3","party4"}) do
            local exists = UnitExists(token)
            if exists and not issecret(exists) then
                local isPlayer = UnitIsPlayer(token)
                if isPlayer and not issecret(isPlayer) then
                    local captured = token
                    local name = UnitName(token) or token
                    DBG("Scheduling inspect for", name, "in", delay, "s")
                    C_Timer.After(delay, function()
                        local e = UnitExists(captured)
                        if e and not issecret(e) then
                            DBG("NotifyInspect ->", UnitName(captured) or captured)
                            NotifyInspect(captured)
                        end
                    end)
                    delay = delay + 1.5
                end
            end
        end

    elseif event == "CHALLENGE_MODE_COMPLETED" then
        DBG("CHALLENGE_MODE_COMPLETED – run ended, tracking loot")
        lootTable = {}
        -- ilvlCache intentionally NOT cleared here – it was filled at key start
        -- and contains fresh data for all members. No need to re-inspect.
        DBG("ilvlCache at run end:", (function()
            local s = ""
            for k,v in pairs(ilvlCache) do s = s .. k .. "=" .. v .. " " end
            return s == "" and "(empty)" or s
        end)())

        local ci = C_ChallengeMode and C_ChallengeMode.GetChallengeCompletionInfo
            and C_ChallengeMode.GetChallengeCompletionInfo()

        if ci then
            local name = C_ChallengeMode and C_ChallengeMode.GetMapUIInfo
                and (select(1, C_ChallengeMode.GetMapUIInfo(ci.mapChallengeModeID)))
            runInfo = {
                dungeonName   = name or "",
                level         = ci.level,
                time          = ci.time,
                onTime        = ci.onTime,
                upgrade       = ci.keystoneUpgradeLevels or 0,
            }
            DBG("Run completed: +", ci.level, "upgrade:", ci.keystoneUpgradeLevels or 0)
        else
            runInfo = nil
        end

        self:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
        self:RegisterEvent("CHAT_MSG_LOOT")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        -- Build window immediately – ilvlCache already has all data from key start
        -- Small delay just to let the completion screen settle
        C_Timer.After(1, function()
            if not runInfo then return end

            local liveEntry = {
                time    = time(),
                dungeon = runInfo.dungeonName or "",
                level   = runInfo.level or 0,
                runTime = runInfo.time or 0,
                onTime  = runInfo.onTime or false,
                upgrade = runInfo.upgrade or 0,
                members = {},
            }

            for _, token in ipairs({"player","party1","party2","party3","party4"}) do
                if UnitExists(token) then
                    local fullKey     = GetFullKey(token)
                    local displayName = GetDisplayName(token)
                    if fullKey and displayName and not issecret(displayName) then
                        local ilvl, score, ct, specName = 0, 0, nil, nil

                        if token == "player" then
                            ilvl = math.floor(select(2, GetAverageItemLevel()) or 0)
                            local si = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization
                                and C_SpecializationInfo.GetSpecialization() or GetSpecialization()
                            if si then specName = select(2,
                                (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo
                                or GetSpecializationInfo)(si)) end
                        else
                            ilvl     = ilvlCache[fullKey] or 0
                            specName = specCache[fullKey] or nil
                            if not specName and GetInspectSpecialization then
                                local specID = GetInspectSpecialization(token)
                                if specID and specID > 0 then
                                    local _, sn = GetSpecializationInfoByID(specID)
                                    if sn then specName = sn end
                                end
                            end
                        end

                        local _, classTag = UnitClass(token)
                        ct = classTag

                        if C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
                            local sum = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(token)
                            if sum and not issecret(sum) then
                                local s = sum.currentSeasonScore
                                if s and not issecret(s) then score = math.floor(s) end
                            end
                        end

                        local delta = nil
                        if score > 0 and scoreBefore[fullKey] and scoreBefore[fullKey] > 0 then
                            local d = score - scoreBefore[fullKey]
                            if d ~= 0 then delta = d end
                        end

                        DBG("Member:", displayName, "key:", fullKey, "iLvl:", ilvl, "Score:", score, "Delta:", tostring(delta))
                        table.insert(liveEntry.members, {
                            name     = displayName,
                            fullKey  = fullKey,
                            ilvl     = ilvl,
                            score    = score,
                            delta    = delta,
                            classTag = ct,
                            spec     = specName,
                            loot     = {},
                        })
                    end
                end
            end

            currentEntry = liveEntry
            PopulateReport(liveEntry)
            DBG("Live window built:", #liveEntry.members, "members")
            -- Show once here – PLAYER_ENTERING_WORLD will NOT show again if already visible
            if N1mmelUIDB and N1mmelUIDB.showRunReport then
                ns.ShowRunReport(false)
            end
        end)

    elseif event == "CHAT_MSG_LOOT" then
        local msg = ...
        if not msg then return end
        local playerName, itemLink = msg:match("^(.+) receives loot: (%[.+%])")
        if not playerName then
            if msg:match("^You receive loot:") then
                playerName = UnitName("player")
                itemLink   = msg:match("(%[.+%])")
            end
        end
        if not playerName or not itemLink then return end

        -- Filter warbound
        if C_Item and C_Item.IsItemBindToAccountUntilEquip then
            if C_Item.IsItemBindToAccountUntilEquip(itemLink) then return end
        end

        -- Filter non-gear – if itemType is nil (not cached yet), skip too
        -- ENCOUNTER_LOOT_RECEIVED is the primary source; CHAT_MSG_LOOT only
        -- catches items that ENCOUNTER_LOOT_RECEIVED missed (e.g. Need/Greed)
        local itemType = select(6, C_Item.GetItemInfoInstant(itemLink))
        if not itemType then
            DBG("LOOT (CHAT) skipped uncached item:", itemLink)
            return
        end
        if itemType ~= Enum.ItemClass.Weapon and itemType ~= Enum.ItemClass.Armor then
            DBG("LOOT (CHAT) skipped non-gear:", itemLink)
            return
        end

        local fullKey = EventNameToKey(playerName)
        if not fullKey then return end

        -- Skip if ENCOUNTER_LOOT_RECEIVED already added this item
        if lootTable[fullKey] then
            for _, ex in ipairs(lootTable[fullKey]) do
                if ex == itemLink then
                    DBG("LOOT (CHAT) skipped duplicate (already from ENCOUNTER):", itemLink)
                    return
                end
            end
        end

        DBG("LOOT (CHAT):", fullKey, "->", itemLink)
        if not lootTable[fullKey] then lootTable[fullKey] = {} end
        table.insert(lootTable[fullKey], itemLink)

        if currentEntry then
            for _, m in ipairs(currentEntry.members) do
                if m.fullKey == fullKey then
                    if not m.loot then m.loot = {} end
                    local lootFound = false
                    for _, l in ipairs(m.loot) do if l == itemLink then lootFound = true; break end end
                    if not lootFound then
                        table.insert(m.loot, itemLink)
                        if reportFrame:IsShown() then PopulateReport(currentEntry) end
                        DBG("Live update loot for", m.name)
                    end
                    break
                end
            end
        end

    elseif event == "ENCOUNTER_LOOT_RECEIVED" then
        local _, _, itemLink, _, unitName = ...
        if not itemLink or not unitName then return end

        -- Filter warbound
        if C_Item and C_Item.IsItemBindToAccountUntilEquip then
            if C_Item.IsItemBindToAccountUntilEquip(itemLink) then return end
        end

        -- Filter non-gear – reject uncached items too (nil = not cached)
        local itemType = select(6, C_Item.GetItemInfoInstant(itemLink))
        if not itemType then
            DBG("LOOT (ENCOUNTER) skipped uncached item:", itemLink)
            return
        end
        if itemType ~= Enum.ItemClass.Weapon and itemType ~= Enum.ItemClass.Armor then
            DBG("LOOT (ENCOUNTER) skipped non-gear:", itemLink)
            return
        end

        local fullKey = EventNameToKey(unitName)
        if not fullKey then return end
        DBG("LOOT (ENCOUNTER):", fullKey, "->", itemLink)

        if not lootTable[fullKey] then lootTable[fullKey] = {} end
        local found = false
        for _, ex in ipairs(lootTable[fullKey]) do if ex == itemLink then found = true; break end end
        if not found then
            table.insert(lootTable[fullKey], itemLink)
            -- Live update currentEntry
            if currentEntry then
                for _, m in ipairs(currentEntry.members) do
                    if m.fullKey == fullKey then
                        if not m.loot then m.loot = {} end
                        local lootFound = false
                        for _, l in ipairs(m.loot) do if l == itemLink then lootFound = true; break end end
                        if not lootFound then
                            table.insert(m.loot, itemLink)
                            if reportFrame:IsShown() then PopulateReport(currentEntry) end
                            DBG("Live update loot for", m.name)
                        end
                        break
                    end
                end
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local isLogin, isReload = ...
        if isLogin or isReload then return end
        DBG("Zone change – saving run to history")
        self:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED")
        self:UnregisterEvent("CHAT_MSG_LOOT")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")

        if currentEntry and runInfo then
            runInfo = nil

            -- Merge any loot that arrived after the live window was built
            -- Now simple and reliable: match by fullKey
            for _, m in ipairs(currentEntry.members) do
                local lootFound = m.fullKey and lootTable[m.fullKey]
                if lootFound and #lootFound > 0 then
                    if not m.loot then m.loot = {} end
                    for _, itemLink in ipairs(lootFound) do
                        local found = false
                        for _, existing in ipairs(m.loot) do
                            if existing == itemLink then found = true; break end
                        end
                        if not found then table.insert(m.loot, itemLink) end
                    end
                end
            end

            local savedEntry = currentEntry
            C_Timer.After(0.5, function()
                DBG("Saving to history:", savedEntry.dungeon, "+", savedEntry.level)
                local history = GetHistory()
                if history[1] == savedEntry then
                    DBG("Entry already in history, skipping duplicate")
                    RefreshDropdown()
                    return
                end
                table.insert(history, 1, savedEntry)
                while #history > MAX_RUNS do table.remove(history) end
                RefreshDropdown()
                if reportFrame:IsShown() then PopulateReport(savedEntry) end
                -- Only auto-show if not already visible
                if N1mmelUIDB and N1mmelUIDB.showRunReport and not reportFrame:IsShown() then
                    ns.ShowRunReport(false)
                end
            end)
        elseif runInfo then
            runInfo = nil
        end
    end
end)