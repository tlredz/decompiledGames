local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Akazo",
	Icon = "rbxassetid://93452648734236",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-1131.975, 1380.916, -1746.561) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-1131.975, 1380.916, -1746.561),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Akazo
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Akazo"
		}
	}
}