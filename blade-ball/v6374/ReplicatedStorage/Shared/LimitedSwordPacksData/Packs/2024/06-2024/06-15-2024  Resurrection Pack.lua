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
		RootFFlagStartTime = "Resurrection1PackRootStartTime",
		RootFFlagEndTime = "Resurrection1PackRootEndTime",
		FFlagStartTime = "ResurrectionBladeStartTime",
		FFlagEndTime = "ResurrectionBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Resurrection Blade",
				Image = v2.Icons:GetSwordIcon("Dual Resurrection Blade"),
				ShowRoom = "ResurrectionBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Resurrection Blade",
						GiftId = 1846765827,
						Item = v.createListReward({ v.createSwordReward("Resurrection Blade") }),
						ProductId = 1846765823
					},
					{
						GiftName = "Dual Resurrection Blade",
						GiftId = 1846765826,
						Item = v.createListReward({
							v.createSwordReward("Dual Resurrection Blade"),
							v.createExplosionReward("Revival Burst!"),
							v.createEmoteReward("Emote379")
						}),
						ProductId = 1846765833
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Resurrection1PackRootStartTime",
		RootFFlagEndTime = "Resurrection1PackRootEndTime",
		FFlagStartTime = "ResurrectionScytheStartTime",
		FFlagEndTime = "ResurrectionScytheEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Resurrection Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Resurrection Scythe"),
				ShowRoom = "ResurrectionScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Resurrection Scythe",
						GiftId = 1846765825,
						Item = v.createListReward({
							v.createSwordReward("Resurrection Scythe"),
							v.createExplosionReward("Resurrection Explosion"),
							v.createEmoteReward("Emote380")
						}),
						ProductId = 1846765829
					},
					{
						GiftName = "Dual Resurrection Scythe",
						GiftId = 1846765832,
						Item = v.createListReward({
							v.createSwordReward("Dual Resurrection Scythe"),
							v.createExplosionReward("Resurrection Explosion"),
							v.createEmoteReward("Emote381")
						}),
						ProductId = 1846765828
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "Resurrection1PackRootStartTime",
		RootFFlagEndTime = "Resurrection1PackRootEndTime",
		FFlagStartTime = "ResurrectionPackStartTime",
		FFlagEndTime = "ResurrectionPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Resurrection Pack",
				Image = "rbxassetid://17861078381",
				ShowRoom = "ResurrectionPackShowRoom",
				Rewards = {
					{
						GiftName = "Resurrection Pack",
						GiftId = 1846765830,
						Item = v.createListReward({
							v.createSwordReward("Resurrection Blade"),
							v.createSwordReward("Resurrection Scythe"),
							v.createExplosionReward("Revival Burst!"),
							v.createEmoteReward("Emote380")
						}),
						ProductId = 1846765831,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Resurrection Pack",
						GiftId = 1846765822,
						Item = v.createListReward({
							v.createSwordReward("Dual Resurrection Blade"),
							v.createSwordReward("Dual Resurrection Scythe"),
							v.createExplosionReward("Resurrection Explosion"),
							v.createEmoteReward("Emote379"),
							v.createEmoteReward("Emote381")
						}),
						ProductId = 1846765824,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}