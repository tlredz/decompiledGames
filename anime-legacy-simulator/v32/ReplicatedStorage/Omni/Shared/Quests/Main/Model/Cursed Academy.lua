local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
return {
	Index = 3,
	Description = "Defend the academy.",
	MaximumCompletions = 1,
	Missions = Enemies.CreateMissionListForMap(script.Name),
	Perks = {
		Damage = {
			Type = "Add",
			Amount = 0.05
		},
		["Fighter Damage"] = {
			Type = "Add",
			Amount = 0.1
		},
		["Player Damage"] = {
			Type = "Add",
			Amount = 0.5
		}
	},
	Rewards = {
		{
			Type = "Item",
			Name = "Free Gems",
			Amount = 500
		},
		{
			Type = "Title",
			Name = "Strongest Sorcerer",
			Amount = 1
		},
		{
			Type = "Currency",
			Name = "Yen",
			Amount = 25000
		}
	}
}