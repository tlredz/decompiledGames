return {
	RefreshSeconds = 60,
	WriteSeconds = 10,
	WriteBatchSize = 8,
	WriteSpacing = 0.15,
	Boards = {
		LMS = {
			ModelName = "LeaderboardLMS",
			DataStoreName = "ChickenOrHero_LMSLeaderboard_v1",
			PageSize = 50,
			Title = "LAST MAN STANDING",
			Suffix = "LMS",
			HoverStuds = 0.22,
			HoverPeriod = 4.5,
			TurnResponsiveness = 4,
			AnimateDistance = 180
		},
		Levels = {
			ModelName = "LeaderboardLevels",
			DataStoreName = "ChickenOrHero_XPLeaderboard_v1",
			PageSize = 50,
			Title = "HIGHEST LEVEL",
			Suffix = "LEVEL",
			ValueFormat = "Level",
			HoverStuds = 0.22,
			HoverPeriod = 4.5,
			TurnResponsiveness = 4,
			AnimateDistance = 180
		},
		Catches = {
			ModelName = "LeaderboardCatches",
			DataStoreName = "ChickenOrHero_CatchesLeaderboard_v1",
			PageSize = 50,
			Title = "MOST CATCHES",
			Suffix = "CATCHES",
			HoverStuds = 0.22,
			HoverPeriod = 4.5,
			TurnResponsiveness = 4,
			AnimateDistance = 180
		},
		Wins = {
			ModelName = "LeaderboardWins",
			DataStoreName = "ChickenOrHero_WinsLeaderboard_v1",
			PageSize = 50,
			Title = "MOST WINS",
			Suffix = "🏆",
			HoverStuds = 0.22,
			HoverPeriod = 4.5,
			TurnResponsiveness = 4,
			AnimateDistance = 180
		}
	}
}