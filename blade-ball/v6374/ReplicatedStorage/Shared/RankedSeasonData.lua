local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local bindableEvent = Instance.new("BindableEvent")

local function sword(sword2: string, icon: string)
	return {
		Sword = sword2,
		Icon = icon
	}
end

local function ability(ability2: string, icon: string)
	return {
		Ability = ability2,
		Icon = icon
	}
end

local function randomAbility(randomAbilities, icon: string)
	return {
		RandomAbilities = randomAbilities,
		Icon = icon
	}
end

local RankedSeasonData = {
	Seasons = {
		Normal = {
			{
				StartTime = DateTime.fromUniversalTime(2023, 10, 1, 1),
				EndTime = DateTime.fromUniversalTime(2023, 11, 11, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2023, 11, 11, 17),
				EndTime = DateTime.fromUniversalTime(2023, 12, 26, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2023, 12, 26, 17),
				EndTime = DateTime.fromUniversalTime(2024, 1, 27, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 1, 27, 17),
				EndTime = DateTime.fromUniversalTime(2024, 3, 13, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 3, 13, 17),
				EndTime = DateTime.fromUniversalTime(2024, 5, 1, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 5, 1, 17),
				EndTime = DateTime.fromUniversalTime(2024, 6, 22, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 6, 22, 18),
				EndTime = DateTime.fromUniversalTime(2024, 8, 21, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 8, 21, 18),
				EndTime = DateTime.fromUniversalTime(2024, 10, 26, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 10, 26, 18),
				EndTime = DateTime.fromUniversalTime(2024, 12, 28, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 12, 28, 18),
				EndTime = DateTime.fromUniversalTime(2025, 2, 22, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 2, 22, 18),
				EndTime = DateTime.fromUniversalTime(2025, 4, 19, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 4, 19, 18),
				EndTime = DateTime.fromUniversalTime(2025, 6, 28, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 6, 28, 18),
				EndTime = DateTime.fromUniversalTime(2025, 8, 23, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 8, 23, 18),
				EndTime = DateTime.fromUniversalTime(2025, 10, 18, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 10, 18, 18),
				EndTime = DateTime.fromUniversalTime(2025, 12, 13, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 12, 13, 18),
				EndTime = DateTime.fromUniversalTime(2026, 2, 7, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 2, 7, 18),
				EndTime = DateTime.fromUniversalTime(2026, 4, 4, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 4, 11, 15),
				EndTime = DateTime.fromUniversalTime(2026, 6, 6, 19)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 7, 4, 15),
				EndTime = DateTime.fromUniversalTime(2026, 8, 1, 21)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 8, 1, 15),
				EndTime = DateTime.fromUniversalTime(2026, 9, 26, 21)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 9, 26, 21),
				EndTime = DateTime.fromUniversalTime(2026, 10, 24, 21)
			}
		},
		NoAbility = {
			{
				StartTime = DateTime.fromUniversalTime(2024, 1, 10, 17),
				EndTime = DateTime.fromUniversalTime(2024, 1, 27, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 1, 27, 17),
				EndTime = DateTime.fromUniversalTime(2024, 3, 9, 22)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 3, 9, 22),
				EndTime = DateTime.fromUniversalTime(2024, 5, 1, 17)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 5, 1, 17),
				EndTime = DateTime.fromUniversalTime(2024, 6, 22, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 6, 22, 18),
				EndTime = DateTime.fromUniversalTime(2024, 8, 21, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 8, 21, 18),
				EndTime = DateTime.fromUniversalTime(2024, 10, 26, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 10, 26, 18),
				EndTime = DateTime.fromUniversalTime(2024, 12, 28, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2024, 12, 28, 18),
				EndTime = DateTime.fromUniversalTime(2025, 2, 22, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 2, 22, 18),
				EndTime = DateTime.fromUniversalTime(2025, 4, 19, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 4, 19, 18),
				EndTime = DateTime.fromUniversalTime(2025, 6, 28, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 6, 28, 18),
				EndTime = DateTime.fromUniversalTime(2025, 8, 23, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 8, 23, 18),
				EndTime = DateTime.fromUniversalTime(2025, 10, 18, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 10, 18, 18),
				EndTime = DateTime.fromUniversalTime(2025, 12, 13, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2025, 12, 13, 18),
				EndTime = DateTime.fromUniversalTime(2026, 2, 7, 18)
			},
			{
				StartTime = DateTime.fromUniversalTime(2026, 2, 7, 18),
				EndTime = DateTime.fromUniversalTime(2026, 4, 4, 18)
			}
		}
	},
	Modes = {
		Duo = {
			PlayersPerTeam = 2,
			DisplayName = "2v2 Duos",
			MaxTeams = 8
		},
		FFA = {
			PlayersPerTeam = 1,
			DisplayName = "FFA",
			MaxTeams = 8
		},
		Duel = {
			PlayersPerTeam = 1,
			DisplayName = "1v1s",
			MaxTeams = 2
		}
	},
	RankedTypes = { "Normal", "NoAbility" },
	MaxMatchHistory = 50,
	SeasonChanged = bindableEvent.Event,
	Rewards = {
		Normal = {
			["1"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 1 Top 1 Sword",
							Icon = "rbxassetid://14923456813"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 1 Top 50 Sword",
							Icon = "rbxassetid://14923474986"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 1 Top 200 Sword",
							Icon = "rbxassetid://14923478749"
						}
					}
				}
			},
			["2"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 2 Top 1 Sword",
							Icon = "rbxassetid://15308721554"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 2 Top 50 Sword",
							Icon = "rbxassetid://15308721702"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 2 Top 200 Sword",
							Icon = "rbxassetid://15308721826"
						}
					}
				}
			},
			["3"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 3 Top 1 Sword",
							Icon = "rbxassetid://15759882708"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 3 Top 50 Sword",
							Icon = "rbxassetid://15759882472"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 3 Top 200 Sword",
							Icon = "rbxassetid://15759882253"
						}
					}
				}
			},
			["4"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 4 Top 1 Sword",
							Icon = "rbxassetid://16138991986"
						}
					}
				},
				{
					Rank = 25,
					Rewards = {
						{
							Sword = "Ranked Season 4 Top 25 Sword",
							Icon = "rbxassetid://16138996452"
						}
					}
				},
				{
					Rank = 100,
					Rewards = {
						{
							Sword = "Ranked Season 4 Top 100 Sword",
							Icon = "rbxassetid://16138999325"
						}
					}
				}
			},
			["5"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 5 Top 1 Sword",
							Icon = "rbxassetid://16730786802"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 5 Top 50 Sword",
							Icon = "rbxassetid://16730787243"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 5 Top 200 Sword",
							Icon = "rbxassetid://16730787056"
						}
					}
				}
			},
			["6"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 6 Top 1 Sword",
							Icon = "rbxassetid://17332114895"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 6 Top 50 Sword",
							Icon = "rbxassetid://17332115196"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 6 Top 200 Sword",
							Icon = "rbxassetid://17332115390"
						}
					}
				}
			},
			["7"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 7 Top 1 Sword",
							Icon = "rbxassetid://18154005151"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 7 Top 50 Sword",
							Icon = "rbxassetid://18153995632"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 7 Top 200 Sword",
							Icon = "rbxassetid://18153985876"
						}
					}
				}
			},
			["8"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 8 Top 1 Sword",
							Icon = "rbxassetid://139495977339184"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 8 Top 50 Sword",
							Icon = "rbxassetid://101196873263203"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 8 Top 200 Sword",
							Icon = "rbxassetid://71984471821473"
						}
					}
				}
			},
			["9"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 9 Top 1 Sword",
							Icon = "rbxassetid://133406510176674"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 9 Top 50 Sword",
							Icon = "rbxassetid://100952926053675"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 9 Top 200 Sword",
							Icon = "rbxassetid://109935550258491"
						}
					}
				}
			},
			["10"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 10 Top 1 Sword",
							Icon = "rbxassetid://98855275725401"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 10 Top 50 Sword",
							Icon = "rbxassetid://112370638063912"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 10 Top 200 Sword",
							Icon = "rbxassetid://79213887614734"
						}
					}
				}
			},
			["11"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 11 Top 1 Sword",
							Icon = "rbxassetid://88546331433016"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 11 Top 50 Sword",
							Icon = "rbxassetid://117190372165675"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 11 Top 200 Sword",
							Icon = "rbxassetid://85756764363947"
						}
					}
				}
			},
			["12"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 12 Top 1",
							Icon = "rbxassetid://94569594941699"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 12 Top 50",
							Icon = "rbxassetid://79352942669442"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 12 Top 200",
							Icon = "rbxassetid://71684913077849"
						}
					}
				}
			},
			["13"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 13 Top 1",
							Icon = "rbxassetid://125685247921966"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 13 Top 50",
							Icon = "rbxassetid://132285100186069"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 13 Top 200",
							Icon = "rbxassetid://129553099805628"
						}
					}
				}
			},
			["14"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 14 Top 1",
							Icon = "rbxassetid://130729894154243"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 14 Top 50",
							Icon = "rbxassetid://122024903174661"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 14 Top 200",
							Icon = "rbxassetid://126787131346147"
						}
					}
				}
			},
			["15"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 15 Top 1",
							Icon = "rbxassetid://112872727261339"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 15 Top 50",
							Icon = "rbxassetid://134760175114302"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 15 Top 200",
							Icon = "rbxassetid://78243518890339"
						}
					}
				}
			},
			["16"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 16 Top 1",
							Icon = "rbxassetid://112872727261339"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 16 Top 50",
							Icon = "rbxassetid://134760175114302"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 16 Top 200",
							Icon = "rbxassetid://78243518890339"
						}
					}
				}
			},
			["17"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 17 Top 1",
							Icon = "rbxassetid://112872727261339"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 17 Top 50",
							Icon = "rbxassetid://134760175114302"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 17 Top 200",
							Icon = "rbxassetid://78243518890339"
						}
					}
				}
			},
			["18"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 18 Top 1",
							Icon = "rbxassetid://112872727261339"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 18 Top 50",
							Icon = "rbxassetid://134760175114302"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 18 Top 200",
							Icon = "rbxassetid://78243518890339"
						}
					}
				}
			},
			["19"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 19 Top 1",
							Icon = "rbxassetid://112872727261339"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 19 Top 50",
							Icon = "rbxassetid://134760175114302"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 19 Top 200",
							Icon = "rbxassetid://78243518890339"
						}
					}
				}
			},
			["20"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked Season 20 Top 1",
							Icon = "rbxassetid://120256774914538"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked Season 20 Top 50",
							Icon = "rbxassetid://71665832533144"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked Season 20 Top 200",
							Icon = "rbxassetid://102495609847951"
						}
					}
				}
			}
		},
		NoAbility = {
			["1"] = {
				{
					Rank = 50,
					Rewards = {
						{
							RandomAbilities = { "Infinity", "Death Slash", "Dribble" },
							Icon = "rbxassetid://15962769255"
						}
					}
				}
			},
			["2"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 1 Sword",
							Icon = "rbxassetid://16138991986"
						}
					}
				},
				{
					Rank = 25,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 25 Sword",
							Icon = "rbxassetid://16138996452"
						}
					}
				},
				{
					Rank = 100,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 100 Sword",
							Icon = "rbxassetid://16138999325"
						}
					}
				}
			},
			["3"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 1 Sword",
							Icon = "rbxassetid://16138991986"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 25 Sword",
							Icon = "rbxassetid://16138996452"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 100 Sword",
							Icon = "rbxassetid://16138999325"
						}
					}
				}
			},
			["4"] = {
				{
					Rank = 1,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 1 Sword",
							Icon = "rbxassetid://16138991986"
						}
					}
				},
				{
					Rank = 50,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 25 Sword",
							Icon = "rbxassetid://16138996452"
						}
					}
				},
				{
					Rank = 200,
					Rewards = {
						{
							Sword = "Ranked NA Season 2 Top 100 Sword",
							Icon = "rbxassetid://16138999325"
						}
					}
				}
			}
		}
	},
	GetRankedType = function()
		if v.isNoAbilityRankedMatchServer() or v.isNoAbilityRankedLobbyServer() then
			return "NoAbility"
		end

		return "Normal"
	end
}

function RankedSeasonData.GetSeasonEndTime(p: string, p2: number?)
	local v3 = p2 or RankedSeasonData.GetCurrentSeason(p)
	local unixTimestamp = RankedSeasonData.Seasons[p][v3].EndTime.UnixTimestamp

	if p == "Normal" then
		return v2.FFlag.GetFFlag(`RankedSeason{v3}EndTime`, unixTimestamp)
	end

	return unixTimestamp
end

function RankedSeasonData.GetSeasonStartTime(p: string, p2: number?)
	local v3 = p2 or RankedSeasonData.GetCurrentSeason(p)
	local unixTimestamp = RankedSeasonData.Seasons[p][v3].StartTime.UnixTimestamp

	if p == "Normal" then
		return v2.FFlag.GetFFlag(`RankedSeason{v3 - 1}EndTime`, unixTimestamp)
	end

	return unixTimestamp
end

function RankedSeasonData.GetCurrentSeason(p)
	local serverTimeNow = workspace:GetServerTimeNow()

	if p == nil then
		warn("Missing RankedType argument", debug.traceback("", 2))
		p = RankedSeasonData.GetRankedType()
	end

	for k, _ in RankedSeasonData.Seasons[p] do
		local seasonStartTime = RankedSeasonData.GetSeasonStartTime(p, k)
		local seasonEndTime = RankedSeasonData.GetSeasonEndTime(p, k)

		if seasonStartTime <= serverTimeNow and serverTimeNow < seasonEndTime then
			return k
		end
	end

	return 1
end

function RankedSeasonData.GetSeasonAct(p: number?, value)
	local currentSeason = RankedSeasonData.GetCurrentSeason(value or "Normal")
	local v3 = value == "NoAbility" and 10 or 12
	local v4 = p or currentSeason
	local v5

	if v3 < v4 then
		local v6 = v4 - v3
		v5 = math.ceil(v6 / v3) + 1
		v4 = (v6 - 1) % v3 + 1
	else
		v5 = 1
	end

	return v5, v4
end

function RankedSeasonData.GetSeasonName(p: number?, p2)
	local seasonAct, v3 = RankedSeasonData.GetSeasonAct(p, p2)
	return (`Act {seasonAct} Season {v3}`)
end

function RankedSeasonData.GetSeasonNameShort(p: number?, p2)
	local seasonAct, v3 = RankedSeasonData.GetSeasonAct(p, p2)
	return (`Act {seasonAct} S{v3}`)
end

task.spawn(function()
	local v3 = {}

	for _, rankedType in RankedSeasonData.RankedTypes do
		v3[rankedType] = RankedSeasonData.GetCurrentSeason(rankedType)
	end

	v2.Thread.Every(1, function()
		for _, rankedType in RankedSeasonData.RankedTypes do
			local currentSeason = RankedSeasonData.GetCurrentSeason(rankedType)

			if not (v3[rankedType] < currentSeason) then
				continue
			end

			print("SEASON HAS CHANGED!", currentSeason, v3)
			bindableEvent:Fire(rankedType, currentSeason, v3)
			v3[rankedType] = currentSeason
		end
	end)
end)
return RankedSeasonData