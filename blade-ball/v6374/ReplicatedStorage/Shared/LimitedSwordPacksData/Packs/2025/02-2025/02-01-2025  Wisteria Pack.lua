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
		RootFFlagStartTime = "WisteriaPackRootStartTime",
		RootFFlagEndTime = "WisteriaPackRootEndTime",
		FFlagStartTime = "WisteriaBladeStartTime",
		FFlagEndTime = "WisteriaBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wisteria Blade",
				Image = v2.Icons:GetSwordIcon("Dual Wisteria Blade"),
				ShowRoom = "WisteriaBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Wisteria Blade",
						GiftId = 2736323719,
						Item = v.createListReward({ v.createSwordReward("Wisteria Blade") }),
						ProductId = 2736323726
					},
					{
						GiftName = "Dual Wisteria Blade",
						GiftId = 2736323722,
						Item = v.createListReward({
							v.createSwordReward("Dual Wisteria Blade"),
							v.createExplosionReward("Wisteria Clouds"),
							v.createEmoteReward("Emote765")
						}),
						ProductId = 2736323718
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WisteriaPackRootStartTime",
		RootFFlagEndTime = "WisteriaPackRootEndTime",
		FFlagStartTime = "WisteriaParasolStartTime",
		FFlagEndTime = "WisteriaParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wisteria Parasol",
				Image = v2.Icons:GetSwordIcon("Wisteria Parasol"),
				ShowRoom = "WisteriaParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Wisteria Parasol",
						GiftId = 2736323724,
						Item = v.createListReward({
							v.createSwordReward("Wisteria Parasol"),
							v.createExplosionReward("Wisteria Swirl"),
							v.createEmoteReward("Emote764")
						}),
						ProductId = 2736323720
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WisteriaPackRootStartTime",
		RootFFlagEndTime = "WisteriaPackRootEndTime",
		FFlagStartTime = "WisteriaPackStartTime",
		FFlagEndTime = "WisteriaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wisteria Pack",
				Image = "rbxassetid://126188789524180",
				ShowRoom = "WisteriaPackShowRoom",
				Rewards = {
					{
						GiftName = "Wisteria Pack",
						GiftId = 2736323725,
						Item = v.createListReward({
							v.createSwordReward("Wisteria Blade"),
							v.createSwordReward("Wisteria Parasol"),
							v.createExplosionReward("Wisteria Clouds"),
							v.createEmoteReward("Emote764")
						}),
						ProductId = 2736323721,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Wisteria Pack",
						GiftId = 2736323717,
						Item = v.createListReward({
							v.createSwordReward("Dual Wisteria Blade"),
							v.createSwordReward("Wisteria Parasol"),
							v.createExplosionReward("Wisteria Swirl"),
							v.createEmoteReward("Emote764"),
							v.createEmoteReward("Emote765")
						}),
						ProductId = 2736323723,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}