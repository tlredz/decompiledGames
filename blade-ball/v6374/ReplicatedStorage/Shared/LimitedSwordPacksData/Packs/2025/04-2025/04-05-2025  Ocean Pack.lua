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
		RootFFlagStartTime = "OceanPackRootStartTime",
		RootFFlagEndTime = "OceanPackRootEndTime",
		FFlagStartTime = "OceanDaggerStartTime",
		FFlagEndTime = "OceanDaggerEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ocean Dagger",
				Image = v2.Icons:GetSwordIcon("Dual Ocean Dagger"),
				ShowRoom = "OceanDaggerShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ocean Dagger",
						GiftId = 3257883853,
						Item = v.createListReward({ v.createSwordReward("Ocean Dagger") }),
						ProductId = 3257883852
					},
					{
						GiftName = "Dual Ocean Dagger",
						GiftId = 3257883851,
						Item = v.createListReward({
							v.createSwordReward("Dual Ocean Dagger"),
							v.createExplosionReward("Oceanflow Puddle"),
							v.createEmoteReward("Emote854")
						}),
						ProductId = 3257883850
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "OceanPackRootStartTime",
		RootFFlagEndTime = "OceanPackRootEndTime",
		FFlagStartTime = "OceanGuitarStartTime",
		FFlagEndTime = "OceanGuitarEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ocean Guitar",
				Image = v2.Icons:GetSwordIcon("Ocean Guitar"),
				ShowRoom = "OceanGuitarShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Ocean Guitar",
						GiftId = 3257883855,
						Item = v.createListReward({
							v.createSwordReward("Ocean Guitar"),
							v.createExplosionReward("Oceanflow Peak"),
							v.createEmoteReward("Emote855")
						}),
						ProductId = 3257883857
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "OceanPackRootStartTime",
		RootFFlagEndTime = "OceanPackRootEndTime",
		FFlagStartTime = "OceanPackStartTime",
		FFlagEndTime = "OceanPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ocean Pack",
				Image = "rbxassetid://101626850031681",
				ShowRoom = "OceanPackShowRoom",
				Rewards = {
					{
						GiftName = "Ocean Pack",
						GiftId = 3257883858,
						Item = v.createListReward({
							v.createSwordReward("Ocean Dagger"),
							v.createSwordReward("Ocean Guitar"),
							v.createExplosionReward("Oceanflow Puddle"),
							v.createEmoteReward("Emote855")
						}),
						ProductId = 3257883849,
						DiscountedFrom = 2999
					},
					{
						GiftName = "Dual Ocean Pack",
						GiftId = 3257883854,
						Item = v.createListReward({
							v.createSwordReward("Dual Ocean Dagger"),
							v.createSwordReward("Ocean Guitar"),
							v.createExplosionReward("Oceanflow Peak"),
							v.createEmoteReward("Emote854"),
							v.createEmoteReward("Emote855")
						}),
						ProductId = 3257883856,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}