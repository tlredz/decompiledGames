local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	Items = {
		{
			Reward = v.createFinisherReward("Frog"),
			DevProduct = 2676404683,
			LimitedStockId = "Frog Finisher"
		},
		{
			Reward = v.createFinisherReward("Frost Dragon"),
			DevProduct = 2676404677,
			LimitedStockId = "Frost Dragon Finisher"
		},
		{
			Reward = v.createFinisherReward("Fire Dragon"),
			DevProduct = 2676404680,
			LimitedStockId = "Fire Dragon Finisher"
		},
		{
			Reward = v.createFinisherReward("Bunny"),
			DevProduct = 2676404684,
			LimitedStockId = "Bunny Finisher"
		},
		{
			Reward = v.createSwordReward("Runic Redblade"),
			DevProduct = 2676404688,
			GiftDevProduct = 2680222760,
			Discount = 25
		},
		{
			Reward = v.createSwordReward("Floral Slicer"),
			DevProduct = 2676404682,
			GiftDevProduct = 2680222762,
			Discount = 25
		},
		{
			Reward = v.createSwordReward("Aurora Bow"),
			DevProduct = 2676404679,
			GiftDevProduct = 2680222763,
			Discount = 25
		},
		{
			Reward = v.createSwordReward("Thorned Sovereign"),
			DevProduct = 2676404685,
			GiftDevProduct = 2680222769,
			Discount = 25
		},
		{
			Reward = v.createExplosionReward("Emberstorm Detonation"),
			DevProduct = 2676404681,
			GiftDevProduct = 2680222767,
			Discount = 25
		},
		{
			Reward = v.createExplosionReward("Galaxy Shatter"),
			DevProduct = 2676404687,
			GiftDevProduct = 2680222775,
			Discount = 25
		},
		{
			Reward = v.createExplosionReward("Frostflare Barrage"),
			DevProduct = 2676404678,
			GiftDevProduct = 2680222761,
			Discount = 25
		},
		{
			Reward = v.createExplosionReward("Soul Counter"),
			DevProduct = 2676404686,
			GiftDevProduct = 2680222772,
			Discount = 25
		},
		{
			Reward = v.createEmoteReward("Venom's Wrath"),
			DevProduct = 2677789898,
			GiftDevProduct = 2680222776,
			LimitedStockId = "Venom's Wrath",
			HasSerials = true
		},
		{
			Reward = v.createEmoteReward("Astral Enlightenment"),
			DevProduct = 2677789896,
			GiftDevProduct = 2680222771,
			LimitedStockId = "Astral Enlightenment",
			HasSerials = true
		},
		{
			Reward = v.createEmoteReward("Ethereal"),
			DevProduct = 2677789899,
			GiftDevProduct = 2680222768,
			LimitedStockId = "Ethereal",
			HasSerials = true
		},
		{
			Reward = v.createEmoteReward("Necrotic Ruler"),
			DevProduct = 2677789900,
			GiftDevProduct = 2680222770,
			LimitedStockId = "Necrotic Ruler",
			HasSerials = true
		},
		{
			Reward = v.createEmoteReward("Eternal Clockwork"),
			DevProduct = 2677789897,
			GiftDevProduct = 2680222774,
			LimitedStockId = "Eternal Clockwork",
			HasSerials = true
		}
	},
	EndTimestamp = DateTime.fromUniversalTime(2025, 1, 2, 17).UnixTimestamp,
	MaxItemsPerPool = 4
}