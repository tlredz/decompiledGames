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
		RootFFlagStartTime = "RadiantDucklingStartTime",
		RootFFlagEndTime = "RadiantDucklingEndTime",
		FFlagStartTime = "RadiantDucklingKunaiStartTime",
		FFlagEndTime = "RadiantDucklingKunaiEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Radiant Duckling Kunai",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Radiant Duckling Kunai"),
				ShowRoom = "RadiantDucklingKunaiShowRoom",
				Color = Color3.fromRGB(255, 196, 46),
				Rewards = {
					{
						GiftName = "Radiant Duckling Kunai",
						GiftId = 3711463427,
						Item = v.createListReward({ v.createSwordReward("Radiant Duckling Kunai") }),
						ProductId = 3711463432
					},
					{
						GiftName = "Dual Radiant Duckling Kunai",
						GiftId = 3711463434,
						Item = v.createListReward({
							v.createSwordReward("Dual Radiant Duckling Kunai"),
							v.createExplosionReward("Radiant Quack Explosion"),
							v.createEmoteReward("Emote1273")
						}),
						ProductId = 3711463440
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RadiantDucklingStartTime",
		RootFFlagEndTime = "RadiantDucklingEndTime",
		FFlagStartTime = "RadiantDucklingLanceStartTime",
		FFlagEndTime = "RadiantDucklingLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Radiant Duckling Lance",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Radiant Duckling Lance"),
				ShowRoom = "RadiantDucklingLanceShowRoom",
				Color = Color3.fromRGB(255, 196, 46),
				Rewards = {
					{
						GiftName = "Radiant Duckling Lance",
						GiftId = 3711463446,
						Item = v.createListReward({
							v.createSwordReward("Radiant Duckling Lance"),
							v.createExplosionReward("Radiant Duckling Explosion"),
							v.createEmoteReward("Emote1274")
						}),
						ProductId = 3711463454
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RadiantDucklingStartTime",
		RootFFlagEndTime = "RadiantDucklingEndTime",
		FFlagStartTime = "RadiantDucklingPackStartTime",
		FFlagEndTime = "RadiantDucklingPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Radiant Duckling Pack",
				Image = "rbxassetid://112632859716512",
				ShowRoom = "RadiantDucklingPackShowRoom",
				Color = Color3.fromRGB(255, 196, 46),
				Rewards = {
					{
						GiftName = "Radiant Duckling Pack",
						GiftId = 3711463474,
						Item = v.createListReward({
							v.createSwordReward("Radiant Duckling Kunai"),
							v.createSwordReward("Radiant Duckling Lance"),
							v.createExplosionReward("Radiant Quack Explosion"),
							v.createEmoteReward("Emote1274")
						}),
						ProductId = 3711463479
					},
					{
						GiftName = "Dual Radiant Duckling Pack",
						GiftId = 3711463487,
						Item = v.createListReward({
							v.createSwordReward("Dual Radiant Duckling Kunai"),
							v.createSwordReward("Radiant Duckling Lance"),
							v.createExplosionReward("Radiant Duckling Explosion"),
							v.createEmoteReward("Emote1273"),
							v.createEmoteReward("Emote1274")
						}),
						ProductId = 3711463492
					}
				}
			}
		}
	}
}