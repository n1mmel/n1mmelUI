local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. MINIMAP SHAPE & MASK
---------------------------------------------------------
-- Overwrite the global function so addons like SexyMap/GatherMate know our shape
function _G.GetMinimapShape()
    return (N1mmelUIDB and N1mmelUIDB.squareMinimap) and "SQUARE" or "ROUND"
end

---------------------------------------------------------
-- 2. WORLD MAP COORDINATES
---------------------------------------------------------
local coordsFrame = CreateFrame("Frame", "n1mmelMapCoords", WorldMapFrame)
coordsFrame:SetSize(280, 25)
coordsFrame:SetFrameStrata("TOOLTIP")

local bg = coordsFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.7)

local coordsText = coordsFrame:CreateFontString(nil, "OVERLAY")
coordsText:SetPoint("CENTER")
if ns.SetUIFont then ns.SetUIFont(coordsText, 14, "OUTLINE") end

coordsFrame:SetScript("OnUpdate", function()
    if not WorldMapFrame:IsShown() then return end
    
    local mapID = WorldMapFrame:GetMapID()
    if not mapID then return end
    
    local pX, pY = 0, 0
    local playerPos = C_Map.GetPlayerMapPosition(mapID, "player")
    if playerPos then
        pX, pY = playerPos:GetXY()
    end
    
    local cX, cY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
    if not cX or not cY or cX < 0 or cX > 1 or cY < 0 or cY > 1 then
        cX, cY = 0, 0
    end

    local pT = playerPos and string.format("%.1f, %.1f", pX * 100, pY * 100) or "--"
    local cT = (cX > 0 or cY > 0) and string.format("%.1f, %.1f", cX * 100, cY * 100) or "--"
    coordsText:SetText(string.format("%s: %s | %s: %s", L.PLAYER or "Player", pT, L.CURSOR or "Cursor", cT))
end)

function ns.UpdateCoordPosition()
    coordsFrame:ClearAllPoints()
    if N1mmelUIDB.coordPos == "TOPLEFT" then
        coordsFrame:SetPoint("TOPLEFT", WorldMapFrame, 15, -70)
    elseif N1mmelUIDB.coordPos == "TOPRIGHT" then
        coordsFrame:SetPoint("TOPRIGHT", WorldMapFrame, -35, -70)
    elseif N1mmelUIDB.coordPos == "BOTTOMLEFT" then
        coordsFrame:SetPoint("BOTTOMLEFT", WorldMapFrame, 15, 15)
    elseif N1mmelUIDB.coordPos == "BOTTOMRIGHT" then
        coordsFrame:SetPoint("BOTTOMRIGHT", WorldMapFrame, -35, 15)
    end
end

function ns.UpdateMapCoordsVisibility()
    if N1mmelUIDB.showMapCoords then
        coordsFrame:Show()
    else
        coordsFrame:Hide()
    end
end

---------------------------------------------------------
-- 3. MINIMAP COORDINATES
---------------------------------------------------------
ns.mmCoordsFrame = CreateFrame("Frame", "n1mmelMinimapCoords", Minimap)
ns.mmCoordsFrame:SetSize(80, 20)

local mmBg = ns.mmCoordsFrame:CreateTexture(nil, "BACKGROUND")
mmBg:SetAllPoints()
mmBg:SetColorTexture(0, 0, 0, 0.6)

local mmText = ns.mmCoordsFrame:CreateFontString(nil, "OVERLAY")
mmText:SetPoint("CENTER")
if ns.SetUIFont then ns.SetUIFont(mmText, 13, "OUTLINE") end

local mmTimer = 0
ns.mmCoordsFrame:SetScript("OnUpdate", function(self, elapsed)
    mmTimer = mmTimer + elapsed
    if mmTimer >= 0.2 then
        mmTimer = 0
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local pos = C_Map.GetPlayerMapPosition(mapID, "player")
            if pos then
                local x, y = pos:GetXY()
                mmText:SetText(string.format("%.1f, %.1f", x * 100, y * 100))
            else
                mmText:SetText("--, --")
            end
        else
            mmText:SetText("--, --")
        end
    end
end)

---------------------------------------------------------
-- 4. MINIMAP SCROLL ZOOM
---------------------------------------------------------
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
    N1mmelUIDB.minimapZoom = Minimap:GetZoom()
end)

hooksecurefunc(Minimap, "SetZoom", function()
    if N1mmelUIDB then
        N1mmelUIDB.minimapZoom = Minimap:GetZoom()
    end
end)

---------------------------------------------------------
-- 5. MINIMAP STYLING (Square vs. Round)
---------------------------------------------------------
local mmBorder = CreateFrame("Frame", "n1mmelMinimapBorder", Minimap, "BackdropTemplate")
mmBorder:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
mmBorder:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -2)
mmBorder:SetFrameStrata("BACKGROUND")
mmBorder:SetFrameLevel(Minimap:GetFrameLevel() - 1)

local squareBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    edgeSize = 2,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

function ns.UpdateMinimapStyle()
    -- Hide default Zoom buttons regardless of style
    if Minimap.ZoomIn then Minimap.ZoomIn:Hide(); Minimap.ZoomIn:SetAlpha(0) end
    if Minimap.ZoomOut then Minimap.ZoomOut:Hide(); Minimap.ZoomOut:SetAlpha(0) end
    if _G.MinimapZoomIn then _G.MinimapZoomIn:Hide(); _G.MinimapZoomIn:SetAlpha(0) end
    if _G.MinimapZoomOut then _G.MinimapZoomOut:Hide(); _G.MinimapZoomOut:SetAlpha(0) end

    if N1mmelUIDB.squareMinimap then
        -- Square Style
        if _G.MinimapBorder then _G.MinimapBorder:Hide() end
        if _G.MinimapBorderTop then _G.MinimapBorderTop:Hide() end
        if _G.MinimapNorthTag then _G.MinimapNorthTag:Hide() end
        if _G.MinimapZoneTextButton then _G.MinimapZoneTextButton:Hide() end
        if _G.MinimapCompassTexture then _G.MinimapCompassTexture:Hide() end

        Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
        Minimap:SetSize(190, 190)

        mmBorder:SetBackdrop(squareBackdrop)
        mmBorder:SetBackdropColor(0, 0, 0, 0.7)
        mmBorder:SetBackdropBorderColor(0.15, 0.15, 0.15, 1)
        mmBorder:Show()

        ns.mmCoordsFrame:ClearAllPoints()
        ns.mmCoordsFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 5)
    else
        -- Round Style (Default)
        if _G.MinimapBorder then _G.MinimapBorder:Show() end
        if _G.MinimapBorderTop then _G.MinimapBorderTop:Show() end
        if _G.MinimapNorthTag then _G.MinimapNorthTag:Show() end
        if _G.MinimapZoneTextButton then _G.MinimapZoneTextButton:Show() end
        if _G.MinimapCompassTexture then _G.MinimapCompassTexture:Show() end

        Minimap:SetMaskTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        Minimap:SetSize(190, 190)

        mmBorder:Hide()
        ns.mmCoordsFrame:ClearAllPoints()
        ns.mmCoordsFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -35)
    end

    -- Force minimap texture update via zoom bounce trick
    local savedZoom = N1mmelUIDB.minimapZoom or 0
    local tempZoom = (savedZoom > 0) and (savedZoom - 1) or (savedZoom + 1)
    Minimap:SetZoom(tempZoom)
    Minimap:SetZoom(savedZoom)
end