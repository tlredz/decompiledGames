local v = {
	"Colossal Ancient Dragon",
	"Colossal Blue Dragon",
	"Colossal Ethereal Dragon",
	"Frostwyrm",
	"Leviathan",
	"Profane Leviathan"
}
local dateTime = DateTime.fromUniversalTime(2026, 8, 15, 16)
return {
	ChapelRequiem1 = {
		DisplayName = "Mortal Shells",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 255, 140),
		QuestType = "Major",
		QuestSeries = "ChapelRequiem",
		SeriesIndex = 1,
		AcceptIndicatorTag = "ChapelNyx",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelNyx" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Catch every Tidefall hunt fish with the Husk mutation.",
		CompletedDescription = "Return to Nyx at the Chapel.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Plesiosaur" },
				nil,
				{
					Mutation = "Husk"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Reef Titan" },
				nil,
				{
					Mutation = "Husk"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Omnithal" },
				nil,
				{
					Mutation = "Husk"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Pliosaur" },
				nil,
				{
					Mutation = "Husk"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Goldwraith" },
				nil,
				{
					Mutation = "Husk"
				}
			}
		},
		Rewards = {}
	},
	ChapelRequiem2 = {
		DisplayName = "Husking Lament",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 255, 140),
		QuestType = "Major",
		QuestSeries = "ChapelRequiem",
		SeriesIndex = 2,
		AcceptIndicatorTag = "ChapelNyx",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelNyx" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Prove your mastery over the Requiem's song.",
		CompletedDescription = "Return to Nyx at the Chapel.",
		Prerequisites = {
			QuestComplete = { "ChapelRequiem1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Omnithal", "Awakened Omnithal" },
				nil,
				{
					Sparkling = true,
					Mutation = "Husk",
					Perfect = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Omnithal", "Awakened Omnithal" },
				nil,
				{
					Mutation = "Requies",
					Return = true
				}
			}
		},
		Rewards = {
			{ "Skin", "Cathedra Requiei" }
		}
	},
	ChapelFabulous1 = {
		DisplayName = "Fabulous Curiosity",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 105, 180),
		QuestType = "Major",
		QuestSeries = "ChapelFabulous",
		SeriesIndex = 1,
		AcceptIndicatorTag = "ChapelAlexandria",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelAlexandria" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Catch the Exotics of Mariana's Veil, Sparkling and Fabulous.",
		CompletedDescription = "Return to Alexandria at the Chapel.",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Magma Leviathan" },
				nil,
				{
					Sparkling = true,
					Mutation = "Fabulous"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Frozen Leviathan" },
				nil,
				{
					Sparkling = true,
					Mutation = "Fabulous"
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Crowned Anglerfish" },
				nil,
				{
					Sparkling = true,
					Mutation = "Fabulous"
				}
			}
		},
		Rewards = {}
	},
	ChapelFabulous2 = {
		DisplayName = "Crystal Anomaly",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 105, 180),
		QuestType = "Major",
		QuestSeries = "ChapelFabulous",
		SeriesIndex = 2,
		AcceptIndicatorTag = "ChapelAlexandria",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelAlexandria" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "One anomaly remains beneath the Calm.",
		CompletedDescription = "Return to Alexandria at the Chapel.",
		Prerequisites = {
			QuestComplete = { "ChapelFabulous1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Crystallized Seadragon" },
				nil,
				{
					Shiny = true,
					Sparkling = true,
					Mutation = "Fabulous",
					Perfect = true
				}
			}
		},
		Rewards = {
			{ "Skin", "Capella Vitrea" }
		}
	},
	ChapelRuinous1 = {
		DisplayName = "Serpentine Ruby",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(170, 0, 0),
		QuestType = "Major",
		QuestSeries = "ChapelRuinous",
		SeriesIndex = 1,
		AcceptIndicatorTag = "ChapelScourge",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelScourge" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Slay a Dragon with a blade that came before the Oath.",
		CompletedDescription = "Return to Scourge at the Chapel.",
		List = {
			{
				"CatchFish",
				1,
				v,
				nil,
				nil,
				{ "Ruinous Oath", "Evil Pitchfork", "Scarlet Spincaster Rod" }
			}
		},
		Rewards = {}
	},
	ChapelRuinous2 = {
		DisplayName = "Draconic Mastery",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(170, 0, 0),
		QuestType = "Major",
		QuestSeries = "ChapelRuinous",
		SeriesIndex = 2,
		AcceptIndicatorTag = "ChapelScourge",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelScourge" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Master the Dragons themselves.",
		CompletedDescription = "Return to Scourge at the Chapel.",
		Prerequisites = {
			QuestComplete = { "ChapelRuinous1" }
		},
		List = {
			{
				"CatchFishAny",
				3,
				v,
				nil,
				{
					Sparkling = true,
					Mutation = "Mastered",
					Perfect = true
				}
			}
		},
		Rewards = {
			{ "Skin", "Ruptor Derelictus" }
		}
	},
	ChapelPoseidon1 = {
		DisplayName = "The Cyclone",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 170, 255),
		QuestType = "Major",
		QuestSeries = "ChapelPoseidon",
		SeriesIndex = 1,
		AcceptIndicatorTag = "ChapelTempest",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelTempest" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Unravel Tempest's riddle.",
		CompletedDescription = "Return to Tempest at the Chapel.",
		IsSecret = true,
		List = {
			{ "Custom", 1, "???" }
		},
		Rewards = {}
	},
	ChapelPoseidon2 = {
		DisplayName = "Tidal Ruler",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 170, 255),
		QuestType = "Major",
		QuestSeries = "ChapelPoseidon",
		SeriesIndex = 2,
		AcceptIndicatorTag = "ChapelTempest",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelTempest" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Claim a catch worthy of the ruler of the seas.",
		CompletedDescription = "Return to Tempest at the Chapel.",
		Prerequisites = {
			QuestComplete = { "ChapelPoseidon1" }
		},
		List = {
			{
				"CatchFish",
				1,
				{ "Tidecrasher Archon" },
				nil,
				nil,
				{ "Poseidon Rod" }
			}
		},
		Rewards = {
			{ "Skin", "Caeruleus Reliquiarium" }
		}
	},
	ChapelMasterline1 = {
		DisplayName = "The Pinnacle",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 215, 0),
		QuestType = "Major",
		QuestSeries = "ChapelMasterline",
		SeriesIndex = 1,
		AcceptIndicatorTag = "ChapelPolyhistor",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelPolyhistor" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Travel to a time where everything began, and finish the mission.",
		CompletedDescription = "Return to Polyhistor at the Chapel.",
		Prerequisites = {
			QuestComplete = {
				"ChapelRequiem2",
				"ChapelFabulous2",
				"ChapelRuinous2",
				"ChapelPoseidon2"
			}
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Moosewood",
				true,
				"Complete the Shiny and Sparkling Bestiary of Moosewood Island"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Snowcap",
				true,
				"Complete the Shiny and Sparkling Bestiary of Snowcap Island"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Terrapin",
				true,
				"Complete the Shiny and Sparkling Bestiary of Terrapin Island"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Sunstone",
				true,
				"Complete the Shiny and Sparkling Bestiary of Sunstone Island"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Roslit",
				true,
				"Complete the Shiny and Sparkling Bestiary of Roslit Bay"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_RoslitVolcano",
				true,
				"Complete the Shiny and Sparkling Bestiary of Roslit Volcano"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Mushgrove",
				true,
				"Complete the Shiny and Sparkling Bestiary of Mushgrove Swamp"
			},
			{
				"DataInstanceValue",
				"Cache.ChapelBestiary_Vertigo",
				true,
				"Complete the Shiny and Sparkling Bestiary of Vertigo"
			}
		},
		Rewards = {}
	},
	ChapelMasterline2 = {
		DisplayName = "A Memory",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 215, 0),
		QuestType = "Major",
		QuestSeries = "ChapelMasterline",
		SeriesIndex = 2,
		AcceptIndicatorTag = "ChapelPolyhistor",
		NavigationTargets = {
			{
				Zone = "The Chapel",
				Tags = { "ChapelPolyhistor" },
				AllComplete = true
			}
		},
		ExpiresAt = dateTime,
		Description = "Relive the memory with the Destiny Rod in hand.",
		CompletedDescription = "Return to Polyhistor at the Chapel.",
		Prerequisites = {
			QuestComplete = { "ChapelMasterline1" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ "Treble Bass" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Manatee" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Molten Banshee" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Rubber Ducky" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Baby Pond Emperor" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Voltfish" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Handfish" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			},
			{
				"CatchFishAny",
				1,
				{ "Manta Ray" },
				nil,
				{
					Shiny = true,
					Sparkling = true
				}
			}
		},
		Rewards = {
			{ "Skin", "Sanctuarium Lucis Seraphim" }
		}
	}
}