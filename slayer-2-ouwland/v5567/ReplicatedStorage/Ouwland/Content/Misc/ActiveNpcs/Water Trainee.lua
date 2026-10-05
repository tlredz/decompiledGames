local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local WaterTrainee = {
	Type = Menum.npcType.Active,
	Name = "Water Trainee Sabito",
	Icon = "rbxassetid://103179547098493",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
WaterTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(815.348, 1018.884, 101.599) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(815.348, 1018.884, 101.599),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.WaterTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "WaterTrainee"
	}
}
return WaterTrainee