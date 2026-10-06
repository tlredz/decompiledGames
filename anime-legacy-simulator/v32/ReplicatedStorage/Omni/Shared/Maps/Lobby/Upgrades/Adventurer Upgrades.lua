return {
	Name = script.Name,
	Interface = "Default",
	MapName = script.Parent.Parent.Name,
	Icon = "rbxassetid://86246958019141",
	Products = {},
	Upgrades = {
		["Player Damage"] = {
			Index = 1,
			MaxLevel = 20,
			Perks = {
				["Player Damage"] = {
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
				Name = "Adventurer Token",
				Amount = 50,
				Increasing = {
					Type = "Add",
					Amount = 50
				}
			}
		},
		["Fighter Damage"] = {
			Index = 2,
			MaxLevel = 20,
			Perks = {
				["Fighter Damage"] = {
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
				Name = "Adventurer Token",
				Amount = 50,
				Increasing = {
					Type = "Add",
					Amount = 50
				}
			}
		},
		Yen = {
			Index = 3,
			MaxLevel = 20,
			Perks = {
				Yen = {
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
				Name = "Adventurer Token",
				Amount = 50,
				Increasing = {
					Type = "Add",
					Amount = 50
				}
			}
		},
		["Player Exp"] = {
			Index = 4,
			MaxLevel = 20,
			Perks = {
				["Player Exp"] = {
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
				Name = "Adventurer Token",
				Amount = 50,
				Increasing = {
					Type = "Add",
					Amount = 50
				}
			}
		},
		Drops = {
			Index = 5,
			MaxLevel = 20,
			Perks = {
				Drops = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 0.0125
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Adventurer Token",
				Amount = 50,
				Increasing = {
					Type = "Add",
					Amount = 50
				}
			}
		},
		Luck = {
			Index = 6,
			MaxLevel = 10,
			Perks = {
				Luck = {
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
				Name = "Adventurer Token",
				Amount = 100,
				Increasing = {
					Type = "Add",
					Amount = 100
				}
			}
		},
		["Gacha Luck"] = {
			Index = 7,
			MaxLevel = 10,
			Perks = {
				["Gacha Luck"] = {
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
				Name = "Adventurer Token",
				Amount = 100,
				Increasing = {
					Type = "Add",
					Amount = 100
				}
			}
		},
		["Attack Range"] = {
			Index = 8,
			MaxLevel = 10,
			Perks = {
				["Attack Range"] = {
					Type = "Add",
					Amount = 0,
					Increasing = {
						Type = "Add",
						Amount = 1
					}
				}
			},
			Price = {
				Type = "Item",
				Name = "Adventurer Token",
				Amount = 100,
				Increasing = {
					Type = "Add",
					Amount = 100
				}
			}
		}
	}
}