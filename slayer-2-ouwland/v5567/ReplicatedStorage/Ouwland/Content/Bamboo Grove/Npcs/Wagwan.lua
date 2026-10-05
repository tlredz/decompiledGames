local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://87464707480133",
	Marker = true,
	Requirements = {
		Level = 40
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://90291812954025" }
	},
	Spawns = { CFrame.new(723.761536, 1019.19946, -801.984009, -0.999999881, 0, 0, 0, 0.999999881, 0, 0, 0, -1) }
}