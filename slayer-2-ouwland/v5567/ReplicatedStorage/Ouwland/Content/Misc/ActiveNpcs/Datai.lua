local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Datai",
	Icon = "rbxassetid://101666209144226",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-165.5, 1043, -1137.5) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-165.5, 1043, -1137.5),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Datai
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Datai"
		}
	}
}