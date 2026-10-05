local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local IceProfoundDemonSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("IceProfoundDemonSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Ice Profound Demon",
	Quantity = 6,
	SendOver = {
		Spawning = {
			Locations = IceProfoundDemonSettings.Spawns,
			SpawnTime = IceProfoundDemonSettings.SpawnTime,
			DespawnDistance = IceProfoundDemonSettings.DespawnDistance,
			Center = IceProfoundDemonSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Iceveil Valley"].IceProfoundDemon
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 100
		},
		Settings = IceProfoundDemonSettings.Settings
	}
}