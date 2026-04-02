local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- WHISPER ALERTS
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
    if not N1mmelUIDB.whisperAlert then
        return
    end

    local soundFile = soundPaths[N1mmelUIDB.whisperSound or "Bell"]
    if soundFile then
        -- We play on "Master" channel to ensure it's heard even if SFX is low
        PlaySoundFile(soundFile, "Master")
    end
end)

---------------------------------------------------------
-- CHAT IMPROVEMENTS (Vanilla+ Features)
---------------------------------------------------------
-- 1. Classcolor
function ns.UpdateChatClassColors()
    local types = {"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER",
                   "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "WHISPER", "WHISPER_INFORM"}
    for _, chatType in ipairs(types) do
        SetChatColorNameByClass(chatType, N1mmelUIDB.chatClassColors)
    end
end

-- 2. Popup-Window for URLs
local urlPopup = CreateFrame("Frame", "N1mmelURLPopup", UIParent, "BasicFrameTemplateWithInset")
urlPopup:SetSize(350, 100)
urlPopup:SetPoint("CENTER")
urlPopup:SetFrameStrata("DIALOG")
urlPopup:Hide()

urlPopup.title = urlPopup:CreateFontString(nil, "OVERLAY")
urlPopup.title:SetFontObject("GameFontHighlight")
urlPopup.title:SetPoint("TOP", 0, -8)
urlPopup.title:SetText(L.URL_COPY_TEXT or "Link kopieren (Strg+C)")

local urlEditBox = CreateFrame("EditBox", nil, urlPopup, "InputBoxTemplate")
urlEditBox:SetHeight(30)
urlEditBox:SetPoint("LEFT", 20, -15)
urlEditBox:SetPoint("RIGHT", -20, -15)
urlEditBox:SetAutoFocus(true)
urlEditBox:SetFontObject("ChatFontNormal")

urlEditBox:SetScript("OnEscapePressed", function(self)
    urlPopup:Hide()
end)
urlPopup:SetScript("OnShow", function()
    urlEditBox:SetFocus()
    urlEditBox:HighlightText()
end)
urlEditBox:SetScript("OnTextChanged", function(self, userInput)
    if userInput then
        self:SetText(self.currentURL or "")
        self:HighlightText()
    end
end)

-- 3. Chat-Hook for short channelnames & URLs
function ns.SetupChatModifications()
    local issecret = issecretvalue or function()
        return false
    end

    local NUM_CHAT_FRAMES = NUM_CHAT_WINDOWS or 10
    for i = 1, NUM_CHAT_FRAMES or 10 do
        local frame = _G["ChatFrame" .. i]
        if frame then
            if not frame.n1OriginalAddMessage then
                frame.n1OriginalAddMessage = frame.AddMessage
            end

            frame.AddMessage = function(self, text, r, g, b, id)
                if type(text) == "string" and not issecret(text) then

                    if N1mmelUIDB.shortChannels then
                        text = text:gsub("|Hchannel:(.-)|h%[(%d+)%.%s*(.-)%]|h", "|Hchannel:%1|h[%2]|h")

                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_GUILD or "Guild") .. "%]|h",
                            "|Hchannel:%1|h[G]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_PARTY or "Party") .. "%]|h",
                            "|Hchannel:%1|h[P]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_PARTY_LEADER or "Party Leader") .. "%]|h",
                            "|Hchannel:%1|h[PL]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID or "Raid") .. "%]|h",
                            "|Hchannel:%1|h[R]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID_LEADER or "Raid Leader") .. "%]|h",
                            "|Hchannel:%1|h[RL]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_RAID_WARNING or "Raid Warning") .. "%]|h",
                            "|Hchannel:%1|h[RW]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_OFFICER or "Officer") .. "%]|h",
                            "|Hchannel:%1|h[O]|h")
                        text = text:gsub("|Hchannel:(.-)|h%[" .. (L.CHAT_INSTANCE or "Instance") .. "%]|h",
                            "|Hchannel:%1|h[I]|h")
                        text = text:gsub(
                            "|Hchannel:(.-)|h%[" .. (L.CHAT_INSTANCE_LEADER or "Instance Leader") .. "%]|h",
                            "|Hchannel:%1|h[IL]|h")
                    end

                    -- URLs klickbar machen
                    if N1mmelUIDB.chatURLs then
                        text = text:gsub("(%s)(https?://[%w_/%.%?=&%-]+)", "%1|Hn1url:%2|h|cFF00FFFF[%2]|r|h")
                        text = text:gsub("(%s)(www%.[%w_/%.%?=&%-]+)", "%1|Hn1url:%2|h|cFF00FFFF[%2]|r|h")
                        text = text:gsub("^(https?://[%w_/%.%?=&%-]+)", "|Hn1url:%1|h|cFF00FFFF[%1]|r|h")
                        text = text:gsub("^(www%.[%w_/%.%?=&%-]+)", "|Hn1url:%1|h|cFF00FFFF[%1]|r|h")
                    end
                end

                return self.n1OriginalAddMessage(self, text, r, g, b, id)
            end
        end
    end
end

-- 4. Click URL Hook
hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    if link and string.sub(link, 1, 5) == "n1url" then
        local url = string.sub(link, 7)
        urlEditBox.currentURL = url
        urlEditBox:SetText(url)
        urlPopup:Show()
    end
end)
