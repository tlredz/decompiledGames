local module = require("../../SimpleFetchQuests/lib")
local color = Color3.fromRGB(255, 248, 200)
local dateTime = DateTime.fromUnixTimestamp(1784563200)
local WingkeeperQuest = {
	Wingkeeper1 = {
		DisplayName = "Seraphel: A Heavenly Sign",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Major",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "Seraphel",
		NavigationTargets = {
			{
				Tags = { "Seraphel" },
				AllComplete = true
			}
		},
		Description = "Seraphel is searching for an omen. Catch and bring her a Heavenly Handfish.",
		CompletedDescription = "Return to Seraphel with the Heavenly Handfish.",
		List = { module.CatchFishAny({
				Fish = "Handfish",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Heavenly"
				},
				AndReturn = true
			}) },
		Rewards = {
			{ "Currency", "Coins", 2500 }
		}
	},
	Wingkeeper2 = {
		DisplayName = "Seraphel: A Celestial Tune",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Major",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "Seraphel",
		NavigationTargets = {
			{
				Tags = { "Seraphel" },
				AllComplete = true
			}
		},
		Description = "Seraphel needs a brighter offering. Catch and bring her a Shiny Celestial Flying Fish.",
		CompletedDescription = "Return to Seraphel with the Shiny Celestial Flying Fish.",
		Prerequisites = {
			QuestComplete = { "Wingkeeper1" }
		},
		List = { module.CatchFishAny({
				Fish = "Flying Fish",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Celestial",
					Shiny = true
				},
				AndReturn = true
			}) },
		Rewards = {
			{ "Bobber", "Guitar Pick" }
		}
	},
	Wingkeeper3 = {
		DisplayName = "Seraphel: A Blessed Hymn",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Major",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "Seraphel",
		NavigationTargets = {
			{
				Tags = { "Seraphel" },
				AllComplete = true
			}
		},
		Description = "Seraphel sings of higher pursuits. Catch and bring her a Shiny Blessed Harmonic Dove.",
		CompletedDescription = "Return to Seraphel with the Shiny Blessed Harmonic Dove.",
		Prerequisites = {
			QuestComplete = { "Wingkeeper2" }
		},
		List = { module.CatchFishAny({
				Fish = "Harmonic Dove",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Blessed",
					Shiny = true
				},
				AndReturn = true
			}) },
		Rewards = {
			{ "Title", "Ascendance" },
			{ "Bait", "Starlight Worm", 150 }
		}
	},
	Wingkeeper4 = {
		DisplayName = "Seraphel: Wings of the Heavens",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		QuestType = "Major",
		ExpiresAt = dateTime,
		AcceptIndicatorTag = "Seraphel",
		NavigationTargets = {
			{
				Tags = { "Seraphel" },
				AllComplete = true
			}
		},
		Description = "Earn the Wingkeeper Rod. Catch and bring Seraphel a Shiny or Sparkling Nova Wyvern.",
		CompletedDescription = "Return to Seraphel to claim the Wingkeeper Rod.",
		Prerequisites = {
			QuestComplete = { "Wingkeeper3" }
		},
		List = { module.CatchFishAny({
				Fish = "Wyvern",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Nova",
					ShinyOrSparkling = true
				},
				AndReturn = true
			}) },
		Rewards = {
			{ "Rod", "Wingkeeper" }
		}
	}
}

for _, v in WingkeeperQuest do
	v.WishLocked = "Wingkeeper"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return WingkeeperQuest