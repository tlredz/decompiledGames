local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Hoyuzo",
	Icon = "rbxassetid://78799362242966",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true
		},
		Spawning = {
			Locations = { createVector(746.875, 1001, -1413) },
			SpawnTime = 180,
			DespawnDistance = 250,
			Center = createVector(746.875, 1001, -1413),
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].Hoyuzo
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Hoyuzo"
		}
	}
}