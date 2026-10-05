local General = {
	PetLightningChancePerWeather = {
		Common = 70,
		Rare = 60,
		Epic = 50,
		Legendary = 30,
		Mythic = 20,
		Divine = 10,
		Ethereal = 7
	},
	MaxPetLightningStrikesPerRarityPerWeather = 3,
	PetLightningMinimumDelaySeconds = 5,
	PetLightningScheduleStartFraction = 0.1,
	PetLightningScheduleEndFraction = 0.9,
	PetLightningScheduleJitterFraction = 0.25,
	RarityLevelRequirementMultiplier = {
		Common = 10,
		Rare = 15,
		Epic = 25,
		Legendary = 27,
		Mythic = 30,
		Divine = 40,
		Ethereal = 50
	},
	CashBoostDuration = 3,
	HeldRiggedStrikeChanceBonus = {
		Common = 5,
		Rare = 5,
		Epic = 4,
		Legendary = 3,
		Mythic = 2,
		Divine = 0.5,
		Ethereal = 0
	},
	SpawnDistance = {
		Rare = {
			Minimum = 300,
			Maximum = 700
		},
		Epic = {
			Minimum = 700,
			Maximum = 1200
		},
		Legendary = {
			Minimum = 1000,
			Maximum = 2000
		},
		Mythic = {
			Minimum = 1200,
			Maximum = 2500
		},
		Divine = {
			Minimum = 2500,
			Maximum = 3000
		},
		Ethereal = {
			Minimum = 3000,
			Maximum = 1e999
		}
	},
	EggBreakTimer = {
		Common = 20,
		Rare = 25,
		Epic = 35,
		Legendary = 30,
		Mythic = 30,
		Divine = 27,
		Ethereal = 21
	},
	EggBreakTouchBonus = 3,
	EggEscapeTouchBonus = 6,
	EggBreakDistanceBonus = {
		Ethereal = {
			From = 3500,
			Step = 20,
			PerStep = 0.1,
			Maximum = nil
		}
	},
	GiantWeatherSizeRanges = {
		{
			Minimum = 1,
			Maximum = 1.5,
			Chance = 70
		},
		{
			Minimum = 1.5,
			Maximum = 2,
			Chance = 19
		},
		{
			Minimum = 2,
			Maximum = 2.5,
			Chance = 6
		},
		{
			Minimum = 2.5,
			Maximum = 3,
			Chance = 3
		},
		{
			Minimum = 3,
			Maximum = 3.5,
			Chance = 1.5
		},
		{
			Minimum = 3.5,
			Maximum = 4,
			Chance = 0.5
		}
	},
	GiantWeatherMultiplier = 1.25,
	GiantWeatherTweenDistance = 300,
	GiantWeatherTweenDuration = 0.6
}

function General.RollGiantWeatherSize(object)
	local number = object:NextNumber(0, 100)
	local giantWeatherSizeRanges = General.GiantWeatherSizeRanges
	local total = 0

	for i, giantWeatherSizeRange in ipairs(giantWeatherSizeRanges) do
		total += giantWeatherSizeRange.Chance

		if number < total or i == #giantWeatherSizeRanges then
			return object:NextNumber(giantWeatherSizeRange.Minimum, giantWeatherSizeRange.Maximum)
		end
	end

	return 1
end

function General.GiantWeatherWeightFor(p, p2)
	local rollGiantWeatherSize = General.RollGiantWeatherSize(p2)

	if rollGiantWeatherSize < p then
		return p * General.GiantWeatherMultiplier
	end

	return rollGiantWeatherSize
end

General.RebirthRequirements = {
	"Horse",
	"Fox",
	"Unicorn",
	"Phoenix",
	"Kitsune",
	"Dragon"
}
General.RebirthBases = {
	"Gold",
	"Diamond",
	"Ruby",
	"Crystal",
	"Sakura",
	"Draconic"
}
General.Fences = {
	Gold = {
		Image = "rbxassetid://71284534108926"
	},
	Diamond = {
		Image = "rbxassetid://70436858186484"
	},
	Ruby = {
		Image = "rbxassetid://113957341552316"
	},
	Crystal = {
		Image = "rbxassetid://110224882977422"
	},
	Sakura = {
		Image = "rbxassetid://129595388936050"
	},
	Draconic = {
		Image = "rbxassetid://119055302459851"
	}
}
General.HatchUpgrade = {
	InitialCost = 5,
	IncrementCost = 10,
	CostIncrementPerFive = 50
}
General.Markers = {
	HomeMarkerDistance = 300,
	PlotTeleportDistance = 300,
	PlotTeleportSpeed = 120,
	PlotTeleportCooldown = 1.5,
	PlotTeleportClearance = 0.5
}
General.WeightDisplay = {
	EggAnchors = {
		{
			Real = 0.9,
			Shown = 1
		},
		{
			Real = 1.2,
			Shown = 15
		},
		{
			Real = 1.5,
			Shown = 73000
		},
		{
			Real = 2,
			Shown = 240000
		},
		{
			Real = 3,
			Shown = 1500000
		}
	},
	PetPerEggKG = 10
}
General.EggGrowthWeightAnchors = {
	{
		Real = 0.9,
		Shown = 1
	},
	{
		Real = 1.2,
		Shown = 15
	},
	{
		Real = 1.5,
		Shown = 1500
	},
	{
		Real = 2,
		Shown = 240000
	},
	{
		Real = 3,
		Shown = 1500000
	}
}

function General.ShownEggKG(p, p2)
	local v = p2 or General.WeightDisplay.EggAnchors
	local v2 = tonumber(p) or 1

	if v2 <= v[1].Real then
		return v[1].Shown
	end

	for i = 1, #v - 1 do
		local v3 = v[i]
		local v4 = v[i + 1]

		if not (v2 <= v4.Real) then
			continue
		end

		local v5 = (v2 - v3.Real) / (v4.Real - v3.Real)
		return 10 ^ (math.log10(v3.Shown) + (math.log10(v4.Shown) - math.log10(v3.Shown)) * v5)
	end

	return v[#v].Shown
end

General.EggInflateFrom = 1.5
General.EggInflateFactor = 2

function General.WorldEggScaleFor(p)
	local v = tonumber(p) or 1

	if General.EggInflateFrom <= v then
		return v * General.EggInflateFactor
	end

	return v
end

General.EggCarrySpeed = {
	FreeSize = 1,
	SizeStep = 0.1,
	PercentPerStep = 1,
	MaxReductionPercent = 80,
	EggSpecificPercentPerStep = {
		Cherub = 1.25
	}
}

function General.EggCarrySpeedMultiplier(p, value)
	local eggCarrySpeed = General.EggCarrySpeed
	local sizeStep = tonumber(eggCarrySpeed.SizeStep) or 0.1

	if sizeStep <= 0 then
		return 1
	end

	local v = math.floor(math.max((tonumber(p) or 1) - (tonumber(eggCarrySpeed.FreeSize) or 1), 0) / sizeStep + 1e-6)
	local percentPerStep = tonumber(eggCarrySpeed.PercentPerStep) or 0
	local eggSpecificPercentPerStep = eggCarrySpeed.EggSpecificPercentPerStep

	if type(eggSpecificPercentPerStep) == "table" and type(value) == "string" then
		local v2 = tonumber(eggSpecificPercentPerStep[value])

		if v2 == nil then
			v2 = tonumber(eggSpecificPercentPerStep[value:gsub(" Egg$", "")])
		end

		if v2 ~= nil then
			percentPerStep = v2
		end
	end

	return 1 - math.min(
		v * math.max(percentPerStep, 0),
		(math.clamp(tonumber(eggCarrySpeed.MaxReductionPercent) or 80, 0, 99))
	) / 100
end

General.PetSpeedDisplay = {
	{
		Walk = 50,
		Shown = 15
	},
	{
		Walk = 55,
		Shown = 300
	},
	{
		Walk = 100,
		Shown = 5000
	},
	{
		Walk = 180,
		Shown = 1000000
	},
	{
		Walk = 200,
		Shown = 100000000
	},
	{
		Walk = 210,
		Shown = 300000000
	},
	{
		Walk = 240,
		Shown = 1000000000
	},
	{
		Walk = 300,
		Shown = 1000000000000
	}
}
General.PetSpeedWeight = {
	SpeedWeightStepKG = 10,
	SpeedPerWeightStep = 1,
	MinSpeedMultiplier = 0.5
}
General.PetSpeedBonus = {
	WalkSpeedPerTenfold = 10,
	MaxBonus = 30
}
General.PetMovementSpeed = {
	SoftCapStart = 240,
	MaxSpeed = 270
}
General.MaxEggWeight = 3
General.EggWeightRoll = {
	{
		Min = 1,
		Max = 1.5,
		Weight = 84.5
	},
	{
		Min = 1.5,
		Max = 2,
		Weight = 10
	},
	{
		Min = 2,
		Max = 2.5,
		Weight = 4
	},
	{
		Min = 2.5,
		Max = 3,
		Weight = 1.5
	}
}

function General.RollEggWeight()
	local eggWeightRoll = General.EggWeightRoll
	local total = 0

	for _, v in ipairs(eggWeightRoll) do
		total += v.Weight
	end

	local v = math.random() * total
	local total2 = 0

	for i, v2 in ipairs(eggWeightRoll) do
		total2 += v2.Weight

		if v < total2 or i == #eggWeightRoll then
			return v2.Min + (v2.Max - v2.Min) * math.random()
		end
	end

	return 1
end

General.PremiumEggStartScale = 0.5
General.PremiumEggs = {
	["Dragon Egg"] = {
		Pets = {
			Crocodile = 50,
			Fox = 30,
			TRex = 15,
			Phoenix = 4,
			Dragon = 1
		}
	},
	["Giant Egg"] = {
		Rarities = {
			Common = 40,
			Rare = 30,
			Epic = 20,
			Legendary = 5,
			Mythic = 4,
			Divine = 1,
			Ethereal = 0.1
		}
	}
}
General.EggGrowthWeightScale = {
	{
		Scale = 15,
		Multiplier = 1
	},
	{
		Scale = 1500,
		Multiplier = 1.5
	},
	{
		Scale = 240000,
		Multiplier = 5
	}
}

function General.GrowthMultiplierFor(p)
	local eggGrowthWeightScale = General.EggGrowthWeightScale
	local v = tonumber(p) or 0

	if not eggGrowthWeightScale or #eggGrowthWeightScale == 0 then
		return 1
	end

	if v <= eggGrowthWeightScale[1].Scale then
		return eggGrowthWeightScale[1].Multiplier
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function Between(p2, p3, p4)
		local v2 = (math.log10(p4) - math.log10(p2.Scale)) / (math.log10(p3.Scale) - math.log10(p2.Scale))
		return 10 ^ (math.log10(p2.Multiplier) + (math.log10(p3.Multiplier) - math.log10(p2.Multiplier)) * v2)
	end

	for i = 1, #eggGrowthWeightScale - 1 do
		local v2 = eggGrowthWeightScale[i]
		local v3 = eggGrowthWeightScale[i + 1]

		if v <= v3.Scale then
			return Between(v2, v3, v)
		end
	end

	local v2 = eggGrowthWeightScale[#eggGrowthWeightScale]
	local v3 = eggGrowthWeightScale[#eggGrowthWeightScale - 1]

	if not v3 or v2.Scale == v3.Scale then
		return v2.Multiplier
	end

	return Between(v3, v2, v)
end

function General.GrowthTimeFor(p, p2)
	local v = tonumber(p) or 0

	if v <= 0 then
		return 0
	end

	return v * General.GrowthMultiplierFor(General.ShownEggKG(p2, General.EggGrowthWeightAnchors))
end

General.RarityColors = {
	Common = Color3.fromRGB(173, 173, 173),
	Rare = Color3.fromRGB(0, 170, 255),
	Epic = Color3.fromRGB(170, 85, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic = Color3.fromRGB(255, 170, 255),
	Divine = Color3.fromRGB(255, 255, 0),
	Ethereal = Color3.fromRGB(170, 170, 255)
}
return General