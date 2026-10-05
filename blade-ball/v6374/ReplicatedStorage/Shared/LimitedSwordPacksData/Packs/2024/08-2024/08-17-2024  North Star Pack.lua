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
		RootFFlagStartTime = "NorthPackRootStartTime",
		RootFFlagEndTime = "NorthPackRootEndTime",
		FFlagStartTime = "NorthBladeStartTime",
		FFlagEndTime = "NorthBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "North Blade",
				Image = v2.Icons:GetSwordIcon("Dual North Blade"),
				ShowRoom = "NorthBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "North Blade",
						GiftId = 1910206453,
						Item = v.createListReward({ v.createSwordReward("North Blade") }),
						ProductId = 1910206454
					},
					{
						GiftName = "Dual North Blade",
						GiftId = 1910206458,
						Item = v.createListReward({
							v.createSwordReward("Dual North Blade"),
							v.createExplosionReward("North Star Shatter"),
							v.createEmoteReward("Emote495")
						}),
						ProductId = 1910206459
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NorthPackRootStartTime",
		RootFFlagEndTime = "NorthPackRootEndTime",
		FFlagStartTime = "NorthStarStartTime",
		FFlagEndTime = "NorthStarEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "North Star",
				Image = v2.Icons:GetSwordIcon("North Star"),
				ShowRoom = "NorthStarShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "North Star",
						GiftId = 1910206461,
						Item = v.createListReward({
							v.createSwordReward("North Star"),
							v.createExplosionReward("Stars Collapse"),
							v.createEmoteReward("Emote496")
						}),
						ProductId = 1910206456
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NorthPackRootStartTime",
		RootFFlagEndTime = "NorthPackRootEndTime",
		FFlagStartTime = "NorthPackStartTime",
		FFlagEndTime = "NorthPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "North Star Pack",
				Image = "rbxassetid://18977631379",
				ShowRoom = "NorthPackShowRoom",
				Rewards = {
					{
						GiftName = "North Star Pack",
						GiftId = 1910206460,
						Item = v.createListReward({
							v.createSwordReward("North Blade"),
							v.createSwordReward("North Star"),
							v.createExplosionReward("North Star Shatter"),
							v.createEmoteReward("Emote495")
						}),
						ProductId = 1910206455,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual North Star Pack",
						GiftId = 1910206452,
						Item = v.createListReward({
							v.createSwordReward("Dual North Blade"),
							v.createSwordReward("North Star"),
							v.createExplosionReward("Stars Collapse"),
							v.createEmoteReward("Emote495"),
							v.createEmoteReward("Emote496")
						}),
						ProductId = 1910206463,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}