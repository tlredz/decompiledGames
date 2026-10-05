local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BanditSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("BanditSettings"))
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Bandit",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = BanditSettings.Spawns,
			SpawnTime = BanditSettings.SpawnTime1,
			DespawnDistance = BanditSettings.DespawnDistance,
			Center = BanditSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Windy Peak"].KaruVillageBandit:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = BanditSettings.Settings
	}
}