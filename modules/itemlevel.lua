local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- ITEM LEVEL LOGIC (Character, Bags, Bank)
---------------------------------------------------------
local equipSlots = {"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot",
                    "WristSlot", "HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
                    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot"}

local enchantableSlotIDs = {
    [1] = true,
    [3] = true,
    [5] = true,
    [7] = true,
    [8] = true,
    [11] = true,
    [12] = true,
    [16] = true,
    [17] = true
}

local function ApplyItemLevelToButton(button, itemLink, isBag)
    local fontSize = isBag and (N1mmelUIDB.ilvlBagsSize or 13) or (N1mmelUIDB.ilvlCharSize or 13)

    if not button.n1mmelIlvlText then
        button.n1mmelIlvlText = button:CreateFontString(nil, "OVERLAY")
        button.n1mmelIlvlText:SetDrawLayer("OVERLAY", 7)
        button.n1mmelIlvlText:SetPoint("TOP", button, "TOP", 0, -2)
        ns.SetUIFont(button.n1mmelIlvlText, fontSize, "OUTLINE")
    else
        if button.n1mmelIlvlText.n1Size ~= fontSize then
            -- Nutzen der zentralen Font-Funktion aus der core.lua
            ns.SetUIFont(button.n1mmelIlvlText, fontSize, "OUTLINE")
        end
    end

    local textFrame = button.n1mmelIlvlText
    local isEnabled = isBag and N1mmelUIDB.ilvlBags or (not isBag and N1mmelUIDB.ilvlChar)

    if not isEnabled or not itemLink then
        textFrame:SetText("")
        return
    end

    local itemID, _, _, equipLoc, _, classID = C_Item.GetItemInfoInstant(itemLink)
    if not itemID then
        textFrame:SetText("");
        return
    end

    local detailedIlvl = C_Item.GetDetailedItemLevelInfo(itemLink)
    local _, _, quality, baseIlvl = C_Item.GetItemInfo(itemLink)
    local ilvl = detailedIlvl or baseIlvl

    if ilvl and ilvl > 1 and (classID == 2 or classID == 4) and equipLoc ~= "INVTYPE_TABARD" and equipLoc ~=
        "INVTYPE_SHIRT" then
        textFrame:SetText(ilvl)
        if N1mmelUIDB.ilvlColorMode == "WHITE" then
            textFrame:SetTextColor(1, 1, 1)
        elseif N1mmelUIDB.ilvlColorMode == "YELLOW" then
            textFrame:SetTextColor(1, 0.82, 0)
        else
            local r, g, b = C_Item.GetItemQualityColor(quality or 1)
            textFrame:SetTextColor(r, g, b)
        end
    else
        textFrame:SetText("")
    end
end

function ns.UpdateCharacterItemLevels()
    if not CharacterFrame:IsShown() then
        return
    end
    for _, slotName in ipairs(equipSlots) do
        local slotFrame = _G["Character" .. slotName]
        if slotFrame then
            if not slotFrame.n1mmelEnchantWarn then
                slotFrame.n1mmelEnchantWarn = slotFrame:CreateFontString(nil, "OVERLAY")
                slotFrame.n1mmelEnchantWarn:SetDrawLayer("OVERLAY", 7)
                slotFrame.n1mmelEnchantWarn:SetPoint("BOTTOM", slotFrame, "BOTTOM", 0, 2)
                ns.SetUIFont(slotFrame.n1mmelEnchantWarn, 20, "OUTLINE")
            end

            local warnFrame = slotFrame.n1mmelEnchantWarn
            local slotId = slotFrame:GetID()
            local itemLink = GetInventoryItemLink("player", slotId)

            ApplyItemLevelToButton(slotFrame, itemLink, false)

            if N1mmelUIDB.ilvlChar and itemLink then
                if enchantableSlotIDs[slotId] then
                    local enchantID = string.match(itemLink, "item:%d+:(%d*)")
                    if enchantID == "" or enchantID == nil or enchantID == "0" then
                        warnFrame:SetText("|cFFFF0000X|r")
                    else
                        warnFrame:SetText("")
                    end
                else
                    warnFrame:SetText("")
                end
            else
                warnFrame:SetText("")
            end
        end
    end
end
hooksecurefunc("PaperDollItemSlotButton_Update", ns.UpdateCharacterItemLevels)

local function UpdateContainerButton(button, bag, slot)
    if not button then
        return
    end
    slot = slot or button:GetID()
    if not (bag and slot) then
        ApplyItemLevelToButton(button, nil, true)
        return
    end
    local info = C_Container.GetContainerItemInfo(bag, slot)
    ApplyItemLevelToButton(button, info and info.hyperlink, true)
end

function ns.UpdateAllBagButtons(frame)
    if frame and frame.EnumerateValidItems then
        for a, b in frame:EnumerateValidItems() do
            local btn = type(a) == "table" and a or b
            if btn and type(btn) == "table" and btn.GetID then
                UpdateContainerButton(btn, btn:GetBagID(), btn:GetID())
            end
        end
    end
end

function ns.UpdateBagItemLevels()
    if ContainerFrameCombinedBags then
        ns.UpdateAllBagButtons(ContainerFrameCombinedBags)
    end
    if ContainerFrameContainer and ContainerFrameContainer.ContainerFrames then
        for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
            ns.UpdateAllBagButtons(frame)
        end
    end
    local updateBank = function(frame)
        if frame and frame.EnumerateValidItems then
            for a, b in frame:EnumerateValidItems() do
                local btn = type(a) == "table" and a or b
                if btn and type(btn) == "table" and btn.GetID then
                    local bag = btn.GetBankTabID and btn:GetBankTabID() or btn:GetBagID()
                    local slot = btn.GetContainerSlotID and btn:GetContainerSlotID() or btn:GetID()
                    UpdateContainerButton(btn, bag, slot)
                end
            end
        end
    end
    updateBank(_G.BankPanel)
    updateBank(_G.AccountBankPanel)
end

if ContainerFrameCombinedBags then
    hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", ns.UpdateAllBagButtons)
end
if ContainerFrameContainer and ContainerFrameContainer.ContainerFrames then
    for _, frame in ipairs(ContainerFrameContainer.ContainerFrames) do
        hooksecurefunc(frame, "UpdateItems", ns.UpdateAllBagButtons)
    end
end

local function hookBankPanel(panel)
    if not panel then
        return
    end
    local update = function(frame)
        if frame and frame.EnumerateValidItems then
            for a, b in frame:EnumerateValidItems() do
                local btn = type(a) == "table" and a or b
                if btn and type(btn) == "table" and btn.GetID then
                    local bag = btn.GetBankTabID and btn:GetBankTabID() or btn:GetBagID()
                    local slot = btn.GetContainerSlotID and btn:GetContainerSlotID() or btn:GetID()
                    UpdateContainerButton(btn, bag, slot)
                end
            end
        end
    end
    if panel.GenerateItemSlotsForSelectedTab then
        hooksecurefunc(panel, "GenerateItemSlotsForSelectedTab", update)
    end
    if panel.RefreshAllItemsForSelectedTab then
        hooksecurefunc(panel, "RefreshAllItemsForSelectedTab", update)
    end
end

hookBankPanel(_G.BankPanel)
hookBankPanel(_G.AccountBankPanel)

---------------------------------------------------------
-- INSPECT FRAME (Other players)
---------------------------------------------------------
function ns.SetupInspectUI()
    if ns.inspectHooked then
        return
    end

    hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
        if not N1mmelUIDB.ilvlChar then
            return
        end
        local unit = InspectFrame.unit
        if not unit then
            return
        end
        local itemLink = GetInventoryItemLink(unit, button:GetID())
        ApplyItemLevelToButton(button, itemLink, false)
    end)

    local inspectEventFrame = CreateFrame("Frame")
    inspectEventFrame:RegisterEvent("INSPECT_READY")
    inspectEventFrame:SetScript("OnEvent", function(self, event, guid)
        if not N1mmelUIDB.ilvlChar then
            return
        end
        if InspectFrame and InspectFrame:IsShown() and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
            if not InspectPaperDollItemsFrame.n1mmelAvgIlvl then
                InspectPaperDollItemsFrame.n1mmelAvgIlvl = InspectPaperDollItemsFrame:CreateFontString(nil, "OVERLAY")
                InspectPaperDollItemsFrame.n1mmelAvgIlvl:SetPoint("BOTTOM", InspectMainHandSlot, "TOP", 20, 15)
                ns.SetUIFont(InspectPaperDollItemsFrame.n1mmelAvgIlvl, 16, "OUTLINE")
            end

            local ilvl = C_PaperDollInfo.GetInspectItemLevel(InspectFrame.unit)
            if ilvl and ilvl > 0 then
                if N1mmelUIDB.ilvlColorMode == "WHITE" then
                    InspectPaperDollItemsFrame.n1mmelAvgIlvl:SetTextColor(1, 1, 1)
                else
                    InspectPaperDollItemsFrame.n1mmelAvgIlvl:SetTextColor(1, 0.82, 0)
                end
                InspectPaperDollItemsFrame.n1mmelAvgIlvl:SetText("Ø iLvl: " .. math.floor(ilvl))
            else
                InspectPaperDollItemsFrame.n1mmelAvgIlvl:SetText("")
            end

            for _, slotName in ipairs(equipSlots) do
                local slotFrame = _G["Inspect" .. slotName]
                if slotFrame then
                    local itemLink = GetInventoryItemLink(InspectFrame.unit, slotFrame:GetID())
                    ApplyItemLevelToButton(slotFrame, itemLink, false)
                end
            end
        end
    end)
    ns.inspectHooked = true
end

if C_AddOns.IsAddOnLoaded("Blizzard_InspectUI") then
    ns.SetupInspectUI()
else
    local inspectLoader = CreateFrame("Frame")
    inspectLoader:RegisterEvent("ADDON_LOADED")
    inspectLoader:SetScript("OnEvent", function(self, event, addon)
        if addon == "Blizzard_InspectUI" then
            ns.SetupInspectUI()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end

---------------------------------------------------------
-- MANUAL ITEM CHECK (Gem & Enchant Verification)
---------------------------------------------------------
function ns.RunItemCheck()
    local results = {}
    local hasMissing = false

    for _, slotName in ipairs(equipSlots) do
        local slotFrame = _G["Character" .. slotName]
        if slotFrame then
            local slotId = slotFrame:GetID()
            local itemLink = GetInventoryItemLink("player", slotId)
            if itemLink then
                local itemName, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemLink)
                local iconString = icon and ("|T" .. icon .. ":16|t ") or ""

                if enchantableSlotIDs[slotId] then
                    local enchantID = string.match(itemLink, "item:%d+:(%d*)")
                    if enchantID == "" or enchantID == nil or enchantID == "0" then
                        table.insert(results, iconString .. itemLink .. ": |cFFFF0000" .. L.MISSING_ENCHANT .. "|r")
                        hasMissing = true
                    end
                end

                local stats = C_Item.GetItemStats(itemLink)
                local totalSockets = 0
                if stats then
                    for statName, value in pairs(stats) do
                        if string.find(statName, "EMPTY_SOCKET") then
                            totalSockets = totalSockets + value
                        end
                    end
                end

                if totalSockets > 0 then
                    local parts = {strsplit(":", itemLink)}
                    local filledGems = 0
                    for i = 4, 7 do
                        if parts[i] and parts[i] ~= "" and parts[i] ~= "0" then
                            filledGems = filledGems + 1
                        end
                    end

                    if filledGems < totalSockets then
                        local missing = totalSockets - filledGems
                        table.insert(results, iconString .. itemLink .. ": |cFFFF0000" .. missing .. " " ..
                            L.MISSING_GEM .. "|r")
                        hasMissing = true
                    end
                end
            end
        end
    end

    if not hasMissing then
        table.insert(results, "|cFF00FF00" .. L.ALL_PERFECT .. "|r")
    end

    if N1mmelUIDB.checkOutput == "WINDOW" and ns.checkWin then
        ns.checkWin.content:SetText(table.concat(results, "\n\n"))
        ns.checkWin:Show()
    else
        local _, classTag = UnitClass("player")
        local color = RAID_CLASS_COLORS[classTag]
        local classHex = string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

        print("|c" .. classHex .. "\n[ n1mmelUI ]\n|r")
        print("|cFFFFFFFF  " .. L.BTN_CHECK .. ":|r")
        print(" ")
        for _, line in ipairs(results) do
            print("  |cFF00FFFF•|r " .. line)
        end
        print(" ")
    end
end

---------------------------------------------------------
-- PLAYER AVERAGE ITEM LEVEL (Character Frame)
---------------------------------------------------------
hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unit)
    if unit == "player" then
        local _, avgIlvlEquipped = GetAverageItemLevel()
        if avgIlvlEquipped and statFrame.Value then
            statFrame.Value:SetText(string.format("%.2f", avgIlvlEquipped))
        end
        ns.SetUIFont(statFrame.Value, N1mmelUIDB.ilvlCharSize or 13, "OUTLINE")
    end
end)
