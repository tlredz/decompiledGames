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
		RootFFlagStartTime = "AbyssalPackRootStartTime",
		RootFFlagEndTime = "AbyssalPackRootEndTime",
		FFlagStartTime = "AbyssalBladeStartTime",
		FFlagEndTime = "AbyssalBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Abyssal Blade",
				Image = v2.Icons:GetSwordIcon("Dual Abyssal Blade"),
				ShowRoom = "AbyssalBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Abyssal Blade",
						GiftId = 1844589014,
						Item = v.createListReward({ v.createSwordReward("Abyssal Blade") }),
						ProductId = 1844589009
					},
					{
						GiftName = "Dual Abyssal Blade",
						GiftId = 1844589011,
						Item = v.createListReward({
							v.createSwordReward("Dual Abyssal Blade"),
							v.createExplosionReward("Abyssal Astrology"),
							v.createEmoteReward("Emote375")
						}),
						ProductId = 1844589010
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AbyssalPackRootStartTime",
		RootFFlagEndTime = "AbyssalPackRootEndTime",
		FFlagStartTime = "AbyssalShieldStartTime",
		FFlagEndTime = "AbyssalShieldEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Abyssal Shield",
				Image = v2.Icons:GetSwordIcon("Abyssal Shield"),
				ShowRoom = "AbyssalShieldShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Abyssal Shield",
						GiftId = 1844589013,
						Item = v.createListReward({
							v.createSwordReward("Abyssal Shield"),
							v.createExplosionReward("Thor's Deflection"),
							v.createEmoteReward("Emote376")
						}),
						ProductId = 1844589015
					},
					{
						GiftName = "Dual Abyssal Set",
						GiftId = 1844730066,
						Item = v.createListReward({
							v.createSwordReward("Dual Abyssal Set"),
							v.createExplosionReward("Thor's Deflection"),
							v.createEmoteReward("Emote377")
						}),
						ProductId = 1844730067
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AbyssalPackRootStartTime",
		RootFFlagEndTime = "AbyssalPackRootEndTime",
		FFlagStartTime = "AbyssalPackStartTime",
		FFlagEndTime = "AbyssalPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Abyssal Pack",
				Image = "rbxassetid://17774191210",
				ShowRoom = "AbyssalPackShowRoom",
				Rewards = {
					{
						GiftName = "Abyssal Pack",
						GiftId = 1844589012,
						Item = v.createListReward({
							v.createSwordReward("Abyssal Blade"),
							v.createSwordReward("Abyssal Shield"),
							v.createExplosionReward("Abyssal Astrology"),
							v.createEmoteReward("Emote376")
						}),
						ProductId = 1844589016,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Abyssal Pack",
						GiftId = 1844589008,
						Item = v.createListReward({
							v.createSwordReward("Dual Abyssal Set"),
							v.createSwordReward("Dual Abyssal Blade"),
							v.createExplosionReward("Thor's Deflection"),
							v.createEmoteReward("Emote375"),
							v.createEmoteReward("Emote377")
						}),
						ProductId = 1844589007,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}