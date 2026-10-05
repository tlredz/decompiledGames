local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return remo.createRemotes({
	TeleportToStage = remo.remote(),
	GetStages = remo.remote().returns()
})