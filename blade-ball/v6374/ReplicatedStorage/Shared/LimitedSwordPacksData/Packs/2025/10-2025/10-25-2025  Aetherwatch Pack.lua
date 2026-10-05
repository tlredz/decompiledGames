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
		RootFFlagStartTime = "AetherwatchPackRootStartTime",
		RootFFlagEndTime = "AetherwatchPackRootEndTime",
		FFlagStartTime = "AetherwatchBladeStartTime",
		FFlagEndTime = "AetherwatchBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherwatch Blade",
				Image = v2.Icons:GetSwordIcon("Dual Aetherwatch Blade"),
				ShowRoom = "AetherwatchBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Aetherwatch Blade",
						GiftId = 3440192729,
						Item = v.createListReward({ v.createSwordReward("Aetherwatch Blade") }),
						ProductId = 3440192724
					},
					{
						GiftName = "Dual Aetherwatch Blade",
						GiftId = 3440192730,
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherwatch Blade"),
							v.createExplosionReward("Haunted Love"),
							v.createEmoteReward("Emote1064")
						}),
						ProductId = 3440192725
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AetherwatchPackRootStartTime",
		RootFFlagEndTime = "AetherwatchPackRootEndTime",
		FFlagStartTime = "AetherwatchScytheStartTime",
		FFlagEndTime = "AetherwatchScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherwatch Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Aetherwatch Scythe"),
				ShowRoom = "AetherwatchScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Aetherwatch Scythe",
						GiftId = 3440192731,
						Item = v.createListReward({
							v.createSwordReward("Aetherwatch Scythe"),
							v.createExplosionReward("Loving Heartlock"),
							v.createEmoteReward("Emote1065")
						}),
						ProductId = 3440192726
					},
					{
						GiftName = "Dual Aetherwatch Scythe",
						GiftId = 3440192728,
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherwatch Scythe"),
							v.createExplosionReward("Loving Heartlock"),
							v.createEmoteReward("Emote1066")
						}),
						ProductId = 3440192735
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "AetherwatchPackRootStartTime",
		RootFFlagEndTime = "AetherwatchPackRootEndTime",
		FFlagStartTime = "AetherwatchPackStartTime",
		FFlagEndTime = "AetherwatchPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Aetherwatch Pack",
				Image = "rbxassetid://74087117795874",
				ShowRoom = "AetherwatchPackShowRoom",
				Rewards = {
					{
						GiftName = "Aetherwatch Pack",
						GiftId = 3440192732,
						Item = v.createListReward({
							v.createSwordReward("Aetherwatch Blade"),
							v.createSwordReward("Aetherwatch Scythe"),
							v.createExplosionReward("Haunted Love"),
							v.createEmoteReward("Emote1065")
						}),
						ProductId = 3440192733,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Aetherwatch Pack",
						GiftId = 3440192727,
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherwatch Blade"),
							v.createSwordReward("Dual Aetherwatch Scythe"),
							v.createExplosionReward("Loving Heartlock"),
							v.createEmoteReward("Emote1064"),
							v.createEmoteReward("Emote1066")
						}),
						ProductId = 3440192734,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}