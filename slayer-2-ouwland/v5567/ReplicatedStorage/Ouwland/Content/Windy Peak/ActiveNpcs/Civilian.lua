local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
require(ReplicatedStorage.CAM.Global.Types.NpcTypes)
local CivilianSettings = require(ReplicatedStorage.Ouwland.Content["Windy Peak"].NpcShared.CivilianSettings)
return {
	Type = Menum.npcType.Active,
	Name = "Civilian",
	Quantity = 2,
	SendOver = {
		Profile = "Civilian",
		Spawning = {
			Locations = CivilianSettings.Points,
			SpawnTime = CivilianSettings.SpawnTime,
			DespawnDistance = CivilianSettings.DespawnDistance,
			Center = CivilianSettings.Center,
			Appearance = CivilianSettings.Models
		},
		Idling = {
			Enabled = true,
			Positions = CivilianSettings.Points
		},
		Flee = {
			FleeOnHit = true,
			FleeOnNearby = false,
			FleeDuration = 3,
			FleeDistance = 40,
			FleeRequirements = {
				OnHit = {
					Player = {}
				}
			}
		},
		Following = {
			CaptureDistance = 0,
			LetGoDistance = 0
		},
		Settings = {
			NpcCode = "Civilian"
		}
	}
}