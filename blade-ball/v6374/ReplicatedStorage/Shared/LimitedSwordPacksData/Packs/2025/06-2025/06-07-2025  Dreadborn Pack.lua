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
		RootFFlagStartTime = "DreadbornPackRootStartTime",
		RootFFlagEndTime = "DreadbornPackRootEndTime",
		FFlagStartTime = "DreadbornBladeStartTime",
		FFlagEndTime = "DreadbornBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dreadborn Blade",
				Image = v2.Icons:GetSwordIcon("Dual Dreadborn Blade"),
				ShowRoom = "DreadbornBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Dreadborn Blade",
						GiftId = 3302187049,
						Item = v.createListReward({ v.createSwordReward("Dreadborn Blade") }),
						ProductId = 3302187045
					},
					{
						GiftName = "Dual Dreadborn Blade",
						GiftId = 3302187054,
						Item = v.createListReward({
							v.createSwordReward("Dual Dreadborn Blade"),
							v.createExplosionReward("Dreadborn Eyes"),
							v.createEmoteReward("Emote950")
						}),
						ProductId = 3302187055
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DreadbornPackRootStartTime",
		RootFFlagEndTime = "DreadbornPackRootEndTime",
		FFlagStartTime = "DreadbornScytheStartTime",
		FFlagEndTime = "DreadbornScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dreadborn Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Dreadborn Scythe"),
				ShowRoom = "DreadbornScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Dreadborn Scythe",
						GiftId = 3302187048,
						Item = v.createListReward({
							v.createSwordReward("Dreadborn Scythe"),
							v.createExplosionReward("Dreadborn Light"),
							v.createEmoteReward("Emote949")
						}),
						ProductId = 3302187052
					},
					{
						GiftName = "Dual Dreadborn Scythe",
						GiftId = 3302187051,
						Item = v.createListReward({
							v.createSwordReward("Dual Dreadborn Scythe"),
							v.createExplosionReward("Dreadborn Light"),
							v.createEmoteReward("Emote948")
						}),
						ProductId = 3302187057
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DreadbornPackRootStartTime",
		RootFFlagEndTime = "DreadbornPackRootEndTime",
		FFlagStartTime = "DreadbornPackStartTime",
		FFlagEndTime = "DreadbornPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dreadborn Pack",
				Image = "rbxassetid://118297266416039",
				ShowRoom = "DreadbornPackShowRoom",
				Rewards = {
					{
						GiftName = "Dreadborn Pack",
						GiftId = 3302187053,
						Item = v.createListReward({
							v.createSwordReward("Dreadborn Blade"),
							v.createSwordReward("Dreadborn Scythe"),
							v.createExplosionReward("Dreadborn Eyes"),
							v.createEmoteReward("Emote949")
						}),
						ProductId = 3302187047,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Dreadborn Pack",
						GiftId = 3302187050,
						Item = v.createListReward({
							v.createSwordReward("Dual Dreadborn Blade"),
							v.createSwordReward("Dual Dreadborn Scythe"),
							v.createExplosionReward("Dreadborn Light"),
							v.createEmoteReward("Emote950"),
							v.createEmoteReward("Emote948")
						}),
						ProductId = 3302187056,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}