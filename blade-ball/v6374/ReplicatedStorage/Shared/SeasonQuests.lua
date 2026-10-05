return {
	{
		QuestType = "Daily",
		DisplayName = "Win 1 game",
		Currency = "XP",
		Reward = 100,
		CompletionArguments = {
			"Round_Won",
			1,
			nil,
			nil,
			nil
		}
	},
	{
		QuestType = "Daily",
		DisplayName = "Win 2 games",
		Currency = "XP",
		Reward = 100,
		CompletionArguments = {
			"Round_Won",
			2,
			nil,
			nil,
			nil
		}
	},
	{
		QuestType = "Daily",
		DisplayName = "Play 15 Ranked mode matches",
		Currency = "XP",
		Reward = 50,
		CompletionArguments = {
			"Play_Round",
			15,
			nil,
			nil,
			"Ranked"
		},
		Icon = "rbxassetid://15022099579"
	},
	{
		QuestType = "Daily",
		DisplayName = "Score Top 5 in any mode",
		Currency = "XP",
		Reward = 60,
		CompletionArguments = { "Top5Alive", 1, nil }
	},
	{
		Disabled = true,
		QuestType = "Daily",
		DisplayName = "Score Top 5 in any mode",
		Currency = "XP",
		Reward = 60,
		CompletionArguments = { "Top5Alive", 1, nil }
	},
	{
		QuestType = "Daily",
		DisplayName = "Score Top 2 in any mode",
		Currency = "XP",
		Reward = 60,
		CompletionArguments = { "Top2Alive", 1, nil }
	},
	{
		QuestType = "Daily",
		DisplayName = "Play for 60 minutes",
		Currency = "XP",
		Reward = 200,
		CompletionArguments = { "Play_Time", 60, nil },
		Icon = "rbxassetid://15046295496",
		Premium = true
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 120 minutes",
		Currency = "XP",
		Reward = 50,
		CompletionArguments = { "Play_Time", 120, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Play with 10 different swords in any mode",
		Currency = "XP",
		Reward = 75,
		CompletionArguments = {
			"Use_Sword_In_Match",
			10,
			nil,
			nil
		}
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 2 enemies in a single match",
		Currency = "XP",
		Reward = 50,
		CompletionArguments = { "Round_Kill_Count", 2, nil }
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 4 enemies in a single match",
		Currency = "XP",
		Reward = 100,
		CompletionArguments = { "Round_Kill_Count", 4, nil }
	},
	{
		QuestType = "Season",
		DisplayName = "Survive for 200 total minutes",
		Currency = "XP",
		Reward = 100,
		CompletionArguments = { "Match_Time", 200, nil }
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 240 total minutes",
		Currency = "XP",
		Reward = 100,
		CompletionArguments = { "Play_Time", 240, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 360 total minutes",
		Currency = "XP",
		Reward = 200,
		CompletionArguments = { "Play_Time", 360, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Survive for 500 total minutes",
		Currency = "XP",
		Reward = 200,
		CompletionArguments = { "Match_Time", 500, nil },
		Premium = true
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 6 enemies in a single match",
		Currency = "XP",
		Reward = 250,
		CompletionArguments = { "Round_Kill_Count", 6, nil }
	},
	{
		QuestType = "Season",
		DisplayName = "Double-jump 800 times in any mode",
		Currency = "XP",
		Reward = 250,
		CompletionArguments = { "Double_Jump", 800, nil }
	},
	{
		QuestType = "Season",
		DisplayName = "Move 50,000 studs in any mode",
		Currency = "XP",
		Reward = 300,
		CompletionArguments = { "Studs_Moved", 50000 }
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 600 total minutes",
		Currency = "XP",
		Reward = 300,
		CompletionArguments = { "Play_Time", 600, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Win 3 games in a row in any mode",
		Currency = "XP",
		Reward = 400,
		CompletionArguments = { "Win_Streak", 3, nil },
		Icon = "rbxassetid://15022099579"
	},
	{
		QuestType = "Season",
		DisplayName = "Add 7 friends from within Blade Ball",
		Currency = "XP",
		Reward = 250,
		CompletionArguments = { "Friend_Added", 7 }
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 960 total minutes",
		Currency = "XP",
		Reward = 400,
		CompletionArguments = { "Play_Time", 960, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Parry the ball 1,000 times",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = { "Parry_Ball", 1000 },
		Icon = "rbxassetid://15046295651"
	},
	{
		QuestType = "Season",
		DisplayName = "Log into the game on a total of 20 days",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = { "Daily_Login", 20 }
	},
	{
		QuestType = "Season",
		DisplayName = "Win 500 matches in any mode",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = {
			"Round_Won",
			500,
			nil,
			nil,
			nil
		}
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 1200 total minutes",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = { "Play_Time", 1200, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Reach Diamond or above in Ranked mode",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = { "Achieve_Rank", 1, 6000 },
		Icon = "rbxassetid://15022099579"
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 50 players with the Glacier Shard!",
		Currency = "XP",
		Reward = 500,
		CompletionArguments = {
			"Kill_Player",
			50,
			nil,
			nil,
			nil,
			"Glacier Shard"
		},
		Premium = true
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 1800 total minutes",
		Currency = "XP",
		Reward = 600,
		CompletionArguments = { "Play_Time", 1800, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 1500 players in any mode",
		Currency = "XP",
		Reward = 750,
		CompletionArguments = { "Kill_Player", 1500 }
	},
	{
		QuestType = "Season",
		DisplayName = "Eliminate 500 players in Ranked mode",
		Currency = "XP",
		Reward = 750,
		CompletionArguments = {
			"Kill_Player",
			500,
			nil,
			nil,
			"Ranked"
		},
		Icon = "rbxassetid://15022099579"
	},
	{
		QuestType = "Season",
		DisplayName = "Play for 2160 total minutes",
		Currency = "XP",
		Reward = 750,
		CompletionArguments = { "Play_Time", 2160, nil },
		Icon = "rbxassetid://15046295496"
	},
	{
		QuestType = "Season",
		DisplayName = "Win 30 matches in Normal mode",
		Currency = "XP",
		Reward = 800,
		CompletionArguments = {
			"Round_Won",
			30,
			nil,
			"Normal",
			nil
		},
		Premium = true
	},
	{
		QuestType = "Season",
		DisplayName = "Use Time Hole 50 times",
		Currency = "XP",
		Reward = 800,
		CompletionArguments = { "Use_Ability", 50, "Time Hole" },
		Icon = "rbxassetid://16125258147",
		Premium = true
	},
	{
		QuestType = "Season",
		DisplayName = "Gift a GamePass or any Robux item",
		Currency = "XP",
		Reward = 1000,
		CompletionArguments = { "Gift_Robux_Item", 1 }
	}
}