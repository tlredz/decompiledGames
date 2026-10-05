local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local v = CFrame.new(-1058.822, 1226.006, -955.657) * CFrame.Angles(0, -1.5707963267948966, 0)
return {
	Type = Menum.npcType.Stationary,
	Name = "Wagasa Maker Genzo",
	Marker = false,
	NameTag = false,
	Appearance = script:FindFirstChild("Model"),
	Animations = {
		idle = { "rbxassetid://116267866253223" }
	},
	ModelAttributes = {
		NoDialogueTurn = true,
		NoDialogueAnim = true
	},
	Spawns = { v },
	WorldEvent = {
		Name = "FirstlightWagasa"
	}
}