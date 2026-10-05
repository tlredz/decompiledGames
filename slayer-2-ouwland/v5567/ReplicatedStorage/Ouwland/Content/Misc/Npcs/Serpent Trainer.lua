local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(36.956, 1311.243, -1179.5) * CFrame.Angles(0, 3.141592653589793, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Serpent Trainer Obari",
	Icon = "rbxassetid://118764283000101",
	Requirements = {
		Level = 25
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://126652254543122" }
	},
	Spawns = { v }
}