local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Sumari",
	Icon = "rbxassetid://139247548136868",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(396.444, 1018, -620.403) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(396.444, 1018, -620.403),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Sumari
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Sumari"
		}
	}
}