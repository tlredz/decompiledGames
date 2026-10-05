local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://119963102832025",
	Marker = true,
	Requirements = {
		Level = 10
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://136737750312075" }
	},
	Spawns = { CFrame.new(714, 1121, -808, 0.872028112, 0, 0.48945576, 0, 1, 0, -0.48945576, 0, 0.872028112) }
}