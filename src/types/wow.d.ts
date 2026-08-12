/** @noSelfInFile */
declare interface WoWStatusBar extends WoWFrame {
    SetMinMaxValues(this: WoWStatusBar, min: number, max: number): void;
    SetValue(this: WoWStatusBar, value: number): void;
    SetStatusBarTexture(this: WoWStatusBar, path: string): void;
    SetStatusBarColor(this: WoWStatusBar, r: number, g: number, b: number, a?: number): void;
    GetStatusBarTexture(this: WoWStatusBar): WoWTexture;
}

declare interface WoWFrame {
    RegisterEvent(this: WoWFrame, event: string): void;
    SetScript(
        this: WoWFrame,
        scriptTypeName: "OnEvent",
        handler: (self: WoWFrame, event: string, ...args: any[]) => void
    ): void;
    SetScript(
        this: WoWFrame,
        scriptTypeName: "OnUpdate",
        handler: (self: WoWFrame, elapsed: number) => void
    ): void;
    SetScript(
        this: WoWFrame,
        scriptTypeName: "OnLoad",
        handler: (self: WoWFrame) => void
    ): void;
    SetSize(this: WoWFrame, width: number, height: number): void;
    SetPoint(this: WoWFrame, point: string, relativeTo?: WoWFrame | null, relativePoint?: string, x?: number, y?: number): void;
    CreateFontString(this: WoWFrame, name?: string, layer?: string, inherits?: string): WoWFontString;
    CreateTexture(this: WoWFrame, name?: string, layer?: string): WoWTexture;
    Show(this: WoWFrame): void;
    Hide(this: WoWFrame): void;
    IsShown(this: WoWFrame): boolean;
}

declare interface WoWFontString {
    SetFont(this: WoWFontString, fontFile: string, fontSize: number, flags?: string): void;
    SetPoint(this: WoWFontString, point: string, relativeTo?: WoWFrame | null, relativePoint?: string, x?: number, y?: number): void;
    SetText(this: WoWFontString, text: string): void;
    SetTextColor(this: WoWFontString, r: number, g: number, b: number, a?: number): void;
}

declare interface WoWTexture {
    SetAllPoints(this: WoWTexture, relativeTo?: WoWFrame): void;
    SetColorTexture(this: WoWTexture, r: number, g: number, b: number, a?: number): void;
    SetTexture(this: WoWTexture, texturePath: string | number): void;
    SetSize(this: WoWTexture, width: number, height: number): void;
    SetPoint(this: WoWTexture, point: string, relativeTo?: WoWFrame | null, relativePoint?: string, x?: number, y?: number): void;
    SetAlpha(this: WoWTexture, alpha: number): void;
}

declare function print(...args: Array<string | number | boolean | undefined>): void;
declare function GetTime(): number;
declare function GetNetStats(): LuaMultiReturn<[number, number, number, number]>;

declare function UnitClass(unit: string): LuaMultiReturn<[string, string]>;
declare function UnitGUID(unit: string): string;
declare function UnitAttackSpeed(unit: string): LuaMultiReturn<[number, number]>;
declare function UnitHealth(unit: string): number;
declare function UnitHealthMax(unit: string): number;
declare function UnitClassification(unit: string): string;
declare function UnitLevel(unit: string): number;
declare function UnitExists(unit: string): boolean;
declare function UnitCanAttack(attacker: string, target: string): boolean;

declare function GetTalentInfo(tabIndex: number, talentIndex: number): LuaMultiReturn<[string, string, number, number, number, number]>;
declare function CombatLogGetCurrentEventInfo(): LuaMultiReturn<[
    number, string, boolean, string, string, number, number, string, string, number, number, number, string
]>;

declare function CreateFrame(frameType: "StatusBar", name?: string, parent?: WoWFrame, template?: string): WoWStatusBar;
declare function CreateFrame(frameType: string, name?: string, parent?: WoWFrame, template?: string): WoWFrame;

declare const TargetFrame: WoWFrame;
declare const PlayerFrame: WoWFrame;
declare const UIParent: WoWFrame;
declare const SlashCmdList: Record<string, (msg: string) => void>;