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
	Spawns = { CFrame.new(1827.212, 1616.207, 119.746) * CFrame.Angles(0, -2.792526803190927, 0) }
}