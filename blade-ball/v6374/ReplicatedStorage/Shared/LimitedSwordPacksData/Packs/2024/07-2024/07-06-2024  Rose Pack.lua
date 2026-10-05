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
		RootFFlagStartTime = "RosePackRootStartTime",
		RootFFlagEndTime = "RosePackRootEndTime",
		FFlagStartTime = "RoseBladeStartTime",
		FFlagEndTime = "RoseBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rose Blade",
				Image = v2.Icons:GetSwordIcon("Dual Rose Blade"),
				ShowRoom = "RoseBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rose Blade",
						GiftId = 1867170532,
						Item = v.createListReward({ v.createSwordReward("Rose Blade") }),
						ProductId = 1867169483
					},
					{
						GiftName = "Dual Rose Blade",
						GiftId = 1867170531,
						Item = v.createListReward({
							v.createSwordReward("Dual Rose Blade"),
							v.createExplosionReward("Flower's Garden"),
							v.createEmoteReward("Emote421")
						}),
						ProductId = 1867169479
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosePackRootStartTime",
		RootFFlagEndTime = "RosePackRootEndTime",
		FFlagStartTime = "RoseBowStartTime",
		FFlagEndTime = "RoseBowEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rose Bow",
				Image = v2.Icons:GetSwordIcon("Rose Bow"),
				ShowRoom = "RoseBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rose Bow",
						GiftId = 1867170534,
						Item = v.createListReward({
							v.createSwordReward("Rose Bow"),
							v.createExplosionReward("Bloom Awakening"),
							v.createEmoteReward("Emote422")
						}),
						ProductId = 1867169480
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosePackRootStartTime",
		RootFFlagEndTime = "RosePackRootEndTime",
		FFlagStartTime = "RosePackStartTime",
		FFlagEndTime = "RosePackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Roses Pack",
				Image = "rbxassetid://18354775920",
				ShowRoom = "RosesPackShowRoom",
				Rewards = {
					{
						GiftName = "Roses Pack",
						GiftId = 1867170533,
						Item = v.createListReward({
							v.createSwordReward("Rose Blade"),
							v.createSwordReward("Rose Bow"),
							v.createExplosionReward("Flower's Garden"),
							v.createEmoteReward("Emote422")
						}),
						ProductId = 1867169478,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Roses Pack",
						GiftId = 1867170536,
						Item = v.createListReward({
							v.createSwordReward("Dual Rose Blade"),
							v.createSwordReward("Rose Bow"),
							v.createExplosionReward("Bloom Awakening"),
							v.createEmoteReward("Emote421"),
							v.createEmoteReward("Emote422")
						}),
						ProductId = 1867169481,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}