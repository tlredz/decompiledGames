local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage:WaitForChild("Chest"):WaitForChild("Modules")
local WorldsId = require(modules.WorldsId)
return {
	[WorldsId.Testing.GoldenArena] = true,
	[WorldsId.KingLegacy.GoldenArena] = true
}