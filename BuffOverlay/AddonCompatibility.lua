---@class BuffOverlay: AceModule
local BuffOverlay = LibStub("AceAddon-3.0"):GetAddon("BuffOverlay")


local pairs, IsAddOnLoaded, next, type = pairs, IsAddOnLoaded, next, type
local addOnsExist = true
local enabledPatterns = {}
local framesToFind = {}
local tempFrameCache = {}

BuffOverlay.frames = {}

--[[ addonFrameInfo

    key:    The name of the addon. This key checked with IsAddOnLoaded, so it must match the name of the
            addon's .toc file exactly.

    frame:  The pattern to match the frame name against. Be as specific as possible, preferrably with beginnings (^)
            and endings ($) as we want to minimize the number of frames we need to process and avoid attaching
            to incorrect frames.

    type:   The filter type of frame. This is used to determine which bars to show/hide when the user changes
            visibility settings.

            Current valid types are "arena", "raid", "party", "pet", "tank", "assist", and "player". If adding more types,
            be sure to update the defaultBarSettings table in BuffOverlay.lua.

    unit:   The name of the key that the addon uses to identify the frame's corresponding displayed unit.
]]
local addonFrameInfo = {
    ["ElvUI"] = {
        {
            frame = "^ElvUF_Raid%d+Group%dUnitButton%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^ElvUF_PartyGroup1UnitButton%d+$",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^ElvUF_RaidpetGroup%dUnitButton%d+$",
            type = "pet",
            unit = "unit",
        },
        {
            frame = "^ElvUF_TankUnitButton%d$",
            type = "tank",
            unit = "unit",
        },
        {
            frame = "^ElvUF_AssistUnitButton%d$",
            type = "assist",
            unit = "unit",
        },
    },
    ["VuhDo"] = {
        {
            --frame = "^Vd%dH%d+$",
			frame = "^Vd",
            type = "raid",
            unit = "raidid",
        },
    },
    ["Grid"] = {
        {
            frame = "^GridLayout",
            type = "raid",
            unit = "unit",
        },
    },
    ["Grid2"] = {
        {
            frame = "^Grid2Layout",
            type = "raid",
            unit = "unit",
        },
    },
    ["HealBot"] = {
        {
            frame = "^HealBot_Action_HealUnit%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^HealBot_HealUnit%d+$",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^hbTest_HealUnit%d+$",
            type = "raid",
            unit = "unit",
        },
    },
    ["Cell"] = {
        {
            frame = "^CellRaidFrameHeader%d+UnitButton%d+$",
            type = "raid",
            unit = "unitid",
        },
        {
            frame = "^CellPartyFrameHeaderUnitButton%d+$",
            type = "party",
            unit = "unitid",
        },
        {
            frame = "^CellRaidFrameHeader%d+UnitButton%d+Pet$",
            type = "pet",
            unit = "unitid",
        },
        {
            frame = "^CellPartyFrameHeaderUnitButton%d+Pet$",
            type = "pet",
            unit = "unitid",
        },
        {
            frame = "^CellSoloFramePlayer$",
            -- type = "solo",
            type = "party",
            unit = "unitid",
        },
        {
            frame = "^CellSoloFramePet$",
            type = "pet",
            unit = "unitid",
        },
    },
    ["Aptechka"] = {
        {
            frame = "^NugRaid%d+UnitButton%d+",
            type = "raid",
            unit = "unit",
        },
    },
    ["Tukui"] = {
        {
            frame = "TuikuiPartyUnitButton",
            type = "party",
            unit = "unit",
        },
        {
            frame = "TukuiRaidUnitButton",
            type = "raid",
            unit = "unit",
        },
    },
    ["ShadowedUnitFrames"] = {
        {
            frame = "^SUFHeaderraidUnitButton",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^SUFHeaderraid%dUnitButton",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^SUFHeaderpartyUnitButton",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^SUFUnitplayer$",
            type = "player",
            unit = "unit",
        },
    },
    ["ZPerl"] = {
        {
            frame = "^XPerl_Raid",
            type = "raid",
            unit = "partyid",
        },
    },
    ["PitBull4"] = {
        {
            frame = "^PitBull4_Groups_Party",
            type = "raid",
            unit = "unit",
        },
    },
    ["oUF"] = {
        {
            frame = "^oUF_.-Party",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^oUF_.-Raid",
            type = "raid",
            unit = "unit",
        },
    },
    ["LunaUnitFrames"] = {
        {
            frame = "^LUFHeaderpartyUnitButton%d+",
            type = "party",
            unit = "unit",
        },
        {
            frame = "^LUFHeaderraid%d+UnitButton%d+",
            type = "raid",
            unit = "unit",
        },
        {
            frame = "^LUFHeadermaintankUnitButton%d+",
            type = "tank",
            unit = "unit",
        },
    },
}
--[[
local blizzardFrameInfo = {
    {
        frame = "^CompactRaidGroup%d+Member%d+$",
        type = "raid",
        unit = "displayedUnit",
    },
    {
        frame = "^CompactRaidFrame%d+$",
        type = "raid",
        unit = "displayedUnit",
    },
    {
        frame = "^CompactPartyFrameMember%d+$",
        type = "party",
        unit = "displayedUnit",
    },
    {
        frame = "^CompactPartyFramePet%d+$",
        type = "pet",
        unit = "displayedUnit",
    },
    {
        frame = "^CompactArenaFrameMember%d+$",
        type = "arena",
        unit = "displayedUnit",
    },
    {
        frame = "^CompactArenaFramePet%d+$",
        type = "pet",
        unit = "displayedUnit",
    },
}
]]
local blizzardFrameInfo = {
	{
		frame = "^PlayerFrame",
		type = "player",
		unit = "unit",
	},

    {
        frame = "^PartyMemberFrame%d+$",
        type = "party",
        unit = "unit",
    },
    {
        frame = "^PartyMemberFrame%dPetFrame$",
        type = "pet",
        unit = "unit",
    },
    {
        frame = "^RaidGroupButton%d+$",
        type = "raid",
        unit = "unit",
    },
}

local function AddOnsExist()
    local addonsExist = false
    for addon, info in pairs(addonFrameInfo) do
        if IsAddOnLoaded(addon) then
            for _, frameInfo in pairs(info) do
                enabledPatterns[frameInfo.frame] = { unit = frameInfo.unit, type = frameInfo.type }
            end

            if not addonsExist then
                addonsExist = true
            end

            -- Fix for ElvUI Party Pet Frames. They are not in the frame cache due
            -- to the way ElvUI creates them. This is unique to party pets, thankfully.
            if addon == "ElvUI" then
                for i = 1, 5 do
                    framesToFind["ElvUF_PartyGroup1UnitButton" .. i .. "Pet"] = { unit = "unit", type = "pet" }
                end
            end
        end
    end

    addOnsExist = addonsExist
    BuffOverlay.addons = addonsExist
    return addonsExist
end

local function cleanFrameCache()
    for frame, name in pairs(tempFrameCache) do
        for addOnFramePattern, data in pairs(enabledPatterns) do
            if name:match(addOnFramePattern) then
                BuffOverlay.frames[frame] = { unit = data.unit, type = data.type }
                break
            end
        end

        tempFrameCache[frame] = nil
    end
end

local function updateUnits()
    cleanFrameCache()

    if next(framesToFind) ~= nil then
        for f, data in pairs(framesToFind) do
            local frame = _G[f]
            if frame and not BuffOverlay.frames[frame] then
                BuffOverlay.frames[frame] = { unit = data.unit, type = data.type }
                framesToFind[f] = nil
            end
        end
    end

    for frame, data in pairs(BuffOverlay.frames) do
        local unit = frame[data.unit] or SecureButton_GetUnit(frame)

        if unit and not data.blizz then
            BuffOverlay:AddUnitFrame(frame, unit)
        end
    end
    BuffOverlay:RefreshOverlays()
end

function BuffOverlay:UpdateUnits()
    if not addOnsExist then return end

    updateUnits()
    self:ScheduleTimer(updateUnits, 1)
end

function BuffOverlay:InitFrames()
    self:ScheduleTimer(function()
        if AddOnsExist() then
            self.eventHandler:RegisterEvent("UNIT_EXITED_VEHICLE")
            self.eventHandler:RegisterEvent("UNIT_ENTERED_VEHICLE")

            self:UpdateUnits()
        end
    end, 0.1)
end

--=====================
local function RegisterBlizzardFrames()
    -- PLAYER FRAME
	if PlayerFrame then
		BuffOverlay.frames[PlayerFrame] = {
			unit = "player",
			type = "player",
			blizz = true,
		}

		BuffOverlay.blizzFrames[PlayerFrame] = true

		BuffOverlay:AddUnitFrame(PlayerFrame, "player")
	end

    -- PARTY FRAMES
    for i = 1, 4 do
        local frame = _G["PartyMemberFrame"..i]

        if frame then
            BuffOverlay.frames[frame] = {
                unit = "party"..i,
                type = "party",
                blizz = true,
            }

            BuffOverlay.blizzFrames[frame] = true
			BuffOverlay:AddUnitFrame(frame, "party"..i)
        end

        -- PARTY PET FRAMES
        local petFrame = _G["PartyMemberFrame"..i.."PetFrame"]

        if petFrame then
            BuffOverlay.frames[petFrame] = {
                unit = "partypet"..i,
                type = "pet",
                blizz = true,
            }

            BuffOverlay.blizzFrames[petFrame] = true
			BuffOverlay:AddUnitFrame(petFrame, "partypet"..i)
        end
    end

    -- RAID FRAMES
    for i = 1, 40 do
        local frame = _G["RaidGroupButton"..i]

        if frame then
            BuffOverlay.frames[frame] = {
                unit = "raid"..i,
                type = "raid",
                blizz = true,
            }

            BuffOverlay.blizzFrames[frame] = true
			BuffOverlay:AddUnitFrame(frame, "raid"..i)
        end
    end
end

-- We obtain frame references entirely from this CreateFrame hook.
-- If an addon does not give the frames they create a unique name,
-- we cannot get the reference here and therefore it needs to be
-- handled on an addon-specific basis.
hooksecurefunc("CreateFrame", function(frameType, frameName)
    if not addOnsExist then return end
    if not frameName then return end
    if frameType ~= "Button" then return end

    -- Ignore BuffOverlay internal bars
    if frameName:find("BuffOverlayBar") then
        return
    end

    local frame = _G[frameName]

    if frame and type(frame) == "table" then
        tempFrameCache[frame] = frameName
    end
end)

-- Blizzard frames are not reliably obtainable through CreateFrame hooks,
-- so we register them directly after the default UI has loaded.
local blizzLoader = CreateFrame("Frame")
	blizzLoader:RegisterEvent("PLAYER_LOGIN")
	blizzLoader:SetScript("OnEvent", function()
		RegisterBlizzardFrames()
end)
