local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GradientRichText = require(ReplicatedStorage.shared.utils.FischUtils.Shared.GradientRichText)
local mutations = require(ReplicatedStorage.shared.modules.fishing.mutations)
local mutations2 = mutations.Mutations
local attributes = require(ReplicatedStorage.shared.modules.library.attributes)
local byName = attributes.byName
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
local Mastery = {
	Mastery = {
		Castbound = {
			MinimumLevel = 1000,
			Quests = {
				Castbound1 = {
					Name = "Anger",
					Order = 1,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						{
							Mutation = "Fury"
						}
					},
					Reward = {
						Info = { "Lantern", "Prisma" }
					}
				},
				Castbound2 = {
					Name = "Like a Boss",
					Order = 2,
					Goal = {
						"CatchFish",
						3,
						{ "Rotbloom" },
						nil,
						{
							Perfect = true
						},
						{ "Castbound" }
					},
					Reward = {
						Info = { "Bobber", "Gemidium" }
					}
				},
				Castbound3 = {
					Name = "The Journey's End?",
					Order = 3,
					Goal = {
						"HaveRod",
						5,
						{
							"Igneous Rupturer",
							"Tidemourner",
							"Verdant Oath",
							"Wind Elemental",
							"Zeus's Thundermaul"
						}
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Castbound",
							"Mastery1",
							"+200 Durability, 3 More Chances, +50% Slash Rate, Perfect Casts = +10% Base Chance for All Passive Mutations & +5% Starting Progress"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Copperbound" }
			}
		},
		["Crew Rod"] = {
			MinimumLevel = 500,
			Quests = {
				CrewRod1 = {
					Name = "5 Star Review",
					Order = 1,
					Goal = { "PersonalCrewRating", 2500 },
					Reward = {
						Info = { "Skin", "Mastered Crew Rod" }
					}
				},
				CrewRod2 = {
					Name = "Wait. We need more Perfect Catch Quests!",
					Order = 2,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Crew Rod" }
					},
					Reward = {
						Info = {
							"ItemOrFish",
							"Rainbow Totem",
							nil,
							5
						}
					}
				},
				CrewRod3 = {
					Name = "It's a SECRET...",
					Order = 3,
					Goal = {
						"CatchFish",
						15,
						nil,
						{ "Secret" },
						nil,
						{ "Crew Rod" }
					},
					Reward = {
						Info = {
							"ItemOrFish",
							"Brine Storm Totem",
							nil,
							1
						}
					}
				}
			},
			CompleteReward = {
				Info = {
					"RodEnhancement",
					"Crew Rod",
					"Mastery1",
					"×3 Divine Secret Luck"
				}
			}
		},
		Part = {
			MinimumLevel = 1,
			Quests = {
				Part1 = {
					Name = "Part One",
					Order = 1,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						nil,
						{ "Part" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Part",
							"Mastery1",
							"Part Awakening"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Part" }
			}
		},
		["Heaven's Rod"] = {
			MinimumLevel = 300,
			Quests = {
				HeavensRod1 = {
					Name = "Ascend the Basics",
					Order = 1,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						nil,
						{ "Heaven's Rod" }
					},
					Reward = {
						Info = { "Title", "Heavenly Angler" }
					}
				},
				HeavensRod2 = {
					Name = "Heavenly Rarities",
					Order = 2,
					Goal = {
						"CatchFish",
						100,
						nil,
						{ "Legendary" },
						nil,
						{ "Heaven's Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Heaven's Rod",
							"Mastery1",
							"+10% Progress Speed, +5% Heavenly Mutation chance"
						}
					}
				},
				HeavensRod3 = {
					Name = "Divine Offering",
					Order = 3,
					Goal = {
						"CatchFish",
						50,
						nil,
						{ "Exotic" },
						{
							Mutation = "Heavenly"
						},
						{ "Heaven's Rod" }
					},
					Reward = {
						Info = {
							{
								"RodEnhancement",
								"Heaven's Rod",
								"Mastery2",
								"Heavenly Beam Passive"
							},
							{ "Skin", "Heavenly Breeze" }
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Heaven's Rod" }
			}
		},
		["Flimsy Rod"] = {
			MinimumLevel = 3,
			Quests = {
				FlimsyRod1 = {
					Name = "Fragile Beginnings",
					Order = 1,
					Goal = {
						"CatchFish",
						20,
						nil,
						nil,
						nil,
						{ "Flimsy Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 2500 }
					}
				},
				FlimsyRod2 = {
					Name = "The Perfect Cast",
					Order = 2,
					Goal = {
						"CatchFish",
						8,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Flimsy Rod" }
					},
					Reward = {
						Info = { "Xp", 5000 }
					}
				},
				FlimsyRod3 = {
					Name = "Flimsy Fortune",
					Order = 3,
					Goal = { "SellFish", 10, nil },
					Reward = {
						Info = { "Bait", "Seaweed", 20 }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Flimsy Rod" }
			}
		},
		["Zeus Rod"] = {
			MinimumLevel = 65,
			Quests = {
				ZeusRod1 = {
					Name = "Bolt of the Gods",
					Order = 1,
					Goal = {
						"CatchFish",
						25,
						{ "Zeus' Herald" },
						nil,
						nil,
						{ "Zeus Rod" },
						{ "Rapid Catcher" }
					},
					Reward = {
						Info = { "Currency", "Coins", 750000 }
					}
				},
				ZeusRod2 = {
					Name = "Summon the Storm",
					Order = 2,
					Goal = {
						"TotemUse",
						3,
						{ "Zeus Storm Totem" }
					},
					Reward = {
						Info = { "Skin", "Silver Bolt" }
					}
				},
				ZeusRod3 = {
					Name = "Electrified Haul",
					Order = 3,
					Goal = {
						"CatchFish",
						300,
						nil,
						nil,
						{
							Mutation = "Electric Shock"
						},
						{ "Zeus Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Zeus Rod",
							"Mastery1",
							"Periodic slashes"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Zeus Rod" }
			}
		},
		["Rod Of The Depths"] = {
			MinimumLevel = 20,
			Quests = {
				RodOfTheDepths1 = {
					Name = "Plunge into Darkness",
					Order = 1,
					Goal = {
						"CatchFish",
						5,
						{ "Enchant Relic" },
						nil,
						nil,
						{ "Rod Of The Depths" }
					},
					Reward = {
						Info = { "Title", "Abyssal Fischer" }
					}
				},
				RodOfTheDepths2 = {
					Name = "Value the Void",
					Order = 2,
					Goal = {
						"AppraiseFish",
						100,
						{ "Ancient Depth Serpent" }
					},
					Reward = {
						Info = { "Lantern", "Abyssal Glow" }
					}
				},
				RodOfTheDepths3 = {
					Name = "Ancient Depthseeker",
					Order = 3,
					Goal = {
						"CatchFish",
						20,
						{ "Ancient Depth Serpent" },
						nil,
						nil,
						{ "Rod Of The Depths" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod Of The Depths",
							"Mastery1",
							"Increased Spirit Catch Frequency"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Rod Of The Depths" }
			}
		},
		["Kings Rod"] = {
			MinimumLevel = 25,
			Quests = {
				KingsRod1 = {
					Name = "Royal Decree",
					Order = 1,
					Goal = {
						"CatchFish",
						50,
						nil,
						{ "Mythical", "Legendary" },
						nil,
						{ "Kings Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 55000 }
					}
				},
				KingsRod2 = {
					Name = "Crown's Treasury",
					Order = 2,
					Goal = {
						"SellFish",
						3,
						{ "Great White Shark", "Whale Shark", "Great Hammerhead Shark" }
					},
					Reward = {
						Info = { "Title", "King of the Seas" }
					}
				},
				KingsRod3 = {
					Name = "King's Catch",
					Order = 3,
					Goal = {
						"CatchFish",
						8,
						{ "Megalodon" },
						nil,
						nil,
						{ "Kings Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Kings Rod",
							"Mastery1",
							"+10% Size, +20% Progress Speed"
						}
					}
				},
				KingsRod4 = {
					Name = "Enlargement",
					Order = 4,
					Goal = {
						"AppraiseFish",
						150,
						{ "Megalodon" }
					},
					Reward = {
						Info = { "Skin", "XL Kings Rod" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Kings Rod" }
			}
		},
		["Trident Rod"] = {
			MinimumLevel = 30,
			Quests = {
				TridentRod1 = {
					Name = "Captain's Fury",
					Order = 1,
					Goal = {
						"CatchFish",
						25,
						{ "Captain's Goldfish" },
						nil,
						{
							Mutation = "Atlantean"
						},
						{ "Trident Rod" }
					},
					Reward = {
						Info = { "Boat", "Atlantean Pontoon" }
					}
				},
				TridentRod2 = {
					Name = "Poseidon's Seaweed",
					Order = 2,
					Goal = {
						"BaitUse",
						120,
						{ "Seaweed" }
					},
					Reward = {
						Info = { "Lantern", "Poseidon's Light" }
					}
				},
				TridentRod3 = {
					Name = "Sea Mine Calling",
					Order = 3,
					Goal = {
						"CatchFishAny",
						3,
						{ "Sea Mine" }
					},
					Reward = {
						Info = {
							{ "Currency", "Coins", 125000 },
							{ "Title", "Boomer" }
						}
					}
				},
				TridentRod4 = {
					Name = "Spear The Elusive",
					Order = 4,
					Goal = {
						"CatchFish",
						200,
						nil,
						{ "Mythical", "Legendary" },
						nil,
						{ "Trident Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Trident Rod",
							"Mastery1",
							"+35% Lure Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Trident Rod" }
			}
		},
		["Steady Rod"] = {
			MinimumLevel = 5,
			Quests = {
				SteadyRod1 = {
					Name = "Enduring Journey",
					Order = 1,
					Goal = {
						"CatchFish",
						25,
						{ "Manta Ray" },
						nil,
						nil,
						{ "Steady Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 5000 }
					}
				},
				SteadyRod2 = {
					Name = "Unwavering Line",
					Order = 2,
					Goal = {
						"CatchFish",
						5,
						{ "Colossal Squid" },
						nil,
						nil,
						{ "Steady Rod" }
					},
					Reward = {
						Info = { "Title", "Steady Conqueror" }
					}
				},
				SteadyRod3 = {
					Name = "Stable Sales",
					Order = 3,
					Goal = { "SellFish", 50, nil },
					Reward = {
						Info = {
							"RodEnhancement",
							"Steady Rod",
							"Mastery1",
							"+30% Lure Speed, +10% Progress Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Steady Rod" }
			}
		},
		["No-Life Rod"] = {
			MinimumLevel = 30,
			Quests = {
				NoLifeRod1 = {
					Name = "Endless Grind",
					Order = 1,
					Goal = {
						"CatchFish",
						500,
						nil,
						nil,
						{
							Mutation = "Hexed"
						},
						{ "No-Life Rod" }
					},
					Reward = {
						Info = { "Lantern", "Hexed Luminescence" }
					}
				},
				NoLifeRod2 = {
					Name = "Mastered Merchant",
					Order = 2,
					Goal = {
						"SellFish",
						20,
						{ "Scylla" }
					},
					Reward = {
						Info = { "Title", "Lifeless Merchant" }
					}
				},
				NoLifeRod3 = {
					Name = "Lifeless Perfection",
					Order = 3,
					Goal = {
						"CatchFish",
						500,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "No-Life Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"No-Life Rod",
							"Mastery1",
							"+25% Progress Speed, +0.05 Control, +10% Lure Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden No-Life Rod" }
			}
		},
		["Seraphic Rod"] = {
			MinimumLevel = 1000,
			Quests = {
				SeraphicRod1 = {
					Name = "Pure Blessings",
					Order = 1,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						{
							Mutation = "Blessed"
						},
						{ "Seraphic Rod" }
					},
					Reward = {
						Info = { "Lantern", "Blessed Gleam" }
					}
				},
				SeraphicRod2 = {
					Name = "Perfectionist of Danger",
					Order = 2,
					Goal = {
						"CatchFish",
						20,
						nil,
						{ "Apex" },
						{
							Perfect = true
						},
						{ "Seraphic Rod" }
					},
					Reward = {
						Info = { "Title", "Blessing" }
					}
				},
				SeraphicRod3 = {
					Name = "Perfection of the Skies",
					Order = 3,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Seraphic Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Seraphic Rod",
							"Mastery1",
							"???"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Biblically Accurate Seraphic Rod" }
			}
		},
		["Ethereal Prism Rod"] = {
			MinimumLevel = 100,
			Quests = {
				EtherealPrismRod1 = {
					Name = "Prismatic Visions",
					Order = 1,
					Goal = {
						"SellFish",
						350,
						{
							"Shimmering Silverside",
							"Crystal Corydoras",
							"Ruby Rasbora",
							"Prismatic Parrotfish"
						}
					},
					Reward = {
						Info = { "Bobber", "Prismatic Gem" }
					}
				},
				EtherealPrismRod2 = {
					Name = "Ethereal Mutations",
					Order = 2,
					Goal = {
						"CatchFish",
						250,
						nil,
						nil,
						{
							Perfect = true,
							Mutation = "Prismize"
						},
						{ "Ethereal Prism Rod" }
					},
					Reward = {
						Info = { "Title", "Ethereal" }
					}
				},
				EtherealPrismRod3 = {
					Name = "Crystallized Perfection",
					Order = 3,
					Goal = {
						"CatchFish",
						20,
						{ "Crystallized Seadragon" },
						nil,
						{
							Perfect = true,
							Mutation = "Prismize"
						},
						{ "Ethereal Prism Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Ethereal Prism Rod",
							"Mastery1",
							"+10% Progress Speed, +5% Lure Speed, +10% Prismize Rate"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Ethereal Prism Rod" }
			}
		},
		["Rod Of The Forgotten Fang"] = {
			MinimumLevel = 750,
			Quests = {
				RodOfTheForgottenFang1 = {
					Name = "Lost Fangs",
					Order = 1,
					Goal = {
						"CatchFish",
						20,
						{ "Megalodon" },
						nil,
						nil,
						{ "Rod Of The Forgotten Fang" }
					},
					Reward = {
						Info = { "Title", "Forgotten" }
					}
				},
				RodOfTheForgottenFang2 = {
					Name = "Ancient Fangs",
					Order = 2,
					Goal = {
						"CatchFish",
						15,
						{ "Ancient Megalodon" },
						nil,
						nil,
						{ "Rod Of The Forgotten Fang" }
					},
					Reward = {
						Info = { "Boat", "Ancient Megalodon" }
					}
				},
				RodOfTheForgottenFang3 = {
					Name = "Ghostly Fangs",
					Order = 3,
					Goal = {
						"CatchFish",
						2,
						{ "Phantom Megalodon" },
						nil,
						nil,
						{ "Rod Of The Forgotten Fang" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod Of The Forgotten Fang",
							"Mastery1",
							"Megalodon Catch Frequency Increased"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Rod Of The Forgotten Fang" }
			}
		},
		["Magnet Rod"] = {
			MinimumLevel = 1,
			Quests = {
				MagnetRod1 = {
					Name = "Magnetic Pull",
					Order = 1,
					Goal = {
						"CatchFish",
						50,
						{ "Bait Crate" },
						nil,
						nil,
						{ "Magnet Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 20000 }
					}
				},
				MagnetRod2 = {
					Name = "Attract the Distance",
					Order = 2,
					Goal = {
						"CatchFish",
						75,
						{ "Quality Bait Crate" },
						nil,
						nil,
						{ "Magnet Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Magnet Rod",
							"Mastery1",
							"+70% Lure Speed"
						}
					}
				},
				MagnetRod3 = {
					Name = "Magnetic Call",
					Order = 3,
					Goal = {
						"BaitUse",
						50,
						{ "Magnet" }
					},
					Reward = {
						Info = { "Boat", "Magnet" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Magnet Rod" }
			}
		},
		["Midas Rod"] = {
			MinimumLevel = 30,
			Quests = {
				MidasRod1 = {
					Name = "Touch of Gold",
					Order = 1,
					Goal = {
						"CatchFish",
						25,
						nil,
						{ "Mythical", "Legendary" },
						{
							Mutation = "Midas"
						},
						{ "Midas Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 75000 }
					}
				},
				MidasRod2 = {
					Name = "Golden Perfection",
					Order = 2,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						{
							Perfect = true,
							Mutation = "Midas"
						},
						{ "Midas Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Midas Rod",
							"Mastery1",
							"+30% Resilience, +10% Progress Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Midas Rod" }
			}
		},
		["Aurora Rod"] = {
			MinimumLevel = 20,
			Quests = {
				AuroraRod1 = {
					Name = "Lights of the North",
					Order = 1,
					Goal = {
						"CatchFish",
						70,
						nil,
						nil,
						{
							Mutation = "Aurora"
						},
						{ "Aurora Rod" }
					},
					Reward = {
						Info = {
							{ "Currency", "Coins", 35000 },
							{ "Bait", "Aurora Bait", 50 }
						}
					}
				},
				AuroraRod2 = {
					Name = "Northern Trek",
					Order = 2,
					Goal = {
						"CatchFish",
						25,
						{ "Captain's Goldfish" },
						nil,
						{
							Mutation = "Aurora"
						},
						{ "Aurora Rod" }
					},
					Reward = {
						Info = { "Lantern", "Aurora Light" }
					}
				},
				AuroraRod3 = {
					Name = "Aurora Summoner",
					Order = 3,
					Goal = {
						"TotemUse",
						3,
						{ "Aurora Totem" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Aurora Rod",
							"Mastery1",
							"+30% Lure Speed, +10% Aurora Rate"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Aurora Rod" }
			}
		},
		["Mythical Rod"] = {
			MinimumLevel = 25,
			Quests = {
				MythicalRod1 = {
					Name = "Lights of the Rainbow",
					Order = 1,
					Goal = {
						"CatchFish",
						70,
						nil,
						nil,
						{
							Mutation = "Mythical"
						},
						{ "Mythical Rod" }
					},
					Reward = {
						Info = {
							{ "Currency", "Coins", 35000 },
							{ "Bait", "Coral", 115 }
						}
					}
				},
				MythicalRod2 = {
					Name = "Mythical Rolling",
					Order = 2,
					Goal = { "AppraiseFish", 100, nil },
					Reward = {
						Info = { "Bobber", "Founders Rainbow" }
					}
				},
				MythicalRod3 = {
					Name = "Mythical Perfectionist",
					Order = 3,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Mythical Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Mythical Rod",
							"Mastery1",
							"+35% Lure Speed, +5% Mythical Rate"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Mythical Rod" }
			}
		},
		["Summit Rod"] = {
			MinimumLevel = 50,
			Quests = {
				SummitRod1 = {
					Name = "Summit Spirits",
					Order = 1,
					Goal = {
						"TotemUse",
						1,
						{ "Avalanche Totem" }
					},
					Reward = {
						Info = { "Currency", "Coins", 125000 }
					}
				},
				SummitRod2 = {
					Name = "Peak Catches",
					Order = 2,
					Goal = {
						"CatchFish",
						75,
						{ "Icebeard Shark", "Borealis Snapper" },
						nil,
						nil,
						{ "Summit Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Summit Rod",
							"Mastery1",
							"+25% Lure Speed, +5% Rate to each Mutation"
						}
					}
				},
				SummitRod3 = {
					Name = "Frostmaster of the Anchovy",
					Order = 3,
					Goal = {
						"CatchFish",
						15,
						{ "Ice Anchovy" },
						nil,
						{
							Mutation = "Blighted"
						},
						{ "Summit Rod" }
					},
					Reward = {
						Info = { "Title", "⛰️" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Summit Rod" }
			}
		},
		["Wisdom Rod"] = {
			MinimumLevel = 100,
			Quests = {
				WisdomRod1 = {
					Name = "Wise Appraisal",
					Order = 1,
					Goal = { "AppraiseFish", 50, nil },
					Reward = {
						Info = { "Xp", 150000 }
					}
				},
				WisdomRod2 = {
					Name = "Seek Knowledge",
					Order = 2,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						nil,
						{ "Wisdom Rod" }
					},
					Reward = {
						Info = { "Xp", 300000 }
					}
				},
				WisdomRod3 = {
					Name = "Enlightened Catches",
					Order = 3,
					Goal = {
						"CatchFish",
						200,
						nil,
						{ "Mythical", "Exotic" },
						nil,
						{ "Wisdom Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Wisdom Rod",
							"Mastery1",
							"Double XP gained from Passive"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Wisdom Rod" }
			}
		},
		["Rod Of The Exalted One"] = {
			MinimumLevel = 450,
			Quests = {
				RodOfTheExaltedOne1 = {
					Name = "Exalted Greatness",
					Order = 1,
					Goal = {
						"CatchFish",
						1,
						{ "Exalted Relic" },
						nil,
						nil,
						{ "Rod Of The Exalted One" }
					},
					Reward = {
						Info = { "Title", "Exalted" }
					}
				},
				RodOfTheExaltedOne2 = {
					Name = "Exalted Glory",
					Order = 2,
					Goal = {
						"CatchFish",
						3,
						{ "Exalted Relic" },
						nil,
						nil,
						{ "Rod Of The Exalted One" }
					},
					Reward = {
						Info = { "Bobber", "Exalted Bobber" }
					}
				},
				RodOfTheExaltedOne3 = {
					Name = "The Exalted One",
					Order = 4,
					Goal = {
						"CatchFish",
						10,
						{ "Exalted Relic" },
						nil,
						nil,
						{ "Rod Of The Exalted One" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod Of The Exalted One",
							"Mastery1",
							"2× chance for Sovereign Relic"
						}
					}
				},
				RodOfTheExaltedOne4 = {
					Name = "Supreme Exaltations",
					Order = 3,
					Goal = {
						"CatchFish",
						8,
						{ "Exalted Relic" },
						nil,
						nil,
						{ "Rod Of The Exalted One" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod Of The Exalted One",
							"Mastery2",
							"Exalted Guardian"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Rod Of The Exalted One" }
			}
		},
		["Abyssal Specter Rod"] = {
			MinimumLevel = 60,
			Quests = {
				AbyssalSpecterRod1 = {
					Name = "Echoes of the Abyss",
					Order = 1,
					Goal = { "ConceptionConch", 50 },
					Reward = {
						Info = { "Bobber", "Ghostly Conch" }
					}
				},
				AbyssalSpecterRod2 = {
					Name = "Ghostly Traps",
					Order = 2,
					Goal = { "CatchFishWithCrabCage", 200, nil },
					Reward = {
						Info = { "Title", "Ghostly Trapper" }
					}
				},
				AbyssalSpecterRod3 = {
					Name = "Spectral Phantasm",
					Order = 3,
					Goal = {
						"CatchFish",
						1,
						{ "Phantom Megalodon" },
						nil,
						{
							Mutation = "Abyssal"
						},
						{ "Abyssal Specter Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Abyssal Specter Rod",
							"Mastery1",
							"+10% Weight Buff, +10% Abyssal Rate, +5% Progress Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Abyssal Specter Rod" }
			}
		},
		["Rod Of The Zenith"] = {
			MinimumLevel = 80,
			Quests = {
				RodOfTheZenith1 = {
					Name = "Royalty of Perfection",
					Order = 1,
					Goal = {
						"CatchFish",
						3,
						{ "Crowned Anglerfish" },
						nil,
						{
							Perfect = true
						},
						{ "Rod Of The Zenith" }
					},
					Reward = {
						Info = { "Boat", "Mini Crowned Anglerfish" }
					}
				},
				RodOfTheZenith2 = {
					Name = "Expression of Wrath",
					Order = 2,
					Goal = {
						"CatchFish",
						100,
						nil,
						{ "Legendary", "Mythical" },
						{
							Mutation = "Wrath"
						},
						{ "Rod Of The Zenith" }
					},
					Reward = {
						Info = { "Title", "Wrath" }
					}
				},
				RodOfTheZenith3 = {
					Name = "The True Challenge",
					Order = 3,
					Goal = {
						"CatchFish",
						1,
						{ "Scylla" },
						nil,
						{
							Perfect = true
						},
						{ "Rod Of The Zenith" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod Of The Zenith",
							"Mastery1",
							"+20% Progress Speed + Occasional slashes"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Rod Of The Zenith" }
			}
		},
		["Tryhard Rod"] = {
			MinimumLevel = 1000,
			Quests = {
				TryhardRod1 = {
					Name = "a lot of fish...",
					Order = 1,
					Goal = {
						"CatchFish",
						5000,
						nil,
						nil,
						nil,
						{ "Tryhard Rod" }
					},
					Reward = {
						Info = { "Lantern", "Tryhard Lantern" }
					}
				},
				TryhardRod2 = {
					Name = "a lot of selling...",
					Order = 2,
					Goal = { "SellFish", 10000, nil },
					Reward = {
						Info = { "Bobber", "Tryhard Bobber" }
					}
				},
				TryhardRod3 = {
					Name = "THE TRUE TRYHARD!",
					Order = 3,
					Goal = {
						"CatchFish",
						30,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Tryhard Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Tryhard Rod",
							"Mastery1",
							"+20% Lure Speed, +15% Forced Progress Speed, +10% Progress Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Tryhard Rod" }
			}
		},
		["Destiny Rod"] = {
			MinimumLevel = 1,
			Quests = {
				DestinyRod1 = {
					Name = "Glistening Ascension",
					Order = 1,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Shiny = true,
							Sparkling = true
						},
						{ "Destiny Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Destiny Rod",
							"Mastery1",
							"+15% Progress Speed, +5% Shiny/Sparkling chance, +5% Blessed chance"
						}
					}
				},
				DestinyRod2 = {
					Name = "Sparkling Perfection",
					Order = 2,
					Goal = {
						"CatchFish",
						150,
						nil,
						nil,
						{
							Perfect = true,
							Sparkling = true
						},
						{ "Destiny Rod" }
					},
					Reward = {
						Info = { "Title", "Destiny" }
					}
				},
				DestinyRod3 = {
					Name = "Shiny Offering",
					Order = 3,
					Goal = {
						"CatchFish",
						200,
						nil,
						{ "Legendary", "Mythical" },
						{
							Shiny = true
						},
						{ "Destiny Rod" }
					},
					Reward = {
						Info = { "Skin", "Dark Destiny" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Destiny Rod" }
			}
		},
		Duskwire = {
			MinimumLevel = 325,
			Quests = {
				Duskwire1 = {
					Name = "Absolute Serenity",
					Order = 1,
					Goal = {
						"CatchFish",
						40,
						nil,
						nil,
						{
							Mutation = "Serene"
						},
						{ "Duskwire" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Duskwire",
							"Mastery1",
							"+20% Chaotic Rate, +3% Serene Rate (+7% for Perfect Catches)"
						}
					}
				},
				Duskwire2 = {
					Name = "Perfection of Dusk",
					Order = 2,
					Goal = {
						"CatchFish",
						200,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Duskwire" }
					},
					Reward = {
						Info = { "Title", "Dusk" }
					}
				},
				Duskwire3 = {
					Name = "Pure Chaos",
					Order = 3,
					Goal = {
						"CatchFish",
						1000,
						nil,
						{ "Legendary", "Mythical" },
						{
							Mutation = "Chaotic"
						},
						{ "Duskwire" }
					},
					Reward = {
						Info = { "Bobber", "Dusk Bobber" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Crosslink" }
			}
		},
		Spiritbinder = {
			MinimumLevel = 920,
			Quests = {
				Spiritbinder1 = {
					Name = "Bulk Spirits",
					Order = 1,
					Goal = {
						"CatchFish",
						500,
						nil,
						nil,
						{
							Mutation = "Spirit"
						},
						{ "Spiritbinder" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Spiritbinder",
							"Mastery1",
							"Passive cooldown reduced (60s → 45s)"
						}
					}
				},
				Spiritbinder2 = {
					Name = "Perfection of Spirits",
					Order = 2,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Spiritbinder" }
					},
					Reward = {
						Info = { "Title", "Spirit" }
					}
				},
				Spiritbinder3 = {
					Name = "Secrets of the Spirits",
					Order = 3,
					Goal = {
						"CatchFish",
						100,
						nil,
						{ "Exotic", "Secret" },
						nil,
						{ "Spiritbinder" }
					},
					Reward = {
						Info = { "Bobber", "Spirit Bobber" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Spiritbinder" }
			}
		},
		["The Boom Ball"] = {
			MinimumLevel = 1,
			Quests = {
				TheBoomBall1 = {
					Name = "What are you doing?",
					Order = 1,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						{
							Mutation = "Exploded"
						},
						{ "The Boom Ball" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"The Boom Ball",
							"Mastery1",
							"Guaranteed Explosions; with a sound boost!"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden The Boom Ball" }
			}
		},
		["Ruinous Oath"] = {
			MinimumLevel = 1000,
			Quests = {
				RuinousOath1 = {
					Name = "True Mastery",
					Order = 1,
					Goal = {
						"CatchFish",
						1000,
						nil,
						nil,
						{
							Mutation = "Mastered"
						},
						{ "Ruinous Oath" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Ruinous Oath",
							"Mastery1",
							"+15% Fish Size"
						}
					}
				},
				RuinousOath2 = {
					Name = "Ruinous Cataclysm",
					Order = 2,
					Goal = {
						"CatchFish",
						5,
						nil,
						{ "Apex" },
						nil,
						{ "Ruinous Oath" }
					},
					Reward = {
						Info = { "Title", "Ruined" }
					}
				},
				RuinousOath3 = {
					Name = "Ethereal King",
					Order = 3,
					Goal = {
						"CatchFish",
						2,
						{ "Colossal Ethereal Dragon" },
						nil,
						{
							Perfect = true
						},
						{ "Ruinous Oath" }
					},
					Reward = {
						Info = { "Bobber", "Ethereal Bobber" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Ruinous Oath" }
			}
		},
		["Evil Pitchfork"] = {
			MinimumLevel = 500,
			Quests = {
				EvilPitchfork1 = {
					Name = "Spirits of Ruin",
					Order = 1,
					Goal = {
						"CatchFish",
						5,
						{ "Enchant Relic" },
						nil,
						{
							Mutation = "Evil"
						},
						{ "Evil Pitchfork" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Evil Pitchfork",
							"Mastery1",
							"5× Value -> 10× Value"
						}
					}
				},
				EvilPitchfork2 = {
					Name = "Unholy Perfection",
					Order = 2,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Perfect = true,
							Mutation = "Evil"
						},
						{ "Evil Pitchfork" }
					},
					Reward = {
						Info = { "Title", "Evil" }
					}
				},
				EvilPitchfork3 = {
					Name = "Whispers Beyond the Veil",
					Order = 3,
					Goal = {
						"CatchFish",
						3,
						{ "Colossal Ancient Dragon" },
						nil,
						{
							Perfect = true
						},
						{ "Evil Pitchfork" }
					},
					Reward = {
						Info = { "Skin", "Voidpiercer" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Evil Pitchfork" }
			}
		},
		Onirifalx = {
			MinimumLevel = 1000,
			Quests = {
				Onirifalx1 = {
					Name = "🤔",
					Order = 1,
					Goal = {
						"CatchFish",
						1,
						{
							"🐋",
							"🦈",
							"🦑",
							"🐡",
							"🐟"
						},
						nil,
						nil,
						{ "Onirifalx" }
					},
					Reward = {
						Info = { "Skin", "XL Onirifalx" }
					}
				},
				Onirifalx2 = {
					Name = "Scylla Collection!",
					Order = 2,
					Goal = {
						"CatchFish",
						15,
						{ "Scylla" },
						nil,
						{
							Perfect = true
						},
						{ "Onirifalx" }
					},
					Reward = {
						Info = { "Title", "The Greatest" }
					}
				},
				Onirifalx3 = {
					Name = "Floppy Floppy Floppy!",
					Order = 3,
					Goal = {
						"CatchFish",
						500,
						{ "Floppy" },
						nil,
						{
							Perfect = true
						},
						{ "Onirifalx" }
					},
					Reward = {
						Info = { "Bobber", "Floppy Bobber" }
					}
				},
				Onirifalx4 = {
					Name = "Floppy Stocks!",
					Order = 4,
					Goal = {
						"AppraiseFish",
						500,
						{ "Floppy" }
					},
					Reward = {
						Info = { "Skin", "Floppinator" }
					}
				},
				Onirifalx5 = {
					Name = "The Finale...",
					Order = 5,
					Goal = {
						"CatchFish",
						10000,
						nil,
						nil,
						nil,
						{ "Onirifalx" }
					},
					Reward = {
						Info = {
							{
								"RodEnhancement",
								"Onirifalx",
								"Mastery1",
								"Pure Strength..."
							},
							{ "Title", "❌🌿" }
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Onirifalx" }
			}
		},
		["Blade Of Glorp"] = {
			MinimumLevel = 1000,
			Quests = {
				Glorp1 = {
					Name = "Enchanted Gleebs",
					Order = 1,
					Goal = {
						"CatchFish",
						10,
						{ "Enchant Relic" },
						nil,
						{
							Mutation = "Gleebous"
						},
						{ "Blade Of Glorp" }
					},
					Reward = {
						Info = { "Title", "Glorply" }
					}
				},
				Glorp2 = {
					Name = "Gleeb Stocks",
					Order = 2,
					Goal = {
						"SellFish",
						150,
						nil,
						{
							Mutation = "Gleebous"
						}
					},
					Reward = {
						Info = { "Bobber", "UFO Of Glorp" }
					}
				},
				Glorp3 = {
					Name = "Perfect Destruction",
					Order = 3,
					Goal = {
						"CatchFish",
						250,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Blade Of Glorp" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Blade Of Glorp",
							"Mastery1",
							"+1 UFO (1/5 > 1/3 Chance to LASER), +10% Gleebous Chance"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Glorply Blade" }
			}
		},
		["Elder Mossripper"] = {
			MinimumLevel = 350,
			Quests = {
				ElderMossripper1 = {
					Name = "Shadows in the Mire",
					Order = 1,
					Goal = {
						"CatchFish",
						300,
						nil,
						{ "Legendary", "Mythical" },
						{
							Mutation = "Shrouded"
						},
						{ "Elder Mossripper" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Elder Mossripper",
							"Mastery1",
							"Doubled Mossjaw Passive Catch Rate"
						}
					}
				},
				ElderMossripper2 = {
					Name = "Roots of Corruption",
					Order = 2,
					Goal = {
						"CatchFish",
						150,
						nil,
						nil,
						{
							Perfect = true,
							Mutation = "Mossy"
						},
						{ "Elder Mossripper" }
					},
					Reward = {
						Info = { "Boat", "Mossjaw" }
					}
				},
				ElderMossripper3 = {
					Name = "Voice of the Ancient Jaws",
					Order = 3,
					Goal = {
						"CatchFish",
						5,
						{ "Mossjaw", "Elder Mossjaw" },
						nil,
						{
							Perfect = true
						},
						{ "Elder Mossripper" }
					},
					Reward = {
						Info = { "Skin", "Elder Spirit" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Elder Mossripper" }
			}
		},
		["Sunken Rod"] = {
			MinimumLevel = 1,
			Quests = {
				SunkenRod1 = {
					Name = "The Drowned",
					Order = 1,
					Goal = {
						"CatchFish",
						20,
						nil,
						nil,
						{
							Mutation = "Sunken"
						},
						{ "Sunken Rod" }
					},
					Reward = {
						Info = { "Currency", "Coins", 2500 }
					}
				},
				SunkenRod2 = {
					Name = "Sunken Rolling",
					Order = 2,
					Goal = { "AppraiseFish", 50, nil },
					Reward = {
						Info = { "Title", "Sunken Sailor" }
					}
				},
				SunkenRod3 = {
					Name = "Sunken Perfection",
					Order = 3,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Perfect = true
						},
						{ "Sunken Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Sunken Rod",
							"Mastery1",
							"+35% Lure Speed, +5% Sunken Rate"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Sunken Rod" }
			}
		},
		["Fabulous Rod"] = {
			MinimumLevel = 1000,
			Quests = {
				FabulousRod1 = {
					Name = "Glamorous Haul",
					Order = 1,
					Goal = {
						"CatchFish",
						3,
						{ "Colossal Ethereal Dragon" },
						nil,
						{
							Mutation = "Fabulous"
						},
						{ "Fabulous Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Fabulous Rod",
							"Mastery1",
							"+15% Fish Size, increased slash frequency while catching Fabulous fish"
						}
					}
				},
				FabulousRod2 = {
					Name = "Style and Substance",
					Order = 2,
					Goal = {
						"CatchFish",
						10,
						nil,
						nil,
						{
							Shiny = true,
							Sparkling = true
						},
						{ "Fabulous Rod" }
					},
					Reward = {
						Info = {
							{ "Title", "Glistening" },
							{
								"RodEnhancement",
								"Fabulous Rod",
								"Mastery2",
								"+5% Shiny & Sparkling Chance"
							}
						}
					}
				},
				FabulousRod3 = {
					Name = "Divine Collection",
					Order = 3,
					Goal = {
						"CatchFish",
						100,
						{ "Celestial Koi", "Starlit Weaver", "Aurora Trout" },
						nil,
						{
							Perfect = true,
							Mutation = "Fabulous"
						},
						{ "Fabulous Rod" }
					},
					Reward = {
						Info = { "Bobber", "Fabulous Bobber" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Fabulous Rod" }
			}
		},
		["Astraeus Serenade"] = {
			MinimumLevel = 1000,
			Quests = {
				AstraeusSerenade1 = {
					Name = "Perfection of the Stars",
					Order = 1,
					Goal = {
						"CatchFish",
						2,
						{ "Spectral Serpent" },
						nil,
						{
							Perfect = true,
							Mutation = "Serene"
						},
						{ "Astraeus Serenade" }
					},
					Reward = {
						Info = { "Bobber", "Astraeus Bobber" }
					}
				},
				AstraeusSerenade2 = {
					Name = "Wind of the Gods",
					Order = 2,
					Goal = {
						"CatchFish",
						1,
						{ "Profane Leviathan" },
						nil,
						{
							Perfect = true,
							Mutation = "Breezed"
						},
						{ "Astraeus Serenade" }
					},
					Reward = {
						Info = { "Title", "🌌" }
					}
				},
				AstraeusSerenade3 = {
					Name = "Astra Divinity",
					Order = 3,
					Goal = {
						"CatchFish",
						25,
						nil,
						{ "Secret" },
						{
							Perfect = true,
							Mutation = "Astraeus"
						},
						{ "Astraeus Serenade" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Astraeus Serenade",
							"Mastery1",
							"Firefly Entity"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Riviere Astrale" }
			}
		},
		Dreambreaker = {
			MinimumLevel = 750,
			Quests = {
				Dreambreaker1 = {
					Name = "Disruptor of Dreams",
					Order = 1,
					Goal = {
						"CatchFish",
						3,
						{ "Leviathan" },
						nil,
						{
							Mutation = "Distraught"
						},
						{ "Dreambreaker" }
					},
					Reward = {
						Info = { "Bobber", "Nightmare" }
					}
				},
				Dreambreaker2 = {
					Name = "Master of the Deep",
					Order = 2,
					Goal = {
						"CatchFish",
						1,
						{ "Profane Leviathan" },
						nil,
						nil,
						{ "Dreambreaker" }
					},
					Reward = {
						Info = { "Title", "Distraught" }
					}
				},
				Dreambreaker3 = {
					Name = "Nightmare Hunter",
					Order = 3,
					Goal = {
						"CatchFish",
						50,
						nil,
						{ "Exotic" },
						{
							Perfect = true
						},
						{ "Dreambreaker" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Dreambreaker",
							"Mastery1",
							"+10% Progress Speed"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Dreamshredder" }
			}
		},
		["Pinion's Aria"] = {
			MinimumLevel = 800,
			Quests = {
				PinionsAria1 = {
					Name = "Harmony in Unison",
					Order = 1,
					Goal = {
						"CatchFish",
						100,
						{ "Harmonic Dove" },
						nil,
						{
							Mutation = "Harmonized"
						}
					},
					Reward = {
						Info = {
							{
								"ItemOrFish",
								"Wings of Harmony",
								{},
								1
							}
						}
					}
				},
				PinionsAria2 = {
					Name = "Perfected Resonance",
					Order = 2,
					Goal = {
						"CatchFish",
						142,
						nil,
						{ "Exotic", "Secret", "Apex" },
						{
							Perfect = true
						},
						{ "Pinion's Aria" }
					},
					Reward = {
						Info = {
							{
								"RodEnhancement",
								"Pinion's Aria",
								"Mastery1",
								"Less punishing and more powerful notes"
							}
						}
					}
				},
				PinionsAria3 = {
					Name = "Tuning the Soul",
					Order = 3,
					Goal = {
						"CatchFish",
						1,
						{ "Wyvern" },
						nil,
						{
							Perfect = true,
							Mutation = "Harmonized"
						},
						{ "Pinion's Aria" }
					},
					Reward = {
						Info = {
							{
								"RodEnhancement",
								"Pinion's Aria",
								"Mastery2",
								"Higher chances for Harmonized and Shiny"
							}
						}
					}
				},
				PinionsAria4 = {
					Name = "The Seventh Day",
					Order = 4,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							Mutation = "Harmonized",
							Shiny = true
						},
						{ "Pinion's Aria" }
					},
					Reward = {
						Info = {
							{ "Halo", "Harmonious Crown of Order" },
							{ "Title", "Dove" }
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Pinion's Aria" }
			}
		},
		["Masterline Rod"] = {
			MinimumLevel = 1000,
			Quests = {
				Masterline2 = {
					Name = "Ascendant Mastery",
					Order = 1,
					Goal = {
						"DataInstanceValue",
						"Cache.MasteriesCompleted2",
						1e999,
						"Complete one third of all other mastery quests!"
					},
					Reward = {
						Info = {
							{ "Halo", "Chromatic Crown" },
							{ "Title", "The Ascended" },
							{
								"RodEnhancement",
								"Masterline Rod",
								"Mastery1",
								"Activates 1 random passive every 5 minutes"
							}
						}
					}
				},
				Masterline3 = {
					Name = "Transcendent Mastery",
					Order = 2,
					Goal = {
						"DataInstanceValue",
						"Cache.MasteriesCompleted3",
						1e999,
						"Complete two thirds of all other mastery quests!"
					},
					Reward = {
						Info = {
							{ "Bobber", "Master Orb" },
							{
								"RodEnhancement",
								"Masterline Rod",
								"Mastery2",
								"Activates 2 random passives every 5 minutes"
							}
						}
					}
				},
				Masterline1 = {
					Name = "Absolute Mastery",
					Order = 3,
					Goal = {
						"DataInstanceValue",
						"Cache.MasteriesCompleted",
						1e999,
						"Complete every other rod mastery quest!"
					},
					Reward = {
						Info = {
							{ "Lantern", "Trophy Star" },
							{
								"RodEnhancement",
								"Masterline Rod",
								"Mastery3",
								"Activates 3 random passives every 5 minutes, with Lock ability"
							}
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Masterscepter" }
			}
		},
		["Nico's Yarncaster"] = {
			MinimumLevel = 500,
			Quests = {
				NicosYarncaster1 = {
					Name = "meow",
					Order = 1,
					Goal = {
						"CatchFish",
						30,
						{ "Opalescent Catfish" },
						nil,
						{
							Mutation = "Skrunkly"
						},
						{ "Nico's Yarncaster" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Nico's Yarncaster",
							"Mastery1",
							"Doubled Fish Rate"
						}
					}
				},
				NicosYarncaster2 = {
					Name = "mrrp",
					Order = 2,
					Goal = {
						"CatchFish",
						250,
						nil,
						nil,
						{
							Mutation = "Nico's Nyantics"
						},
						{ "Nico's Yarncaster" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Nico's Yarncaster",
							"Mastery2",
							"Mitosis"
						}
					}
				},
				NicosYarncaster3 = {
					Name = ":3",
					Order = 3,
					Goal = {
						"CatchFish",
						15,
						{ "Catfish" },
						nil,
						{
							Perfect = true
						},
						{ "Nico's Yarncaster" }
					},
					Reward = {
						Info = { "Boat", "Nico" }
					}
				}
			},
			CompleteReward = {
				Info = { "CompanionSkin", "Golden Nico" }
			}
		},
		["Poseidon Rod"] = {
			MinimumLevel = 500,
			Quests = {
				PoseidonRod1 = {
					Name = "Master of Tides",
					Order = 1,
					Goal = {
						"CatchFish",
						75,
						nil,
						nil,
						{
							Mutation = "King’s Blessing",
							Perfect = true
						},
						{ "Poseidon Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Poseidon Rod",
							"Mastery1",
							"+10% King's Blessing chance"
						}
					}
				},
				PoseidonRod2 = {
					Name = "Wrath of the Sea",
					Order = 2,
					Goal = {
						"CatchFish",
						30,
						nil,
						nil,
						{
							WeightClass = "Giant"
						},
						{ "Poseidon Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Poseidon Rod",
							"Mastery2",
							"Occasional slashes"
						}
					}
				},
				PoseidonRod3 = {
					Name = "Blessing of the Sea",
					Order = 3,
					Goal = {
						"CatchFish",
						1,
						{ "Ancient Kraken" },
						nil,
						{
							Mutation = "King’s Blessing"
						},
						{ "Poseidon Rod" }
					},
					Reward = {
						Info = { "Title", "Wave" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Poseidon Rod" }
			}
		},
		["Tempest Rod"] = {
			MinimumLevel = 100,
			Quests = {
				TempestRod1 = {
					Name = "Electrifying Tempest",
					Order = 1,
					Goal = {
						"CatchFish",
						150,
						nil,
						nil,
						{
							Mutation = "Electric"
						},
						{ "Tempest Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Tempest Rod",
							"Mastery1",
							"25% chance for Electric mutation (50% during Rain)"
						}
					}
				},
				TempestRod2 = {
					Name = "Steadfast Tempest",
					Order = 2,
					Goal = {
						"CatchFish",
						500,
						nil,
						nil,
						nil,
						{ "Tempest Rod" }
					},
					Reward = {
						Info = { "Title", "Tempest" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Tempest Rod" }
			}
		},
		["Depthseeker Rod"] = {
			MinimumLevel = 20,
			Quests = {
				DepthseekerRod1 = {
					Name = "The Deep Dark",
					Order = 1,
					Goal = {
						"CatchFish",
						150,
						nil,
						nil,
						{
							Locations = { "Atlantis" }
						},
						{ "Depthseeker Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Depthseeker Rod",
							"Mastery1",
							"100% for Darkened while underground"
						}
					}
				},
				DepthseekerRod2 = {
					Name = "Deepest Depths",
					Order = 2,
					Goal = {
						"CatchFish",
						300,
						nil,
						nil,
						{
							Mutation = "Darkened"
						},
						{ "Depthseeker Rod" }
					},
					Reward = {
						Info = { "Title", "Seeker of Depths" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Golden Depthseeker Rod" }
			}
		},
		MiguRod = {
			MinimumLevel = 1000,
			Quests = {
				MiguRod1 = {
					Name = "Final Battle",
					Order = 1,
					Goal = {
						"CatchFish",
						1,
						{ "Redlip Batfish" },
						nil,
						nil,
						{ "MiguRod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"MiguRod",
							"Mastery1",
							"???"
						}
					}
				},
				MiguRod2 = {
					Name = "Crimson Mesmerizer",
					Order = 2,
					Goal = {
						"CatchFish",
						1,
						nil,
						{ "Apex" },
						{
							Mutation = "Mesmerized"
						},
						{ "MiguRod" }
					},
					Reward = {
						Info = {
							{ "Title", "Mesmerizer" },
							{ "Title", "Mesmerized" }
						}
					}
				},
				MiguRod3 = {
					Name = "Equipment Crafting",
					Order = 3,
					Goal = {
						"CatchFish",
						2,
						{ "Boots" },
						nil,
						{
							Mutation = "Mesmerized",
							Shiny = true
						},
						{ "MiguRod" }
					},
					Reward = {
						Info = {
							"ItemOrFish",
							"Amphibian Boots",
							{},
							1
						}
					}
				},
				MiguRod4 = {
					Name = "Regular Boring Mastery",
					Order = 4,
					Goal = {
						"CatchFish",
						401,
						nil,
						nil,
						{
							Mutation = "Supersonic"
						},
						{ "MiguRod" }
					},
					Reward = {
						Info = {
							{ "Lantern", "Pear" },
							{ "Halo", "Baguette" }
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Mankind's Demise" }
			}
		},
		Lullaby = {
			MinimumLevel = 1000,
			Quests = {
				Lullaby1 = {
					Name = "Forever in Harmony",
					Order = 1,
					Goal = { "Custom", 180, "All for nothing at all..." },
					Reward = {
						Info = {
							{ "Halo", "Simon's Gift" },
							{ "Bobber", "Moon" }
						}
					}
				},
				Lullaby2 = {
					Name = "The Climb",
					Order = 2,
					Goal = { "Custom", 20, "Thinking of the way I used to spend the time..." },
					Reward = {
						Info = {
							"RodEnhancement",
							"Lullaby",
							"Mastery1",
							"Doubled buff durations"
						}
					}
				},
				Lullaby3 = {
					Name = "The Collection",
					Order = 3,
					Goal = {
						"Custom",
						6,
						"Past is passed and rather than regret the old, I can live it back the other way..."
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Lullaby",
							"Mastery2",
							"Increased progress speed on metronome hits"
						}
					}
				},
				Lullaby4 = {
					Name = "True Ascension",
					Order = 4,
					Goal = { "Custom", 1, "Use all that you've gained to rise Above The Clouds." },
					Reward = {
						Info = { "RodMode", "Lullaby", "Serenity" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Serenity" }
			}
		},
		["Random Rod"] = {
			MinimumLevel = 1,
			Quests = {
				RandomRod1 = {
					Name = "Please Stat Pity",
					Order = 1,
					Goal = {
						"CatchFish",
						100,
						nil,
						nil,
						{
							WeightClass = "Small"
						},
						{ "Random Rod" }
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Random Rod",
							"Mastery1",
							"Better stat rolls"
						}
					}
				},
				RandomRod2 = {
					Name = "Random Fishing",
					Order = 2,
					Goal = {
						"CatchFishAny",
						25,
						nil,
						nil,
						{
							Glitched = true
						}
					},
					Reward = {
						Info = { "Bobber", "Random Bobber" }
					}
				},
				RandomRod3 = {
					Name = "Random Light",
					Order = 3,
					Goal = { "Custom", 100, "Catch 100 fish while underground" },
					Reward = {
						Info = { "Lantern", "Random Lantern" }
					}
				},
				RandomRod4 = {
					Name = "Random Fit",
					Order = 4,
					Goal = {
						"CatchFishAny",
						25,
						nil,
						nil,
						{
							ShinyOrSparkling = true
						}
					},
					Reward = {
						Info = { "RandomSkin" }
					}
				},
				RandomRod5 = {
					Name = "Random Traveling",
					Order = 5,
					Goal = { "Custom", 100, "Catch 100 fish while sitting in a boat" },
					Reward = {
						Info = { "Boat", "Random Boat" }
					}
				}
			},
			CompleteReward = {
				Info = {
					"RodEnhancement",
					"Random Rod",
					"Mastery2",
					"Mystery Box passive"
				}
			}
		},
		["Olympian Godbreaker"] = {
			MinimumLevel = 1000,
			Quests = {
				OlympianGodbreaker1 = {
					Name = "War Against Bellona",
					Order = 1,
					Goal = lib.CatchFish({
						RequiredAmount = 197,
						PerfectCatch = true,
						EventFlags = { "WarSurge" },
						Rods = { "Olympian Godbreaker" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Olympian Godbreaker",
							"Mastery1",
							"+2% Olympian Mutation chance, +3% Progress from Gravity Pull"
						}
					}
				},
				OlympianGodbreaker2 = {
					Name = "Apollo's Appeal",
					Order = 2,
					Goal = lib.CatchFish({
						RequiredAmount = 196,
						EventFlags = { "ApolloLightBeam" },
						Rods = { "Olympian Godbreaker" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Olympian Godbreaker",
							"Mastery2",
							"+2% Olympian Mutation chance, -0.15 → -0.0981 Control during Starcaller Cry"
						}
					}
				},
				OlympianGodbreaker3 = {
					Name = "Poseidon's Pantheon",
					Order = 3,
					Goal = lib.CatchFish({
						RequiredAmount = 196,
						EventFlags = { "StormFlood", "PoseidonWhirlpool" },
						Rods = { "Olympian Godbreaker" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Olympian Godbreaker",
							"Mastery3",
							"+2% Olympian Mutation chance, +2 catch duration on Disturbance buff from Starcaller Cry"
						}
					}
				},
				OlympianGodbreaker4 = {
					Name = "Zeus! Your Child has returned!",
					Order = 4,
					Goal = lib.CatchFish({
						RequiredAmount = 196,
						EventFlags = { "ChargedZeusPool" },
						Rods = { "Olympian Godbreaker" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Olympian Godbreaker",
							"Mastery4",
							"+2% Olympian Mutation chance, +1 fish from Starcaller Cry"
						}
					}
				},
				OlympianGodbreaker5 = {
					Name = "Hades' Hatred",
					Order = 5,
					Goal = lib.CatchFish({
						RequiredAmount = 196,
						EventFlags = { "SoulPool", "WispHauntZone", "SoulScourge" },
						Rods = { "Olympian Godbreaker" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Olympian Godbreaker",
							"Mastery5",
							"+2% Olympian Mutation chance, -75% → -60% Fixed Progress Speed while catching Progress-Locked fish"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Olympian Ascension" }
			}
		},
		Remembrance = {
			MinimumLevel = 1000,
			Quests = {
				Remembrance1 = {
					Name = "A Sorrow In You",
					Order = 1,
					Goal = lib.CatchFish({
						Fish = "Butterfly",
						RequiredAmount = 300,
						RequiredAttributes = {
							Mutation = "Departed"
						},
						Rods = { "Remembrance" }
					}),
					Reward = {
						Info = {
							{
								"RodEnhancement",
								"Remembrance",
								"Mastery1",
								"Increased chance for Departed + Butterfly can duplicate fish (Departed Mode Only)"
							}
						}
					}
				},
				Remembrance2 = {
					Name = "My Breath Of Life",
					Order = 2,
					Goal = lib.CatchFish({
						Fish = "Butterfly",
						RequiredAmount = 300,
						RequiredAttributes = {
							Mutation = "Fluttering"
						},
						Rods = { "Remembrance" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Remembrance",
							"Mastery2",
							"Increased chance for Fluttering + Butterfly Swarm can catch nearby fish (Living Mode Only)"
						}
					}
				},
				Remembrance3 = {
					Name = "Mephistopheles",
					Order = 3,
					Goal = lib.CatchFish({
						Fish = { "Orca", "Ancient Orca" },
						RequiredAmount = 13,
						RequiredAttributes = {
							Mutation = "Departed"
						},
						Rods = { "Remembrance" }
					}),
					Reward = {
						Info = { "Title", "The Mourned" }
					}
				},
				Remembrance4 = {
					Name = "Star Of The City",
					Order = 4,
					Goal = lib.CatchFish({
						Fish = "🦋",
						RequiredAmount = 1,
						Rods = { "Remembrance" }
					}),
					Reward = {
						Info = {
							"ItemOrFish",
							"Wings of Lament",
							{},
							1
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "The Butterfly's Wake" }
			}
		},
		["Wind Elemental"] = {
			MinimumLevel = 800,
			Quests = {
				WindElemental1 = {
					Name = "Second Nature",
					Order = 1,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						{
							Mutation = "Breezed"
						},
						{ "Wind Elemental" }
					},
					Reward = {
						Info = { "RodMode", "Wind Elemental", "Earth" }
					}
				},
				WindElemental2 = {
					Name = "Solid Ground",
					Order = 2,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						{
							Mutation = "Terra"
						},
						{ "Wind Elemental" }
					},
					Reward = {
						Info = { "RodMode", "Wind Elemental", "Fire" }
					}
				},
				WindElemental3 = {
					Name = "Trial by Fire",
					Order = 3,
					Goal = {
						"CatchFish",
						50,
						nil,
						nil,
						{
							Mutation = "Ignited"
						},
						{ "Wind Elemental" }
					},
					Reward = {
						Info = { "RodMode", "Wind Elemental", "Water" }
					}
				},
				WindElemental4 = {
					Name = "Avatar of the Elements",
					Order = 4,
					Goal = {
						"Custom",
						4,
						(`Sacrifice a {GradientRichText("Breezed", mutations2.Breezed.Color)} Wyvern, a {GradientRichText("Terra", mutations2.Terra.Color)} Flower Guardian, an {GradientRichText("Ignited", mutations2.Ignited.Color)} Magma Leviathan and a {GradientRichText("Stormy", mutations2.Stormy.Color)} Blue Whale to the four crystals at the summit of the Northern Expedition`)
					},
					Reward = {
						Info = { "Title", "Avatar" }
					}
				}
			},
			CompleteReward = {
				Info = { "RodMode", "Wind Elemental", "Omni" }
			}
		},
		["Lemonade Serenade"] = {
			MinimumLevel = 333,
			Quests = {
				LemonadeSerenade1 = {
					Name = "Lime Fusion",
					Order = 1,
					Goal = lib.CatchFish({
						RequiredAmount = 333,
						RequiredAttributes = {
							Mutation = "Lemon"
						},
						Rods = "Lemonade Serenade"
					}),
					Reward = {
						Info = { "Skin", "Limeade Serenade" }
					}
				},
				LemonadeSerenade2 = {
					Name = "Got any lime?",
					Order = 2,
					Goal = lib.CatchFish({
						Fish = "Leafscale Lemon Shark",
						RequiredAmount = 133,
						RequiredAttributes = {
							Mutation = "Lime"
						},
						Rods = "Lemonade Serenade"
					}),
					Reward = {
						Info = { "Skin", "Berrynade Serenade" }
					}
				},
				LemonadeSerenade3 = {
					Name = "Fruity Collection",
					Order = 3,
					Goal = lib.CatchFish({
						RequiredAmount = 333,
						RequiredAttributes = {
							Mutation = "Strawberry"
						},
						Rods = "Lemonade Serenade"
					}),
					Reward = {
						Info = {
							{ "Bobber", "Lemon" },
							{ "Bobber", "Lime" },
							{ "Bobber", "Berry" },
							{ "Bobber", "Banana" }
						}
					}
				},
				LemonadeSerenade4 = {
					Name = "Sour Day",
					Order = 4,
					Goal = { "Custom", 333, "Catch 333 droplets during the Lemonade Serenade minigame" },
					Reward = {
						Info = {
							"RodEnhancement",
							"Lemonade Serenade",
							"Mastery1",
							"50% faster squeeze, 2× more drops, and +3% chance for Sour mutation per droplet caught"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Bananade Serenade" }
			}
		},
		Plaguereaver = {
			MinimumLevel = 850,
			Quests = {
				Plaguereaver1 = {
					Name = "Master of the Garden",
					Order = 1,
					Goal = lib.CatchFish({
						RequiredAmount = 1,
						Fish = "Toxic Guardian",
						Rods = "Plaguereaver",
						PerfectCatch = true
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Plaguereaver",
							"Mastery1",
							"+25% Lure Speed, +2 Disturbance, +50 Durability"
						}
					}
				},
				Plaguereaver2 = {
					Name = "The Plague",
					Order = 2,
					Goal = lib.CatchFish({
						RequiredAmount = 400,
						RequiredAttributes = {
							Mutation = "Plagued"
						},
						Rods = "Plaguereaver"
					}),
					Reward = {
						Info = { "Title", "Plague Doctor" }
					}
				},
				Plaguereaver3 = {
					Name = "A Great Disturbance",
					Order = 3,
					Goal = { "Custom", 25000, "Contribute 25,000 Disturbance with Plaguereaver" },
					Reward = {
						Info = { "ItemOrFish", "Wings of Wrath" }
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Plaguecleaver" }
			}
		},
		Noiseform = {
			Quests = {
				Noiseform1 = {
					Name = "A Noisy Throwback",
					Order = 1,
					Goal = { "Custom", 5, [[
A ballad echoes of tales long gone,
follow its rhythm and relive your <font color='rgb(0,255,0)'>legacy</font>.]] },
					Reward = {
						Info = {
							{ "Lantern", "Obelisk" },
							{
								"RodEnhancement",
								"Noiseform",
								"Mastery2",
								"+10% Soultorn chance"
							}
						}
					}
				},
				Noiseform2 = {
					Name = "Dance of the Green Titan",
					Order = 2,
					Goal = { "Custom", 1, [[
A beast lurks beneath the sea,
<font color='rgb(0,255,0)'>follow</font> its rhythm and witness its spark.]] },
					Reward = {
						Info = {
							{ "Title", "Caprine" },
							{
								"RodEnhancement",
								"Noiseform",
								"Mastery3",
								"+2% Shiny & Sparkling chance"
							}
						}
					}
				},
				Noiseform3 = {
					Name = "Soul of the Devil",
					Order = 3,
					Goal = { "Custom", 1, [[
Tear down the evil that lies beneath,
and <font color='rgb(255,0,0)'>fetch</font> me the remains.]] },
					Reward = {
						Info = { "ItemOrFish", "Soulwalker" }
					}
				},
				Noiseform4 = {
					Name = "Flow of Life",
					Order = 4,
					Goal = {
						"Custom",
						1,
						"Life <font color='rgb(0,255,0)'>glimmers</font> where the waters flow deep."
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Noiseform",
							"Mastery1",
							[[

Falling Arrow Time 1-10 → 1-5
Flowed Chance 25% → 35%
Incorrect Zone Penalty -28% → -20%]]
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Ravereign" }
			}
		},
		["Celestial Rod"] = {
			MinimumLevel = 800,
			Quests = {
				CelestialRod1 = {
					Name = "A Full Rotation",
					Order = 1,
					Goal = lib.CatchFishAny({
						RequiredAmount = 365,
						RequiredAttributes = {
							Mutation = "Celestial"
						}
					}),
					Reward = {
						Info = { "Lantern", "Twinkle Stars" }
					}
				},
				CelestialRod2 = {
					Name = "Stars Collide",
					Order = 2,
					Goal = { "Custom", 42, "Obtain or refresh the Celestial buff 42 times" },
					Reward = {
						Info = {
							"RodEnhancement",
							"Celestial Rod",
							"Mastery1",
							"Doubled Celestial buff duration"
						}
					}
				},
				CelestialRod3 = {
					Name = "Celestial Infusion",
					Order = 3,
					Goal = lib.CatchFishAny({
						Fish = "Moon Wood",
						RequiredAmount = 2,
						RequiredAttributes = {
							Mutation = "Celestial",
							Shiny = true
						}
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Celestial Rod",
							"Mastery2",
							"+10% Starting Progress on base rod and Celestial buff"
						}
					}
				}
			},
			CompleteReward = {
				Info = {
					"RodEnhancement",
					"Celestial Rod",
					"Mastery3",
					"Falling Stars passive"
				}
			}
		},
		Requiem = {
			MinimumLevel = 1000,
			Quests = {
				Requiem1 = {
					Name = "Requiem of the Hunt",
					Order = 1,
					Goal = { "Custom", 5, "Perfect Catch all Tidefall hunt fish with Husk mutation" },
					Reward = {
						Info = {
							"RodEnhancement",
							"Requiem",
							"Mastery1",
							"+5% Husk chance"
						}
					}
				},
				Requiem2 = {
					Name = "Requies of the Hunt",
					Order = 2,
					Goal = lib.CatchFish({
						RequiredAmount = 1,
						Fish = {
							"Colossus Reef Titan",
							"Awakened Omnithal",
							"Ancestral Pliosaur",
							"Ancient Goldwraith"
						},
						RequiredAttributes = {
							Mutation = "Requies"
						},
						Rods = "Requiem"
					}),
					Reward = {
						Info = { "Title", "The Requiem" }
					}
				},
				Requiem3 = {
					Name = "Requiem of the Husk",
					Order = 3,
					Goal = lib.CatchFish({
						RequiredAmount = 250,
						RequiredAttributes = {
							Mutation = "Husk"
						},
						Rods = "Requiem"
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Requiem",
							"Mastery2",
							"+0.5% click progress on Progress Locked Fish"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Ethereal Requiem" }
			}
		},
		["Stellarwave Melody"] = {
			MinimumLevel = 888,
			Quests = {
				StellarwaveMelody1 = {
					Name = "Tuning the Tides",
					Order = 1,
					Goal = {
						"Custom",
						88,
						"Click the correct star sign 4 times in a row in a single minigame 88 times"
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Stellarwave Melody",
							"Mastery1",
							"+100 Durability, +1 Disturbance, +9 Hunt Focus (Goliath Siphonophore), +0.5s zodiac wheel lifetime"
						}
					}
				},
				StellarwaveMelody2 = {
					Name = "What is that Melody?",
					Order = 2,
					Goal = lib.CatchFish({
						RequiredAmount = 365,
						RequiredAttributes = {
							Mutation = "Melody"
						},
						Rods = { "Stellarwave Melody" }
					}),
					Reward = {
						Info = {
							"ItemOrFish",
							"Zodiac Glider",
							nil,
							1
						}
					}
				},
				StellarwaveMelody3 = {
					Name = "Stellar Synth",
					Order = 3,
					Goal = lib.CatchFish({
						RequiredAmount = 88,
						Raritites = { "Mythical", "Exotic", "Secret" },
						RequiredAttributes = {
							Mutation = "Synth"
						},
						Rods = { "Stellarwave Melody" }
					}),
					Reward = {
						Info = { "Bobber", "Piano" }
					}
				},
				StellarwaveMelody4 = {
					Name = "The Sequel",
					Order = 4,
					Goal = lib.CatchFish({
						RequiredAmount = 24,
						Fish = { "Spectral Serpent" },
						RequiredAttributes = {
							Mutation = { "Melody", "Synth" }
						},
						DirectCatch = true,
						Rods = { "Stellarwave Melody" }
					}),
					Reward = {
						Info = { "Title", "Spectre" }
					}
				},
				StellarwaveMelody5 = {
					Name = "Cosmic Crescendo",
					Order = 5,
					Goal = lib.CatchFish({
						RequiredAmount = 12,
						Fish = { "Goliath Siphonophore" },
						RequiredAttributes = {
							Mutation = { "Melody", "Synth" },
							Sparkling = true
						},
						Rods = { "Stellarwave Melody" }
					}),
					Reward = {
						Info = {
							"RodEnhancement",
							"Stellarwave Melody",
							"Mastery2",
							(`+5% → +8% <i>{GradientRichText("Sparkling", byName.Sparkling.Color)}</i> chance (+8% → +12% total during Aurora/Starfall), +5% <b>{GradientRichText("Aurora", mutations2.Aurora.Color)}</b> chance, +3.6% <b>{GradientRichText("Melody", mutations2.Melody.Color)}</b> chance, +3.6% <b>{GradientRichText("Synth", mutations2.Synth.Color)}</b> chance`)
						}
					}
				},
				StellarwaveMelody6 = {
					Name = "Aurora Inception",
					Order = 6,
					Goal = lib.CatchFish({
						RequiredAmount = 108,
						Fish = { "Aurora Gar", "Aurora Trout" },
						Rods = { "Stellarwave Melody" },
						DirectCatch = true
					}),
					Reward = {
						Info = {
							{ "Lantern", "Stellar Compass" },
							{ "Bait", "Aurora Bait", 108 }
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Nullwave" }
			}
		},
		["Rod of the Singularity"] = {
			MinimumLevel = 750,
			Quests = {
				RodoftheSingularity1 = {
					Name = "Infinitely Dense",
					Order = 1,
					Goal = {
						"Custom",
						30,
						"Catch 30 fish with a weight exceeding 186,000 kg using Rod of the Singularity"
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod of the Singularity",
							"Mastery1",
							"+40% Weight Boost"
						}
					}
				},
				RodoftheSingularity2 = {
					Name = "Gifts from the Event Horizon",
					Order = 2,
					Goal = { "Custom", 3, "Trigger a triplication from Rod of the Singularity's passive 3 times" },
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod of the Singularity",
							"Mastery2",
							"+1% → +2% Forced Progress Speed per second"
						}
					}
				},
				RodoftheSingularity3 = {
					Name = "Stellar Abyss",
					Order = 3,
					Goal = lib.CatchFish({
						RequiredAmount = 287,
						RequiredAttributes = {
							WeightClass = "Big"
						},
						Rods = { "Rod of the Singularity" }
					}),
					Reward = {
						Info = { "Bobber", "Event Horizon" }
					}
				},
				RodoftheSingularity4 = {
					Name = "Gravitational Collapse",
					Order = 4,
					Goal = {
						"Custom",
						2870,
						"Gain a total of 2,870% Forced Progress Speed via the Rod of the Singularity's passive"
					},
					Reward = {
						Info = {
							"RodEnhancement",
							"Rod of the Singularity",
							"Mastery3",
							"+200 Durability, +4 Disturbance"
						}
					}
				}
			},
			CompleteReward = {
				Info = { "Skin", "Platinum Reverie" }
			}
		}
	}
}
local module = require("../rods")
local count = 0

for k, v in Mastery.Mastery do
	if module[k].Unregistered then
		continue
	end

	for _ in v.Quests do
		count += 1
	end
end

Mastery.Mastery["Masterline Rod"].Quests.Masterline1.Goal[3] = count
Mastery.Mastery["Masterline Rod"].Quests.Masterline2.Goal[3] = math.floor(count * 0.3333333333333333)
Mastery.Mastery["Masterline Rod"].Quests.Masterline3.Goal[3] = math.floor(count * 0.6666666666666666)
return Mastery