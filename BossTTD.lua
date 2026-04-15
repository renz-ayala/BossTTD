local frame = CreateFrame("Frame")
local lastHealth, lastTime, lastPrint = 0, 0, 0
local dmgHistory = {}
--local minDmg = 1000

local cds = {
    ["Blood Fury"] = { duration = 15, id = 20572 },
    ["Death Wish"] = { duration = 30, id = 12292 },
    ["Bloodlust Brooch"] = { duration = 20, id = 29383 },
    ["Abacus of Violent Odds"] = { duration = 10, id = 28288 },
    ["Recklessness"] = { duration = 15, id = 1719 }
}

frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")

frame:SetScript("OnEvent", function (self, event, unit)
    if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_REGEN_DISABLED" then
        lastHealth = UnitHealth("target") or 0
        lastTime = GetTime()
        dmgHistory = {}
        lastPrint = 0
    
    elseif event == "UNIT_HEALTH" and unit == "target" then
        local crHealth = UnitHealth("target")
        local crTime = GetTime()
        --local dmg = lastHealth - crHealth
        
        local crHealthMax = UnitHealthMax("target")
        local crDmg = (crHealth / crHealthMax) * 100
        local lastDmg = (lastHealth / crHealthMax) * 100
        local dmg = lastDmg - crDmg 

        if crHealth > 0 and dmg > 0.1 then
            local timeDiff = crTime - lastTime

            if timeDiff > 0 then
                table.insert(dmgHistory, dmg / timeDiff)
                
                if #dmgHistory > 40 then table.remove(dmgHistory, 1) end

                local sum = 0
                for _, value in ipairs(dmgHistory) do sum = sum + value end
                local avgDps = sum / #dmgHistory

                if avgDps > 0 then
                    --local ttDie = crHealth / avgDps
                    local ttDie = crDmg / avgDps
                    
                    if ttDie < 600 and (crTime - lastPrint > 1) then
                        local m = math.floor(ttDie / 60)
                        local s = math.floor(ttDie - (m * 60))
                        
                        print(string.format("Dead: %02d:%02d", m, s))

                        for cdName, data in pairs(cds) do
                            if ttDie <= (data.duration + 2) and ttDie >= (data.duration - 1) then
                                local cooldownDuration = 0
                                if cdName == "Bloodlust Brooch" or cdName == "Abacus of Violent Odds" then
                                    local itemCDInfo = C_Container.GetItemCooldown(data.id)
                                    if type(itemCDInfo) == "table" then
                                        cooldownDuration = itemCDInfo.duration or 0
                                    end
                                else
                                    local _, spellCooldown = GetSpellCooldown(data.id)
                                    cooldownDuration = spellCooldown or 0
                                end

                                if cooldownDuration == 0 then
                                    print(string.format("PRESS: %s", cdName))
                                end
                                --print(string.format("PRESS: %s", cdName))
                            end
                        end

                        lastPrint = crTime
                    end
                end
            end
            lastHealth = crHealth
            lastTime = crTime
        end
    end
end)