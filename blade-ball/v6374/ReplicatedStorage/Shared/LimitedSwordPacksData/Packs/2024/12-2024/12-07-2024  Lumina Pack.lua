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
		RootFFlagStartTime = "LuminaPackRootStartTime",
		RootFFlagEndTime = "LuminaPackRootEndTime",
		FFlagStartTime = "LuminaBladeStartTime",
		FFlagEndTime = "LuminaBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumina Blade",
				Image = v2.Icons:GetSwordIcon("Dual Lumina Blade"),
				ShowRoom = "LuminaBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumina Blade",
						GiftId = 2669774736,
						Item = v.createListReward({ v.createSwordReward("Lumina Blade") }),
						ProductId = 2669774745
					},
					{
						GiftName = "Dual Lumina Blade",
						GiftId = 2669774737,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumina Blade"),
							v.createExplosionReward("White Diamond"),
							v.createEmoteReward("Emote658")
						}),
						ProductId = 2669774738
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LuminaPackRootStartTime",
		RootFFlagEndTime = "LuminaPackRootEndTime",
		FFlagStartTime = "LuminaBowStartTime",
		FFlagEndTime = "LuminaBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumina Bow",
				Image = v2.Icons:GetSwordIcon("Lumina Bow"),
				ShowRoom = "LuminaBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumina Bow",
						GiftId = 2669774739,
						Item = v.createListReward({
							v.createSwordReward("Lumina Bow"),
							v.createExplosionReward("Diamond Stars"),
							v.createEmoteReward("Emote659")
						}),
						ProductId = 2669774740
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LuminaPackRootStartTime",
		RootFFlagEndTime = "LuminaPackRootEndTime",
		FFlagStartTime = "LuminaPackStartTime",
		FFlagEndTime = "LuminaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumina Pack",
				Image = "rbxassetid://108887944941785",
				ShowRoom = "LuminaPackShowRoom",
				Rewards = {
					{
						GiftName = "Lumina Pack",
						GiftId = 2669774741,
						Item = v.createListReward({
							v.createSwordReward("Lumina Blade"),
							v.createSwordReward("Lumina Bow"),
							v.createExplosionReward("White Diamond"),
							v.createEmoteReward("Emote659")
						}),
						ProductId = 2669774744,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Lumina Pack",
						GiftId = 2669774743,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumina Blade"),
							v.createSwordReward("Lumina Bow"),
							v.createExplosionReward("Diamond Stars"),
							v.createEmoteReward("Emote658"),
							v.createEmoteReward("Emote659")
						}),
						ProductId = 2669774742,
						DiscountedFrom = 2999
					}
				}
			}
		}
	}
}