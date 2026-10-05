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
		FFlagStartTime = "DesertBladeStartTime",
		RootFFlagStartTime = "DesertPackStartTime",
		FFlagEndTime = "DesertBladeEndTime",
		RootFFlagEndTime = "DesertPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Desert Blade",
				Image = v2.Icons:GetSwordIcon("Dual Desert Blade"),
				ShowRoom = "DesertBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Desert Blade",
						Item = v.createListReward({ v.createSwordReward("Desert Blade") }),
						ProductId = 1811876587
					},
					{
						GiftName = "Dual Desert Blade",
						Item = v.createListReward({
							v.createSwordReward("Dual Desert Blade"),
							v.createEmoteReward("Emote281"),
							v.createExplosionReward("Sand Dust")
						}),
						ProductId = 1811876589
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DesertClawsStartTime",
		RootFFlagStartTime = "DesertClawsStartTime",
		FFlagEndTime = "DesertClawEndTime",
		RootFFlagEndTime = "DesertPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Desert Claws",
				Image = v2.Icons:GetSwordIcon("Desert Claws"),
				ShowRoom = "DesertClawsShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Desert Claws",
						Item = v.createListReward({
							v.createSwordReward("Desert Claws"),
							v.createEmoteReward("Emote283"),
							v.createExplosionReward("Pyramid Scheme")
						}),
						ProductId = 1811876591
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DesertPackStartTime",
		RootFFlagStartTime = "DesertPackStartTime",
		FFlagEndTime = "DesertPackEndTime",
		RootFFlagEndTime = "DesertPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Desert Pack",
				Image = "rbxassetid://17219988338",
				ShowRoom = "DesertPackShowRoom",
				Rewards = {
					{
						GiftName = "Desert Pack",
						Item = v.createListReward({
							v.createSwordReward("Desert Blade"),
							v.createSwordReward("Desert Claws"),
							v.createEmoteReward("Emote281"),
							v.createExplosionReward("Sand Dust")
						}),
						ProductId = 1811876590,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Desert Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Desert Blade"),
							v.createSwordReward("Desert Claws"),
							v.createExplosionReward("Pyramid Scheme"),
							v.createEmoteReward("Emote281"),
							v.createEmoteReward("Emote283")
						}),
						ProductId = 1811876595,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}