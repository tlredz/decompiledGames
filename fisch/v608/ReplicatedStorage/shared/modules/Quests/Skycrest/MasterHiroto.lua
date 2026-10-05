local module = require("../../SimpleFetchQuests/lib")
return {
	MasterHiroto = {
		HasCustomData = true,
		DisplayName = `Master Hiroto: {module.var("TargetFish")}`,
		Icon = "rbxassetid://0",
		IconColor = Color3.fromRGB(140, 190, 230),
		QuestType = "Challenge",
		AutoNavigate = true,
		AcceptIndicatorTag = "MasterHiroto",
		NavigationTargets = {
			{
				Zone = "Skycrest",
				Tags = { "MasterHiroto" },
				AllComplete = true
			}
		},
		Description = `Master Hiroto has set you a trial: catch a {module.var("TargetFish")}.`,
		CompletedDescription = `You caught the {module.var("TargetFish")}! Return it to Master Hiroto.`,
		List = {
			{
				"CatchFishAny",
				1,
				{ module.var("TargetFish") },
				nil,
				{
					Mutation = module.var("TargetMutation"),
					Return = true
				}
			}
		},
		Rewards = {}
	}
}