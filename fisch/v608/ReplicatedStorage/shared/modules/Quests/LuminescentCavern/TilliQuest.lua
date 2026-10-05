local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.TilliCrownFragment] = {
		DisplayName = "Tilli's Fragment",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Tilli",
		NavigationTargets = {
			{
				Zone = "Crimson Cavern",
				Tags = { "Tilli" }
			}
		},
		Description = "Collect glowing plants for Tilli.",
		CompletedDescription = "Speak to Tilli to complete the quest.",
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.TilliCrownFragment}`,
				5,
				"Collect and give 5 glowing plants to Tilli."
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Tilli's Fragment</b>" }
		}
	}
}