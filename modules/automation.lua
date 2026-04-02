local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. MERCHANT EVENTS (Auto-Repair & Auto-Sell)
---------------------------------------------------------
local merchantFrame = CreateFrame("Frame")
merchantFrame:RegisterEvent("MERCHANT_SHOW")
merchantFrame:SetScript("OnEvent", function()
    local _, classTag = UnitClass("player")
    local color = RAID_CLASS_COLORS[classTag]
    local classHex = string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
    local prefix = "|c" .. classHex .. "n1mmelUI:|r"

    if N1mmelUIDB.autoSell then
        local profit = 0
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                if itemInfo and itemInfo.quality == 0 and not itemInfo.hasNoValue then
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = C_Item.GetItemInfo(itemInfo.hyperlink)
                    if (sellPrice or 0) > 0 then
                        profit = profit + (sellPrice * itemInfo.stackCount)
                        C_Container.UseContainerItem(bag, slot)
                    end
                end
            end
        end
        if profit > 0 then
            print(prefix .. " " .. (L.SELL_TRASH or "Schrott verkauft für ") ..
                      C_CurrencyInfo.GetCoinTextureString(profit))
        end
    end

    if N1mmelUIDB.autoRepair and CanMerchantRepair() then
        local cost, canRepair = GetRepairAllCost()
        if canRepair and cost > 0 then
            if GetMoney() >= cost then
                RepairAllItems()
                print(prefix .. " " .. (L.REPAIR_GEAR or "Ausrüstung repariert für ") ..
                          C_CurrencyInfo.GetCoinTextureString(cost))
            else
                print(prefix .. " " .. (L.REPAIR_NO_GOLD or "|cFFFF0000Nicht genug Gold zum Reparieren!|r"))
            end
        end
    end
end)

---------------------------------------------------------
-- 2. AUTO CINEMATIC SKIPPER 
---------------------------------------------------------
local cinematicFrame = CreateFrame("Frame")

cinematicFrame:RegisterEvent("CINEMATIC_START")
cinematicFrame:RegisterEvent("PLAY_MOVIE")

cinematicFrame:SetScript("OnEvent", function(self, event)
    if not N1mmelUIDB.skipCinematics then
        return
    end

    if event == "CINEMATIC_START" then
        if CinematicFrame_CancelCinematic then
            CinematicFrame_CancelCinematic()
        end
    elseif event == "PLAY_MOVIE" then
        if MovieFrame then
            MovieFrame:StopMovie()
        end
    end
end)

---------------------------------------------------------
-- 3. FAST DELETE (Midnight Update)
---------------------------------------------------------
local fastDeleteFrame = CreateFrame("Frame")
fastDeleteFrame:RegisterEvent("ADDON_LOADED")
fastDeleteFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == addonName then

        local function FastDeleteSafety(popupFrame)
            -- In Midnight heißt das Feld EditBox (Großbuchstabe)
            if IsShiftKeyDown() and popupFrame.EditBox then
                -- Wir nutzen direkt den globalen String für die Sprache
                popupFrame.EditBox:SetText(DELETE_ITEM_CONFIRM_STRING or "DELETE")
                -- Den Button im neuen ButtonContainer suchen und freischalten
                if popupFrame.button1 then
                    popupFrame.button1:Enable()
                elseif popupFrame.Buttons and popupFrame.Buttons[1] then
                    popupFrame.Buttons[1]:Enable()
                end
            end
        end

        local dialogs = {"DELETE_GOOD_ITEM", "DELETE_GOOD_QUEST_ITEM"}
        for _, dialog in ipairs(dialogs) do
            if StaticPopupDialogs[dialog] then
                hooksecurefunc(StaticPopupDialogs[dialog], "OnShow", function(self)
                    FastDeleteSafety(self)
                end)
            end
        end
    end
end)
