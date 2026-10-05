local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Packages.Net)
return {
	BadgeId = 2598727506093289,
	AssetId = 96044723451500,
	TotalStock = 40000,
	Rewards = {
		Primary = v.createBadgeReward(2598727506093289, "Highlights Hero"),
		Secondary = v.createGachaSpinsReward(1, "Haunted Spin")
	},
	Remotes = {
		HasMedalInstalled = v2:RemoteFunction("MedalEvent/HasMedalInstalled"),
		Claim = v2:RemoteFunction("MedalEvent/Claim")
	}
}