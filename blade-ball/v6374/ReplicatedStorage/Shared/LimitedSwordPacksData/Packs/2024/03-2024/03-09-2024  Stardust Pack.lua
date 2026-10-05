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
		FFlagStartTime = "StardustKatanaStartTime",
		FFlagEndTime = "StardustKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stardust Katana",
				Image = v2.Icons:GetSwordIcon("Dual Stardust Katana"),
				ShowRoom = "StardustKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Stardust Katana",
						Item = v.createListReward({ v.createSwordReward("Stardust Katana") }),
						ProductId = 1771868888
					},
					{
						GiftName = "Dual Stardust Katana",
						Item = v.createListReward({
							v.createSwordReward("Dual Stardust Katana"),
							v.createExplosionReward("Stardust Beam"),
							v.createEmoteReward("Emote182")
						}),
						ProductId = 1771871780
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "StardustBowStartTime",
		FFlagEndTime = "StardustBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stardust Bow",
				Image = v2.Icons:GetSwordIcon("Stardust Bow"),
				ShowRoom = "StardustBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Stardust Bow",
						Item = v.createListReward({
							v.createSwordReward("Stardust Bow"),
							v.createExplosionReward("Stardust Beam"),
							v.createEmoteReward("Emote178")
						}),
						ProductId = 1771873495
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "StardustPackStartTime",
		FFlagEndTime = "StardustPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stardust Pack",
				Image = "rbxassetid://16686412739",
				ShowRoom = "StardustPackShowRoom",
				Rewards = {
					{
						GiftName = "Stardust Pack",
						Item = v.createListReward({
							v.createSwordReward("Stardust Katana"),
							v.createSwordReward("Stardust Bow"),
							v.createExplosionReward("Stardust Beam"),
							v.createEmoteReward("Emote178")
						}),
						ProductId = 1771874689,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Stardust Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Stardust Katana"),
							v.createSwordReward("Stardust Bow"),
							v.createExplosionReward("Stardust Beam"),
							v.createEmoteReward("Emote178"),
							v.createEmoteReward("Emote182")
						}),
						ProductId = 1771875015,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}