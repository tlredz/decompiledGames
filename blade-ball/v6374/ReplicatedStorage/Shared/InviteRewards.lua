local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return (table.freeze({
	["Fantasy Katana"] = {
		Invites = 1,
		Reward = v.createSwordReward("Fantasy Katana")
	},
	Emote118 = {
		Invites = 2,
		Reward = v.createEmoteReward("Emote118")
	}
}))