local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
return {
	schoolBookAssetName = "SchoolBook",
	bookSpawnZoneName = "BookSpawnZone",
	schoolBooks = {
		orbTemplate = "AdminAbuse/20Anniversary/Years/2016/SchoolBook",
		spawnIntervalMinSeconds = 0.5,
		spawnIntervalMaxSeconds = 1,
		orbsPerWave = 5,
		initialOrbsPerPlayer = 112,
		maxActivePerPlayer = 192,
		orbLifetimeSeconds = 50,
		hoverHeightStuds = 2,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	schoolBookAward = {
		source = "20YearsEvent:2016:SchoolBook",
		multiplier = 0.5
	}
}