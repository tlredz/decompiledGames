local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://91372298221911",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://80683301320042" }
	},
	Spawns = { CFrame.new(
			-791.602722,
			1260.07422,
			-1130.90991,
			0.766044319,
			0,
			-0.642787755,
			0,
			0.99999994,
			0,
			0.642787755,
			0,
			0.766044319
		) }
}