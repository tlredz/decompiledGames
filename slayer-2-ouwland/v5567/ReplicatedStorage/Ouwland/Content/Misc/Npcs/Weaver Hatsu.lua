local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Marker = false,
	Appearance = script:FindFirstChild("Model"),
	ModelAttributes = {
		NoDialogueTurn = true
	},
	Animations = {
		idle = { "rbxassetid://129529377840424" }
	},
	Spawns = { CFrame.new(2281.171, 812.677, 14.746) * CFrame.Angles(0, 1.5707963267948966, 0) }
}