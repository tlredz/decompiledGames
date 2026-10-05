require("../../SimpleFetchQuests/lib")
local dateTime = DateTime.fromUnixTimestamp(1785168000)
local LullabyQuests = {
	Lullaby1 = {
		DisplayName = "Introduction to Snow",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 1,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ1_1",
				1,
				"Lovers, one forgotten and other no more."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ1_2",
				true,
				"For now, both may be remembered under the stars..."
			}
		},
		Rewards = {
			{ "Title", "Musical Fish" }
		}
	},
	Lullaby2 = {
		DisplayName = "Forest",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 2,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		Prerequisites = {
			QuestComplete = { "Lullaby1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ2_1",
				2,
				"Owls on the night watch..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ2_2",
				2,
				"Shadows of nobody there..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ2_3",
				2,
				"Deeper in they crept, oblivious of the bears and darker terrors..."
			}
		},
		Rewards = {}
	},
	Lullaby3 = {
		DisplayName = "Heaven",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 3,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		Prerequisites = {
			QuestComplete = { "Lullaby2" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ3_1",
				7,
				"天の御国"
			}
		},
		Rewards = {}
	},
	Lullaby4_1 = {
		DisplayName = "Trapped",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 4,
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby3" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ4_1",
				true,
				"Surrounded by ghosts in a cloud of smoke..."
			}
		},
		Rewards = {
			{ "DisplayOnly", "You feel... somewhat connected?" },
			{ "Lantern", "Stella Octangula" }
		}
	},
	Lullaby4_2 = {
		DisplayName = "Trapped",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 5,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to the Lost Soul.",
		Prerequisites = {
			QuestComplete = { "Lullaby4_1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ4_2",
				12,
				"See how I circle..."
			}
		},
		Rewards = {}
	},
	Lullaby5_1 = {
		DisplayName = "Time Machine",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 6,
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby4_2" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ5_1",
				true,
				"You'll have time enough to spend some time alone..."
			}
		},
		Rewards = {}
	},
	Lullaby5_2 = {
		DisplayName = "Time Machine",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 7,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		Prerequisites = {
			QuestComplete = { "Lullaby5_1" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "ItemOrFish", "Time Machine" }
		}
	},
	Lullaby6_1 = {
		DisplayName = "Stranded Amongst a Sea of Stars",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 8,
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby5_2" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ6_1",
				1,
				"I'd like to know why you are all alone while I..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ6_2",
				true,
				"A million moments meant remembered rest in deep dark sound..."
			}
		},
		Rewards = {}
	},
	Lullaby6_2 = {
		DisplayName = "Stranded Amongst a Sea of Stars",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 9,
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby6_1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ6_3",
				1,
				"Awake would only prove the fantasy made lucid sense..."
			}
		},
		Rewards = {}
	},
	Lullaby7_1 = {
		DisplayName = "Le Grande Finale",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 10,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		Prerequisites = {
			QuestComplete = { "Lullaby6_2" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ7_1",
				1,
				"Signed, yours truly..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ7_2",
				1,
				"The part is wholly ending..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQ7_3",
				1,
				"To know we are beyond a bow..."
			}
		},
		Rewards = {}
	},
	Lullaby7_2 = {
		DisplayName = "Le Grande Finale",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 11,
		ExpiresAt = dateTime,
		CompletedDescription = "Return to Simon.",
		Prerequisites = {
			QuestComplete = { "Lullaby7_1" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQ7_4",
				1,
				"Now that existence is on the wake..."
			}
		},
		Rewards = {
			{ "Rod", "Lullaby", "Restricted" }
		}
	},
	Lullaby8 = {
		DisplayName = "Encore",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		QuestSeries = "Lullaby",
		SeriesIndex = 12,
		ExpiresAt = dateTime,
		Description = "Bye, Hi. Sigh, Hawaii..",
		Prerequisites = {
			QuestComplete = { "Lullaby7_2" }
		},
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				"Cache.QuestProgress",
				true,
				"???"
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Lullaby</b> Restriction lifted" }
		}
	},
	Lullaby_Quickening = {
		DisplayName = "A Quickening Symphony",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby8" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyQuickening_1",
				1,
				"Lightning strikes mine temples..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyQuickening_2",
				1,
				"...dekcohs steg gniklrE eht dnA"
			}
		},
		Rewards = {
			{ "RodMode", "Lullaby", "Quickening" }
		}
	},
	Lullaby_Strengthening = {
		DisplayName = "A Strengthening Melody",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		CompletedDescription = "A victim of magic...",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby8" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyStrengthening_1",
				1,
				"One day, after dinner..."
			},
			{
				"DataInstanceValue",
				"Cache.LullabyStrengthening_2",
				12,
				"Why would it hurt me? Or was it real?"
			}
		},
		Rewards = {
			{ "RodMode", "Lullaby", "Strengthening" }
		}
	},
	Lullaby_Fortuitous = {
		DisplayName = "A Fortuitous Harmony",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby8" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyFortuitous",
				1,
				"Connect the Rainbow"
			}
		},
		Rewards = {
			{ "RodMode", "Lullaby", "Fortuitous" }
		}
	},
	Lullaby_Prismatic = {
		DisplayName = "A Prismatic Sinfonia",
		Icon = "rbxassetid://70822794044383",
		IconColor = Color3.fromRGB(255, 34, 133),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Prerequisites = {
			QuestComplete = { "Lullaby_Quickening", "Lullaby_Strengthening", "Lullaby_Fortuitous" }
		},
		List = {
			{
				"DataInstanceValue",
				"Cache.LullabyPrismatic",
				true,
				"Such impossible bliss..."
			}
		},
		Rewards = {
			{ "RodMode", "Lullaby", "Prismatic" }
		}
	}
}

for _, v in LullabyQuests do
	v.WishLocked = "Lullaby"
end

return LullabyQuests