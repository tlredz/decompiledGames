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
		RootFFlagStartTime = "CursedPackRootStartTime",
		RootFFlagEndTime = "CursedPackRootEndTime",
		FFlagStartTime = "CursedSwordStartTime",
		FFlagEndTime = "CursedSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cursed Blade",
				Image = v2.Icons:GetSwordIcon("Dual Cursed Blade"),
				ShowRoom = "CursedBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Cursed Blade",
						GiftId = 1942159293,
						Item = v.createListReward({ v.createSwordReward("Cursed Blade") }),
						ProductId = 1942159282
					},
					{
						GiftName = "Dual Cursed Blade",
						GiftId = 1942159292,
						Item = v.createListReward({
							v.createSwordReward("Dual Cursed Blade"),
							v.createExplosionReward("Cursed Beam"),
							v.createEmoteReward("Emote550")
						}),
						ProductId = 1942159289
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CursedPackRootStartTime",
		RootFFlagEndTime = "CursedPackRootEndTime",
		FFlagStartTime = "CursedScytheStartTime",
		FFlagEndTime = "CursedScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cursed Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Cursed Scythe"),
				ShowRoom = "CursedScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Cursed Scythe",
						GiftId = 1942159297,
						Item = v.createListReward({
							v.createSwordReward("Cursed Scythe"),
							v.createExplosionReward("Cursed Eye"),
							v.createEmoteReward("Emote551")
						}),
						ProductId = 1942159286
					},
					{
						GiftName = "Dual Cursed Scythe",
						GiftId = 1942159283,
						Item = v.createListReward({
							v.createSwordReward("Dual Cursed Scythe"),
							v.createExplosionReward("Cursed Eye"),
							v.createEmoteReward("Emote552")
						}),
						ProductId = 1942159295
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CursedPackRootStartTime",
		RootFFlagEndTime = "CursedPackRootEndTime",
		FFlagStartTime = "CursedPackStartTime",
		FFlagEndTime = "CursedPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cursed Pack",
				Image = "rbxassetid://128033720750368",
				ShowRoom = "CursedPackShowRoom",
				Rewards = {
					{
						GiftName = "Cursed Pack",
						GiftId = 1942159288,
						Item = v.createListReward({
							v.createSwordReward("Cursed Blade"),
							v.createSwordReward("Cursed Scythe"),
							v.createExplosionReward("Cursed Beam"),
							v.createEmoteReward("Emote551")
						}),
						ProductId = 1942159291,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Cursed Pack",
						GiftId = 1942159285,
						Item = v.createListReward({
							v.createSwordReward("Dual Cursed Blade"),
							v.createSwordReward("Dual Cursed Scythe"),
							v.createExplosionReward("Cursed Eye"),
							v.createEmoteReward("Emote550"),
							v.createEmoteReward("Emote552")
						}),
						ProductId = 1942159298,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}