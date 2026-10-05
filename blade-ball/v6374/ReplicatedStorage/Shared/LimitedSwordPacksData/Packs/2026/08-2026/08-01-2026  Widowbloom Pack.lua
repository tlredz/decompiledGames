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
		RootFFlagStartTime = "WidowbloomStartTime",
		RootFFlagEndTime = "WidowbloomEndTime",
		FFlagStartTime = "WidowbloomBladeStartTime",
		FFlagEndTime = "WidowbloomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Widowbloom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Widowbloom Blade"),
				ShowRoom = "WidowbloomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Widowbloom Blade",
						GiftId = 3612678838,
						Item = v.createListReward({ v.createSwordReward("Widowbloom Blade") }),
						ProductId = 3612678841
					},
					{
						GiftName = "Dual Widowbloom Blade",
						GiftId = 3612678847,
						Item = v.createListReward({
							v.createSwordReward("Dual Widowbloom Blade"),
							v.createExplosionReward("Widow's Garden"),
							v.createEmoteReward("Emote1258")
						}),
						ProductId = 3612678852
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WidowbloomStartTime",
		RootFFlagEndTime = "WidowbloomEndTime",
		FFlagStartTime = "WidowbloomBowStartTime",
		FFlagEndTime = "WidowbloomBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Widowbloom Bow",
				Image = v2.Icons:GetSwordIcon("Widowbloom Bow"),
				ShowRoom = "WidowbloomBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Widowbloom Bow",
						GiftId = 3612678855,
						Item = v.createListReward({
							v.createSwordReward("Widowbloom Bow"),
							v.createExplosionReward("Widow's Garden"),
							v.createEmoteReward("Emote1257")
						}),
						ProductId = 3612678865
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "WidowbloomStartTime",
		RootFFlagEndTime = "WidowbloomEndTime",
		FFlagStartTime = "WidowbloomPackStartTime",
		FFlagEndTime = "WidowbloomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Widowbloom Pack",
				Image = "rbxassetid://118215688727085",
				ShowRoom = "WidowbloomPackShowRoom",
				Rewards = {
					{
						GiftName = "Widowbloom Pack",
						GiftId = 3612678869,
						Item = v.createListReward({
							v.createSwordReward("Widowbloom Blade"),
							v.createSwordReward("Widowbloom Bow"),
							v.createExplosionReward("Widow's Garden"),
							v.createEmoteReward("Emote1257")
						}),
						ProductId = 3612678871
					},
					{
						GiftName = "Dual Widowbloom Pack",
						GiftId = 3612678875,
						Item = v.createListReward({
							v.createSwordReward("Dual Widowbloom Blade"),
							v.createSwordReward("Widowbloom Bow"),
							v.createExplosionReward("Venom's Blossom"),
							v.createEmoteReward("Emote1258"),
							v.createEmoteReward("Emote1257")
						}),
						ProductId = 3612678881
					}
				}
			}
		}
	}
}