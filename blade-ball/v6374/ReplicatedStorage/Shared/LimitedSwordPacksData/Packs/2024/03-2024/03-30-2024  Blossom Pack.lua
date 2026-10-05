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
		FFlagStartTime = "BlossomBladeStartTime",
		FFlagEndTime = "BlossomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blossom Blade",
				Image = v2.Icons:GetSwordIcon("Blossom Blade"),
				ShowRoom = "BlossomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Blossom Blade",
						Item = v.createListReward({ v.createSwordReward("Blossom Blade") }),
						ProductId = 1790919375
					},
					{
						GiftName = "Dual Blossom Blade",
						Item = v.createListReward({
							v.createSwordReward("Dual Blossom Blade"),
							v.createEmoteReward("Emote237"),
							v.createExplosionReward("Blossom Season")
						}),
						ProductId = 1790920148
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "BlossomScytheStartTime",
		FFlagEndTime = "BlossomScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blossom Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Blossom Scythe"),
				ShowRoom = "BlossomScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Blossom Scythe",
						Item = v.createListReward({
							v.createSwordReward("Blossom Scythe"),
							v.createExplosionReward("Cherry Blossom Tree"),
							v.createEmoteReward("Emote238")
						}),
						ProductId = 1790926672
					},
					{
						GiftName = "Dual Blossom Scythe",
						Item = v.createListReward({
							v.createSwordReward("Dual Blossom Scythe"),
							v.createExplosionReward("Cherry Blossom Tree"),
							v.createEmoteReward("Emote239")
						}),
						ProductId = 1790927312
					}
				}
			}
		}
	},
	{
		Reconcile = true,
		FFlagStartTime = "BlossomPackStartTime",
		FFlagEndTime = "BlossomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Blossom Pack",
				Image = "rbxassetid://16933826038",
				ShowRoom = "BlossomPackShowRoom",
				Rewards = {
					{
						GiftName = "Blossom Pack",
						Item = v.createListReward({
							v.createSwordReward("Blossom Blade"),
							v.createSwordReward("Blossom Scythe"),
							v.createExplosionReward("Blossom Season"),
							v.createEmoteReward("Emote238")
						}),
						ProductId = 1790920895,
						DiscountedFrom = 2500
					},
					{
						GiftName = "Dual Blossom Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Blossom Blade"),
							v.createSwordReward("Dual Blossom Scythe"),
							v.createExplosionReward("Cherry Blossom Tree"),
							v.createEmoteReward("Emote237"),
							v.createEmoteReward("Emote239")
						}),
						ProductId = 1790922110,
						DiscountedFrom = 5000
					}
				}
			}
		}
	}
}