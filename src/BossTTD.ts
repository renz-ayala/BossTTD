/** @noSelfInFile */

let lastHealth = 0;
let lastTime = 0;
let avgDps = 0;
let updateTimer = 0;
const dmgHistory: number[] = [];
const MAX_SAMPLES = 60;

const ttdFrame = CreateFrame("Frame", "SalemTTDFrame", TargetFrame || UIParent);
ttdFrame.SetSize(120, 30);
ttdFrame.SetPoint("BOTTOM", TargetFrame || UIParent, "TOP", 0, 5);

const timerText = ttdFrame.CreateFontString(undefined, "OVERLAY");
timerText.SetFont("Fonts\\FRIZQT__.TTF", 18, "THICKOUTLINE");
timerText.SetTextColor(0, 1, 0, 1);
timerText.SetPoint("CENTER", ttdFrame, "CENTER", 0, 0);
timerText.SetText("[--:--]");
ttdFrame.Hide();

function isBossTarget(): boolean {
    if (!UnitExists("target") || !UnitCanAttack("player", "target")) {
        return false;
    }
    const classification = UnitClassification("target");
    const level = UnitLevel("target");

    return classification === "boss" || classification === "rareelite" || level === -1;
}

function resetCalculation(): void {
    lastHealth = UnitHealth("target") || 0;
    lastTime = GetTime();
    dmgHistory.length = 0;
    avgDps = 0;
    timerText.SetText("[--:--]");
}

const eventFrame = CreateFrame("Frame", "SalemTTDEventFrame");
eventFrame.RegisterEvent("PLAYER_TARGET_CHANGED");
eventFrame.RegisterEvent("UNIT_HEALTH");
eventFrame.RegisterEvent("PLAYER_REGEN_DISABLED");
eventFrame.RegisterEvent("PLAYER_REGEN_ENABLED");

eventFrame.SetScript("OnEvent", (self: WoWFrame, event: string, ...args: any[]) => {
    if (event === "PLAYER_TARGET_CHANGED" || event === "PLAYER_REGEN_DISABLED") {
        if (isBossTarget()) {
            resetCalculation();
            ttdFrame.Show();
        } else {
            ttdFrame.Hide();
        }
        return;
    }

    if (event === "PLAYER_REGEN_ENABLED") {
        ttdFrame.Hide();
        return;
    }

    if (event === "UNIT_HEALTH") {
        const unit = args[0] as string;
        if (unit !== "target" || !isBossTarget()) {
            return;
        }

        const currentHealth = UnitHealth("target");
        const maxHealth = UnitHealthMax("target");
        const currentTime = GetTime();

        if (maxHealth <= 0) return;

        const currentPct = (currentHealth / maxHealth) * 100;
        const lastPct = (lastHealth / maxHealth) * 100;
        const pctDiff = lastPct - currentPct;

        if (currentHealth > 0 && pctDiff > 0.01) {
            const timeDiff = currentTime - lastTime;

            if (timeDiff > 0) {
                dmgHistory.push(pctDiff / timeDiff);

                if (dmgHistory.length > MAX_SAMPLES) {
                    dmgHistory.shift();
                }

                let sum = 0;
                for (let i = 0; i < dmgHistory.length; i++) {
                    sum += dmgHistory[i];
                }
                avgDps = sum / dmgHistory.length;
            }

            lastHealth = currentHealth;
            lastTime = currentTime;
        }
    }
});

eventFrame.SetScript("OnUpdate", (self: WoWFrame, elapsed: number) => {
    if (!isBossTarget()) {
        if (ttdFrame.IsShown()) {
            ttdFrame.Hide();
        }
        return;
    }

    updateTimer += elapsed;
    if (updateTimer < 0.2) {
        return;
    }
    updateTimer = 0;

    if (avgDps > 0) {
        const maxHealth = UnitHealthMax("target");
        if (maxHealth > 0) {
            const currentPct = (UnitHealth("target") / maxHealth) * 100;
            const timeToDie = currentPct / avgDps;

            if (timeToDie > 0 && timeToDie < 3600) {
                const minutes = Math.floor(timeToDie / 60);
                const seconds = Math.floor(timeToDie % 60);

                const minStr = minutes < 10 ? `0${minutes}` : `${minutes}`;
                const secStr = seconds < 10 ? `0${seconds}` : `${seconds}`;

                timerText.SetText(`[${minStr}:${secStr}]`);
            } else {
                timerText.SetText("[--:--]");
            }
        }
    } else {
        timerText.SetText("[--:--]");
    }
});

export {};