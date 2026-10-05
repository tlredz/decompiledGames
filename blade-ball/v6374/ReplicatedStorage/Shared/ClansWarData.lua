local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = {
	Season = 3,
	DailyWars = 10,
	DailyWarsResetCooldown = 86400,
	PlayersPerParty = game.GameId ~= 4777817887 and 2 or 5,
	Rewards = {
		Winner = { v.createCrownsReward(50), v.createActivityPointsReward(100) },
		Loser = { v.createCrownsReward(10), v.createActivityPointsReward(20) }
	},
	TopClansRewards = {
		{
			Reward = v.createSwordReward("Rose Piercer"),
			Top = 3
		},
		{
			Reward = v.createSwordReward("Amethyst Slicer"),
			Top = 50
		}
	},
	MaxMatchHistorySize = 20,
	CANCELLED_SYMBOL = "\0",
	CLANS_WAR_LEADERBOARD_PARTITION = 4,
	CLANS_WAR_END_UNIX = DateTime.fromUniversalTime(2025, 2, 8, 17).UnixTimestamp,
	parsePartyUser = function(value: string)
		return string.match(value, "(%d+)_(.+)")
	end
}
return table.freeze(v2)