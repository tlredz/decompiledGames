local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Gyutai",
	Icon = "rbxassetid://109390346292090",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-266.118, 1043.237, -1139.734) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-266.118, 1043.237, -1139.734),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Gyutai
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Gyutai"
		}
	}
}