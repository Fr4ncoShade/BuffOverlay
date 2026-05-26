---@class BuffOverlay: AceModule
BuffOverlay = LibStub("AceAddon-3.0"):NewAddon(
    "BuffOverlay",
    "AceConsole-3.0",
    "AceTimer-3.0"
)

local GetSpellInfo = GetSpellInfo

-- Localization Table
BuffOverlay.L = {}

-- Make missing translations available
setmetatable(BuffOverlay.L, {__index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end})

-- Definitions
BuffOverlay.GetSpellInfo = GetSpellInfo

--[[
BuffOverlay.GetSpellInfo = function(spell)
    if not spell then
        return nil
    end

    return GetSpellInfo(spell)
end
]]

-- Initialize a spells table so a new game version doesn't break the addon.
BuffOverlay.defaultSpells = {}


