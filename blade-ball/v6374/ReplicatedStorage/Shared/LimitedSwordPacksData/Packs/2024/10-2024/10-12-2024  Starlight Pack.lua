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
		RootFFlagStartTime = "StarlightPackRootStartTime",
		RootFFlagEndTime = "StarlightPackRootEndTime",
		FFlagStartTime = "StarlightSwordStartTime",
		FFlagEndTime = "StarlightSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starlight Axe",
				Image = v2.Icons:GetSwordIcon("Dual Starlight Axe"),
				ShowRoom = "StarlightAxeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Starlight Axe",
						GiftId = 2153861784,
						Item = v.createListReward({ v.createSwordReward("Starlight Axe") }),
						ProductId = 2153861791
					},
					{
						GiftName = "Dual Starlight Axe",
						GiftId = 2153861789,
						Item = v.createListReward({
							v.createSwordReward("Dual Starlight Axe"),
							v.createExplosionReward("Starlit Bloom"),
							v.createEmoteReward("Emote563")
						}),
						ProductId = 2153861787
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarlightPackRootStartTime",
		RootFFlagEndTime = "StarlightPackRootEndTime",
		FFlagStartTime = "StarlightScytheStartTime",
		FFlagEndTime = "StarlightScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starlight Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Starlight Scythe"),
				ShowRoom = "StarlightScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Starlight Scythe",
						GiftId = 2153861797,
						Item = v.createListReward({
							v.createSwordReward("Starlight Scythe"),
							v.createExplosionReward("Starlit Candle"),
							v.createEmoteReward("Emote564")
						}),
						ProductId = 2153861786
					},
					{
						GiftName = "Dual Starlight Scythe",
						GiftId = 2153861794,
						Item = v.createListReward({
							v.createSwordReward("Dual Starlight Scythe"),
							v.createExplosionReward("Starlit Candle"),
							v.createEmoteReward("Emote565")
						}),
						ProductId = 2153861790
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarlightPackRootStartTime",
		RootFFlagEndTime = "StarlightPackRootEndTime",
		FFlagStartTime = "StarlightPackStartTime",
		FFlagEndTime = "StarlightPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starlight Pack",
				Image = "rbxassetid://110256975277320",
				ShowRoom = "StarlightPackShowRoom",
				Rewards = {
					{
						GiftName = "Starlight Pack",
						GiftId = 2153861785,
						Item = v.createListReward({
							v.createSwordReward("Starlight Axe"),
							v.createSwordReward("Starlight Scythe"),
							v.createExplosionReward("Starlit Bloom"),
							v.createEmoteReward("Emote564")
						}),
						ProductId = 2153861792,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Starlight Pack",
						GiftId = 2153861793,
						Item = v.createListReward({
							v.createSwordReward("Dual Starlight Axe"),
							v.createSwordReward("Dual Starlight Scythe"),
							v.createExplosionReward("Starlit Candle"),
							v.createEmoteReward("Emote563"),
							v.createEmoteReward("Emote565")
						}),
						ProductId = 2153861788,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}