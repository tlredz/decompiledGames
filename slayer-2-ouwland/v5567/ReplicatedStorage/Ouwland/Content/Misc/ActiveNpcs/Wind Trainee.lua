local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.NpcTypes)
local WindTrainee = {
	Type = Menum.npcType.Active,
	Name = "Wind Trainee",
	Icon = "rbxassetid://75784714790464",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
WindTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-941.573, 1381, -2635.568) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-941.573, 1381, -2635.568),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.WindTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "WindTrainee"
	}
}
return WindTrainee