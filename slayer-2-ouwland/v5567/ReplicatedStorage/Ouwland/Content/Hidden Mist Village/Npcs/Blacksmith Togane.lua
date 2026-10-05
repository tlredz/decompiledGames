local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(1732.068, 694, -764.554) * CFrame.Angles(0, 3.0543261909900767, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Blacksmith Togane",
	Icon = "rbxassetid://121620215283606",
	Marker = true,
	Requirements = {
		Level = 65
	},
	ModelAttributes = {
		NoDialogueTurn = true
	},
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://121042708991853" }
	},
	Spawns = { v }
}