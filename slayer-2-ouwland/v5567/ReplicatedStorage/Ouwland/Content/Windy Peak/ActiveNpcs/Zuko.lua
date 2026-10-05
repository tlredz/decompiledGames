local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BanditSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("BanditSettings"))
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Zuko",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true
		},
		Spawning = {
			Locations = { vector.create(-283.311, 1224.2, -1032.39) },
			SpawnTime = 135,
			DespawnDistance = BanditSettings.DespawnDistance,
			Center = BanditSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Windy Peak"].Zuko
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Zuko"
		}
	}
}