local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local TaiChiTrainee = {
	Type = Menum.npcType.Active,
	Name = "Tai Chi Trainee Suzume",
	Icon = "rbxassetid://132888817986073",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
TaiChiTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(2360.47, 601.991, -642.309) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(2360.47, 601.991, -642.309),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.TaiChiTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "TaiChiTrainee"
	}
}
return TaiChiTrainee