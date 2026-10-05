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
		RootFFlagStartTime = "FinalPhasePackRootStartTime",
		RootFFlagEndTime = "FinalPhasePackRootEndTime",
		FFlagStartTime = "FinalPhaseBladeStartTime",
		FFlagEndTime = "FinalPhaseBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Final Phase",
				Image = v2.Icons:GetSwordIcon("Final Phase"),
				ShowRoom = "FinalPhaseShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Final Phase",
						GiftId = 3291655583,
						Item = v.createListReward({ v.createSwordReward("Final Phase") }),
						ProductId = 3291655576
					},
					{
						GiftName = "Dual Final Phase",
						GiftId = 3291655580,
						Item = v.createListReward({
							v.createSwordReward("Dual Final Phase"),
							v.createExplosionReward("Reaper Shard"),
							v.createEmoteReward("Emote917")
						}),
						ProductId = 3291655578
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FinalPhasePackRootStartTime",
		RootFFlagEndTime = "FinalPhasePackRootEndTime",
		FFlagStartTime = "FinalPhaseBowStartTime",
		FFlagEndTime = "FinalPhaseBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Oblivion Pike",
				Image = v2.Icons:GetSwordIcon("Oblivion Pike"),
				ShowRoom = "OblivionPikeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Oblivion Pike",
						GiftId = 3291655581,
						Item = v.createListReward({
							v.createSwordReward("Oblivion Pike"),
							v.createExplosionReward("Oblivion Strike"),
							v.createEmoteReward("Emote916")
						}),
						ProductId = 3291655584
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FinalPhasePackRootStartTime",
		RootFFlagEndTime = "FinalPhasePackRootEndTime",
		FFlagStartTime = "FinalPhasePackStartTime",
		FFlagEndTime = "FinalPhasePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Final Phase Pack",
				Image = "rbxassetid://87313185778611",
				ShowRoom = "FinalPhasePackShowRoom",
				Rewards = {
					{
						GiftName = "Final Phase Pack",
						GiftId = 3291655587,
						Item = v.createListReward({
							v.createSwordReward("Final Phase"),
							v.createSwordReward("Oblivion Pike"),
							v.createExplosionReward("Reaper Shard"),
							v.createEmoteReward("Emote916")
						}),
						ProductId = 3291655582,
						DiscountedFrom = 2399
					},
					{
						GiftName = "Dual Final Phase Pack",
						GiftId = 3291655579,
						Item = v.createListReward({
							v.createSwordReward("Dual Final Phase"),
							v.createSwordReward("Oblivion Pike"),
							v.createExplosionReward("Oblivion Strike"),
							v.createEmoteReward("Emote916"),
							v.createEmoteReward("Emote917")
						}),
						ProductId = 3291655585,
						DiscountedFrom = 2799
					}
				}
			}
		}
	}
}