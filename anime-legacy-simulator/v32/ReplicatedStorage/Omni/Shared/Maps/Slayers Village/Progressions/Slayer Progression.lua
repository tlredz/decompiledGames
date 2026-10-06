return {
	Interface = "Default",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://97599868728413",
	MaxLevel = 100,
	Perks = {
		["Player Damage"] = {
			Type = "Add",
			Amount = 0,
			Reason = 1,
			Increasing = {
				Type = "Add",
				Amount = 0.025
			}
		}
	},
	Chance = {
		Amount = 100,
		Reason = 1,
		Minimum = 5,
		Maximum = 100,
		Increasing = {
			Type = "Add",
			Amount = -1.2
		}
	},
	Price = {
		Type = "Item",
		Name = "Slayer Token",
		Amount = 10,
		Reason = 2,
		Minimum = 10,
		Maximum = 200,
		Increasing = {
			Type = "Add",
			Amount = 5
		}
	},
	Products = {
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 50,
			Price = 200,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 150,
			Price = 500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 400,
			Price = 1250,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 1000,
			Price = 2500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 3000,
			Price = 6000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 8000,
			Price = 12500,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 20000,
			Price = 25000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 50000,
			Price = 50000,
			Enabled = true
		},
		{
			Type = "Item",
			Name = "Slayer Token",
			Amount = 125000,
			Price = 100000,
			Enabled = true
		}
	}
}