local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://102950460729187",
	Marker = true,
	Requirements = {
		Level = 10
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://113178351451807" }
	},
	Spawns = { CFrame.new(-615.499939, 1258.5, -1177.49988, -1, 0, 0, 0, 1, 0, 0, 0, -1) }
}