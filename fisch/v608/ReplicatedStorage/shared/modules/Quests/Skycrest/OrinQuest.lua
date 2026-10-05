local module = require("../../SimpleFetchQuests/lib")
local _ = { "Loopy Five Firefly", "Blue Ghost Firefly" }
return {
	Orin_IdolCrest = {
		DisplayName = "Orin: A Proper Bobber",
		QuestType = "Major",
		Icon = "",
		IconColor = Color3.fromRGB(164, 195, 232),
		CompletedDescription = "You gathered everything Orin asked for. Bring it back to him.",
		AutoNavigate = true,
		AcceptIndicatorTag = "Orin",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "Orin" },
				AllComplete = true
			}
		},
		List = {
			module.CatchFishAny({
				RequiredAmount = 15,
				FishingZones = "Skycrest",
				PerfectCast = true,
				PerfectCatch = true
			}),
			{ "Custom", 1, "Catch 1 Loopy Five Firefly or Blue Ghost Firefly" },
			module.CatchFishAny({
				RequiredAmount = 1,
				RequiredAttributes = {
					ShinyOrSparkling = true
				},
				FishingZones = "Skycrest"
			})
		},
		Rewards = {
			{ "Bobber", "Idol Crest" },
			{ "IdolFavor", 2500 }
		}
	}
}