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
		RootFFlagStartTime = "DivinePackRootStartTime",
		RootFFlagEndTime = "DivinePackRootEndTime",
		FFlagStartTime = "DivineSwordStartTime",
		FFlagEndTime = "DivineSwordEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Sword",
				Image = v2.Icons:GetSwordIcon("Dual Divine Sword"),
				ShowRoom = "DivineSwordShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divine Sword",
						GiftId = 1889292956,
						Item = v.createListReward({ v.createSwordReward("Divine Sword") }),
						ProductId = 1889292949
					},
					{
						GiftName = "Dual Divine Sword",
						GiftId = 1889292953,
						Item = v.createListReward({
							v.createSwordReward("Dual Divine Sword"),
							v.createExplosionReward("Judge Gavel"),
							v.createEmoteReward("Emote456")
						}),
						ProductId = 1889292963
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivinePackRootStartTime",
		RootFFlagEndTime = "DivinePackRootEndTime",
		FFlagStartTime = "DivineBlasterStartTime",
		FFlagEndTime = "DivineBlasterEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Blaster",
				Image = v2.Icons:GetSwordIcon("Dual Divine Blaster"),
				ShowRoom = "DivineBlasterShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divine Blaster",
						GiftId = 1889292964,
						Item = v.createListReward({
							v.createSwordReward("Divine Blaster"),
							v.createExplosionReward("Court Justice"),
							v.createEmoteReward("Emote457")
						}),
						ProductId = 1889292955
					},
					{
						GiftName = "Dual Divine Blaster",
						GiftId = 1889292954,
						Item = v.createListReward({
							v.createSwordReward("Dual Divine Blaster"),
							v.createExplosionReward("Court Justice"),
							v.createEmoteReward("Emote455")
						}),
						ProductId = 1889292962
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivinePackRootStartTime",
		RootFFlagEndTime = "DivinePackRootEndTime",
		FFlagStartTime = "DivinePackStartTime",
		FFlagEndTime = "DivinePackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divine Pack",
				Image = "rbxassetid://18681229941",
				ShowRoom = "DivinePackShowRoom",
				Rewards = {
					{
						GiftName = "Divine Pack",
						GiftId = 1889292960,
						Item = v.createListReward({
							v.createSwordReward("Divine Sword"),
							v.createSwordReward("Divine Blaster"),
							v.createExplosionReward("Judge Gavel"),
							v.createEmoteReward("Emote457")
						}),
						ProductId = 1889292957,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Divine Pack",
						GiftId = 1889292950,
						Item = v.createListReward({
							v.createSwordReward("Dual Divine Sword"),
							v.createSwordReward("Dual Divine Blaster"),
							v.createExplosionReward("Court Justice"),
							v.createEmoteReward("Emote455"),
							v.createEmoteReward("Emote456")
						}),
						ProductId = 1889292951,
						DiscountedFrom = 3250
					}
				}
			}
		}
	}
}