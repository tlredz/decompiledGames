local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
return table.freeze({
	CratePrice = 1,
	LoginStreaks = {},
	Items = {
		{
			Reward = v2.createExplosionReward("Chill Crack"),
			Chance = 35
		},
		{
			Reward = v2.createSwordReward("Phantom Shard"),
			Chance = 5
		},
		{
			Reward = v2.createExplosionReward("Ancient City"),
			Chance = 1
		},
		{
			Reward = v2.createSwordReward("North Star Fragment"),
			Chance = 42.8
		},
		{
			Reward = v2.createSwordReward("Necro Fang"),
			Chance = 10
		},
		{
			Reward = v2.createEmoteReward("Drive By"),
			Chance = 6
		},
		{
			Reward = v2.createSwordReward("Orbit Spear"),
			Chance = 0.2,
			ShouldUseReplacement = function(object)
				local v3

				if RunService:IsClient() then
					v3 = v.Client:WaitReplion("LimitedStockItems")
				else
					v3 = v.Server:WaitReplion("LimitedStockItems")
				end

				if not (v3 and v3:Get("Loaded")) then
					return true
				end

				local v4 = v3:Get({ "Stock", "Orbit Spear" })
				return not v4 or v4 <= 0 or object:Get("ReceivedTournamentEventFFAOrbitSpear") == true
			end
		}
	}
})