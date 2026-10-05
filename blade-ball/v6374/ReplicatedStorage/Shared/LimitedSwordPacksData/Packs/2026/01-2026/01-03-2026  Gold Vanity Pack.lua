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
		RootFFlagStartTime = "GoldVanityPackRootStartTime",
		RootFFlagEndTime = "GoldVanityPackRootEndTime",
		FFlagStartTime = "GoldVanityBladeStartTime",
		FFlagEndTime = "GoldVanityBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gold Vanity Blade",
				Image = v2.Icons:GetSwordIcon("Dual Gold Vanity Blade"),
				ShowRoom = "GoldVanityBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gold Vanity Blade",
						GiftId = 3499847700,
						Item = v.createListReward({ v.createSwordReward("Gold Vanity Blade") }),
						ProductId = 3499847696
					},
					{
						GiftName = "Dual Gold Vanity Blade",
						GiftId = 3499847701,
						Item = v.createListReward({
							v.createSwordReward("Dual Gold Vanity Blade"),
							v.createExplosionReward("Gold Vanity Storm"),
							v.createEmoteReward("Emote1121")
						}),
						ProductId = 3499847695
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GoldVanityPackRootStartTime",
		RootFFlagEndTime = "GoldVanityPackRootEndTime",
		FFlagStartTime = "GoldVanitySpearStartTime",
		FFlagEndTime = "GoldVanitySpearEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gold Vanity Spear",
				Image = v2.Icons:GetSwordIcon("Gold Vanity Spear"),
				ShowRoom = "GoldVanitySpearShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gold Vanity Spear",
						GiftId = 3499847702,
						Item = v.createListReward({
							v.createSwordReward("Gold Vanity Spear"),
							v.createExplosionReward("Gold Vanity Sparkle"),
							v.createEmoteReward("Emote1120")
						}),
						ProductId = 3499847699
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GoldVanityPackRootStartTime",
		RootFFlagEndTime = "GoldVanityPackRootEndTime",
		FFlagStartTime = "GoldVanityPackStartTime",
		FFlagEndTime = "GoldVanityPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gold Vanity Pack",
				Image = "rbxassetid://113897304880602",
				ShowRoom = "GoldVanityPackShowRoom",
				Rewards = {
					{
						GiftName = "Gold Vanity Pack",
						GiftId = 3499847704,
						Item = v.createListReward({
							v.createSwordReward("Gold Vanity Spear"),
							v.createSwordReward("Gold Vanity Blade"),
							v.createExplosionReward("Gold Vanity Storm"),
							v.createEmoteReward("Emote1120")
						}),
						ProductId = 3499847697,
						DiscountedFrom = 2499
					},
					{
						GiftName = "Dual Gold Vanity Pack",
						GiftId = 3499847703,
						Item = v.createListReward({
							v.createSwordReward("Dual Gold Vanity Blade"),
							v.createSwordReward("Gold Vanity Spear"),
							v.createExplosionReward("Gold Vanity Sparkle"),
							v.createEmoteReward("Emote1120"),
							v.createEmoteReward("Emote1121")
						}),
						ProductId = 3499847698,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}