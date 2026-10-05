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
		RootFFlagStartTime = "GleamingPackRootStartTime",
		RootFFlagEndTime = "GleamingPackRootEndTime",
		FFlagStartTime = "GleamingKatanaStartTime",
		FFlagEndTime = "GleamingKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gleaming Katana",
				Image = v2.Icons:GetSwordIcon("Dual Gleaming Katana"),
				ShowRoom = "GleamingKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gleaming Katana",
						GiftId = 3283045446,
						Item = v.createListReward({ v.createSwordReward("Gleaming Katana") }),
						ProductId = 3283045438
					},
					{
						GiftName = "Dual Gleaming Katana",
						GiftId = 3283045448,
						Item = v.createListReward({
							v.createSwordReward("Dual Gleaming Katana"),
							v.createExplosionReward("Gleaming Glitter"),
							v.createEmoteReward("Emote904")
						}),
						ProductId = 3283045449
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GleamingPackRootStartTime",
		RootFFlagEndTime = "GleamingPackRootEndTime",
		FFlagStartTime = "GleamingScytheStartTime",
		FFlagEndTime = "GleamingScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gleaming Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Gleaming Scythe"),
				ShowRoom = "GleamingScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gleaming Scythe",
						GiftId = 3283045445,
						Item = v.createListReward({
							v.createSwordReward("Gleaming Scythe"),
							v.createExplosionReward("Gleaming Bloom"),
							v.createEmoteReward("Emote905")
						}),
						ProductId = 3283045444
					},
					{
						GiftName = "Dual Gleaming Scythe",
						GiftId = 3283045443,
						Item = v.createListReward({
							v.createSwordReward("Dual Gleaming Scythe"),
							v.createExplosionReward("Gleaming Bloom"),
							v.createEmoteReward("Emote906")
						}),
						ProductId = 3283045442
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GleamingPackRootStartTime",
		RootFFlagEndTime = "GleamingPackRootEndTime",
		FFlagStartTime = "GleamingPackStartTime",
		FFlagEndTime = "GleamingPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gleaming Pack",
				Image = "rbxassetid://123394502494074",
				ShowRoom = "GleamingPackShowRoom",
				Rewards = {
					{
						GiftName = "Gleaming Pack",
						GiftId = 3283045441,
						Item = v.createListReward({
							v.createSwordReward("Gleaming Katana"),
							v.createSwordReward("Gleaming Scythe"),
							v.createExplosionReward("Gleaming Glitter"),
							v.createEmoteReward("Emote905")
						}),
						ProductId = 3283045439,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Gleaming Pack",
						GiftId = 3283045440,
						Item = v.createListReward({
							v.createSwordReward("Dual Gleaming Katana"),
							v.createSwordReward("Dual Gleaming Scythe"),
							v.createExplosionReward("Gleaming Bloom"),
							v.createEmoteReward("Emote904"),
							v.createEmoteReward("Emote906")
						}),
						ProductId = 3283045447,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}