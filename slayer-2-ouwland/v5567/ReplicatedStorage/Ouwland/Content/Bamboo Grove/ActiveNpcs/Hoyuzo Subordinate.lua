local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Hoyuzo Subordinate",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = {
				createVector(536, 1001, -1389),
				createVector(544.019, 1001.519, -1169.504),
				createVector(596, 1001, -1134),
				createVector(580, 1001, -1010),
				createVector(606, 1001, -1071),
				createVector(672, 1001, -1001)
			},
			SpawnTime = 40,
			DespawnDistance = 495,
			Center = createVector(533, 1001, -1357),
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].HoyuzoSub:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 45,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "HoyuzoSub"
		}
	}
}