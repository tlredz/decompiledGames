local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Reaper",
	Icon = "rbxassetid://138406794828849",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true,
			HealthEvents = "SecondPhase"
		},
		Spawning = {
			Locations = { createVector(98.468, 1043, -573.911) },
			SpawnTime = 300,
			DespawnDistance = 250,
			Center = createVector(98.468, 1043, -573.911),
			Appearance = ReplicatedStorage.Assets.Npcs.EvilArtDemons.Reaper
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Reaper"
		}
	}
}