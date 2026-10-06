local v = {
	["V.I.P"] = {
		Order = 1,
		ID = 1976570717,
		BasePrice = 399,
		Color = Color3.fromRGB(255, 236, 62),
		Description = "1.1x Yen<br/>VIP chat tag<br/>Exclusive fighter",
		Rewards = {
			{
				Type = "Fighter",
				Name = "VIP Fighter",
				Amount = 1,
				EnsureOwned = true
			}
		},
		Perks = {
			Yen = {
				Type = "Multi",
				Amount = 1.1
			}
		}
	},
	["Remote Access"] = {
		Order = 2,
		ID = 1979186475,
		BasePrice = 799,
		Color = Color3.fromRGB(62, 255, 239),
		Description = "Open unlocked systems from Teleport",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {}
	},
	["Small Backpack"] = {
		Order = 3,
		ID = 1977326733,
		BasePrice = 99,
		Color = Color3.fromRGB(62, 255, 88),
		Description = "+25 inventory slots",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Inventory Slots"] = {
				Type = "Add",
				Amount = 25
			}
		}
	},
	["Big Backpack"] = {
		Order = 4,
		ID = 1976660734,
		BasePrice = 249,
		Color = Color3.fromRGB(117, 255, 62),
		Description = "+100 inventory slots",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Inventory Slots"] = {
				Type = "Add",
				Amount = 100
			}
		}
	},
	["2x Yen"] = {
		Order = 5,
		ID = 1979636442,
		BasePrice = 299,
		Color = Color3.fromRGB(255, 236, 62),
		Description = "2x Yen",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			Yen = {
				Type = "Multi",
				Amount = 2
			}
		}
	},
	["2x EXP"] = {
		Order = 6,
		ID = 1978754495,
		BasePrice = 299,
		Color = Color3.fromRGB(255, 62, 168),
		Description = "2x player and fighter EXP",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Player Exp"] = {
				Type = "Multi",
				Amount = 2
			},
			["Fighter Exp"] = {
				Type = "Multi",
				Amount = 2
			}
		}
	},
	Lucky = {
		Order = 7,
		ID = 1976276712,
		BasePrice = 99,
		Color = Color3.fromRGB(62, 255, 72),
		Description = "+1 Star Luck<br/>+0.5 Gacha Luck",
		Icon = "",
		PaidRandom = true,
		Rewards = {},
		Perks = {
			Luck = {
				Type = "Add",
				Amount = 1
			},
			["Gacha Luck"] = {
				Type = "Add",
				Amount = 0.5
			}
		}
	},
	["Super Lucky"] = {
		Order = 8,
		ID = 1976750697,
		BasePrice = 299,
		Color = Color3.fromRGB(255, 62, 168),
		Description = "+2 Star Luck<br/>+1 Gacha Luck",
		Icon = "",
		PaidRandom = true,
		Rewards = {},
		Perks = {
			Luck = {
				Type = "Add",
				Amount = 2
			},
			["Gacha Luck"] = {
				Type = "Add",
				Amount = 1
			}
		}
	},
	["Ultra Lucky"] = {
		Order = 9,
		ID = 1976750698,
		BasePrice = 699,
		Color = Color3.fromRGB(255, 62, 65),
		Description = "+3 Star Luck<br/>+1.5 Gacha Luck",
		Icon = "",
		PaidRandom = true,
		Rewards = {},
		Perks = {
			Luck = {
				Type = "Add",
				Amount = 3
			},
			["Gacha Luck"] = {
				Type = "Add",
				Amount = 1.5
			}
		}
	},
	["Shiny Hunter"] = {
		Order = 10,
		ID = 1977374726,
		BasePrice = 599,
		Color = Color3.fromRGB(255, 62, 94),
		Description = "+5% Shiny chance",
		Icon = "",
		PaidRandom = true,
		Rewards = {},
		Perks = {
			["Shiny Chance"] = {
				Type = "Add",
				Amount = 5
			}
		}
	},
	["Extra Equip"] = {
		Order = 11,
		ID = 1976048668,
		BasePrice = 399,
		Color = Color3.fromRGB(62, 162, 255),
		Description = "+2 fighter equips",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Fighter Equip"] = {
				Type = "Add",
				Amount = 2
			}
		}
	},
	["Multi Open"] = {
		Order = 12,
		ID = 1978862499,
		BasePrice = 499,
		Color = Color3.fromRGB(255, 171, 62),
		Description = "+2 Star opens<br/>+1 normal Gacha open",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Star Open"] = {
				Type = "Add",
				Amount = 2
			},
			["Gacha Open"] = {
				Type = "Add",
				Amount = 1
			}
		}
	},
	["Fast Open"] = {
		Order = 13,
		ID = 1976444709,
		BasePrice = 499,
		Color = Color3.fromRGB(62, 242, 255),
		Description = "2x Star and Gacha opening speed",
		Icon = "",
		PaidRandom = false,
		Rewards = {},
		Perks = {
			["Star Open Speed"] = {
				Type = "Multi",
				Amount = 2
			},
			["Gacha Open Speed"] = {
				Type = "Multi",
				Amount = 2
			}
		}
	}
}
return table.freeze(v)