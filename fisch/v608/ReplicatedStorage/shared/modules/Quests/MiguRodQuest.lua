local module = require("../SimpleFetchQuests/lib")
return {
	MiguRod_TitleSecondChance = {
		DisplayName = "MiguRod: Fool's Errand",
		Icon = "rbxassetid://119449004351627",
		IconColor = Color3.fromRGB(255, 43, 71),
		QuestType = "Side",
		ExpiresAt = DateTime.fromUniversalTime(2026, 5, 1),
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "Migura" }
			}
		},
		Description = "All of this for a title... ばかだな",
		CompletedDescription = "",
		List = {
			module.ObtainItem({
				Item = "Bluelip Batfish",
				RequiredAttributes = {
					Mutation = "Tryhard",
					Sparkling = true
				},
				ForNpc = "Migura"
			}),
			module.ObtainItem({
				Item = "Bluelip Batfish",
				RequiredAttributes = {
					Mutation = "Evil",
					Shiny = true
				},
				ForNpc = "Migura"
			}),
			module.ObtainItem({
				Item = "Bluelip Batfish",
				RequiredAttributes = {
					Mutation = "Sanguine",
					Shiny = true,
					Sparkling = true
				},
				ForNpc = "Migura"
			}),
			{
				"DataInstanceValue",
				"Cache.FoolPay1B",
				true,
				"Pay 1,000,000,000 C$ to Migura"
			}
		},
		Rewards = {
			{ "Title", "Fool" }
		}
	},
	MiguRod_TawouExtra = {
		DisplayName = "MiguRod: Tawou's Snack",
		Icon = "rbxassetid://119449004351627",
		IconColor = Color3.fromRGB(255, 219, 41),
		QuestType = "Side",
		ExpiresAt = DateTime.fromUniversalTime(2026, 5, 1),
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "Tawou" },
				AllComplete = true
			}
		},
		Description = "The insatiable greed of The Yellow One",
		CompletedDescription = "Return the Sparkling Mesmerized Banana to Tawou",
		List = { module.CatchFishAny({
				Fish = "Banana",
				RequiredAttributes = {
					Mutation = "Mesmerized",
					Sparkling = true
				},
				AndReturn = true
			}) },
		Rewards = {
			{
				"ItemOrFish",
				"Broken Phone",
				{},
				1
			}
		}
	},
	MiguRod_MakhExtra = {
		DisplayName = "MiguRod: Makh's Relic",
		Icon = "rbxassetid://119449004351627",
		IconColor = Color3.fromRGB(39, 219, 255),
		QuestType = "Side",
		ExpiresAt = DateTime.fromUniversalTime(2026, 5, 1),
		AutoNavigate = true,
		NavigationTargets = {
			{
				Zone = "Underground Music Venue",
				Tags = { "Makh" },
				AllComplete = true
			}
		},
		Description = "Makh needs a special relic for some reason.",
		CompletedDescription = "Return the Sparkling Harmonized Enchant Relic to Makh",
		List = { module.CatchFishAny({
				Fish = "Enchant Relic",
				RequiredAttributes = {
					Mutation = "Harmonized",
					Sparkling = true
				},
				AndReturn = true
			}) },
		Rewards = {
			{ "DisplayOnly", "???" }
		}
	}
}