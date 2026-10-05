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
		RootFFlagStartTime = "HakaiPackRootStartTime",
		RootFFlagEndTime = "HakaiPackRootEndTime",
		FFlagStartTime = "HakaiSwordStartTime",
		FFlagEndTime = "HakaiSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hakai Blade",
				Image = v2.Icons:GetSwordIcon("Dual Hakai Blade"),
				ShowRoom = "HakaiBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hakai Blade",
						GiftId = 1937800650,
						Item = v.createListReward({ v.createSwordReward("Hakai Blade") }),
						ProductId = 1937800646
					},
					{
						GiftName = "Dual Hakai Blade",
						GiftId = 1937800648,
						Item = v.createListReward({
							v.createSwordReward("Dual Hakai Blade"),
							v.createExplosionReward("Destruction Star"),
							v.createEmoteReward("Emote543")
						}),
						ProductId = 1937800649
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HakaiPackRootStartTime",
		RootFFlagEndTime = "HakaiPackRootEndTime",
		FFlagStartTime = "HakaiScorpionStartTime",
		FFlagEndTime = "HakaiScorpionEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hakai Scorpion",
				Image = v2.Icons:GetSwordIcon("Dual Hakai Set"),
				ShowRoom = "HakaiScorpionShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hakai Scorpion",
						GiftId = 1937800644,
						Item = v.createListReward({
							v.createSwordReward("Hakai Scorpion"),
							v.createExplosionReward("Hakai!"),
							v.createEmoteReward("Emote544")
						}),
						ProductId = 1937800639
					},
					{
						GiftName = "Dual Hakai Set",
						GiftId = 1937800642,
						Item = v.createListReward({
							v.createSwordReward("Dual Hakai Set"),
							v.createExplosionReward("Hakai!"),
							v.createEmoteReward("Emote545")
						}),
						ProductId = 1937800640
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HakaiPackRootStartTime",
		RootFFlagEndTime = "HakaiPackRootEndTime",
		FFlagStartTime = "HakaiPackStartTime",
		FFlagEndTime = "HakaiPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hakai Pack",
				Image = "rbxassetid://97445931183432",
				ShowRoom = "HakaiPackShowRoom",
				Rewards = {
					{
						GiftName = "Hakai Pack",
						GiftId = 1937800643,
						Item = v.createListReward({
							v.createSwordReward("Hakai Blade"),
							v.createSwordReward("Hakai Scorpion"),
							v.createExplosionReward("Destruction Star"),
							v.createEmoteReward("Emote544")
						}),
						ProductId = 1937800641,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Hakai Pack",
						GiftId = 1937800651,
						Item = v.createListReward({
							v.createSwordReward("Dual Hakai Blade"),
							v.createSwordReward("Dual Hakai Set"),
							v.createExplosionReward("Hakai!"),
							v.createEmoteReward("Emote543"),
							v.createEmoteReward("Emote545")
						}),
						ProductId = 1937800647,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}