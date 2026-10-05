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
		FFlagStartTime = "VoltfireLashStartTime",
		FFlagEndTime = "VoltfireLashEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Voltfire Lash",
				Image = v2.Icons:GetSwordIcon("Dual Voltfire Lash"),
				ShowRoom = "VoltfireLashShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Voltfire Lash",
						Item = v.createListReward({
							v.createSwordReward("Voltfire Lash"),
							v.createEmoteReward("Emote124")
						}),
						ProductId = 1746026449
					},
					{
						GiftName = "Dual Voltfire Lash",
						Item = v.createListReward({
							v.createSwordReward("Dual Voltfire Lash"),
							v.createEmoteReward("Emote125")
						}),
						ProductId = 1746026714
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "VoltfireBladeStartTime",
		FFlagEndTime = "VoltfireBladeEndTime",
		Rewards = {
			{
				Type = "Sword",
				Name = "Voltfire Blade",
				Image = v2.Icons:GetSwordIcon("Dual Voltfire Blade"),
				ShowRoom = "VoltfireBladeShowRoom",
				Rewards = {
					{
						GiftName = "Voltfire Blade",
						Item = v.createSwordReward("Voltfire Blade"),
						ProductId = 1746027052
					},
					{
						GiftName = "Dual Voltfire Blade",
						Item = v.createSwordReward("Dual Voltfire Blade"),
						ProductId = 1746028043
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "VoltfirePackStartTime",
		FFlagEndTime = "VoltfirePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Voltfire Pack",
				Image = "rbxassetid://16223384536",
				ShowRoom = "VoltfirePackShowRoom",
				Rewards = {
					{
						GiftName = "Voltfire Pack",
						Item = v.createListReward({
							v.createSwordReward("Voltfire Lash"),
							v.createSwordReward("Voltfire Blade"),
							v.createExplosionReward("Voltfire Explosion"),
							v.createEmoteReward("Emote124")
						}),
						ProductId = 1746028867,
						DiscountedFrom = 1500
					},
					{
						GiftName = "Dual Voltfire Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Voltfire Lash"),
							v.createSwordReward("Dual Voltfire Blade"),
							v.createExplosionReward("Voltfire Explosion"),
							v.createEmoteReward("Emote125")
						}),
						ProductId = 1746029192,
						DiscountedFrom = 5000
					}
				}
			}
		}
	}
}