local addonName, ns = ...

---------------------------------------------------------
-- CURSOR ENHANCER
-- A clean, lightweight ring around the mouse cursor.
-- Uses the same positioning technique as CursorRing addon.
-- Color: class color or white (configurable in GUI).
---------------------------------------------------------

local cursorFrame = CreateFrame("Frame", "N1mmelCursorFrame", UIParent)
cursorFrame:SetSize(48, 48)
cursorFrame:SetFrameStrata("TOOLTIP")
cursorFrame:SetFrameLevel(100)
cursorFrame:EnableMouse(false)
cursorFrame:SetClampedToScreen(false)
cursorFrame:Hide()

local ring = cursorFrame:CreateTexture(nil, "OVERLAY")
ring:SetAllPoints(cursorFrame)
ring:SetTexture("Interface\\AddOns\\n1mmelUI\\media\\images\\thin_ring.tga")
ring:SetBlendMode("ADD")

-- Cache UIParent rect for accurate positioning (CursorRing technique)
local cachedUILeft, cachedUIBottom = nil, nil

local function ApplyCursorColor()
    if not N1mmelUIDB then return end
    local mode = N1mmelUIDB.cursorColorMode
    if mode == "WHITE" then
        ring:SetVertexColor(1, 1, 1, 1.0)
    else
        -- Default: class color
        local c = ns.classColor or { r = 1, g = 1, b = 1 }
        ring:SetVertexColor(c.r, c.g, c.b, 1.0)
    end
end

---------------------------------------------------------
-- MOVEMENT: CursorRing accurate positioning
---------------------------------------------------------
cursorFrame:SetScript("OnUpdate", function(self, elapsed)
    if not cachedUILeft then
        cachedUILeft, cachedUIBottom = UIParent:GetRect()
    end
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    x = x / scale - cachedUILeft
    y = y / scale - cachedUIBottom
    self:ClearAllPoints()
    self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end)

local scaleFrame = CreateFrame("Frame")
scaleFrame:RegisterEvent("UI_SCALE_CHANGED")
scaleFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
scaleFrame:SetScript("OnEvent", function()
    cachedUILeft, cachedUIBottom = nil, nil
end)

---------------------------------------------------------
-- PUBLIC API
---------------------------------------------------------
function ns.UpdateCursorEnhancer()
    if not N1mmelUIDB then return end
    if N1mmelUIDB.cursorEnhancer then
        ApplyCursorColor()
        cursorFrame:Show()
    else
        cursorFrame:Hide()
    end
end

---------------------------------------------------------
-- INIT
---------------------------------------------------------
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    ns.UpdateCursorEnhancer()
end)