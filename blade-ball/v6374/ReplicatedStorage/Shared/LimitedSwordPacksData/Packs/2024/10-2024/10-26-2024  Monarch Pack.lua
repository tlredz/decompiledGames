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
		RootFFlagStartTime = "MonarchPackRootStartTime",
		RootFFlagEndTime = "MonarchPackRootEndTime",
		FFlagStartTime = "MonarchBladeStartTime",
		FFlagEndTime = "MonarchBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Monarch Blade",
				Image = v2.Icons:GetSwordIcon("Dual Monarch Blade"),
				ShowRoom = "MonarchBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Monarch Blade",
						GiftId = 2319193586,
						Item = v.createListReward({ v.createSwordReward("Monarch Blade") }),
						ProductId = 2319193584
					},
					{
						GiftName = "Dual Monarch Blade",
						GiftId = 2319193576,
						Item = v.createListReward({
							v.createSwordReward("Dual Monarch Blade"),
							v.createExplosionReward("Violet Iris"),
							v.createEmoteReward("Emote589")
						}),
						ProductId = 2319193585
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MonarchPackRootStartTime",
		RootFFlagEndTime = "MonarchPackRootEndTime",
		FFlagStartTime = "MonarchShieldStartTime",
		FFlagEndTime = "MonarchShieldEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Monarch Shield",
				Image = v2.Icons:GetSwordIcon("Dual Monarch Set"),
				ShowRoom = "MonarchShieldShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Monarch Shield",
						GiftId = 2319193582,
						Item = v.createListReward({
							v.createSwordReward("Monarch Shield"),
							v.createExplosionReward("Monarch Light"),
							v.createEmoteReward("Emote590")
						}),
						ProductId = 2319193575
					},
					{
						GiftName = "Dual Monarch Set",
						GiftId = 2319193580,
						Item = v.createListReward({
							v.createSwordReward("Dual Monarch Set"),
							v.createExplosionReward("Monarch Light"),
							v.createEmoteReward("Emote591")
						}),
						ProductId = 2319193579
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MonarchPackRootStartTime",
		RootFFlagEndTime = "MonarchPackRootEndTime",
		FFlagStartTime = "MonarchPackStartTime",
		FFlagEndTime = "MonarchPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Monarch Pack",
				Image = "rbxassetid://102438111125400",
				ShowRoom = "MonarchPackShowRoom",
				Rewards = {
					{
						GiftName = "Monarch Pack",
						GiftId = 2319193577,
						Item = v.createListReward({
							v.createSwordReward("Monarch Blade"),
							v.createSwordReward("Monarch Shield"),
							v.createExplosionReward("Violet Iris"),
							v.createEmoteReward("Emote590")
						}),
						ProductId = 2319193578,
						DiscountedFrom = 1599
					},
					{
						GiftName = "Dual Monarch Pack",
						GiftId = 2319193588,
						Item = v.createListReward({
							v.createSwordReward("Dual Monarch Blade"),
							v.createSwordReward("Dual Monarch Set"),
							v.createExplosionReward("Monarch Light"),
							v.createEmoteReward("Emote589"),
							v.createEmoteReward("Emote591")
						}),
						ProductId = 2319193583,
						DiscountedFrom = 3499
					}
				}
			}
		}
	}
}