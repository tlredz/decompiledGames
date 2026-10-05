local function var(var_: string)
	return {
		_var_ = var_
	}
end

return {
	Luck = {
		NameFormat = "Lucky <$StackNumeral$>",
		DescriptionFormat = "+<$BoostValue$>% Luck",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://18198637843",
		MainColor = Color3.fromRGB(0, 255, 106),
		IconColor = Color3.fromRGB(0, 255, 106),
		FishingStatsAdd = {
			Luck = {
				_var_ = "BoostValue"
			}
		}
	},
	Unlucky = {
		NameFormat = "Unlucky <$StackNumeral$>",
		DescriptionFormat = "<$BoostValue$>% Luck",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = false,
		Icon = "rbxassetid://139695287607406",
		MainColor = Color3.fromRGB(126, 96, 46),
		IconColor = Color3.fromRGB(126, 96, 46),
		FishingStatsAdd = {
			Luck = {
				_var_ = "BoostValue"
			}
		}
	},
	LuckMultiply = {
		NameFormat = "Lucky+ <$StackNumeral$>",
		DescriptionFormat = "<$BoostValue$>× Luck",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://18198637843",
		MainColor = Color3.fromRGB(0, 255, 106),
		IconColor = Color3.fromRGB(0, 255, 106),
		FishingStatsMultiply = {
			Luck = {
				_var_ = "BoostValue"
			}
		}
	},
	TrenchSuppression = {
		NameFormat = "Suppression",
		DescriptionFormat = "-<$Reduction$>% to all rod stats\nAbsorb glowing crystals to weaken it",
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://137683569986880",
		MainColor = Color3.fromRGB(97, 54, 55),
		IconColor = Color3.fromRGB(188, 86, 88),
		FishingStatsMultiply = {
			Luck = {
				_var_ = "Mult"
			},
			Strength = {
				_var_ = "Mult"
			},
			Lure = {
				_var_ = "Mult"
			},
			Resilience = {
				_var_ = "Mult"
			},
			Control = {
				_var_ = "Mult"
			},
			Durability = {
				_var_ = "Mult"
			},
			LineDistance = {
				_var_ = "Mult"
			},
			Scavenging = {
				_var_ = "Mult"
			},
			WeightBoost = {
				_var_ = "Mult"
			},
			ProgressSpeed = {
				_var_ = "Mult"
			},
			ForcedProgressSpeed = {
				_var_ = "Mult"
			},
			TrueProgressSpeed = {
				_var_ = "Mult"
			},
			Power = {
				_var_ = "Mult"
			},
			Handling = {
				_var_ = "Mult"
			},
			Piercing = {
				_var_ = "Mult"
			},
			Range = {
				_var_ = "Mult"
			},
			Velocity = {
				_var_ = "Mult"
			},
			Accuracy = {
				_var_ = "Mult"
			},
			FishingTypes = "all"
		}
	},
	Lure = {
		NameFormat = "Lure <$StackNumeral$>",
		DescriptionFormat = "+<$BoostValue$>% Lure",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://18962615150",
		MainColor = Color3.fromRGB(107, 209, 253),
		IconColor = Color3.fromRGB(107, 209, 253),
		FishingStatsAdd = {
			Lure = {
				_var_ = "BoostValue"
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	AllSeasons = {
		NameFormat = "All Seasons",
		DescriptionFormat = "Ignore Season Preferences",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://128790211567708",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 207, 85)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(82, 255, 255))
		}),
		FishingStatsSet = {
			SeasonEffectiveness = 0
		}
	},
	Glitched = {
		NameFormat = "Glitched <$StackNumeral$>",
		DescriptionFormat = "<$DuplicateChance$>% Fish Duplication Chance with Glitched attribute",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://74286595580144",
		MainColor = ColorSequence.new(Color3.fromRGB(0, 186, 74), Color3.fromRGB(17, 59, 0)),
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = {
					_var_ = "DuplicateChance"
				},
				DuplicateGlitched = true,
				RequireDirectCatch = true,
				FishingTypes = "all",
				PassiveBlockLevel = 3
			}
		}
	},
	Pollinated = {
		NameFormat = "Pollinated",
		DescriptionFormat = "Reduced Bee Aggression",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://102501072997549",
		MainColor = Color3.fromRGB(255, 200, 89)
	},
	Currency = {
		NameFormat = "Wealth <$StackNumeral$>",
		DescriptionFormat = "+<$Percent::BoostValue$>% Sell Value",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://117451337053485",
		MainColor = Color3.fromRGB(255, 235, 83),
		IconColor = Color3.fromRGB(255, 235, 83)
	},
	Fire = {
		NameFormat = "Burn <$StackNumeral$>",
		DescriptionFormat = "Losing <$Damage$> health/second!",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://18197272991",
		MainColor = Color3.fromRGB(255, 156, 34),
		IconColor = Color3.fromRGB(255, 156, 34)
	},
	Charged = {
		NameFormat = "Charged <$StackNumeral$>",
		DescriptionFormat = "+<$BoostValue$>% Progress Speed",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://104254988221975",
		MainColor = Color3.fromRGB(255, 255, 100),
		IconColor = Color3.fromRGB(255, 255, 100),
		FishingStatsAdd = {
			ProgressSpeed = {
				_var_ = "BoostValue"
			}
		}
	},
	Electrified = {
		NameFormat = "Electrified",
		DescriptionFormat = "+<$BoostValue$>% Progress Speed",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://116804519768289",
		MainColor = Color3.fromRGB(255, 255, 100),
		IconColor = Color3.fromRGB(255, 255, 100),
		FishingStatsAdd = {
			ProgressSpeed = {
				_var_ = "BoostValue"
			}
		}
	},
	Divine = {
		NameFormat = "Divine <$StackNumeral$>",
		DescriptionFormat = "<$BoostValue$>× Luck",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://122279757293327",
		MainColor = Color3.fromRGB(253, 233, 132),
		IconColor = Color3.fromRGB(253, 233, 132),
		FishingStatsMultiply = {
			LuckMultiply = {
				_var_ = "BoostValue"
			}
		}
	},
	XpMultiply = {
		NameFormat = "Insight <$StackNumeral$>",
		DescriptionFormat = "+<$Percent-1::BoostValue$>% XP",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://93850281635532",
		MainColor = Color3.fromRGB(0, 157, 255),
		IconColor = Color3.fromRGB(0, 157, 255)
	},
	BlueMoon = {
		NameFormat = "Blue Moon",
		DescriptionFormat = [[
• +50% XP
• 5% for Moon-Kissed
• 10% for +50% weight]],
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://90066270358528",
		MainColor = ColorSequence.new(Color3.fromRGB(1, 223, 246), Color3.fromRGB(0, 152, 246)),
		FishingStatsMultiply = {
			XpMultiply = 1.5
		},
		OnlyFishingType = "rod"
	},
	MerlinsVeil = {
		NameFormat = "Merlin's Veil",
		DescriptionFormat = "Grants access to The Chasm",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://83622365983695",
		MainColor = ColorSequence.new(Color3.fromRGB(183, 89, 255), Color3.fromRGB(255, 112, 255)),
		IconColor = ColorSequence.new(Color3.fromRGB(183, 89, 255), Color3.fromRGB(255, 112, 255))
	},
	Masterline = {
		NameFormat = "Masterline",
		DescriptionFormat = "<$RodList$>",
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://89538599409665",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 194)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(254, 254, 254)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(191, 251, 249))
		}),
		IconColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 235, 194)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(254, 254, 254)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(191, 251, 249))
		}),
		OnlyFishingType = "rod"
	},
	CelestialPower = {
		NameFormat = "Celestial",
		DescriptionFormat = "<$+StatsBullet::PassiveBoosts$>\n• 100% chance for Celestial mutation",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://101290412690050",
		MainColor = ColorSequence.new(Color3.fromRGB(242, 255, 0), Color3.fromRGB(232, 201, 0)),
		IconColor = ColorSequence.new(Color3.fromRGB(242, 255, 0), Color3.fromRGB(232, 201, 0)),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "all"
			}
		}
	},
	MoonlitBonus = {
		NameFormat = "Moonlit <$StackNumeral$>",
		DescriptionFormat = "+<$WeightBoost$>% Weight Boost",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://130573043245984",
		MainColor = ColorSequence.new(Color3.fromRGB(94, 190, 238), Color3.fromRGB(111, 255, 250)),
		IconColor = ColorSequence.new(Color3.fromRGB(94, 190, 238), Color3.fromRGB(111, 255, 250)),
		FishingStatsAdd = {
			WeightBoost = {
				_var_ = "WeightBoost"
			}
		}
	},
	RoyalEscort = {
		NameFormat = "Royal Escort",
		DescriptionFormat = [[
<$+StatsBullet::PassiveBoosts$>
• +10% for <font color='#f3bc5d'>Royal</font> mutation]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://89538599409665",
		MainColor = ColorSequence.new(Color3.fromRGB(217, 103, 255), Color3.fromRGB(159, 129, 251)),
		IconColor = ColorSequence.new(Color3.fromRGB(217, 103, 255), Color3.fromRGB(159, 129, 251)),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "all"
			}
		}
	},
	EclipseBoost = {
		NameFormat = "Eclipsed",
		DescriptionFormat = "<$+StatsBullet::PassiveBoosts$>",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://93815001725064",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 212, 138)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(106, 84, 86)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(231, 174, 255))
		}),
		IconColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 212, 138)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(106, 84, 86)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(231, 174, 255))
		}),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	Blazing = {
		NameFormat = "Blazing",
		DescriptionFormat = "All stats doubled",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://80275929100256",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 151, 66), Color3.fromRGB(255, 67, 67)),
		IconColor = ColorSequence.new(Color3.fromRGB(255, 151, 66), Color3.fromRGB(255, 67, 67)),
		OnlyFishingType = "rod"
	},
	Embraced = {
		NameFormat = "Embraced",
		DescriptionFormat = [[
• +<$MutationPool.Embraced$>% Embraced Mutation rate
<$+StatsBullet::PassiveBoosts$>]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = false,
		Icon = "rbxassetid://76367641948766",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 121, 213), Color3.fromRGB(255, 130, 142)),
		IconColor = ColorSequence.new(Color3.fromRGB(255, 121, 213), Color3.fromRGB(255, 130, 142)),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	Frog = {
		NameFormat = "Frog <$StackNumeral$>",
		DescriptionFormat = "+<$PassiveBoosts.LuckMultiply$>× Luck",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = false,
		Icon = "rbxassetid://115474278604730",
		MainColor = Color3.fromRGB(69, 181, 49),
		IconColor = Color3.fromRGB(69, 181, 49),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		OnlyFishingType = "rod"
	},
	Swiftness = {
		NameFormat = "Swiftness",
		DescriptionFormat = [[
• +20% Movement Speed
• +20% Lure Speed
• +10% Progress Speed]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://138138306557955",
		MainColor = Color3.fromRGB(194, 227, 255),
		IconColor = Color3.fromRGB(194, 227, 255),
		FishingStatsAdd = {
			Lure = 20,
			ProgressSpeed = 10
		},
		WalkSpeedMultiply = 1.2
	},
	Endurance = {
		NameFormat = "Endurance",
		DescriptionFormat = "• +0.05 Control\n• +20% Resilience",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://93807213283522",
		MainColor = ColorSequence.new(Color3.fromRGB(90, 108, 135), Color3.fromRGB(55, 71, 100)),
		IconColor = ColorSequence.new(Color3.fromRGB(90, 108, 135), Color3.fromRGB(55, 71, 100)),
		FishingStatsAdd = {
			Control = 0.05,
			Resilience = 20
		}
	},
	Fortune = {
		NameFormat = "Fortune",
		DescriptionFormat = [[
• +50% Luck
• 25% chance to duplicate fish
• +25% Natural Mutation chance]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://119752580972029",
		MainColor = ColorSequence.new(Color3.fromRGB(203, 120, 255), Color3.fromRGB(127, 136, 250)),
		IconColor = ColorSequence.new(Color3.fromRGB(203, 120, 255), Color3.fromRGB(127, 136, 250)),
		FishingStatsAdd = {
			Luck = 50,
			NaturalMutationChance = 25
		},
		FishingPassives = {
			Generic_DuplicateFish = {
				DuplicateChance = 25,
				RequireDirectCatch = true,
				FishingTypes = "all",
				PassiveBlockLevel = 3
			}
		}
	},
	Depth = {
		NameFormat = "Depth",
		DescriptionFormat = [[
• +20% Fish Size
• +inf Max Kg
• +50 Line Distance]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://74727502841062",
		MainColor = ColorSequence.new(Color3.fromRGB(61, 88, 124), Color3.fromRGB(59, 65, 153)),
		IconColor = ColorSequence.new(Color3.fromRGB(61, 88, 124), Color3.fromRGB(59, 65, 153)),
		FishingStatsAdd = {
			WeightBoost = 20,
			Strength = 1e999,
			LineDistance = 50
		}
	},
	Wrath = {
		NameFormat = "Wrath",
		DescriptionFormat = [[
• +25% XP
• +5 Disturbance
• +200 Durability]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://94540402574685",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 49, 52), Color3.fromRGB(255, 44, 90)),
		IconColor = ColorSequence.new(Color3.fromRGB(255, 49, 52), Color3.fromRGB(255, 44, 90)),
		FishingStatsAdd = {
			XpMultiply = 0.25,
			Disturbance = 5,
			Durability = 200
		}
	},
	Slateskin = {
		NameFormat = "Slateskin",
		DescriptionFormat = [[
• +50 Max HP
• -25% Movement Speed
• Immunity to lightning
• You feel slightly heavier...]],
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://137762193687482",
		MainColor = ColorSequence.new(Color3.fromRGB(138, 166, 207), Color3.fromRGB(91, 109, 136)),
		IconColor = ColorSequence.new(Color3.fromRGB(138, 166, 207), Color3.fromRGB(91, 109, 136)),
		WalkSpeedMultiply = 0.75
	},
	Nico = {
		NameFormat = "Nico",
		DescriptionFormat = "mrrroew :3",
		StackMode = "none",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://94407542039308",
		MainColor = ColorSequence.new(Color3.fromRGB(252, 177, 213), Color3.fromRGB(251, 213, 153)),
		FishingPassives = {
			["Nico's Yarncaster"] = {
				BobberMutationPool = {},
				NicoMutationPool = {},
				TargetBobber = "Clownfish Cat Toy",
				FollowTime = 0.2,
				SleepInterval = 15,
				SleepToggleChance = 40,
				IdleTimeBeforeDive = 60,
				DiveChance = 33,
				TugInterval = 600,
				TugChance = 2,
				TugDuration = 5,
				TugStrength = 30,
				PassiveBlockLevel = 0
			}
		}
	},
	AncientLittleMeg = {
		NameFormat = "Ancient Power",
		DescriptionFormat = [[
• Doubled effectiveness of Jaw Constriction
• All low-rarity fish scared away]],
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://133687739332008",
		MainColor = ColorSequence.new(Color3.fromRGB(251, 142, 142), Color3.fromRGB(252, 228, 228))
	},
	ToucanFishScout = {
		NameFormat = "Scouted",
		DescriptionFormat = [[
<$Nickname$> is scouting for valuable fish!
• +<$LuckBoost$>% Luck
• +<$WeightBoost$>% Fish Weight]],
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://115103331721188",
		MainColor = ColorSequence.new(Color3.fromRGB(251, 190, 84), Color3.fromRGB(50, 35, 0)),
		FishingStatsAdd = {
			Luck = {
				_var_ = "LuckBoost"
			},
			WeightBoost = {
				_var_ = "WeightBoost"
			}
		}
	},
	LullabyQuickening = {
		NameFormat = "Quickening",
		DescriptionFormat = "Empowered by Quickening Symphony:\n<$+StatsBullet::StatBoosts$>",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://125195401804674",
		MainColor = ColorSequence.new(Color3.fromRGB(213, 255, 248), Color3.fromRGB(112, 236, 255)),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				}
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	LullabyStrengthening = {
		NameFormat = "Strengthening",
		DescriptionFormat = "Empowered by Strengthening Melody:\n<$+StatsBullet::StatBoosts$>",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://137881438860164",
		MainColor = ColorSequence.new(Color3.fromRGB(248, 135, 6), Color3.fromRGB(165, 37, 37)),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				}
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	LullabyFortuitous = {
		NameFormat = "Fortuitous",
		DescriptionFormat = "Empowered by Fortuitous Harmony:\n<$+StatsBullet::StatBoosts$>",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://75735607800057",
		MainColor = ColorSequence.new(Color3.fromRGB(229, 254, 122), Color3.fromRGB(120, 255, 134)),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				}
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	LullabyResistant = {
		NameFormat = "Resistant",
		DescriptionFormat = "Empowered by Resistant Composition:\n<$+StatsBullet::StatBoosts$>",
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://106206049362009",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 242, 23), Color3.fromRGB(177, 152, 48)),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				}
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	LullabyPrismatic = {
		NameFormat = "Prismatic",
		DescriptionFormat = table.concat({
			"Empowered by Prismatic Sinfonia:",
			"• +<$MutationPool.Prismatic$>% <font color='#d2a5ff'>Prismatic</font> Mutation Chance",
			"• +<$MutationPool.Mythical$>% <font color='#ff5294'>Mythical</font> Mutation Chance",
			"<$+StatsBullet::StatBoosts$>"
		}, "\n"),
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://103371808334979",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(202, 248, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(237, 239, 193)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(237, 194, 186))
		}),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				},
				MutationPool = {
					_var_ = "MutationPool"
				}
			}
		},
		FishingTypeEffectiveness = {
			cage = 0.5
		}
	},
	LullabySerenity = {
		NameFormat = "Serenity",
		DescriptionFormat = [[
Empowered by Serene Hymn:
• +<$MutationPool.Serene$>% <font color='#00ffe1'>Serene</font> Mutation Chance
<$+StatsBullet::StatBoosts$>]],
		StackMode = "with_source",
		AllowMultiple = true,
		CanRemove = true,
		Icon = "rbxassetid://110456768627220",
		MainColor = ColorSequence.new(Color3.fromRGB(250, 183, 255), Color3.fromRGB(198, 115, 204)),
		FishingPassives = {
			LullabyStatBoost = {
				Stats = {
					_var_ = "StatBoosts"
				},
				MutationPool = {
					_var_ = "MutationPool"
				}
			}
		}
	},
	Anglerfish = {
		NameFormat = "Anglerfish",
		DescriptionFormat = "Anglerfish",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://75275513184407",
		MainColor = Color3.fromRGB(225, 171, 161),
		FishingPassives = {
			Generic_ForcedReplacePool = {
				ReplacementPool = {
					Anglerfish = 100
				}
			}
		},
		WalkSpeedMultiply = 0.1
	},
	MoonlitBlessing = {
		NameFormat = "Moonlit Blessing",
		DescriptionFormat = "<$+StatsBullet::PassiveBoosts$>\n• 100% chance for Lunar mutation",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://130573043245984",
		MainColor = ColorSequence.new(Color3.fromRGB(206, 224, 255), Color3.fromRGB(74, 110, 200)),
		IconColor = ColorSequence.new(Color3.fromRGB(206, 224, 255), Color3.fromRGB(74, 110, 200)),
		FishingStatsAdd = {
			_var_ = "PassiveBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	ConstructEnchant = {
		NameFormat = "Enchanted",
		DescriptionFormat = "<$+StatsBullet::StatBoosts$>",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://111213700628842",
		MainColor = ColorSequence.new(Color3.fromRGB(85, 255, 193), Color3.fromRGB(93, 255, 104)),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	ConstructExalted = {
		NameFormat = "Exalted",
		DescriptionFormat = "<$+StatsBullet::StatBoosts$>",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://79066824574985",
		MainColor = ColorSequence.new(Color3.fromRGB(229, 167, 255), Color3.fromRGB(158, 226, 255)),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	ConstructCosmic = {
		NameFormat = "Cosmic",
		DescriptionFormat = "<$+StatsBullet::StatBoosts$>",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://80055965949958",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 99, 169), Color3.fromRGB(191, 80, 255)),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	ConstructTwisted = {
		NameFormat = "Twisted",
		DescriptionFormat = "Relic Construct will attack hooked fish periodically",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://104028602283751",
		MainColor = ColorSequence.new(Color3.fromRGB(99, 70, 166), Color3.fromRGB(38, 25, 45)),
		ClientFishingPassives = {
			RelicConstruct_TwistedAttack = {
				_var_ = "TwistedAttackConfig"
			}
		}
	},
	ConstructSovereign = {
		NameFormat = "Sovereign",
		DescriptionFormat = table.concat(
			{
				"• +<$MutationPool.Sovereign$>% <font color='#ada6ff'>Sovereign</font> Mutation Chance",
				"<$+StatsBullet::StatBoosts$>",
				"• Relic Construct will attack hooked fish rarely"
			},
			"\n"
		),
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://128633413956547",
		MainColor = ColorSequence.new(Color3.fromRGB(167, 179, 255), Color3.fromRGB(157, 133, 255)),
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "all"
			}
		},
		ClientFishingPassives = {
			RelicConstruct_TwistedAttack = {
				_var_ = "TwistedAttackConfig"
			}
		},
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	ConstructBlessed = {
		NameFormat = "Blessed",
		DescriptionFormat = "<$+StatsBullet::StatBoosts$>",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://77063190708643",
		MainColor = ColorSequence.new(Color3.fromRGB(128, 168, 255), Color3.fromRGB(179, 222, 255)),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	ConstructInvincible = {
		NameFormat = "Invincible",
		DescriptionFormat = "<$+StatsBullet::StatBoosts$>",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = false,
		Icon = "rbxassetid://117127637063318",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 114, 43), Color3.fromRGB(255, 207, 62)),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	SoulVision = {
		NameFormat = "Soul Vision",
		DescriptionFormat = "Can see moving Soul Pools",
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://70675988361237",
		IconColor = ColorSequence.new(Color3.fromRGB(28, 255, 160), Color3.fromRGB(35, 255, 90)),
		MainColor = ColorSequence.new(Color3.fromRGB(28, 255, 160), Color3.fromRGB(35, 255, 90))
	},
	Blazebringer = {
		NameFormat = "Ablaze <$StackNumeral$>",
		DescriptionFormat = [[
<$+StatsBullet::StatBoosts$>
• +<$MutationPool.Ember$>% <font color='#ffaa00'>Ember</font> chance
• +<$MutationPool.Cracked$>% <font color='#240036'>Cracked</font> chance
• +<$MutationPool.Emberflame$>% <font color='#ffaa00'>Emberflame</font> chance]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://76779510183446",
		MainColor = Color3.fromRGB(255, 170, 0),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	Darkness = {
		NameFormat = "Darkness <$StackNumeral$>",
		DescriptionFormat = [[
<$+StatsBullet::StatBoosts$>
• +<$MutationPool.Darkness$>% <font color='#303025'>Darkness</font> chance]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://130526509714895",
		MainColor = Color3.fromRGB(48, 48, 37),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	Light = {
		NameFormat = "Light <$StackNumeral$>",
		DescriptionFormat = [[
<$+StatsBullet::StatBoosts$>
• +<$MutationPool.Light$>% <font color='#fff5d8'>Light</font> chance]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://140550782584897",
		MainColor = Color3.fromRGB(255, 245, 216),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	InfernalMelody = {
		NameFormat = "Infernal Melody <$StackNumeral$>",
		DescriptionFormat = [[
<$+StatsBullet::StatBoosts$>
• +<$MutationPool.Scorched$>% <font color='#471e11'>Scorched</font> chance
• +<$MutationPool.Emberflame$>% <font color='#ffaa00'>Emberflame</font> chance
• +<$MutationPool.Infernal$>% <font color='#ff2c02'>Infernal</font> chance]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://79281785079831",
		MainColor = Color3.fromRGB(255, 44, 2),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	SMILE = {
		NameFormat = "SMILE <$StackNumeral$>",
		DescriptionFormat = [[
<$+StatsBullet::StatBoosts$>
• +<$MutationPool.Darkened$>% <font color='#000000'>Darkened</font> chance]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://74920242957556",
		MainColor = Color3.fromRGB(255, 255, 255),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "rod"
			}
		},
		OnlyFishingType = "rod"
	},
	CoconutCooler = {
		NameFormat = "Coconut Cooler",
		DescriptionFormat = [[
• +10% Resilience
• +5% Forced Progress Speed
• +10% Walk Speed]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://76089149787529",
		MainColor = Color3.fromRGB(97, 213, 255),
		FishingStatsAdd = {
			Resilience = 10,
			ForcedProgressSpeed = 5
		},
		WalkSpeedMultiply = 1.1
	},
	PineapplePunch = {
		NameFormat = "Pineapple Punch",
		DescriptionFormat = "• +25% Luck\n• +25% Natural Mutation Chance",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://97567044867261",
		MainColor = Color3.fromRGB(203, 255, 90),
		FishingStatsAdd = {
			Luck = 25,
			NaturalMutationChance = 25
		}
	},
	SunsetSmoothie = {
		NameFormat = "Sunset Smoothie",
		DescriptionFormat = "• +10% XP\n• +10% Fish Weight",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://133207200789490",
		MainColor = Color3.fromRGB(255, 171, 76),
		FishingStatsAdd = {
			XpMultiply = 0.1,
			WeightBoost = 10
		}
	},
	LagoonLemonade = {
		NameFormat = "Lagoon Lemonade",
		DescriptionFormat = "• +15% Lure Speed\n• +10% Progress Speed",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://111446616050843",
		MainColor = Color3.fromRGB(255, 219, 76),
		FishingStatsAdd = {
			Lure = 15,
			ProgressSpeed = 10
		}
	},
	SunburstSoda = {
		NameFormat = "Sunburst Soda",
		DescriptionFormat = "• +50 Line Distance\n• +3 Disturbance",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://130089010016891",
		MainColor = Color3.fromRGB(255, 126, 75),
		FishingStatsAdd = {
			LineDistance = 50,
			Disturbance = 3
		}
	},
	ReefRefresher = {
		NameFormat = "Reef Refresher",
		DescriptionFormat = "+5% True Progress Speed",
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://127563717243009",
		MainColor = Color3.fromRGB(255, 87, 174),
		FishingStatsAdd = {
			TrueProgressSpeed = 5
		}
	},
	NoCompanions = {
		NameFormat = "Separated",
		DescriptionFormat = "Your Companions can't help you here.",
		StackMode = "none",
		AllowMultiple = true,
		CanRemove = false,
		Icon = "rbxassetid://124797441208122",
		IconColor = Color3.fromRGB(193, 135, 135),
		MainColor = Color3.fromRGB(193, 135, 135)
	},
	KineticRelease = {
		NameFormat = "Kinetic Release",
		DescriptionFormat = [[
• +<$MutationPool.Clockwork$>% <font color='#ffce80'>Clockwork</font> Mutation Chance
<$+StatsBullet::StatBoosts$>]],
		StackMode = "with_source",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://77215890862281",
		MainColor = ColorSequence.new(Color3.fromRGB(255, 206, 61), Color3.fromRGB(220, 120, 40)),
		FishingPassives = {
			Generic_MutationPool = {
				MutationPool = {
					_var_ = "MutationPool"
				},
				FishingTypes = "all"
			}
		},
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		}
	},
	Wisdom = {
		NameFormat = "Wisdom <$StackNumeral$>",
		DescriptionFormat = "• <$StatBoostsMult.XpMultiply$>× XP\n<$+StatsBullet::StatBoosts$>",
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://139792686966380",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 238, 140)),
			ColorSequenceKeypoint.new(0.1, Color3.fromRGB(54, 37, 13)),
			ColorSequenceKeypoint.new(0.9, Color3.fromRGB(42, 29, 10)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 238, 140))
		}),
		FishingStatsAdd = {
			_var_ = "StatBoosts"
		},
		FishingStatsMultiply = {
			_var_ = "StatBoostsMult"
		},
		OnlyFishingType = "rod"
	},
	Propagation = {
		NameFormat = "Propagation <$Stack$>",
		DescriptionFormat = [[
• Toxic Fungus spawn rate increased by <$Percent::SpawnRateBoost$>%
• Progress boost rate increased by <$Percent::ProgressRateBoost$>%]],
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://75759344950964",
		IconColor = ColorSequence.new(Color3.fromRGB(211, 79, 255), Color3.fromRGB(134, 78, 255)),
		MainColor = ColorSequence.new(Color3.fromRGB(211, 79, 255), Color3.fromRGB(134, 78, 255))
	},
	DarkHeart = {
		NameFormat = "Dark Heart <$StackNumeral$>",
		DescriptionFormat = "When about to snap a reel due to progress loss, consumes 1 stack of this effect to <b>reset minigame progress to 20%</b>",
		StackMode = "none",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://93784975681164",
		MainColor = ColorSequence.new(Color3.fromRGB(53, 53, 53), Color3.fromRGB(0, 0, 0))
	},
	Stellar = {
		NameFormat = "Stellar",
		DescriptionFormat = [[
Every <$GiveFishEvery$> direct catch(es), catches an additional random fish, with a <$CosmicRelicChance$>% chance to be a Cosmic Relic.
<i>(Can transfer between rods)</i>]],
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "",
		MainColor = ColorSequence.new(Color3.fromRGB(231, 169, 255), Color3.fromRGB(170, 228, 255)),
		FishingPassives = {
			Generic_BonusCatch = {
				GiveFishEvery = {
					_var_ = "GiveFishEvery"
				},
				FishCount = 1,
				PassiveBlockLevel = 0,
				AddedFixedChanceFish = {
					["Cosmic Relic"] = {
						_var_ = "CosmicRelicChance"
					}
				}
			}
		}
	},
	FruityBlessing = {
		NameFormat = "Fruity Blessing",
		DescriptionFormat = [[
• <$StatMultiplier$>× Luck, Lure, Strength, Resilience, Control, Progress Speed and Line Distance
• Equipped companion acts <$CompanionLevels$> level(s) higher]],
		StackMode = "with_all",
		AllowMultiple = false,
		CanRemove = true,
		Icon = "rbxassetid://98091547951779",
		MainColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 108, 128)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 214, 92)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(126, 217, 87))
		}),
		FishingPassives = {
			Generic_SignedStatMultiply = {
				Multiplier = {
					_var_ = "StatMultiplier"
				},
				Stats = {
					"Luck",
					"Lure",
					"Strength",
					"Resilience",
					"Control",
					"ProgressSpeed",
					"LineDistance"
				}
			},
			Generic_CompanionLevelBoost = {
				Levels = {
					_var_ = "CompanionLevels"
				}
			}
		}
	}
}