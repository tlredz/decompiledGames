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
		RootFFlagStartTime = "BloodpetalPackRootStartTime",
		RootFFlagEndTime = "BloodpetalPackRootEndTime",
		FFlagStartTime = "BloodpetalBladeStartTime",
		FFlagEndTime = "BloodpetalBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodpetal Blade",
				Image = v2.Icons:GetSwordIcon("Dual Bloodpetal Blade"),
				ShowRoom = "BloodpetalBladeShowRoom",
				TemplateType = "Blade",
				Rewards = {
					{
						GiftName = "Bloodpetal Blade",
						GiftId = 3480615736,
						Item = v.createListReward({ v.createSwordReward("Bloodpetal Blade") }),
						ProductId = 3480615732
					},
					{
						GiftName = "Dual Bloodpetal Blade",
						GiftId = 3480615737,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodpetal Blade"),
							v.createExplosionReward("Deathscar Eye"),
							v.createEmoteReward("Emote1109")
						}),
						ProductId = 3480615730
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodpetalPackRootStartTime",
		RootFFlagEndTime = "BloodpetalPackRootEndTime",
		FFlagStartTime = "BloodpetalBlasterStartTime",
		FFlagEndTime = "BloodpetalBlasterEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodpetal Blaster",
				Image = v2.Icons:GetSwordIcon("Dual Bloodpetal Blaster"),
				ShowRoom = "BloodpetalBlasterShowRoom",
				TemplateType = "Blade",
				Rewards = {
					{
						GiftName = "Bloodpetal Blaster",
						GiftId = 3480615735,
						Item = v.createListReward({
							v.createSwordReward("Bloodpetal Blaster"),
							v.createExplosionReward("Deathscar Core"),
							v.createEmoteReward("Emote1110")
						}),
						ProductId = 3480615733
					},
					{
						GiftName = "Dual Bloodpetal Blaster",
						GiftId = 3480618294,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodpetal Blaster"),
							v.createExplosionReward("Deathscar Core"),
							v.createEmoteReward("Emote1111")
						}),
						ProductId = 3480618293
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloodpetalPackRootStartTime",
		RootFFlagEndTime = "BloodpetalPackRootEndTime",
		FFlagStartTime = "BloodpetalPackStartTime",
		FFlagEndTime = "BloodpetalPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloodpetal Pack",
				Image = "rbxassetid://120309444296416",
				ShowRoom = "BloodpetalPackShowRoom",
				Rewards = {
					{
						GiftName = "Bloodpetal Pack",
						GiftId = 3480615729,
						Item = v.createListReward({
							v.createSwordReward("Bloodpetal Blade"),
							v.createSwordReward("Bloodpetal Blaster"),
							v.createExplosionReward("Deathscar Eye"),
							v.createEmoteReward("Emote1110")
						}),
						ProductId = 3480615738,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Bloodpetal Pack",
						GiftId = 3480615739,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloodpetal Blade"),
							v.createSwordReward("Dual Bloodpetal Blaster"),
							v.createExplosionReward("Deathscar Eye"),
							v.createEmoteReward("Emote1111"),
							v.createEmoteReward("Emote1109")
						}),
						ProductId = 3480615731,
						DiscountedFrom = 3250
					}
				}
			}
		}
	}
}