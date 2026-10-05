local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.WixieCrownFragment] = {
		DisplayName = "Wixie's Fragment",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Wixie",
		NavigationTargets = {
			{
				Zone = "Crimson Cavern",
				Tags = { "Wixie" }
			}
		},
		Description = "Find and return crystals to Wixie.",
		CompletedDescription = "Speak to Wixie to complete the quest.",
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.WixieCrownFragment}`,
				8,
				"Collect 8 crystals for Wixie."
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Wixie's Fragment</b>" }
		}
	}
}