local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = "Shady Individual Rooyi",
	Icon = "rbxassetid://117686811946202",
	Marker = true,
	Requirements = {
		Race = { "Demon", "Hybrid" },
		Level = 62
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://83241418829766" }
	},
	Spawns = { CFrame.new(-772.937, 965.074, -8.564, 0.906, 0, -0.423, 0, 1, 0, 0.423, 0, 0.906) }
}