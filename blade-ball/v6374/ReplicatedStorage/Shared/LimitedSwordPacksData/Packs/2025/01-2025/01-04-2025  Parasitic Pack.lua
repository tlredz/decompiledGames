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
		RootFFlagStartTime = "ParasiticPackRootStartTime",
		RootFFlagEndTime = "ParasiticPackRootEndTime",
		FFlagStartTime = "ParasiticDaggerStartTime",
		FFlagEndTime = "ParasiticDaggerEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Parasitic Dagger",
				Image = v2.Icons:GetSwordIcon("Dual Parasitic Dagger"),
				ShowRoom = "ParasiticDaggerShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Parasitic Dagger",
						GiftId = 2687731522,
						Item = v.createListReward({ v.createSwordReward("Parasitic Dagger") }),
						ProductId = 2687731528
					},
					{
						GiftName = "Dual Parasitic Dagger",
						GiftId = 2687731520,
						Item = v.createListReward({
							v.createSwordReward("Dual Parasitic Dagger"),
							v.createExplosionReward("Parasitic Vision"),
							v.createEmoteReward("Emote714")
						}),
						ProductId = 2687731517
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ParasiticPackRootStartTime",
		RootFFlagEndTime = "ParasiticPackRootEndTime",
		FFlagStartTime = "ParasiticScytheStartTime",
		FFlagEndTime = "ParasiticScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Parasitic Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Parasitic Scythe"),
				ShowRoom = "ParasiticScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Parasitic Scythe",
						GiftId = 2687731525,
						Item = v.createListReward({
							v.createSwordReward("Parasitic Scythe"),
							v.createExplosionReward("Parasitic Waves"),
							v.createEmoteReward("Emote715")
						}),
						ProductId = 2687731518
					},
					{
						GiftName = "Dual Parasitic Scythe",
						GiftId = 2687731524,
						Item = v.createListReward({
							v.createSwordReward("Dual Parasitic Scythe"),
							v.createExplosionReward("Parasitic Waves"),
							v.createEmoteReward("Emote716")
						}),
						ProductId = 2687731516
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ParasiticPackRootStartTime",
		RootFFlagEndTime = "ParasiticPackRootEndTime",
		FFlagStartTime = "ParasiticPackStartTime",
		FFlagEndTime = "ParasiticPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Parasitic Pack",
				Image = "rbxassetid://132692637418089",
				ShowRoom = "ParasiticPackShowRoom",
				Rewards = {
					{
						GiftName = "Parasitic Pack",
						GiftId = 2687731521,
						Item = v.createListReward({
							v.createSwordReward("Parasitic Dagger"),
							v.createSwordReward("Parasitic Scythe"),
							v.createExplosionReward("Parasitic Vision"),
							v.createEmoteReward("Emote715")
						}),
						ProductId = 2687731515,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Parasitic Pack",
						GiftId = 2687731523,
						Item = v.createListReward({
							v.createSwordReward("Dual Parasitic Dagger"),
							v.createSwordReward("Dual Parasitic Scythe"),
							v.createExplosionReward("Parasitic Waves"),
							v.createEmoteReward("Emote714"),
							v.createEmoteReward("Emote716")
						}),
						ProductId = 2687731519,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}