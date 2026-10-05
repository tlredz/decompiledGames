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
		RootFFlagStartTime = "HeroofHopePackRootStartTime",
		RootFFlagEndTime = "HeroofHopePackRootEndTime",
		FFlagStartTime = "HeroofHopeSaberStartTime",
		FFlagEndTime = "HeroofHopeSaberEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hero of Hope Saber",
				Image = v2.Icons:GetSwordIcon("Dual Hero of Hope Saber"),
				ShowRoom = "HeroofHopeSaberShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hero of Hope Saber",
						GiftId = 3542483759,
						Item = v.createListReward({ v.createSwordReward("Hero of Hope Saber") }),
						ProductId = 3542483765
					},
					{
						GiftName = "Dual Hero of Hope Saber",
						GiftId = 3542483770,
						Item = v.createListReward({
							v.createSwordReward("Dual Hero of Hope Saber"),
							v.createExplosionReward("Hero of Hope Spark"),
							v.createEmoteReward("Emote1168")
						}),
						ProductId = 3542483760
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeroofHopePackRootStartTime",
		RootFFlagEndTime = "HeroofHopePackRootEndTime",
		FFlagStartTime = "HeroofHopeScytheStartTime",
		FFlagEndTime = "HeroofHopeScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hero of Hope Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Hero of Hope Scythe"),
				ShowRoom = "HeroofHopeScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hero of Hope Scythe",
						GiftId = 3542483769,
						Item = v.createListReward({
							v.createSwordReward("Hero of Hope Scythe"),
							v.createExplosionReward("Hero Bloom"),
							v.createEmoteReward("Emote1169")
						}),
						ProductId = 3542483764
					},
					{
						GiftName = "Dual Hero of Hope Scythe",
						GiftId = 3542483762,
						Item = v.createListReward({
							v.createSwordReward("Dual Hero of Hope Scythe"),
							v.createExplosionReward("Hero Bloom"),
							v.createEmoteReward("Emote1170")
						}),
						ProductId = 3542483766
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HeroofHopePackRootStartTime",
		RootFFlagEndTime = "HeroofHopePackRootEndTime",
		FFlagStartTime = "HeroofHopePackStartTime",
		FFlagEndTime = "HeroofHopePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hero of Hope Pack",
				Image = "rbxassetid://90935021851196",
				ShowRoom = "HeroofHopePackShowRoom",
				Rewards = {
					{
						GiftName = "Hero of Hope Pack",
						GiftId = 3542483767,
						Item = v.createListReward({
							v.createSwordReward("Hero of Hope Saber"),
							v.createSwordReward("Hero of Hope Scythe"),
							v.createExplosionReward("Hero of Hope Spark"),
							v.createEmoteReward("Emote1169")
						}),
						ProductId = 3542483768,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Hero of Hope Pack",
						GiftId = 3542483763,
						Item = v.createListReward({
							v.createSwordReward("Dual Hero of Hope Saber"),
							v.createSwordReward("Dual Hero of Hope Scythe"),
							v.createExplosionReward("Hero Bloom"),
							v.createEmoteReward("Emote1168"),
							v.createEmoteReward("Emote1170")
						}),
						ProductId = 3542483771,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}