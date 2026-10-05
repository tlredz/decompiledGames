local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "ZodiacPackRootStartTime",
		RootFFlagEndTime = "ZodiacPackRootEndTime",
		FFlagStartTime = "ZodiacBladeStartTime",
		FFlagEndTime = "ZodiacBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zodiac Blade",
				Image = v2.Icons:GetSwordIcon("Dual Zodiac Blade"),
				ShowRoom = "ZodiacBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Zodiac Blade",
						GiftId = 3239938579,
						Item = v.createListReward({ v.createSwordReward("Zodiac Blade") }),
						ProductId = 3239938583
					},
					{
						GiftName = "Dual Zodiac Blade",
						GiftId = 3239938575,
						Item = v.createListReward({
							v.createSwordReward("Dual Zodiac Blade"),
							v.createExplosionReward("Zodiac Ascendant"),
							v.createEmoteReward("Emote833")
						}),
						ProductId = 3239938584
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ZodiacPackRootStartTime",
		RootFFlagEndTime = "ZodiacPackRootEndTime",
		FFlagStartTime = "ZodiacParasolStartTime",
		FFlagEndTime = "ZodiacParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zodiac Parasol",
				Image = v2.Icons:GetSwordIcon("Zodiac Parasol"),
				ShowRoom = "ZodiacParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Zodiac Parasol",
						GiftId = 3239938577,
						Item = v.createListReward({
							v.createSwordReward("Zodiac Parasol"),
							v.createExplosionReward("Zodiac Shrine"),
							v.createEmoteReward("Emote834")
						}),
						ProductId = 3239938580
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ZodiacPackRootStartTime",
		RootFFlagEndTime = "ZodiacPackRootEndTime",
		FFlagStartTime = "ZodiacPackStartTime",
		FFlagEndTime = "ZodiacPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zodiac Pack",
				Image = "rbxassetid://130907095937556",
				ShowRoom = "ZodiacPackShowRoom",
				Rewards = {
					{
						GiftName = "Zodiac Pack",
						GiftId = 3239938581,
						Item = v.createListReward({
							v.createSwordReward("Zodiac Blade"),
							v.createSwordReward("Zodiac Parasol"),
							v.createExplosionReward("Zodiac Ascendant"),
							v.createEmoteReward("Emote834")
						}),
						ProductId = 3239938578,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Zodiac Pack",
						GiftId = 3239938582,
						Item = v.createListReward({
							v.createSwordReward("Dual Zodiac Blade"),
							v.createSwordReward("Zodiac Parasol"),
							v.createExplosionReward("Zodiac Shrine"),
							v.createEmoteReward("Emote834"),
							v.createEmoteReward("Emote833")
						}),
						ProductId = 3239938576,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}