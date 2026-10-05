local module = require("../SharedEnchants")
local enchants = {
	Weighted = {
		Description = "Increases Power by <$Power$>%",
		Color = Color3.fromRGB(153, 153, 153),
		StrokeColor = Color3.fromRGB(76, 76, 76),
		Display = "Weighted",
		Power = 25,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Deadeye = {
		Description = "Increases Accuracy by <$Accuracy$>% & Velocity by <$Velocity$>%",
		Color = Color3.fromRGB(230, 78, 56),
		StrokeColor = Color3.fromRGB(131, 50, 33),
		Display = "Deadeye",
		Accuracy = 20,
		Velocity = 20,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Ballistic = {
		Description = "Increases Velocity by <$Velocity$>% & Range by <$Range$>%",
		Color = Color3.fromRGB(241, 196, 57),
		StrokeColor = Color3.fromRGB(175, 82, 16),
		Display = "Ballistic",
		Velocity = 30,
		Range = 128,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Lightened = {
		Description = "Reduces Reload Time by <$PercentBoosts.Reload$>%, increases Velocity by <$Velocity$>%, and decreases Power by <$Power$>%",
		Color = Color3.fromRGB(129, 220, 234),
		StrokeColor = Color3.fromRGB(221, 249, 255),
		ForceStroke = true,
		Display = "Lightened",
		PercentBoosts = {
			Reload = 50
		},
		Velocity = 25,
		Power = -10,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Stable = {
		Description = "Increases Resilience by <$Resilience$>%",
		Color = Color3.fromRGB(118, 165, 175),
		StrokeColor = Color3.fromRGB(63, 88, 93),
		Display = "Stable",
		Resilience = 20,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Chainshot = {
		Description = "Perfect Catches increase Velocity, Resilience, and Progress Speed incrementally",
		Color = Color3.fromRGB(78, 116, 176),
		StrokeColor = Color3.fromRGB(45, 53, 91),
		Display = "Chainshot",
		FishingPassives = {
			Chainshot = {
				AttributeName = "CurrentChainshotBoost",
				BoostPerStack = 5,
				ReducePerImperfect = 20,
				MaxBoost = 40
			}
		},
		ConditionalBoosts = function(_, instance)
			return {
				ProgressSpeed = instance:GetAttribute("CurrentChainshotBoost") or 0,
				Velocity = instance:GetAttribute("CurrentChainshotBoost") or 0,
				Resilience = instance:GetAttribute("CurrentChainshotBoost") or 0
			}
		end,
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Barbed = {
		Description = "<$ClientFishingPassives.Generic_HarpoonSlashes.SlashChance$>% chance to instantly complete a PULL",
		Color = Color3.fromRGB(166, 28, 0),
		StrokeColor = Color3.fromRGB(56, 24, 14),
		Display = "Barbed",
		ClientFishingPassives = {
			Generic_HarpoonSlashes = {
				TriggerMode = "ButtonSpawn",
				SlashChance = 10,
				AllowMultipleClicks = true,
				MultiClickInterval = 0.1,
				SourceId = "Barbed",
				SoundName = "stabbystab",
				IconColor = Color3.fromRGB(196, 116, 63),
				GradientColor = Color3.fromRGB(232, 158, 96)
			}
		},
		RelicGroup = "Default",
		CanSelectFromAdmin = true
	},
	Polished = {
		Description = "Increases Shiny & Sparkling chances by <$ShinyChance$>% & all stats by <$AllStatsPercent$>%",
		Color = Color3.fromRGB(255, 230, 158),
		StrokeColor = Color3.fromRGB(168, 131, 94),
		ForceStroke = true,
		Display = "Polished",
		ShinyChance = 3,
		SparklingChance = 3,
		AllStatsPercent = 5,
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	},
	Reinforced = {
		Description = "Increases Resilience by <$Resilience$>% & Power by <$Power$>%, but decreases Velocity by 5%",
		Color = Color3.fromRGB(109, 109, 109),
		StrokeColor = Color3.fromRGB(38, 38, 38),
		Display = "Reinforced",
		Resilience = 10,
		Power = 10,
		Velocity = -5,
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	},
	Aberrant = {
		Description = "Increases mutation rates by <$MutationRate$>% & fluctuates fish size from -25% to +35%",
		Color = Color3.fromRGB(106, 168, 79),
		StrokeColor = Color3.fromRGB(60, 81, 38),
		Display = "Aberrant",
		MutationRate = 20,
		WeightBoost = 0,
		ConditionalBoosts = function(_, _)
			return {
				WeightBoost = math.random(-25, 35)
			}
		end,
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	},
	Foraging = {
		Description = "Increased chance for extra drops",
		Color = Color3.fromRGB(255, 191, 102),
		StrokeColor = Color3.fromRGB(56, 39, 13),
		Display = "Foraging",
		Scavenging = 300,
		Secondary = true,
		RelicGroup = "Cosmic",
		CanSelectFromAdmin = true
	}
}
return module.new({
	Enchants = enchants,
	PercentStats = {
		"Power",
		"Strength",
		"Range",
		"Reload",
		"Velocity",
		"Resilience",
		"Accuracy"
	},
	InverseStats = {
		Reload = true
	},
	EnsureStats = {
		"ShinyChance",
		"SparklingChance",
		"WeightBoost",
		"ProgressSpeed",
		"MutationRate"
	}
})