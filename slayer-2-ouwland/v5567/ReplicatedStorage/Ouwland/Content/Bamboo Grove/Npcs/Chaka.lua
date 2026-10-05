local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://119669744410416",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://101631644638110" }
	},
	Spawns = { CFrame.new(471, 1146, -1260, 0.591740668, 0, 0.806128383, 0, 1, 0, -0.806128383, 0, 0.591740668) }
}