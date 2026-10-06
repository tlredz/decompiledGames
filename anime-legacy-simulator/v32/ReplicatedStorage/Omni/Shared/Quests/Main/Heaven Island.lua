local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
return {
	Index = 1,
	Description = "Clear the island.",
	Npc = "Namy",
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
			Name = "Pirate King",
			Amount = 1
		},
		{
			Type = "Map",
			Name = "Slayers Village",
			Amount = 1,
			Icon = "rbxassetid://73531323211850"
		}
	}
}