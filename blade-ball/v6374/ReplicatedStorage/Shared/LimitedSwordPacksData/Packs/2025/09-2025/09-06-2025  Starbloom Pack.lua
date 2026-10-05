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
		RootFFlagStartTime = "StarbloomPackRootStartTime",
		RootFFlagEndTime = "StarbloomPackRootEndTime",
		FFlagStartTime = "StarbloomBladeStartTime",
		FFlagEndTime = "StarbloomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starbloom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Starbloom Blade"),
				ShowRoom = "StarbloomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Starbloom Blade",
						GiftId = 3397438021,
						Item = v.createListReward({ v.createSwordReward("Starbloom Blade") }),
						ProductId = 3397438016
					},
					{
						GiftName = "Dual Starbloom Blade",
						GiftId = 3397438022,
						Item = v.createListReward({
							v.createSwordReward("Dual Starbloom Blade"),
							v.createExplosionReward("Starbloom Vision"),
							v.createEmoteReward("Emote1027")
						}),
						ProductId = 3397438025
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarbloomPackRootStartTime",
		RootFFlagEndTime = "StarbloomPackRootEndTime",
		FFlagStartTime = "StarbloomScytheStartTime",
		FFlagEndTime = "StarbloomScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starbloom Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Starbloom Scythe"),
				ShowRoom = "StarbloomScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Starbloom Scythe",
						GiftId = 3397438019,
						Item = v.createListReward({
							v.createSwordReward("Starbloom Scythe"),
							v.createExplosionReward("Starbloom Core"),
							v.createEmoteReward("Emote1027")
						}),
						ProductId = 3397438023
					},
					{
						GiftName = "Dual Starbloom Scythe",
						GiftId = 3397438029,
						Item = v.createListReward({
							v.createSwordReward("Dual Starbloom Scythe"),
							v.createExplosionReward("Starbloom Core"),
							v.createEmoteReward("Emote1028")
						}),
						ProductId = 3397438018
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarbloomPackRootStartTime",
		RootFFlagEndTime = "StarbloomPackRootEndTime",
		FFlagStartTime = "StarbloomPackStartTime",
		FFlagEndTime = "StarbloomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starbloom Pack",
				Image = "rbxassetid://113339559551149",
				ShowRoom = "StarbloomPackShowRoom",
				Rewards = {
					{
						GiftName = "Starbloom Pack",
						GiftId = 3397438027,
						Item = v.createListReward({
							v.createSwordReward("Starbloom Blade"),
							v.createSwordReward("Starbloom Scythe"),
							v.createExplosionReward("Starbloom Vision"),
							v.createEmoteReward("Emote1028")
						}),
						ProductId = 3397438024,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Starbloom Pack",
						GiftId = 3397438026,
						Item = v.createListReward({
							v.createSwordReward("Dual Starbloom Blade"),
							v.createSwordReward("Dual Starbloom Scythe"),
							v.createExplosionReward("Starbloom Core"),
							v.createEmoteReward("Emote1027"),
							v.createEmoteReward("Emote1029")
						}),
						ProductId = 3397438028,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}