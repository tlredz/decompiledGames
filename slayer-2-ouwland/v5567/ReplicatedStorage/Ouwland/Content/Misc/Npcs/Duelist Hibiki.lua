local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Marker = false,
	Appearance = script:FindFirstChild("Model"),
	WorldEvent = {
		Name = "CleaverDuel"
	},
	Spawns = { CFrame.new(-1233.792, 1427.381, -4592.84) * CFrame.Angles(0, 1.5707963267948966, 0) }
}