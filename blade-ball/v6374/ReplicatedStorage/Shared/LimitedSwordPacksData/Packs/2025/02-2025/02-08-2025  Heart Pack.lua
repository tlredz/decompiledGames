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
		RootFFlagStartTime = "HeartPackRootStartTime",
		RootFFlagEndTime = "HeartPackRootEndTime",
		FFlagStartTime = "HeartBladeStartTime",
		FFlagEndTime = "HeartBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heart Blade",
				Image = v2.Icons:GetSwordIcon("Dual Heart Blade"),
				ShowRoom = "HeartBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heart Blade",
						GiftId = 2838625496,
						Item = v.createListReward({ v.createSwordReward("Heart Blade") }),
						ProductId = 2838625501
					},
					{
						GiftName = "Dual Heart Blade",
						GiftId = 2838625503,
						Item = v.createListReward({
							v.createSwordReward("Dual Heart Blade"),
							v.createExplosionReward("Hearts"),
							v.createEmoteReward("Emote771")
						}),
						ProductId = 2838625497
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeartPackRootStartTime",
		RootFFlagEndTime = "HeartPackRootEndTime",
		FFlagStartTime = "HeartBowStartTime",
		FFlagEndTime = "HeartBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heart Bow",
				Image = v2.Icons:GetSwordIcon("Heart Bow"),
				ShowRoom = "HeartBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heart Bow",
						GiftId = 2838625495,
						Item = v.createListReward({
							v.createSwordReward("Heart Bow"),
							v.createExplosionReward("Affection Rain"),
							v.createEmoteReward("Emote770")
						}),
						ProductId = 2838625494
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeartPackRootStartTime",
		RootFFlagEndTime = "HeartPackRootEndTime",
		FFlagStartTime = "HeartPackStartTime",
		FFlagEndTime = "HeartPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heart Pack",
				Image = "rbxassetid://81110150394711",
				ShowRoom = "HeartPackShowRoom",
				Rewards = {
					{
						GiftName = "Heart Pack",
						GiftId = 2838625500,
						Item = v.createListReward({
							v.createSwordReward("Heart Blade"),
							v.createSwordReward("Heart Bow"),
							v.createExplosionReward("Hearts"),
							v.createEmoteReward("Emote770")
						}),
						ProductId = 2838625498,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Heart Pack",
						GiftId = 2838625502,
						Item = v.createListReward({
							v.createSwordReward("Dual Heart Blade"),
							v.createSwordReward("Heart Bow"),
							v.createExplosionReward("Affection Rain"),
							v.createEmoteReward("Emote770"),
							v.createEmoteReward("Emote771")
						}),
						ProductId = 2838625499,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}