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
		RootFFlagStartTime = "LumenwingPackRootStartTime",
		RootFFlagEndTime = "LumenwingPackRootEndTime",
		FFlagStartTime = "LumenwingBladeStartTime",
		FFlagEndTime = "LumenwingBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenwing Blade",
				Image = v2.Icons:GetSwordIcon("Dual Lumenwing Blade"),
				ShowRoom = "LumenwingBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumenwing Blade",
						GiftId = 3389535449,
						Item = v.createListReward({ v.createSwordReward("Lumenwing Blade") }),
						ProductId = 3389535442
					},
					{
						GiftName = "Dual Lumenwing Blade",
						GiftId = 3389535457,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumenwing Blade"),
							v.createExplosionReward("Blue Beauty"),
							v.createEmoteReward("Emote1025")
						}),
						ProductId = 3389535452
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LumenwingPackRootStartTime",
		RootFFlagEndTime = "LumenwingPackRootEndTime",
		FFlagStartTime = "LumenwingBowStartTime",
		FFlagEndTime = "LumenwingBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenwing Bow",
				Image = v2.Icons:GetSwordIcon("Lumenwing Bow"),
				ShowRoom = "LumenwingBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumenwing Bow",
						GiftId = 3389535456,
						Item = v.createListReward({
							v.createSwordReward("Lumenwing Bow"),
							v.createExplosionReward("Butterfly Storm"),
							v.createEmoteReward("Emote1026")
						}),
						ProductId = 3389535454
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LumenwingPackRootStartTime",
		RootFFlagEndTime = "LumenwingPackRootEndTime",
		FFlagStartTime = "LumenwingPackStartTime",
		FFlagEndTime = "LumenwingPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenwing Pack",
				Image = "rbxassetid://125633959660747",
				ShowRoom = "LumenwingPackShowRoom",
				Rewards = {
					{
						GiftName = "Lumenwing Pack",
						GiftId = 3389535453,
						Item = v.createListReward({
							v.createSwordReward("Lumenwing Blade"),
							v.createSwordReward("Lumenwing Bow"),
							v.createExplosionReward("Blue Beauty"),
							v.createEmoteReward("Emote1026")
						}),
						ProductId = 3389535455,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Lumenwing Pack",
						GiftId = 3389535450,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumenwing Blade"),
							v.createSwordReward("Lumenwing Bow"),
							v.createExplosionReward("Butterfly Storm"),
							v.createEmoteReward("Emote1026"),
							v.createEmoteReward("Emote1025")
						}),
						ProductId = 3389535451,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}