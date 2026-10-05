return {
	SlipperSituationQuest = {
		DisplayName = "Slipper Situation",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Side",
		AcceptIndicatorTag = "Linebeck",
		NavigationTargets = {
			{
				Zone = "Roslit Hamlet",
				Tags = { "Linebeck" }
			}
		},
		Description = "Catch And Appraise an Eel!",
		CompletedDescription = "Talk to Linebeck to receive your reward!",
		List = {
			{
				"CatchFishAny",
				1,
				{ "Eel" },
				nil,
				nil
			},
			{
				"AppraiseFish",
				1,
				{ "Eel" }
			}
		},
		Rewards = {
			{ "Currency", "Coins", 1500 },
			{ "Xp", 3000 }
		}
	}
}