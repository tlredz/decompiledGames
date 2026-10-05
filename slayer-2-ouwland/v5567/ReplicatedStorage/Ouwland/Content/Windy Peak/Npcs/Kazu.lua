local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://139343077080160",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://10586618784" }
	},
	Spawns = { CFrame.new(-626, 1242.5, -1138, -1, 0, 0, 0, 1, 0, 0, 0, -1) }
}