local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://130007467623437",
	Marker = true,
	Requirements = {
		Level = 10
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://10586618784" }
	},
	Spawns = { CFrame.new(
			507.230621,
			1121.41968,
			-970.192566,
			0.956137717,
			-0.0108698178,
			0.292716444,
			0,
			0.999311328,
			0.0371087156,
			-0.292918205,
			-0.0354810283,
			0.955479145
		) }
}