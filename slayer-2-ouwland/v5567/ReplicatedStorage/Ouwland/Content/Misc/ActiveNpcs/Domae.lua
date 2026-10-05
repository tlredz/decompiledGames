local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Domae",
	Icon = "rbxassetid://89038846694171",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(-296.472, 1350.5, -3451.273) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(-296.472, 1350.5, -3451.273),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Domae
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Domae"
		}
	}
}