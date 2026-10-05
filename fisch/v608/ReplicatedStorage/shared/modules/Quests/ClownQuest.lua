local dateTime = DateTime.fromUniversalTime(2025, 12, 13, 17)
local ClownQuest = {
	ClownQuest1 = {
		DisplayName = "Silly Clown: Find the Balloon Animals!",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 0, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Interact with the 20 Balloon Animals across the sea!",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.ClownQuest1",
				20,
				"Interact with the 20 Balloon Animals across the sea!"
			}
		},
		Rewards = {}
	},
	ClownQuest2 = {
		DisplayName = "Silly Clown: Where's the String?",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(255, 255, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		Description = "Return a single String",
		CompletedDescription = "",
		List = {
			{
				"DataInstanceValue",
				"Cache.ClownQuest2",
				true,
				"Return a single String."
			}
		},
		Rewards = {
			{ "Boat", "Clown Car" },
			{ "Title", "🔴 Honked 🔴" },
			{
				"ItemOrFish",
				"Banana",
				{
					Weight = 4,
					Mutation = "Honked",
					Shiny = true
				},
				1
			},
			{ "Rod", "Silly Fun Happy Rod" }
		}
	}
}

for _, v in ClownQuest do
	v.WishLocked = "SillyFunHappyRod"
	v.AcceptIndicatorTag = "WishEcho"
	v.NavigationTargets = {
		{
			Zone = "Skycrest",
			Tags = { "WishEcho" }
		}
	}
end

return ClownQuest