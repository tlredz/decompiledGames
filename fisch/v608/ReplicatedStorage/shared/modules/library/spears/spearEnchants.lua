local module = require("../SharedEnchants")
local enchants = {
	Pointy = {
		Description = "Increases Power by <$PercentBoosts.Power$>% & Piercing by +<$Piercing$>%",
		Color = Color3.fromRGB(224, 102, 102),
		StrokeColor = Color3.fromRGB(135, 47, 47),
		Display = "Pointy",
		PercentBoosts = {
			Power = 25
		},
		Piercing = 15,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Blunted = {
		Description = "Increases Handling by +<$Handling$>%, but decreases Power by <$Power$> & Piercing by <$Piercing$>%",
		Color = Color3.fromRGB(209, 166, 122),
		StrokeColor = Color3.fromRGB(140, 103, 60),
		Display = "Blunted",
		Handling = 25,
		Power = -5,
		Piercing = -10,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Lunging = {
		Description = "Increases Spear Range by <$PercentBoosts.Range$>%",
		Color = Color3.fromRGB(109, 158, 235),
		StrokeColor = Color3.fromRGB(58, 72, 153),
		Display = "Lunging",
		PercentBoosts = {
			Range = 50
		},
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Savage = {
		Description = "<$ClientFishingPassives.Savage.TriggerChance$>% chance to strike twice on an input",
		Color = Color3.fromRGB(204, 65, 37),
		StrokeColor = Color3.fromRGB(131, 27, 18),
		Display = "Savage",
		ClientFishingPassives = {
			Savage = {
				TriggerChance = 25
			}
		},
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Frenzy = {
		Description = "Every successful input in a row increases Progress Speed by <$ClientFishingPassives.Frenzy.ProgressSpeed$>%",
		Color = Color3.fromRGB(103, 78, 167),
		StrokeColor = Color3.fromRGB(87, 105, 226),
		Display = "Frenzy",
		ClientFishingPassives = {
			Frenzy = {
				ProgressSpeed = 10
			}
		},
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Splintered = {
		Description = "Increases Piercing by <$Piercing$>%, but decreases Handling by <$Handling$>%",
		Color = Color3.fromRGB(150, 81, 74),
		StrokeColor = Color3.fromRGB(85, 46, 42),
		Display = "Splintered",
		Piercing = 25,
		Handling = -10,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Superior = {
		Description = "Increases all stats by <$AllStatsPercent$>%",
		Color = Color3.fromRGB(52, 255, 208),
		StrokeColor = Color3.fromRGB(208, 255, 245),
		ForceStroke = true,
		Display = "Superior",
		AllStatsPercent = 20,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Forgiving = {
		Description = "Any input counts towards progress after <$ClientFishingPassives.Forgiving.RequiredCorrect$> correct inputs in a row",
		Color = Color3.fromRGB(213, 166, 189),
		StrokeColor = Color3.fromRGB(127, 84, 106),
		Display = "Forgiving",
		ClientFishingPassives = {
			Forgiving = {
				RequiredCorrect = 5
			}
		},
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	},
	Sharpened = {
		Description = "Increases Power & Piercing by <$Power$>%",
		Color = Color3.fromRGB(65, 112, 200),
		StrokeColor = Color3.fromRGB(39, 48, 130),
		Display = "Sharpened",
		Power = 5,
		Piercing = 5,
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	},
	Finisher = {
		Description = "Increases all stats by 50% beyond 70% progress",
		Color = Color3.fromRGB(241, 210, 50),
		StrokeColor = Color3.fromRGB(171, 117, 31),
		Display = "Finisher",
		ClientFishingPassives = {
			Finisher = {
				ProgressThreshold = 70,
				StatMultiplier = 1.5,
				ModifierNames = {
					"power",
					"handling",
					"piercing",
					"resilience",
					"progressefficiency"
				}
			}
		},
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	}
}
return module.new({
	Enchants = enchants,
	PercentStats = {
		"Power",
		"Handling",
		"Piercing",
		"Range"
	},
	EnsureStats = {
		"ShinyChance",
		"SparklingChance",
		"WeightBoost",
		"ProgressSpeed"
	}
})