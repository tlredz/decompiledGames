local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
return {
	Type = "Defense",
	Style = "Party",
	Lighting = "Heaven Island",
	Icon = "rbxassetid://122425384935598",
	MapName = "Heaven Island",
	CancelPositionSave = true,
	MaxPartyMembers = 4,
	DifficultHealthMultis = {
		Easy = 0.5,
		Medium = 1,
		Hard = 2,
		Insane = 4,
		Boss = 8,
		Secret = 16
	},
	Difficulties = {
		Easy = {
			HealthMultiplier = 0.5,
			MaxWave = 5,
			PrepareTime = 10,
			StarterHealth = Number:Unformat("5K"),
			MinimumEnemies = 3,
			MaximumEnemies = 5,
			EnemySpawnDelay = 0.5,
			EnemySpeed = 10,
			BaseHealth = 3,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 25,
						Maximum = 50
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 15,
						Minimum = 1,
						Maximum = 1
					}
				},
				Boss = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 75,
						Maximum = 125
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 40,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		},
		Medium = {
			HealthMultiplier = 1,
			MaxWave = 5,
			PrepareTime = 10,
			StarterHealth = Number:Unformat("5K"),
			MinimumEnemies = 3,
			MaximumEnemies = 5,
			EnemySpawnDelay = 0.5,
			EnemySpeed = 10,
			BaseHealth = 3,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 50,
						Maximum = 100
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 15,
						Minimum = 1,
						Maximum = 1
					}
				},
				Boss = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 150,
						Maximum = 250
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 40,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		},
		Hard = {
			HealthMultiplier = 2,
			MaxWave = 5,
			PrepareTime = 10,
			StarterHealth = Number:Unformat("5K"),
			MinimumEnemies = 3,
			MaximumEnemies = 5,
			EnemySpawnDelay = 0.5,
			EnemySpeed = 10,
			BaseHealth = 3,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 100,
						Maximum = 200
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 15,
						Minimum = 1,
						Maximum = 1
					}
				},
				Boss = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 300,
						Maximum = 500
					},
					{
						Type = "Item",
						Name = "Haki Token",
						Chance = 40,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		}
	}
}