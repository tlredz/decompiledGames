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
		FFlagStartTime = "SwordPackStartTime",
		FFlagEndTime = "SwordPackEndTime",
		Rewards = {
			{
				Type = "Sword",
				Name = "Crimson Eclipse",
				Image = v2.Icons:GetSwordIcon("Dual Crimson Eclipse"),
				ShowRoom = "CrimsonEclipseShowRoom",
				Rewards = {
					{
						GiftName = "Crimson Eclipse",
						Item = v.createSwordReward("Crimson Eclipse"),
						ProductId = 1724909611
					},
					{
						GiftName = "Dual Crimson Eclipse",
						Item = v.createSwordReward("Dual Crimson Eclipse"),
						ProductId = 1724909731
					}
				}
			},
			{
				Type = "Sword",
				Name = "Crimson Katana",
				Image = v2.Icons:GetSwordIcon("Dual Crimson Katana"),
				ShowRoom = "CrimsonKatanaShowRoom",
				Rewards = {
					{
						GiftName = "Crimson Katana",
						Item = v.createSwordReward("Crimson Katana"),
						ProductId = 1726007128
					},
					{
						GiftName = "Dual Crimson Katana",
						Item = v.createSwordReward("Dual Crimson Katana"),
						ProductId = 1726008384
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Crimson Pack",
				Image = "rbxassetid://15887850180",
				ShowRoom = "CrimsonPackShowRoom",
				Rewards = {
					{
						GiftName = "Crimson Pack",
						Item = v.createListReward({
							v.createSwordReward("Crimson Eclipse"),
							v.createSwordReward("Crimson Katana"),
							v.createExplosionReward("Crimson Explosion"),
							v.createEmoteReward("Emote76")
						}),
						ProductId = 1724912198,
						DiscountedFrom = 1499
					},
					{
						GiftName = "Dual Crimson Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Crimson Eclipse"),
							v.createSwordReward("Dual Crimson Katana"),
							v.createExplosionReward("Crimson Explosion"),
							v.createEmoteReward("Emote77")
						}),
						ProductId = 1724912598,
						DiscountedFrom = 2899
					}
				}
			}
		}
	}
}