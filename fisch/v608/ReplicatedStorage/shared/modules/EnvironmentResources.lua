require("@self/Types")
return {
	Resources = {
		Oxygen = {
			Name = "Oxygen",
			DisplayOrder = 1,
			InverseDirection = false,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 0,
			BaseDamagePerSecond = 20,
			DamageTag = "Drowning",
			AlwaysEnabled = true,
			RightSide = false,
			Icon = "rbxassetid://122732093099491",
			BarColor = ColorSequence.new(Color3.fromRGB(124, 154, 181), Color3.fromRGB(81, 107, 141)),
			HighlightColor = Color3.fromRGB(174, 216, 255),
			BackgroundColor = Color3.fromRGB(0, 42, 62)
		},
		OxygenPeaks = {
			Name = "OxygenPeaks",
			DisplayOrder = 2,
			InverseDirection = false,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 10,
			BaseDamagePerSecond = 20,
			DamageTag = "Oxygen Deprivation",
			EnabledZones = {
				"Northern Summit",
				"Overgrowth Caves",
				"Frigid Cavern",
				"Cryogenic Canal",
				"Glacial Grotto"
			},
			RightSide = false,
			Icon = "rbxassetid://101516559973672",
			BarColor = ColorSequence.new(Color3.fromRGB(158, 182, 213), Color3.fromRGB(114, 143, 170)),
			HighlightColor = Color3.fromRGB(174, 216, 255),
			BackgroundColor = Color3.fromRGB(24, 42, 80)
		},
		Pressure = {
			Name = "Pressure",
			DisplayOrder = 3,
			InverseDirection = true,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 10,
			BaseDamagePerSecond = 20,
			EnabledZones = { "Underwater Opening", "Underwater Cave" },
			RightSide = false,
			Icon = "rbxassetid://129358343439035",
			BarColor = ColorSequence.new(Color3.fromRGB(72, 40, 124), Color3.fromRGB(46, 41, 124)),
			HighlightColor = Color3.fromRGB(124, 107, 255),
			BackgroundColor = Color3.fromRGB(23, 0, 50)
		},
		Heat = {
			Name = "Heat",
			DisplayOrder = 4,
			InverseDirection = true,
			BaseMin = 37,
			BaseMax = 44,
			BaseReplenish = 0.1,
			BaseDamagePerSecond = 5,
			TextFormat = "%dº",
			DamageTag = "Hyperthermia",
			AlwaysEnabled = true,
			RightSide = true,
			Icon = "rbxassetid://80275929100256",
			BarColor = ColorSequence.new(Color3.fromRGB(255, 161, 66), Color3.fromRGB(220, 55, 55)),
			HighlightColor = Color3.fromRGB(255, 204, 75),
			BackgroundColor = Color3.fromRGB(52, 26, 0)
		},
		Cold = {
			Name = "Cold",
			DisplayOrder = 5,
			InverseDirection = false,
			BaseMin = 32,
			BaseMax = 37,
			BaseReplenish = 0.1,
			BaseDamagePerSecond = 5,
			TextFormat = "%dº",
			DamageTag = "Hypothermia",
			AlwaysEnabled = true,
			RightSide = true,
			Icon = "rbxassetid://102308304633503",
			BarColor = ColorSequence.new(Color3.fromRGB(165, 224, 255), Color3.fromRGB(203, 251, 255)),
			HighlightColor = Color3.fromRGB(221, 241, 255),
			BackgroundColor = Color3.fromRGB(22, 43, 44)
		},
		Decay = {
			Name = "Decay",
			DisplayOrder = 6,
			InverseDirection = true,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 10,
			EnabledZones = { "Oscar's Locker" },
			RightSide = true,
			Icon = "rbxassetid://98581677734463",
			BarColor = ColorSequence.new(Color3.fromRGB(74, 180, 108), Color3.fromRGB(56, 140, 119)),
			HighlightColor = Color3.fromRGB(105, 255, 153),
			BackgroundColor = Color3.fromRGB(0, 44, 23)
		},
		ToxicFumes = {
			Name = "ToxicFumes",
			DisplayOrder = 7,
			InverseDirection = true,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 10,
			BaseDamagePerSecond = 100,
			DamageTag = "Poison",
			EnabledZones = { "Lost Jungle", "Toxic Grove", "Toxic Cave" },
			RightSide = true,
			Icon = "rbxassetid://99237446118780",
			BarColor = ColorSequence.new(Color3.fromRGB(128, 50, 168), Color3.fromRGB(80, 20, 120)),
			HighlightColor = Color3.fromRGB(200, 120, 255),
			BackgroundColor = Color3.fromRGB(30, 0, 50)
		},
		PoseidonCharge = {
			Name = "PoseidonCharge",
			DisplayOrder = 8,
			InverseDirection = true,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 0,
			NoDamage = true,
			EnabledZones = { "Poseidon's Storm of Floods" },
			EnabledAttributes = { "DeadMansPassiveActive" },
			RightSide = false,
			Icon = "rbxassetid://",
			BarColor = ColorSequence.new(Color3.fromRGB(30, 120, 200), Color3.fromRGB(20, 80, 160)),
			HighlightColor = Color3.fromRGB(100, 200, 255),
			BackgroundColor = Color3.fromRGB(0, 30, 60)
		},
		OlympianFissurePoseidonCharge = {
			Name = "OlympianFissurePoseidonCharge",
			DisplayOrder = 9,
			InverseDirection = true,
			BaseMin = 0,
			BaseMax = 100,
			BaseReplenish = 0,
			NoDamage = true,
			EnabledZones = { "Olympian Fissure" },
			RightSide = false,
			Icon = "rbxassetid://",
			BarColor = ColorSequence.new(Color3.fromRGB(141, 23, 23), Color3.fromRGB(75, 7, 7)),
			HighlightColor = Color3.fromRGB(255, 130, 130),
			BackgroundColor = Color3.fromRGB(22, 0, 0)
		}
	},
	Modifiers = {
		{
			Resource = "Oxygen",
			SourceType = "Scriptable",
			ModifierType = "Scriptable",
			Name = "Water",
			DefaultValue = 9
		},
		{
			Resource = "Oxygen",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "DrowningWater",
			DefaultValue = 85
		},
		{
			Resource = "Oxygen",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefBasicGear",
			DefaultValue = 0.125
		},
		{
			Resource = "Oxygen",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefAdvancedGear",
			DefaultValue = 0.06666666666666667
		},
		{
			Resource = "Oxygen",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "WaterBubbleEquipped",
			DefaultValue = 0.03333333333333333
		},
		{
			Resource = "Oxygen",
			SourceType = "Attribute",
			ModifierType = "ForceDecay",
			Name = "InDrowningWhirlpool",
			DefaultValue = 9
		},
		{
			Resource = "Oxygen",
			SourceType = "Attribute",
			ModifierType = "ForceDecay",
			Name = { "NoWaterZone", "DisableOxygen" },
			DefaultValue = -100
		},
		{
			Resource = "Oxygen",
			SourceType = "ProximityTag",
			ModifierType = "AddRate",
			Name = "AirBubble",
			DefaultValue = -40
		},
		{
			Resource = "Oxygen",
			SourceType = "TaggedParts",
			ModifierType = "ForceDecay",
			Name = "BreathableAir",
			DefaultValue = -100
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Overgrowth Caves",
			DefaultValue = 0.75
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Frigid Cavern",
			DefaultValue = 2
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Cryogenic Canal",
			DefaultValue = 3.5
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Glacial Grotto",
			DefaultValue = 5
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefOxygen1",
			DefaultValue = 0.3333333333333333
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefOxygen2",
			DefaultValue = 0.125
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefOxygen3",
			DefaultValue = 0.07142857142857142
		},
		{
			Resource = "OxygenPeaks",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "DefOxygen4",
			DefaultValue = 0.05
		},
		{
			Resource = "Pressure",
			SourceType = "Scriptable",
			ModifierType = "Scriptable",
			Name = "Pressure",
			DefaultValue = 0.25
		},
		{
			Resource = "Pressure",
			SourceType = "Attribute",
			ModifierType = "MultiplyDecay",
			Name = "AbyssalTonicActive",
			DefaultValue = 0.2
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Volcanic Vents",
			DefaultValue = 0.005
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Scoria Reach",
			DefaultValue = 0.02
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Ashbrook Town",
			DefaultValue = 0.019
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Scoria Mines",
			DefaultValue = 0.773
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Scoria Volcano",
			DefaultValue = 0.773
		},
		{
			Resource = "Heat",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = "Drylands",
			DefaultValue = 0.005
		},
		{
			Resource = "Heat",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = { "Glimmerfin1", "Glimmerfin2", "Glimmerfin3" },
			DefaultValue = -0.01
		},
		{
			Resource = "Heat",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "DefScoriaArmor",
			DefaultValue = -0.75
		},
		{
			Resource = "Heat",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "DefDunehavenWraps",
			DefaultValue = -0.009
		},
		{
			Resource = "Heat",
			SourceType = "ProximityTag",
			ModifierType = "AddRate",
			Name = "HeatEmitter",
			DefaultValue = 1
		},
		{
			Resource = "Heat",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "FreezingWaterTempHeat",
			DefaultValue = 0
		},
		{
			Resource = "Heat",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "FireDebuffTemp",
			DefaultValue = 0
		},
		{
			Resource = "Heat",
			SourceType = "Scriptable",
			ModifierType = "Scriptable",
			Name = "Water",
			DefaultValue = -0.5
		},
		{
			Resource = "Cold",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = { "Challenger's Deep", "Overgrowth Caves" },
			DefaultValue = 0.01
		},
		{
			Resource = "Cold",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = { "Frigid Cavern" },
			DefaultValue = 0.02
		},
		{
			Resource = "Cold",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = { "Cryogenic Canal" },
			DefaultValue = 0.03
		},
		{
			Resource = "Cold",
			SourceType = "Zone",
			ModifierType = "AddRate",
			Name = { "Glacial Grotto", "Boreal Pines", "Crystal Fissure" },
			DefaultValue = 0.04
		},
		{
			Resource = "Cold",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = {
				"WinterCloakEquipped",
				"UglySweater",
				"Glimmerfin2",
				"Glimmerfin3"
			},
			DefaultValue = -0.05
		},
		{
			Resource = "Cold",
			SourceType = "ProximityTag",
			ModifierType = "AddRate",
			Name = "WarmSpot",
			DefaultValue = -1
		},
		{
			Resource = "Cold",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "FreezingWaterTemp",
			DefaultValue = 0
		},
		{
			Resource = "Cold",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "FireDebuffTempCold",
			DefaultValue = 0
		},
		{
			Resource = "Decay",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "Deterioration",
			DefaultValue = 20
		},
		{
			Resource = "Decay",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "BlockDeterioration",
			DefaultValue = -25
		},
		{
			Resource = "ToxicFumes",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "ToxicFumes",
			DefaultValue = 50
		},
		{
			Resource = "ToxicFumes",
			SourceType = "Attribute",
			ModifierType = "AddRate",
			Name = "GasMaskEquipped",
			DefaultValue = -60
		},
		{
			Resource = "ToxicFumes",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "ToxicWater",
			DefaultValue = 80
		},
		{
			Resource = "ToxicFumes",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "SuperDeadlyToxicWater",
			DefaultValue = 260
		},
		{
			Resource = "PoseidonCharge",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "PoseidonChargeZone",
			DefaultValue = 0.8333333333333334
		},
		{
			Resource = "OlympianFissurePoseidonCharge",
			SourceType = "TaggedParts",
			ModifierType = "AddRate",
			Name = "OlympianFissurePoseidonChargeZone",
			DefaultValue = 0.8333333333333334
		}
	}
}