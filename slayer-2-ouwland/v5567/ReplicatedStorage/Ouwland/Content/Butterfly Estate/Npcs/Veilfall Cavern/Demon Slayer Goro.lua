local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-871.97, 234.75, 318.469) * CFrame.Angles(0, -2.9670597283903604, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://137177540560157",
	Marker = true,
	Requirements = {
		Race = { "Slayer", "Hybrid" },
		Level = 75
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://129529377840424" }
	},
	Spawns = { v }
}