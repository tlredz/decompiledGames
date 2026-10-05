local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
return {
	Type = Menum.npcType.Stationary,
	Name = script.Name,
	Marker = false,
	Appearance = script:FindFirstChild("Model"),
	Spawns = { CFrame.new(1876, 659.047, -206) },
	WorldEvent = {
		Name = "GauntletStatues"
	}
}