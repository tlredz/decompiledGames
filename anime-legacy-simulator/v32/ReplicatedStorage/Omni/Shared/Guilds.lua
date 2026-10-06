require("@game/ReplicatedStorage/Omni/Settings")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	Ranks = {
		"Recruit",
		"Veteran",
		"Co-Leader",
		"Leader"
	},
	BaseMaxMembers = 10,
	NameMaxLength = 16,
	DescriptionMaxLength = 64,
	AnnouncementMaxLength = 32,
	AnnouncementHistoryMax = 25,
	MaxInvitesPerPlayer = 25,
	OnlineTimeout = 900,
	CreateCostGems = 2000,
	DefaultIcons = {
		"rbxassetid://130585331881625",
		"rbxassetid://102983821688591",
		"rbxassetid://83656610297725",
		"rbxassetid://114359466472503",
		"rbxassetid://100737828707396",
		"rbxassetid://99464435624898"
	},
	RankColors = {
		Recruit = Color3.fromRGB(255, 255, 50),
		Veteran = Color3.fromRGB(50, 255, 50),
		["Co-Leader"] = Color3.fromRGB(255, 50, 50),
		Leader = Color3.fromRGB(50, 255, 255)
	},
	Permissions = {
		Leader = {
			Invite = true,
			Announce = true,
			PromoteRecruitToVeteran = true,
			PromoteVeteranToCoLeader = true,
			Kick = true,
			BuyUpgrade = true,
			Edit = true
		},
		["Co-Leader"] = {
			Invite = true,
			Announce = true,
			PromoteRecruitToVeteran = true,
			PromoteVeteranToCoLeader = false,
			Kick = true,
			BuyUpgrade = true,
			Edit = false
		},
		Veteran = {
			Invite = true,
			Announce = true,
			PromoteRecruitToVeteran = false,
			PromoteVeteranToCoLeader = false,
			Kick = false,
			BuyUpgrade = false,
			Edit = false
		},
		Recruit = {
			Invite = false,
			Announce = false,
			PromoteRecruitToVeteran = false,
			PromoteVeteranToCoLeader = false,
			Kick = false,
			BuyUpgrade = false,
			Edit = false
		}
	},
	Upgrades = {
		MaxMembers = {
			Name = "Max Members",
			Icon = "rbxassetid://83656610297725",
			Levels = {
				{
					TotalMembersAdded = 1,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000
					}
				},
				{
					TotalMembersAdded = 2,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000
					}
				},
				{
					TotalMembersAdded = 3,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000
					}
				},
				{
					TotalMembersAdded = 4,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000
					}
				},
				{
					TotalMembersAdded = 5,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000
					}
				},
				{
					TotalMembersAdded = 6,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000
					}
				},
				{
					TotalMembersAdded = 7,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000
					}
				},
				{
					TotalMembersAdded = 8,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000
					}
				},
				{
					TotalMembersAdded = 9,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000
					}
				},
				{
					TotalMembersAdded = 10,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000
					}
				},
				{
					TotalMembersAdded = 11,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000
					}
				},
				{
					TotalMembersAdded = 12,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000
					}
				},
				{
					TotalMembersAdded = 13,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000
					}
				},
				{
					TotalMembersAdded = 14,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000000
					}
				},
				{
					TotalMembersAdded = 15,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000000
					}
				},
				{
					TotalMembersAdded = 16,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000000
					}
				},
				{
					TotalMembersAdded = 17,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000000
					}
				},
				{
					TotalMembersAdded = 18,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000000
					}
				},
				{
					TotalMembersAdded = 19,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000000
					}
				},
				{
					TotalMembersAdded = 20,
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000000000
					}
				}
			}
		},
		YenBoost = {
			Name = "Yen Boost",
			Icon = "rbxassetid://128122107653249",
			Levels = {
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.15
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.35
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.45
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.55
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.6
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.65
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.7
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.75
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.8
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.85
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.9
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 0.95
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000000
					}
				},
				{
					Perks = {
						Yen = {
							Type = "Add",
							Amount = 1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000000
					}
				}
			}
		},
		DamageBoost = {
			Name = "Damage Boost",
			Icon = "rbxassetid://80640623407879",
			Levels = {
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.025
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.075
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.125
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.15
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.175
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.225
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.275
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.325
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.35
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.375
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.425
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.45
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.475
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000000000
					}
				},
				{
					Perks = {
						Damage = {
							Type = "Add",
							Amount = 0.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000000000
					}
				}
			}
		},
		PlayerDamageBoost = {
			Name = "Player Damage Boost",
			Icon = "rbxassetid://81941152561733",
			Levels = {
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.6
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.7
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.8
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 0.9
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.6
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.7
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.8
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 1.9
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000000
					}
				},
				{
					Perks = {
						["Player Damage"] = {
							Type = "Add",
							Amount = 2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000000
					}
				}
			}
		},
		FighterDamageBoost = {
			Name = "Fighter Damage Boost",
			Icon = "rbxassetid://81941152561733",
			Levels = {
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.15
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.35
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.45
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.55
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.6
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.65
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.7
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.75
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 750000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.8
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 2500000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.85
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 7500000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.9
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 25000000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 0.95
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 75000000000000
					}
				},
				{
					Perks = {
						["Fighter Damage"] = {
							Type = "Add",
							Amount = 1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 250000000000000
					}
				}
			}
		},
		DropsBoost = {
			Name = "Drops Boost",
			Icon = "rbxassetid://116055951228504",
			Levels = {
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.025
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.05
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.075
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.1
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.125
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.15
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.175
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.2
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.225
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.25
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.275
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.3
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.325
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.35
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.375
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 1500000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.4
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 5000000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.425
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 15000000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.45
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 50000000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.475
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 150000000000000
					}
				},
				{
					Perks = {
						Drops = {
							Type = "Add",
							Amount = 0.5
						}
					},
					Price = {
						Type = "Currency",
						Name = "Yen",
						Amount = 500000000000000
					}
				}
			}
		}
	},
	Leaderboards = {
		["Guild Total Power"] = {
			Index = 1,
			Stat = "TotalPower",
			RequireAllF2P = false,
			Icon = "rbxassetid://80640623407879"
		},
		["Guild Total Power F2P"] = {
			Index = 2,
			Stat = "TotalPower",
			RequireAllF2P = true,
			Icon = "rbxassetid://80640623407879"
		},
		["Guild Total Yen"] = {
			Index = 3,
			Stat = "TotalDonated",
			RequireAllF2P = false,
			Icon = "rbxassetid://128122107653249"
		},
		["Guild Total Yen F2P"] = {
			Index = 4,
			Stat = "TotalDonated",
			RequireAllF2P = true,
			Icon = "rbxassetid://128122107653249"
		}
	}
}

function v.CanActOn(p: string?, p2: string?)
	if not (p and p2) then
		return false
	end

	local index = table.find(v.Ranks, p)
	local index2 = table.find(v.Ranks, p2)

	if index and index2 then
		return index2 < index
	end

	return false
end

function v.GetPermissions(p: string?)
	if p then
		return v.Permissions[p]
	end

	return nil
end

function v.GetRankColor(p: string?)
	if p then
		return v.RankColors[p] or Color3.fromRGB(255, 255, 255)
	end

	return Color3.fromRGB(255, 255, 255)
end

function v.RemoveMemberAnnouncements(list, p: number)
	for i = #list, 1, -1 do
		if list[i].AuthorId == p then
			table.remove(list, i)
		end
	end
end

function v.NormalizeIcon(value: string?)
	if not value or typeof(value) ~= "string" then
		return nil
	end

	local v2 = value:gsub("^%s+", ""):gsub("%s+$", "")

	if v2 == "" then
		return nil
	end

	local v3 = v2:match("^rbxassetid://(%d+)$") or v2:match("^(%d+)$")

	if v3 then
		return "rbxassetid://" .. v3
	end

	return nil
end

function v.FormatOfflineTime(p: number)
	local v2 = math.max(math.floor(p / 60), 0)
	local v3 = math.floor(v2 / 1440)
	local v4 = math.floor(v2 % 1440 / 60)
	local v5 = v2 % 60

	if v3 > 0 then
		return (`{v3}d {v4}h {v5}m`)
	end

	if v4 > 0 then
		return (`{v4}h {v5}m`)
	end

	return (`{v5}m`)
end

function v.GetRandomIcon()
	return v.DefaultIcons[math.random(1, #v.DefaultIcons)]
end

function v.GetUpgradeLevelInfo(p: string, p2: number)
	local upgrade = v.Upgrades[p]

	if upgrade then
		return upgrade.Levels[p2]
	end

	return nil
end

function v.GetNextUpgradeLevelInfo(p: string, p2: number)
	return v.GetUpgradeLevelInfo(p, p2 + 1)
end

function v.IsUpgradeMaxLevel(p: string, p2: number)
	local upgrade = v.Upgrades[p]
	return not upgrade or #upgrade.Levels <= p2
end

function v.GetMaxMembers(p)
	local baseMaxMembers = v.BaseMaxMembers
	local maxMembers = p.Upgrades.MaxMembers
	local level = maxMembers and maxMembers.Level or 0

	if level > 0 then
		local upgradeLevelInfo = v.GetUpgradeLevelInfo("MaxMembers", level)

		if upgradeLevelInfo and upgradeLevelInfo.TotalMembersAdded then
			baseMaxMembers += upgradeLevelInfo.TotalMembersAdded
		end
	end

	return baseMaxMembers
end

function v.AllMembersF2P(items)
	for _, item in items do
		if not (item.IsExcluded or item.IsF2P) then
			return false
		end
	end

	return true
end

function v.GetTotalDonated(data)
	if data.TotalDonated then
		return data.TotalDonated
	end

	local yen = data.Vault.Yen

	for k, upgrade in data.Upgrades do
		for i = 1, upgrade.Level do
			local upgradeLevelInfo = v.GetUpgradeLevelInfo(k, i)

			if upgradeLevelInfo then
				yen += upgradeLevelInfo.Price.Amount
			end
		end
	end

	return yen
end

function v.GetRankedDonated(p)
	return (math.max(v.GetTotalDonated(p) - (p.ExcludedDonated or 0), 0))
end

function v:SetMemberExcluded(state, isExcluded: boolean)
	local isExcluded2 = state.IsExcluded == true
	state.IsExcluded = isExcluded

	if isExcluded2 == isExcluded then
		return
	end

	local totalDonated = state.TotalDonated or 0
	local v2 = isExcluded and totalDonated or -totalDonated
	self.ExcludedDonated = math.max((self.ExcludedDonated or 0) + v2, 0)
end

function v.SystemSolver(p: string, p2)
	local perks = {}

	if not (p2.Guild and p2.Guild.GuildId) then
		return perks
	end

	for k, upgradeLevel in p2.Guild.UpgradeLevels do
		if upgradeLevel <= 0 then
			continue
		end

		local upgradeLevelInfo = v.GetUpgradeLevelInfo(k, upgradeLevel)

		if not (upgradeLevelInfo and upgradeLevelInfo.Perks) then
			continue
		end

		local perk = upgradeLevelInfo.Perks[p]

		if perk then
			table.insert(perks, perk)
		end
	end

	return perks
end

return table.freeze(v)