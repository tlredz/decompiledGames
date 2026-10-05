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
		RootFFlagStartTime = "SinisterPackRootStartTime",
		RootFFlagEndTime = "SinisterPackRootEndTime",
		FFlagStartTime = "SinisterBladeStartTime",
		FFlagEndTime = "SinisterBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sinister Blade",
				Image = v2.Icons:GetSwordIcon("Dual Sinister Blade"),
				ShowRoom = "SinisterBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sinister Blade",
						GiftId = 1880798601,
						Item = v.createListReward({ v.createSwordReward("Sinister Blade") }),
						ProductId = 1880798600
					},
					{
						GiftName = "Dual Sinister Blade",
						GiftId = 1880798606,
						Item = v.createListReward({
							v.createSwordReward("Dual Sinister Blade"),
							v.createExplosionReward("Sinister Smurk"),
							v.createEmoteReward("Emote442")
						}),
						ProductId = 1880798610
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SinisterPackRootStartTime",
		RootFFlagEndTime = "SinisterPackRootEndTime",
		FFlagStartTime = "SinisterBlasterStartTime",
		FFlagEndTime = "SinisterBlasterEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sinister Blaster",
				Image = v2.Icons:GetSwordIcon("Dual Sinister Blasters"),
				ShowRoom = "SinisterBlasterShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sinister Blaster",
						GiftId = 1880798599,
						Item = v.createListReward({
							v.createSwordReward("Sinister Blaster"),
							v.createExplosionReward("Sinister Shaft"),
							v.createEmoteReward("Emote443")
						}),
						ProductId = 1880798604
					},
					{
						GiftName = "Dual Sinister Blasters",
						GiftId = 1880798603,
						Item = v.createListReward({
							v.createSwordReward("Dual Sinister Blasters"),
							v.createExplosionReward("Sinister Shaft"),
							v.createEmoteReward("Emote444")
						}),
						ProductId = 1880798602
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SinisterPackRootStartTime",
		RootFFlagEndTime = "SinisterPackRootEndTime",
		FFlagStartTime = "SinisterPackStartTime",
		FFlagEndTime = "SinisterPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sinister Pack",
				Image = "rbxassetid://18578585317",
				ShowRoom = "SinisterPackShowRoom",
				Rewards = {
					{
						GiftName = "Sinister Pack",
						GiftId = 1880798608,
						Item = v.createListReward({
							v.createSwordReward("Sinister Blade"),
							v.createSwordReward("Sinister Blaster"),
							v.createExplosionReward("Sinister Smurk"),
							v.createEmoteReward("Emote443")
						}),
						ProductId = 1880798598,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Sinister Pack",
						GiftId = 1880798607,
						Item = v.createListReward({
							v.createSwordReward("Dual Sinister Blade"),
							v.createSwordReward("Dual Sinister Blasters"),
							v.createExplosionReward("Sinister Shaft"),
							v.createEmoteReward("Emote442"),
							v.createEmoteReward("Emote444")
						}),
						ProductId = 1880798609,
						DiscountedFrom = 3250
					}
				}
			}
		}
	}
}