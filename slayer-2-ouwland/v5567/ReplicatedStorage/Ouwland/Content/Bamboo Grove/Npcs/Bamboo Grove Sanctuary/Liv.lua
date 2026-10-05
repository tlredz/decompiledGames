local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://72969862766213",
	Marker = true,
	Requirements = {
		Level = 14
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://74848208467606" }
	},
	ModelAttributes = {
		NoDialogueAnim = true
	},
	Spawns = { CFrame.new(
			657.363281,
			1018.70026,
			139.748718,
			0.352788359,
			0,
			-0.935703218,
			0,
			1,
			0,
			0.935703218,
			0,
			0.352788359
		) }
}