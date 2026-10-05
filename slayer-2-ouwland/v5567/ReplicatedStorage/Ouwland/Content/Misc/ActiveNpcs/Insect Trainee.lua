local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.NpcTypes)
local InsectTrainee = {
	Type = Menum.npcType.Active,
	Name = "Insect Trainee",
	Icon = "rbxassetid://84412720285589",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
InsectTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-1395.644, 261.5, 69.22) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-1395.644, 261.5, 69.22),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.InsectTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "InsectTrainee"
	}
}
return InsectTrainee