local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(1814, 659, -516) * CFrame.Angles(0, 3.141592653589793, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Yagane",
	Icon = "rbxassetid://130580436002764",
	Marker = true,
	Appearance = script:FindFirstChild("Model"),
	Animations = {},
	Spawns = { v }
}