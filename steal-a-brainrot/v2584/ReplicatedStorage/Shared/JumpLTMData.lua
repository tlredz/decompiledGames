local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local Animals = require(ReplicatedStorage.Datas.Animals)
local rarityScales = {
	Common = 0.5,
	Rare = 0.6,
	Epic = 0.8,
	Legendary = 0.75,
	Mythic = 1,
	["Brainrot God"] = 1.25,
	Secret = 1.5,
	OG = 1.75,
	Admin = 1.75,
	Taco = 1,
	Spooky = 1,
	Festive = 1,
	Valentines = 1,
	["St Patrick's"] = 1,
	Easter = 1,
	Summer = 1,
	Honey = 1
}
local levelUpCosts = {
	50,
	100,
	400,
	530,
	1330,
	1800,
	3500,
	4300,
	7300,
	13800,
	16700,
	33700,
	42600,
	51700,
	91500,
	106000,
	120000,
	220000,
	264000,
	308000
}
local table2 = Asserts.Table({
	Template = Asserts.String,
	BounceXP = Asserts.FinitePositive,
	Cost = Asserts.FiniteNonNegative,
	RequiredLevel = Asserts.IntegerPositive
})
local flags = {
	LevelUpCosts = FastFlags.Replicated("Game.JumpLTM.LevelUpCosts", function(p)
		local v4 = Asserts.Array(Asserts.FinitePositive)(p)
		assert(#v4 == 20, (`LevelUpCosts must have {20} entries`))
		return v4
	end, levelUpCosts),
	TrampolineTiers = FastFlags.Replicated("Game.JumpLTM.TrampolineTiers", Asserts.Array(table2), {
		{
			Template = "DefaultTrampoline",
			BounceXP = 1,
			Cost = 0,
			RequiredLevel = 1
		},
		{
			Template = "GoldTrampoline",
			BounceXP = 2,
			Cost = 50000,
			RequiredLevel = 2
		},
		{
			Template = "DiamondTrampoline",
			BounceXP = 3,
			Cost = 2500000,
			RequiredLevel = 3
		},
		{
			Template = "CandyTrampoline",
			BounceXP = 5,
			Cost = 25000000,
			RequiredLevel = 5
		},
		{
			Template = "LavaTrampoline",
			BounceXP = 8,
			Cost = 250000000,
			RequiredLevel = 7
		},
		{
			Template = "GalaxyTrampoline",
			BounceXP = 12,
			Cost = 2500000000,
			RequiredLevel = 10
		},
		{
			Template = "YinYangTrampoline",
			BounceXP = 18,
			Cost = 10000000000,
			RequiredLevel = 12
		},
		{
			Template = "CursedTrampoline",
			BounceXP = 27,
			Cost = 50000000000,
			RequiredLevel = 15
		},
		{
			Template = "DivineTrampoline",
			BounceXP = 40,
			Cost = 250000000000,
			RequiredLevel = 18
		}
	}),
	TrampolineJumpForce = FastFlags.Replicated("Game.JumpLTM.TrampolineJumpForce", Asserts.FinitePositive, 150),
	BaseTrampolineJumpForce = FastFlags.Replicated("Game.JumpLTM.BaseTrampolineJumpForce", Asserts.FinitePositive, 60),
	BounceXPWindowSeconds = FastFlags.Replicated("Game.JumpLTM.BounceXPWindowSeconds", Asserts.FinitePositive, 9),
	MaxPaidBouncesPerWindow = FastFlags.Replicated("Game.JumpLTM.MaxPaidBouncesPerWindow", Asserts.IntegerPositive, 11),
	XPGainMultiplier = FastFlags.Replicated("Game.JumpLTM.XPGainMultiplier", Asserts.FinitePositive, 1),
	BasePetPayoutInterval = FastFlags.Replicated("Game.JumpLTM.BasePetPayoutInterval", Asserts.FinitePositive, 10),
	TrackEggsPerArea = FastFlags.Replicated("Game.JumpLTM.TrackEggsPerArea", Asserts.IntegerPositive, 5),
	CloudVanishAreaStep = FastFlags.Replicated("Game.JumpLTM.CloudVanishAreaStep", Asserts.FiniteNonNegative, 0.1),
	CloudVanishMinMultiplier = FastFlags.Replicated("Game.JumpLTM.CloudVanishMinMultiplier", Asserts.Range(0, 1), 0.4)
}

local function getExpansionLevel(p: number)
	return (math.clamp(p // 2, 0, 9))
end

local function getExpansionDepth(value: number)
	return math.clamp(value, 0, 9) * 6
end

local function getBrainrotScale(p)
	local rarity = p.Rarity

	if not rarity and p.Name then
		local animal = Animals[p.Name]
		rarity = animal and animal.Rarity
	end

	if rarity and rarityScales[rarity] then
		return rarityScales[rarity]
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLevelCost(value: number)
	local v4 = math.clamp(value, 1, 20)
	return flags.LevelUpCosts:Get()[v4]
end

local function getTrampolineTiers()
	return flags.TrampolineTiers:Get()
end

local function getLevelInfo(value: number?)
	local v4 = (type(value) ~= "number" or value ~= value) and 0 or math.max(value, 0)
	local v5 = 1

	while v5 < 21 do
		local levelCost = getLevelCost(v5) -- equivalent call inferred; original call site unknown

		if v4 < levelCost then
			return v5, v4, levelCost
		end

		v4 -= levelCost
		v5 += 1
	end

	return 21, 0, nil
end

local function getExtraJumps(p: number?)
	return (getLevelInfo(p))
end

local function getTrackEggScale(p: number)
	return math.clamp((p - 15) / 3585, 0, 1) * 0.8 + 0.8
end

return table.freeze({
	RebirthsPerExpansion = 2,
	MaxExpansionLevel = 9,
	ExpansionDepthPerLevel = 6,
	FencePostSpacing = 6,
	SkinOverlayModes = {
		Christmas = "Move",
		Divine = "Move",
		Radioactive = "Move",
		Cursed = "Move",
		Lucky = "Move",
		Rose = "Move",
		Cyber = "Move",
		Easter = "Move",
		Headless = "Center"
	},
	PetWalkSpeed = 6,
	PetScaredSpeedMultiplier = 1.8,
	PetIdleTimeMin = 1.5,
	PetIdleTimeMax = 4,
	PetFloorMargin = 4,
	PetFocusFollowRadius = 6,
	PetScareRadius = 9,
	PetHomeWanderFraction = 0.5,
	PetSeparationDistance = 2,
	RarityScales = rarityScales,
	BasePetPayoutInterval = 10,
	TrackEggsPerArea = 5,
	TrackEggHatchTimeMin = 15,
	TrackEggHatchTimeMax = 3600,
	TrackEggScaleMin = 0.8,
	TrackEggScaleMax = 1.6,
	BaseEggHatchHoldDuration = 0.5,
	BaseEggHatchShakeDuration = 1.2,
	BaseEggExplosionDebrisSeconds = 2.5,
	TrampolineJumpForce = 150,
	BaseTrampolineJumpForce = 60,
	BounceXPWindowSeconds = 9,
	MaxPaidBouncesPerWindow = 11,
	StartLevel = 1,
	TrackAreaCount = 7,
	TrackAreaNames = {
		"Grass",
		"Desert",
		"Snow",
		"Cave",
		"Water",
		"Lava",
		"Heaven"
	},
	CloudVanishAreaStep = 0.1,
	CloudVanishMinMultiplier = 0.4,
	LevelsPerArea = 3,
	MaxLevel = 21,
	LevelUpCosts = levelUpCosts,
	Flags = flags,
	GetExpansionLevel = getExpansionLevel,
	GetExpansionDepth = getExpansionDepth,
	GetBrainrotScale = getBrainrotScale,
	GetLevelCost = getLevelCost,
	GetLevelInfo = getLevelInfo,
	GetExtraJumps = getExtraJumps,
	GetTrampolineTiers = getTrampolineTiers,
	GetTrackEggScale = getTrackEggScale
})