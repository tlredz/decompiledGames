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
		RootFFlagStartTime = "SnowveilPackRootStartTime",
		RootFFlagEndTime = "SnowveilPackRootEndTime",
		FFlagStartTime = "SnowveilBladeStartTime",
		FFlagEndTime = "SnowveilBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Snowveil Blade",
				Image = v2.Icons:GetSwordIcon("Dual Snowveil Blade"),
				ShowRoom = "SnowveilBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Snowveil Blade",
						GiftId = 2673564005,
						Item = v.createListReward({ v.createSwordReward("Snowveil Blade") }),
						ProductId = 2673564004
					},
					{
						GiftName = "Dual Snowveil Blade",
						GiftId = 2673564003,
						Item = v.createListReward({
							v.createSwordReward("Dual Snowveil Blade"),
							v.createExplosionReward("Snow Globe"),
							v.createEmoteReward("Emote679")
						}),
						ProductId = 2673564010
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SnowveilPackRootStartTime",
		RootFFlagEndTime = "SnowveilPackRootEndTime",
		FFlagStartTime = "SnowveilScytheStartTime",
		FFlagEndTime = "SnowveilScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Snowveil Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Snowveil Scythe"),
				ShowRoom = "SnowveilScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Snowveil Scythe",
						GiftId = 2673564001,
						Item = v.createListReward({
							v.createSwordReward("Snowveil Scythe"),
							v.createExplosionReward("Snowveil Flake"),
							v.createEmoteReward("Emote680")
						}),
						ProductId = 2673563999
					},
					{
						GiftName = "Dual Snowveil Scythe",
						GiftId = 2673564000,
						Item = v.createListReward({
							v.createSwordReward("Dual Snowveil Scythe"),
							v.createExplosionReward("Snowveil Flake"),
							v.createEmoteReward("Emote681")
						}),
						ProductId = 2673564002
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SnowveilPackRootStartTime",
		RootFFlagEndTime = "SnowveilPackRootEndTime",
		FFlagStartTime = "SnowveilPackStartTime",
		FFlagEndTime = "SnowveilPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Snowveil Pack",
				Image = "rbxassetid://103235013760229",
				ShowRoom = "SnowveilPackShowRoom",
				Rewards = {
					{
						GiftName = "Snowveil Pack",
						GiftId = 2673564007,
						Item = v.createListReward({
							v.createSwordReward("Snowveil Blade"),
							v.createSwordReward("Snowveil Scythe"),
							v.createExplosionReward("Snow Globe"),
							v.createEmoteReward("Emote680")
						}),
						ProductId = 2673564008,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Snowveil Pack",
						GiftId = 2673564006,
						Item = v.createListReward({
							v.createSwordReward("Dual Snowveil Blade"),
							v.createSwordReward("Dual Snowveil Scythe"),
							v.createExplosionReward("Snowveil Flake"),
							v.createEmoteReward("Emote679"),
							v.createEmoteReward("Emote681")
						}),
						ProductId = 2673564009,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}