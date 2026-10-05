return {
	DisplayName = "Shipwright",
	Description = "Being a Shipwright grants you the ability to repair ships using Wooden Planks. You have a chance of looting Wooden Planks from breaking trees.",
	Passives = {
		Base = {
			UnlockOrder = 1,
			LevelRequirement = 1,
			DisplayName = "Repair",
			Description = function(p, p2)
				local upgrade = p.Levels[p2].Upgrade
				return {
					Current = ("Can repair boats using wooden planks for + %d HP. Trees can drop (%d - %d) wooden planks at a %d%% chance."):format(
						upgrade.WoodPlankRepairHP,
						upgrade.WoodPlankBreakCount.Min,
						upgrade.WoodPlankBreakCount.Max,
						upgrade.WoodPlankBreakChance * 100
					)
				}
			end,
			Levels = {
				{
					Description = nil,
					Cost = {
						Fragments = 3000
					},
					Upgrade = {
						WoodPlankBreakChance = 0.3,
						WoodPlankBreakCount = NumberRange.new(2, 4),
						WoodPlankRepairHP = 10,
						WoodPlankRepairMaxHP = nil,
						AutoRepairBoatSpeed = nil,
						AutoRepairBoatHP = nil
					}
				}
			}
		},
		PlankScavenger = {
			UnlockOrder = 2,
			LevelRequirement = 5,
			DisplayName = "Plank Scavenger",
			Levels = {
				{
					Cost = {
						Fragments = 1000,
						Valor = 500
					},
					Upgrade = {
						WoodPlankBreakChance = 0.6,
						WoodPlankBreakCount = NumberRange.new(2, 4)
					},
					Description = {
						Current = "60% chance of receiving 2x wooden planks.",
						Upgrade = "3x planks"
					}
				},
				{
					Cost = {
						Fragments = 800,
						Valor = 700
					},
					Upgrade = {
						WoodPlankBreakChance = 0.6,
						WoodPlankBreakCount = NumberRange.new(3, 6)
					},
					Description = {
						Current = "60% chance of receiving 3x wooden planks.",
						Upgrade = "90% chance"
					}
				},
				{
					Cost = {
						Fragments = 500,
						Valor = 1000
					},
					Upgrade = {
						WoodPlankBreakChance = 0.9,
						WoodPlankBreakCount = NumberRange.new(3, 6)
					},
					Description = {
						Current = "90% chance of receiving 3x wooden planks."
					}
				}
			}
		},
		ExpertRepair = {
			UnlockOrder = 3,
			LevelRequirement = 12,
			DisplayName = "Blueprint Specialist",
			Levels = {
				{
					Cost = {
						Fragments = 1500,
						Valor = 1000
					},
					Upgrade = {
						WoodPlankRepairHP = 15
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 15 HP.",
						Upgrade = "22 HP"
					}
				},
				{
					Cost = {
						Fragments = 1000,
						Valor = 1300
					},
					Upgrade = {
						WoodPlankRepairHP = 22
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 22 HP.",
						Upgrade = "30 HP"
					}
				},
				{
					Cost = {
						Fragments = 500,
						Valor = 1800
					},
					Upgrade = {
						WoodPlankRepairHP = 30
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 30 HP."
					}
				}
			}
		},
		MaxHp = {
			UnlockOrder = 4,
			LevelRequirement = 18,
			DisplayName = "Hull Mechanic",
			Levels = {
				{
					Cost = {
						Fragments = 2000,
						Valor = 1800
					},
					Upgrade = {
						WoodPlankRepairMaxHP = 2
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 2 Max HP in the boats minigame.",
						Upgrade = "4 HP"
					}
				},
				{
					Cost = {
						Fragments = 1500,
						Valor = 2000
					},
					Upgrade = {
						WoodPlankRepairMaxHP = 4
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 4 Max HP in the boats minigame.",
						Upgrade = "8 HP"
					}
				},
				{
					Cost = {
						Fragments = 1000,
						Valor = 2200
					},
					Upgrade = {
						WoodPlankRepairMaxHP = 8
					},
					Description = {
						Current = "Can repair boats using wooden planks for + 8 Max HP in the boats minigame."
					}
				}
			}
		},
		NoStun = {
			UnlockOrder = 5,
			LevelRequirement = 25,
			DisplayName = "Heavy Hammer",
			Levels = {
				{
					Cost = {
						Fragments = 3000,
						Valor = 5000
					},
					Upgrade = {
						IgnoreStun = true
					},
					Description = {
						Current = "Stuns can't stop you from repairing."
					}
				}
			}
		}
	}
}