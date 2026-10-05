local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-207.065, 1349.646, -2423.003) * CFrame.Angles(0, -0.040334559013588955, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://119622412987549",
	Marker = true,
	Requirements = {
		Level = 105
	},
	Appearance = script:FindFirstChild("Model"),
	Spawns = { v }
}