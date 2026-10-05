local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
return {
	scriptablesFolderName = "Scriptables",
	chestsFolderName = "Chests",
	promptName = "ChestPrompt",
	chestIdAttributeName = "ChestId",
	promptActionText = "Open",
	promptObjectText = "Treasure Chest",
	promptHoldSeconds = 0.5,
	promptDistanceStuds = 10,
	maxOpenDistanceStuds = 18,
	chestAward = {
		source = "20YearsEvent:2018:Chest",
		multiplier = 10
	},
	orbSpawnZoneName = "OrbSpawnZone",
	winOrbs = {
		orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
		spawnIntervalMinSeconds = 0.5,
		spawnIntervalMaxSeconds = 1,
		orbsPerWave = 13,
		initialOrbsPerPlayer = 225,
		maxActivePerPlayer = 225,
		orbLifetimeSeconds = 60,
		hoverHeightStuds = 2,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	winOrbAward = {
		source = "20YearsEvent:2018:WinOrb",
		multiplier = 0.5
	}
}