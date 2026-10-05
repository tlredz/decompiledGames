local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-1212.575, 1387.474, -2371.557) * CFrame.Angles(0, 1.6535423866319479, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Harvester of Souls Zurinyz",
	Icon = "rbxassetid://74259714664576",
	Requirements = {
		Race = { "Demon", "Hybrid" },
		Level = 100
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://86565852659794" }
	},
	Spawns = { v }
}