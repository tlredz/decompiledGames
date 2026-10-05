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
		FFlagStartTime = "DemonicBladeStartTime",
		FFlagEndTime = "DemonicBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Demonic Blade",
				Image = v2.Icons:GetSwordIcon("Demonic Blade"),
				ShowRoom = "DemonicBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Demonic Blade",
						Item = v.createListReward({ v.createSwordReward("Demonic Blade") }),
						ProductId = 1798013698
					},
					{
						GiftName = "Dual Demonic Blade",
						Item = v.createListReward({
							v.createSwordReward("Dual Demonic Blade"),
							v.createEmoteReward("Emote250"),
							v.createExplosionReward("Demonic Chain")
						}),
						ProductId = 1798015057
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DemonicScytheStartTime",
		FFlagEndTime = "DemonicScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Demonic Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Demonic Scythe"),
				ShowRoom = "DemonicScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Demonic Scythe",
						Item = v.createListReward({
							v.createSwordReward("Demonic Scythe"),
							v.createExplosionReward("Summon Blast"),
							v.createEmoteReward("Emote252")
						}),
						ProductId = 1798015987
					},
					{
						GiftName = "Dual Demonic Scythe",
						Item = v.createListReward({
							v.createSwordReward("Dual Demonic Scythe"),
							v.createExplosionReward("Summon Blast"),
							v.createEmoteReward("Emote251")
						}),
						ProductId = 1798017304
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "DemonicPackStartTime",
		FFlagEndTime = "DemonicPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Demonic Pack",
				Image = "rbxassetid://17027094022",
				ShowRoom = "DemonicPackShowRoom",
				Rewards = {
					{
						GiftName = "Demonic Pack",
						Item = v.createListReward({
							v.createSwordReward("Demonic Blade"),
							v.createSwordReward("Demonic Scythe"),
							v.createExplosionReward("Demonic Chain"),
							v.createEmoteReward("Emote252")
						}),
						ProductId = 1798018988,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Demonic Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Demonic Blade"),
							v.createSwordReward("Dual Demonic Scythe"),
							v.createExplosionReward("Summon Blast"),
							v.createEmoteReward("Emote251"),
							v.createEmoteReward("Emote250")
						}),
						ProductId = 1798020133,
						DiscountedFrom = 5000
					}
				}
			}
		}
	}
}