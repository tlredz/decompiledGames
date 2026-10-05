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
	Spawns = { CFrame.new(-2621.62964, 284.067505, -203.029007, -1, 0, 0, 0, 1, 0, 0, 0, -1) }
}