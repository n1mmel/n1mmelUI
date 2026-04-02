local addonName, ns = ...
local L = ns.L

---------------------------------------------------------
-- FONT MANAGEMENT
---------------------------------------------------------
ns.N1Fonts = {}

local fontPaths = {
    ["STANDARD"] = STANDARD_TEXT_FONT,
    ["PTSANS"] = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\PTSansNarrow.ttf",
    ["EXPRESSWAY"] = "Interface\\AddOns\\n1mmelUI\\media\\fonts\\Expressway.ttf"
}

function ns.SetUIFont(fs, size, outline)
    if not fs then
        return
    end
    fs.n1Size = size or 12
    fs.n1Flags = outline or ""
    table.insert(ns.N1Fonts, fs)
    local path = fontPaths[N1mmelUIDB and N1mmelUIDB.globalFont or "STANDARD"] or STANDARD_TEXT_FONT
    fs:SetFont(path, fs.n1Size, fs.n1Flags)
end

function ns.UpdateAllFonts()
    local path = fontPaths[N1mmelUIDB.globalFont] or STANDARD_TEXT_FONT
    for _, fs in ipairs(ns.N1Fonts) do
        if fs then
            fs:SetFont(path, fs.n1Size, fs.n1Flags)
        end
    end
end
