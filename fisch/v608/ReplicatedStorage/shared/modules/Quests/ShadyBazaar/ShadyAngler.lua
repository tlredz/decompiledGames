local module = require("../../SimpleFetchQuests/lib")
return {
	ShadyAngler = {
		HasCustomData = true,
		DisplayName = `Shady Angler: {module.var("TargetFish")}`,
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(180, 140, 90),
		QuestType = "Challenge",
		AutoNavigate = true,
		AcceptIndicatorTag = "ShadyAngler",
		NavigationTargets = {
			{
				Zone = "The Shady Bazaar",
				Tags = { "ShadyAngler" },
				AllComplete = true
			}
		},
		Description = `The Shady Angler has tasked you to catch a {module.var("TargetFish")}.`,
		CompletedDescription = `You caught a {module.var("TargetFish")}! Bring it back to the Shady Angler.`,
		Prerequisites = {
			QuestComplete = { "Bazaar_LighthouseEntry" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ module.var("TargetFish") },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{ "LocalCurrency", "Shady Scrip", module.var("ScripReward") }
		}
	},
	HuntingAngler = {
		HasCustomData = true,
		DisplayName = `Hunting Angler: {module.var("TargetFish")}`,
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(180, 140, 90),
		QuestType = "Challenge",
		AutoNavigate = true,
		AcceptIndicatorTag = "HuntingAngler",
		NavigationTargets = {
			{
				Zone = "The Shady Bazaar",
				Tags = { "HuntingAngler" },
				AllComplete = true
			}
		},
		Description = `The Hunting Angler has tasked you to catch a specific {module.var("TargetFish")}.`,
		CompletedDescription = `You caught the {module.var("TargetFish")}! Bring it back to the Hunting Angler.`,
		Prerequisites = {
			QuestComplete = { "Bazaar_LighthouseEntry" }
		},
		List = {
			{
				"CatchFishAny",
				1,
				{ module.var("TargetFish") },
				nil,
				{
					Mutation = module.var("TargetMutation"),
					Return = true
				}
			}
		},
		Rewards = {
			{ "LocalCurrency", "Shady Scrip", module.var("ScripReward") }
		}
	}
}