local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("Trading.SignEnabled", Asserts.Boolean, false)
local replicated2 = FastFlags.Replicated("Trading.SignCooldown", Asserts.FinitePositive, 5)
local replicated3 = FastFlags.Replicated("Trading.SignMaxLength", Asserts.IntegerPositive, 100)
local replicated4 = FastFlags.Replicated("Trading.SignPresetsEnabled", Asserts.Boolean, true)
local replicated5 = FastFlags.Replicated("Trading.SignPresets", Asserts.Array(Asserts.String), {
	"➕ Add More",
	"❌ L Trade",
	"🧾 Last Offer",
	"🤝 Deal?",
	"✅ Fair Trade",
	"🙅 No Thanks"
})
local replicated6 = FastFlags.Replicated("Trading.SignAgeGroupsEnabled", Asserts.Boolean, true)
local replicated7 = FastFlags.Replicated("Trading.SignFreeTypeDisabled", Asserts.Boolean, false)
local replicated8 = FastFlags.Replicated("Trading.SignPresetCooldown", Asserts.FinitePositive, 5)
local replicated9 = FastFlags.Replicated("Trading.SignMaxMessages", Asserts.IntegerPositive, 30)
local replicated10 = FastFlags.Replicated("Trading.TradePlazaSignsDisabled", Asserts.Boolean, false)
local replicated11 = FastFlags.Replicated("Trading.TradePlazaSignMaxLength", Asserts.IntegerPositive, 60)
local replicated12 = FastFlags.Replicated("Trading.TradePlazaSignChangeCooldown", Asserts.FinitePositive, 10)
local replicated13 = FastFlags.Replicated("Trading.TriggerBrainrotCountAnalyticsUpdate", Asserts.Boolean, true)
local replicated14 = FastFlags.Replicated("Trading.SignMinTextSize", Asserts.IntegerPositive, 8)
local replicated15 = FastFlags.Replicated("Trading.SignMaxTextSize", Asserts.IntegerPositive, 30)
local replicated16 = FastFlags.Replicated("Trading.SignTextSizeRatio", Asserts.Range(0, 1), 0.1)
return table.freeze({
	SignEnabled = replicated,
	SignCooldown = replicated2,
	SignPresetCooldown = replicated8,
	SignMaxLength = replicated3,
	SignMaxMessages = replicated9,
	SignPresetsEnabled = replicated4,
	SignPresets = replicated5,
	SignAgeGroupsEnabled = replicated6,
	SignFreeTypeDisabled = replicated7,
	TradePlazaSignsDisabled = replicated10,
	TradePlazaSignMaxLength = replicated11,
	TradePlazaSignChangeCooldown = replicated12,
	TriggerBrainrotCountAnalyticsUpdate = replicated13,
	SignMinTextSize = replicated14,
	SignMaxTextSize = replicated15,
	SignTextSizeRatio = replicated16
})