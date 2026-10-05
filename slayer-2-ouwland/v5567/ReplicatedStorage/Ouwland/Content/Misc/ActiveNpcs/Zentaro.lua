local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Zentaro",
	Icon = "rbxassetid://78571334992349",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(1332.091, 821.5, -1017.637) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(1332.091, 821.5, -1017.637),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Zentaro
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Zentaro"
		}
	}
}