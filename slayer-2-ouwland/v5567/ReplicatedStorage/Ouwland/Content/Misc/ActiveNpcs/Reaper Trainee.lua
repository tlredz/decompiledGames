local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local ReaperTrainee = {
	Type = Menum.npcType.Active,
	Name = "Reaper Trainee Kuzan",
	Icon = "rbxassetid://114279912267702",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReaperTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-1219.262, 1373.625, -3034.386) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-1219.262, 1373.625, -3034.386),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.ReaperTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "ReaperTrainee"
	}
}
return ReaperTrainee