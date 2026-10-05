local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(2578.583, 1095.806, -828.401) * CFrame.Angles(0, 3.141592653589793, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Stone Trainer Gyorei",
	Icon = "rbxassetid://122921780565487",
	Requirements = {
		Level = 25
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://85759143708964" }
	},
	Spawns = { v }
}