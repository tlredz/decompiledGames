local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.VimbleCrownFragment] = {
		DisplayName = "Vimble's Fragment",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "Vimble",
		NavigationTargets = {
			{
				Zone = "Luminescent Cavern",
				Tags = { "Vimble" }
			}
		},
		Description = "Find fish to show to Vimble.",
		CompletedDescription = "Show Vimble the fish he wants to see.",
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.VimbleCrownFragment}`,
				true,
				"???"
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Vimble's Fragment</b>" }
		}
	}
}