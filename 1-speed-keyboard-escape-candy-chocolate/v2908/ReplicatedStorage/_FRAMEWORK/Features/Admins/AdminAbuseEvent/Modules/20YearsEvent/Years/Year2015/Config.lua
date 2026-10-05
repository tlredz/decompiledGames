local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
return {
	axeAssetName = "Axe",
	treeAssetName = "GoldenTree",
	treeSpawnZoneName = "TreeSpawnZone",
	swingAnimationName = "Swing",
	chopSoundName = "Chop",
	fallSoundName = "Fall",
	toolName = "Golden Axe",
	toolTip = "Chop the golden trees!",
	spawnIntervalSeconds = 5,
	treesPerWave = 5,
	initialTrees = 25,
	maxActiveTrees = 45,
	treeLifetimeSeconds = 50,
	spawnAttempts = 10,
	zoneEdgeMarginStuds = 14,
	minTreeSeparationStuds = 26,
	minPlayerSeparationStuds = 12,
	raycastHeightStuds = 0,
	raycastDepthStuds = 80,
	treeHitPoints = 4,
	swingCooldownSeconds = 0.45,
	chopReachStuds = 16,
	chopFacingDot = 0.3,
	shedLifetimeSeconds = 3,
	shedImpulseStuds = 28,
	shedUpwardStuds = 18,
	shedSpinRadians = 6,
	charredColor = Color3.fromRGB(28, 24, 22),
	charredMaterial = Enum.Material.Slate,
	treesFolderName = "GoldenTrees",
	shedFolderName = "Shed",
	fallYawAttributeName = "FallYaw",
	fallPushStuds = 14,
	fallDespawnDelaySeconds = 3,
	chopAward = {
		source = "20YearsEvent:2015:GoldenTree",
		multiplier = 1
	},
	fellAward = {
		source = "20YearsEvent:2015:GoldenTree",
		multiplier = 5
	},
	orbSpawnZoneName = "OrbSpawnZone",
	winOrbs = {
		orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
		spawnIntervalMinSeconds = 0.5,
		spawnIntervalMaxSeconds = 1,
		orbsPerWave = 6,
		initialOrbsPerPlayer = 140,
		maxActivePerPlayer = 240,
		orbLifetimeSeconds = 60,
		hoverHeightStuds = 2,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	winOrbAward = {
		source = "20YearsEvent:2015:WinOrb",
		multiplier = 0.5
	}
}