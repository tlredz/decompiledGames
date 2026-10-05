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
		RootFFlagStartTime = "VelvetPackRootStartTime",
		RootFFlagEndTime = "VelvetPackRootEndTime",
		FFlagStartTime = "VelvetBladeStartTime",
		FFlagEndTime = "VelvetBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Velvet Blade",
				Image = v2.Icons:GetSwordIcon("Dual Velvet Blade"),
				ShowRoom = "VelvetBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Velvet Blade",
						GiftId = 3502960479,
						Item = v.createListReward({ v.createSwordReward("Velvet Blade") }),
						ProductId = 3502960480
					},
					{
						GiftName = "Dual Velvet Blade",
						GiftId = 3502960477,
						Item = v.createListReward({
							v.createSwordReward("Dual Velvet Blade"),
							v.createExplosionReward("Velvet Beam"),
							v.createEmoteReward("Emote1122")
						}),
						ProductId = 3502960472
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VelvetPackRootStartTime",
		RootFFlagEndTime = "VelvetPackRootEndTime",
		FFlagStartTime = "VelvetFanStartTime",
		FFlagEndTime = "VelvetFanEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Velvet Fan",
				Image = v2.Icons:GetSwordIcon("Dual Velvet Fan"),
				ShowRoom = "VelvetFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Velvet Fan",
						GiftId = 3502960474,
						Item = v.createListReward({
							v.createSwordReward("Velvet Fan"),
							v.createExplosionReward("Velvet Dimension"),
							v.createEmoteReward("Emote1124")
						}),
						ProductId = 3502960470
					},
					{
						GiftName = "Dual Velvet Fan",
						GiftId = 3502960473,
						Item = v.createListReward({
							v.createSwordReward("Dual Velvet Fan"),
							v.createExplosionReward("Velvet Dimension"),
							v.createEmoteReward("Emote1123")
						}),
						ProductId = 3502960476
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VelvetPackRootStartTime",
		RootFFlagEndTime = "VelvetPackRootEndTime",
		FFlagStartTime = "VelvetPackStartTime",
		FFlagEndTime = "VelvetPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Velvet Pack",
				Image = "rbxassetid://75253754377223",
				ShowRoom = "VelvetPackShowRoom",
				Rewards = {
					{
						GiftName = "Velvet Pack",
						GiftId = 3502960475,
						Item = v.createListReward({
							v.createSwordReward("Velvet Blade"),
							v.createSwordReward("Velvet Fan"),
							v.createExplosionReward("Velvet Beam"),
							v.createEmoteReward("Emote1124")
						}),
						ProductId = 3502960469,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Velvet Pack",
						GiftId = 3502960478,
						Item = v.createListReward({
							v.createSwordReward("Dual Velvet Blade"),
							v.createSwordReward("Dual Velvet Fan"),
							v.createExplosionReward("Velvet Dimension"),
							v.createEmoteReward("Emote1122"),
							v.createEmoteReward("Emote1123")
						}),
						ProductId = 3502960471,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}