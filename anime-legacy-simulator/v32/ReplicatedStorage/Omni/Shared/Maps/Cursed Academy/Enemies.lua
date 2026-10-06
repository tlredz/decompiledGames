local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Number = require(ReplicatedStorage.Omni.Utils.Number)
local Enemies = require(ReplicatedStorage.Omni.Shared.Enemies)
local v = {
	Jogu = {
		Difficulty = "Easy",
		Respawn = 2.5,
		PlayerExp = 8,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 20,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Inverted Spear",
				Chance = 1,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 0.1,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Toje = {
		Difficulty = "Medium",
		Respawn = 2.5,
		PlayerExp = 10,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 22.5,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Inverted Spear",
				Chance = 1.75,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 0.25,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Mahita = {
		Difficulty = "Hard",
		Respawn = 2.5,
		PlayerExp = 14,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 25,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Inverted Spear",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 0.5,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Lyu = {
		Difficulty = "Insane",
		Respawn = 2.5,
		PlayerExp = 20,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 30,
				Minimum = 5,
				Maximum = 5
			},
			{
				Type = "Weapon",
				Name = "Inverted Spear",
				Chance = 5,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 0.75,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Kashimu = {
		Difficulty = "Boss",
		Respawn = 3.5,
		PlayerExp = 28,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 35,
				Minimum = 7,
				Maximum = 7
			},
			{
				Type = "Accessory",
				Name = "Blindfold",
				Chance = 1,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 1,
				Minimum = 1,
				Maximum = 1
			}
		}
	},
	Sokona = {
		Difficulty = "Secret",
		Respawn = 5,
		PlayerExp = 56,
		Drops = {
			{
				Type = "Item",
				Name = "Cursed Token",
				Chance = 50,
				Minimum = 10,
				Maximum = 10
			},
			{
				Type = "Accessory",
				Name = "Blindfold",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			},
			{
				Type = "Item",
				Name = "Gokumonkye",
				Chance = 2.5,
				Minimum = 1,
				Maximum = 1
			}
		}
	}
}
local unformat = Number:Unformat("25K")
local unformat2 = Number:Unformat("75K")
local v2 = {
	Easy = {
		Currency = 1,
		Health = 10
	},
	Medium = {
		Currency = 3,
		Health = 50
	},
	Hard = {
		Currency = 10,
		Health = 170
	},
	Insane = {
		Currency = 30,
		Health = 540
	},
	Boss = {
		Currency = 100,
		Health = 2800
	},
	Secret = {
		Currency = 300,
		Health = 28000
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