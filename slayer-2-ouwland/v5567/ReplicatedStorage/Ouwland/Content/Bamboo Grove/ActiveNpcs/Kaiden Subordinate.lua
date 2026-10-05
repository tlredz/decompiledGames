local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Kaiden Subordinate",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = {
				createVector(601.3, 1146.547, -1305.887),
				createVector(581.053, 1146.547, -1297.5),
				createVector(568.32495, 1146.547, -1319.546),
				createVector(590.371, 1146.547, -1332.2739)
			},
			SpawnTime = 40,
			DespawnDistance = 250,
			Center = createVector(585.712, 1146.547, -1314.887),
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].KaidenSub:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "KaidenSub"
		}
	}
}