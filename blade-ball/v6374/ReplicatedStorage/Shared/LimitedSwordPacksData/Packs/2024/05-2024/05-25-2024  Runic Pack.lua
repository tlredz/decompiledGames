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
		RootFFlagStartTime = "RunicPackRootStartTime",
		RootFFlagEndTime = "RunicPackRootEndTime",
		FFlagStartTime = "RunicBladeStartTime",
		FFlagEndTime = "RunicBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Runic Blade",
				Image = v2.Icons:GetSwordIcon("Dual Runic Blade"),
				ShowRoom = "RunicBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Runic Blade",
						GiftId = 1834650194,
						Item = v.createListReward({ v.createSwordReward("Runic Blade") }),
						ProductId = 1834650191
					},
					{
						GiftName = "Dual Runic Blade",
						GiftId = 1834650199,
						Item = v.createListReward({
							v.createSwordReward("Dual Runic Blade"),
							v.createExplosionReward("Runic Portal"),
							v.createEmoteReward("Emote351")
						}),
						ProductId = 1834650202
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RunicPackRootStartTime",
		RootFFlagEndTime = "RunicPackRootEndTime",
		FFlagStartTime = "RunicScytheStartTime",
		FFlagEndTime = "RunicScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Runic Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Runic Scythe"),
				ShowRoom = "RunicScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Runic Scythe",
						GiftId = 1834650196,
						Item = v.createListReward({
							v.createSwordReward("Runic Scythe"),
							v.createExplosionReward("Runic Curse"),
							v.createEmoteReward("Emote352")
						}),
						ProductId = 1834650197
					},
					{
						GiftName = "Dual Runic Scythe",
						GiftId = 1834650195,
						Item = v.createListReward({
							v.createSwordReward("Dual Runic Scythe"),
							v.createExplosionReward("Runic Curse"),
							v.createEmoteReward("Emote353")
						}),
						ProductId = 1834650201
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RunicPackRootStartTime",
		RootFFlagEndTime = "RunicPackRootEndTime",
		FFlagStartTime = "RunicPackStartTime",
		FFlagEndTime = "RunicPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Runic Pack",
				Image = "rbxassetid://17605626199",
				ShowRoom = "RunicPackShowRoom",
				Rewards = {
					{
						GiftName = "Runic Pack",
						GiftId = 1834650200,
						Item = v.createListReward({
							v.createSwordReward("Runic Blade"),
							v.createSwordReward("Runic Scythe"),
							v.createExplosionReward("Runic Portal"),
							v.createEmoteReward("Emote352")
						}),
						ProductId = 1834650203,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Runic Pack",
						GiftId = 1834650193,
						Item = v.createListReward({
							v.createSwordReward("Dual Runic Blade"),
							v.createSwordReward("Dual Runic Scythe"),
							v.createExplosionReward("Runic Curse"),
							v.createEmoteReward("Emote351"),
							v.createEmoteReward("Emote353")
						}),
						ProductId = 1834650198,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}