local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(139.614, 1254.197, -1911.295) * CFrame.Angles(0, -1.6868432687599997, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Icon = "rbxassetid://109030384838893",
	Marker = true,
	Requirements = {
		Race = { "Demon", "Hybrid" },
		Level = 90
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://83241418829766" }
	},
	Spawns = { v }
}