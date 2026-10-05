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
		RootFFlagStartTime = "BloodmoonPackRootStartTime",
		RootFFlagEndTime = "BloodmoonPackRootEndTime",
		FFlagStartTime = "BloodmoonBladeStartTime",
		FFlagEndTime = "BloodmoonBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodmoon Blade",
				Image = v2.Icons:GetSwordIcon("Dual Bloodmoon Blade"),
				ShowRoom = "BloodmoonBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloodmoon Blade",
						GiftId = 3347607725,
						Item = v.createListReward({ v.createSwordReward("Bloodmoon Blade") }),
						ProductId = 3347607731
					},
					{
						GiftName = "Dual Bloodmoon Blade",
						GiftId = 3347607722,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodmoon Blade"),
							v.createExplosionReward("Red Crescent"),
							v.createEmoteReward("Emote995")
						}),
						ProductId = 3347607724
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodmoonPackRootStartTime",
		RootFFlagEndTime = "BloodmoonPackRootEndTime",
		FFlagStartTime = "BloodmoonScytheStartTime",
		FFlagEndTime = "BloodmoonScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodmoon Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Bloodmoon Scythe"),
				ShowRoom = "BloodmoonScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloodmoon Scythe",
						GiftId = 3347607736,
						Item = v.createListReward({
							v.createSwordReward("Bloodmoon Scythe"),
							v.createExplosionReward("Crimson Skies"),
							v.createEmoteReward("Emote996")
						}),
						ProductId = 3347607735
					},
					{
						GiftName = "Dual Bloodmoon Scythe",
						GiftId = 3347607733,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodmoon Scythe"),
							v.createExplosionReward("Crimson Skies"),
							v.createEmoteReward("Emote997")
						}),
						ProductId = 3347607728
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodmoonPackRootStartTime",
		RootFFlagEndTime = "BloodmoonPackRootEndTime",
		FFlagStartTime = "BloodmoonPackStartTime",
		FFlagEndTime = "BloodmoonPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodmoon Pack",
				Image = "rbxassetid://86532875206507",
				ShowRoom = "BloodmoonPackShowRoom",
				Rewards = {
					{
						GiftName = "Bloodmoon Pack",
						GiftId = 3347607727,
						Item = v.createListReward({
							v.createSwordReward("Bloodmoon Blade"),
							v.createSwordReward("Bloodmoon Scythe"),
							v.createExplosionReward("Red Crescent"),
							v.createEmoteReward("Emote996")
						}),
						ProductId = 3347607730,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Bloodmoon Pack",
						GiftId = 3347607726,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodmoon Blade"),
							v.createSwordReward("Dual Bloodmoon Scythe"),
							v.createExplosionReward("Crimson Skies"),
							v.createEmoteReward("Emote995"),
							v.createEmoteReward("Emote997")
						}),
						ProductId = 3347607734,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}