local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return remo.createRemotes({
	SettingsAction = remo.remote()
})