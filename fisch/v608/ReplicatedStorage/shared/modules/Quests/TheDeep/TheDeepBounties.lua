local module = require("../../SimpleFetchQuests/lib")
local TheDeepBounties = {}

for i = 1, 5 do
	TheDeepBounties[`DeepBounty{i}`] = {
		HasCustomData = true,
		IsRepeatable = true,
		DisplayName = `Deep Bounty: {module.var("TargetFish")}`,
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(96, 189, 210),
		QuestType = "Challenge",
		AutoNavigate = true,
		AcceptIndicatorTag = "DeepBountyBoard",
		NavigationTargets = {
			{
				Zone = "Deep City",
				Tags = { "DeepBountyBoard" },
				AllComplete = true
			}
		},
		Description = `The Citizen Bounty Board is paying for one {module.var("TargetFish")} from the {module.var("TargetRegion")}. The contract expires {module.var("ExpireMinutes")} minutes after signing.`,
		CompletedDescription = `You caught the {module.var("TargetFish")}! Return it to the Bounty Tracker in Deep City before the contract expires.`,
		List = {
			{
				"CatchFishAny",
				1,
				{ module.var("TargetFish") },
				nil,
				{
					Return = true
				}
			}
		},
		Rewards = {
			{
				"ItemOrFish",
				"Deep Tackle Box",
				{
					Weight = 18
				},
				5
			},
			{ "Currency", "Coins", module.var("CoinReward") },
			{ "Xp", module.var("XpReward") }
		}
	}
end

return TheDeepBounties