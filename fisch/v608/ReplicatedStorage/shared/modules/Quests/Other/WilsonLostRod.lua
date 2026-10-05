local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
require(ReplicatedStorage.shared.modules.Quests.Util)
return {
	WilsonLostRod = {
		DisplayName = "Wilson's Lost Rod",
		Icon = "rbxassetid://18409756966",
		IconColor = Color3.new(0, 0, 0),
		QuestType = "Side",
		Description = "Wilson lost his rod while fishing off a cliff...",
		CompletedDescription = "You found Wilson's rod! Head back to upper Snowcap to return it.",
		AcceptIndicatorTag = "Wilson",
		NavigationTargets = {
			{
				Zone = "Snowcap",
				Objectives = { 1 }
			},
			{
				Zone = "Upper Snowcap",
				Tags = { "Wilson" },
				AllComplete = true
			}
		},
		List = {
			{ "Custom", true, "Find Wilson's lost rod" }
		},
		Rewards = {
			{
				"ItemOrFish",
				"Common Crate",
				{},
				25
			},
			{ "Xp", 1000 }
		}
	}
}