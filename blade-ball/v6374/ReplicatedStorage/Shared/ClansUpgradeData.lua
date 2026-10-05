local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(script.Parent.ClansData)
local v2 = {
	Upgrades = {
		Size = {
			Levels = {
				{
					XP = 0,
					Value = 12
				},
				{
					XP = 2000,
					Value = 20
				},
				{
					XP = 4500,
					Value = 25
				},
				{
					XP = 20000,
					Value = 30
				},
				{
					XP = 75000,
					Value = 35
				},
				{
					XP = 200000,
					Value = 40
				},
				{
					XP = 450000,
					Value = 45
				},
				{
					XP = 1000000,
					Value = 50
				},
				{
					XP = 2000000,
					Value = 55
				}
			},
			DisplayName = "Size",
			Description = "Expands clan member capacity!",
			Icon = "rbxassetid://15594226000",
			IconBackground = "rbxassetid://15592780082"
		},
		CoinEarning = {
			Levels = {
				{
					XP = 0,
					Value = 0
				},
				{
					XP = 800,
					Value = 0.01
				},
				{
					XP = 1500,
					Value = 0.02
				},
				{
					XP = 4500,
					Value = 0.025
				},
				{
					XP = 16000,
					Value = 0.03
				},
				{
					XP = 29000,
					Value = 0.05
				},
				{
					XP = 85000,
					Value = 0.1
				},
				{
					XP = 200000,
					Value = 0.15
				},
				{
					XP = 500000,
					Value = 0.2
				}
			},
			DisplayName = "Coin Earning",
			Description = "Increases coin multiplier for all clan members!",
			Icon = "rbxassetid://15594219221",
			IconBackground = "rbxassetid://15518226758"
		},
		Welfare = {
			Levels = {
				{
					XP = 0,
					GP = 900,
					Rewards = { v.createCoinsReward(100, "Small") }
				},
				{
					XP = 2000,
					GP = 1200,
					Rewards = { v.createCoinsReward(100, "Small") }
				},
				{
					XP = 4500,
					GP = 900,
					Rewards = { v.createCoinsReward(100, "Small") }
				},
				{
					XP = 12000,
					GP = 1200,
					Rewards = { v.createCrownsReward(10) }
				},
				{
					XP = 25000,
					GP = 1800,
					Rewards = { v.createCrownsReward(15) }
				},
				{
					XP = 65000,
					GP = 3600,
					Rewards = { v.createCrownsReward(20) }
				},
				{
					XP = 180000,
					GP = 1500,
					Rewards = { v.createCrownsReward(25) }
				},
				{
					XP = 250000,
					GP = 1800,
					Rewards = {
						v.createCrownsReward(30),
						v.createChestReward("Clan Magical", 1, "rbxassetid://17207236184")
					}
				},
				{
					XP = 600000,
					GP = 1800,
					Rewards = {
						v.createCrownsReward(35),
						v.createChestReward("Clan Magical", 1, "rbxassetid://17207236184")
					}
				}
			},
			DisplayName = "Welfare",
			Description = "All clan members can claim a reward at %s and has to be claimed within a certain time period. This upgrade increases the grace period for that time.",
			Icon = "rbxassetid://15593970264",
			IconBackground = "rbxassetid://15518687236"
		},
		Luck = {
			Levels = {
				{
					XP = 0,
					Value = 0
				},
				{
					XP = 4000,
					Value = 0.005
				},
				{
					XP = 15000,
					Value = 0.015
				},
				{
					XP = 50000,
					Value = 0.025
				},
				{
					XP = 180000,
					Value = 0.04
				},
				{
					XP = 400000,
					Value = 0.05
				},
				{
					XP = 900000,
					Value = 0.07
				},
				{
					XP = 1500000,
					Value = 0.1
				},
				{
					XP = 3000000,
					Value = 0.125
				}
			},
			DisplayName = "Luck",
			Description = "Increases rare item drop rates in Blade Ball for all clan members!",
			Icon = "rbxassetid://15592780889",
			IconBackground = "rbxassetid://15518687330"
		}
	},
	CrownsPerDonate = 100,
	MaxCrownsDonates = 1,
	CrownsResetTime = 600,
	MinClanPointsDonate = 1
}

function v2.getClanUpgrade(p, p2: string)
	assert(v2.Upgrades[p2], (`{p2} is not a valid clan upgrade!`))
	local levels = v2.Upgrades[p2].Levels
	local v3 = 1
	local level = levels[v3]
	local v4 = p[p2]

	if not v4 then
		return level, v3
	end

	for k, level2 in levels do
		if level2.XP <= v4 then
			v3 = k
			level = level2
		else
			break
		end
	end

	return level, v3
end

function v2.getUpgrade(p)
	local upgrade = v2.Upgrades[p]

	if upgrade then
		return upgrade
	end
end

function v2.getWelfareClaim(p)
	local universalTime = DateTime.now():ToUniversalTime()
	local timezoneOffset = p.timezoneOffset or 0
	return DateTime.fromUniversalTime(universalTime.Year, universalTime.Month, universalTime.Day, 20).UnixTimestamp - timezoneOffset * 60 * 60
end

function v2.getUpgradeLevel(p: string, p2: number)
	local levels = v2.Upgrades[p].Levels
	local v3 = 1
	local level = levels[v3]

	if p2 == 0 then
		return level, v3
	end

	for k, level2 in levels do
		if level2.XP <= p2 then
			v3 = k
			level = level2
		else
			break
		end
	end

	return level, v3
end

return table.freeze(v2)