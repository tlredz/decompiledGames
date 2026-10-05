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
		FFlagStartTime = "ShadowDaggersStartTime",
		FFlagEndTime = "ShadowDaggersEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Dagger",
				Image = v2.Icons:GetSwordIcon("Dual Shadow Daggers"),
				ShowRoom = "ShadowDaggersShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Shadow Dagger",
						Item = v.createListReward({ v.createSwordReward("Shadow Dagger") }),
						ProductId = 1756569843
					},
					{
						GiftName = "Dual Shadow Daggers",
						Item = v.createListReward({
							v.createSwordReward("Dual Shadow Daggers"),
							v.createExplosionReward("Shadow Vortex")
						}),
						ProductId = 1756570467
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "ShadowMirageStartTime",
		FFlagEndTime = "ShadowMirageEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Mirage",
				Image = v2.Icons:GetSwordIcon("Dual Shadow Mirage"),
				ShowRoom = "ShadowMirageShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Shadow Mirage",
						Item = v.createListReward({
							v.createSwordReward("Shadow Mirage"),
							v.createEmoteReward("Emote152"),
							v.createExplosionReward("Shadow Vortex")
						}),
						ProductId = 1756571918
					},
					{
						GiftName = "Dual Shadow Mirage",
						Item = v.createListReward({
							v.createSwordReward("Dual Shadow Mirage"),
							v.createEmoteReward("Emote153"),
							v.createExplosionReward("Shadow Vortex")
						}),
						ProductId = 1756572211
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "ShadowPackStartTime",
		FFlagEndTime = "ShadowPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shadow Pack",
				Image = "rbxassetid://16402393722",
				ShowRoom = "ShadowPackShowRoom",
				Rewards = {
					{
						GiftName = "Shadow Pack",
						Item = v.createListReward({
							v.createSwordReward("Shadow Mirage"),
							v.createSwordReward("Shadow Dagger"),
							v.createEmoteReward("Emote152"),
							v.createExplosionReward("Shadow Vortex")
						}),
						ProductId = 1756572907,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Shadow Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Shadow Mirage"),
							v.createSwordReward("Dual Shadow Daggers"),
							v.createEmoteReward("Emote153"),
							v.createExplosionReward("Shadow Vortex")
						}),
						ProductId = 1756573251,
						DiscountedFrom = 3500
					}
				}
			}
		}
	}
}