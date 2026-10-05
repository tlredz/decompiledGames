local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Shared.SeasonPassData)
local v4 = require3(ReplicatedStorage2.Shared.InfiniteBattlepass.InfiniteBattlepassData)
local v5 = require3(ReplicatedStorage2.Shared.LTM)
require3(ReplicatedStorage2.Shared.SpecialTrainingEvent.SpecialTrainingEventData)
local v6 = require3(ReplicatedStorage2.Shared.ThemedQuests.ThemedQuestsData)
local relicItems = require3(ReplicatedStorage2.Shared.PeriodEvent.Relics.SerpentBreakout).RelicItems
local v7 = require3(ReplicatedStorage2.ServerInfo).isTestGame() and 417758512417164 or 1873215711178593
local v8 = require3(script.GetQuestValue)
local v9 = require3(ReplicatedStorage2.Shared.MedalEventInfo)
local currentLTM = v5.getCurrentLTM()
local _ = currentLTM and currentLTM.IsActive()
local Quests = {
	SerpentBreakout = {
		Limited = {
			Amount = 6,
			Quests = {
				{
					Difficulty = 1,
					Category = "Roblox Anniversary",
					DisplayName = "Collect 3 Tix from Knights",
					Currency = "ItemReward",
					Reward = v2.createBadgeReward(v7, "Serpent Breakout Main Badge"),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createSwordReward("Serpentbane"),
					Arguments = {
						key = "SerpentBreakout_CollectTix",
						value = 3
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Collect 75 relics",
					Currency = "XP",
					Reward = 3,
					Arguments = {
						key = "SerpentBreakout_CollectRelic",
						value = 75
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Steal 10 relics from other players",
					Currency = "XP",
					Reward = 3,
					Arguments = {
						key = "SerpentBreakout_StealRelic",
						value = 10
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 24 Serpent Scales",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "SerpentBreakout_CollectRelicItem",
						value = 24,
						conditions = {
							Item = relicItems.Common[1].item.Value
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 18 Serpent Eyes",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "SerpentBreakout_CollectRelicItem",
						value = 18,
						conditions = {
							Item = relicItems.Common[2].item.Value
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 12 Venom Cores",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "SerpentBreakout_CollectRelicItem",
						value = 12,
						conditions = {
							Item = relicItems.Rare[1].item.Value
						}
					}
				}
			}
		},
		Identifier = "SerpentBreakout",
		ReplionPath = "SerpentBreakout",
		ReplionXP = "SerpentBreakout.XP",
		VersionId = 4
	},
	MedalEvent = {
		Limited = {
			Amount = 1,
			Quests = {
				{
					DisplayName = "Win 7 games",
					Currency = "ItemReward",
					Reward = v9.Rewards.Primary,
					SecondCurrency = "ItemReward",
					SecondReward = v9.Rewards.Secondary,
					Arguments = {
						key = "RoundWon",
						value = 7
					}
				}
			}
		},
		Identifier = "MedalEvent",
		ReplionPath = "MedalEvent.Quests",
		ReplionXP = "MedalEvent.Quests.XP",
		VersionId = 1
	},
	SummerGames = {
		Daily = {
			Amount = 3,
			Quests = {
				{
					Difficulty = 1,
					DisplayName = "Eliminate 10 players",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "KillPlayer",
						value = 10
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Block the ball 75 times",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "ParryBall",
						value = 75
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Play a game on the Event Map",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "PlayRound",
						value = 1,
						conditions = {
							Map = "RobloxSummerEventMap"
						}
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Collect 25 Tennis Balls",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "PickupTennisBalls",
						value = 25
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Play in the AFK world for 15 minutes",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "PlayTime",
						value = 15,
						conditions = {
							Mode = "AFK"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 3 games",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 5 games in Duel servers",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "Win_Duel",
						value = 5
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 30,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Collect 300 Tennis Balls",
					Currency = "XP",
					Reward = 30,
					Arguments = {
						key = "PickupTennisBalls",
						value = 300
					}
				}
			}
		},
		Limited = {
			Amount = 3,
			Quests = {
				{
					Tier = 1,
					DisplayName = "Eliminate 5 players",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "KillPlayer",
						value = 5
					}
				},
				{
					Tier = 2,
					DisplayName = "Win once on the Summer Event map",
					Currency = "XP",
					Reward = 20,
					Arguments = {
						key = "RoundWon",
						value = 1,
						conditions = {
							Map = "RobloxSummerEventMap"
						}
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat the boss once",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "DefeatSummerEventBoss",
						value = 1
					}
				}
			}
		},
		Identifier = "SummerGames",
		ReplionPath = "SummerGamesEvent.Quests",
		ReplionXP = "SummerGamesEvent.Quests.XP",
		VersionId = 1
	},
	SinglePassEvent = {
		Limited = {
			Amount = 8,
			Quests = {
				{
					DisplayName = "25 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createSwordReward("Frostbite Sword"),
					Arguments = {
						key = "KillPlayer",
						value = 25
					}
				},
				{
					DisplayName = "100 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createEmoteReward("Freezing"),
					Arguments = {
						key = "KillPlayer",
						value = 100
					}
				},
				{
					DisplayName = "250 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createSwordReward("Polar Edge"),
					Arguments = {
						key = "KillPlayer",
						value = 250
					}
				},
				{
					DisplayName = "500 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createGachaSpinsReward(1),
					Arguments = {
						key = "KillPlayer",
						value = 500
					}
				},
				{
					DisplayName = "750 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createExplosionReward("Ice Blast"),
					Arguments = {
						key = "KillPlayer",
						value = 750
					}
				},
				{
					DisplayName = "1000 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createEmoteReward("Winter Wizard"),
					Arguments = {
						key = "KillPlayer",
						value = 1000
					}
				},
				{
					DisplayName = "1500 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createSwordReward("Winter Warrior"),
					Arguments = {
						key = "KillPlayer",
						value = 1500
					}
				},
				{
					DisplayName = "2000 Eliminations",
					Currency = "ItemReward",
					Reward = v2.createEmoteReward("Winter Warrior Emote"),
					Arguments = {
						key = "KillPlayer",
						value = 2000
					}
				}
			}
		},
		Identifier = "SinglePassEvent",
		ReplionPath = "SinglePass.Quests",
		ReplionXP = "SinglePass.Quests.XP",
		VersionId = 2
	},
	SummerClashEvent = {
		Daily = {
			Amount = 6,
			Quests = {
				{
					Difficulty = 1,
					DisplayName = "Eliminate 10 players",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(50),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(25),
					Arguments = {
						key = "KillPlayer",
						value = 10
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Parry the ball 100 times",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(50),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(25),
					Arguments = {
						key = "ParryBall",
						value = 100
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Play 1 game on Kraken Island",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(50),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(25),
					Arguments = {
						key = "PlayRound",
						value = 1,
						conditions = {
							Map = "KrakenIsland"
						}
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Collect 25 Starfish",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(50),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(25),
					Arguments = {
						key = "CollectCoinDrops",
						value = 25
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 1 game on Kraken Island",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(100),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(50),
					Arguments = {
						key = "RoundWon",
						value = 1,
						conditions = {
							Map = "KrakenIsland"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Play in the AFK world for 15 minutes",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(100),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(50),
					Arguments = {
						key = "PlayTime",
						value = 15,
						conditions = {
							Mode = "AFK"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 3 games",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(100),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(50),
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 5 games in Duel servers",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(100),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(50),
					Arguments = {
						key = "Win_Duel",
						value = 5
					}
				},
				{
					DisplayName = "Win 2 games in a row",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(200),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(100),
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Collect 300 Starfish",
					Currency = "ItemReward",
					Reward = v2.createOctoCoinsReward(200),
					SecondCurrency = "ItemReward",
					SecondReward = v2.createStarfishReward(100),
					Arguments = {
						key = "CollectCoinDrops",
						value = 300
					}
				}
			}
		},
		Identifier = "SummerClashEvent",
		ReplionPath = "ClashEventData.Quests",
		ReplionXP = "ClashEventData.Quests.XP",
		VersionId = 1
	},
	ClassicRoblox = {
		Limited = {
			Amount = 27,
			Quests = {
				{
					Tier = 1,
					DisplayName = "Play 5 games",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "PlayRound",
						value = 5
					}
				},
				{
					Tier = 1,
					DisplayName = "Spin the daily wheel",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "SpinWheel",
						value = 1
					}
				},
				{
					Tier = 1,
					DisplayName = "Play for 10 minutes",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "PlayTime",
						value = 10
					}
				},
				{
					Tier = 2,
					DisplayName = "Block the ball %d times",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "ParryBall",
						value = v8("TheClassic", "Tier2-ParryBall")
					}
				},
				{
					Tier = 2,
					DisplayName = "Eliminate 5 players",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "KillPlayer",
						value = 5
					}
				},
				{
					Tier = 2,
					DisplayName = "Spin the Hacker Crate",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "LTMCrate",
						value = 1
					}
				},
				{
					Tier = 3,
					DisplayName = "Use Dash 5 times",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "UseAbility",
						value = 5,
						conditions = {
							ConsumedAbility = "Dash"
						}
					}
				},
				{
					Tier = 3,
					DisplayName = "Win 1 game",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat the boss",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "BeatBoss",
						value = 1
					}
				},
				{
					Tier = 4,
					DisplayName = "Open 3 Normal Sword Crates",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "OpenCrate",
						value = 3,
						conditions = {
							ConsumedCrate = "NormalSwordCrate"
						}
					}
				},
				{
					Tier = 4,
					DisplayName = "Play 10 games",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "PlayRound",
						value = 10
					}
				},
				{
					Tier = 4,
					DisplayName = "Win 2 games",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "RoundWon",
						value = 2
					}
				},
				{
					Tier = 5,
					DisplayName = "Block the ball %d times",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "ParryBall",
						value = v8("TheClassic", "Tier5-ParryBall")
					}
				},
				{
					Tier = 5,
					DisplayName = "Play 10 games",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "PlayRound",
						value = 10
					}
				},
				{
					Tier = 5,
					DisplayName = "Defeat the boss 3 times",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "BeatBoss",
						value = 3
					}
				},
				{
					Tier = 6,
					DisplayName = "Play 5 games",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "PlayRound",
						value = 5
					}
				},
				{
					Tier = 6,
					DisplayName = "Parry the ball 75 times",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "ParryBall",
						value = 75
					}
				},
				{
					Tier = 6,
					DisplayName = "Have a friend join your game",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "FriendLogin",
						value = 1
					}
				},
				{
					Tier = 7,
					DisplayName = "Eliminate 2 enemies in a single match",
					Currency = "XP",
					Reward = 10,
					Arguments = {
						key = "RoundKillCount",
						value = 2
					}
				},
				{
					Tier = 7,
					DisplayName = "Play 5 Ranked matches",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "PlayEntireRankedMatch",
						value = 5
					}
				},
				{
					Tier = 7,
					DisplayName = "Parry the ball 150 times",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "ParryBall",
						value = 150
					}
				},
				{
					Tier = 8,
					DisplayName = "Win 3 games",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Tier = 8,
					DisplayName = "Win a Ranked match",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "WinEntireRankedMatch",
						value = 1
					}
				},
				{
					Tier = 8,
					DisplayName = "Reach level 5 in Dungeons",
					Currency = "XP",
					Reward = 15,
					Arguments = {
						key = "ReachDungeonLevel",
						value = 5
					}
				},
				{
					Tier = 9,
					DisplayName = "Eliminate 3 players in Ranked mode",
					Currency = "XP",
					Reward = 20,
					Arguments = {
						key = "KillPlayer",
						value = 3,
						conditions = {
							Mode = "Ranked"
						}
					}
				},
				{
					Tier = 9,
					DisplayName = "Play for 30 minutes",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "PlayTime",
						value = 30
					}
				},
				{
					Tier = 9,
					DisplayName = "Join a clan or create your own clan",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "JoinClan",
						value = 1
					}
				}
			}
		},
		Identifier = "ClassicRoblox",
		ReplionPath = "ClassicRobloxEvent.Quests",
		ReplionXP = "ClassicRobloxEvent.Quests.XP",
		VersionId = 1
	},
	WelcomeBack = {
		Daily = {
			Amount = 4,
			Quests = {
				{
					OrderedDay = 1,
					DisplayName = "[Day 1] Sign into Blade Ball",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(50),
					Arguments = {
						key = "BladeBallSignIn",
						value = 1
					}
				},
				{
					OrderedDay = 1,
					DisplayName = "Play a game",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(50),
					Arguments = {
						key = "PlayRound",
						value = 1
					}
				},
				{
					OrderedDay = 1,
					DisplayName = "Spin the daily wheel",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(50),
					Arguments = {
						key = "SpinWheel",
						value = 1
					}
				},
				{
					OrderedDay = 1,
					DisplayName = "Play a Ranked match",
					Currency = "XP",
					Reward = 25,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(75),
					Arguments = {
						key = "PlayEntireRankedMatch",
						value = 1
					}
				},
				{
					OrderedDay = 2,
					DisplayName = "[Day 2] Sign into Blade Ball",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(75),
					Arguments = {
						key = "BladeBallSignIn",
						value = 1
					}
				},
				{
					OrderedDay = 2,
					DisplayName = "Play 3 games",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(75),
					Arguments = {
						key = "PlayRound",
						value = 3
					}
				},
				{
					OrderedDay = 2,
					DisplayName = "Get 3 eliminations",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(75),
					Arguments = {
						key = "KillPlayer",
						value = 3
					}
				},
				{
					OrderedDay = 2,
					DisplayName = "Win a game",
					Currency = "XP",
					Reward = 25,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(100),
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					OrderedDay = 3,
					DisplayName = "[Day 3] Sign into Blade Ball",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(100),
					Arguments = {
						key = "BladeBallSignIn",
						value = 1
					}
				},
				{
					OrderedDay = 3,
					DisplayName = "Play 5 games",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(100),
					Arguments = {
						key = "PlayRound",
						value = 5
					}
				},
				{
					OrderedDay = 3,
					DisplayName = "Get 5 eliminations",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(100),
					Arguments = {
						key = "KillPlayer",
						value = 5
					}
				},
				{
					OrderedDay = 3,
					DisplayName = "Win a game",
					Currency = "XP",
					Reward = 25,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(125),
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					OrderedDay = 4,
					DisplayName = "[Day 4] Sign into Blade Ball",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(125),
					Arguments = {
						key = "BladeBallSignIn",
						value = 1
					}
				},
				{
					OrderedDay = 4,
					DisplayName = "Play 7 games",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(125),
					Arguments = {
						key = "PlayRound",
						value = 7
					}
				},
				{
					OrderedDay = 4,
					DisplayName = "Get 7 eliminations",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(125),
					Arguments = {
						key = "KillPlayer",
						value = 7
					}
				},
				{
					OrderedDay = 4,
					DisplayName = "Win 2 games",
					Currency = "XP",
					Reward = 25,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(150),
					Arguments = {
						key = "RoundWon",
						value = 2
					}
				},
				{
					OrderedDay = 5,
					DisplayName = "[Day 5] Sign into Blade Ball",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(150),
					Arguments = {
						key = "BladeBallSignIn",
						value = 1
					}
				},
				{
					OrderedDay = 5,
					DisplayName = "Play 10 games",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(150),
					Arguments = {
						key = "PlayRound",
						value = 10
					}
				},
				{
					OrderedDay = 5,
					DisplayName = "Get 10 eliminations",
					Currency = "XP",
					Reward = 15,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(150),
					Arguments = {
						key = "KillPlayer",
						value = 10
					}
				},
				{
					OrderedDay = 5,
					DisplayName = "Win 2 games",
					Currency = "XP",
					Reward = 25,
					SecondCurrency = "ItemReward",
					SecondReward = v2.createReturnCoinsReward(200),
					Arguments = {
						key = "RoundWon",
						value = 2
					}
				}
			}
		},
		Identifier = "WelcomeBack",
		ReplionPath = "WelcomeBackEvent.Quests",
		ReplionXP = "WelcomeBackEvent.Quests.XP",
		VersionId = 1
	},
	Battlepass = {
		Daily = {
			Amount = 5,
			Quests = {
				{
					DisplayName = "Use Dash 30 times",
					Currency = "XP",
					Reward = 30,
					Arguments = {
						key = "UseAbility",
						value = 30,
						conditions = {
							ConsumedAbility = "Dash"
						}
					}
				},
				{
					DisplayName = "Win 2 games",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundWon",
						value = 2
					}
				},
				{
					DisplayName = "Play 10 Ranked matches",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "PlayEntireRankedMatch",
						value = 10
					}
				},
				{
					DisplayName = "Score top 5 in any mode, one time",
					Currency = "XP",
					Reward = 60,
					Arguments = {
						key = "Top5Alive",
						value = 1
					}
				},
				{
					DisplayName = "Lose 5 times in any mode",
					Currency = "XP",
					Reward = 60,
					Arguments = {
						key = "CharacterDied",
						value = 5
					}
				},
				{
					Premium = true,
					DisplayName = "Play for 60 minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "PlayTime",
						value = 60
					}
				},
				{
					DisplayName = "Play for 30 minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "PlayTime",
						value = 30
					}
				},
				{
					DisplayName = "Double jump 100 times",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "DoubleJump",
						value = 100
					}
				},
				{
					DisplayName = "Win a Ranked match",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "WinEntireRankedMatch",
						value = 1
					}
				},
				{
					DisplayName = "Eliminate 25 people",
					Currency = "XP",
					Reward = 75,
					Arguments = {
						key = "KillPlayer",
						value = 25
					}
				}
			}
		},
		Weekly = {
			Amount = 20,
			Quests = {
				{
					DisplayName = "Survive for 200 total minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "MatchTime",
						value = 200
					}
				},
				{
					DisplayName = "Survive for 500 total minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "MatchTime",
						value = 500
					}
				},
				{
					DisplayName = "Play with 10 different swords",
					Currency = "XP",
					Reward = 75,
					Arguments = {
						key = "UseSwordInMatch",
						value = 10
					}
				},
				{
					DisplayName = "Eliminate 2 enemies in a single match",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "RoundKillCount",
						value = 2
					}
				},
				{
					DisplayName = "Eliminate 4 enemies in a single match",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundKillCount",
						value = 4
					}
				},
				{
					DisplayName = "Eliminate 6 enemies in a single match",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "RoundKillCount",
						value = 6
					}
				},
				{
					DisplayName = "Eliminate 1,500 players",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "KillPlayer",
						value = 1500
					}
				},
				{
					DisplayName = "Eliminate 500 players in Ranked mode",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "KillPlayer",
						value = 500,
						conditions = {
							Mode = "Ranked"
						}
					}
				},
				{
					DisplayName = "Double jump 800 times",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "DoubleJump",
						value = 800
					}
				},
				{
					DisplayName = "Play for 240 minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "PlayTime",
						value = 240
					}
				},
				{
					DisplayName = "Play for 360 minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "PlayTime",
						value = 360
					}
				},
				{
					DisplayName = "Play for 600 minutes",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "PlayTime",
						value = 600
					}
				},
				{
					DisplayName = "Play for 960 minutes",
					Currency = "XP",
					Reward = 400,
					Arguments = {
						key = "PlayTime",
						value = 960
					}
				},
				{
					DisplayName = "Play for 1,200 minutes",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "PlayTime",
						value = 1200
					}
				},
				{
					DisplayName = "Play for 1,800 minutes",
					Currency = "XP",
					Reward = 600,
					Arguments = {
						key = "PlayTime",
						value = 1800
					}
				},
				{
					DisplayName = "Play for 2,160 minutes",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "PlayTime",
						value = 2160
					}
				},
				{
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					DisplayName = "Parry the ball 1,000 times",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "ParryBall",
						value = 1000
					}
				},
				{
					DisplayName = "Gift a GamePass or any Robux item",
					Currency = "XP",
					Reward = 1000,
					Arguments = {
						key = "GiftRobuxItem",
						value = 1
					}
				},
				{
					Premium = true,
					DisplayName = "Win 30 matches in Normal Mode",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "RoundWon",
						value = 30,
						conditions = {
							Mode = "Normal"
						}
					}
				},
				{
					DisplayName = "Win 300 games",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "RoundWon",
						value = 300
					}
				},
				{
					DisplayName = "Claim the reward chest from normal daily quests, 10 times",
					Currency = "XP",
					Reward = 600,
					Arguments = {
						key = "DailyRewardChest",
						value = 10
					}
				},
				{
					Premium = true,
					DisplayName = "Use Infinity 50 times",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "UseAbility",
						value = 50,
						conditions = {
							ConsumedAbility = "Infinity"
						}
					}
				},
				{
					Premium = true,
					DisplayName = "Use Event Horizon 50 times",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "UseAbility",
						value = 50,
						conditions = {
							ConsumedAbility = "Event Horizon"
						}
					}
				},
				{
					Premium = true,
					DisplayName = "Use Singularity 50 times",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "UseAbility",
						value = 50,
						conditions = {
							ConsumedAbility = "Singularity"
						}
					}
				},
				{
					Premium = true,
					DisplayName = "Use Slashes of Fury 50 times",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "UseAbility",
						value = 50,
						conditions = {
							ConsumedAbility = "Slashes of Fury"
						}
					}
				},
				{
					DisplayName = "Open 50 Normal Sword Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 50,
						conditions = {
							ConsumedCrate = "NormalSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 50 Normal Explosion Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 50,
						conditions = {
							ConsumedCrate = "NormalExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Open 10 Premium Sword Crates",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "OpenCrate",
						value = 10,
						conditions = {
							ConsumedCrate = "PremiumSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 10 Premium Explosion Crates",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "OpenCrate",
						value = 10,
						conditions = {
							ConsumedCrate = "PremiumExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Open 3 Premium Sword Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 3,
						conditions = {
							ConsumedCrate = "PremiumSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 3 Premium Explosion Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 3,
						conditions = {
							ConsumedCrate = "PremiumExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Add a new friend from within Blade Ball",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "FriendAdded",
						value = 1
					}
				},
				{
					DisplayName = "Add 5 friends from within Blade Ball",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "FriendAdded",
						value = 5
					}
				},
				{
					DisplayName = "Reach Diamond elo or above in Ranked mode",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "AchieveRankedElo",
						value = 6000
					}
				},
				{
					DisplayName = "Move 50,000 studs",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "StudsMoved",
						value = 50000
					}
				},
				{
					Premium = true,
					DisplayName = `Eliminate 50 players with the {v3.CurrentSeasonData.Rewards[1][25].Premium.Value} sword!`,
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "KillPlayer",
						value = 50,
						conditions = {
							EquippedSword = v3.CurrentSeasonData.Rewards[1][25].Premium.Value
						}
					}
				}
			}
		},
		Limited = {
			Amount = 0,
			Quests = {}
		},
		Identifier = "Battlepass",
		ReplionPath = "BattlepassSeason",
		ReplionXP = "BattlepassSeason.XP",
		VersionId = v3.CurrentSeason + 4
	},
	SpecialTrainingEvent = {
		Limited = {
			Amount = 9,
			Quests = {
				{
					Difficulty = 1,
					DisplayName = "Defeat 80 Aliens during Galactic Collapse",
					Currency = "XP",
					Reward = 3,
					Arguments = {
						key = "ST_EliminateNPC",
						value = 80
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Collect 75 relics",
					Currency = "XP",
					Reward = 3,
					Arguments = {
						key = "ST_CollectRelic",
						value = 75
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Steal 10 relics from other players",
					Currency = "XP",
					Reward = 3,
					Arguments = {
						key = "ST_StealRelic",
						value = 10
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 24 Pulsar Fragments",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 24,
						conditions = {
							Item = "PulsarFragments"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 18 Rift Tendrils",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 18,
						conditions = {
							Item = "RiftTendrils"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Collect 12 Singularity Tears",
					Currency = "XP",
					Reward = 5,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 12,
						conditions = {
							Item = "SingularityTears"
						}
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Recover the \"Alienated Portal\" Explosion",
					Currency = "XP",
					Reward = 8,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 1,
						conditions = {
							Item = "Alienated Portal"
						}
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Recover the \"Alien's Slicer\" Sword",
					Currency = "XP",
					Reward = 8,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 1,
						conditions = {
							Item = "Alien's Slicer"
						}
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Recover the \"Alien Spiderblade\" Sword",
					Currency = "XP",
					Reward = 8,
					Arguments = {
						key = "ST_CollectRelicItem",
						value = 1,
						conditions = {
							Item = "Alien Spiderblade"
						}
					}
				}
			}
		},
		Identifier = "SpecialTrainingEvent",
		ReplionPath = "SpecialTrainingEvent",
		ReplionXP = "SpecialTrainingEvent.XP",
		VersionId = 6
	},
	ThanksgivingEvent = {
		Daily = {
			Amount = 4,
			Quests = {
				{
					Difficulty = 1,
					DisplayName = "Deflect the ball 50 times",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "ParryBall",
						value = 50
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Eliminate 3 players",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "KillPlayer",
						value = 3
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win 1 game",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win a duels match",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "Win_Duel",
						value = 1
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win a dungeon game",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "WinDungeon",
						value = 1
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 3 games",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Buy an item in the trade world",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "BuyItemInTradePlaza",
						value = 1
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Eliminate 5 players using Dash",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "KillPlayer",
						value = 5,
						conditions = {
							EquippedAbility = "Dash"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Survive without deflecting for 20 seconds",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "SurviceWithoutParry",
						value = 20
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Eliminate 2 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 2
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					Tier = 3,
					DisplayName = "Eliminate 5 enemies in a single match",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "RoundKillCount",
						value = 5
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Eliminate a player within 10 seconds of spawning",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "EliminateAfterSpawn",
						value = 1
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Eliminate 3 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 3
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Find and eliminate 3 turkeys ",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "EliminateTurkey",
						value = 3
					}
				}
			}
		},
		Limited = {
			Amount = 0,
			Quests = {}
		},
		Identifier = "ThanksgivingEvent",
		ReplionPath = "ThanksgivingEvent.Quests",
		ReplionXP = "ThanksgivingEvent.TurkeyCoins",
		VersionId = 1
	},
	CNYEvent = {
		Daily = {
			Amount = 4,
			Quests = {
				{
					Difficulty = 1,
					DisplayName = "Deflect the ball 50 times",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "ParryBall",
						value = 50
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Eliminate 3 players",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "KillPlayer",
						value = 3
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win 1 game",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win a duels match",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "Win_Duel",
						value = 1
					}
				},
				{
					Difficulty = 1,
					DisplayName = "Win a dungeon game",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "WinDungeon",
						value = 1
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Win 3 games",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Buy an item in the trade world",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "BuyItemInTradePlaza",
						value = 1
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Eliminate 5 players using Dash",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "KillPlayer",
						value = 5,
						conditions = {
							EquippedAbility = "Dash"
						}
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Survive without deflecting for 20 seconds",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "SurviceWithoutParry",
						value = 20
					}
				},
				{
					Difficulty = 2,
					DisplayName = "Eliminate 2 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 2
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					Tier = 3,
					DisplayName = "Eliminate 5 enemies in a single match",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "RoundKillCount",
						value = 5
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Eliminate a player within 10 seconds of spawning",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "EliminateAfterSpawn",
						value = 1
					}
				},
				{
					Difficulty = 3,
					DisplayName = "Eliminate 3 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 3
					}
				}
			}
		},
		Limited = {
			Amount = 0,
			Quests = {}
		},
		Identifier = "CNYEvent",
		ReplionPath = "CNYEvent.Quests",
		ReplionXP = "CNYEvent.Lanterns",
		VersionId = 1
	},
	ChristmasEvent = {
		Daily = {
			Amount = 4,
			Quests = {
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Deflect the ball 50 times",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "ParryBall",
						value = 50
					}
				},
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Eliminate 3 players in Santas vs Elves",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "KillPlayer",
						value = 3,
						conditions = {
							GameMode = "SantasVsElves"
						}
					}
				},
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Win 1 game",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "RoundWon",
						value = 1
					}
				},
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Win a duels match",
					Currency = "XP",
					Reward = 25,
					Arguments = {
						key = "Win_Duel",
						value = 1
					}
				},
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Win a dungeon game",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "WinDungeon",
						value = 1
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Win 3 games",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "RoundWon",
						value = 3
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Eliminate 10 players in the 50 Player Winter Royale",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "KillPlayer",
						value = 10,
						conditions = {
							GameMode = "WinterRoyale"
						}
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Buy an item in the trade world",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "BuyItemInTradePlaza",
						value = 1
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Eliminate 5 players using Dash",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "KillPlayer",
						value = 5,
						conditions = {
							EquippedAbility = "Dash"
						}
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Survive without deflecting for 20 seconds",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "SurviceWithoutParry",
						value = 20
					}
				},
				{
					Tier = 1,
					Difficulty = 2,
					DisplayName = "Eliminate 2 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 2
					}
				},
				{
					Tier = 1,
					Difficulty = 3,
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					Tier = 1,
					Difficulty = 3,
					DisplayName = "Eliminate 5 enemies in a single match",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundKillCount",
						value = 5
					}
				},
				{
					Tier = 1,
					Difficulty = 3,
					DisplayName = "Eliminate a player within 10 seconds of spawning",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "EliminateAfterSpawn",
						value = 1
					}
				},
				{
					Tier = 1,
					Difficulty = 3,
					DisplayName = "Eliminate 3 players within 10 seconds of each elimination",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "EliminateWithin10Seconds",
						value = 3
					}
				},
				{
					Tier = 1,
					Difficulty = 3,
					DisplayName = "Find and eliminate 3 Evil Elves",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "EliminateElf",
						value = 3
					}
				}
			}
		},
		Limited = {
			Amount = 2,
			Quests = {
				{
					Tier = 1,
					Difficulty = 1,
					DisplayName = "Win 1 game of Santas vs Elves",
					Currency = "ItemReward",
					Reward = v2.createBadgeReward(465575225079118, "Standard Token", "rbxassetid://128198639021666"),
					Arguments = {
						key = "RoundWon",
						value = 1,
						conditions = {
							GameMode = "SantasVsElves"
						}
					}
				},
				{
					Tier = 2,
					Difficulty = 2,
					DisplayName = "Place top 5 in the 50 Player Winter Royale 3 times",
					Currency = "ItemReward",
					Reward = v2.createBadgeReward(4006110777959809, "Elite Token", "rbxassetid://102872841308688"),
					Arguments = {
						key = "Top5Alive",
						value = 3,
						conditions = {
							GameMode = "WinterRoyale"
						}
					}
				}
			}
		},
		Identifier = "ChristmasEvent",
		ReplionPath = "ChristmasEvent.Quests",
		ReplionXP = "ChristmasEvent.CandyCanes",
		VersionId = 1
	},
	LegoEvent = {
		Limited = {
			Amount = 11,
			Quests = {
				{
					Tier = 1,
					DisplayName = "Defeat 25 players",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "KillPlayer",
						value = 25
					}
				},
				{
					Tier = 1,
					DisplayName = "Defeat 5 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "KillMinifigure",
						value = 5
					}
				},
				{
					Tier = 1,
					IgnoreQuestTier = true,
					DisplayName = "Play 7 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "DailyLogin",
						value = 6
					}
				},
				{
					Tier = 1,
					DisplayName = "Get 25 defeats with a LEGO® cosmetic equipped",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "KillPlayerWithLEGO",
						value = 25
					}
				},
				{
					Tier = 2,
					DisplayName = "Defeat 50 players",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "KillPlayer",
						value = 50
					}
				},
				{
					Tier = 2,
					DisplayName = "Defeat 10 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "KillMinifigure",
						value = 10
					}
				},
				{
					Tier = 2,
					IgnoreQuestTier = true,
					DisplayName = "Play 14 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "DailyLogin",
						value = 13
					}
				},
				{
					Tier = 2,
					DisplayName = "Get 50 defeats with a LEGO® cosmetic equipped",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "KillPlayerWithLEGO",
						value = 50
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat 100 players",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "KillPlayer",
						value = 100
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat 20 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "KillMinifigure",
						value = 20
					}
				},
				{
					Tier = 3,
					IgnoreQuestTier = true,
					DisplayName = "Play 25 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "DailyLogin",
						value = 24
					}
				}
			}
		},
		Identifier = "LegoEvent",
		ReplionPath = "LegoEvent.Quests",
		ReplionXP = "LegoEvent.Quests.XP",
		QuestTierPath = "LegoEvent.QuestTiers",
		VersionId = 1
	},
	LegoEvent2 = {
		Limited = {
			Amount = 12,
			Quests = {
				{
					Tier = 1,
					DisplayName = "Defeat 100 players",
					Currency = "None",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "KillPlayer",
						value = 100
					}
				},
				{
					Tier = 1,
					DisplayName = "Defeat 25 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "KillMinifigure",
						value = 25
					}
				},
				{
					Tier = 1,
					IgnoreQuestTier = true,
					DisplayName = "Play 7 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(0),
					Arguments = {
						key = "DailyLogin",
						value = 1
					}
				},
				{
					Tier = 2,
					DisplayName = "Defeat 250 players",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "KillPlayer",
						value = 250
					}
				},
				{
					Tier = 2,
					DisplayName = "Defeat 50 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "KillMinifigure",
						value = 50
					}
				},
				{
					Tier = 2,
					IgnoreQuestTier = true,
					DisplayName = "Play 14 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(0),
					Arguments = {
						key = "DailyLogin",
						value = 1
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat 500 players",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "KillPlayer",
						value = 500
					}
				},
				{
					Tier = 3,
					DisplayName = "Defeat 100 Minifigures",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "KillMinifigure",
						value = 100
					}
				},
				{
					Tier = 3,
					IgnoreQuestTier = true,
					DisplayName = "Play 25 days during the event",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(0),
					Arguments = {
						key = "DailyLogin",
						value = 1
					}
				},
				{
					Tier = 1,
					DisplayName = "Play on the Ninjago Wetlands Map",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(100),
					Arguments = {
						key = "PlayRound",
						value = 1,
						conditions = {
							Map = "LEGONinjagoWetlands"
						}
					}
				},
				{
					Tier = 2,
					DisplayName = "Play on the Ninjago Temple Map",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(250),
					Arguments = {
						key = "PlayRound",
						value = 1,
						conditions = {
							Map = "LEGONinjagoTemple"
						}
					}
				},
				{
					Tier = 3,
					DisplayName = "Play on the Ninjago Swamp Map",
					Currency = "ItemReward",
					Reward = v2.createLegoBricksReward(500),
					Arguments = {
						key = "PlayRound",
						value = 1,
						conditions = {
							Map = "LEGONinjagoSwamp"
						}
					}
				}
			}
		},
		Identifier = "LegoEvent2",
		ReplionPath = "LegoEvent2.Quests",
		ReplionXP = "LegoEvent2.Quests.XP",
		QuestTierPath = "LegoEvent2.QuestTiers",
		VersionId = 2
	},
	ThemedQuests = {
		Limited = {
			Amount = 3,
			Quests = {
				{
					DisplayName = "Eliminate 100 players",
					Currency = "None",
					Reward = 0,
					Arguments = {
						key = "KillPlayer",
						value = 100
					}
				},
				{
					DisplayName = "Play 3 Ranked Games",
					Currency = "None",
					Reward = 0,
					Arguments = {
						key = "PlayEntireRankedMatch",
						value = 3
					}
				},
				{
					Tier = 1,
					DisplayName = "Win 5 Games",
					Currency = "None",
					Reward = 0,
					Arguments = {
						key = "RoundWon",
						value = 5
					}
				}
			}
		},
		Identifier = "ThemedQuests",
		ReplionPath = "ThemedQuests.Quests",
		ReplionXP = "ThemedQuests.Quests.XP",
		QuestTierPath = "ThemedQuests.QuestTiers",
		VersionId = v6.Version
	},
	InfiniteBattlepass = {
		Daily = {
			Amount = 5,
			Quests = {
				{
					DisplayName = "Use Dash 30 times",
					Currency = "XP",
					Reward = 30,
					Arguments = {
						key = "UseAbility",
						value = 30,
						conditions = {
							ConsumedAbility = "Dash"
						}
					}
				},
				{
					DisplayName = "Win 2 games",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundWon",
						value = 2
					}
				},
				{
					DisplayName = "Play 10 Ranked matches",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "PlayEntireRankedMatch",
						value = 10
					}
				},
				{
					DisplayName = "Score top 5 in any mode, one time",
					Currency = "XP",
					Reward = 60,
					Arguments = {
						key = "Top5Alive",
						value = 1
					}
				},
				{
					DisplayName = "Lose 5 times in any mode",
					Currency = "XP",
					Reward = 60,
					Arguments = {
						key = "CharacterDied",
						value = 5
					}
				},
				{
					Premium = true,
					DisplayName = "Play for 60 minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "PlayTime",
						value = 60
					}
				},
				{
					DisplayName = "Play for 30 minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "PlayTime",
						value = 30
					}
				},
				{
					DisplayName = "Double jump 100 times",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "DoubleJump",
						value = 100
					}
				},
				{
					DisplayName = "Win a Ranked match",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "WinEntireRankedMatch",
						value = 1
					}
				},
				{
					DisplayName = "Eliminate 25 people",
					Currency = "XP",
					Reward = 75,
					Arguments = {
						key = "KillPlayer",
						value = 25
					}
				}
			}
		},
		Weekly = {
			Amount = 20,
			Quests = {
				{
					DisplayName = "Survive for 200 total minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "MatchTime",
						value = 200
					}
				},
				{
					DisplayName = "Survive for 500 total minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "MatchTime",
						value = 500
					}
				},
				{
					DisplayName = "Play with 10 different swords",
					Currency = "XP",
					Reward = 75,
					Arguments = {
						key = "UseSwordInMatch",
						value = 10
					}
				},
				{
					DisplayName = "Eliminate 2 enemies in a single match",
					Currency = "XP",
					Reward = 50,
					Arguments = {
						key = "RoundKillCount",
						value = 2
					}
				},
				{
					DisplayName = "Eliminate 4 enemies in a single match",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "RoundKillCount",
						value = 4
					}
				},
				{
					DisplayName = "Eliminate 6 enemies in a single match",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "RoundKillCount",
						value = 6
					}
				},
				{
					DisplayName = "Eliminate 1,500 players",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "KillPlayer",
						value = 1500
					}
				},
				{
					DisplayName = "Eliminate 500 players in Ranked mode",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "KillPlayer",
						value = 500,
						conditions = {
							Mode = "Ranked"
						}
					}
				},
				{
					DisplayName = "Double jump 800 times",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "DoubleJump",
						value = 800
					}
				},
				{
					DisplayName = "Play for 240 minutes",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "PlayTime",
						value = 240
					}
				},
				{
					DisplayName = "Play for 360 minutes",
					Currency = "XP",
					Reward = 200,
					Arguments = {
						key = "PlayTime",
						value = 360
					}
				},
				{
					DisplayName = "Play for 600 minutes",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "PlayTime",
						value = 600
					}
				},
				{
					DisplayName = "Play for 960 minutes",
					Currency = "XP",
					Reward = 400,
					Arguments = {
						key = "PlayTime",
						value = 960
					}
				},
				{
					DisplayName = "Play for 1,200 minutes",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "PlayTime",
						value = 1200
					}
				},
				{
					DisplayName = "Play for 1,800 minutes",
					Currency = "XP",
					Reward = 600,
					Arguments = {
						key = "PlayTime",
						value = 1800
					}
				},
				{
					DisplayName = "Play for 2,160 minutes",
					Currency = "XP",
					Reward = 750,
					Arguments = {
						key = "PlayTime",
						value = 2160
					}
				},
				{
					DisplayName = "Win 2 games in a row",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "WinStreak",
						value = 2
					}
				},
				{
					DisplayName = "Parry the ball 1,000 times",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "ParryBall",
						value = 1000
					}
				},
				{
					DisplayName = "Gift a GamePass or any Robux item",
					Currency = "XP",
					Reward = 1000,
					Arguments = {
						key = "GiftRobuxItem",
						value = 1
					}
				},
				{
					Premium = true,
					DisplayName = "Win 30 matches in Normal Mode",
					Currency = "XP",
					Reward = 800,
					Arguments = {
						key = "RoundWon",
						value = 30,
						conditions = {
							Mode = "Normal"
						}
					}
				},
				{
					DisplayName = "Win 300 games",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "RoundWon",
						value = 300
					}
				},
				{
					DisplayName = "Claim the reward chest from normal daily quests, 10 times",
					Currency = "XP",
					Reward = 600,
					Arguments = {
						key = "DailyRewardChest",
						value = 10
					}
				},
				{
					DisplayName = "Open 50 Normal Sword Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 50,
						conditions = {
							ConsumedCrate = "NormalSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 50 Normal Explosion Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 50,
						conditions = {
							ConsumedCrate = "NormalExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Open 10 Premium Sword Crates",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "OpenCrate",
						value = 10,
						conditions = {
							ConsumedCrate = "PremiumSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 10 Premium Explosion Crates",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "OpenCrate",
						value = 10,
						conditions = {
							ConsumedCrate = "PremiumExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Open 3 Premium Sword Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 3,
						conditions = {
							ConsumedCrate = "PremiumSwordCrate"
						}
					}
				},
				{
					DisplayName = "Open 3 Premium Explosion Crates",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "OpenCrate",
						value = 3,
						conditions = {
							ConsumedCrate = "PremiumExplosionCrate"
						}
					}
				},
				{
					DisplayName = "Add a new friend from within Blade Ball",
					Currency = "XP",
					Reward = 100,
					Arguments = {
						key = "FriendAdded",
						value = 1
					}
				},
				{
					DisplayName = "Add 5 friends from within Blade Ball",
					Currency = "XP",
					Reward = 250,
					Arguments = {
						key = "FriendAdded",
						value = 5
					}
				},
				{
					DisplayName = "Reach Diamond elo or above in Ranked mode",
					Currency = "XP",
					Reward = 500,
					Arguments = {
						key = "AchieveRankedElo",
						value = 6000
					}
				},
				{
					DisplayName = "Move 50,000 studs",
					Currency = "XP",
					Reward = 300,
					Arguments = {
						key = "StudsMoved",
						value = 50000
					}
				}
			}
		},
		Limited = {
			Amount = 0,
			Quests = {}
		},
		Identifier = "InfiniteBattlepass",
		ReplionPath = "InfiniteBattlepass.Quests",
		ReplionXP = "InfiniteBattlepass.Quests.XP",
		VersionId = v4.Season
	}
}

if Quests.Battlepass.Weekly then
	Quests.Battlepass.Weekly.Amount = #Quests.Battlepass.Weekly.Quests
end

if Quests.InfiniteBattlepass.Weekly then
	Quests.InfiniteBattlepass.Weekly.Amount = #Quests.InfiniteBattlepass.Weekly.Quests
end

if RunService:IsClient() then
	task.spawn(function()
		local v10 = v.Client:WaitReplion("Data")

		if not v10 then
			return
		end

		for _, v11 in Quests do
			for _, v12 in ipairs({ "Daily", "Weekly", "Limited" }) do
				local v13 = v11[v12]

				if not v13 then
					continue
				end

				for _, quest in ipairs(v13.Quests) do
					if quest.__UPDATED then
						continue
					end

					local value = quest.Arguments.value

					if typeof(value) ~= "function" then
						continue
					end

					local v14 = value(v10)
					local formatted = quest.DisplayName:format(v14)

					if v14 == 1 and formatted:sub(#formatted, #formatted) == "s" then
						formatted = formatted:sub(1, #formatted - 1)
					end

					quest.DisplayName = formatted
					quest.__UPDATED = true
				end
			end
		end
	end)
end

return Quests