local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local FireProfoundDemonSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("FireProfoundDemonSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Fire Profound Demon",
	Quantity = 3,
	SendOver = {
		Spawning = {
			Locations = FireProfoundDemonSettings.Spawns,
			SpawnTime = FireProfoundDemonSettings.SpawnTime,
			DespawnDistance = FireProfoundDemonSettings.DespawnDistance,
			Center = FireProfoundDemonSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Iceveil Valley"].FireProfoundDemon
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 100
		},
		Settings = FireProfoundDemonSettings.Settings
	}
}