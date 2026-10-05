local module = require("../../SimpleFetchQuests/lib")
return {
	Vance_CrestedCloud = {
		DisplayName = "Aeronaut Vance: An Air-Worthy Vessel",
		QuestType = "Major",
		Icon = "",
		IconColor = Color3.fromRGB(198, 233, 255),
		CompletedDescription = "You gathered every part. Take them back to Vance.",
		AutoNavigate = true,
		AcceptIndicatorTag = "AeronautVance",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "AeronautVance" },
				AllComplete = true
			}
		},
		List = {
			module.CatchFishAny({
				Fish = "African Butterflyfish",
				RequiredAmount = 1,
				Weathers = "Tropical Squall"
			}),
			module.ObtainItem({
				Item = "Crested Relic",
				RequiredAmount = 1,
				ForNpc = "Vance"
			}),
			module.CatchFishAny({
				Fish = "Abaia",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Gusty"
				},
				AndReturn = true
			}),
			module.ObtainItem({
				Item = "Empyrean Relic",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Gusty"
				},
				ForNpc = "Vance"
			})
		},
		Rewards = {
			{ "Boat", "Crested Cloud" },
			{ "IdolFavor", 4000 }
		}
	}
}