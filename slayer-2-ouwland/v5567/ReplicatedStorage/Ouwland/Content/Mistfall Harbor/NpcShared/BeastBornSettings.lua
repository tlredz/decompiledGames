local CivilianSettings = require(script.Parent:WaitForChild("CivilianSettings"))
return {
	Spawns = CivilianSettings.Points,
	Settings = {
		NpcCode = "BeastBornDemon_MistfallHarbor"
	},
	Center = CivilianSettings.Center,
	DespawnDistance = 500,
	SpawnTime = 45
}