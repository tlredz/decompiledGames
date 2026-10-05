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
		RootFFlagStartTime = "BloomveilPackRootStartTime",
		RootFFlagEndTime = "BloomveilPackRootEndTime",
		FFlagStartTime = "BloomveilKunaiStartTime",
		FFlagEndTime = "BloomveilKunaiEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloomveil Kunai",
				Image = v2.Icons:GetSwordIcon("Dual Bloomveil Kunai"),
				ShowRoom = "BloomveilKunaiShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloomveil Kunai",
						GiftId = 3421995832,
						Item = v.createListReward({ v.createSwordReward("Bloomveil Kunai") }),
						ProductId = 3421995826
					},
					{
						GiftName = "Dual Bloomveil Kunai",
						GiftId = 3421995833,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloomveil Kunai"),
							v.createExplosionReward("Bloomveil Burst"),
							v.createEmoteReward("Emote1053")
						}),
						ProductId = 3421995828
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloomveilPackRootStartTime",
		RootFFlagEndTime = "BloomveilPackRootEndTime",
		FFlagStartTime = "BloomveilLanceStartTime",
		FFlagEndTime = "BloomveilLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloomveil Lance",
				Image = v2.Icons:GetSwordIcon("Bloomveil Lance"),
				ShowRoom = "BloomveilLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Bloomveil Lance",
						GiftId = 3421995836,
						Item = v.createListReward({
							v.createSwordReward("Bloomveil Lance"),
							v.createExplosionReward("Blossoming Oath"),
							v.createEmoteReward("Emote1054")
						}),
						ProductId = 3421995831
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BloomveilPackRootStartTime",
		RootFFlagEndTime = "BloomveilPackRootEndTime",
		FFlagStartTime = "BloomveilPackStartTime",
		FFlagEndTime = "BloomveilPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bloomveil Pack",
				Image = "rbxassetid://84671715496681",
				ShowRoom = "BloomveilPackShowRoom",
				Rewards = {
					{
						GiftName = "Bloomveil Pack",
						GiftId = 3421995835,
						Item = v.createListReward({
							v.createSwordReward("Bloomveil Kunai"),
							v.createSwordReward("Bloomveil Lance"),
							v.createExplosionReward("Bloomveil Burst"),
							v.createEmoteReward("Emote1054")
						}),
						ProductId = 3421995830,
						DiscountedFrom = 2999
					},
					{
						GiftName = "Dual Bloomveil Pack",
						GiftId = 3421995829,
						Item = v.createListReward({
							v.createSwordReward("Dual Bloomveil Kunai"),
							v.createSwordReward("Bloomveil Lance"),
							v.createExplosionReward("Blossoming Oath"),
							v.createEmoteReward("Emote1054"),
							v.createEmoteReward("Emote1053")
						}),
						ProductId = 3421995834,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}