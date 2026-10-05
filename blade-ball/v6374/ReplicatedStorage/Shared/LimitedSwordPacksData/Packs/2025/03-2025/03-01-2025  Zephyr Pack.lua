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
		RootFFlagStartTime = "ZephyrPackRootStartTime",
		RootFFlagEndTime = "ZephyrPackRootEndTime",
		FFlagStartTime = "ZephyrBladeStartTime",
		FFlagEndTime = "ZephyrBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zephyr Blade",
				Image = v2.Icons:GetSwordIcon("Dual Zephyr Blade"),
				ShowRoom = "ZephyrBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Zephyr Blade",
						GiftId = 3228372135,
						Item = v.createListReward({ v.createSwordReward("Zephyr Blade") }),
						ProductId = 3228372136
					},
					{
						GiftName = "Dual Zephyr Blade",
						GiftId = 3228372142,
						Item = v.createListReward({
							v.createSwordReward("Dual Zephyr Blade"),
							v.createExplosionReward("Zephyr Ripple"),
							v.createEmoteReward("Emote807")
						}),
						ProductId = 3228372138
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ZephyrPackRootStartTime",
		RootFFlagEndTime = "ZephyrPackRootEndTime",
		FFlagStartTime = "ZephyrScytheStartTime",
		FFlagEndTime = "ZephyrScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zephyr Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Zephyr Scythe"),
				ShowRoom = "ZephyrScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Zephyr Scythe",
						GiftId = 3228372144,
						Item = v.createListReward({
							v.createSwordReward("Zephyr Scythe"),
							v.createExplosionReward("Zephyr Sky"),
							v.createEmoteReward("Emote808")
						}),
						ProductId = 3228372141
					},
					{
						GiftName = "Dual Zephyr Scythe",
						GiftId = 3228372146,
						Item = v.createListReward({
							v.createSwordReward("Dual Zephyr Scythe"),
							v.createExplosionReward("Zephyr Sky"),
							v.createEmoteReward("Emote809")
						}),
						ProductId = 3228372140
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ZephyrPackRootStartTime",
		RootFFlagEndTime = "ZephyrPackRootEndTime",
		FFlagStartTime = "ZephyrPackStartTime",
		FFlagEndTime = "ZephyrPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Zephyr Pack",
				Image = "rbxassetid://84296955339653",
				ShowRoom = "ZephyrPackShowRoom",
				Rewards = {
					{
						GiftName = "Zephyr Pack",
						GiftId = 3228372137,
						Item = v.createListReward({
							v.createSwordReward("Zephyr Blade"),
							v.createSwordReward("Zephyr Scythe"),
							v.createExplosionReward("Zephyr Ripple"),
							v.createEmoteReward("Emote808")
						}),
						ProductId = 3228372139,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Zephyr Pack",
						GiftId = 3228372143,
						Item = v.createListReward({
							v.createSwordReward("Dual Zephyr Blade"),
							v.createSwordReward("Dual Zephyr Scythe"),
							v.createExplosionReward("Zephyr Sky"),
							v.createEmoteReward("Emote807"),
							v.createEmoteReward("Emote809")
						}),
						ProductId = 3228372145,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}