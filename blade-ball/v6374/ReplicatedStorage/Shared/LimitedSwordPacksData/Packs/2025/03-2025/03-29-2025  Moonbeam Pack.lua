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
		RootFFlagStartTime = "MoonbeamPackRootStartTime",
		RootFFlagEndTime = "MoonbeamPackRootEndTime",
		FFlagStartTime = "MoonbeamBladeStartTime",
		FFlagEndTime = "MoonbeamBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonbeam Blade",
				Image = v2.Icons:GetSwordIcon("Dual Moonbeam Blade"),
				ShowRoom = "MoonbeamBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moonbeam Blade",
						GiftId = 3251941663,
						Item = v.createListReward({ v.createSwordReward("Moonbeam Blade") }),
						ProductId = 3251941669
					},
					{
						GiftName = "Dual Moonbeam Blade",
						GiftId = 3251941667,
						Item = v.createListReward({
							v.createSwordReward("Dual Moonbeam Blade"),
							v.createExplosionReward("Moonbeam Peak"),
							v.createEmoteReward("Emote851")
						}),
						ProductId = 3251941664
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonbeamPackRootStartTime",
		RootFFlagEndTime = "MoonbeamPackRootEndTime",
		FFlagStartTime = "MoonbeamBowStartTime",
		FFlagEndTime = "MoonbeamBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonbeam Bow",
				Image = v2.Icons:GetSwordIcon("Moonbeam Bow"),
				ShowRoom = "MoonbeamBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moonbeam Bow",
						GiftId = 3251941665,
						Item = v.createListReward({
							v.createSwordReward("Moonbeam Bow"),
							v.createExplosionReward("Moonbeam Memory"),
							v.createEmoteReward("Emote850")
						}),
						ProductId = 3251941659
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonbeamPackRootStartTime",
		RootFFlagEndTime = "MoonbeamPackRootEndTime",
		FFlagStartTime = "MoonbeamPackStartTime",
		FFlagEndTime = "MoonbeamPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moonbeam Pack",
				Image = "rbxassetid://110216955500163",
				ShowRoom = "MoonbeamPackShowRoom",
				Rewards = {
					{
						GiftName = "Moonbeam Pack",
						GiftId = 3251941666,
						Item = v.createListReward({
							v.createSwordReward("Moonbeam Blade"),
							v.createSwordReward("Moonbeam Bow"),
							v.createExplosionReward("Moonbeam Peak"),
							v.createEmoteReward("Emote850")
						}),
						ProductId = 3251941662,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Moonbeam Pack",
						GiftId = 3251941670,
						Item = v.createListReward({
							v.createSwordReward("Dual Moonbeam Blade"),
							v.createSwordReward("Moonbeam Bow"),
							v.createExplosionReward("Moonbeam Memory"),
							v.createEmoteReward("Emote850"),
							v.createEmoteReward("Emote851")
						}),
						ProductId = 3251941661,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}