local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local SoryuTrainee = {
	Type = Menum.npcType.Active,
	Name = "Soryu Trainee Goki",
	Icon = "rbxassetid://96180371653134",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
SoryuTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-426.985, 288.809, 543.272) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-426.985, 288.809, 543.272),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.SoryuTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "SoryuTrainee"
	}
}
return SoryuTrainee