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
		RootFFlagStartTime = "RosefirePackRootStartTime",
		RootFFlagEndTime = "RosefirePackRootEndTime",
		FFlagStartTime = "RosefireBladeStartTime",
		FFlagEndTime = "RosefireBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosefire Blade",
				Image = v2.Icons:GetSwordIcon("Dual Rosefire Blade"),
				ShowRoom = "RosefireBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rosefire Blade",
						GiftId = 2650349233,
						Item = v.createListReward({ v.createSwordReward("Rosefire Blade") }),
						ProductId = 2650349240
					},
					{
						GiftName = "Dual Rosefire Blade",
						GiftId = 2650349239,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosefire Blade"),
							v.createExplosionReward("Floral Blaze"),
							v.createEmoteReward("Emote597")
						}),
						ProductId = 2650349234
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosefirePackRootStartTime",
		RootFFlagEndTime = "RosefirePackRootEndTime",
		FFlagStartTime = "RosefireScytheStartTime",
		FFlagEndTime = "RosefireScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosefire Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Rosefire Scythe"),
				ShowRoom = "RosefireScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Rosefire Scythe",
						GiftId = 2650349237,
						Item = v.createListReward({
							v.createSwordReward("Rosefire Scythe"),
							v.createExplosionReward("Red Velvet Beam"),
							v.createEmoteReward("Emote598")
						}),
						ProductId = 2650349230
					},
					{
						GiftName = "Dual Rosefire Scythe",
						GiftId = 2650349236,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosefire Scythe"),
							v.createExplosionReward("Red Velvet Beam"),
							v.createEmoteReward("Emote599")
						}),
						ProductId = 2650349231
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RosefirePackRootStartTime",
		RootFFlagEndTime = "RosefirePackRootEndTime",
		FFlagStartTime = "RosefirePackStartTime",
		FFlagEndTime = "RosefirePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Rosefire Pack",
				Image = "rbxassetid://116594876589512",
				ShowRoom = "RosefirePackShowRoom",
				Rewards = {
					{
						GiftName = "Rosefire Pack",
						GiftId = 2650349232,
						Item = v.createListReward({
							v.createSwordReward("Rosefire Blade"),
							v.createSwordReward("Rosefire Scythe"),
							v.createExplosionReward("Floral Blaze"),
							v.createEmoteReward("Emote598")
						}),
						ProductId = 2650349229,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Rosefire Pack",
						GiftId = 2650349238,
						Item = v.createListReward({
							v.createSwordReward("Dual Rosefire Blade"),
							v.createSwordReward("Dual Rosefire Scythe"),
							v.createExplosionReward("Red Velvet Beam"),
							v.createEmoteReward("Emote597"),
							v.createEmoteReward("Emote599")
						}),
						ProductId = 2650349235,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}