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
		RootFFlagBowtTime = "ButterflyPackRootBowtTime",
		RootFFlagEndTime = "ButterflyPackRootEndTime",
		FFlagBowtTime = "ButterflyBladeBowtTime",
		FFlagEndTime = "ButterflyBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Butterfly Blade",
				Image = v2.Icons:GetSwordIcon("Dual Butterfly Blade"),
				ShowRoom = "ButterflyBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Butterfly Blade",
						GiftId = 1916255434,
						Item = v.createListReward({ v.createSwordReward("Butterfly Blade") }),
						ProductId = 1916255433
					},
					{
						GiftName = "Dual Butterfly Blade",
						GiftId = 1916255438,
						Item = v.createListReward({
							v.createSwordReward("Dual Butterfly Blade"),
							v.createExplosionReward("Butterfly Glitter"),
							v.createEmoteReward("Emote498")
						}),
						ProductId = 1916255436
					}
				}
			}
		}
	},
	{
		RootFFlagBowtTime = "ButterflyPackRootBowtTime",
		RootFFlagEndTime = "ButterflyPackRootEndTime",
		FFlagBowtTime = "ButterflyBowBowtTime",
		FFlagEndTime = "ButterflyBowEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Butterfly Bow",
				Image = v2.Icons:GetSwordIcon("Butterfly Bow"),
				ShowRoom = "ButterflyBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Butterfly Bow",
						GiftId = 1916255431,
						Item = v.createListReward({
							v.createSwordReward("Butterfly Bow"),
							v.createExplosionReward("Aesthetic Butterfly"),
							v.createEmoteReward("Emote497")
						}),
						ProductId = 1916255439
					}
				}
			}
		}
	},
	{
		RootFFlagBowtTime = "ButterflyPackRootBowtTime",
		RootFFlagEndTime = "ButterflyPackRootEndTime",
		FFlagBowtTime = "ButterflyPackBowtTime",
		FFlagEndTime = "ButterflyPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Butterfly Bow Pack",
				Image = "rbxassetid://90460699996778",
				ShowRoom = "ButterflyPackShowRoom",
				Rewards = {
					{
						GiftName = "Butterfly Bow Pack",
						GiftId = 1916255429,
						Item = v.createListReward({
							v.createSwordReward("Butterfly Blade"),
							v.createSwordReward("Butterfly Bow"),
							v.createExplosionReward("Butterfly Glitter"),
							v.createEmoteReward("Emote497")
						}),
						ProductId = 1916255435,
						DiscountedFrom = 2250
					},
					{
						GiftName = "Dual Butterfly Bow Pack",
						GiftId = 1916255437,
						Item = v.createListReward({
							v.createSwordReward("Dual Butterfly Blade"),
							v.createSwordReward("Butterfly Bow"),
							v.createExplosionReward("Aesthetic Butterfly"),
							v.createEmoteReward("Emote498"),
							v.createEmoteReward("Emote497")
						}),
						ProductId = 1916255432,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}