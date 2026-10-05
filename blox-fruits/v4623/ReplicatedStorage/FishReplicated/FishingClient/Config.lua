local function rgb255RichText(data)
	local v = math.round(data.R * 255)
	local v2 = math.round(data.G * 255)
	local v3 = math.round(data.B * 255)
	return string.format("rgb(%d, %d, %d)", v, v2, v3)
end

return {
	WATER_BODY_TAG = "WaterBody",
	FISHING_ROD_NAME = "Fishing Rod",
	Minigame = {
		FishMovementSpeed = 0.15,
		FishAcceleration = 0.05,
		PlayerMovementSpeed = 0.0225,
		PlayerAcceleration = 0.0525,
		ProgressGainRate = 0.0025,
		ProgressLossRate = 0.003,
		AlwaysShowTreasure = false,
		TreasureMinSpawnTime = 2,
		TreasureMaxSpawnTime = 4,
		TreasureGainRate = 0.03,
		TreasureLossRate = 0.02,
		FishBarHeight = 0.1,
		PlayerBarHeight = 0.15,
		ChestBarHeight = 0.1,
		InitialProgress = 0.5,
		BiteDelayMin = 3,
		BiteDelayMax = 12,
		BiteWindowMin = 1.25,
		BiteWindowMax = 2,
		FishTargetChangeMin = 0.5,
		FishTargetChangeMax = 3,
		EnableBiteDelay = true,
		TimeToMaxChaos = 60,
		MaxChaosMultiplier = 5
	},
	Rod = {
		MaxLaunchDistance = 32.5
	},
	RarityColors = {
		[0] = "Common",
		[1] = "Uncommon",
		[2] = "Rare",
		[3] = "Legendary",
		[4] = "Mythical"
	},
	RichTextColors = {},
	RgbRichText = rgb255RichText
}