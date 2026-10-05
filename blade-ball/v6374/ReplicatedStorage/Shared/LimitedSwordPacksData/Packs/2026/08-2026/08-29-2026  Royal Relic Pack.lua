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
		RootFFlagStartTime = "RoyalRelicStartTime",
		RootFFlagEndTime = "RoyalRelicEndTime",
		FFlagStartTime = "RoyalRelicBladeStartTime",
		FFlagEndTime = "RoyalRelicBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Royal Relic Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Royal Relic Blade"),
				ShowRoom = "RoyalRelicBladeShowRoom",
				Rewards = {
					{
						GiftName = "Royal Relic Blade",
						GiftId = 3710432792,
						Item = v.createListReward({ v.createSwordReward("Royal Relic Blade") }),
						ProductId = 3710432796
					},
					{
						GiftName = "Dual Royal Relic Blade",
						GiftId = 3710432798,
						Item = v.createListReward({
							v.createSwordReward("Dual Royal Relic Blade"),
							v.createExplosionReward("Royal Relic Sympol"),
							v.createEmoteReward("Emote1270")
						}),
						ProductId = 3710432802
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RoyalRelicStartTime",
		RootFFlagEndTime = "RoyalRelicEndTime",
		FFlagStartTime = "RoyalRelicBowStartTime",
		FFlagEndTime = "RoyalRelicBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Royal Relic Bow",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Royal Relic Bow"),
				ShowRoom = "RoyalRelicBowShowRoom",
				Rewards = {
					{
						GiftName = "Royal Relic Bow",
						GiftId = 3710432806,
						Item = v.createListReward({
							v.createSwordReward("Royal Relic Bow"),
							v.createExplosionReward("Royal Relic Crown"),
							v.createEmoteReward("Emote1271")
						}),
						ProductId = 3710432811
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RoyalRelicStartTime",
		RootFFlagEndTime = "RoyalRelicEndTime",
		FFlagStartTime = "RoyalRelicPackStartTime",
		FFlagEndTime = "RoyalRelicPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Royal Relic Pack",
				Image = "rbxassetid://105563674631815",
				ShowRoom = "RoyalRelicPackShowRoom",
				Rewards = {
					{
						GiftName = "Royal Relic Pack",
						GiftId = 3710432818,
						Item = v.createListReward({
							v.createSwordReward("Royal Relic Blade"),
							v.createSwordReward("Royal Relic Bow"),
							v.createExplosionReward("Royal Relic Crown"),
							v.createEmoteReward("Emote1271")
						}),
						ProductId = 3710432825
					},
					{
						GiftName = "Dual Royal Relic Pack",
						GiftId = 3710432827,
						Item = v.createListReward({
							v.createSwordReward("Dual Royal Relic Blade"),
							v.createSwordReward("Royal Relic Bow"),
							v.createExplosionReward("Royal Relic Crown"),
							v.createEmoteReward("Emote1270"),
							v.createEmoteReward("Emote1271")
						}),
						ProductId = 3710432836
					}
				}
			}
		}
	}
}