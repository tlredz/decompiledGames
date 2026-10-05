local dateTime = DateTime.fromUniversalTime(2026, 9, 12, 16)
return {
	CompetitiveCarter = {
		DisplayName = "Fischfest 2026: A Worthy Competitor",
		Icon = "rbxassetid://18162767851",
		IconColor = Color3.fromRGB(0, 0, 0),
		QuestType = "Major",
		ExpiresAt = dateTime,
		AutoNavigate = true,
		AcceptIndicatorTag = "CompetitiveCarter",
		NavigationTargets = {
			{
				Zone = "Fischfest",
				Tags = { "JetskiReferee" },
				Objectives = { 1 }
			},
			{
				Zone = "Fischfest",
				Tags = { "BeachVolleyballReferee" },
				Objectives = { 2 }
			},
			{
				Zone = "Fischfest",
				Tags = { "SandcastleReferee" },
				Objectives = { 3 }
			},
			{
				Zone = "Fischfest",
				Tags = { "CompetitiveCarter" },
				AllComplete = true
			}
		},
		Description = "Prove yourself across all three beach minigames.",
		CompletedDescription = "",
		List = {
			{ "Custom", true, "Win 3 Jetski Races, or finish one under 2:00" },
			{ "Custom", true, "Reach 25+ score in a game of Beach Volleyball" },
			{ "Custom", true, "Win 5 Sand Castle Contests" }
		},
		Rewards = {
			{ "Rod", "Floatie Rod" }
		}
	}
}