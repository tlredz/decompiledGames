local tiers = {
	{
		Rank = 10,
		Wen = 500000,
		Ore = 10
	},
	{
		Rank = 25,
		Wen = 300000,
		Ore = 5
	},
	{
		Rank = 50,
		Wen = 200000
	},
	{
		Rank = 100,
		Wen = 100000
	},
	{
		Rank = 100,
		Percent = 1,
		Wen = 50000
	}
}
local tiers2 = {
	{
		Rank = 100,
		Percent = 1
	}
}
return {
	MinPlayers = 10,
	Groups = {
		["1v1"] = {
			Tiers = {
				{
					Rank = 10,
					Wen = 1000000,
					Ore = 20
				},
				{
					Rank = 25,
					Wen = 500000,
					Ore = 10
				},
				{
					Rank = 50,
					Wen = 300000
				},
				{
					Rank = 100,
					Wen = 150000
				},
				{
					Rank = 100,
					Percent = 1,
					Wen = 50000
				}
			},
			TitleGrades = {
				Top10 = {
					rarity = "Mythic",
					buffs = {
						{
							stat = "Max Health",
							amount = 50
						},
						{
							stat = "Additional Damage Factor",
							amount = 0.06,
							isRatio = true
						}
					},
					collection = {
						{
							stat = "Max Health",
							amount = 5
						}
					}
				},
				Top100 = {
					rarity = "Legendary",
					buffs = {
						{
							stat = "Max Health",
							amount = 30
						},
						{
							stat = "Additional Damage Factor",
							amount = 0.04,
							isRatio = true
						}
					},
					collection = {
						{
							stat = "Max Health",
							amount = 3
						}
					}
				},
				Share = {
					rarity = "Epic",
					buffs = {
						{
							stat = "Max Health",
							amount = 15
						},
						{
							stat = "Additional Damage Factor",
							amount = 0.02,
							isRatio = true
						}
					},
					collection = {
						{
							stat = "Max Health",
							amount = 1.5
						}
					}
				}
			}
		},
		["2v2"] = {
			Tiers = tiers
		},
		["3v3"] = {
			Tiers = tiers
		},
		Zenith = {
			Tiers = tiers,
			Titles = {
				{
					Rank = 10,
					Percent = 1,
					Slayer = "Hashira",
					Demon = "Upper Moon"
				},
				{
					Rank = 100,
					Percent = 3,
					Slayer = "Tsuguko",
					Demon = "Lower Moon"
				}
			}
		},
		Normal = {
			Tiers = tiers2
		},
		Roguelike = {
			Tiers = tiers2
		}
	},
	TitleGrades = {
		Top10 = {
			rarity = "Mythic",
			buffs = {
				{
					stat = "Max Health",
					amount = 30
				},
				{
					stat = "Additional Damage Factor",
					amount = 0.05,
					isRatio = true
				}
			},
			collection = {
				{
					stat = "Max Health",
					amount = 5
				}
			}
		},
		Top100 = {
			rarity = "Legendary",
			buffs = {
				{
					stat = "Max Health",
					amount = 20
				},
				{
					stat = "Additional Damage Factor",
					amount = 0.03,
					isRatio = true
				}
			},
			collection = {
				{
					stat = "Max Health",
					amount = 3
				}
			}
		},
		Share = {
			rarity = "Epic",
			buffs = {
				{
					stat = "Max Health",
					amount = 12
				},
				{
					stat = "Additional Damage Factor",
					amount = 0.015,
					isRatio = true
				}
			},
			collection = {
				{
					stat = "Max Health",
					amount = 1.5
				}
			}
		}
	},
	TitleColors = {
		["1v1"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(215, 140, 20)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(215, 140, 20)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 60)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 240, 200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 240, 200))
		}),
		["2v2"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 110, 20)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(220, 110, 20)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 175, 70)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 235, 205)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 205))
		}),
		["3v3"] = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 100, 30)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(180, 100, 30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 165, 70)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 230, 195)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 230, 195))
		}),
		Normal = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 60, 55)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(235, 60, 55)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 140)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 235, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 235, 230))
		}),
		Roguelike = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 150, 90)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(20, 150, 90)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 230, 120)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(235, 255, 225)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(235, 255, 225))
		}),
		Zenith = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 170, 40)),
			ColorSequenceKeypoint.new(0.2, Color3.fromRGB(220, 170, 40)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 225, 120)),
			ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 250, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 250, 230))
		})
	},
	TitleParticles = {
		["3v3"] = "Sword Brothers"
	},
	Seasons = {
		{
			Ready = true,
			["1v1"] = {
				Title = "Sword Saint",
				Item = "Champion Outfit"
			},
			["2v2"] = {
				Title = "Sword Brothers",
				Item = "Champion Mask"
			},
			["3v3"] = {
				Title = "Sworn Trio",
				Item = "Champion Hat"
			},
			Zenith = {
				Items = {
					Hashira = {
						Flame = "Flame Hashira Haori",
						Insect = "Insect Hashira Haori",
						Serpent = "Serpent Hashira Haori",
						Sound = "Sound Hashira Haori",
						Stone = "Stone Hashira Haori",
						Thunder = "Thunder Hashira Haori",
						Water = "Water Hashira Haori",
						Wind = "Wind Hashira Haori"
					},
					Tsuguko = "Tsuguko Haori",
					["Upper Moon"] = "Uppermoon Haori",
					["Lower Moon"] = "Lowermoon Haori"
				}
			},
			Normal = {
				Title = "Spire Conqueror",
				Item = "Chainbound Garb",
				ItemShare = true
			},
			Roguelike = {
				Title = "Fatebreaker",
				Item = nil
			}
		}
	}
}