local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Shared.RankedSeasonData)
require3(ReplicatedStorage2.Packages.Replion)

local function currency(amount, currencyName)
	return {
		CurrencyName = currencyName,
		Amount = amount,
		Icon = currencyName == "Coins" and "rbxassetid://15245976510" or false
	}
end

local function sword(p, icon)
	return {
		Name = p,
		SwordName = p,
		Icon = icon
	}
end

local RankData = {
	Ranks = {
		Rookie = {
			MinimumElo = 0,
			MaximumElo = 1999,
			TextColor = Color3.fromRGB(91, 174, 102),
			Icon = "rbxassetid://14916629523"
		},
		Bronze = {
			MinimumElo = 2000,
			MaximumElo = 2999,
			TextColor = Color3.fromRGB(200, 132, 93),
			Icon = "rbxassetid://14916630678",
			Reward = {
				Normal = { v.createCoinsReward(250, "Small"), v.createGachaSpinsReward(1) },
				NoAbility = { v.createCoinsReward(75, "Small") }
			}
		},
		Silver = {
			MinimumElo = 3000,
			MaximumElo = 3999,
			TextColor = Color3.fromRGB(161, 175, 181),
			Icon = "rbxassetid://14916629343",
			Reward = {
				Normal = { v.createCoinsReward(500, "Small"), v.createGachaSpinsReward(2) },
				NoAbility = { v.createCoinsReward(100, "Small") }
			}
		},
		Gold = {
			MinimumElo = 4000,
			MaximumElo = 4999,
			TextColor = Color3.fromRGB(236, 194, 39),
			Icon = "rbxassetid://14916630089",
			Reward = {
				Normal = { v.createCoinsReward(1000, "Small"), v.createGachaSpinsReward(3) },
				NoAbility = { v.createCoinsReward(200, "Small") }
			}
		},
		Platinum = {
			MinimumElo = 5000,
			MaximumElo = 5999,
			TextColor = Color3.fromRGB(228, 242, 248),
			Icon = "rbxassetid://14916629671",
			Reward = {
				Normal = { v.createCoinsReward(1500, "Med"), v.createGachaSpinsReward(5) },
				NoAbility = { v.createCoinsReward(375, "Med") }
			}
		},
		Diamond = {
			MinimumElo = 6000,
			MaximumElo = 6999,
			TextColor = Color3.fromRGB(83, 231, 255),
			Icon = "rbxassetid://14916630252",
			Reward = {
				Normal = { v.createCoinsReward(2500, "Big"), v.createGachaSpinsReward(10) },
				NoAbility = { v.createCoinsReward(750, "Big") }
			}
		},
		["???"] = {
			MinimumElo = 7000,
			MaximumElo = 7999,
			TextColor = Color3.fromRGB(255, 82, 255),
			Icon = "rbxassetid://14916629907",
			Reward = {
				Normal = { v.createCoinsReward(5000, "Big"), v.createGachaSpinsReward(15) },
				NoAbility = { v.createCoinsReward(1500, "Big") }
			}
		},
		Champion = {
			MinimumElo = 8000,
			MaximumElo = "inf",
			TextColor = Color3.fromRGB(0, 124, 215),
			Icon = "rbxassetid://14916630439",
			Rewards = {
				Normal = {
					["2"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Azure Thunderbolt") },
					["3"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Champion's Excalibur") },
					["4"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Valor's Rage") },
					["5"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 5 Champion") },
					["6"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 6 Champion") },
					["7"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 7 Champion") },
					["8"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 8 Champion") },
					["9"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 9 Champion") },
					["10"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 10 Champion") },
					["11"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Ranked Season 11 Champion") },
					["12"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 12 Champion")
					},
					["13"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 13 Champion")
					},
					["14"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 14 Champion")
					},
					["15"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 15 Champion")
					},
					["16"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 16 Champion")
					},
					["17"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 17 Champion")
					},
					["18"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 18 Champion")
					},
					["19"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 19 Champion")
					},
					["20"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createSwordReward("Ranked Season 20 Champion")
					},
					["21"] = {
						v.createCoinsReward(10000, "Big"),
						v.createGachaSpinsReward(25),
						v.createExplosionReward("Ranked Season 21 Champion")
					}
				},
				NoAbility = {
					["1"] = { v.createCoinsReward(2000, "Big"), v.createSwordReward("Champion's Excalibur") }
				}
			},
			PrimaryReward = 3
		}
	},
	RankList = {}
}

for k, rank in RankData.Ranks do
	rank.Name = k
	table.insert(RankData.RankList, rank)
end

table.sort(RankData.RankList, function(a, b)
	return a.MinimumElo < b.MinimumElo
end)

function RankData.GetRank(value)
	local v3 = math.max(0, typeof(value) ~= "number" and 0 or value)
	local v4 = nil

	for _, v5 in RankData.RankList do
		if v5.MinimumElo <= v3 then
			v4 = v5
		end
	end

	return v4
end

function RankData.GetNextRank(value)
	local v3 = math.max(0, typeof(value) ~= "number" and 0 or value)
	local v4 = 1

	for k, v5 in RankData.RankList do
		if v5.MinimumElo <= v3 then
			v4 = k
		end
	end

	if v4 == #RankData.RankList then
		return nil
	end

	return RankData.RankList[v4 + 1]
end

function RankData.GetPlayerRank(object, p: string)
	local rankedType = v2.GetRankedType()
	local v3 = object:Get({ "Elo", rankedType, (`Season{v2.GetCurrentSeason(rankedType)}`) })
	local v4 = v3 and (v3[p] or v3.FFA)

	if v4 then
		return RankData.GetRank(v4)
	end

	return RankData.Ranks.Bronze
end

return RankData