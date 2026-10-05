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
		RootFFlagStartTime = "RosariumPackRootStartTime",
		RootFFlagEndTime = "RosariumPackRootEndTime",
		FFlagStartTime = "RosariumBladeStartTime",
		FFlagEndTime = "RosariumBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosarium Blade",
				Image = v2.Icons:GetSwordIcon("Dual Rosarium Blade"),
				ShowRoom = "RosariumBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rosarium Blade",
						GiftId = 3415882913,
						Item = v.createListReward({ v.createSwordReward("Rosarium Blade") }),
						ProductId = 3415882908
					},
					{
						GiftName = "Dual Rosarium Blade",
						GiftId = 3415882912,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosarium Blade"),
							v.createExplosionReward("Blooming Rose"),
							v.createEmoteReward("Emote1049")
						}),
						ProductId = 3415882918
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosariumPackRootStartTime",
		RootFFlagEndTime = "RosariumPackRootEndTime",
		FFlagStartTime = "RosariumScytheStartTime",
		FFlagEndTime = "RosariumScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosarium Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Rosarium Scythe"),
				ShowRoom = "RosariumScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rosarium Scythe",
						GiftId = 3415882914,
						Item = v.createListReward({
							v.createSwordReward("Rosarium Scythe"),
							v.createExplosionReward("Final Rose"),
							v.createEmoteReward("Emote1050")
						}),
						ProductId = 3415882910
					},
					{
						GiftName = "Dual Rosarium Scythe",
						GiftId = 3415882909,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosarium Scythe"),
							v.createExplosionReward("Final Rose"),
							v.createEmoteReward("Emote1051")
						}),
						ProductId = 3415882923
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosariumPackRootStartTime",
		RootFFlagEndTime = "RosariumPackRootEndTime",
		FFlagStartTime = "RosariumPackStartTime",
		FFlagEndTime = "RosariumPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosarium Pack",
				Image = "rbxassetid://113108922901912",
				ShowRoom = "RosariumPackShowRoom",
				Rewards = {
					{
						GiftName = "Rosarium Pack",
						GiftId = 3415882915,
						Item = v.createListReward({
							v.createSwordReward("Rosarium Blade"),
							v.createSwordReward("Rosarium Scythe"),
							v.createExplosionReward("Blooming Rose"),
							v.createEmoteReward("Emote1050")
						}),
						ProductId = 3415882911,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Rosarium Pack",
						GiftId = 3415882916,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosarium Blade"),
							v.createSwordReward("Dual Rosarium Scythe"),
							v.createExplosionReward("Final Rose"),
							v.createEmoteReward("Emote1049"),
							v.createEmoteReward("Emote1051")
						}),
						ProductId = 3415882917,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}