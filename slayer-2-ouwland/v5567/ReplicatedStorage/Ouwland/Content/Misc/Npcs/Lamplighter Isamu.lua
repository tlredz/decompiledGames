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
		idle = { "rbxassetid://83241418829766" }
	},
	Spawns = { CFrame.new(1082.206, 1425.703, -749.032) * CFrame.Angles(0, 0, 0) },
	WorldEvent = {
		Name = "FirstlightLantern"
	}
}