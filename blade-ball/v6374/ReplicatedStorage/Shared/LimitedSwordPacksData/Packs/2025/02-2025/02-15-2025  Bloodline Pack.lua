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
		RootFFlagStartTime = "BloodlinePackRootStartTime",
		RootFFlagEndTime = "BloodlinePackRootEndTime",
		FFlagStartTime = "BloodlineBladeStartTime",
		FFlagEndTime = "BloodlineBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodline Blade",
				Image = v2.Icons:GetSwordIcon("Dual Bloodline Blade"),
				ShowRoom = "BloodlineBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloodline Blade",
						GiftId = 3030391521,
						Item = v.createListReward({ v.createSwordReward("Bloodline Blade") }),
						ProductId = 3030391518
					},
					{
						GiftName = "Dual Bloodline Blade",
						GiftId = 3030391516,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodline Blade"),
							v.createExplosionReward("Bloodline Cataclysm"),
							v.createEmoteReward("Emote789")
						}),
						ProductId = 3030391523
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodlinePackRootStartTime",
		RootFFlagEndTime = "BloodlinePackRootEndTime",
		FFlagStartTime = "BloodlineScytheStartTime",
		FFlagEndTime = "BloodlineScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodline Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Bloodline Scythe"),
				ShowRoom = "BloodlineScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloodline Scythe",
						GiftId = 3030391517,
						Item = v.createListReward({
							v.createSwordReward("Bloodline Scythe"),
							v.createExplosionReward("Bloodline Triangle"),
							v.createEmoteReward("Emote790")
						}),
						ProductId = 3030391525
					},
					{
						GiftName = "Dual Bloodline Scythe",
						GiftId = 3030391520,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodline Scythe"),
							v.createExplosionReward("Bloodline Triangle"),
							v.createEmoteReward("Emote791")
						}),
						ProductId = 3030391515
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodlinePackRootStartTime",
		RootFFlagEndTime = "BloodlinePackRootEndTime",
		FFlagStartTime = "BloodlinePackStartTime",
		FFlagEndTime = "BloodlinePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodline Pack",
				Image = "rbxassetid://77065147330067",
				ShowRoom = "BloodlinePackShowRoom",
				Rewards = {
					{
						GiftName = "Bloodline Pack",
						GiftId = 3030391522,
						Item = v.createListReward({
							v.createSwordReward("Bloodline Blade"),
							v.createSwordReward("Bloodline Scythe"),
							v.createExplosionReward("Bloodline Cataclysm"),
							v.createEmoteReward("Emote790")
						}),
						ProductId = 3030391526,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Bloodline Pack",
						GiftId = 3030391519,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodline Blade"),
							v.createSwordReward("Dual Bloodline Scythe"),
							v.createExplosionReward("Bloodline Triangle"),
							v.createEmoteReward("Emote789"),
							v.createEmoteReward("Emote791")
						}),
						ProductId = 3030391528,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}