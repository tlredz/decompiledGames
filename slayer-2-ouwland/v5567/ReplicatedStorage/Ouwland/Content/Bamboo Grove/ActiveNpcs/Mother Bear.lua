local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BearSettings = require(script.Parent.Parent:WaitForChild("NpcShared"):WaitForChild("BearSettings"))
local Menum = require(ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
return {
	Type = Menum.npcType.Active,
	Name = "Mother Bear",
	Icon = "rbxassetid://118920276129806",
	Quantity = 1,
	SendOver = {
		Boss = {
			SpawnCountdown = true,
			DamageLeaderboard = true
		},
		Spawning = {
			Locations = BearSettings.Spawns,
			SpawnTime = 150,
			DespawnDistance = BearSettings.DespawnDistance,
			Center = BearSettings.Center,
			Appearance = ReplicatedStorage.Assets.Npcs["Bamboo Grove"].MotherBear,
			ModelAttributes = {
				OverheadTopMargin = -2
			}
		},
		Idling = {
			Enabled = false
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 140
		},
		Settings = {
			NpcCode = "MotherBear"
		}
	}
}