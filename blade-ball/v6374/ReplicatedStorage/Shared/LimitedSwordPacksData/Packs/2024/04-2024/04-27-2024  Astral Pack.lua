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
		FFlagStartTime = "AstralSwordStartTime",
		RootFFlagStartTime = "AstralPackStartTime",
		FFlagEndTime = "AstralSwordEndTime",
		RootFFlagEndTime = "AstralPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astral Sword",
				Image = v2.Icons:GetSwordIcon("Dual Astral Swords"),
				ShowRoom = "AstralSwordShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Astral Sword",
						Item = v.createListReward({ v.createSwordReward("Astral Sword") }),
						ProductId = 1817055846
					},
					{
						GiftName = "Dual Astral Swords",
						Item = v.createListReward({
							v.createSwordReward("Dual Astral Swords"),
							v.createEmoteReward("Emote296"),
							v.createExplosionReward("Astral Sky")
						}),
						ProductId = 1817058116
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "AstralBowStartTime",
		RootFFlagStartTime = "AstralPackStartTime",
		FFlagEndTime = "AstralBowEndTime",
		RootFFlagEndTime = "AstralPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astral Bow",
				Image = v2.Icons:GetSwordIcon("Astral Bow"),
				ShowRoom = "AstralBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Astral Bow",
						Item = v.createListReward({
							v.createSwordReward("Astral Bow"),
							v.createEmoteReward("Emote297"),
							v.createExplosionReward("Astral Moon")
						}),
						ProductId = 1817059206
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "AstralPackStartTime",
		RootFFlagStartTime = "AstralPackStartTime",
		FFlagEndTime = "AstralPackEndTime",
		RootFFlagEndTime = "AstralPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Astral Pack",
				Image = "rbxassetid://17299767041",
				ShowRoom = "AstralPackShowRoom",
				Rewards = {
					{
						GiftName = "Astral Pack",
						Item = v.createListReward({
							v.createSwordReward("Astral Sword"),
							v.createSwordReward("Astral Bow"),
							v.createEmoteReward("Emote297"),
							v.createExplosionReward("Astral Sky")
						}),
						ProductId = 1817059864,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Astral Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Astral Swords"),
							v.createSwordReward("Astral Bow"),
							v.createExplosionReward("Astral Moon"),
							v.createEmoteReward("Emote297"),
							v.createEmoteReward("Emote296")
						}),
						ProductId = 1817061833,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}