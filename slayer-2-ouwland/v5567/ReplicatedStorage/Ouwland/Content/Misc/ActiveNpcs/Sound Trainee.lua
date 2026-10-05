local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.NpcTypes)
local SoundTrainee = {
	Type = Menum.npcType.Active,
	Name = "Sound Trainee",
	Icon = "rbxassetid://103322791656200",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
SoundTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(192.5, 1349, -2581.313) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(192.5, 1349, -2581.313),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.SoundTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "SoundTrainee"
	}
}
return SoundTrainee