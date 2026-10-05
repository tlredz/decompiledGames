local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local cframe = CFrame.new(-1814.339, 311.801, -101.066, -1, 0, 0, 0, 1, 0, 0, 0, -1)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://117393968853057",
	Marker = true,
	Requirements = {
		Level = 70
	},
	Appearance = script:FindFirstChild("Model"),
	Spawns = { cframe }
}