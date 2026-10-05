local module = require("../SimpleFetchQuests/lib")
return {
	ApprenticeArchaeologist = {
		DisplayName = "Invincible Relic",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 145, 48),
		QuestType = "Challenge",
		AcceptIndicatorTag = "ApprenticeArchaeologist",
		NavigationTargets = {
			{
				Zone = "Ancient Isle",
				Tags = { "ApprenticeArchaeologist" },
				AllComplete = true
			}
		},
		Description = "The Apprentice Archaeologist found a strange, unique Relic... but wants some help in return for it.",
		CompletedDescription = "You caught the Ancient Megalodon! Head back to the Apprentice Archaeologist to claim the Relic.",
		Prerequisites = {
			Level = 50
		},
		List = { module.CatchFishAny({
				Fish = "Ancient Megalodon",
				AndReturn = true
			}) },
		Rewards = {
			{
				"ItemOrFish",
				"Invincible Relic",
				{
					Weight = 21
				},
				1
			}
		}
	},
	CaptainAhab = {
		DisplayName = "Song of the Deep",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(42, 180, 255),
		QuestType = "Challenge",
		AcceptIndicatorTag = "CaptainAhab",
		NavigationTargets = {
			{
				Zone = "Moosewood",
				Tags = { "CaptainAhab" },
				AllComplete = true
			}
		},
		Description = "Captain Ahab has tasked you with enacting vengeance on a great white beast, in return for a rare and powerful Relic.",
		CompletedDescription = "You caught the Moby (or Humpback Whale)! Head back to Captain Ahab to claim the Relic.",
		Prerequisites = {
			Level = 50
		},
		List = { module.CatchFishAny({
				Fish = { "Moby", "Humpback Whale" },
				AndReturn = true
			}) },
		Rewards = {
			{
				"ItemOrFish",
				"Song of the Deep",
				{
					Weight = 21
				},
				1
			},
			{ "Bobber", "The Moby Bobber" }
		}
	}
}