local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remo = require(ReplicatedStorage.Packages.remo)
return (remo.createRemotes({
	ChangeStage = remo.remote(),
	SetStageTimePosition = remo.remote(),
	Ready = remo.remote()
}))