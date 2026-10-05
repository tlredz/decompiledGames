local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Obari",
	Icon = "rbxassetid://78844218100909",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(770.518, 1121, -1047.036) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(770.518, 1121, -1047.036),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Obari
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Obari"
		}
	}
}