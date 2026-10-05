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
		RootFFlagStartTime = "JadeRootStartTime",
		RootFFlagEndTime = "JadeRootEndTime",
		FFlagStartTime = "JadeBladeStartTime",
		FFlagEndTime = "JadeBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Jade Blade",
				Image = v2.Icons:GetSwordIcon("Dual Jade Blade"),
				ShowRoom = "JadeBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Jade Blade",
						GiftId = 3608158166,
						Item = v.createListReward({ v.createSwordReward("Jade Blade") }),
						ProductId = 3608158168
					},
					{
						GiftName = "Dual Jade Blade",
						GiftId = 3608158171,
						Item = v.createListReward({
							v.createSwordReward("Dual Jade Blade"),
							v.createExplosionReward("Jade Crystallisation Explosion"),
							v.createEmoteReward("Emote1244")
						}),
						ProductId = 3608158176
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "JadeRootStartTime",
		RootFFlagEndTime = "JadeRootEndTime",
		FFlagStartTime = "JadeScytheStartTime",
		FFlagEndTime = "JadeScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Jade Scythe",
				Image = v2.Icons:GetSwordIcon("Jade Scythe"),
				ShowRoom = "JadeScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Jade Scythe",
						GiftId = 3608158182,
						Item = v.createListReward({
							v.createSwordReward("Jade Scythe"),
							v.createExplosionReward("Jade Blessing Explosion"),
							v.createEmoteReward("Emote1242")
						}),
						ProductId = 3608158189
					},
					{
						GiftName = "Dual Jade Scythe",
						GiftId = 3608158197,
						Item = v.createListReward({
							v.createSwordReward("Dual Jade Scythe"),
							v.createExplosionReward("Jade Blessing Explosion"),
							v.createEmoteReward("Emote1243")
						}),
						ProductId = 3608158208
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "JadeRootStartTime",
		RootFFlagEndTime = "JadeRootEndTime",
		FFlagStartTime = "JadePackStartTime",
		FFlagEndTime = "JadePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Jade Pack",
				Image = "rbxassetid://95855202495545",
				ShowRoom = "JadePackShowRoom",
				Rewards = {
					{
						GiftName = "Jade Pack",
						GiftId = 3608158215,
						Item = v.createListReward({
							v.createSwordReward("Jade Blade"),
							v.createSwordReward("Jade Scythe"),
							v.createExplosionReward("Jade Crystallisation Explosion"),
							v.createEmoteReward("Emote1242")
						}),
						ProductId = 3608158219,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Jade Pack",
						GiftId = 3608158221,
						Item = v.createListReward({
							v.createSwordReward("Dual Jade Blade"),
							v.createSwordReward("Dual Jade Scythe"),
							v.createExplosionReward("Jade Blessing Explosion"),
							v.createEmoteReward("Emote1244"),
							v.createEmoteReward("Emote1243")
						}),
						ProductId = 3608158223,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}