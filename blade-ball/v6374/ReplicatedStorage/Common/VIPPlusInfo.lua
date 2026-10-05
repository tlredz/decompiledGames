local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)(script.Parent.RewardInfo)
local _ = {
	DisplayName = "???",
	Icon = "http://www.roblox.com/asset/?id=14899683432",
	Type = "Coins",
	Value = 100
}
return {
	Instant = {
		v.createCoinsReward(1500, "Big"),
		v.createExplosionReward("Blackhole Whitehole"),
		v.createCrateKeyReward("PremiumExplosion", 3, "Premium Explosion Crate", "rbxassetid://15049303003"),
		v.createBoothReward("Golden")
	},
	MonthlyRewards = {
		{
			[1] = {
				v.createEmoteReward("Emote26"),
				v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646")
			},
			[8] = { v.createSwordReward("Runic Wrecker"), v.createEmoteReward("Emote27") },
			[15] = { v.createSwordReward("VIP Sword"), v.createExplosionReward("VIP Explosion") },
			[22] = { v.createExplosionReward("Golden Reserve"), v.createSwordReward("VIP Cutlass") }
		},
		{
			[1] = {
				v.createEmoteReward("Emote47"),
				v.createCrateKeyReward("PremiumSword", 1, "Premium Sword Crate", "rbxassetid://16039967646")
			},
			[8] = {
				v.createSwordReward("Festive Sword"),
				v.createCrateKeyReward("PremiumExplosion", 1, "Premium Explosion Crate", "rbxassetid://15049303003")
			},
			[15] = { v.createExplosionReward("Christmas Present"), v.createExplosionReward("Crowned Ending") },
			[22] = { v.createSwordReward("Parasol"), v.createEmoteReward("Emote100") }
		}
	}
}