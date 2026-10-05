local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Shinora",
	Icon = "rbxassetid://109849104474630",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-452.647, 964.498, 2.124) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-452.647, 964.498, 2.124),
			Appearance = ReplicatedStorage.Assets.Npcs.Hashiras.Shinora
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Shinora"
		}
	}
}