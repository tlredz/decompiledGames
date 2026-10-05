local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BearSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("BearSettings"))
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Bear Cub",
	Quantity = 4,
	SendOver = {
		Spawning = {
			Locations = BearSettings.Spawns,
			SpawnTime = 24,
			DespawnDistance = BearSettings.DespawnDistance,
			Center = BearSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].BearCub,
			ModelAttributes = {
				OverheadTopMargin = -2
			}
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 120
		},
		Settings = {
			NpcCode = "BearCub"
		}
	}
}