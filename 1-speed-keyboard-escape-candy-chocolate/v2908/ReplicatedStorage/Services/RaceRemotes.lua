local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return remo.createRemotes({
	RaceSetEnabled = remo.remote(),
	RaceAbort = remo.remote(),
	RacePersonalBest = remo.remote(),
	RaceVoided = remo.remote(),
	ChronoLeaderboardSync = remo.remote(),
	RaceLocalLeaderboardSync = remo.remote(),
	RaceSelfStats = remo.remote(),
	RaceStageCount = remo.remote()
})