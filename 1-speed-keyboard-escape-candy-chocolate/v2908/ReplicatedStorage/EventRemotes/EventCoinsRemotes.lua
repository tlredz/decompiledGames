local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return remo.createRemotes({
	EventCoinSpawn = remo.remote(),
	EventCoinDespawn = remo.remote(),
	EventCoinCollected = remo.remote(),
	EventCoinCollect = remo.remote(),
	EventCoinStormAnnounce = remo.remote()
})