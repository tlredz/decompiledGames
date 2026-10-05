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
		RootFFlagStartTime = "MoonCycleStartTime",
		RootFFlagEndTime = "MoonCycleEndTime",
		FFlagStartTime = "MoonCycleSaberStartTime",
		FFlagEndTime = "MoonCycleSaberEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moon Cycle Saber",
				Image = v2.Icons:GetSwordIcon("Dual Moon Cycle Saber"),
				ShowRoom = "MoonCycleSaberShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moon Cycle Saber",
						GiftId = 3577257032,
						Item = v.createListReward({ v.createSwordReward("Moon Cycle Saber") }),
						ProductId = 3577257033
					},
					{
						GiftName = "Dual Moon Cycle Saber",
						GiftId = 3577257041,
						Item = v.createListReward({
							v.createSwordReward("Dual Moon Cycle Saber"),
							v.createExplosionReward("Moon Cycle Explosion"),
							v.createEmoteReward("Emote1203")
						}),
						ProductId = 3577257037
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonCycleStartTime",
		RootFFlagEndTime = "MoonCycleEndTime",
		FFlagStartTime = "MoonCycleScytheStartTime",
		FFlagEndTime = "MoonCycleScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moon Cycle Scythe",
				Image = v2.Icons:GetSwordIcon("Moon Cycle Scythe"),
				ShowRoom = "MoonCycleScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Moon Cycle Scythe",
						GiftId = 3577257042,
						Item = v.createListReward({
							v.createSwordReward("Moon Cycle Scythe"),
							v.createExplosionReward("Full Moon Explosion"),
							v.createEmoteReward("Emote1201")
						}),
						ProductId = 3577257040
					},
					{
						GiftName = "Dual Moon Cycle Scythe",
						GiftId = 3577257036,
						Item = v.createListReward({
							v.createSwordReward("Dual Moon Cycle Scythe"),
							v.createExplosionReward("Full Moon Explosion"),
							v.createEmoteReward("Emote1202")
						}),
						ProductId = 3577257034
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "MoonCycleStartTime",
		RootFFlagEndTime = "MoonCycleEndTime",
		FFlagStartTime = "MoonCyclePackStartTime",
		FFlagEndTime = "MoonCyclePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Moon Cycle Pack",
				Image = "rbxassetid://78848174220445",
				ShowRoom = "MoonCyclePackShowRoom",
				Rewards = {
					{
						GiftName = "Moon Cycle Pack",
						GiftId = 3577257038,
						Item = v.createListReward({
							v.createSwordReward("Moon Cycle Saber"),
							v.createSwordReward("Moon Cycle Scythe"),
							v.createExplosionReward("Moon Cycle Explosion"),
							v.createEmoteReward("Emote1201")
						}),
						ProductId = 3577257039,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Moon Cycle Pack",
						GiftId = 3577257043,
						Item = v.createListReward({
							v.createSwordReward("Dual Moon Cycle Saber"),
							v.createSwordReward("Dual Moon Cycle Scythe"),
							v.createExplosionReward("Full Moon Explosion"),
							v.createEmoteReward("Emote1203"),
							v.createEmoteReward("Emote1202")
						}),
						ProductId = 3577257035,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}