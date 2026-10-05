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
		RootFFlagStartTime = "MoonlightPackRootStartTime",
		RootFFlagEndTime = "MoonlightPackRootEndTime",
		FFlagStartTime = "MoonlightBladeStartTime",
		FFlagEndTime = "MoonlightBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonlight Blade",
				Image = v2.Icons:GetSwordIcon("Dual Moonlight Blade"),
				ShowRoom = "MoonlightBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moonlight Blade",
						GiftId = 3339576016,
						Item = v.createListReward({ v.createSwordReward("Moonlight Blade") }),
						ProductId = 3339576012
					},
					{
						GiftName = "Dual Moonlight Blade",
						GiftId = 3339576013,
						Item = v.createListReward({
							v.createSwordReward("Dual Moonlight Blade"),
							v.createExplosionReward("Moonlight Crescent"),
							v.createEmoteReward("Emote988")
						}),
						ProductId = 3339576008
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonlightPackRootStartTime",
		RootFFlagEndTime = "MoonlightPackRootEndTime",
		FFlagStartTime = "MoonlightBowStartTime",
		FFlagEndTime = "MoonlightBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonlight Bow",
				Image = v2.Icons:GetSwordIcon("Moonlight Bow"),
				ShowRoom = "MoonlightBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moonlight Bow",
						GiftId = 3339576009,
						Item = v.createListReward({
							v.createSwordReward("Moonlight Bow"),
							v.createExplosionReward("Moonlight Reflection"),
							v.createEmoteReward("Emote989")
						}),
						ProductId = 3339576015
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonlightPackRootStartTime",
		RootFFlagEndTime = "MoonlightPackRootEndTime",
		FFlagStartTime = "MoonlightPackStartTime",
		FFlagEndTime = "MoonlightPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonlight Pack",
				Image = "rbxassetid://118301418826362",
				ShowRoom = "MoonlightPackShowRoom",
				Rewards = {
					{
						GiftName = "Moonlight Pack",
						GiftId = 3339576011,
						Item = v.createListReward({
							v.createSwordReward("Moonlight Blade"),
							v.createSwordReward("Moonlight Bow"),
							v.createExplosionReward("Moonlight Crescent"),
							v.createEmoteReward("Emote989")
						}),
						ProductId = 3339576010,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Moonlight Pack",
						GiftId = 3339576006,
						Item = v.createListReward({
							v.createSwordReward("Dual Moonlight Blade"),
							v.createSwordReward("Moonlight Bow"),
							v.createExplosionReward("Moonlight Reflection"),
							v.createEmoteReward("Emote989"),
							v.createEmoteReward("Emote988")
						}),
						ProductId = 3339576007,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}