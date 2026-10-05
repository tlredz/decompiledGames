local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Packages.Signal)
return {
	Reveal = Signal.new(),
	ShowTutorial = Signal.new()
}