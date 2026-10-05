local createVector = vector.create
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.NpcTypes)
local SerpentTrainee = {
	Type = Menum.npcType.Active,
	Name = "Serpent Trainee",
	Icon = "rbxassetid://140495004689315",
	Quantity = 1,
	SendOver = 0
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
SerpentTrainee.SendOver = {
	Boss = {
		SpawnCountdown = true,
		DamageLeaderboard = true
	},
	Spawning = {
		Locations = { createVector(-271.378, 1292, -1535.713) },
		SpawnTime = 120,
		DespawnDistance = 250,
		Center = createVector(-271.378, 1292, -1535.713),
		Appearance = ReplicatedStorage.Assets.Npcs.Trainees.SerpentTrainee
	},
	Idling = {
		Enabled = false
	},
	Following = {
		CaptureDistance = 0,
		LetGoDistance = 140
	},
	Settings = {
		NpcCode = "SerpentTrainee"
	}
}
return SerpentTrainee