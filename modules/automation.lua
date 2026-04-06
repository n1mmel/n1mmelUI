local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. MERCHANT AUTOMATION (Auto-Repair & Auto-Sell)
---------------------------------------------------------
local merchantFrame = CreateFrame("Frame")
merchantFrame:RegisterEvent("MERCHANT_SHOW")
merchantFrame:SetScript("OnEvent", function()
    -- Get player class color for chat prefix
    local _, classTag = UnitClass("player")
    local color = RAID_CLASS_COLORS[classTag]
    local classHex = string.format("ff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
    local prefix = "|c" .. classHex .. "n1mmelUI:|r"

    -- Auto-Sell Gray Items
    if N1mmelUIDB.autoSell then
        local profit = 0
        -- Iterate through all bags (0-4)
        for bag = 0, 4 do
            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
                -- Check if item exists, is poor quality (0), and has a vendor value
                if itemInfo and itemInfo.quality == 0 and not itemInfo.hasNoValue then
                    local _, _, _, _, _, _, _, _, _, _, sellPrice = C_Item.GetItemInfo(itemInfo.hyperlink)
                    if (sellPrice or 0) > 0 then
                        profit = profit + (sellPrice * itemInfo.stackCount)
                        C_Container.UseContainerItem(bag, slot)
                    end
                end
            end
        end
        -- Print total profit if anything was sold
        if profit > 0 then
            print(prefix .. " " .. (L.SELL_TRASH or "Trash sold for ") .. C_CurrencyInfo.GetCoinTextureString(profit))
        end
    end

    -- Auto-Repair Gear
    if N1mmelUIDB.autoRepair and CanMerchantRepair() then
        local cost, canRepair = GetRepairAllCost()
        if canRepair and cost > 0 then
            if GetMoney() >= cost then
                RepairAllItems()
                print(prefix .. " " .. (L.REPAIR_GEAR or "Gear repaired for ") .. C_CurrencyInfo.GetCoinTextureString(cost))
            else
                print(prefix .. " " .. (L.REPAIR_NO_GOLD or "|cFFFF0000Not enough gold to repair!|r"))
            end
        end
    end
end)

---------------------------------------------------------
-- 2. AUTO CINEMATIC SKIPPER 
---------------------------------------------------------
local cinematicFrame = CreateFrame("Frame")

-- Listen for cinematic and movie triggers
cinematicFrame:RegisterEvent("CINEMATIC_START")
cinematicFrame:RegisterEvent("PLAY_MOVIE")

cinematicFrame:SetScript("OnEvent", function(self, event)
    -- Exit if the feature is disabled in settings
    if not N1mmelUIDB.skipCinematics then
        return
    end

    -- Handle in-game cinematics
    if event == "CINEMATIC_START" then
        if CinematicFrame_CancelCinematic then
            CinematicFrame_CancelCinematic()
        end
    -- Handle pre-rendered movies
    elseif event == "PLAY_MOVIE" then
        if MovieFrame then
            MovieFrame:StopMovie()
        end
    end
end)

---------------------------------------------------------
-- 3. FAST ITEM DELETE (Shift to skip confirmation text)
---------------------------------------------------------
local fastDeleteFrame = CreateFrame("Frame")
fastDeleteFrame:RegisterEvent("ADDON_LOADED")

fastDeleteFrame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == addonName then

        -- Function to automatically fill the "DELETE" text box
        local function FastDeleteSafety(popupFrame)
            -- Check if Shift is held down and the EditBox exists
            if IsShiftKeyDown() and popupFrame.EditBox then
                -- Automatically fill in the localized confirmation string
                popupFrame.EditBox:SetText(DELETE_ITEM_CONFIRM_STRING or "DELETE")
                
                -- Enable the "Yes" button (handles different API versions)
                if popupFrame.button1 then
                    popupFrame.button1:Enable()
                elseif popupFrame.Buttons and popupFrame.Buttons[1] then
                    popupFrame.Buttons[1]:Enable()
                end
            end
        end

        -- Hook into standard deletion dialogs
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