local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Name = "Sealed Chest T2",
	Spawns = {
		CFrame.new(-2026.54, 277.5, 0) * CFrame.Angles(0, 0.4886921905584123, 0),
		CFrame.new(-1530, 286.5, 170) * CFrame.Angles(0, 1.2915436464758039, 0),
		CFrame.new(-1376.649, 262.07, -52.211) * CFrame.Angles(0, -0.9773843811168246, 0),
		CFrame.new(-840, 948.07, 700) * CFrame.Angles(0, 1.6755160819145565, 0),
		CFrame.new(790, 1227.5, 420) * CFrame.Angles(0, -2.5830872929516078, 0),
		CFrame.new(-790, 963.83, 120) * CFrame.Angles(0, -1.239183768915974, 0),
		CFrame.new(-440, 963.72, -170) * CFrame.Angles(0, 2.775073510670984, 0),
		CFrame.new(160.264, 828.268, 1030.217) * CFrame.Angles(0, -1.6057029118347832, 0),
		CFrame.new(-1799.165, 312.992, 1097.478),
		CFrame.new(-2112.748, 133.75, 1031.911),
		CFrame.new(-670.909, 1005.074, 1161.466),
		CFrame.new(-1261.839, 287.5, 746.273)
	},
	WorldEvent = {
		Name = "SealedChest",
		ActiveCount = 5,
		RespawnTime = 1500,
		ChestId = "Sealed Cache T2",
		Guards = {
			{
				Config = "Cache Lancer",
				NpcCode = "CacheLancer",
				Count = 2
			},
			{
				Config = "Lancer Captain",
				NpcCode = "LancerCaptain",
				Count = 1,
				Radius = { 6, 12 },
				Leash = 100
			}
		}
	}
}