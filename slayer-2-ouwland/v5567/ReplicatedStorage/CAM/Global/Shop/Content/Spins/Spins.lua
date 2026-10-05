local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
return {
	["1 Spin"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 1,
		Price = {
			Product = 3709745340
		},
		ListedPrice = 5,
		AllowOre = true
	},
	["15 Spins"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 15,
		Price = {
			Product = 3709745395
		},
		ListedPrice = 60,
		AllowOre = true
	},
	["25 Spins"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 25,
		Price = {
			Product = 3709745729
		},
		ListedPrice = 90,
		AllowOre = true
	},
	["50 Spins"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 50,
		Price = {
			Product = 3709745760
		},
		ListedPrice = 150,
		AllowOre = true
	},
	["100 Spins"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 100,
		Price = {
			Product = 3709745970
		},
		ListedPrice = 270,
		AllowOre = true
	},
	["250 Spins"] = {
		Type = Menum.ShopItemType.Spins,
		Spins = 250,
		Price = {
			Product = 3709745992
		},
		ListedPrice = 600,
		AllowOre = true,
		Tag = "BestValue"
	}
}