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
		RootFFlagStartTime = "SpringPackRootStartTime",
		RootFFlagEndTime = "SpringPackRootEndTime",
		FFlagStartTime = "SpringSaberStartTime",
		FFlagEndTime = "SpringSaberEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Spring Saber",
				Image = v2.Icons:GetSwordIcon("Dual Spring Saber"),
				ShowRoom = "SpringSaberShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Spring Saber",
						GiftId = 3551335207,
						Item = v.createListReward({ v.createSwordReward("Spring Saber") }),
						ProductId = 3551335210
					},
					{
						GiftName = "Dual Spring Saber",
						GiftId = 3551335205,
						Item = v.createListReward({
							v.createSwordReward("Dual Spring Saber"),
							v.createExplosionReward("Spring Blessings"),
							v.createEmoteReward("Emote1178")
						}),
						ProductId = 3551335215
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SpringPackRootStartTime",
		RootFFlagEndTime = "SpringPackRootEndTime",
		FFlagStartTime = "SpringScytheStartTime",
		FFlagEndTime = "SpringScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Spring Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Spring Scythe"),
				ShowRoom = "SpringScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Spring Scythe",
						GiftId = 3551335212,
						Item = v.createListReward({
							v.createSwordReward("Spring Scythe"),
							v.createExplosionReward("Pink Valley"),
							v.createEmoteReward("Emote1177")
						}),
						ProductId = 3551335213
					},
					{
						GiftName = "Dual Spring Scythe",
						GiftId = 3551335206,
						Item = v.createListReward({
							v.createSwordReward("Dual Spring Scythe"),
							v.createExplosionReward("Pink Valley"),
							v.createEmoteReward("Emote1176")
						}),
						ProductId = 3551335211
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SpringPackRootStartTime",
		RootFFlagEndTime = "SpringPackRootEndTime",
		FFlagStartTime = "SpringPackStartTime",
		FFlagEndTime = "SpringPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Spring Pack",
				Image = "rbxassetid://84020140431333",
				ShowRoom = "SpringPackShowRoom",
				Rewards = {
					{
						GiftName = "Spring Pack",
						GiftId = 3551335219,
						Item = v.createListReward({
							v.createSwordReward("Spring Saber"),
							v.createSwordReward("Spring Scythe"),
							v.createExplosionReward("Spring Blessings"),
							v.createEmoteReward("Emote1177")
						}),
						ProductId = 3551335209,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Spring Pack",
						GiftId = 3551335217,
						Item = v.createListReward({
							v.createSwordReward("Dual Spring Saber"),
							v.createSwordReward("Dual Spring Scythe"),
							v.createExplosionReward("Pink Valley"),
							v.createEmoteReward("Emote1178"),
							v.createEmoteReward("Emote1176")
						}),
						ProductId = 3551335208,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}