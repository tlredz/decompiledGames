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
		RootFFlagStartTime = "CrystalRibbonStartTime",
		RootFFlagEndTime = "CrystalRibbonEndTime",
		FFlagStartTime = "CrystalRibbonBladeStartTime",
		FFlagEndTime = "CrystalRibbonBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Ribbon Blade",
				Image = v2.Icons:GetSwordIcon("Dual Crystal Ribbon Blade"),
				ShowRoom = "CrystalRibbonBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Crystal Ribbon Blade",
						GiftId = 3564884273,
						Item = v.createListReward({ v.createSwordReward("Crystal Ribbon Blade") }),
						ProductId = 3564884276
					},
					{
						GiftName = "Dual Crystal Ribbon Blade",
						GiftId = 3564884267,
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Ribbon Blade"),
							v.createExplosionReward("Crystalized Path"),
							v.createEmoteReward("Emote1191")
						}),
						ProductId = 3564884277
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CrystalRibbonStartTime",
		RootFFlagEndTime = "CrystalRibbonEndTime",
		FFlagStartTime = "CrystalRibbonScytheStartTime",
		FFlagEndTime = "CrystalRibbonScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Ribbon Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Crystal Ribbon Scythe"),
				ShowRoom = "CrystalRibbonScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Crystal Ribbon Scythe",
						GiftId = 3564884275,
						Item = v.createListReward({
							v.createSwordReward("Crystal Ribbon Scythe"),
							v.createExplosionReward("Crystal Mirror"),
							v.createEmoteReward("Emote1192")
						}),
						ProductId = 3564884274
					},
					{
						GiftName = "Dual Crystal Ribbon Scythe",
						GiftId = 3564884272,
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Ribbon Scythe"),
							v.createExplosionReward("Crystal Mirror"),
							v.createEmoteReward("Emote1193")
						}),
						ProductId = 3564884271
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CrystalRibbonStartTime",
		RootFFlagEndTime = "CrystalRibbonEndTime",
		FFlagStartTime = "CrystalRibbonPackStartTime",
		FFlagEndTime = "CrystalRibbonPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Ribbon Pack",
				Image = "rbxassetid://105444295681610",
				ShowRoom = "CrystalRibbonPackShowRoom",
				Rewards = {
					{
						GiftName = "Crystal Ribbon Pack",
						GiftId = 3564884266,
						Item = v.createListReward({
							v.createSwordReward("Crystal Ribbon Blade"),
							v.createSwordReward("Crystal Ribbon Scythe"),
							v.createExplosionReward("Crystalized Path"),
							v.createEmoteReward("Emote1192")
						}),
						ProductId = 3564884270,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Crystal Ribbon Pack",
						GiftId = 3564884278,
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Ribbon Blade"),
							v.createSwordReward("Dual Crystal Ribbon Scythe"),
							v.createExplosionReward("Crystal Mirror"),
							v.createEmoteReward("Emote1191"),
							v.createEmoteReward("Emote1193")
						}),
						ProductId = 3564884268,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}