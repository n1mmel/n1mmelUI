local addonName, ns = ...
local L = ns.L
local n1mmelGUI

---------------------------------------------------------
-- 1. FONT & SOUND PATHS
---------------------------------------------------------
local fontPaths = {
    ["STANDARD"] = STANDARD_TEXT_FONT,
    ["PTSANS"] = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\PTSansNarrow.ttf",
    ["EXPRESSWAY"] = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\Expressway.ttf"
}

-- Sounds from /media/sounds/ folder
local soundPaths = {
    ["Bell"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Bell.ogg",
    ["Chime"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Chime.ogg",
    ["Heart"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Heart.ogg",
    ["IM"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\IM.ogg",
    ["Info"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Info.ogg",
    ["Kachink"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Kachink.ogg",
    ["Link"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Link.ogg",
    ["Text1"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Text1.ogg",
    ["Text2"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Text2.ogg",
    ["Xylo"] = "Interface\\AddOns\\n1mmelUI\\media\\sounds\\Xylo.ogg"
}

-- Register fonts for the dropdown menus
local menuFonts = {}
for key, path in pairs(fontPaths) do
    menuFonts[key] = CreateFont("N1mmelUI_DropFont_" .. key)
    menuFonts[key]:SetFont(path, 12, "")
end

---------------------------------------------------------
-- 2. HELPERS & FACTORIES
---------------------------------------------------------
-- Toggles the main GUI
function ns.ToggleGUI()
    if n1mmelGUI then
        if n1mmelGUI:IsShown() then
            n1mmelGUI:Hide()
        else
            n1mmelGUI:Show()
        end
    else
        print(L.GUI_ERROR or "GUI not loaded")
    end
end

-- Slash Commands
SLASH_N1MMELMENU1 = "/n1"
SLASH_N1MMELMENU2 = "/n1mmelui"
SlashCmdList["N1MMELMENU"] = function()
    ns.ToggleGUI()
end
SLASH_N1DEBUG1 = "/n1debug"
SlashCmdList["N1DEBUG"] = function()
    -- Wir kehren den aktuellen Status um (Toggle)
    N1mmelUIDB.debugMode = not N1mmelUIDB.debugMode

    if N1mmelUIDB.debugMode then
        print("|cff00ff00n1mmelUI Debug: AN|r")
    else
        print("|cffff0000n1mmelUI Debug: AUS|r")
    end
end

-- Refresh Item Levels on UI change
local function RefreshItemLevels()
    if ns.UpdateCharacterItemLevels then
        ns.UpdateCharacterItemLevels()
    end
    if ns.UpdateBagItemLevels then
        ns.UpdateBagItemLevels()
    end
end

-- Dropdown Radio Button Factory
local function AddStyledRadio(rootDescription, text, isSelectedFunc, setSelectedFunc, customFontKey)
    local btnDesc = rootDescription:CreateRadio(text, isSelectedFunc, setSelectedFunc)
    local fontKey = customFontKey or (N1mmelUIDB and N1mmelUIDB.globalFont) or "STANDARD"

    if btnDesc.SetFontObject then
        btnDesc:SetFontObject(menuFonts[fontKey])
    else
        btnDesc:AddInitializer(function(btn)
            local fs = btn.fontString or btn.Text or (btn.GetFontString and btn:GetFontString())
            if fs and fs.SetFontObject then
                fs:SetFontObject(menuFonts[fontKey])
            end
        end)
    end
    return btnDesc
end

-- Checkbox Factory (Saves ~150 lines of code)
function ns.CreateCheckbox(parent, anchorFrame, point, relPoint, x, y, label, isChecked, onClickFn)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint(point, anchorFrame, relPoint, x, y)
    cb.text = cb:CreateFontString(nil, "OVERLAY")
    cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    ns.SetUIFont(cb.text, 12)
    cb.text:SetText(label)
    cb:SetChecked(isChecked)
    cb:SetScript("OnClick", onClickFn)
    return cb
end

---------------------------------------------------------
-- 3. PAGE BUILDERS (Modular UI Tabs)
---------------------------------------------------------
local function BuildPage1_General(page)
    local _, classTag = UnitClass("player")
    local color = RAID_CLASS_COLORS[classTag] or {
        r = 1,
        g = 1,
        b = 1
    }
    local classHex = string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local title = page:CreateFontString(nil, "OVERLAY")
    title:SetPoint("TOP", 0, -20)
    ns.SetUIFont(title, 22, "OUTLINE")
    local coloredName = "|c" .. classHex .. "n1mmelUI|r"
    title:SetText(string.format(L.WELCOME_TITLE or "Welcome to %s", coloredName))
    local line = page:CreateTexture(nil, "ARTWORK")
    line:SetSize(420, 1)
    line:SetColorTexture(1, 1, 1, 0.2)
    line:SetPoint("TOP", title, "BOTTOM", 0, -15)

    -- Checkboxes using the Factory
    local cbChat = ns.CreateCheckbox(page, page, "TOPLEFT", "TOPLEFT", 20, -80, L.CB_CHAT, N1mmelUIDB.showLoadMessage,
        function(self)
            N1mmelUIDB.showLoadMessage = self:GetChecked()
        end)
    local cbRepair = ns.CreateCheckbox(page, cbChat, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_REPAIR, N1mmelUIDB.autoRepair,
        function(self)
            N1mmelUIDB.autoRepair = self:GetChecked()
        end)
    local cbSell = ns.CreateCheckbox(page, cbRepair, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_SELL, N1mmelUIDB.autoSell,
        function(self)
            N1mmelUIDB.autoSell = self:GetChecked()
        end)
    local cbInfo = ns.CreateCheckbox(page, cbSell, "TOPLEFT", "BOTTOMLEFT", 0, -5, "Show Info Window",
        N1mmelUIDB.infoWindow, function(self)
            -- Speichere den Zustand in der DB
            N1mmelUIDB.infoWindow = self:GetChecked()

            -- Sag dem Fenster direkt, was es tun soll
            if ns.infoWindow then
                if N1mmelUIDB.infoWindow then
                    ns.infoWindow:Show()
                else
                    ns.infoWindow:Hide()
                end
            end
        end)


    -- Font Dropdown
    local fontLabel = page:CreateFontString(nil, "ARTWORK")
    fontLabel:SetPoint("TOPLEFT", cbInfo, "BOTTOMLEFT", 5, -20)
    ns.SetUIFont(fontLabel, 12)
    fontLabel:SetText(L.FONT_LABEL)

    local fontDrop = CreateFrame("DropdownButton", "N1mmelFontDropdown", page, "WowStyle1DropdownTemplate")
    fontDrop:SetPoint("LEFT", fontLabel, "RIGHT", 15, 0)
    fontDrop:SetWidth(150)
    fontDrop:SetupMenu(function(dropdown, rootDescription)
        AddStyledRadio(rootDescription, "Standard WoW", function()
            return N1mmelUIDB.globalFont == "STANDARD"
        end, function()
            N1mmelUIDB.globalFont = "STANDARD";
            ns.UpdateAllFonts()
        end, "STANDARD")
        AddStyledRadio(rootDescription, "PT Sans Narrow", function()
            return N1mmelUIDB.globalFont == "PTSANS"
        end, function()
            N1mmelUIDB.globalFont = "PTSANS";
            ns.UpdateAllFonts()
        end, "PTSANS")
        AddStyledRadio(rootDescription, "Expressway", function()
            return N1mmelUIDB.globalFont == "EXPRESSWAY"
        end, function()
            N1mmelUIDB.globalFont = "EXPRESSWAY";
            ns.UpdateAllFonts()
        end, "EXPRESSWAY")
    end)
    if fontDrop.Text then
        ns.SetUIFont(fontDrop.Text, 12)
    end

    local fontWarn = page:CreateFontString(nil, "ARTWORK")
    fontWarn:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -15)
    ns.SetUIFont(fontWarn, 11)
    fontWarn:SetTextColor(0.8, 0.8, 0.8)
    fontWarn:SetText(L.FONT_RELOAD_WARN)

    local fontReload = page:CreateFontString(nil, "ARTWORK")
    fontReload:SetPoint("TOPLEFT", fontWarn, "BOTTOMLEFT", 20, -75)
    ns.SetUIFont(fontReload, 11)
    fontReload:SetTextColor(0.8, 0.8, 0.8)
    fontReload:SetText(
        "If there is any problem, try reloading the UI with\n /reload or by clicking the button to your right ->")

    local btnReloadTemplate = GameMenuFrame and GameMenuFrame.buttonTemplate or "GameMenuButtonTemplate"
    local btnReload = CreateFrame("BUTTON", nil, page, btnReloadTemplate)
    btnReload:SetSize(100, 30)
    btnReload:SetPoint("BOTTOMRIGHT", -5, 5)
    btnReload:SetText("Reload UI")
    btnReload:SetScript("OnClick", function()
        ReloadUI()
    end)
    if btnReload:GetFontString() then
        ns.SetUIFont(btnReload:GetFontString(), 13)
    end
end



local function BuildPage2_Equipment(page)
    local cbIlvlChar = ns.CreateCheckbox(page, page, "TOPLEFT", "TOPLEFT", 20, -20, L.ILVL_CHAR, N1mmelUIDB.ilvlChar,
        function(self)
            N1mmelUIDB.ilvlChar = self:GetChecked();
            RefreshItemLevels()
        end)

    local charSizeDrop = CreateFrame("DropdownButton", "N1mmelCharSizeDrop", page, "WowStyle1DropdownTemplate")
    charSizeDrop:SetPoint("LEFT", cbIlvlChar.text, "RIGHT", 15, 0)
    charSizeDrop:SetWidth(60)
    charSizeDrop:SetupMenu(function(dropdown, rootDescription)
        for i = 9, 16 do
            AddStyledRadio(rootDescription, tostring(i), function()
                return N1mmelUIDB.ilvlCharSize == i
            end, function()
                N1mmelUIDB.ilvlCharSize = i;
                RefreshItemLevels()
            end)
        end
    end)

    local cbIlvlBags = ns.CreateCheckbox(page, cbIlvlChar, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.ILVL_BAGS,
        N1mmelUIDB.ilvlBags, function(self)
            N1mmelUIDB.ilvlBags = self:GetChecked();
            RefreshItemLevels()
        end)

    local bagSizeDrop = CreateFrame("DropdownButton", "N1mmelBagSizeDrop", page, "WowStyle1DropdownTemplate")
    bagSizeDrop:SetPoint("LEFT", cbIlvlBags.text, "RIGHT", 15, 0)
    bagSizeDrop:SetWidth(60)
    bagSizeDrop:SetupMenu(function(dropdown, rootDescription)
        for i = 9, 16 do
            AddStyledRadio(rootDescription, tostring(i), function()
                return N1mmelUIDB.ilvlBagsSize == i
            end, function()
                N1mmelUIDB.ilvlBagsSize = i;
                RefreshItemLevels()
            end)
        end
    end)

    -- Color Mode
    local colorLabel = page:CreateFontString(nil, "ARTWORK")
    colorLabel:SetPoint("TOPLEFT", cbIlvlBags, "BOTTOMLEFT", 5, -20)
    ns.SetUIFont(colorLabel, 12)
    colorLabel:SetText(L.ILVL_COLOR_LABEL)

    local colorDrop = CreateFrame("DropdownButton", "N1mmelIlvlColorDropdown", page, "WowStyle1DropdownTemplate")
    colorDrop:SetPoint("LEFT", colorLabel, "RIGHT", 15, 0)
    colorDrop:SetWidth(200)
    colorDrop:SetupMenu(function(dropdown, rootDescription)
        AddStyledRadio(rootDescription, L.COLOR_QUALITY, function()
            return N1mmelUIDB.ilvlColorMode == "QUALITY"
        end, function()
            N1mmelUIDB.ilvlColorMode = "QUALITY";
            RefreshItemLevels()
        end)
        AddStyledRadio(rootDescription, L.COLOR_WHITE, function()
            return N1mmelUIDB.ilvlColorMode == "WHITE"
        end, function()
            N1mmelUIDB.ilvlColorMode = "WHITE";
            RefreshItemLevels()
        end)
        AddStyledRadio(rootDescription, L.COLOR_YELLOW, function()
            return N1mmelUIDB.ilvlColorMode == "YELLOW"
        end, function()
            N1mmelUIDB.ilvlColorMode = "YELLOW";
            RefreshItemLevels()
        end)
    end)
    if colorDrop.Text then
        ns.SetUIFont(colorDrop.Text, 12)
    end

    -- Output Divider
    local checkDivider = page:CreateTexture(nil, "ARTWORK")
    checkDivider:SetSize(420, 1)
    checkDivider:SetPoint("TOPLEFT", colorLabel, "BOTTOMLEFT", -5, -30)
    checkDivider:SetColorTexture(1, 1, 1, 0.15)

    local outputLabel = page:CreateFontString(nil, "ARTWORK")
    outputLabel:SetPoint("TOPLEFT", checkDivider, "BOTTOMLEFT", 5, -20)
    ns.SetUIFont(outputLabel, 12)
    outputLabel:SetText(L.CHECK_OUTPUT)

    local outputDrop = CreateFrame("DropdownButton", "N1mmelCheckOutputDropdown", page, "WowStyle1DropdownTemplate")
    outputDrop:SetPoint("LEFT", outputLabel, "RIGHT", 15, 0)
    outputDrop:SetWidth(150)
    outputDrop:SetupMenu(function(dropdown, rootDescription)
        AddStyledRadio(rootDescription, L.OUTPUT_CHAT, function()
            return N1mmelUIDB.checkOutput == "CHAT"
        end, function()
            N1mmelUIDB.checkOutput = "CHAT"
        end)
        AddStyledRadio(rootDescription, L.OUTPUT_WINDOW, function()
            return N1mmelUIDB.checkOutput == "WINDOW"
        end, function()
            N1mmelUIDB.checkOutput = "WINDOW"
        end)
    end)
    if outputDrop.Text then
        ns.SetUIFont(outputDrop.Text, 12)
    end

    -- Manual Check Button
    local escBtnTemplate = GameMenuFrame and GameMenuFrame.buttonTemplate or "GameMenuButtonTemplate"
    local btnItemCheck = CreateFrame("Button", nil, page, escBtnTemplate)
    btnItemCheck:SetSize(160, 30)
    btnItemCheck:SetPoint("TOPLEFT", outputLabel, "BOTTOMLEFT", 125, -25)
    btnItemCheck:SetText(L.BTN_CHECK)
    btnItemCheck:SetScript("OnClick", function()
        ns.RunItemCheck()
    end)
    if btnItemCheck:GetFontString() then
        ns.SetUIFont(btnItemCheck:GetFontString(), 13)
    end

    local checkDesc = page:CreateFontString(nil, "ARTWORK")
    checkDesc:SetPoint("TOP", btnItemCheck, "BOTTOM", 0, -10)
    checkDesc:SetWidth(400)
    checkDesc:SetJustifyH("CENTER")
    ns.SetUIFont(checkDesc, 11)
    checkDesc:SetTextColor(0.8, 0.8, 0.8)
    checkDesc:SetText(L.CHECK_DESC)
end

local function BuildPage3_Performance(page)
    -- Fontstrings
    local fpsTitle = page:CreateFontString(nil, "ARTWORK")
    fpsTitle:SetPoint("TOPLEFT", page, "TOPLEFT", 20, -20)
    ns.SetUIFont(fpsTitle, 12);
    fpsTitle:SetText(L.FPS_TEXT)

    local fpsVal = page:CreateFontString(nil, "ARTWORK")
    fpsVal:SetPoint("TOPLEFT", fpsTitle, "BOTTOMLEFT", 0, -5)
    ns.SetUIFont(fpsVal, 14, "OUTLINE")

    local pingTitle = page:CreateFontString(nil, "ARTWORK")
    pingTitle:SetPoint("TOPLEFT", fpsVal, "BOTTOMLEFT", 0, -15)
    ns.SetUIFont(pingTitle, 12);
    pingTitle:SetText(L.LATENCY_TEXT)

    local pingVal = page:CreateFontString(nil, "ARTWORK")
    pingVal:SetPoint("TOPLEFT", pingTitle, "BOTTOMLEFT", 0, -5)
    ns.SetUIFont(pingVal, 14, "OUTLINE")

    local ramTitle = page:CreateFontString(nil, "ARTWORK")
    ramTitle:SetPoint("TOPLEFT", pingVal, "BOTTOMLEFT", 0, -15)
    ns.SetUIFont(ramTitle, 12);
    ramTitle:SetText(L.RAM_TEXT)

    local ramVal = page:CreateFontString(nil, "ARTWORK")
    ramVal:SetPoint("TOPLEFT", ramTitle, "BOTTOMLEFT", 0, -5)
    ns.SetUIFont(ramVal, 14, "OUTLINE")

    local totalRamTitle = page:CreateFontString(nil, "ARTWORK")
    totalRamTitle:SetPoint("TOPLEFT", ramVal, "BOTTOMLEFT", 0, -15)
    ns.SetUIFont(totalRamTitle, 12);
    totalRamTitle:SetText(L.TOTALMEM_TEXT)

    local totalRamVal = page:CreateFontString(nil, "ARTWORK")
    totalRamVal:SetPoint("TOPLEFT", totalRamTitle, "BOTTOMLEFT", 0, -5)
    ns.SetUIFont(totalRamVal, 14, "OUTLINE")

    local topAddonsTitle = page:CreateFontString(nil, "ARTWORK")
    topAddonsTitle:SetPoint("TOPLEFT", totalRamVal, "BOTTOMLEFT", 0, -15)
    ns.SetUIFont(topAddonsTitle, 12);
    topAddonsTitle:SetText(L.MOSTMEMORY_TEXT)

    local topAddonsVal = page:CreateFontString(nil, "ARTWORK")
    topAddonsVal:SetPoint("TOPLEFT", topAddonsTitle, "BOTTOMLEFT", 0, -5)
    ns.SetUIFont(topAddonsVal, 12);
    topAddonsVal:SetTextColor(0.8, 0.8, 0.8);
    topAddonsVal:SetJustifyH("LEFT")

    -- Garbage Collect Button
    local cleanBtn = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    cleanBtn:SetSize(140, 25)
    cleanBtn:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 20, 20)
    cleanBtn:SetText(L.GARBAGE_COLLECT_TEXT)
    cleanBtn:SetScript("OnClick", function()
        UpdateAddOnMemoryUsage();
        collectgarbage("collect");
        UpdateAddOnMemoryUsage()
    end)
    if cleanBtn.Text then
        ns.SetUIFont(cleanBtn.Text, 12)
    end

    -- Update Logic
    local fpsTimer, ramTimer, totalFPS, fpsCount = 0, 0, 0, 0
    page:SetScript("OnShow", function()
        totalFPS, fpsCount = 0, 0;
        fpsTimer, ramTimer = 0.5, 2.0
    end)
    page:SetScript("OnUpdate", function(self, elapsed)
        fpsTimer = fpsTimer + elapsed
        ramTimer = ramTimer + elapsed

        if fpsTimer >= 0.5 then
            local currentFPS = GetFramerate()
            totalFPS = totalFPS + currentFPS
            fpsCount = fpsCount + 1
            fpsVal:SetText(string.format("%.1f (Ø %.1f)", currentFPS, totalFPS / fpsCount))

            local _, _, home, world = GetNetStats()
            pingVal:SetText(string.format("%d ms (Home)  |  %d ms (World)", home, world))
            fpsTimer = 0
        end

        if ramTimer >= 2.0 then
            UpdateAddOnMemoryUsage()
            local mem = GetAddOnMemoryUsage(addonName)
            if mem > 1024 then
                ramVal:SetText(string.format("%.2f MB", mem / 1024))
            else
                ramVal:SetText(string.format("%.1f KB", mem))
            end

            local totalMem = 0
            local addons = {}
            for i = 1, C_AddOns.GetNumAddOns() do
                local usage = GetAddOnMemoryUsage(i)
                totalMem = totalMem + usage
                table.insert(addons, {
                    name = C_AddOns.GetAddOnInfo(i),
                    usage = usage
                })
            end
            totalRamVal:SetText(string.format("%.2f MB", totalMem / 1024))

            table.sort(addons, function(a, b)
                return a.usage > b.usage
            end)
            local topStr = ""
            for i = 1, 3 do
                if addons[i] and addons[i].usage > 0 then
                    topStr = topStr .. string.format("%d. %s%s|r (%s)\n", i, "|cFFFFFFFF", addons[i].name,
                        string.format("|cffffd100%.1f MB|r", addons[i].usage / 1024))
                end
            end
            topAddonsVal:SetText(topStr)
            ramTimer = 0
        end
    end)
end

local function BuildPage4_MapMinimap(page)
    local cbSquare = ns.CreateCheckbox(page, page, "TOPLEFT", "TOPLEFT", 20, -15, L.CB_SQUARE_MINIMAP,
        N1mmelUIDB.squareMinimap, function(self)
            N1mmelUIDB.squareMinimap = self:GetChecked();
            ns.UpdateMinimapStyle()
        end)
    local cbMinimap = ns.CreateCheckbox(page, cbSquare, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_MINIMAP,
        N1mmelUIDB.showMinimapCoords, function(self)
            N1mmelUIDB.showMinimapCoords = self:GetChecked();
            if N1mmelUIDB.showMinimapCoords then
                ns.mmCoordsFrame:Show()
            else
                ns.mmCoordsFrame:Hide()
            end
        end)
    local cbMapCoords = ns.CreateCheckbox(page, cbMinimap, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_MAP_COORDS,
        N1mmelUIDB.showMapCoords, function(self)
            N1mmelUIDB.showMapCoords = self:GetChecked();
            if ns.UpdateMapCoordsVisibility then
                ns.UpdateMapCoordsVisibility()
            end
        end)

    local posLabel = page:CreateFontString(nil, "ARTWORK")
    posLabel:SetPoint("TOPLEFT", cbMapCoords, "BOTTOMLEFT", 5, -50)
    ns.SetUIFont(posLabel, 12);
    posLabel:SetText(L.POS_LABEL)

    local dropDown = CreateFrame("DropdownButton", "N1mmelUIDropdown", page, "WowStyle1DropdownTemplate")
    dropDown:SetPoint("LEFT", posLabel, "RIGHT", 15, 0)
    dropDown:SetWidth(150)
    dropDown:SetupMenu(function(dropdown, rootDescription)
        AddStyledRadio(rootDescription, L.TOP_LEFT, function()
            return N1mmelUIDB.coordPos == "TOPLEFT"
        end, function()
            N1mmelUIDB.coordPos = "TOPLEFT";
            ns.UpdateCoordPosition()
        end)
        AddStyledRadio(rootDescription, L.TOP_RIGHT, function()
            return N1mmelUIDB.coordPos == "TOPRIGHT"
        end, function()
            N1mmelUIDB.coordPos = "TOPRIGHT";
            ns.UpdateCoordPosition()
        end)
        AddStyledRadio(rootDescription, L.BOTTOM_LEFT, function()
            return N1mmelUIDB.coordPos == "BOTTOMLEFT"
        end, function()
            N1mmelUIDB.coordPos = "BOTTOMLEFT";
            ns.UpdateCoordPosition()
        end)
        AddStyledRadio(rootDescription, L.BOTTOM_RIGHT, function()
            return N1mmelUIDB.coordPos == "BOTTOMRIGHT"
        end, function()
            N1mmelUIDB.coordPos = "BOTTOMRIGHT";
            ns.UpdateCoordPosition()
        end)
    end)
    if dropDown.Text then
        ns.SetUIFont(dropDown.Text, 12)
    end

    local cbMinimapBtn = ns.CreateCheckbox(page, cbMapCoords, "TOPLEFT", "BOTTOMLEFT", 0, -5, "Minimap Button anzeigen",
        not N1mmelUIDB.minimapIcon.hide, function(self)
            N1mmelUIDB.minimapIcon.hide = not self:GetChecked()
            local icon = LibStub("LibDBIcon-1.0", true)
            if icon then
                if N1mmelUIDB.minimapIcon.hide then
                    icon:Hide(addonName)
                else
                    icon:Show(addonName)
                end
            end
        end)
end

local function BuildPage5_UI(page)
    -- 1. Checkbox: Klassenfarben (bestehend)
    local cbClassColor = ns.CreateCheckbox(page, page, "TOPLEFT", "TOPLEFT", 20, -15, L.CB_CLASSCOLOR,
        N1mmelUIDB.targetClassColor, function(self)
            N1mmelUIDB.targetClassColor = self:GetChecked();
            if ns.ForceTargetColorUpdate then
                ns.ForceTargetColorUpdate()
            end
        end)

    -- 2. NEU: Checkbox für Unit Frame Fonts
    local cbUFFonts = ns.CreateCheckbox(page, cbClassColor, "TOPLEFT", "BOTTOMLEFT", 0, -5, "Unit Frame Fonts anpassen",
        N1mmelUIDB.unitFrameFonts, function(self)
            N1mmelUIDB.unitFrameFonts = self:GetChecked()
            if ns.UpdateUnitFrameFonts then
                ns.UpdateUnitFrameFonts()
            end
        end)

    -- 3. NEU: Dropdown für die Schriftgröße (direkt rechts neben der Checkbox)
    local ufSizeDrop = CreateFrame("DropdownButton", "N1mmelUnitFontSizeDrop", page, "WowStyle1DropdownTemplate")
    ufSizeDrop:SetPoint("LEFT", cbUFFonts.text, "RIGHT", 20, 0)
    ufSizeDrop:SetWidth(70)
    ufSizeDrop:SetupMenu(function(dropdown, rootDescription)
        for i = 10, 18 do
            AddStyledRadio(rootDescription, tostring(i), function()
                return N1mmelUIDB.unitFrameFontSize == i
            end, function()
                N1mmelUIDB.unitFrameFontSize = i;
                if ns.UpdateUnitFrameFonts then
                    ns.UpdateUnitFrameFonts()
                end
            end)
        end
    end)
    -- Damit im Dropdown immer die aktuelle Zahl steht
    if ufSizeDrop.Text then
        ns.SetUIFont(ufSizeDrop.Text, 12)
    end

    -- 4. Checkbox: Cinematics (bestehend, jetzt unter der Font-Checkbox verankert)
    local cbCinematics = ns.CreateCheckbox(page, cbUFFonts, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_SKIP_CINEMATICS,
        N1mmelUIDB.skipCinematics, function(self)
            N1mmelUIDB.skipCinematics = self:GetChecked()
        end)

    -- 5. Checkbox: Talking Head (bestehend)
    local cbTalkingHead = ns.CreateCheckbox(page, cbCinematics, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_HIDE_TALKINGHEAD,
        N1mmelUIDB.hideTalkingHead, function(self)
            N1mmelUIDB.hideTalkingHead = self:GetChecked();
            if ns.UpdateTalkingHead then
                ns.UpdateTalkingHead()
            end
        end)

    -- 6. Checkbox: AFK Screen (bestehend)
    local cbAFK = ns.CreateCheckbox(page, cbTalkingHead, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_AFK_SCREEN,
        N1mmelUIDB.afkScreen, function(self)
            N1mmelUIDB.afkScreen = self:GetChecked();
            if ns.ToggleAFKScreen then
                ns.ToggleAFKScreen()
            end
        end)
end

local function BuildPage6_Chat(page)
    local cbShortChannels = ns.CreateCheckbox(page, page, "TOPLEFT", "TOPLEFT", 20, -15, L.CB_SHORT_CHANNELS,
        N1mmelUIDB.shortChannels, function(self)
            N1mmelUIDB.shortChannels = self:GetChecked()
        end)
    local cbChatClassColors = ns.CreateCheckbox(page, cbShortChannels, "TOPLEFT", "BOTTOMLEFT", 0, -5,
        L.CB_CHAT_CLASS_COLORS, N1mmelUIDB.chatClassColors, function(self)
            N1mmelUIDB.chatClassColors = self:GetChecked();
            if ns.UpdateChatClassColors then
                ns.UpdateChatClassColors()
            end
        end)
    local cbChatURLs = ns.CreateCheckbox(page, cbChatClassColors, "TOPLEFT", "BOTTOMLEFT", 0, -5, L.CB_CHAT_URLS,
        N1mmelUIDB.chatURLs, function(self)
            N1mmelUIDB.chatURLs = self:GetChecked()
        end)

    local whisperDivider = page:CreateTexture(nil, "ARTWORK")
    whisperDivider:SetSize(420, 1)
    whisperDivider:SetPoint("TOPLEFT", cbChatURLs, "BOTTOMLEFT", -5, -20)
    whisperDivider:SetColorTexture(1, 1, 1, 0.15)

    local whisperTitle = page:CreateFontString(nil, "OVERLAY")
    whisperTitle:SetPoint("TOPLEFT", whisperDivider, "BOTTOMLEFT", 5, -15)
    ns.SetUIFont(whisperTitle, 14, "OUTLINE");
    whisperTitle:SetText(L.WHISPER_ALERT_TITLE)

    local cbWhisper = ns.CreateCheckbox(page, whisperTitle, "TOPLEFT", "BOTTOMLEFT", -5, -10, L.CB_WHISPER_ALERT,
        N1mmelUIDB.whisperAlert, function(self)
            N1mmelUIDB.whisperAlert = self:GetChecked()
        end)

    local soundLabel = page:CreateFontString(nil, "ARTWORK")
    soundLabel:SetPoint("TOPLEFT", cbWhisper, "BOTTOMLEFT", 5, -15)
    ns.SetUIFont(soundLabel, 12);
    soundLabel:SetText(L.SOUND_LABEL)

    local soundDrop = CreateFrame("DropdownButton", "N1mmelWhisperSoundDrop", page, "WowStyle1DropdownTemplate")
    soundDrop:SetPoint("LEFT", soundLabel, "RIGHT", 15, 0)
    soundDrop:SetWidth(150)
    soundDrop:SetupMenu(function(dropdown, rootDescription)
        local keys = {}
        for k in pairs(soundPaths) do
            table.insert(keys, k)
        end
        table.sort(keys)
        for _, name in ipairs(keys) do
            AddStyledRadio(rootDescription, name, function()
                return N1mmelUIDB.whisperSound == name
            end, function()
                N1mmelUIDB.whisperSound = name;
                PlaySoundFile(soundPaths[name], "Master")
            end)
        end
    end)
    if soundDrop.Text then
        ns.SetUIFont(soundDrop.Text, 12)
    end
end

local function BuildPage7_Mythic(page)
    local mScoreLabel = page:CreateFontString(nil, "OVERLAY")
    mScoreLabel:SetPoint("TOP", page, "TOP", 0, -25)
    ns.SetUIFont(mScoreLabel, 14);
    mScoreLabel:SetText((L.TAB_MYTHIC or "Mythic") .. " Rating:");
    mScoreLabel:SetTextColor(0.8, 0.8, 0.8)

    local mScoreVal = page:CreateFontString(nil, "OVERLAY")
    mScoreVal:SetPoint("TOP", mScoreLabel, "BOTTOM", 0, -5)
    ns.SetUIFont(mScoreVal, 42, "OUTLINE")

    local mPlayerInfo = page:CreateFontString(nil, "OVERLAY")
    mPlayerInfo:SetPoint("TOP", mScoreVal, "BOTTOM", 0, -10)
    ns.SetUIFont(mPlayerInfo, 16, "OUTLINE")

    local mDivider = page:CreateTexture(nil, "ARTWORK")
    mDivider:SetSize(420, 1)
    mDivider:SetPoint("TOP", mPlayerInfo, "BOTTOM", 0, -15)
    mDivider:SetColorTexture(1, 1, 1, 0.15)

    local mWeeklyLabel = page:CreateFontString(nil, "OVERLAY")
    mWeeklyLabel:SetPoint("TOP", mDivider, "BOTTOM", 0, -20)
    ns.SetUIFont(mWeeklyLabel, 13);
    mWeeklyLabel:SetText("Highest Weekly Key:");
    mWeeklyLabel:SetTextColor(0.8, 0.8, 0.8)

    local mWeeklyVal = page:CreateFontString(nil, "OVERLAY")
    mWeeklyVal:SetPoint("TOP", mWeeklyLabel, "BOTTOM", 0, -5)
    ns.SetUIFont(mWeeklyVal, 26, "OUTLINE")

    local crestIDs = {{
        id = 3383,
        name = "Adventurer"
    }, {
        id = 3341,
        name = "Veteran"
    }, {
        id = 3343,
        name = "Champion"
    }, {
        id = 3345,
        name = "Hero"
    }, {
        id = 3347,
        name = "Myth"
    }}

    local crestFrames = {}
    for i, data in ipairs(crestIDs) do
        local f = CreateFrame("Frame", nil, page)
        f:SetSize(60, 80)
        f:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 50 + (i - 1) * 75, 30)

        f.icon = f:CreateTexture(nil, "OVERLAY")
        f.icon:SetSize(32, 32);
        f.icon:SetPoint("TOP", f, "TOP", 0, 0)

        f.txt = f:CreateFontString(nil, "OVERLAY")
        f.txt:SetPoint("TOP", f.icon, "BOTTOM", 0, -5);
        ns.SetUIFont(f.txt, 12, "OUTLINE")

        f.progress = f:CreateFontString(nil, "OVERLAY")
        f.progress:SetPoint("TOP", f.txt, "BOTTOM", 0, -2);
        ns.SetUIFont(f.progress, 9)

        f.label = f:CreateFontString(nil, "OVERLAY")
        f.label:SetPoint("TOP", f.progress, "BOTTOM", 0, -4)
        ns.SetUIFont(f.label, 9);
        f.label:SetText(data.name);
        f.label:SetTextColor(0.6, 0.6, 0.6)

        f:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:SetCurrencyByID(data.id);
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        crestFrames[i] = f
    end

    local function UpdateMythicPage()
        local score = C_ChallengeMode.GetOverallDungeonScore()
        local color = C_ChallengeMode.GetDungeonScoreRarityColor(score) or HIGHLIGHT_FONT_COLOR
        mScoreVal:SetText(score > 0 and score or "0")
        mScoreVal:SetTextColor(color.r, color.g, color.b)

        local _, classTag = UnitClass("player")
        local c = RAID_CLASS_COLORS[classTag] or {
            r = 1,
            g = 1,
            b = 1
        }
        local classHex = string.format("ff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
        local specName = GetSpecialization() and select(2, GetSpecializationInfo(GetSpecialization())) or ""
        local avgIlvl = math.floor(select(2, GetAverageItemLevel()))
        mPlayerInfo:SetText("|c" .. classHex .. UnitName("player") .. " - " .. specName .. "|r |cFFFFFFFF(iLvl: " ..
                                avgIlvl .. ")|r")

        local highest = 0
        local maps = C_ChallengeMode.GetMapTable()
        for _, mapID in ipairs(maps) do
            local _, level = C_MythicPlus.GetWeeklyBestForMap(mapID)
            if level and level > highest then
                highest = level
            end
        end
        mWeeklyVal:SetText(highest > 0 and ("+" .. highest) or "-")

        for i, data in ipairs(crestIDs) do
            local info = C_CurrencyInfo.GetCurrencyInfo(data.id)
            if info and crestFrames[i] then
                crestFrames[i].icon:SetTexture(info.iconFileID)
                crestFrames[i].txt:SetText(info.quantity)
                local total = info.totalEarned or 0
                local maxQ = info.maxQuantity or 0
                crestFrames[i].progress:SetText(total .. " / " .. maxQ)
                if total >= maxQ and maxQ > 0 then
                    crestFrames[i].progress:SetTextColor(1, 0, 0)
                else
                    crestFrames[i].progress:SetTextColor(1, 1, 1)
                end
            end
        end
    end
    page:SetScript("OnShow", UpdateMythicPage)
end

local function BuildPage8_Info(page)
    local infoTitle = page:CreateFontString(nil, "OVERLAY")
    infoTitle:SetPoint("TOP", 0, -20);
    ns.SetUIFont(infoTitle, 22, "OUTLINE");
    infoTitle:SetText("|cff00ffffn1mmelUI|r")

    local infoAuthor = page:CreateFontString(nil, "OVERLAY")
    infoAuthor:SetPoint("TOP", infoTitle, "BOTTOM", 0, -5);
    ns.SetUIFont(infoAuthor, 14);
    infoAuthor:SetText((L.INFO_BY or "by") .. " |cffffd100n1mmel|r")

    local infoLine = page:CreateTexture(nil, "ARTWORK")
    infoLine:SetSize(420, 1);
    infoLine:SetColorTexture(1, 1, 1, 0.2)
    infoLine:SetPoint("TOP", infoAuthor, "BOTTOM", 0, -20)

    local infoContent = page:CreateFontString(nil, "OVERLAY")
    infoContent:SetWidth(420);
    infoContent:SetJustifyH("LEFT");
    infoContent:SetJustifyV("TOP")
    infoContent:SetPoint("TOP", infoLine, "BOTTOM", 0, -20);
    ns.SetUIFont(infoContent, 13)
    infoContent:SetText(L.INFO_CONTENT or "Text fehlt.")

    -- CurseForge Link Popup Registration
    if not StaticPopupDialogs["N1MMELUI_CURSE_LINK"] then
        StaticPopupDialogs["N1MMELUI_CURSE_LINK"] = {
            text = L.COPY_CURSE_LINK or "Press Ctrl+C to copy:",
            button1 = OKAY,
            hasEditBox = true,
            OnShow = function(self, data)
                local editBox = self.EditBox or self.editBox
                if editBox then
                    editBox:SetText(data);
                    editBox:HighlightText();
                    editBox:SetFocus()
                end
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
    end

    local curseBtn = CreateFrame("Button", nil, page)
    curseBtn:SetSize(250, 30);
    curseBtn:SetPoint("BOTTOM", page, "BOTTOM", 0, 20)

    local curseIcon = curseBtn:CreateTexture(nil, "ARTWORK")
    curseIcon:SetSize(16, 16);
    curseIcon:SetPoint("LEFT", curseBtn, "LEFT", 10, 0)
    curseIcon:SetTexture("Interface\\FriendsFrame\\InformationIcon")

    local curseText = curseBtn:CreateFontString(nil, "OVERLAY")
    curseText:SetPoint("LEFT", curseIcon, "RIGHT", 8, 0);
    ns.SetUIFont(curseText, 14)
    curseText:SetText("n1mmelUI auf CurseForge");
    curseText:SetTextColor(0, 1, 1)

    curseBtn:SetScript("OnEnter", function()
        curseText:SetTextColor(1, 1, 1)
    end)
    curseBtn:SetScript("OnLeave", function()
        curseText:SetTextColor(0, 1, 1)
    end)
    curseBtn:SetScript("OnClick", function()
        StaticPopup_Show("N1MMELUI_CURSE_LINK", "", "", "https://www.curseforge.com/wow/addons/n1mmelui")
    end)
end

---------------------------------------------------------
-- 4. GUI CONSTRUCTION (Main Execution)
---------------------------------------------------------
function ns.BuildStandaloneGUI()
    local _, playerClass = UnitClass("player")
    local cColor = RAID_CLASS_COLORS[playerClass]
    local r, g, b = 0, 1, 1
    if cColor then
        r, g, b = cColor.r, cColor.g, cColor.b
    end

    -----------------------------------------------------
    -- POPUP WINDOW: ITEM CHECK RESULTS
    -----------------------------------------------------
    ns.checkWin = CreateFrame("Frame", "N1mmelItemCheckWindow", UIParent)
    ns.checkWin:SetSize(350, 400);
    ns.checkWin:SetPoint("CENTER")
    ns.checkWin:SetMovable(true);
    ns.checkWin:EnableMouse(true);
    ns.checkWin:RegisterForDrag("LeftButton")
    ns.checkWin:SetScript("OnDragStart", ns.checkWin.StartMoving);
    ns.checkWin:SetScript("OnDragStop", ns.checkWin.StopMovingOrSizing)
    ns.checkWin:SetFrameStrata("DIALOG");
    ns.checkWin:Hide()
    tinsert(UISpecialFrames, ns.checkWin:GetName())

    local cwBg = ns.checkWin:CreateTexture(nil, "BACKGROUND")
    cwBg:SetAllPoints();
    cwBg:SetColorTexture(0.05, 0.05, 0.05, 0.95)

    local cwBorder = ns.checkWin:CreateTexture(nil, "BORDER")
    cwBorder:SetSize(350, 2);
    cwBorder:SetPoint("TOP", ns.checkWin, "TOP", 0, 0);
    cwBorder:SetColorTexture(r, g, b, 0.8)

    -- Bottom Border (in Class Color)
    local cwBorder2 = ns.checkWin:CreateTexture(nil, "BORDER")
    cwBorder2:SetSize(350, 2);
    cwBorder2:SetPoint("BOTTOM", ns.checkWin, "BOTTOM", 0, 0);
    cwBorder2:SetColorTexture(r, g, b, 0.8)

    


    local cwCloseBtn = CreateFrame("Button", nil, ns.checkWin, "UIPanelCloseButton")
    cwCloseBtn:SetPoint("TOPRIGHT", ns.checkWin, "TOPRIGHT", -5, -5);
    cwCloseBtn:SetScript("OnClick", function()
        ns.checkWin:Hide()
    end)

    local cwTitle = ns.checkWin:CreateFontString(nil, "OVERLAY")
    cwTitle:SetPoint("TOP", 0, -15);
    ns.SetUIFont(cwTitle, 16, "OUTLINE");
    cwTitle:SetText(L.BTN_CHECK)

    local scrollFrame = CreateFrame("ScrollFrame", nil, ns.checkWin, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 15, -45);
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 15)

    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild);
    scrollChild:SetSize(305, 1)

    local cwText = scrollChild:CreateFontString(nil, "OVERLAY")
    cwText:SetPoint("TOPLEFT", 0, 0);
    cwText:SetWidth(305);
    cwText:SetJustifyH("LEFT");
    ns.SetUIFont(cwText, 13)
    ns.checkWin.content = cwText

    -----------------------------------------------------
    -- MAIN CONFIGURATION WINDOW
    -----------------------------------------------------
    n1mmelGUI = CreateFrame("Frame", "N1mmelUIStandaloneGUI", UIParent)
    n1mmelGUI:SetSize(600, 390);
    n1mmelGUI:SetPoint("CENTER")
    n1mmelGUI:SetMovable(true);
    n1mmelGUI:EnableMouse(true);
    n1mmelGUI:RegisterForDrag("LeftButton")
    n1mmelGUI:SetScript("OnDragStart", n1mmelGUI.StartMoving);
    n1mmelGUI:SetScript("OnDragStop", n1mmelGUI.StopMovingOrSizing)
    n1mmelGUI:SetFrameStrata("DIALOG");
    n1mmelGUI:Hide()
    tinsert(UISpecialFrames, n1mmelGUI:GetName())

    local guiBg = n1mmelGUI:CreateTexture(nil, "BACKGROUND")
    guiBg:SetAllPoints();
    guiBg:SetColorTexture(0.05, 0.05, 0.05, 0.95)

    -- Top Border (in Class Color)
    local topBorder = n1mmelGUI:CreateTexture(nil, "BORDER")
    topBorder:SetSize(600, 2);
    topBorder:SetPoint("TOP", n1mmelGUI, "TOP", 0, 0);
    topBorder:SetColorTexture(r, g, b, 0.8)

    -- Bottom Border (in Class Color)
    local bottomBorder = n1mmelGUI:CreateTexture(nil, "BORDER")
    bottomBorder:SetSize(600, 2);
    bottomBorder:SetPoint("BOTTOM", n1mmelGUI, "BOTTOM", 0, 0);
    bottomBorder:SetColorTexture(r, g, b, 0.8)

    local closeBtn = CreateFrame("Button", nil, n1mmelGUI, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", n1mmelGUI, "TOPRIGHT", -5, -5);
    closeBtn:SetScript("OnClick", function()
        n1mmelGUI:Hide()
    end)

    -----------------------------------------------------
    -- SIDEBAR & NAVIGATION 
    -----------------------------------------------------
    local sidebar = CreateFrame("Frame", nil, n1mmelGUI)
    sidebar:SetSize(140, 390);
    sidebar:SetPoint("TOPLEFT", n1mmelGUI, "TOPLEFT", 0, 0)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints();
    sidebarBg:SetColorTexture(0.1, 0.1, 0.1, 0.5)

    local logo = sidebar:CreateTexture(nil, "OVERLAY")
    logo:SetSize(140, 120);
    logo:SetPoint("TOP", sidebar, "TOP", 0, -3)
    logo:SetTexture("Interface\\AddOns\\n1mmelUI\\media\\images\\nUI1.png")

    local contentArea = CreateFrame("Frame", nil, n1mmelGUI)
    contentArea:SetSize(460, 390);
    contentArea:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 0, 0)

    local pages = {}
    local menuButtons = {}

    local function CreateMenuButton(index, text)
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(140, 30);
        btn:SetPoint("TOP", sidebar, "TOP", 0, -115 - (index * 30))

        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints();
        highlight:SetColorTexture(0.2, 0.2, 0.2, 0.5)

        local activeBg = btn:CreateTexture(nil, "BACKGROUND")
        activeBg:SetAllPoints();
        activeBg:SetColorTexture(0.7412, 0.4863, 0.2118, 0.3);
        activeBg:Hide()
        btn.activeBg = activeBg

        local btnText = btn:CreateFontString(nil, "OVERLAY")
        btnText:SetPoint("LEFT", btn, "LEFT", 15, 0);
        ns.SetUIFont(btnText, 13);
        btnText:SetText(text)
        btn.text = btnText

        menuButtons[index] = btn
        return btn
    end

    local function SelectPage(index)
        for i, page in pairs(pages) do
            if i == index then
                page:Show();
                menuButtons[i].activeBg:Show();
                menuButtons[i].text:SetTextColor(1, 1, 1)
            else
                page:Hide();
                menuButtons[i].activeBg:Hide();
                menuButtons[i].text:SetTextColor(1, 0.82, 0)
            end
        end
    end

    -----------------------------------------------------
    -- BUILD PAGES
    -----------------------------------------------------
    local tabLabels = {L.TAB_SETTINGS, L.TAB_GEAR, L.TAB_PERF, L.TAB_MINIMAP, L.TAB_UI, L.TAB_CHAT, L.TAB_MYTHIC,
                       L.TAB_INFO or "|cff00ffffInfo|r"}
    for i = 1, 8 do
        pages[i] = CreateFrame("Frame", nil, contentArea)
        pages[i]:SetAllPoints()
        local btn = CreateMenuButton(i, tabLabels[i] or ("Tab " .. i))
        btn:SetScript("OnClick", function()
            SelectPage(i)
        end)
    end

    BuildPage1_General(pages[1])
    BuildPage2_Equipment(pages[2])
    BuildPage3_Performance(pages[3])
    BuildPage4_MapMinimap(pages[4])
    BuildPage5_UI(pages[5])
    BuildPage6_Chat(pages[6])
    BuildPage7_Mythic(pages[7])
    BuildPage8_Info(pages[8])

    SelectPage(1)

    ---------------------------------------------------------
    -- SETTINGS CATEGORY (Blizzard Options Menu)
    ---------------------------------------------------------
    local function RegisterBlizzardCategory()
        local categoryFrame = CreateFrame("Frame", "N1mmelUIOptionsCategory", UIParent)
        categoryFrame.name = L.TITLE

        local openBtn = CreateFrame("Button", nil, categoryFrame, "SharedButtonSmallTemplate")
        openBtn:SetSize(160, 32);
        openBtn:SetPoint("TOP", categoryFrame, "TOP", 0, -20);
        openBtn:SetText(L.TITLE)

        openBtn:SetScript("OnClick", function()
            if SettingsPanel then
                SettingsPanel:Hide()
            end
            if n1mmelGUI then
                n1mmelGUI:Show()
            end
        end)

        local category = Settings.RegisterCanvasLayoutCategory(categoryFrame, L.TITLE)
        Settings.RegisterAddOnCategory(category)
    end

    RegisterBlizzardCategory()
end
