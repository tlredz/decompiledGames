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
		RootFFlagStartTime = "PhantomPackRootStartTime",
		RootFFlagEndTime = "PhantomPackRootEndTime",
		FFlagStartTime = "PhantomSwordStartTime",
		FFlagEndTime = "PhantomSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Phantom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Phantom Blade"),
				ShowRoom = "PhantomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Phantom Blade",
						GiftId = 1896542193,
						Item = v.createListReward({ v.createSwordReward("Phantom Blade") }),
						ProductId = 1896542198
					},
					{
						GiftName = "Dual Phantom Blade",
						GiftId = 1896542197,
						Item = v.createListReward({
							v.createSwordReward("Dual Phantom Blade"),
							v.createExplosionReward("Phantom Torch"),
							v.createEmoteReward("Emote470")
						}),
						ProductId = 1896542200
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PhantomPackRootStartTime",
		RootFFlagEndTime = "PhantomPackRootEndTime",
		FFlagStartTime = "PhantomBlasterStartTime",
		FFlagEndTime = "PhantomBlasterEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Phantom Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Phantom Scythe"),
				ShowRoom = "PhantomScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Phantom Scythe",
						GiftId = 1896542204,
						Item = v.createListReward({
							v.createSwordReward("Phantom Scythe"),
							v.createExplosionReward("Chromium Phantom"),
							v.createEmoteReward("Emote471")
						}),
						ProductId = 1896542196
					},
					{
						GiftName = "Dual Phantom Scythe",
						GiftId = 1896542194,
						Item = v.createListReward({
							v.createSwordReward("Dual Phantom Scythe"),
							v.createExplosionReward("Chromium Phantom"),
							v.createEmoteReward("Emote472")
						}),
						ProductId = 1896542195
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PhantomPackRootStartTime",
		RootFFlagEndTime = "PhantomPackRootEndTime",
		FFlagStartTime = "PhantomPackStartTime",
		FFlagEndTime = "PhantomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Phantom Pack",
				Image = "rbxassetid://18784933136",
				ShowRoom = "PhantomPackShowRoom",
				Rewards = {
					{
						GiftName = "Phantom Pack",
						GiftId = 1896542206,
						Item = v.createListReward({
							v.createSwordReward("Phantom Blade"),
							v.createSwordReward("Phantom Scythe"),
							v.createExplosionReward("Phantom Torch"),
							v.createEmoteReward("Emote471")
						}),
						ProductId = 1896542199,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Phantom Pack",
						GiftId = 1896542205,
						Item = v.createListReward({
							v.createSwordReward("Dual Phantom Blade"),
							v.createSwordReward("Dual Phantom Scythe"),
							v.createExplosionReward("Chromium Phantom"),
							v.createEmoteReward("Emote470"),
							v.createEmoteReward("Emote472")
						}),
						ProductId = 1896542207,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}