local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return remo.createRemotes({
	AlienAbductRequest = remo.remote(),
	AlienStop = remo.remote()
})