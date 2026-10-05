local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
local BunchaIcons = require(game.ReplicatedStorage.CAM.Global.BunchaIcons)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = BunchaIcons.FinalSelectionSisters,
	Marker = false,
	NameTag = false,
	Dialogue = false,
	Appearance = script.Model,
	Animations = {
		idle = { "rbxassetid://10586618784" }
	},
	Spawns = { CFrame.new(-2629.62744, 284.019318, -203.147003, -1, 0, 0, 0, 1, 0, 0, 0, -1) }
}