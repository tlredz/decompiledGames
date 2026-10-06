local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
return {
	Type = "Dungeon",
	Style = "Scheduled",
	Difficulty = "Easy",
	Lighting = "Trial",
	Icon = "rbxassetid://110853417502505",
	Thumb = "rbxassetid://108445142153621",
	MapName = script.Parent.Parent.Name,
	CancelPositionSave = true,
	EnterTime = 60,
	TotalTime = 1500,
	OpenTimes = { 0, 30 },
	DifficultHealthMultis = {
		Easy = 0.05,
		Medium = 0.2,
		Hard = 0.65,
		Insane = 1,
		Boss = 1.5,
		Secret = 2.5
	},
	HealthMultiplier = 0.5,
	MinimumRooms = 25,
	MaximumRooms = 51,
	RoomMultiplier = 1.35,
	ShieldBreakCount = 2,
	StarterHealth = Number:Unformat("5K"),
	TreasureRooms = {
		Minimum = 2,
		Maximum = 5,
		Chests = {
			["Small Chest"] = {
				Chance = 60,
				HealthMultiplier = 1,
				Drops = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 3000,
						Maximum = 22000
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 100,
						Minimum = 25,
						Maximum = 25
					},
					{
						Type = "Item",
						Name = "Slayer Token",
						Chance = 100,
						Minimum = 25,
						Maximum = 25
					},
					{
						Type = "Item",
						Name = "Breathing Token",
						Chance = 100,
						Minimum = 25,
						Maximum = 25
					},
					{
						Type = "Item",
						Name = "Adventurer Token",
						Chance = 100,
						Minimum = 7,
						Maximum = 7
					},
					{
						Type = "Item",
						Name = "Trait Shard",
						Chance = 100,
						Minimum = 10,
						Maximum = 10
					},
					{
						Type = "Item",
						Name = "Stats Reset Token",
						Chance = 1,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Lufe Belt",
						Chance = 10,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Nezko Box",
						Chance = 10,
						Minimum = 1,
						Maximum = 1
					}
				}
			},
			["Medium Chest"] = {
				Chance = 30,
				HealthMultiplier = 3,
				Drops = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 3500,
						Maximum = 24000
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 100,
						Minimum = 35,
						Maximum = 35
					},
					{
						Type = "Item",
						Name = "Slayer Token",
						Chance = 100,
						Minimum = 35,
						Maximum = 35
					},
					{
						Type = "Item",
						Name = "Breathing Token",
						Chance = 100,
						Minimum = 35,
						Maximum = 35
					},
					{
						Type = "Item",
						Name = "Adventurer Token",
						Chance = 100,
						Minimum = 10,
						Maximum = 10
					},
					{
						Type = "Item",
						Name = "Trait Shard",
						Chance = 100,
						Minimum = 15,
						Maximum = 15
					},
					{
						Type = "Item",
						Name = "Stats Reset Token",
						Chance = 1.5,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Lufe Belt",
						Chance = 15,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Nezko Box",
						Chance = 15,
						Minimum = 1,
						Maximum = 1
					}
				}
			},
			["Big Chest"] = {
				Chance = 10,
				HealthMultiplier = 5,
				Drops = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 4000,
						Maximum = 30000
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 100,
						Minimum = 45,
						Maximum = 45
					},
					{
						Type = "Item",
						Name = "Slayer Token",
						Chance = 100,
						Minimum = 45,
						Maximum = 45
					},
					{
						Type = "Item",
						Name = "Breathing Token",
						Chance = 100,
						Minimum = 45,
						Maximum = 45
					},
					{
						Type = "Item",
						Name = "Adventurer Token",
						Chance = 100,
						Minimum = 15,
						Maximum = 15
					},
					{
						Type = "Item",
						Name = "Trait Shard",
						Chance = 100,
						Minimum = 20,
						Maximum = 20
					},
					{
						Type = "Item",
						Name = "Stats Reset Token",
						Chance = 2.5,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Lufe Belt",
						Chance = 20,
						Minimum = 1,
						Maximum = 1
					},
					{
						Type = "Accessory",
						Name = "Nezko Box",
						Chance = 20,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		}
	},
	Drops = {
		Normal = {
			{
				Type = "Currency",
				Name = "Yen",
				Chance = 100,
				Minimum = 750,
				Maximum = 9000
			},
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 10
			},
			{
				Type = "Item",
				Name = "Slayer Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 10
			},
			{
				Type = "Item",
				Name = "Breathing Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 10
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
				Maximum = 2
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
				Minimum = 2500,
				Maximum = 20000
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
				Minimum = 2,
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
	},
	MinimapColors = {
		Completed = Color3.fromRGB(70, 220, 90),
		Start = Color3.fromRGB(60, 140, 255),
		Treasure = Color3.fromRGB(255, 200, 40),
		Default = Color3.fromRGB(128, 128, 128)
	}
}