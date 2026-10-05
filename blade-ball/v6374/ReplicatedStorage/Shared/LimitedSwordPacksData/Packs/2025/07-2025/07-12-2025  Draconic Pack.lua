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
		RootFFlagStartTime = "DraconicPackRootStartTime",
		RootFFlagEndTime = "DraconicPackRootEndTime",
		FFlagStartTime = "DraconicBladeStartTime",
		FFlagEndTime = "DraconicBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Draconic Blade",
				Image = v2.Icons:GetSwordIcon("Dual Draconic Blade"),
				ShowRoom = "DraconicBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Draconic Blade",
						GiftId = 3332429123,
						Item = v.createListReward({ v.createSwordReward("Draconic Blade") }),
						ProductId = 3332429125
					},
					{
						GiftName = "Dual Draconic Blade",
						GiftId = 3332429118,
						Item = v.createListReward({
							v.createSwordReward("Dual Draconic Blade"),
							v.createExplosionReward("Draconic Burst"),
							v.createEmoteReward("Emote976")
						}),
						ProductId = 3332429119
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DraconicPackRootStartTime",
		RootFFlagEndTime = "DraconicPackRootEndTime",
		FFlagStartTime = "DraconicTwinbladeStartTime",
		FFlagEndTime = "DraconicTwinbladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Draconic Twinblade",
				Image = v2.Icons:GetSwordIcon("Dual Draconic Twinblade"),
				ShowRoom = "DraconicTwinbladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Draconic Twinblade",
						GiftId = 3332429122,
						Item = v.createListReward({
							v.createSwordReward("Draconic Twinblade"),
							v.createExplosionReward("Draconic Runes"),
							v.createEmoteReward("Emote977")
						}),
						ProductId = 3332429117
					},
					{
						GiftName = "Dual Draconic Twinblade",
						GiftId = 3332429124,
						Item = v.createListReward({
							v.createSwordReward("Dual Draconic Twinblade"),
							v.createExplosionReward("Draconic Runes"),
							v.createEmoteReward("Emote978")
						}),
						ProductId = 3332429121
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DraconicPackRootStartTime",
		RootFFlagEndTime = "DraconicPackRootEndTime",
		FFlagStartTime = "DraconicPackStartTime",
		FFlagEndTime = "DraconicPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Draconic Pack",
				Image = "rbxassetid://124753236579070",
				ShowRoom = "DraconicPackShowRoom",
				Rewards = {
					{
						GiftName = "Draconic Pack",
						GiftId = 3332429116,
						Item = v.createListReward({
							v.createSwordReward("Draconic Blade"),
							v.createSwordReward("Draconic Twinblade"),
							v.createExplosionReward("Draconic Burst"),
							v.createEmoteReward("Emote977")
						}),
						ProductId = 3332429115,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Draconic Pack",
						GiftId = 3332429120,
						Item = v.createListReward({
							v.createSwordReward("Dual Draconic Blade"),
							v.createSwordReward("Dual Draconic Twinblade"),
							v.createExplosionReward("Draconic Runes"),
							v.createEmoteReward("Emote976"),
							v.createEmoteReward("Emote978")
						}),
						ProductId = 3332429113,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}