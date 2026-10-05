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
		RootFFlagStartTime = "HeartbreakerPackRootStartTime",
		RootFFlagEndTime = "HeartbreakerPackRootEndTime",
		FFlagStartTime = "HeartbreakerBladeStartTime",
		FFlagEndTime = "HeartbreakerBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heartbreaker Blade",
				Image = v2.Icons:GetSwordIcon("Dual Heartbreaker Blade"),
				ShowRoom = "HeartbreakerBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heartbreaker Blade",
						GiftId = 3428082782,
						Item = v.createListReward({ v.createSwordReward("Heartbreaker Blade") }),
						ProductId = 3428082794
					},
					{
						GiftName = "Dual Heartbreaker Blade",
						GiftId = 3428082791,
						Item = v.createListReward({
							v.createSwordReward("Dual Heartbreaker Blade"),
							v.createExplosionReward("Love Pop"),
							v.createEmoteReward("Emote1055")
						}),
						ProductId = 3428082783
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeartbreakerPackRootStartTime",
		RootFFlagEndTime = "HeartbreakerPackRootEndTime",
		FFlagStartTime = "HeartbreakerScytheStartTime",
		FFlagEndTime = "HeartbreakerScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heartbreaker Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Heartbreaker Scythe"),
				ShowRoom = "HeartbreakerScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Heartbreaker Scythe",
						GiftId = 3428082784,
						Item = v.createListReward({
							v.createSwordReward("Heartbreaker Scythe"),
							v.createExplosionReward("Love Bow"),
							v.createEmoteReward("Emote1056")
						}),
						ProductId = 3428082790
					},
					{
						GiftName = "Dual Heartbreaker Scythe",
						GiftId = 3428082781,
						Item = v.createListReward({
							v.createSwordReward("Dual Heartbreaker Scythe"),
							v.createExplosionReward("Love Bow"),
							v.createEmoteReward("Emote1057")
						}),
						ProductId = 3428082788
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeartbreakerPackRootStartTime",
		RootFFlagEndTime = "HeartbreakerPackRootEndTime",
		FFlagStartTime = "HeartbreakerPackStartTime",
		FFlagEndTime = "HeartbreakerPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Heartbreaker Pack",
				Image = "rbxassetid://106336819959979",
				ShowRoom = "HeartbreakerPackShowRoom",
				Rewards = {
					{
						GiftName = "Heartbreaker Pack",
						GiftId = 3428082786,
						Item = v.createListReward({
							v.createSwordReward("Heartbreaker Blade"),
							v.createSwordReward("Heartbreaker Scythe"),
							v.createExplosionReward("Love Pop"),
							v.createEmoteReward("Emote1056")
						}),
						ProductId = 3428082789,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Heartbreaker Pack",
						GiftId = 3428082787,
						Item = v.createListReward({
							v.createSwordReward("Dual Heartbreaker Blade"),
							v.createSwordReward("Dual Heartbreaker Scythe"),
							v.createExplosionReward("Love Bow"),
							v.createEmoteReward("Emote1055"),
							v.createEmoteReward("Emote1057")
						}),
						ProductId = 3428082780,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}