local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. WHISPER ALERTS (Sound Notifications)
---------------------------------------------------------
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

local whisperEventFrame = CreateFrame("Frame")
whisperEventFrame:RegisterEvent("CHAT_MSG_WHISPER")
whisperEventFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")

whisperEventFrame:SetScript("OnEvent", function(self, event, ...)
    -- Exit if whisper alerts are disabled in settings
    if not N1mmelUIDB.whisperAlert then
        return
    end

    local soundFile = soundPaths[N1mmelUIDB.whisperSound or "Bell"]
    if soundFile then
        -- Play on the "Master" channel to ensure it's heard even if SFX is low
        PlaySoundFile(soundFile, "Master")
    end
end)

---------------------------------------------------------
-- 2. CHAT CLASS COLORS
---------------------------------------------------------
function ns.UpdateChatClassColors()
    -- List of all chat types that should be colored by class
    local types = {
        "SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "PARTY", "PARTY_LEADER", 
        "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", 
        "WHISPER", "WHISPER_INFORM"
    }
    
    for _, chatType in ipairs(types) do
        -- Applies the boolean setting from the database to the Blizzard API
        SetChatColorNameByClass(chatType, N1mmelUIDB.chatClassColors)
    end
end

---------------------------------------------------------
-- 3. URL POPUP FRAME (Copy Window)
---------------------------------------------------------
-- Create the hidden popup window for copying links
local urlPopup = CreateFrame("Frame", "N1mmelURLPopup", UIParent, "BasicFrameTemplateWithInset")
urlPopup:SetSize(350, 100)
urlPopup:SetPoint("CENTER")
urlPopup:SetFrameStrata("DIALOG")
urlPopup:Hide()

urlPopup.title = urlPopup:CreateFontString(nil, "OVERLAY")
urlPopup.title:SetFontObject("GameFontHighlight")
urlPopup.title:SetPoint("TOP", 0, -8)
urlPopup.title:SetText(L.URL_COPY_TEXT or "Copy Link (Ctrl+C)")

local urlEditBox = CreateFrame("EditBox", nil, urlPopup, "InputBoxTemplate")
urlEditBox:SetHeight(30)
urlEditBox:SetPoint("LEFT", 20, -15)
urlEditBox:SetPoint("RIGHT", -20, -15)
urlEditBox:SetAutoFocus(true)
urlEditBox:SetFontObject("ChatFontNormal")

-- Close the window when pressing Escape
urlEditBox:SetScript("OnEscapePressed", function(self)
    urlPopup:Hide()
end)

-- Auto-highlight the text when the window opens
urlPopup:SetScript("OnShow", function()
    urlEditBox:SetFocus()
    urlEditBox:HighlightText()
end)

-- Prevent the user from accidentally typing into the box and altering the URL
urlEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        self:SetText(self.currentURL or "")
        self:HighlightText()
    end
end)

---------------------------------------------------------
-- 4. CHAT MESSAGE HOOK (Short Channels & URLs)
---------------------------------------------------------
function ns.SetupChatModifications()
    -- Compatibility fallback for Blizzard's secret value censorship
    local issecret = issecretvalue or function() return false end
    -- NUM_CHAT_WINDOWS is the correct global in modern WoW; fallback to 10
    local numFrames = NUM_CHAT_WINDOWS or 10

    for i = 1, numFrames do
        local frame = _G["ChatFrame" .. i]
        -- Only hook frames that haven't been hooked yet and have a valid AddMessage
        if frame and not frame.n1OriginalAddMessage and type(frame.AddMessage) == "function" then
            -- Store the original function safely before overwriting
            frame.n1OriginalAddMessage = frame.AddMessage

            frame.AddMessage = function(self, text, r, g, b, id)
                -- Only process valid, non-secret string messages
                -- Also guard against N1mmelUIDB not being ready
                if N1mmelUIDB and type(text) == "string" and not issecret(text) then

                    -- 4a. Shorten Channel Names
                    if N1mmelUIDB.shortChannels then
                        -- Compress custom channel numbers (e.g. "[1. General]" to "[1]")
                        text = text:gsub("|Hchannel:(.-)|h%[(%d+)%.%s*(.-)%]|h", "|Hchannel:%1|h[%2]|h")

                        -- Shorten standard Blizzard channels using localization
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_GUILD or "Guild") .. "%]|h", "|Hchannel:%1|h[G]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_PARTY or "Party") .. "%]|h", "|Hchannel:%1|h[P]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_PARTY_LEADER or "Party Leader") .. "%]|h", "|Hchannel:%1|h[PL]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID or "Raid") .. "%]|h", "|Hchannel:%1|h[R]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID_LEADER or "Raid Leader") .. "%]|h", "|Hchannel:%1|h[RL]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID_WARNING or "Raid Warning") .. "%]|h", "|Hchannel:%1|h[RW]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_OFFICER or "Officer") .. "%]|h", "|Hchannel:%1|h[O]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_INSTANCE or "Instance") .. "%]|h", "|Hchannel:%1|h[I]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_INSTANCE_LEADER or "Instance Leader") .. "%]|h", "|Hchannel:%1|h[IL]|h")
                    end

                    -- 4b. Format Web URLs to be clickable
                    if N1mmelUIDB.chatURLs then
                        text = text:gsub("(%s)(https?://[%w_/%.%?=&%-]+)", "%1|Hn1url:%2|h|cFF00FFFF[%2]|r|h")
                        text = text:gsub("(%s)(www%.[%w_/%.%?=&%-]+)", "%1|Hn1url:%2|h|cFF00FFFF[%2]|r|h")
                        text = text:gsub("^(https?://[%w_/%.%?=&%-]+)", "|Hn1url:%1|h|cFF00FFFF[%1]|r|h")
                        text = text:gsub("^(www%.[%w_/%.%?=&%-]+)", "|Hn1url:%1|h|cFF00FFFF[%1]|r|h")
                    end
                end

                -- Always call the original Blizzard function
                return self.n1OriginalAddMessage(self, text, r, g, b, id)
            end
        end
    end
end

---------------------------------------------------------
-- 5. URL CLICK HANDLER
---------------------------------------------------------
-- Hook into Blizzard's item link clicking system
hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    -- If the clicked link is our custom "n1url", open the copy popup
    if link and string.sub(link, 1, 5) == "n1url" then
        local url = string.sub(link, 7)
        urlEditBox.currentURL = url
        urlEditBox:SetText(url)
        urlPopup:Show()
    end
end)