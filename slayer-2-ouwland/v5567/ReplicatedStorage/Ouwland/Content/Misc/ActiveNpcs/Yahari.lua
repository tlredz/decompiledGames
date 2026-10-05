local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Yahari",
	Icon = "rbxassetid://77562210024440",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(825.678, 1019.2, -641.335) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(825.678, 1019.2, -641.335),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Yahari
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Yahari"
		}
	}
}