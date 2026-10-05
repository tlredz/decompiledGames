local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local MizunotoSettings = require(script.Parent.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("MizunotoSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Mizunoto",
	Quantity = 5,
	SendOver = {
		Spawning = {
			Locations = MizunotoSettings.Spawns,
			SpawnTime = MizunotoSettings.SpawnTime,
			DespawnDistance = MizunotoSettings.DespawnDistance,
			Center = MizunotoSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs.Mizunoto:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 45,
			LetGoDistance = 140,
			AggroValidator = "DemonRaces"
		},
		Settings = MizunotoSettings.Settings
	}
}