local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
return {
	[LuminescentCavern.Enums.Quest.CrimsonGuard] = {
		DisplayName = "A Mutated Dragon",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		AcceptIndicatorTag = "CrimsonGuard",
		NavigationTargets = {
			{
				Zone = "Luminescent Cavern",
				Tags = { "CrimsonGuard" }
			}
		},
		Description = "Find a special dragon for the Crimson Guard.",
		CompletedDescription = "Speak to the Crimson Guard.",
		IsSecret = true,
		List = {
			{
				"DataInstanceValue",
				`Cache.{LuminescentCavern.Enums.Quest.CrimsonGuard}`,
				true,
				"???"
			}
		},
		Rewards = {
			{ "DisplayOnly", "Access to the <b><font color='#af3a3a'>Crimson Cavern</font></b>" }
		}
	}
}