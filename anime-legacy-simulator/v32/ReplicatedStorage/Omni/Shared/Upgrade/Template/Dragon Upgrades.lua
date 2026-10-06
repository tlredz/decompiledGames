return {
	Name = script.Name,
	Interface = "Default",
	MapName = "Dragon Verse",
	Icon = "rbxassetid://93670476085226",
	Products = {
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 675,
			Price = 200
		},
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 3500,
			Price = 990
		},
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 9500,
			Price = 2490
		},
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 25000,
			Price = 5990
		},
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 70000,
			Price = 14990
		},
		{
			Type = "Item",
			Name = "Ball Shard",
			Amount = 250000,
			Price = 49900
		}
	},
	Upgrades = {
		Power = {
			Index = 1,
			MaxLevel = 30,
			Perks = {
				Power = {
					Type = "Multi",
					Amount = 1,
					Increasing = {
						Type = "Add",
						Amount = 0.1
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		Damage = {
			Index = 2,
			MaxLevel = 30,
			Perks = {
				Damage = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.1
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		Crystals = {
			Index = 3,
			MaxLevel = 30,
			Perks = {
				Crystals = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.1
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		["Player Exp"] = {
			Index = 1,
			MaxLevel = 30,
			Perks = {
				["Player Exp"] = {
					Type = "Multi",
					Amount = 1,
					Increasing = {
						Type = "Add",
						Amount = 0.05
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		["Avatar Exp"] = {
			Index = 2,
			MaxLevel = 30,
			Perks = {
				["Avatar Exp"] = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.05
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		["Movement Speed"] = {
			Index = 3,
			MaxLevel = 30,
			Perks = {
				["Movement Speed"] = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.025
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 250,
				Increasing = {
					Type = "Add",
					Amount = 500
				}
			}
		},
		["Gacha Speed"] = {
			Index = 4,
			MaxLevel = 10,
			Perks = {
				["Gacha Speed"] = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.01
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 500,
				Increasing = {
					Type = "Add",
					Amount = 750
				}
			}
		},
		["Star Speed"] = {
			Index = 5,
			MaxLevel = 10,
			Perks = {
				["Star Speed"] = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.01
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Ball Shard",
				Amount = 500,
				Increasing = {
					Type = "Add",
					Amount = 750
				}
			}
		}
	}
}