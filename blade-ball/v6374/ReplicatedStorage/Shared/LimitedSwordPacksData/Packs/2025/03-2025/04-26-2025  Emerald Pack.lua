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
		RootFFlagStartTime = "EmeraldPackRootStartTime",
		RootFFlagEndTime = "EmeraldPackRootEndTime",
		FFlagStartTime = "EmeraldBladeStartTime",
		FFlagEndTime = "EmeraldBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Emerald Blade",
				Image = v2.Icons:GetSwordIcon("Dual Emerald Blade"),
				ShowRoom = "EmeraldBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Emerald Blade",
						GiftId = 3274261821,
						Item = v.createListReward({ v.createSwordReward("Emerald Blade") }),
						ProductId = 3274261822
					},
					{
						GiftName = "Dual Emerald Blade",
						GiftId = 3274261830,
						Item = v.createListReward({
							v.createSwordReward("Dual Emerald Blade"),
							v.createExplosionReward("Emerald Halo"),
							v.createEmoteReward("Emote895")
						}),
						ProductId = 3274261826
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "EmeraldPackRootStartTime",
		RootFFlagEndTime = "EmeraldPackRootEndTime",
		FFlagStartTime = "EmeraldParasolStartTime",
		FFlagEndTime = "EmeraldParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Emerald Parasol",
				Image = v2.Icons:GetSwordIcon("Emerald Parasol"),
				ShowRoom = "EmeraldParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Emerald Parasol",
						GiftId = 3274261829,
						Item = v.createListReward({
							v.createSwordReward("Emerald Parasol"),
							v.createExplosionReward("Emerald Beam"),
							v.createEmoteReward("Emote896")
						}),
						ProductId = 3274261823
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "EmeraldPackRootStartTime",
		RootFFlagEndTime = "EmeraldPackRootEndTime",
		FFlagStartTime = "EmeraldPackStartTime",
		FFlagEndTime = "EmeraldPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Emerald Pack",
				Image = "rbxassetid://83830006587440",
				ShowRoom = "EmeraldPackShowRoom",
				Rewards = {
					{
						GiftName = "Emerald Pack",
						GiftId = 3274261825,
						Item = v.createListReward({
							v.createSwordReward("Emerald Blade"),
							v.createSwordReward("Emerald Parasol"),
							v.createExplosionReward("Emerald Halo"),
							v.createEmoteReward("Emote896")
						}),
						ProductId = 3274261827,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Emerald Pack",
						GiftId = 3274261824,
						Item = v.createListReward({
							v.createSwordReward("Dual Emerald Blade"),
							v.createSwordReward("Emerald Parasol"),
							v.createExplosionReward("Emerald Beam"),
							v.createEmoteReward("Emote896"),
							v.createEmoteReward("Emote895")
						}),
						ProductId = 3274261828,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}