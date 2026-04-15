local lastHealth, lastTime, lastPrint = 0, 0, 0
local dmgHistory = {}
local avgDps = 0
local inRaid = false
--local minDmg = 1000

local cds = {
    ["Blood Fury"] = { duration = 15, id = 20572 },
    ["Death Wish"] = { duration = 30, id = 12292 },
    ["Bloodlust Brooch"] = { duration = 20, id = 29383 },
    ["Abacus of Violent Odds"] = { duration = 10, id = 28288 },
    ["Recklessness"] = { duration = 15, id = 1719 }
}

local alertFrame = CreateFrame("Frame", nil, PlayerFrame)
alertFrame:SetSize(200, 40)
alertFrame:SetPoint("BOTTOM", PlayerFrame, "TOP", 0, 10)
alertFrame:Hide()
--CDS
alertFrame.alertText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
alertFrame.alertText:SetPoint("TOP", alertFrame, "TOP", 0, 10)
alertFrame.alertText:SetTextColor(0, 1, 0)
alertFrame.alertText:Hide()
--TTD
alertFrame.timerText = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
alertFrame.timerText:SetPoint("BOTTOM")
alertFrame.timerText:SetText("Dead: --:--")

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local function ShowCDAlert(msg)
    alertFrame.alertText:SetText(">>> " .. msg .. " <<<")
    alertFrame.alertText:Show()
    C_Timer.After(2, function() alertFrame.alertText:Hide() end)
end

local function updInRaid()
    local _, instanceType = GetInstanceInfo()
    if instanceType == "raid" then
        inRaid = true
        alertFrame:Show()
    else
        inRaid = false
        alertFrame:Hide()
    end
end

frame:SetScript("OnEvent", function (self, event, unit)

    if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
        updInRaid()
    end

    if not inRaid then
        return
    end
    
    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
        lastHealth = UnitHealth("target") or 0
        lastTime = GetTime()
        dmgHistory = {}
        lastPrint = 0
        avgDps = 0
    
    elseif event == "UNIT_HEALTH" and unit == "target" then
        local crHealth = UnitHealth("target")
        local crTime = GetTime()
        --local dmg = lastHealth - crHealth
        
        local crHealthMax = UnitHealthMax("target")
        if crHealthMax > 0 then
            local crDmg = (crHealth / crHealthMax) * 100
            local lastDmg = (lastHealth / crHealthMax) * 100
            local dmg = lastDmg - crDmg 

            if crHealth > 0 and dmg > 0.05 then
                local timeDiff = crTime - lastTime

                if timeDiff > 0 then
                    table.insert(dmgHistory, dmg / timeDiff)
                    
                    if #dmgHistory > 40 then table.remove(dmgHistory, 1) end

                    local sum = 0
                    for _, value in ipairs(dmgHistory) do sum = sum + value end
                    avgDps = sum / #dmgHistory
                end
                lastHealth = crHealth
                lastTime = crTime
            end
        end
    end
end)

frame:SetScript("OnUpdate", function(self, elapsed)

    if not inRaid then
        return
    end

    if avgDps > 0 then
        local crHealthMax = UnitHealthMax("target")
        if crHealthMax > 0 then
            local crPercent = (UnitHealth("target") / crHealthMax) * 100
            local ttDie = crPercent / avgDps
            
            if ttDie > 0 and ttDie < 600 then
                local m = math.floor(ttDie / 60)
                local s = math.floor(ttDie % 60)
                alertFrame.timerText:SetText(string.format("Dead: %02d:%02d", m, s))

                local now = GetTime()
                if now - lastPrint > 1.5 then
                    for cdName, data in pairs(cds) do
                        if ttDie <= (data.duration + 1) and ttDie >= (data.duration - 0.5) then
                            local currentCD = 0
                            
                            if cdName == "Bloodlust Brooch" or cdName == "Abacus of Violent Odds" then
                                local itemCDInfo = C_Container.GetItemCooldown(data.id)
                                if type(itemCDInfo) == "table" then
                                    currentCD = itemCDInfo.duration or 0
                                else
                                    currentCD = itemCDInfo or 0
                                end
                            else
                                local _, spellCD = GetSpellCooldown(data.id)
                                currentCD = spellCD or 0
                            end

                            if currentCD == 0 then
                                ShowCDAlert(cdName)
                                lastPrint = now
                            end
                        end
                    end
                end
            else
                alertFrame.timerText:SetText("Dead: --:--")
            end
        end
    else
        alertFrame.timerText:SetText("Dead: --:--")
    end
end)

updInRaid()