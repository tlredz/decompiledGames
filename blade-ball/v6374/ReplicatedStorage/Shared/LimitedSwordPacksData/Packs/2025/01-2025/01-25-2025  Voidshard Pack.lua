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
		RootFFlagStartTime = "VoidshardPackRootStartTime",
		RootFFlagEndTime = "VoidshardPackRootEndTime",
		FFlagStartTime = "VoidshardBladeStartTime",
		FFlagEndTime = "VoidshardBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Voidshard Blade",
				Image = v2.Icons:GetSwordIcon("Dual Voidshard Blade"),
				ShowRoom = "VoidshardBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Voidshard Blade",
						GiftId = 2708335264,
						Item = v.createListReward({ v.createSwordReward("Voidshard Blade") }),
						ProductId = 2708335256
					},
					{
						GiftName = "Dual Voidshard Blade",
						GiftId = 2708335257,
						Item = v.createListReward({
							v.createSwordReward("Dual Voidshard Blade"),
							v.createExplosionReward("Voidshard Realm"),
							v.createEmoteReward("Emote758")
						}),
						ProductId = 2708335265
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VoidshardPackRootStartTime",
		RootFFlagEndTime = "VoidshardPackRootEndTime",
		FFlagStartTime = "VoidshardBowStartTime",
		FFlagEndTime = "VoidshardBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Voidshard Bow",
				Image = v2.Icons:GetSwordIcon("Voidshard Bow"),
				ShowRoom = "VoidshardBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Voidshard Bow",
						GiftId = 2708335262,
						Item = v.createListReward({
							v.createSwordReward("Voidshard Bow"),
							v.createExplosionReward("Voidshard Shadow"),
							v.createEmoteReward("Emote759")
						}),
						ProductId = 2708335263
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VoidshardPackRootStartTime",
		RootFFlagEndTime = "VoidshardPackRootEndTime",
		FFlagStartTime = "VoidshardPackStartTime",
		FFlagEndTime = "VoidshardPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Voidshard Pack",
				Image = "rbxassetid://123868223888966",
				ShowRoom = "VoidshardPackShowRoom",
				Rewards = {
					{
						GiftName = "Voidshard Pack",
						GiftId = 2708335259,
						Item = v.createListReward({
							v.createSwordReward("Voidshard Blade"),
							v.createSwordReward("Voidshard Bow"),
							v.createExplosionReward("Voidshard Realm"),
							v.createEmoteReward("Emote759")
						}),
						ProductId = 2708335261,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Voidshard Pack",
						GiftId = 2708335258,
						Item = v.createListReward({
							v.createSwordReward("Dual Voidshard Blade"),
							v.createSwordReward("Voidshard Bow"),
							v.createExplosionReward("Voidshard Shadow"),
							v.createEmoteReward("Emote758"),
							v.createEmoteReward("Emote759")
						}),
						ProductId = 2708335260,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}