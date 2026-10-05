local Accessoryupgrades = {
	SurveyDevice_LightModule = {
		DisplayName = "High-Output Light Module",
		Description = "Provides light in the <b>Gloomy Crevice</b>",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(212, 189, 119),
		IconRectOffset = Vector2.new(0, 0),
		IconRectSize = Vector2.new(16, 16),
		Attribute = "LightModuleEnhancer"
	},
	SurveyDevice_TrenchRunning = {
		DisplayName = "Trench Running Enhancer MK I",
		Description = "<b>+12 Movement Speed</b> while underwater",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(127, 178, 212),
		IconRectOffset = Vector2.new(16, 0),
		IconRectSize = Vector2.new(16, 16),
		Attribute = "TrenchRunningEnhancer",
		AttributeValue = 12
	},
	SurveyDevice_AccuracyChip = {
		DisplayName = "Calibration Chip MK I",
		Description = "<b>+10% Accuracy</b> on all Harpoon Guns",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(212, 182, 160),
		IconRectOffset = Vector2.new(32, 0),
		IconRectSize = Vector2.new(16, 16),
		FishingStats = {
			Accuracy = 10
		},
		FishingStatsTypes = { "harpoon" }
	},
	SurveyDevice_RangeChip = {
		DisplayName = "Range Chip MK I",
		Description = "<b>+32 Range</b> on all Harpoon Guns",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(147, 212, 137),
		IconRectOffset = Vector2.new(48, 0),
		IconRectSize = Vector2.new(16, 16),
		FishingStats = {
			Range = 32
		},
		FishingStatsTypes = { "harpoon" }
	},
	SurveyDevice_ResilienceChip = {
		DisplayName = "Stabilizer Chip MK I",
		Description = "<b>+15% Resilience</b> on all Harpoon Guns",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(205, 153, 212),
		IconRectOffset = Vector2.new(64, 0),
		IconRectSize = Vector2.new(16, 16),
		FishingStats = {
			Resilience = 15
		},
		FishingStatsTypes = { "harpoon" }
	},
	SurveyDevice_PowerChip = {
		DisplayName = "Power Chip MK I",
		Description = "<b>+5% Power</b> and <b>+100,000 Max KG</b> on all Harpoon Guns",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(212, 150, 155),
		IconRectOffset = Vector2.new(80, 0),
		IconRectSize = Vector2.new(16, 16),
		FishingStats = {
			Power = 5,
			Strength = 100000
		},
		FishingStatsTypes = { "harpoon" }
	},
	SurveyDevice_BuoyancyChip = {
		DisplayName = "Buoyancy Chip MK I",
		Description = "Hold your depth underwater; move up and down freely",
		Icon = "rbxassetid://122110093782324",
		IconColor = Color3.fromRGB(137, 190, 212),
		IconRectOffset = Vector2.new(96, 0),
		IconRectSize = Vector2.new(16, 16),
		Attribute = "BuoyancyStabilizer"
	}
}

for k, v in Accessoryupgrades do
	v.Id = k
end

return Accessoryupgrades