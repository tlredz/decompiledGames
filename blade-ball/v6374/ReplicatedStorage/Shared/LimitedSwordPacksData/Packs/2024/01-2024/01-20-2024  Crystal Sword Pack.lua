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
		FFlagStartTime = "CrystalPackStartTime",
		FFlagEndTime = "CrystalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crystal Greatblade",
				Image = v2.Icons:GetSwordIcon("Dual Crystal Greatblade"),
				ShowRoom = "CrystalGreatbladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Crystal Greatblade",
						Item = v.createListReward({
							v.createSwordReward("Crystal Greatblade"),
							v.createEmoteReward("Emote111")
						}),
						ProductId = 1736294996,
						DiscountedFrom = 499
					},
					{
						GiftName = "Dual Crystal Greatblade",
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Greatblade"),
							v.createEmoteReward("Emote112")
						}),
						ProductId = 1736295482,
						DiscountedFrom = 1299
					}
				}
			},
			{
				Type = "Sword",
				Name = "Crystal Reaperblade",
				Image = v2.Icons:GetSwordIcon("Dual Crystal Reaperblade"),
				ShowRoom = "CrystalReaperbladeShowRoom",
				Rewards = {
					{
						GiftName = "Crystal Reaperblade",
						Item = v.createSwordReward("Crystal Reaperblade"),
						ProductId = 1736756300
					},
					{
						GiftName = "Dual Crystal Reaperblade",
						Item = v.createSwordReward("Dual Crystal Reaperblade"),
						ProductId = 1736756442
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Crystal Sword Pack",
				Image = "rbxassetid://16052784475",
				ShowRoom = "CrystalPackShowRoom",
				Rewards = {
					{
						GiftName = "Crystal Sword Pack",
						Item = v.createListReward({
							v.createSwordReward("Crystal Reaperblade"),
							v.createSwordReward("Crystal Greatblade"),
							v.createExplosionReward("Crystal Explosion"),
							v.createEmoteReward("Emote113")
						}),
						ProductId = 1736758020,
						DiscountedFrom = 1499
					},
					{
						GiftName = "Dual Crystal Sword Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Crystal Reaperblade"),
							v.createSwordReward("Dual Crystal Greatblade"),
							v.createExplosionReward("Crystal Explosion"),
							v.createEmoteReward("Emote114")
						}),
						ProductId = 1736760152,
						DiscountedFrom = 2899
					}
				}
			}
		}
	}
}