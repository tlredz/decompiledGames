local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Name = "Sealed Chest T1",
	Spawns = {
		CFrame.new(802.349, 1121.764, -1002.728) * CFrame.Angles(0, -2.553765761518103, 0),
		CFrame.new(917.909, 1019.107, 15.007) * CFrame.Angles(0, -2.553765761518103, 0),
		CFrame.new(535.553, 1019.111, 204.519) * CFrame.Angles(0, 2.4007003861182006, 0),
		CFrame.new(331.35, 1018.936, -686.555) * CFrame.Angles(0, 0.6497860805174889, 0),
		CFrame.new(597.777, 1146.609, -1230.817) * CFrame.Angles(0, -2.1786945052645215, 0),
		CFrame.new(387.138, 1122.116, -1171.613) * CFrame.Angles(0, 0.4043927876870862, 0),
		CFrame.new(942.733, 1102.488, -1147.013) * CFrame.Angles(0, -0.5883504908472885, 0),
		CFrame.new(1053.77, 1042.43, -481.3) * CFrame.Angles(0, -0.5883504908472885, 0)
	},
	WorldEvent = {
		Name = "SealedChest",
		ActiveCount = 3,
		ChestId = "Sealed Cache T1",
		Guards = {
			{
				Config = "GroveRaider",
				NpcCode = "GroveRaider",
				Count = 2
			},
			{
				Config = "RaidCaptain",
				NpcCode = "RaidCaptain",
				Count = 1,
				Radius = { 6, 12 },
				Leash = 100
			}
		}
	}
}