local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
return {
	Index = 2,
	Description = "Protect the village.",
	Npc = "Rengoke",
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
			Name = "Hashira",
			Amount = 1
		},
		{
			Type = "Map",
			Name = "Cursed Academy",
			Amount = 1,
			Icon = "rbxassetid://73531323211850"
		}
	}
}