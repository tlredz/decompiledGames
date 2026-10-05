local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local ThunderTrainee = {
	Type = Menum.npcType.Active,
	Name = "Thunder Trainee",
	Icon = "rbxassetid://100715629980691",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ThunderTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(2425.506, 1073.631, -556.788) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(2425.506, 1073.631, -556.788),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.ThunderTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "ThunderTrainee"
	}
}
return ThunderTrainee