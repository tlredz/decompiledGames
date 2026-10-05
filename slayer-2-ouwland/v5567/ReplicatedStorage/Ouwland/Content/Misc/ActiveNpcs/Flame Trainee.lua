local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Types"):WaitForChild("NpcTypes"))
local FlameTrainee = {
	Type = Menum.npcType.Active,
	Name = "Flame Trainee",
	Icon = "rbxassetid://84603644178937",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
FlameTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-1128.902, 1029.049, 994.42) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-1128.902, 1029.049, 994.42),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.FlameTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "FlameTrainee"
	}
}
return FlameTrainee