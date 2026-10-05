local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Kaiden",
	Icon = "rbxassetid://127854988699543",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true
		},
		Spawning = {
			Locations = { createVector(585.712, 1146.547, -1314.887) },
			SpawnTime = 165,
			DespawnDistance = 250,
			Center = createVector(585.712, 1146.547, -1314.887),
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].Kaiden
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "Kaiden"
		}
	}
}