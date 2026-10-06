local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
local v = {
	Kume = {
		Difficulty = "Easy",
		Respawn = 2.5,
		PlayerExp = 1,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 20,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Bisento",
				Chance = 1,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	["Robin Lucco"] = {
		Difficulty = "Medium",
		Respawn = 2.5,
		PlayerExp = 2,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 22.5,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Bisento",
				Chance = 1.75,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Buggo = {
		Difficulty = "Hard",
		Respawn = 2.5,
		PlayerExp = 3,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 25,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Bisento",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Kuzon = {
		Difficulty = "Insane",
		Respawn = 2.5,
		PlayerExp = 5,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 30,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Bisento",
				Chance = 5,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	["Hawk Eyes"] = {
		Difficulty = "Boss",
		Respawn = 3.5,
		PlayerExp = 8,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 35,
				Minimum = 7,
				Maximum = 7
			},
			{
				Type = "Accessory",
				Name = "Aze Hat",
				Chance = 1,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Anel = {
		Difficulty = "Secret",
		Respawn = 5,
		PlayerExp = 16,
		Drops = {
			{
				Type = "Item",
				Name = "Haki Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 10
			},
			{
				Type = "Accessory",
				Name = "Aze Hat",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			}
		}
	}
}
local unformat = Number:Unformat("100")
local unformat2 = Number:Unformat("50")
local v2 = {
	Easy = {
		Currency = 1,
		Health = 5
	},
	Medium = {
		Currency = 3,
		Health = 30
	},
	Hard = {
		Currency = 10,
		Health = 150
	},
	Insane = {
		Currency = 30,
		Health = 750
	},
	Boss = {
		Currency = 100,
		Health = 3000
	},
	Secret = {
		Currency = 300,
		Health = 30000
	}
}

for _, v3 in v do
	local v4 = v2[v3.Difficulty] or v2.Easy

	if not v4 then
		continue
	end

	if not v3.Drops then
		v3.Drops = {}
	end

	local v5 = false

	for _, drop in v3.Drops do
		if drop.Name ~= "Yen" then
			continue
		end

		v5 = true
		break
	end

	if not v5 then
		local v7 = unformat2 * v4.Currency
		table.insert(v3.Drops, {
			Type = "Currency",
			Name = "Yen",
			Chance = 100,
			Minimum = v7,
			Maximum = v7
		})
	end

	if not v3.Health then
		v3.Health = unformat * v4.Health
	end
end

Enemies.Register(script.Parent.Name, v)
return true