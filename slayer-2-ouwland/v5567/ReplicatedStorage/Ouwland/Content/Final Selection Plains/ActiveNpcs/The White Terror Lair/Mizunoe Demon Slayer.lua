local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local MizunoeDemonSlayerSettings = require(script.Parent.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("MizunoeDemonSlayerSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Mizunoe Demon Slayer",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = MizunoeDemonSlayerSettings.Spawns,
			SpawnTime = MizunoeDemonSlayerSettings.SpawnTime,
			DespawnDistance = MizunoeDemonSlayerSettings.DespawnDistance,
			Center = MizunoeDemonSlayerSettings.Center,
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
		Settings = MizunoeDemonSlayerSettings.Settings
	}
}