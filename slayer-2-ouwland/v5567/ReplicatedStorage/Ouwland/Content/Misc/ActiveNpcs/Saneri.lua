local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Saneri",
	Icon = "rbxassetid://71155084242970",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-379.108, 1093.531, -422.421) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-379.108, 1093.531, -422.421),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Saneri
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Saneri"
		}
	}
}