local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.UGCTracker)
return {
	EndTimestamp = DateTime.fromUniversalTime(2026, 6, 6, 17).UnixTimestamp,
	Version = 5,
	Rewards = {
		[3] = {
			reward = v.createExplosionReward("Powering Joy")
		}
	}
}