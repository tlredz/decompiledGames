local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	EndTime = DateTime.fromUnixTimestamp(1776528000),
	AdminEvent = {
		IterationTime = v.isDevPlaceGame() and 600 or 10800,
		Season = "042026",
		EggsRequired = 10,
		StockPerIteration = 50,
		StartTime = not (v.isDevPlaceGame() or v.isTestGame()) and 1775318400 or DateTime.fromUniversalTime(2026).UnixTimestamp,
		EndTime = 1776528000,
		Reward = v2.createSwordReward("Easter Staff")
	}
}