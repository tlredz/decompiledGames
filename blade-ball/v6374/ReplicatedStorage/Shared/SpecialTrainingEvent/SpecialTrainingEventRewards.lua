local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require3(ReplicatedStorage2.Packages.Replion)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Shared.UGCTracker)
local v2 = {
	{
		Reward = v.createSwordReward("Singularity Fang"),
		XP = 48
	}
}
return table.freeze(v2)