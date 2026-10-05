local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)

local function getEvent(p: string)
	return v:RemoteEvent((`Trio Pass/{p}`))
end

local function getFunction(p: string)
	return v:RemoteFunction((`Trio Pass/{p}`))
end

return {
	Id = string.lower("silentveil2"),
	RewardsPerKills = {
		[50] = v2.createSeasonPassCurrencyReward(100),
		[200] = v2.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003"),
		[500] = v2.createSeasonPassCurrencyReward(500),
		[100] = v2.createWheelSpinReward(2),
		[1500] = v2.createSwordReward("Azure Blueblade"),
		[2000] = v2.createExplosionReward("Disco Rift"),
		[3000] = v2.createSwordReward("Blazing Temple"),
		[5000] = v2.createSwordReward("Relic Scythe")
	},
	Remotes = {
		Disband = v:RemoteFunction("Trio Pass/Disband"),
		SendInvite = v:RemoteFunction("Trio Pass/SendInvite"),
		InviteReceived = v:RemoteEvent("Trio Pass/InviteReceived"),
		RemoveInvite = v:RemoteEvent("Trio Pass/RemoveInvite"),
		SetReplication = v:RemoteEvent("Trio Pass/SetReplication"),
		ClaimLeaderboardRewards = v:RemoteFunction("Trio Pass/ClaimLeaderboardRewards")
	},
	LeaderboardRewards = {
		{
			Rank = 3,
			Rewards = { v2.createSwordReward("Lumenwing Bow") }
		},
		{
			Rank = 50,
			Rewards = { v2.createSwordReward("Lumenwing Blade") }
		}
	}
}