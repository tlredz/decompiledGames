local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local replicated = FastFlags.Replicated("TradePlazaServerBrowser/Enabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated(
	"TradePlazaServerBrowser/ProGenerationRequirement",
	Asserts.FiniteNonNegative,
	25000000000
)
local replicated3 = FastFlags.Replicated(
	"TradePlazaServerBrowser/OGGenerationRequirement",
	Asserts.FiniteNonNegative,
	100000000000
)
local replicated4 = FastFlags.Replicated(
	"TradePlazaServerBrowser/RegistryUpdateDebounce",
	Asserts.FiniteNonNegative,
	30
)
local replicated5 = FastFlags.Replicated(
	"TradePlazaServerBrowser/PlayerCountUpdateDebounce",
	Asserts.FiniteNonNegative,
	60
)
local replicated6 = FastFlags.Replicated("TradePlazaServerBrowser/MaxSearchesPerSecond", Asserts.FiniteNonNegative, 20)
local replicated7 = FastFlags.Replicated("TradePlazaServerBrowser/SearchLimit", Asserts.FinitePositive, 25)
local replicated8 = FastFlags.Replicated(
	"TradePlazaServerBrowser/DefaultResultsCacheTtl",
	Asserts.FiniteNonNegative,
	60
)
local replicated9 = FastFlags.Replicated("TradePlazaServerBrowser/MinSearchDuration", Asserts.FiniteNonNegative, 3)
local replicated10 = FastFlags.Replicated("TradePlazaServerBrowser/RefreshMin", Asserts.FinitePositive, 450)
local replicated11 = FastFlags.Replicated("TradePlazaServerBrowser/RefreshMax", Asserts.FinitePositive, 510)
local replicated12 = FastFlags.Replicated("TradePlazaServerBrowser/JoinDebounce", Asserts.FiniteNonNegative, 5)
local replicated13 = FastFlags.Replicated(
	"TradePlazaServerBrowser/GenerationChangeThreshold",
	Asserts.FiniteNonNegative,
	0.05
)
return table.freeze({
	Enabled = replicated,
	ProGenerationRequirement = replicated2,
	OGGenerationRequirement = replicated3,
	RegistryUpdateDebounce = replicated4,
	PlayerCountUpdateDebounce = replicated5,
	MaxSearchesPerSecond = replicated6,
	SearchLimit = replicated7,
	DefaultResultsCacheTtl = replicated8,
	MinSearchDuration = replicated9,
	RefreshMin = replicated10,
	RefreshMax = replicated11,
	JoinDebounce = replicated12,
	GenerationChangeThreshold = replicated13
})