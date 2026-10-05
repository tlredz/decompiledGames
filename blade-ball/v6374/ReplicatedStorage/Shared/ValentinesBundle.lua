local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	EndTime = DateTime.fromUnixTimestamp(1708189200),
	Bundles = {
		{
			ProductId = 2837244882,
			GiftName = "Valentines Bundle [1]",
			GiftProductId = 2837244883,
			Rewards = { v.createSwordReward("Rose Axe"), v.createExplosionReward("Rose Mirage Bloom") }
		},
		{
			ProductId = 2837244884,
			GiftName = "Valentines Bundle [2]",
			GiftProductId = 2837244885,
			Rewards = {
				v.createSwordReward("Rose Twinblade"),
				v.createSwordReward("Rose Axe"),
				v.createExplosionReward("Rose Mirage Bloom"),
				v.createEmoteReward("Fated Dance")
			}
		}
	}
}