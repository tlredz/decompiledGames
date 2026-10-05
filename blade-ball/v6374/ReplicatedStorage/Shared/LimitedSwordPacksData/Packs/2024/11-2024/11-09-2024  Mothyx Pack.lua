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
		RootFFlagStartTime = "MothyxPackRootStartTime",
		RootFFlagEndTime = "MothyxPackRootEndTime",
		FFlagStartTime = "MothyxBladeStartTime",
		FFlagEndTime = "MothyxBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Mothyx Blade",
				Image = v2.Icons:GetSwordIcon("Dual Mothyx Blade"),
				ShowRoom = "MothyxBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Mothyx Blade",
						GiftId = 2654531514,
						Item = v.createListReward({ v.createSwordReward("Mothyx Blade") }),
						ProductId = 2654531515
					},
					{
						GiftName = "Dual Mothyx Blade",
						GiftId = 2654531521,
						Item = v.createListReward({
							v.createSwordReward("Dual Mothyx Blade"),
							v.createExplosionReward("Mothyx Awakening"),
							v.createEmoteReward("Emote610")
						}),
						ProductId = 2654531513
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MothyxPackRootStartTime",
		RootFFlagEndTime = "MothyxPackRootEndTime",
		FFlagStartTime = "MothyxScissorsStartTime",
		FFlagEndTime = "MothyxScissorsEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Mothyx Scissors",
				Image = v2.Icons:GetSwordIcon("Mothyx Scissors"),
				ShowRoom = "MothyxScissorsShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Mothyx Scissors",
						GiftId = 2654531522,
						Item = v.createListReward({
							v.createSwordReward("Mothyx Scissors"),
							v.createExplosionReward("Mothyx Guard"),
							v.createEmoteReward("Emote611")
						}),
						ProductId = 2654531518
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MothyxPackRootStartTime",
		RootFFlagEndTime = "MothyxPackRootEndTime",
		FFlagStartTime = "MothyxPackStartTime",
		FFlagEndTime = "MothyxPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Mothyx Pack",
				Image = "rbxassetid://86747806894321",
				ShowRoom = "MothyxPackShowRoom",
				Rewards = {
					{
						GiftName = "Mothyx Pack",
						GiftId = 2654531520,
						Item = v.createListReward({
							v.createSwordReward("Mothyx Blade"),
							v.createSwordReward("Mothyx Scissors"),
							v.createExplosionReward("Mothyx Awakening"),
							v.createEmoteReward("Emote611")
						}),
						ProductId = 2654531516,
						DiscountedFrom = 2750
					},
					{
						GiftName = "Dual Mothyx Pack",
						GiftId = 2654531519,
						Item = v.createListReward({
							v.createSwordReward("Dual Mothyx Blade"),
							v.createSwordReward("Mothyx Scissors"),
							v.createExplosionReward("Mothyx Guard"),
							v.createEmoteReward("Emote610"),
							v.createEmoteReward("Emote611")
						}),
						ProductId = 2654531517,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}