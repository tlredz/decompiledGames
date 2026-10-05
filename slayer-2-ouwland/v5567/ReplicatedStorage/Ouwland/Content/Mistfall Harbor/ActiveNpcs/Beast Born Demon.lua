local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local BeastBornSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("BeastBornSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Beast Born Demon",
	Quantity = 6,
	SendOver = {
		Spawning = {
			Locations = BeastBornSettings.Spawns,
			SpawnTime = BeastBornSettings.SpawnTime,
			DespawnDistance = BeastBornSettings.DespawnDistance,
			Center = BeastBornSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Mistfall Harbor"].BeastBornDemon_MistfallHarbor:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = BeastBornSettings.Settings
	}
}