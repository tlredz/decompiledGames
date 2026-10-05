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
		RootFFlagStartTime = "InfinitePackRootStartTime",
		RootFFlagEndTime = "InfinitePackRootEndTime",
		FFlagStartTime = "InfiniteBladeStartTime",
		FFlagEndTime = "InfiniteBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Infinite Blade",
				Image = v2.Icons:GetSwordIcon("Dual Infinite Blade"),
				ShowRoom = "InfiniteBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Infinite Blade",
						GiftId = 1873904914,
						Item = v.createListReward({ v.createSwordReward("Infinite Blade") }),
						ProductId = 1873904912
					},
					{
						GiftName = "Dual Infinite Blade",
						GiftId = 1873904903,
						Item = v.createListReward({
							v.createSwordReward("Dual Infinite Blade"),
							v.createExplosionReward("Infinite Hole"),
							v.createEmoteReward("Emote426")
						}),
						ProductId = 1873904904
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "InfinitePackRootStartTime",
		RootFFlagEndTime = "InfinitePackRootEndTime",
		FFlagStartTime = "InfiniteScytheStartTime",
		FFlagEndTime = "InfiniteScytheEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Infinite Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Infinite Scythe"),
				ShowRoom = "InfiniteScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Infinite Scythe",
						GiftId = 1873904911,
						Item = v.createListReward({
							v.createSwordReward("Infinite Scythe"),
							v.createExplosionReward("Infinite Loop"),
							v.createEmoteReward("Emote427")
						}),
						ProductId = 1873904908
					},
					{
						GiftName = "Dual Infinite Scythe",
						GiftId = 1873904906,
						Item = v.createListReward({
							v.createSwordReward("Dual Infinite Scythe"),
							v.createExplosionReward("Infinite Loop"),
							v.createEmoteReward("Emote428")
						}),
						ProductId = 1873904909
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "InfinitePackRootStartTime",
		RootFFlagEndTime = "InfinitePackRootEndTime",
		FFlagStartTime = "InfinitePackStartTime",
		FFlagEndTime = "InfinitePackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Infinite Pack",
				Image = "rbxassetid://18465328771",
				ShowRoom = "InfinitePackShowRoom",
				Rewards = {
					{
						GiftName = "Infinite Pack",
						GiftId = 1873904907,
						Item = v.createListReward({
							v.createSwordReward("Infinite Blade"),
							v.createSwordReward("Infinite Scythe"),
							v.createExplosionReward("Infinite Hole"),
							v.createEmoteReward("Emote427")
						}),
						ProductId = 1873904910,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Infinite Pack",
						GiftId = 1873904913,
						Item = v.createListReward({
							v.createSwordReward("Dual Infinite Blade"),
							v.createSwordReward("Dual Infinite Scythe"),
							v.createExplosionReward("Infinite Loop"),
							v.createEmoteReward("Emote426"),
							v.createEmoteReward("Emote428")
						}),
						ProductId = 1873904905,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}