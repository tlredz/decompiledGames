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
		RootFFlagStartTime = "ChristmasPackRootStartTime",
		RootFFlagEndTime = "ChristmasPackRootEndTime",
		FFlagStartTime = "FestiveBladeStartTime",
		FFlagEndTime = "FestiveBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Festive Blade",
				Image = v2.Icons:GetSwordIcon("Dual Festive Blade"),
				ShowRoom = "FestiveBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Festive Blade",
						GiftId = 3484259259,
						Item = v.createListReward({ v.createSwordReward("Festive Blade") }),
						ProductId = 3484259256
					},
					{
						GiftName = "Dual Festive Blade",
						GiftId = 3484259264,
						Item = v.createListReward({
							v.createSwordReward("Dual Festive Blade"),
							v.createExplosionReward("Final Star"),
							v.createEmoteReward("Emote1112")
						}),
						ProductId = 3484259265
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChristmasPackRootStartTime",
		RootFFlagEndTime = "ChristmasPackRootEndTime",
		FFlagStartTime = "FestiveScytheStartTime",
		FFlagEndTime = "FestiveScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Festive Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Festive Scythe"),
				ShowRoom = "FestiveScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Festive Scythe",
						GiftId = 3484259262,
						Item = v.createListReward({
							v.createSwordReward("Festive Scythe"),
							v.createExplosionReward("Christmas Lightover"),
							v.createEmoteReward("Emote1113")
						}),
						ProductId = 3484259258
					},
					{
						GiftName = "Dual Festive Scythe",
						GiftId = 3484259261,
						Item = v.createListReward({
							v.createSwordReward("Dual Festive Scythe"),
							v.createExplosionReward("Christmas Lightover"),
							v.createEmoteReward("Emote1114")
						}),
						ProductId = 3484259257
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ChristmasPackRootStartTime",
		RootFFlagEndTime = "ChristmasPackRootEndTime",
		FFlagStartTime = "FestiveScytheStartTime",
		FFlagEndTime = "FestiveScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Festive Pack",
				Image = "rbxassetid://130004735156247",
				ShowRoom = "FestivePackShowRoom",
				Rewards = {
					{
						GiftName = "Festive Pack",
						GiftId = 3484259773,
						Item = v.createListReward({
							v.createSwordReward("Festive Blade"),
							v.createSwordReward("Festive Scythe"),
							v.createExplosionReward("Final Star"),
							v.createEmoteReward("Emote1113")
						}),
						ProductId = 3484259772,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Festive Pack",
						GiftId = 3484259260,
						Item = v.createListReward({
							v.createSwordReward("Dual Festive Blade"),
							v.createSwordReward("Dual Festive Scythe"),
							v.createExplosionReward("Christmas Lightover"),
							v.createEmoteReward("Emote1112"),
							v.createEmoteReward("Emote1114")
						}),
						ProductId = 3484259263,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}