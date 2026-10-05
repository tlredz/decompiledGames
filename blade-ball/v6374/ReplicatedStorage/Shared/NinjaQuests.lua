game:GetService("RunService")
local v = {
	RookieRouletteSpin = {
		DisplayName = "Rookie Roulette Spin",
		Icon = "rbxassetid://15488478901"
	},
	AddCrateKeys = {
		DisplayName = "Sword Crate",
		Icon = "rbxassetid://15049301853"
	},
	AddCoins = {
		DisplayName = "Coin",
		Icon = "rbxassetid://9341850470"
	},
	AddEmote = {
		Items = {
			Emote55 = {
				NoQuantity = true,
				DisplayName = "Emote 55",
				Icon = "rbxassetid://15496320234"
			}
		}
	},
	AddSword = {
		Items = {
			Ghostwalker = {
				NoQuantity = true,
				DisplayName = "Ghostwalker",
				Icon = "rbxassetid://15762283711"
			}
		}
	}
}
return {
	RefreshTime = 20,
	WinQuests = {
		{
			DisplayName = "Win 1 match",
			CompletionArguments = {
				"Round_Won",
				1,
				nil,
				nil,
				nil
			},
			Rewards = {
				{ "RookieRouletteSpin", 1 }
			}
		},
		{
			DisplayName = "Win 3 matches",
			CompletionArguments = {
				"Round_Won",
				3,
				nil,
				nil,
				nil
			},
			Rewards = {
				{ "RookieRouletteSpin", 1 }
			}
		},
		{
			DisplayName = "Win 7 matches",
			CompletionArguments = {
				"Round_Won",
				7,
				nil,
				nil,
				nil
			},
			Rewards = {
				{ "RookieRouletteSpin", 1 }
			}
		},
		{
			DisplayName = "Win 12 matches",
			CompletionArguments = {
				"Round_Won",
				12,
				nil,
				nil,
				nil
			},
			Rewards = {
				{ "RookieRouletteSpin", 2 }
			}
		},
		{
			DisplayName = "Win 35 matches",
			CompletionArguments = {
				"Round_Won",
				12,
				nil,
				nil,
				nil
			},
			Rewards = {
				{ "RookieRouletteSpin", 5 }
			}
		}
	},
	DailyQuests = {
		{
			QuestPool = {
				{
					StarterQuest = true,
					DisplayName = "Spend a total of 5 minutes in rounds",
					CompletionArguments = { "Play_Time", 5, nil }
				},
				{
					DisplayName = "Eliminate 2 players",
					CompletionArguments = {
						"Kill_Player",
						2,
						nil,
						nil,
						nil,
						nil
					}
				}
			},
			Rewards = {
				{ "AddCrateKeys", "PremiumSwordCrate", 1 }
			}
		},
		{
			QuestPool = {
				{
					DisplayName = "Win 1 match",
					CompletionArguments = {
						"Round_Won",
						1,
						nil,
						nil,
						nil
					}
				},
				{
					DisplayName = "Spend a total of 25 minutes in rounds",
					CompletionArguments = { "Play_Time", 25, nil }
				}
			},
			Rewards = {
				{ "RookieRouletteSpin", 1 }
			}
		},
		{
			QuestPool = {
				{
					DisplayName = "Eliminate 5 players in ranked",
					CompletionArguments = {
						"Kill_Player",
						5,
						nil,
						nil,
						"Ranked"
					}
				},
				{
					DisplayName = "Join a clan for the first time",
					CompletionArguments = { "Join_Clan", 1 }
				}
			},
			Rewards = {
				{ "AddCoins", 400 },
				{ "RookieRouletteSpin", 2 }
			}
		},
		{
			QuestPool = {
				{
					DisplayName = "Spend a total of 60 minutes in rounds",
					CompletionArguments = { "Play_Time", 60, nil }
				},
				{
					DisplayName = "Win 2 rounds in solo ranked",
					CompletionArguments = {
						"Round_Won",
						2,
						nil,
						"Ranked",
						nil
					}
				}
			},
			Rewards = {
				{ "AddEmote", "Emote55" },
				{ "RookieRouletteSpin", 2 }
			}
		},
		{
			RandomizeQuests = true,
			QuestPool = {
				{
					DisplayName = "Spend a total of 90 minutes in rounds",
					CompletionArguments = { "Play_Time", 90, nil }
				},
				{
					DisplayName = "Win 2 rounds in solo ranked",
					CompletionArguments = {
						"Round_Won",
						2,
						nil,
						"Ranked",
						nil
					}
				},
				{
					DisplayName = "Spend a total of 90 minutes in rounds",
					CompletionArguments = { "Play_Time", 90, nil }
				},
				{
					DisplayName = "Eliminate 10 players",
					CompletionArguments = {
						"Kill_Player",
						10,
						nil,
						nil,
						nil,
						nil
					}
				}
			},
			Rewards = {
				{ "AddSword", "Ghostwalker" },
				{ "RookieRouletteSpin", 3 }
			}
		}
	},
	GetRewardData = function(_, list)
		local v2 = list[1]
		local v3 = list[2]
		local v4 = v[v2]

		if not v4 then
			return
		end

		local items = v4.Items

		if items then
			return items[v3]
		end

		return v4
	end
}