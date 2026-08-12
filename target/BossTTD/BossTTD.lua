--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]

local ____modules = {}
local ____moduleCache = {}
local ____originalRequire = require
local function require(file, ...)
    if ____moduleCache[file] then
        return ____moduleCache[file].value
    end
    if ____modules[file] then
        local module = ____modules[file]
        local value = nil
        if (select("#", ...) > 0) then value = module(...) else value = module(file) end
        ____moduleCache[file] = { value = value }
        return value
    else
        if ____originalRequire then
            return ____originalRequire(file)
        else
            error("module '" .. file .. "' not found")
        end
    end
end
____modules = {
["BossTTD"] = function(...) 
--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArraySetLength(self, length)
    if length < 0 or length ~= length or length == math.huge or math.floor(length) ~= length then
        error(
            "invalid array length: " .. tostring(length),
            0
        )
    end
    for i = length + 1, #self do
        self[i] = nil
    end
    return length
end
-- End of Lua Library inline imports
local ____exports = {}
---
-- @noSelfInFile
local lastHealth = 0
local lastTime = 0
local avgDps = 0
local updateTimer = 0
local dmgHistory = {}
local MAX_SAMPLES = 60
local ttdFrame = CreateFrame("Frame", "SalemTTDFrame", TargetFrame or UIParent)
ttdFrame:SetSize(120, 30)
ttdFrame:SetPoint(
    "BOTTOM",
    TargetFrame or UIParent,
    "TOP",
    0,
    5
)
local timerText = ttdFrame:CreateFontString(nil, "OVERLAY")
timerText:SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE")
timerText:SetTextColor(0, 1, 0, 1)
timerText:SetPoint(
    "CENTER",
    ttdFrame,
    "CENTER",
    0,
    0
)
timerText:SetText("[--:--]")
ttdFrame:Hide()
local function isBossTarget()
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        return false
    end
    local classification = UnitClassification("target")
    local level = UnitLevel("target")
    return classification == "boss" or classification == "rareelite" or level == -1
end
local function resetCalculation()
    lastHealth = UnitHealth("target") or 0
    lastTime = GetTime()
    __TS__ArraySetLength(dmgHistory, 0)
    avgDps = 0
    timerText:SetText("[--:--]")
end
local eventFrame = CreateFrame("Frame", "SalemTTDEventFrame")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript(
    "OnEvent",
    function(____self, event, ...)
        local args = {...}
        if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
            if isBossTarget() then
                resetCalculation()
                ttdFrame:Show()
            else
                ttdFrame:Hide()
            end
            return
        end
        if event == "PLAYER_REGEN_ENABLED" then
            ttdFrame:Hide()
            return
        end
        if event == "UNIT_HEALTH" then
            local unit = args[1]
            if unit ~= "target" or not isBossTarget() then
                return
            end
            local currentHealth = UnitHealth("target")
            local maxHealth = UnitHealthMax("target")
            local currentTime = GetTime()
            if maxHealth <= 0 then
                return
            end
            local currentPct = currentHealth / maxHealth * 100
            local lastPct = lastHealth / maxHealth * 100
            local pctDiff = lastPct - currentPct
            if currentHealth > 0 and pctDiff > 0.01 then
                local timeDiff = currentTime - lastTime
                if timeDiff > 0 then
                    dmgHistory[#dmgHistory + 1] = pctDiff / timeDiff
                    if #dmgHistory > MAX_SAMPLES then
                        table.remove(dmgHistory, 1)
                    end
                    local sum = 0
                    do
                        local i = 0
                        while i < #dmgHistory do
                            sum = sum + dmgHistory[i + 1]
                            i = i + 1
                        end
                    end
                    avgDps = sum / #dmgHistory
                end
                lastHealth = currentHealth
                lastTime = currentTime
            end
        end
    end
)
eventFrame:SetScript(
    "OnUpdate",
    function(____self, elapsed)
        if not isBossTarget() then
            if ttdFrame:IsShown() then
                ttdFrame:Hide()
            end
            return
        end
        updateTimer = updateTimer + elapsed
        if updateTimer < 0.2 then
            return
        end
        updateTimer = 0
        if avgDps > 0 then
            local maxHealth = UnitHealthMax("target")
            if maxHealth > 0 then
                local currentPct = UnitHealth("target") / maxHealth * 100
                local timeToDie = currentPct / avgDps
                if timeToDie > 0 and timeToDie < 3600 then
                    local minutes = math.floor(timeToDie / 60)
                    local seconds = math.floor(timeToDie % 60)
                    local ____temp_0
                    if minutes < 10 then
                        ____temp_0 = "0" .. tostring(minutes)
                    else
                        ____temp_0 = tostring(minutes)
                    end
                    local minStr = ____temp_0
                    local ____temp_1
                    if seconds < 10 then
                        ____temp_1 = "0" .. tostring(seconds)
                    else
                        ____temp_1 = tostring(seconds)
                    end
                    local secStr = ____temp_1
                    timerText:SetText(((("[" .. minStr) .. ":") .. secStr) .. "]")
                else
                    timerText:SetText("[--:--]")
                end
            end
        else
            timerText:SetText("[--:--]")
        end
    end
)
return ____exports
 end,
}
local ____entry = require("BossTTD", ...)
return ____entry
