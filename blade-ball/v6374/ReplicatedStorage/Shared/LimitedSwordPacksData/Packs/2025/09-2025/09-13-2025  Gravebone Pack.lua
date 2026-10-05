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
		RootFFlagStartTime = "GravebonePackRootStartTime",
		RootFFlagEndTime = "GravebonePackRootEndTime",
		FFlagStartTime = "GraveboneBladeStartTime",
		FFlagEndTime = "GraveboneBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gravebone Blade",
				Image = v2.Icons:GetSwordIcon("Dual Gravebone Blade"),
				ShowRoom = "GraveboneBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gravebone Blade",
						GiftId = 3403846181,
						Item = v.createListReward({ v.createSwordReward("Gravebone Blade") }),
						ProductId = 3403846176
					},
					{
						GiftName = "Dual Gravebone Blade",
						GiftId = 3403847576,
						Item = v.createListReward({
							v.createSwordReward("Dual Gravebone Blade"),
							v.createExplosionReward("Gravebone Crush"),
							v.createEmoteReward("Emote1041")
						}),
						ProductId = 3403846180
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GravebonePackRootStartTime",
		RootFFlagEndTime = "GravebonePackRootEndTime",
		FFlagStartTime = "GraveboneScytheStartTime",
		FFlagEndTime = "GraveboneScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gravebone Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Gravebone Scythe"),
				ShowRoom = "GraveboneScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Gravebone Scythe",
						GiftId = 3403846184,
						Item = v.createListReward({
							v.createSwordReward("Gravebone Scythe"),
							v.createExplosionReward("Gravebone Streak"),
							v.createEmoteReward("Emote1042")
						}),
						ProductId = 3403846183
					},
					{
						GiftName = "Dual Gravebone Scythe",
						GiftId = 3403846175,
						Item = v.createListReward({
							v.createSwordReward("Dual Gravebone Scythe"),
							v.createExplosionReward("Gravebone Streak"),
							v.createEmoteReward("Emote1043")
						}),
						ProductId = 3403846179
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "GravebonePackRootStartTime",
		RootFFlagEndTime = "GravebonePackRootEndTime",
		FFlagStartTime = "GravebonePackStartTime",
		FFlagEndTime = "GravebonePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gravebone Pack",
				Image = "rbxassetid://123620243138485",
				ShowRoom = "GravebonePackShowRoom",
				Rewards = {
					{
						GiftName = "Gravebone Pack",
						GiftId = 3403846178,
						Item = v.createListReward({
							v.createSwordReward("Gravebone Blade"),
							v.createSwordReward("Gravebone Scythe"),
							v.createExplosionReward("Gravebone Crush"),
							v.createEmoteReward("Emote1042")
						}),
						ProductId = 3403846177,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Gravebone Pack",
						GiftId = 3403846182,
						Item = v.createListReward({
							v.createSwordReward("Dual Gravebone Blade"),
							v.createSwordReward("Dual Gravebone Scythe"),
							v.createExplosionReward("Gravebone Streak"),
							v.createEmoteReward("Emote1043"),
							v.createEmoteReward("Emote1041")
						}),
						ProductId = 3403846185,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}