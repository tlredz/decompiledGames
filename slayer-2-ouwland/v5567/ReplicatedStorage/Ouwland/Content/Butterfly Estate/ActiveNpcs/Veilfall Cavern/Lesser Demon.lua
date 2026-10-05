local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local LesserDemonSettings = require(script.Parent.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("LesserDemonSettings"))
return {
	Type = Menum.npcType.Active,
	Name = "Lesser Demon",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = LesserDemonSettings.Spawns,
			SpawnTime = LesserDemonSettings.SpawnTime,
			DespawnDistance = LesserDemonSettings.DespawnDistance,
			Center = LesserDemonSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Butterfly Estate"].LesserDemon_ButterflyEstate:GetChildren()
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 45,
			LetGoDistance = 140
		},
		Settings = LesserDemonSettings.Settings
	}
}