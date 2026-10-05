return {
	Win3 = {
		Type = "Wins",
		Goal = 3,
		Label = "Win 3 matches",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	Win7 = {
		Type = "Wins",
		Goal = 7,
		Label = "Win 7 matches",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	PlayMatches5 = {
		Type = "MatchesPlayed",
		Goal = 5,
		Label = "Play 5 matches",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	Playtime15 = {
		Type = "Playtime",
		Goal = 900,
		Label = "Play for 15 minutes",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	Playtime30 = {
		Type = "Playtime",
		Goal = 1800,
		Label = "Play for 30 minutes",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	Playtime60 = {
		Type = "Playtime",
		Goal = 3600,
		Label = "Play for 1 hour",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	FastWord3 = {
		Type = "Speed",
		Goal = 3,
		Condition = function(_, p)
			return p <= 3
		end,
		Label = "Answer 3 words in under 3 seconds",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	FastWord5 = {
		Type = "Speed",
		Goal = 5,
		Condition = function(_, p)
			return p <= 5
		end,
		Label = "Answer 5 words in under 5 seconds",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	WinStreak2 = {
		Type = "WinStreak",
		Goal = 2,
		Label = "Win 2 matches in a row",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	WinStreak3 = {
		Type = "WinStreak",
		Goal = 3,
		Label = "Win 3 matches in a row",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	NoStrikeMatch = {
		Type = "NoStrike",
		Goal = 1,
		Label = "Finish a match without getting a strike",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	LongWord8 = {
		Type = "Length",
		Goal = 1,
		Condition = function(list)
			return #list >= 8
		end,
		Label = "Type a word with 8+ letters",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	LongWord12 = {
		Type = "Length",
		Goal = 1,
		Condition = function(list)
			return #list >= 12
		end,
		Label = "Type a word with 12+ letters",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	PrefixUn = {
		Type = "Prefix",
		Goal = 3,
		Condition = function(value)
			return value:sub(1, 2) == "un"
		end,
		Label = "Type 3 words starting with \"un\"",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	PrefixRe = {
		Type = "Prefix",
		Goal = 3,
		Condition = function(value)
			return value:sub(1, 2) == "re"
		end,
		Label = "Type 3 words starting with \"re\"",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	SuffixIng = {
		Type = "Suffix",
		Goal = 5,
		Condition = function(value)
			return value:sub(-3) == "ing"
		end,
		Label = "Type 5 words ending with \"-ing\"",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	SuffixLy = {
		Type = "Suffix",
		Goal = 5,
		Condition = function(value)
			return value:sub(-2) == "ly"
		end,
		Label = "Type 5 words ending with \"-ly\"",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	},
	SuffixEd = {
		Type = "Suffix",
		Goal = 5,
		Condition = function(value)
			return value:sub(-2) == "ed"
		end,
		Label = "Type 5 words ending with \"-ed\"",
		Rewards = {
			{
				Id = "SecretKey",
				Amount = 1
			}
		}
	}
}