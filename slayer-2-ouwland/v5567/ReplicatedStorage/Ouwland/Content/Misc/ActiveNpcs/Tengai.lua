local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Tengai",
	Icon = "rbxassetid://89376748233580",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-133.509, 1349, -2631.336) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-133.509, 1349, -2631.336),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Tengai
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Tengai"
		}
	}
}