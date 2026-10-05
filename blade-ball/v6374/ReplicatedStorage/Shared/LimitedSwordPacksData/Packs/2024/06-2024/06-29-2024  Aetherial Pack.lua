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
		RootFFlagStartTime = "AetherialPackv2RootStartTime",
		RootFFlagEndTime = "AetherialPackv2RootEndTime",
		FFlagStartTime = "AetherialKunaiStartTime",
		FFlagEndTime = "AetherialKunaiEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherial Kunai",
				Image = v2.Icons:GetSwordIcon("Dual Aetherial Kunai"),
				ShowRoom = "AetherialKunaiShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Aetherial Kunai",
						GiftId = 1860034591,
						Item = v.createListReward({ v.createSwordReward("Aetherial Kunai") }),
						ProductId = 1860034585
					},
					{
						GiftName = "Dual Aetherial Kunai",
						GiftId = 1860034586,
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherial Kunai"),
							v.createExplosionReward("Aetherial Gate"),
							v.createEmoteReward("Emote410")
						}),
						ProductId = 1860034587
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AetherialPackv2RootStartTime",
		RootFFlagEndTime = "AetherialPackv2RootEndTime",
		FFlagStartTime = "AetherialLanceStartTime",
		FFlagEndTime = "AetherialLanceEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherial Lance",
				Image = v2.Icons:GetSwordIcon("Aetherial Lance"),
				ShowRoom = "AetherialLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Aetherial Lance",
						GiftId = 1860034589,
						Item = v.createListReward({
							v.createSwordReward("Aetherial Lance"),
							v.createExplosionReward("Aetherial Blackhole"),
							v.createEmoteReward("Emote411")
						}),
						ProductId = 1860034588
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AetherialPackv2RootStartTime",
		RootFFlagEndTime = "AetherialPackv2RootEndTime",
		FFlagStartTime = "AetherialPackv2StartTime",
		FFlagEndTime = "AetherialPackv2EndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherial Pack",
				Image = "rbxassetid://18261577397",
				ShowRoom = "AetherialPackShowRoom",
				Rewards = {
					{
						GiftName = "Aetherial Pack",
						GiftId = 1860034593,
						Item = v.createListReward({
							v.createSwordReward("Aetherial Kunai"),
							v.createSwordReward("Aetherial Lance"),
							v.createExplosionReward("Aetherial Gate"),
							v.createEmoteReward("Emote411")
						}),
						ProductId = 1860034590,
						DiscountedFrom = 2250
					},
					{
						GiftName = "Dual Aetherial Pack",
						GiftId = 1860034592,
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherial Kunai"),
							v.createSwordReward("Aetherial Lance"),
							v.createExplosionReward("Aetherial Blackhole"),
							v.createEmoteReward("Emote410"),
							v.createEmoteReward("Emote411")
						}),
						ProductId = 1860034584,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}