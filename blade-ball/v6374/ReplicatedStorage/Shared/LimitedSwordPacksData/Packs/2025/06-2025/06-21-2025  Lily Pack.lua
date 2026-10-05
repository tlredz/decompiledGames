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
		RootFFlagStartTime = "LilyPackRootStartTime",
		RootFFlagEndTime = "LilyPackRootEndTime",
		FFlagStartTime = "LilyBladeStartTime",
		FFlagEndTime = "LilyBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lily Blade",
				Image = v2.Icons:GetSwordIcon("Dual Lily Blade"),
				ShowRoom = "LilyBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lily Blade",
						GiftId = 3313331544,
						Item = v.createListReward({ v.createSwordReward("Lily Blade") }),
						ProductId = 3313331543
					},
					{
						GiftName = "Dual Lily Blade",
						GiftId = 3313331547,
						Item = v.createListReward({
							v.createSwordReward("Dual Lily Blade"),
							v.createExplosionReward("Lilies Bloom"),
							v.createEmoteReward("Emote962")
						}),
						ProductId = 3313331546
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LilyPackRootStartTime",
		RootFFlagEndTime = "LilyPackRootEndTime",
		FFlagStartTime = "LilyParasolStartTime",
		FFlagEndTime = "LilyParasolEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lily Parasol",
				Image = v2.Icons:GetSwordIcon("Lily Parasol"),
				ShowRoom = "LilyParasolShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lily Parasol",
						GiftId = 3313331549,
						Item = v.createListReward({
							v.createSwordReward("Lily Parasol"),
							v.createExplosionReward("Escaped Lilies"),
							v.createEmoteReward("Emote961")
						}),
						ProductId = 3313331548
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LilyPackRootStartTime",
		RootFFlagEndTime = "LilyPackRootEndTime",
		FFlagStartTime = "LilyPackStartTime",
		FFlagEndTime = "LilyPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lily Pack",
				Image = "rbxassetid://82540858668005",
				ShowRoom = "LilyPackShowRoom",
				Rewards = {
					{
						GiftName = "Lily Pack",
						GiftId = 3313331551,
						Item = v.createListReward({
							v.createSwordReward("Lily Blade"),
							v.createSwordReward("Lily Parasol"),
							v.createExplosionReward("Lilies Bloom"),
							v.createEmoteReward("Emote961")
						}),
						ProductId = 3313331545,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Lily Pack",
						GiftId = 3313331552,
						Item = v.createListReward({
							v.createSwordReward("Dual Lily Blade"),
							v.createSwordReward("Lily Parasol"),
							v.createExplosionReward("Escaped Lilies"),
							v.createEmoteReward("Emote962"),
							v.createEmoteReward("Emote961")
						}),
						ProductId = 3313331550,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}