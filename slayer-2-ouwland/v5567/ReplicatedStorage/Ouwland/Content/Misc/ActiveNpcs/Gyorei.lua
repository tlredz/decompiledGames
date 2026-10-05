local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Gyorei",
	Icon = "rbxassetid://90757597716886",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(2574.568, 1089, -742.43) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(2574.568, 1089, -742.43),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Gyorei
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Gyorei"
		}
	}
}