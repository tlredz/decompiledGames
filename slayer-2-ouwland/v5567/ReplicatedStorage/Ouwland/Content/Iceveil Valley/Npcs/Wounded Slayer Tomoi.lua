local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local cframe = CFrame.new(485.340332, 1222.61743, -1812.99634, -4.37113883e-8, 0, 1, 0, 1, 0, -1, 0, -4.37113883e-8)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://93885945754716",
	Marker = true,
	Requirements = {
		Race = { "Slayer", "Hybrid" },
		Level = 90
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://91826854825928" }
	},
	Spawns = { cframe }
}