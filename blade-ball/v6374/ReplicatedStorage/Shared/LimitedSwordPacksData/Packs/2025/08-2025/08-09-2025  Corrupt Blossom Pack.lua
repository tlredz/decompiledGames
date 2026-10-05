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
		RootFFlagStartTime = "CorruptBlossomPackRootStartTime",
		RootFFlagEndTime = "CorruptBlossomPackRootEndTime",
		FFlagStartTime = "CorruptBlossomBladeStartTime",
		FFlagEndTime = "CorruptBlossomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupt Blossom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Corrupt Blossom Blade"),
				ShowRoom = "CorruptBlossomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Corrupt Blossom Blade",
						GiftId = 3364245900,
						Item = v.createListReward({ v.createSwordReward("Corrupt Blossom Blade") }),
						ProductId = 3364245899
					},
					{
						GiftName = "Dual Corrupt Blossom Blade",
						GiftId = 3364245908,
						Item = v.createListReward({
							v.createSwordReward("Dual Corrupt Blossom Blade"),
							v.createExplosionReward("Corrupt Season"),
							v.createEmoteReward("Emote1008")
						}),
						ProductId = 3364245901
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CorruptBlossomPackRootStartTime",
		RootFFlagEndTime = "CorruptBlossomPackRootEndTime",
		FFlagStartTime = "CorruptBlossomBowStartTime",
		FFlagEndTime = "CorruptBlossomBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupt Blossom Bow",
				Image = v2.Icons:GetSwordIcon("Corrupt Blossom Bow"),
				ShowRoom = "CorruptBlossomBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Corrupt Blossom Bow",
						GiftId = 3364245903,
						Item = v.createListReward({
							v.createSwordReward("Corrupt Blossom Bow"),
							v.createExplosionReward("Corrupted Garden"),
							v.createEmoteReward("Emote1009")
						}),
						ProductId = 3364245904
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CorruptBlossomPackRootStartTime",
		RootFFlagEndTime = "CorruptBlossomPackRootEndTime",
		FFlagStartTime = "CorruptBlossomPackStartTime",
		FFlagEndTime = "CorruptBlossomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupt Blossom Pack",
				Image = "rbxassetid://125036527922274",
				ShowRoom = "CorruptBlossomPackShowRoom",
				Rewards = {
					{
						GiftName = "Corrupt Blossom Pack",
						GiftId = 3364245905,
						Item = v.createListReward({
							v.createSwordReward("Corrupt Blossom Blade"),
							v.createSwordReward("Corrupt Blossom Bow"),
							v.createExplosionReward("Corrupt Season"),
							v.createEmoteReward("Emote1009")
						}),
						ProductId = 3364245907,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Corrupt Blossom Pack",
						GiftId = 3364245902,
						Item = v.createListReward({
							v.createSwordReward("Dual Corrupt Blossom Blade"),
							v.createSwordReward("Corrupt Blossom Bow"),
							v.createExplosionReward("Corrupted Garden"),
							v.createEmoteReward("Emote1009"),
							v.createEmoteReward("Emote1008")
						}),
						ProductId = 3364245909,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}