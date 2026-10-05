local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Name = "Sealed Chest T3",
	Spawns = {
		CFrame.new(642.929, 1220.557, -1566.969) * CFrame.Angles(0, 0.7155849933176751, 0),
		CFrame.new(757, 1221.5, -1699.24) * CFrame.Angles(0, -0.4188790204786391, 0),
		CFrame.new(321.068, 1223.074, -1771.513),
		CFrame.new(145.09, 1255.033, -2011.606),
		CFrame.new(156.267, 1319.629, -2226.213) * CFrame.Angles(0, 0.20943951023931956, 0),
		CFrame.new(133, 1317.091, -2429.985) * CFrame.Angles(0, -1.0995574287564276, 0),
		CFrame.new(-74.255, 1349.5, -2267) * CFrame.Angles(0, 1.6755160819145565, 0),
		CFrame.new(392.015, 1350.5, -2310.823),
		CFrame.new(-608.906, 1382, -2473.826),
		CFrame.new(-1230.833, 1382.437, -2264.551),
		CFrame.new(-963.872, 1383.074, -2553.207),
		CFrame.new(-667.213, 1383.074, -2733.774)
	},
	WorldEvent = {
		Name = "SealedChest",
		ActiveCount = 5,
		RespawnTime = 1500,
		ChestId = "Sealed Cache T3",
		Guards = {
			{
				Config = "Cache Prowler",
				NpcCode = "CacheProwler",
				Count = 2
			},
			{
				Config = "Prowler Captain",
				NpcCode = "ProwlerCaptain",
				Count = 1,
				Radius = { 6, 12 },
				Leash = 100
			}
		}
	}
}