local frame = CreateFrame("Frame")
local lastHealth, lastTime, lastPrint = 0, 0, 0
local dmgHistory = {}
local minDmg = 1000

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
        local dmg = lastHealth - crHealth

        if crHealth > 0 and (dmg > minDmg or dmg < 0) then
            local timeDiff = crTime - lastTime

            if timeDiff > 0 then
                table.insert(dmgHistory, dmg / timeDiff)
                
                if #dmgHistory > 40 then table.remove(dmgHistory, 1) end

                local sum = 0
                for _, value in ipairs(dmgHistory) do sum = sum + value end
                local avgDps = sum / #dmgHistory

                if avgDps > 0 then
                    local ttDie = crHealth / avgDps
                    
                    if ttDie < 600 and (crTime - lastPrint > 1) then
                        local m = math.floor(ttDie / 60)
                        local s = math.floor(ttDie - (m * 60))
                        
                        print(string.format("Dead: %02d:%02d", m, s))
                        lastPrint = crTime
                    end
                end
            end
            lastHealth = crHealth
            lastTime = crTime
        end
    end
end)