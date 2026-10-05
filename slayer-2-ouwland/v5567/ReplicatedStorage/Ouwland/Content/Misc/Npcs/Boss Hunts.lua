local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Name = "Boss Hunts",
	WorldEvent = {
		Name = "BossHunts",
		TimedEvent = "BossHunt"
	}
}