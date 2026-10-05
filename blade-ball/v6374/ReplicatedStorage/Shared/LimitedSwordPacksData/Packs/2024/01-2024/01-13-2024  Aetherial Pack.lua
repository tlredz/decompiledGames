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
		FFlagStartTime = "AetherialPackStartTime",
		FFlagEndTime = "AetherialPackEndTime",
		Rewards = {
			{
				Type = "Sword",
				Name = "Aetherial Azure Reckoner",
				Image = v2.Icons:GetSwordIcon("Dual Aetherial Azure Reckoner"),
				ShowRoom = "AetherialAzureReckonerShowRoom",
				Rewards = {
					{
						GiftName = "Aetherial Azure Reckoner",
						Item = v.createSwordReward("Aetherial Azure Reckoner"),
						ProductId = 1730792771
					},
					{
						GiftName = "Dual Aetherial Azure Reckoner",
						Item = v.createSwordReward("Dual Aetherial Azure Reckoner"),
						ProductId = 1730794997
					}
				}
			},
			{
				Type = "Sword",
				Name = "Aetherial Azure Katana",
				Image = v2.Icons:GetSwordIcon("Dual Aetherial Azure Katana"),
				ShowRoom = "AetherialAzureKatanaShowRoom",
				Rewards = {
					{
						GiftName = "Aetherial Azure Katana",
						Item = v.createSwordReward("Aetherial Azure Katana"),
						ProductId = 1730796049
					},
					{
						GiftName = "Dual Aetherial Azure Katana",
						Item = v.createSwordReward("Dual Aetherial Azure Katana"),
						ProductId = 1730797207
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Aetherial Azure Pack",
				Image = "rbxassetid://15963974672",
				ShowRoom = "AetherialAzurePackShowRoom",
				Rewards = {
					{
						GiftName = "Aetherial Azure Pack",
						Item = v.createListReward({
							v.createSwordReward("Aetherial Azure Reckoner"),
							v.createSwordReward("Aetherial Azure Katana"),
							v.createExplosionReward("Aetherial Explosion"),
							v.createEmoteReward("Emote103")
						}),
						ProductId = 1730797881,
						DiscountedFrom = 1499
					},
					{
						GiftName = "Dual Aetherial Azure Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Aetherial Azure Reckoner"),
							v.createSwordReward("Dual Aetherial Azure Katana"),
							v.createExplosionReward("Aetherial Explosion"),
							v.createEmoteReward("Emote104")
						}),
						ProductId = 1730799336,
						DiscountedFrom = 2899
					}
				}
			}
		}
	}
}