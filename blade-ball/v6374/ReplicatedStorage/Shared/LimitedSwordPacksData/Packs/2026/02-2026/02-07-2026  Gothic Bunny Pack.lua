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
		RootFFlagStartTime = "GothicBunnyPackRootStartTime",
		RootFFlagEndTime = "GothicBunnyPackRootEndTime",
		FFlagStartTime = "GothicBunnyBladeStartTime",
		FFlagEndTime = "GothicBunnyBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Bunny Blade",
				Image = v2.Icons:GetSwordIcon("Dual Gothic Bunny Blade"),
				ShowRoom = "GothicBunnyBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gothic Bunny Blade",
						GiftId = 3533095923,
						Item = v.createListReward({ v.createSwordReward("Gothic Bunny Blade") }),
						ProductId = 3533095929
					},
					{
						GiftName = "Dual Gothic Bunny Blade",
						GiftId = 3533095933,
						Item = v.createListReward({
							v.createSwordReward("Dual Gothic Bunny Blade"),
							v.createExplosionReward("Affection Hopper"),
							v.createEmoteReward("Emote1151")
						}),
						ProductId = 3533095925
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GothicBunnyPackRootStartTime",
		RootFFlagEndTime = "GothicBunnyPackRootEndTime",
		FFlagStartTime = "GothicBunnyScytheStartTime",
		FFlagEndTime = "GothicBunnyScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Bunny Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Gothic Bunny Scythe"),
				ShowRoom = "GothicBunnyScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gothic Bunny Scythe",
						GiftId = 3533095928,
						Item = v.createListReward({
							v.createSwordReward("Gothic Bunny Scythe"),
							v.createExplosionReward("Superstar Bunny"),
							v.createEmoteReward("Emote1153")
						}),
						ProductId = 3533095930
					},
					{
						GiftName = "Dual Gothic Bunny Scythe",
						GiftId = 3533095934,
						Item = v.createListReward({
							v.createSwordReward("Dual Gothic Bunny Scythe"),
							v.createExplosionReward("Superstar Bunny"),
							v.createEmoteReward("Emote1152")
						}),
						ProductId = 3533095924
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GothicBunnyPackRootStartTime",
		RootFFlagEndTime = "GothicBunnyPackRootEndTime",
		FFlagStartTime = "GothicBunnyPackStartTime",
		FFlagEndTime = "GothicBunnyPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gothic Bunny Pack",
				Image = "rbxassetid://112883937856123",
				ShowRoom = "GothicBunnyPackShowRoom",
				Rewards = {
					{
						GiftName = "Gothic Bunny Pack",
						GiftId = 3533095932,
						Item = v.createListReward({
							v.createSwordReward("Gothic Bunny Blade"),
							v.createSwordReward("Gothic Bunny Scythe"),
							v.createExplosionReward("Affection Hopper"),
							v.createEmoteReward("Emote1153")
						}),
						ProductId = 3533095931,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Gothic Bunny Pack",
						GiftId = 3533095926,
						Item = v.createListReward({
							v.createSwordReward("Dual Gothic Bunny Blade"),
							v.createSwordReward("Dual Gothic Bunny Scythe"),
							v.createExplosionReward("Superstar Bunny"),
							v.createEmoteReward("Emote1151"),
							v.createEmoteReward("Emote1152")
						}),
						ProductId = 3533095927,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}