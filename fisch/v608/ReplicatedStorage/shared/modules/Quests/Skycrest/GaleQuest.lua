local module = require("../../SimpleFetchQuests/lib")
return {
	Gale_GaleSpirit = {
		DisplayName = "Gale: A Light Through the Storm",
		QuestType = "Major",
		Icon = "",
		IconColor = Color3.fromRGB(143, 216, 255),
		CompletedDescription = "The lantern's core is lit. Return to Gale.",
		AutoNavigate = true,
		AcceptIndicatorTag = "Gale",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "FireOfSpirits" },
				Objectives = { 3 }
			},
			{
				Zone = "Skycrest",
				Tags = { "Gale" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", true, "Collect a Blue Ghost Firefly during Foggy weather" },
			module.CatchFishAny({
				RequiredAmount = 5,
				RequiredAttributes = {
					Mutation = "Squalled"
				}
			}),
			{ "Custom", 3, "Offer 3 fish at the Fire of Spirits" }
		},
		Rewards = {
			{ "Lantern", "Gale Spirit" },
			{ "IdolFavor", 3500 }
		}
	}
}