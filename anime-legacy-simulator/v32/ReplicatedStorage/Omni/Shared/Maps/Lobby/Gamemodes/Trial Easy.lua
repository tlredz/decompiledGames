local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
return {
	Type = "Trial",
	Style = "Scheduled",
	Difficulty = "Easy",
	Lighting = "Trial",
	Icon = "rbxassetid://126855202180943",
	Thumb = "rbxassetid://99737081225408",
	MapName = script.Parent.Parent.Name,
	CancelPositionSave = true,
	EnterTime = 60,
	TotalTime = 1500,
	OpenTimes = { 15, 45 },
	DifficultHealthMultis = {
		Easy = 0.05,
		Medium = 0.2,
		Hard = 0.65,
		Insane = 1,
		Boss = 1.5,
		Secret = 2.5
	},
	HealthMultiplier = 0.5,
	MaxWave = 50,
	RoomsBehind = 4,
	WaveMultiplier = 2.05,
	StarterHealth = Number:Unformat("12.5K"),
	Drops = {
		Normal = {
			{
				Type = "Currency",
				Name = "Yen",
				Chance = 100,
				Minimum = 200,
				Maximum = 1000
			},
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 15
			},
			{
				Type = "Item",
				Name = "Slayer Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 15
			},
			{
				Type = "Item",
				Name = "Breathing Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 15
			},
			{
				Type = "Item",
				Name = "Adventurer Token",
				Chance = 100,
				Minimum = 3,
				Maximum = 3
			},
			{
				Type = "Item",
				Name = "Trait Shard",
				Chance = 100,
				Minimum = 2,
				Maximum = 3
			},
			{
				Type = "Accessory",
				Name = "Lufe Belt",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Accessory",
				Name = "Nezko Box",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			}
		},
		Boss = {
			{
				Type = "Currency",
				Name = "Yen",
				Chance = 100,
				Minimum = 1500,
				Maximum = 7500
			},
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 100,
				Minimum = 15,
				Maximum = 20
			},
			{
				Type = "Item",
				Name = "Slayer Token",
				Chance = 100,
				Minimum = 15,
				Maximum = 20
			},
			{
				Type = "Item",
				Name = "Breathing Token",
				Chance = 100,
				Minimum = 15,
				Maximum = 20
			},
			{
				Type = "Item",
				Name = "Adventurer Token",
				Chance = 100,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Item",
				Name = "Trait Shard",
				Chance = 100,
				Minimum = 3,
				Maximum = 4
			},
			{
				Type = "Accessory",
				Name = "Lufe Belt",
				Chance = 5,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Accessory",
				Name = "Nezko Box",
				Chance = 5,
				Minimum = 1,
				Maximum = 1
			}
		}
	}
}