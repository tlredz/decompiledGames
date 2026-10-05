local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.RokkoCrownFragment] = {
		DisplayName = "Rokko's Fragment",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Rokko",
		NavigationTargets = {
			{
				Zone = "Luminescent Cavern",
				Tags = { "Rokko" }
			}
		},
		Description = "Find something to show to Rokko.",
		CompletedDescription = "Show your catch to Rokko.",
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.RokkoCrownFragment}`,
				true,
				"???"
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Rokko's Fragment</b>" }
		}
	}
}