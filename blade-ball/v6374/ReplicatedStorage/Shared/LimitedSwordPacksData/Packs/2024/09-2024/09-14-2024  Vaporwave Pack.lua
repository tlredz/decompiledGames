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
		RootFFlagStartTime = "VaporwavePackRootStartTime",
		RootFFlagEndTime = "VaporwavePackRootEndTime",
		FFlagStartTime = "VaporwaveSwordStartTime",
		FFlagEndTime = "VaporwaveSwordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vaporwave Blade",
				Image = v2.Icons:GetSwordIcon("Dual Vaporwave Blade"),
				ShowRoom = "VaporwaveBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Vaporwave Blade",
						GiftId = 1932763829,
						Item = v.createListReward({ v.createSwordReward("Vaporwave Blade") }),
						ProductId = 1932763824
					},
					{
						GiftName = "Dual Vaporwave Blade",
						GiftId = 1932763833,
						Item = v.createListReward({
							v.createSwordReward("Dual Vaporwave Blade"),
							v.createExplosionReward("Retro Wave"),
							v.createEmoteReward("Emote529")
						}),
						ProductId = 1932763832
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VaporwavePackRootStartTime",
		RootFFlagEndTime = "VaporwavePackRootEndTime",
		FFlagStartTime = "VaporwaveCrusherStartTime",
		FFlagEndTime = "VaporwaveCrusherEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vaporwave Crusher",
				Image = v2.Icons:GetSwordIcon("Dual Vaporwave Crusher"),
				ShowRoom = "VaporwaveCrusherShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Vaporwave Crusher",
						GiftId = 1932763823,
						Item = v.createListReward({
							v.createSwordReward("Vaporwave Crusher"),
							v.createExplosionReward("Pastel Vaporwave"),
							v.createEmoteReward("Emote530")
						}),
						ProductId = 1932763828
					},
					{
						GiftName = "Dual Vaporwave Crusher",
						GiftId = 1932763835,
						Item = v.createListReward({
							v.createSwordReward("Dual Vaporwave Crusher"),
							v.createExplosionReward("Pastel Vaporwave"),
							v.createEmoteReward("Emote531")
						}),
						ProductId = 1932763831
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "VaporwavePackRootStartTime",
		RootFFlagEndTime = "VaporwavePackRootEndTime",
		FFlagStartTime = "VaporwavePackStartTime",
		FFlagEndTime = "VaporwavePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Vaporwave Pack",
				Image = "rbxassetid://113705097489519",
				ShowRoom = "VaporwavePackShowRoom",
				Rewards = {
					{
						GiftName = "Vaporwave Pack",
						GiftId = 1932763827,
						Item = v.createListReward({
							v.createSwordReward("Vaporwave Blade"),
							v.createSwordReward("Vaporwave Crusher"),
							v.createExplosionReward("Retro Wave"),
							v.createEmoteReward("Emote530")
						}),
						ProductId = 1932763825,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Vaporwave Pack",
						GiftId = 1932763834,
						Item = v.createListReward({
							v.createSwordReward("Dual Vaporwave Blade"),
							v.createSwordReward("Dual Vaporwave Crusher"),
							v.createExplosionReward("Pastel Vaporwave"),
							v.createEmoteReward("Emote529"),
							v.createEmoteReward("Emote531")
						}),
						ProductId = 1932763830,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}