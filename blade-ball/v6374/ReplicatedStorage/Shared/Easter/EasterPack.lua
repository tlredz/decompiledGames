local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	EndTime = require3(ReplicatedStorage2.Shared.Easter.EasterEvent).EndTime,
	ProductId = 1789076375,
	GiftProductId = 1789076462,
	Rewards = {
		v.createSwordReward("Bunny Staff"),
		v.createEmoteReward("Emote235"),
		v.createExplosionReward("Eggsplosive Exit")
	}
}