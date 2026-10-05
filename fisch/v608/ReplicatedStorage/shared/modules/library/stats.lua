local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function ordered(p)
	count += 1
	p.Order = count
	return p
end

return {
	Luck = ordered({
		DisplayName = "Luck",
		Suffix = "%"
	}),
	LuckMultiply = ordered({
		DisplayName = "Luck",
		Suffix = "×"
	}),
	Lure = ordered({
		DisplayName = "Lure Speed",
		Suffix = "%"
	}),
	Power = ordered({
		DisplayName = "Power"
	}),
	Handling = ordered({
		DisplayName = "Handling",
		Suffix = "%"
	}),
	Piercing = ordered({
		DisplayName = "Piercing",
		Suffix = "%"
	}),
	Range = ordered({
		DisplayName = "Range",
		Suffix = "m"
	}),
	Reload = ordered({
		DisplayName = "Reload Time",
		Suffix = "s"
	}),
	Velocity = ordered({
		DisplayName = "Velocity"
	}),
	Accuracy = ordered({
		DisplayName = "Accuracy"
	}),
	Strength = ordered({
		DisplayName = "Max KG",
		Suffix = "kg"
	}),
	Resilience = ordered({
		DisplayName = "Resilience",
		Suffix = "%"
	}),
	Control = ordered({
		DisplayName = "Control"
	}),
	ProgressSpeed = ordered({
		DisplayName = "Progress Speed",
		Suffix = "%"
	}),
	ForcedProgressSpeed = ordered({
		DisplayName = "Forced Progress Speed",
		Suffix = "%"
	}),
	TrueProgressSpeed = ordered({
		DisplayName = "True Progress Speed",
		Suffix = "%"
	}),
	Disturbance = ordered({
		DisplayName = "Disturbance"
	}),
	XpMultiply = ordered({
		DisplayName = "XP",
		Suffix = "%",
		Multiply = 100
	}),
	BaitPreserveChance = ordered({
		DisplayName = "Bait Preservation Chance",
		Suffix = "%"
	}),
	LineDistance = ordered({
		DisplayName = "Line Distance"
	}),
	Durability = ordered({
		DisplayName = "Durability"
	}),
	StartingProgress = ordered({
		DisplayName = "Starting Progress",
		Suffix = "%"
	}),
	Scavenging = ordered({
		DisplayName = "Scavenging",
		Suffix = "%"
	}),
	WeightBoost = ordered({
		DisplayName = "Fish Weight",
		Suffix = "%"
	}),
	NaturalMutationChance = ordered({
		DisplayName = "Natural Mutation Chance",
		Suffix = "%"
	}),
	MutationChanceBoost = ordered({
		DisplayName = "Universal Mutation Chance",
		Suffix = "%"
	}),
	ShinyChance = ordered({
		DisplayName = "Shiny Chance",
		Suffix = "%"
	}),
	SparklingChance = ordered({
		DisplayName = "Sparkling Chance",
		Suffix = "%"
	}),
	BaitEffectiveness = ordered({
		DisplayName = "Bait Effectiveness",
		Suffix = "×"
	}),
	TimeEffectiveness = ordered({
		DisplayName = "Time Effectiveness",
		Suffix = "×"
	}),
	WeatherEffectiveness = ordered({
		DisplayName = "Weather Effectiveness",
		Suffix = "×"
	}),
	SeasonEffectiveness = ordered({
		DisplayName = "Season Effectiveness",
		Suffix = "×"
	}),
	ShakeSize = ordered({
		DisplayName = "Shake Button Size",
		Suffix = "%"
	}),
	ShakePower = ordered({
		DisplayName = "Shake Button Power",
		Suffix = "%"
	}),
	PowerEfficiency = ordered({
		DisplayName = "Keeperbound Power Efficiency",
		Suffix = "%"
	})
}