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
		FFlagStartTime = "StellarBladeStartTime",
		FFlagEndTime = "StellarBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stellar Blade",
				Image = v2.Icons:GetSwordIcon("Stellar Blade"),
				ShowRoom = "StellarBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Stellar Blade",
						Item = v.createListReward({ v.createSwordReward("Stellar Blade") }),
						ProductId = 1783955673
					},
					{
						GiftName = "Dual Stellar Blade",
						Item = v.createListReward({
							v.createSwordReward("Dual Stellar Blade"),
							v.createEmoteReward("Emote223")
						}),
						ProductId = 1783957166
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "StellarRevolverStartTime",
		FFlagEndTime = "StellarRevolverEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stellar Revolver",
				Image = v2.Icons:GetSwordIcon("Stellar Revolver"),
				ShowRoom = "StellarRevolverShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Stellar Revolver",
						Item = v.createListReward({
							v.createSwordReward("Stellar Revolver"),
							v.createExplosionReward("Planetary Explosion"),
							v.createEmoteReward("Emote221")
						}),
						ProductId = 1783957624
					},
					{
						GiftName = "Dual Stellar Revolver",
						Item = v.createListReward({
							v.createSwordReward("Dual Stellar Revolver"),
							v.createExplosionReward("Triple Planetary Explosion"),
							v.createEmoteReward("Emote222")
						}),
						ProductId = 1783958176
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "StellarPackStartTime",
		FFlagEndTime = "StellarPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stellar Pack",
				Image = "rbxassetid://16838922387",
				ShowRoom = "StellarPackShowRoom",
				Rewards = {
					{
						GiftName = "Stellar Pack",
						Item = v.createListReward({
							v.createSwordReward("Stellar Blade"),
							v.createSwordReward("Stellar Revolver"),
							v.createExplosionReward("Planetary Explosion"),
							v.createEmoteReward("Emote221")
						}),
						ProductId = 1783958797,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Stellar Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Stellar Blade"),
							v.createSwordReward("Dual Stellar Revolver"),
							v.createExplosionReward("Triple Planetary Explosion"),
							v.createEmoteReward("Emote222"),
							v.createEmoteReward("Emote223")
						}),
						ProductId = 1783959359,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}