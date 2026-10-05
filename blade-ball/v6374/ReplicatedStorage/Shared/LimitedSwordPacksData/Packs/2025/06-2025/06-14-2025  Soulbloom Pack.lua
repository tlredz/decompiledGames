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
		RootFFlagStartTime = "SoulbloomPackRootStartTime",
		RootFFlagEndTime = "SoulbloomPackRootEndTime",
		FFlagStartTime = "SoulbloomBladeStartTime",
		FFlagEndTime = "SoulbloomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Soulbloom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Soulbloom Blade"),
				ShowRoom = "SoulbloomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Soulbloom Blade",
						GiftId = 3307370223,
						Item = v.createListReward({ v.createSwordReward("Soulbloom Blade") }),
						ProductId = 3307370225
					},
					{
						GiftName = "Dual Soulbloom Blade",
						GiftId = 3307370224,
						Item = v.createListReward({
							v.createSwordReward("Dual Soulbloom Blade"),
							v.createExplosionReward("Soulbloom Aurora"),
							v.createEmoteReward("Emote957")
						}),
						ProductId = 3307370222
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SoulbloomPackRootStartTime",
		RootFFlagEndTime = "SoulbloomPackRootEndTime",
		FFlagStartTime = "SoulbloomScissorsStartTime",
		FFlagEndTime = "SoulbloomScissorsEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Soulbloom Scissors",
				Image = v2.Icons:GetSwordIcon("Soulbloom Scissors"),
				ShowRoom = "SoulbloomScissorsShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Soulbloom Scissors",
						GiftId = 3307370221,
						Item = v.createListReward({
							v.createSwordReward("Soulbloom Scissors"),
							v.createExplosionReward("Pink Healer"),
							v.createEmoteReward("Emote958")
						}),
						ProductId = 3307370227
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SoulbloomPackRootStartTime",
		RootFFlagEndTime = "SoulbloomPackRootEndTime",
		FFlagStartTime = "SoulbloomPackStartTime",
		FFlagEndTime = "SoulbloomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Soulbloom Pack",
				Image = "rbxassetid://96665165451048",
				ShowRoom = "SoulbloomPackShowRoom",
				Rewards = {
					{
						GiftName = "Soulbloom Pack",
						GiftId = 3307370229,
						Item = v.createListReward({
							v.createSwordReward("Soulbloom Blade"),
							v.createSwordReward("Soulbloom Scissors"),
							v.createExplosionReward("Soulbloom Aurora"),
							v.createEmoteReward("Emote958")
						}),
						ProductId = 3307370228,
						DiscountedFrom = 2750
					},
					{
						GiftName = "Dual Soulbloom Pack",
						GiftId = 3307370226,
						Item = v.createListReward({
							v.createSwordReward("Dual Soulbloom Blade"),
							v.createSwordReward("Soulbloom Scissors"),
							v.createExplosionReward("Pink Healer"),
							v.createEmoteReward("Emote958"),
							v.createEmoteReward("Emote957")
						}),
						ProductId = 3307370220,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}