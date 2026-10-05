local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-1798.94, 347.893, -189.344) * CFrame.Angles(0, 0, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Insect Trainer Shinora",
	Icon = "rbxassetid://106761322795530",
	Requirements = {
		Level = 25
	},
	Appearance = script:FindFirstChild("Model"),
	Spawns = { v }
}