local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-967.639, 1028.702, 1188.217) * CFrame.Angles(0, 3.0543261909900767, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Flame Trainer Rengu",
	Icon = "rbxassetid://98063060860768",
	Requirements = {
		Level = 25
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://128491476076246" }
	},
	Spawns = { v }
}