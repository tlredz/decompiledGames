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
		RootFFlagStartTime = "PeachbornePackRootStartTime",
		RootFFlagEndTime = "PeachbornePackRootEndTime",
		FFlagStartTime = "PeachborneBladeStartTime",
		FFlagEndTime = "PeachborneBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Peachborne Blade",
				Image = v2.Icons:GetSwordIcon("Dual Peachborne Blade"),
				ShowRoom = "PeachborneBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Peachborne Blade",
						GiftId = 3473122139,
						Item = v.createListReward({ v.createSwordReward("Peachborne Blade") }),
						ProductId = 3473122137
					},
					{
						GiftName = "Dual Peachborne Blade",
						GiftId = 3473122142,
						Item = v.createListReward({
							v.createSwordReward("Dual Peachborne Blade"),
							v.createExplosionReward("Shattered Peach"),
							v.createEmoteReward("Emote1092")
						}),
						ProductId = 3473122138
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PeachbornePackRootStartTime",
		RootFFlagEndTime = "PeachbornePackRootEndTime",
		FFlagStartTime = "PeachborneFanStartTime",
		FFlagEndTime = "PeachborneFanEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Peachborne Fan",
				Image = v2.Icons:GetSwordIcon("Dual Peachborne Fan"),
				ShowRoom = "PeachborneFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Peachborne Fan",
						GiftId = 3473122148,
						Item = v.createListReward({
							v.createSwordReward("Peachborne Fan"),
							v.createExplosionReward("Crystalized Peach"),
							v.createEmoteReward("Emote1093")
						}),
						ProductId = 3473122145
					},
					{
						GiftName = "Dual Peachborne Fan",
						GiftId = 3473122141,
						Item = v.createListReward({
							v.createSwordReward("Dual Peachborne Fan"),
							v.createExplosionReward("Crystalized Peach"),
							v.createEmoteReward("Emote1094")
						}),
						ProductId = 3473122146
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "PeachbornePackRootStartTime",
		RootFFlagEndTime = "PeachbornePackRootEndTime",
		FFlagStartTime = "PeachbornePackStartTime",
		FFlagEndTime = "PeachbornePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Peachborne Pack",
				Image = "rbxassetid://108403542516388",
				ShowRoom = "PeachbornePackShowRoom",
				Rewards = {
					{
						GiftName = "Peachborne Pack",
						GiftId = 3473122140,
						Item = v.createListReward({
							v.createSwordReward("Peachborne Blade"),
							v.createSwordReward("Peachborne Fan"),
							v.createExplosionReward("Shattered Peach"),
							v.createEmoteReward("Emote1093")
						}),
						ProductId = 3473122143,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Peachborne Pack",
						GiftId = 3473123076,
						Item = v.createListReward({
							v.createSwordReward("Dual Peachborne Blade"),
							v.createSwordReward("Dual Peachborne Fan"),
							v.createExplosionReward("Crystalized Peach"),
							v.createEmoteReward("Emote1092"),
							v.createEmoteReward("Emote1094")
						}),
						ProductId = 3473122147,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}