local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Nezura",
	Icon = "rbxassetid://118227676164869",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-1459.526, 275.951, 935.536) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-1459.526, 275.951, 935.536),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Nezura
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Nezura"
		}
	}
}