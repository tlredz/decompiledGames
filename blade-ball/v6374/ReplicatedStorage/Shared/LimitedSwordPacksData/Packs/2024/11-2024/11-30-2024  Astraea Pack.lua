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
		RootFFlagStartTime = "AstraeaPackRootStartTime",
		RootFFlagEndTime = "AstraeaPackRootEndTime",
		FFlagStartTime = "AstraeaBladeStartTime",
		FFlagEndTime = "AstraeaBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astraea Blade",
				Image = v2.Icons:GetSwordIcon("Astraea Blade"),
				ShowRoom = "AstraeaBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Astraea Blade",
						GiftId = 2666789697,
						Item = v.createListReward({ v.createSwordReward("Astraea Blade") }),
						ProductId = 2666789706,
						DiscountedFrom = 399
					},
					{
						GiftName = "Dual Astraea Blade",
						GiftId = 2666789702,
						Item = v.createListReward({
							v.createSwordReward("Dual Astraea Blade"),
							v.createExplosionReward("Astraea Star"),
							v.createEmoteReward("Emote654")
						}),
						ProductId = 2666789708,
						DiscountedFrom = 1299
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AstraeaPackRootStartTime",
		RootFFlagEndTime = "AstraeaPackRootEndTime",
		FFlagStartTime = "AstraeaPackStartTime",
		FFlagEndTime = "AstraeaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astraea Pack",
				Image = "rbxassetid://94465754191193",
				ShowRoom = "AstraeaPackShowRoom",
				Rewards = {
					{
						GiftName = "Astraea Pack",
						GiftId = 2666789703,
						Item = v.createListReward({
							v.createSwordReward("Astraea Blade"),
							v.createSwordReward("Dual Astraea Blade"),
							v.createExplosionReward("Astraea Star"),
							v.createEmoteReward("Emote654")
						}),
						ProductId = 2666789707,
						DiscountedFrom = 2000
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AstraeaPackRootStartTime",
		RootFFlagEndTime = "AstraeaPackRootEndTime",
		FFlagStartTime = "AstraeaStaffStartTime",
		FFlagEndTime = "AstraeaStaffEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astraea Staff",
				Image = "rbxassetid://91501530569994",
				ShowRoom = "AstraeaStaffShowRoom",
				Stock = "Astraea Staff",
				Rewards = {
					{
						GiftName = "Astraea Staff",
						GiftId = 2666789699,
						Item = v.createListReward({
							v.createSwordReward("Astraea Staff"),
							v.createExplosionReward("Astraea Orb"),
							v.createEmoteReward("Emote655")
						}),
						ProductId = 2666789704
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LeviathanSetRootStartTime",
		RootFFlagEndTime = "LeviathanSetRootEndTime",
		FFlagStartTime = "LeviathanSetStartTime",
		FFlagEndTime = "LeviathanSetEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Leviathan Set",
				Image = "rbxassetid://116574095080347",
				ShowRoom = "LeviathanSetShowRoom",
				Stock = "Dual Leviathan Set",
				Rewards = {
					{
						GiftName = "Dual Leviathan Set",
						GiftId = 2666876724,
						Item = v.createListReward({
							v.createSwordReward("Dual Leviathan Set"),
							v.createExplosionReward("Serpent Anchor"),
							v.createEmoteReward("Emote657")
						}),
						ProductId = 2666876723
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AstraeaPackRootStartTime",
		RootFFlagEndTime = "AstraeaPackRootEndTime",
		FFlagStartTime = "AstraeaSetStartTime",
		FFlagEndTime = "AstraeaSetEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dual Astraea Set",
				Image = "rbxassetid://105974962201153",
				ShowRoom = "AstraeaSetShowRoom",
				Stock = "Dual Astraea Set",
				Rewards = {
					{
						GiftName = "Dual Astraea Set",
						GiftId = 2666789705,
						Item = v.createListReward({
							v.createSwordReward("Dual Astraea Set"),
							v.createExplosionReward("Astraea Guidance"),
							v.createEmoteReward("Emote656")
						}),
						ProductId = 2666789698
					}
				}
			}
		}
	}
}