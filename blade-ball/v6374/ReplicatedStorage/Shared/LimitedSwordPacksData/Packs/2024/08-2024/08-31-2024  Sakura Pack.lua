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
		RootFFlagParasoltTime = "SakuraPackRootParasoltTime",
		RootFFlagEndTime = "SakuraPackRootEndTime",
		FFlagParasoltTime = "SakuraFanParasoltTime",
		FFlagEndTime = "SakuraFanEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sakura Fan",
				Image = v2.Icons:GetSwordIcon("Dual Sakura Fan"),
				ShowRoom = "SakuraFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sakura Fan",
						GiftId = 1922479632,
						Item = v.createListReward({ v.createSwordReward("Sakura Fan") }),
						ProductId = 1922479634
					},
					{
						GiftName = "Dual Sakura Fan",
						GiftId = 1922479631,
						Item = v.createListReward({
							v.createSwordReward("Dual Sakura Fan"),
							v.createExplosionReward("Hanami Explosion"),
							v.createEmoteReward("Emote506")
						}),
						ProductId = 1922479648
					}
				}
			}
		}
	},
	{
		RootFFlagParasoltTime = "SakuraPackRootParasoltTime",
		RootFFlagEndTime = "SakuraPackRootEndTime",
		FFlagParasoltTime = "SakuraParasolParasoltTime",
		FFlagEndTime = "SakuraParasolEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sakura Parasol",
				Image = v2.Icons:GetSwordIcon("Sakura Parasol"),
				ShowRoom = "SakuraParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sakura Parasol",
						GiftId = 1922479650,
						Item = v.createListReward({
							v.createSwordReward("Sakura Parasol"),
							v.createExplosionReward("Sakura Season"),
							v.createEmoteReward("Emote507")
						}),
						ProductId = 1922479643
					}
				}
			}
		}
	},
	{
		RootFFlagParasoltTime = "SakuraPackRootParasoltTime",
		RootFFlagEndTime = "SakuraPackRootEndTime",
		FFlagParasoltTime = "SakuraPackParasoltTime",
		FFlagEndTime = "SakuraPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sakura Parasol Pack",
				Image = "rbxassetid://127411852145685",
				ShowRoom = "SakuraPackShowRoom",
				Rewards = {
					{
						GiftName = "Single Sakura Pack",
						GiftId = 1922480880,
						Item = v.createListReward({
							v.createSwordReward("Sakura Fan"),
							v.createSwordReward("Sakura Parasol"),
							v.createExplosionReward("Sakura Season"),
							v.createEmoteReward("Emote507")
						}),
						ProductId = 1922480879,
						DiscountedFrom = 2250
					},
					{
						GiftName = "Dual Sakura Pack",
						GiftId = 1922479637,
						Item = v.createListReward({
							v.createSwordReward("Dual Sakura Fan"),
							v.createSwordReward("Sakura Parasol"),
							v.createExplosionReward("Sakura Season"),
							v.createEmoteReward("Emote506"),
							v.createEmoteReward("Emote507")
						}),
						ProductId = 1922479635,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}