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
		RootFFlagStartTime = "FlashbackButterflyStartTime",
		RootFFlagEndTime = "FlashbackButterflyEndTime",
		FFlagStartTime = "FlashbackButterflyBladeStartTime",
		FFlagEndTime = "FlashbackButterflyBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flashback Butterfly Blade",
				Image = v2.Icons:GetSwordIcon("Dual Flashback Butterfly Blade"),
				ShowRoom = "FlashbackButterflyBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Flashback Butterfly Blade",
						GiftId = 3585187990,
						Item = v.createListReward({ v.createSwordReward("Flashback Butterfly Blade") }),
						ProductId = 3585187997
					},
					{
						GiftName = "Dual Flashback Butterfly Blade",
						GiftId = 3585188003,
						Item = v.createListReward({
							v.createSwordReward("Dual Flashback Butterfly Blade"),
							v.createExplosionReward("Flashback Butterfly"),
							v.createEmoteReward("Emote1206")
						}),
						ProductId = 3585187998
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FlashbackButterflyStartTime",
		RootFFlagEndTime = "FlashbackButterflyEndTime",
		FFlagStartTime = "FlashbackButterflyScytheStartTime",
		FFlagEndTime = "FlashbackButterflyScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flashback Butterfly Scythe",
				Image = v2.Icons:GetSwordIcon("Flashback Butterfly Scythe"),
				ShowRoom = "FlashbackButterflyScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Flashback Butterfly Scythe",
						GiftId = 3585187999,
						Item = v.createListReward({
							v.createSwordReward("Flashback Butterfly Scythe"),
							v.createExplosionReward("Flashback Shatter"),
							v.createEmoteReward("Emote1208")
						}),
						ProductId = 3585188001
					},
					{
						GiftName = "Dual Flashback Butterfly Scythe",
						GiftId = 3585188002,
						Item = v.createListReward({
							v.createSwordReward("Dual Flashback Butterfly Scythe"),
							v.createExplosionReward("Flashback Shatter"),
							v.createEmoteReward("Emote1207")
						}),
						ProductId = 3585187994
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FlashbackButterflyStartTime",
		RootFFlagEndTime = "FlashbackButterflyEndTime",
		FFlagStartTime = "FlashbackButterflyPackStartTime",
		FFlagEndTime = "FlashbackButterflyPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Flashback Butterfly Pack",
				Image = "rbxassetid://110529073365373",
				ShowRoom = "FlashbackButterflyPackShowRoom",
				Rewards = {
					{
						GiftName = "Flashback Butterfly Pack",
						GiftId = 3585188000,
						Item = v.createListReward({
							v.createSwordReward("Flashback Butterfly Blade"),
							v.createSwordReward("Flashback Butterfly Scythe"),
							v.createExplosionReward("Flashback Butterfly"),
							v.createEmoteReward("Emote1208")
						}),
						ProductId = 3585187995,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Flashback Butterfly Pack",
						GiftId = 3585187996,
						Item = v.createListReward({
							v.createSwordReward("Dual Flashback Butterfly Blade"),
							v.createSwordReward("Dual Flashback Butterfly Scythe"),
							v.createExplosionReward("Flashback Shatter"),
							v.createEmoteReward("Emote1206"),
							v.createEmoteReward("Emote1207")
						}),
						ProductId = 3585188004,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}