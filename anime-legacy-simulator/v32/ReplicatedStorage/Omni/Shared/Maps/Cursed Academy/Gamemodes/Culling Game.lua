local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
return {
	Type = "ShieldedRaid",
	Style = "Party",
	Lighting = "Cursed Academy",
	Icon = "rbxassetid://102942968227299",
	Thumb = "rbxassetid://84196073517188",
	MapName = script.Parent.Parent.Name,
	CancelPositionSave = false,
	MaxPartyMembers = 4,
	Price = {
		Type = "Item",
		Name = "Gokumonkye",
		Amount = 1
	},
	DifficultHealthMultis = {
		Easy = 0.05,
		Medium = 0.2,
		Hard = 0.65,
		Insane = 1,
		Boss = 1.5,
		Secret = 2.5
	},
	Difficulties = {
		Easy = {
			HealthMultiplier = 0.5,
			MaxWave = 50,
			WaveTime = 120,
			PrepareTime = 10,
			WaveMultiplier = 4.85,
			StarterHealth = Number:Unformat("250K"),
			ShieldWaveInterval = 3,
			ShieldBreakCount = 2,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 750000,
						Maximum = 2500000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 25,
						Minimum = 7,
						Maximum = 7
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
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
						Minimum = 4000000,
						Maximum = 15000000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 50,
						Minimum = 10,
						Maximum = 15
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
						Chance = 5,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		},
		Medium = {
			HealthMultiplier = 0.5,
			MaxWave = 50,
			WaveTime = 120,
			PrepareTime = 10,
			WaveMultiplier = 7.95,
			StarterHealth = Number:Unformat("125M"),
			ShieldWaveInterval = 3,
			ShieldBreakCount = 2,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 1000000,
						Maximum = 3500000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 25,
						Minimum = 10,
						Maximum = 10
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
						Chance = 5,
						Minimum = 1,
						Maximum = 1
					}
				},
				Boss = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 8000000,
						Maximum = 30000000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 50,
						Minimum = 15,
						Maximum = 20
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
						Chance = 7.5,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		},
		Hard = {
			HealthMultiplier = 0.5,
			MaxWave = 50,
			WaveTime = 120,
			PrepareTime = 10,
			WaveMultiplier = 11.45,
			StarterHealth = Number:Unformat("350B"),
			ShieldWaveInterval = 3,
			ShieldBreakCount = 2,
			Drops = {
				Normal = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 3500000,
						Maximum = 12000000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 25,
						Minimum = 15,
						Maximum = 15
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
						Chance = 7.5,
						Minimum = 1,
						Maximum = 1
					}
				},
				Boss = {
					{
						Type = "Currency",
						Name = "Yen",
						Chance = 100,
						Minimum = 17500000,
						Maximum = 50000000
					},
					{
						Type = "Item",
						Name = "Cursed Token",
						Chance = 50,
						Minimum = 20,
						Maximum = 25
					},
					{
						Type = "Accessory",
						Name = "Cursed Worm",
						Chance = 10,
						Minimum = 1,
						Maximum = 1
					}
				}
			}
		}
	}
}