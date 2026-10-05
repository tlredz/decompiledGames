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
		FFlagStartTime = "PrismaticPackStartTime",
		FFlagEndTime = "PrismaticPackEndTime",
		Rewards = {
			{
				Type = "Sword",
				Name = "Prismatic Harvester",
				Image = v2.Icons:GetSwordIcon("Double Sided Prismatic"),
				ShowRoom = "PrismaticShowRoom",
				Rewards = {
					{
						GiftName = "Prismatic Harvester",
						Item = v.createSwordReward("Prismatic Harvester"),
						ProductId = 1724910010
					},
					{
						GiftName = "Double Sided Prismatic",
						Item = v.createSwordReward("Double Sided Prismatic"),
						ProductId = 1724910135
					}
				}
			},
			{
				Type = "Sword",
				Name = "Prismatic Katana",
				Image = v2.Icons:GetSwordIcon("Dual Prismatic Katana"),
				ShowRoom = "PrismaticKatanaShowRoom",
				Rewards = {
					{
						GiftName = "Prismatic Katana",
						Item = v.createSwordReward("Prismatic Katana"),
						ProductId = 1726009543
					},
					{
						GiftName = "Dual Prismatic Katana",
						Item = v.createSwordReward("Dual Prismatic Katana"),
						ProductId = 1726010627
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Prismatic Pack",
				Image = "rbxassetid://15890452696",
				ShowRoom = "PrismaticPackShowRoom",
				Rewards = {
					{
						GiftName = "Prismatic Pack",
						Item = v.createListReward({
							v.createSwordReward("Prismatic Harvester"),
							v.createSwordReward("Prismatic Katana"),
							v.createExplosionReward("Prismatic Explosion"),
							v.createEmoteReward("Emote78")
						}),
						ProductId = 1724912908,
						DiscountedFrom = 1299
					},
					{
						GiftName = "Double Sided Prismatic Pack",
						Item = v.createListReward({
							v.createSwordReward("Double Sided Prismatic"),
							v.createSwordReward("Dual Prismatic Katana"),
							v.createExplosionReward("Prismatic Explosion"),
							v.createEmoteReward("Emote79")
						}),
						ProductId = 1724913777,
						DiscountedFrom = 2599
					}
				}
			}
		}
	}
}