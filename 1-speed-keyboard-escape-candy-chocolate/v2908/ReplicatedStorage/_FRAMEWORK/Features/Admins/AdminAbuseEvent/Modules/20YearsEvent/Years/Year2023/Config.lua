local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
return {
	swordAssetName = "LinkedSword",
	ballAssetName = "Ball",
	swingSoundName = "SwordSlash",
	toolName = "Linked Sword",
	toolTip = "Swing to launch a ball at the nearest player!",
	swingCooldownSeconds = 0.8,
	targetRangeStuds = 150,
	targetConeDot = 0.5,
	noTargetRangeStuds = 60,
	launchForwardStuds = 4,
	launchUpStuds = 1,
	ballSpeedStuds = 60,
	minFlightSeconds = 0.8,
	ballEaseExponent = 1.4,
	arcSideRatioMin = 0.3,
	arcSideRatioMax = 0.6,
	arcUpRatio = 0.3,
	driftStartAlpha = 0.35,
	driftMaxStuds = 25,
	hitRadiusStuds = 4.5,
	ballDiameterStuds = 2.5,
	ballColor = Color3.fromRGB(255, 70, 70),
	trailLifetimeSeconds = 0.25,
	ballsFolderName = "Year2023Balls",
	flingHorizontalSpeed = 30,
	flingVerticalSpeed = 45,
	flingSpeedJitter = 0.3,
	flingAngularSpeed = 18,
	tripSeconds = 2,
	immunityGraceSeconds = 1,
	hitSoundId = "rbxassetid://173818824",
	hitSoundLifetimeSeconds = 4,
	hitAward = {
		source = "20YearsEvent:2023:BladeBall",
		multiplier = 15
	},
	orbSpawnZoneName = "OrbSpawnZone",
	winOrbs = {
		orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
		spawnIntervalMinSeconds = 0.5,
		spawnIntervalMaxSeconds = 1,
		orbsPerWave = 9,
		initialOrbsPerPlayer = 90,
		maxActivePerPlayer = 225,
		orbLifetimeSeconds = 60,
		hoverHeightStuds = 2,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	winOrbAward = {
		source = "20YearsEvent:2023:WinOrb",
		multiplier = 0.5
	}
}