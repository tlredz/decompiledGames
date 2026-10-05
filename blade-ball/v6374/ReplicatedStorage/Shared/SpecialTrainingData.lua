game:GetService("ReplicatedStorage")
return {
	DISABLED = true,
	MAXEVENTTIME = DateTime.fromUniversalTime(2024, 6, 15, 16, 0, 0),
	AMOUNTOFQUESTS = 5,
	SPECIAL_DAILY_LOGIN_VERSION = 15,
	CURRENT_TRAINING_QUEST = 11,
	CURRENT_RESETS_AVAILABLE = 1,
	EVENT_QUESTS = 1,
	GiftPurchaseSword = 1766864749,
	PurchaseSword = 1766864625,
	QuestToDiff = {
		1,
		1,
		2,
		2,
		3
	},
	SpecialTrainingQuests = {
		{
			{
				QuestType = "Daily",
				DisplayName = "Play 8 matches",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Play_Round", 8 }
			},
			{
				QuestType = "Daily",
				DisplayName = "Eliminate 5 people in 2 team mode",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = {
					"Kill_Player",
					5,
					nil,
					"2Teams"
				}
			},
			{
				QuestType = "Daily",
				DisplayName = "Parry the ball 60 times",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Parry_Ball", 60, nil }
			},
			{
				QuestType = "Daily",
				DisplayName = "Play for 30 minutes",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Play_Time", 600, nil }
			},
			{
				QuestType = "Daily",
				DisplayName = "Play with 1 friend",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Friend_Login", 1 }
			},
			{
				QuestType = "Daily",
				DisplayName = "Play in 4 Duels",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Play_Duel", 4 }
			},
			{
				QuestType = "Daily",
				DisplayName = "Join or create a clan",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = { "Join_Clan", 1 }
			},
			{
				QuestType = "Daily",
				DisplayName = "Defeat 5 people in ICC Fan Zone Map",
				Currency = "XP",
				Amount = 5,
				CompletionArguments = { "Kill_Player", 5, "StadiumICC" },
				IsEventQuest = true
			},
			{
				QuestType = "Daily",
				DisplayName = "Play a match on the ICC Fan Zone Map",
				Currency = "XP",
				Amount = 5,
				CompletionArguments = { "Play_Round", 1, "StadiumICC" },
				IsEventQuest = true
			}
		},
		{
			[1] = {
				QuestType = "Daily",
				DisplayName = "Eliminate 7 people in any mode",
				Currency = "XP",
				Amount = 3,
				CompletionArguments = {
					"Kill_Player",
					7,
					nil,
					nil
				}
			},
			[2] = {
				QuestType = "Daily",
				DisplayName = "Parry the ball 100 times",
				Currency = "XP",
				Amount = 5,
				CompletionArguments = { "Parry_Ball", 100, nil }
			},
			[3] = {
				QuestType = "Daily",
				DisplayName = "Parry the ball 250 times",
				Currency = "XP",
				Amount = 5,
				CompletionArguments = { "Parry_Ball", 250, nil }
			},
			[4] = {
				QuestType = "Daily",
				DisplayName = "Win at least 2 Duels",
				Currency = "XP",
				Amount = 5,
				CompletionArguments = { "Win_Duel", 2 }
			},
			[6] = {
				QuestType = "Daily",
				DisplayName = "Win 3 times in ICC Fan Zone Map",
				Currency = "XP",
				Amount = 8,
				CompletionArguments = {
					"Round_Won",
					3,
					nil,
					nil,
					nil,
					nil,
					"StadiumICC"
				},
				IsEventQuest = true
			}
		},
		{
			{
				QuestType = "Daily",
				DisplayName = "Play for 90 minutes",
				Currency = "XP",
				Amount = 8,
				CompletionArguments = { "Play_Time", 1800, nil }
			},
			{
				QuestType = "Daily",
				DisplayName = "Eliminate 5 enemies in a single match 5 times",
				Currency = "XP",
				Amount = 8,
				CompletionArguments = { "Round_Kill_Count_Special", 5, nil }
			},
			{
				QuestType = "Daily",
				DisplayName = "Win 1 game",
				Currency = "XP",
				Amount = 8,
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
				DisplayName = "Win 2 Team Mode 2 Times",
				Currency = "XP",
				Amount = 8,
				CompletionArguments = {
					"Round_Won",
					2,
					"2Teams",
					nil,
					nil
				}
			},
			{
				QuestType = "Daily",
				DisplayName = "Win 1 game using dash ability",
				Currency = "XP",
				Amount = 8,
				CompletionArguments = {
					"Round_Won",
					1,
					nil,
					nil,
					"Dash"
				}
			},
			{
				QuestType = "Daily",
				DisplayName = "Win 5 games in ICC Fan Zone Map",
				Currency = "XP",
				Amount = 10,
				CompletionArguments = {
					"Round_Won",
					5,
					nil,
					nil,
					nil,
					nil,
					"StadiumICC"
				},
				IsEventQuest = true
			},
			{
				QuestType = "Daily",
				DisplayName = "Win a dungeons game",
				Currency = "XP",
				Amount = 10,
				CompletionArguments = { "Win_Dungeon", 1 },
				IsEventQuest = true
			}
		}
	},
	SpecialTrainingRewards = {
		{
			Icon = "rbxassetid://15038384377",
			Required = 20,
			RewardType = "Coins",
			Amount = 250
		},
		{
			Icon = "rbxassetid://15049303003",
			Required = 40,
			RewardType = "PremiumExplosionCrate",
			Amount = 1
		},
		{
			Icon = "rbxassetid://17693585682",
			Required = 60,
			RewardType = "Explosion",
			RewardStat = "Cowboy's Capture",
			DisplayName = "Cowboy's Capture"
		},
		{
			Icon = "rbxassetid://17684913683",
			Required = 80,
			RewardType = "Emote",
			RewardStat = "Emote357",
			DisplayName = "High Noon"
		},
		{
			Icon = "rbxassetid://17684914004",
			Required = 100,
			RewardType = "Sword",
			RewardStat = "Horseman's Sword",
			DisplayName = "Horseman's Sword"
		},
		{
			Icon = "rbxassetid://17676181458",
			Required = 120,
			RewardType = "Ability",
			RewardStat = "Bounty",
			DisplayName = "Bounty"
		}
	},
	Products = {
		[0] = {
			Id = 1676256463,
			Amount = 1,
			Price = 1
		},
		[1] = {
			Id = 1676261676,
			Amount = 1,
			Price = 99
		},
		[2] = {
			Id = 1676261918,
			Amount = 1,
			Price = 199
		},
		[3] = {
			Id = 1676261963,
			Amount = 1,
			Price = 299
		},
		[4] = {
			Id = 1676262004,
			Amount = 1,
			Price = 399
		}
	},
	Gifts = {
		{
			Id = 1676262354,
			Amount = 2,
			Price = 999
		},
		{
			Id = 1676262500,
			Amount = 10,
			Price = 2999
		},
		{
			Id = 1676262558,
			Amount = 100,
			Price = 9999
		}
	}
}