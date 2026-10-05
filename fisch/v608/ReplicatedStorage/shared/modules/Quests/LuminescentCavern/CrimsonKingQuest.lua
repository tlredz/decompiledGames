local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.CrimsonKing] = {
		DisplayName = "The Crimson King's Fragments",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "CrimsonKing",
		NavigationTargets = {
			{
				Zone = "Crimson Cavern",
				Tags = { "CrimsonKing" }
			}
		},
		Description = "Collect and show 5 fragments to the Crimson King.",
		CompletedDescription = "Speak to the Crimson King to Complete.",
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.CrimsonKing}`,
				5,
				"Collect and show 5 fragments to the Crimson King."
			}
		},
		Rewards = {
			{ "DisplayOnly", "<b>Evil Sigil</b> ×1" }
		}
	}
}