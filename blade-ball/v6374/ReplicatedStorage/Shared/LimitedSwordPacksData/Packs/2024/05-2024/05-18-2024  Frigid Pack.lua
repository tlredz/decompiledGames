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
		RootFFlagStartTime = "FrigidPackRootStartTime",
		RootFFlagEndTime = "FrigidPackRootEndTime",
		FFlagStartTime = "FrigidBladeStartTime",
		FFlagEndTime = "FrigidBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Frigid Blade",
				Image = v2.Icons:GetSwordIcon("Dual Frigid Blade"),
				ShowRoom = "FrigidBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Frigid Blade",
						GiftId = 1830537367,
						Item = v.createListReward({ v.createSwordReward("Frigid Blade") }),
						ProductId = 1830537372
					},
					{
						GiftName = "Dual Frigid Blade",
						GiftId = 1830537373,
						Item = v.createListReward({
							v.createSwordReward("Dual Frigid Blade"),
							v.createExplosionReward("Frigid Twister"),
							v.createEmoteReward("Emote339")
						}),
						ProductId = 1830537376
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FrigidPackRootStartTime",
		RootFFlagEndTime = "FrigidPackRootEndTime",
		FFlagStartTime = "FrigidScytheStartTime",
		FFlagEndTime = "FrigidScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Frigid Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Frigid Scythe"),
				ShowRoom = "FrigidScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Frigid Scythe",
						GiftId = 1830537371,
						Item = v.createListReward({
							v.createSwordReward("Frigid Scythe"),
							v.createExplosionReward("Snowstorm Burst"),
							v.createEmoteReward("Emote340")
						}),
						ProductId = 1830537375
					},
					{
						GiftName = "Dual Frigid Scythe",
						GiftId = 1830537366,
						Item = v.createListReward({
							v.createSwordReward("Dual Frigid Scythe"),
							v.createExplosionReward("Snowstorm Burst"),
							v.createEmoteReward("Emote341")
						}),
						ProductId = 1830537368
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FrigidPackRootStartTime",
		RootFFlagEndTime = "FrigidPackRootEndTime",
		FFlagStartTime = "FrigidPackStartTime",
		FFlagEndTime = "FrigidPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Frigid Pack",
				Image = "rbxassetid://17526468852",
				ShowRoom = "FrigidPackShowRoom",
				Rewards = {
					{
						GiftName = "Frigid Pack",
						GiftId = 1830537377,
						Item = v.createListReward({
							v.createSwordReward("Frigid Blade"),
							v.createSwordReward("Frigid Scythe"),
							v.createExplosionReward("Frigid Twister"),
							v.createEmoteReward("Emote340")
						}),
						ProductId = 1830537370,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Frigid Pack",
						GiftId = 1830537369,
						Item = v.createListReward({
							v.createSwordReward("Dual Frigid Blade"),
							v.createSwordReward("Dual Frigid Scythe"),
							v.createExplosionReward("Snowstorm Burst"),
							v.createEmoteReward("Emote341"),
							v.createEmoteReward("Emote339")
						}),
						ProductId = 1830537374,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}