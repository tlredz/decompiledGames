local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local KanoeDemonSlayerSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("KanoeDemonSlayerSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Kanoe Demon Slayer",
	Quantity = 8,
	SendOver = {
		Spawning = {
			Locations = KanoeDemonSlayerSettings.Spawns,
			SpawnTime = KanoeDemonSlayerSettings.SpawnTime,
			DespawnDistance = KanoeDemonSlayerSettings.DespawnDistance,
			Center = KanoeDemonSlayerSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs.Mizunoto:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 45,
			LetGoDistance = 140,
			AggroValidator = "DemonRaces",
			NpcsPerPlayer = 1
		},
		Settings = KanoeDemonSlayerSettings.Settings
	}
}