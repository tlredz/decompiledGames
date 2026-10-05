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
		FFlagStartTime = "NebulaKatanaPackStartTime",
		FFlagEndTime = "NebulaKatanaPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nebula Katana",
				Image = v2.Icons:GetSwordIcon("Dual Nebula Katana"),
				ShowRoom = "NebulaKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nebula Katana",
						Item = v.createListReward({ v.createSwordReward("Nebula Katana") }),
						ProductId = 1741791528
					},
					{
						GiftName = "Dual Nebula Katana + Dark Matter Explosion",
						Item = v.createListReward({
							v.createSwordReward("Dual Nebula Katana"),
							v.createExplosionReward("Dark Matter Explosion")
						}),
						ProductId = 1741792530,
						DiscountedFrom = 1599
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "NightfallPackStartTime",
		FFlagEndTime = "NightfallPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nightfall Violin",
				Image = v2.Icons:GetSwordIcon("Nightfall Violin"),
				ShowRoom = "NightfallViolinShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nightfall Violin",
						Item = v.createListReward({
							v.createSwordReward("Nightfall Violin"),
							v.createEmoteReward("Emote122")
						}),
						ProductId = 1741879185
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Nightfall Violin Pack",
				Image = "rbxassetid://16137600993",
				ShowRoom = "NightfallShowRoom",
				Rewards = {
					{
						GiftName = "Nightfall Violin Pack",
						Item = v.createListReward({
							v.createSwordReward("Nightfall Violin"),
							v.createSwordReward("Dual Nebula Katana"),
							v.createExplosionReward("Violin Explosion"),
							v.createEmoteReward("Emote122")
						}),
						ProductId = 1741793017,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}