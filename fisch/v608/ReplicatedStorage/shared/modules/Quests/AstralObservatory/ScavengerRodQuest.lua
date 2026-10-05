local ReplicatedStorage = game:GetService("ReplicatedStorage")
local color = Color3.fromRGB(193, 233, 255)
local lib = require(ReplicatedStorage.shared.modules.SimpleFetchQuests.lib)
return {
	ScavengerRod = {
		DisplayName = "Dr. Crookspine's Errands",
		QuestType = "Major",
		Icon = "rbxassetid://18162767851",
		IconColor = color,
		Description = "Dr. Crookspine needs a few materials to finish making his new prototype fishing rod...",
		NavigationTargets = {
			{
				Zone = "The Laboratory",
				Tags = { "Crookspine" },
				AllComplete = true
			}
		},
		List = { lib.ObtainItem({
				Item = "Rusty Bolt",
				RequiredAmount = 2,
				RequiredAttributes = {
					Mutation = "Silver"
				},
				ForNpc = "Dr. Crookspine"
			}), lib.CatchFishAny({
				Fish = "Scrap Metal",
				RequiredAmount = 5,
				AndReturn = true
			}), lib.ObtainItem({
				Item = "String",
				RequiredAmount = 1,
				RequiredAttributes = {
					Mutation = "Lunar"
				},
				ForNpc = "Dr. Crookspine"
			}) },
		Rewards = {
			{ "Rod", "Scavenger Rod" }
		}
	}
}