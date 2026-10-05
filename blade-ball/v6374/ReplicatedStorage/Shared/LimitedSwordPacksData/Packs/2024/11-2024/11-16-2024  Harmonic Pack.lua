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
		RootFFlagStartTime = "HarmonicPackRootStartTime",
		RootFFlagEndTime = "HarmonicPackRootEndTime",
		FFlagStartTime = "HarmonicBladeStartTime",
		FFlagEndTime = "HarmonicBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Harmonic Staff",
				Image = v2.Icons:GetSwordIcon("Dual Harmonic Set"),
				ShowRoom = "HarmonicSetShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Harmonic Staff",
						GiftId = 2658591371,
						Item = v.createListReward({ v.createSwordReward("Harmonic Staff") }),
						ProductId = 2658591366
					},
					{
						GiftName = "Dual Harmonic Set",
						GiftId = 2658591365,
						Item = v.createListReward({
							v.createSwordReward("Dual Harmonic Set"),
							v.createExplosionReward("Harmonic Echo"),
							v.createEmoteReward("Emote630")
						}),
						ProductId = 2658591367
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HarmonicPackRootStartTime",
		RootFFlagEndTime = "HarmonicPackRootEndTime",
		FFlagStartTime = "HarmonicFanStartTime",
		FFlagEndTime = "HarmonicFanEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Harmonic Fan",
				Image = v2.Icons:GetSwordIcon("Harmonic Fan"),
				ShowRoom = "HarmonicFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Harmonic Fan",
						GiftId = 2658591363,
						Item = v.createListReward({
							v.createSwordReward("Harmonic Fan"),
							v.createExplosionReward("Harmonic Surge"),
							v.createEmoteReward("Emote631")
						}),
						ProductId = 2658591372
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HarmonicPackRootStartTime",
		RootFFlagEndTime = "HarmonicPackRootEndTime",
		FFlagStartTime = "HarmonicPackStartTime",
		FFlagEndTime = "HarmonicPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Harmonic Pack",
				Image = "rbxassetid://112740270635238",
				ShowRoom = "HarmonicPackShowRoom",
				Rewards = {
					{
						GiftName = "Harmonic Pack",
						GiftId = 2658591368,
						Item = v.createListReward({
							v.createSwordReward("Harmonic Staff"),
							v.createSwordReward("Harmonic Fan"),
							v.createExplosionReward("Harmonic Echo"),
							v.createEmoteReward("Emote631")
						}),
						ProductId = 2658591369,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Harmonic Pack",
						GiftId = 2658591370,
						Item = v.createListReward({
							v.createSwordReward("Dual Harmonic Set"),
							v.createSwordReward("Harmonic Fan"),
							v.createExplosionReward("Harmonic Surge"),
							v.createEmoteReward("Emote630"),
							v.createEmoteReward("Emote631")
						}),
						ProductId = 2658591364,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}