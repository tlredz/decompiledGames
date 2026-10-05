local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.NpcTypes)
local StoneTrainee = {
	Type = Menum.npcType.Active,
	Name = "Stone Trainee",
	Icon = "rbxassetid://132969680551373",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
StoneTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(2685.184, 1073.6, -568.754) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(2685.184, 1073.6, -568.754),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.StoneTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "StoneTrainee"
	}
}
return StoneTrainee