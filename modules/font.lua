local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- 1. FONT DEFINITIONS & CACHE
---------------------------------------------------------
-- Table to store all FontStrings managed by n1mmelUI
ns.N1Fonts = {}

-- Available font paths mapped to their database keys
local fontPaths = {
    ["STANDARD"]   = STANDARD_TEXT_FONT,
    ["PTSANS"]     = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\PTSansNarrow.ttf",
    ["EXPRESSWAY"] = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\Expressway.ttf"
}

---------------------------------------------------------
-- 2. FONT ASSIGNMENT
---------------------------------------------------------
-- Applies the globally selected font to a FontString and registers it for future updates
function ns.SetUIFont(fs, size, outline)
    if not fs then return end
    
    -- Store the desired size and outline directly on the FontString object
    fs.n1Size = size or 12
    fs.n1Flags = outline or ""
    
    -- Add it to our tracking table so we can update it later if the user changes the font in the settings
    table.insert(ns.N1Fonts, fs)
    
    -- Determine the correct path from the DB (fallback to STANDARD if DB isn't loaded yet)
    local path = fontPaths[N1mmelUIDB and N1mmelUIDB.globalFont or "STANDARD"] or STANDARD_TEXT_FONT
    fs:SetFont(path, fs.n1Size, fs.n1Flags)
end

---------------------------------------------------------
-- 3. GLOBAL FONT UPDATE
---------------------------------------------------------
-- Iterates through all registered FontStrings and updates their font family instantly
function ns.UpdateAllFonts()
    local path = fontPaths[N1mmelUIDB.globalFont] or STANDARD_TEXT_FONT
    
    for _, fs in ipairs(ns.N1Fonts) do
        -- Safety check to ensure the FontString still exists and is valid before applying
        if fs and type(fs) == "table" and fs.SetFont then
            fs:SetFont(path, fs.n1Size, fs.n1Flags)
        end
    end
end