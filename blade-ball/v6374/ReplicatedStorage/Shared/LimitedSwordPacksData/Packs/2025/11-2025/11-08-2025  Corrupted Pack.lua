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
		RootFFlagStartTime = "CorruptedPackRootStartTime",
		RootFFlagEndTime = "CorruptedPackRootEndTime",
		FFlagStartTime = "CorruptedLovebladeStartTime",
		FFlagEndTime = "CorruptedLovebladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupted Loveblade",
				Image = v2.Icons:GetSwordIcon("Dual Corrupted Loveblade"),
				ShowRoom = "CorruptedLovebladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Corrupted Blade",
						GiftId = 3451309517,
						Item = v.createListReward({ v.createSwordReward("Corrupted Loveblade") }),
						ProductId = 3451309521
					},
					{
						GiftName = "Dual Corrupted Loveblade",
						GiftId = 3451309518,
						Item = v.createListReward({
							v.createSwordReward("Dual Corrupted Loveblade"),
							v.createExplosionReward("Heart Corruption"),
							v.createEmoteReward("Emote1079")
						}),
						ProductId = 3451309519
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CorruptedPackRootStartTime",
		RootFFlagEndTime = "CorruptedPackRootEndTime",
		FFlagStartTime = "CorruptedFanStartTime",
		FFlagEndTime = "CorruptedFanEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupted Fan",
				Image = v2.Icons:GetSwordIcon("Dual Corrupted Fan"),
				ShowRoom = "CorruptedFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Corrupted Fan",
						GiftId = 3451309528,
						Item = v.createListReward({
							v.createSwordReward("Corrupted Fan"),
							v.createExplosionReward("Heart Awakening"),
							v.createEmoteReward("Emote1080")
						}),
						ProductId = 3451309525
					},
					{
						GiftName = "Dual Corrupted Fan",
						GiftId = 3451309522,
						Item = v.createListReward({
							v.createSwordReward("Dual Corrupted Fan"),
							v.createExplosionReward("Heart Awakening"),
							v.createEmoteReward("Emote1081")
						}),
						ProductId = 3451309534
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CorruptedPackRootStartTime",
		RootFFlagEndTime = "CorruptedPackRootEndTime",
		FFlagStartTime = "CorruptedPackStartTime",
		FFlagEndTime = "CorruptedPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Corrupted Pack",
				Image = "rbxassetid://115510326051572",
				ShowRoom = "CorruptedPackShowRoom",
				Rewards = {
					{
						GiftName = "Corrupted Pack",
						GiftId = 3451309524,
						Item = v.createListReward({
							v.createSwordReward("Corrupted Loveblade"),
							v.createSwordReward("Corrupted Fan"),
							v.createExplosionReward("Heart Corruption"),
							v.createEmoteReward("Emote1080")
						}),
						ProductId = 3451309527,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Corrupted Pack",
						GiftId = 3451309523,
						Item = v.createListReward({
							v.createSwordReward("Dual Corrupted Loveblade"),
							v.createSwordReward("Dual Corrupted Fan"),
							v.createExplosionReward("Heart Awakening"),
							v.createEmoteReward("Emote1079"),
							v.createEmoteReward("Emote1081")
						}),
						ProductId = 3451309526,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}