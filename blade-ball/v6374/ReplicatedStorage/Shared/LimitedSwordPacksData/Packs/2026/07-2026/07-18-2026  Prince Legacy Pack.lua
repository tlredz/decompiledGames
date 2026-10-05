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
		RootFFlagStartTime = "PrinceLegacyRootStartTime",
		RootFFlagEndTime = "PrinceLegacyRootEndTime",
		FFlagStartTime = "PrinceLegacyBladeStartTime",
		FFlagEndTime = "PrinceLegacyBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prince Legacy Blade",
				Image = v2.Icons:GetSwordIcon("Dual Prince Legacy Blade"),
				ShowRoom = "PrinceLegacyBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Prince Legacy Blade",
						GiftId = 3610475280,
						Item = v.createListReward({ v.createSwordReward("Prince Legacy Blade") }),
						ProductId = 3610475285
					},
					{
						GiftName = "Dual Prince Legacy Blade",
						GiftId = 3610475286,
						Item = v.createListReward({
							v.createSwordReward("Dual Prince Legacy Blade"),
							v.createExplosionReward("Prince Landing Explosion"),
							v.createEmoteReward("Emote1251")
						}),
						ProductId = 3610475290
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrinceLegacyRootStartTime",
		RootFFlagEndTime = "PrinceLegacyRootEndTime",
		FFlagStartTime = "PrinceLegacyScytheStartTime",
		FFlagEndTime = "PrinceLegacyScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prince Legacy Scythe",
				Image = v2.Icons:GetSwordIcon("Prince Legacy Scythe"),
				ShowRoom = "PrinceLegacyScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Prince Legacy Scythe",
						GiftId = 3610475294,
						Item = v.createListReward({
							v.createSwordReward("Prince Legacy Scythe"),
							v.createExplosionReward("Prince Landing Explosion"),
							v.createEmoteReward("Emote1252")
						}),
						ProductId = 3610475303
					},
					{
						GiftName = "Dual Prince Legacy Scythe",
						GiftId = 3610475304,
						Item = v.createListReward({
							v.createSwordReward("Dual Prince Legacy Scythe"),
							v.createExplosionReward("Prince Legacy Explosion"),
							v.createEmoteReward("Emote1253")
						}),
						ProductId = 3610475306
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PrinceLegacyRootStartTime",
		RootFFlagEndTime = "PrinceLegacyRootEndTime",
		FFlagStartTime = "PrinceLegacyPackStartTime",
		FFlagEndTime = "PrinceLegacyPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prince Legacy Pack",
				Image = "rbxassetid://113091206312051",
				ShowRoom = "PrinceLegacyPackShowRoom",
				Rewards = {
					{
						GiftName = "Prince Legacy Pack",
						GiftId = 3610475310,
						Item = v.createListReward({
							v.createSwordReward("Prince Legacy Blade"),
							v.createSwordReward("Prince Legacy Scythe"),
							v.createExplosionReward("Prince Landing Explosion"),
							v.createEmoteReward("Emote1252")
						}),
						ProductId = 3610475315,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Prince Legacy Pack",
						GiftId = 3610475320,
						Item = v.createListReward({
							v.createSwordReward("Dual Prince Legacy Blade"),
							v.createSwordReward("Dual Prince Legacy Scythe"),
							v.createExplosionReward("Prince Legacy Explosion"),
							v.createEmoteReward("Emote1251"),
							v.createEmoteReward("Emote1253")
						}),
						ProductId = 3610475324,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}