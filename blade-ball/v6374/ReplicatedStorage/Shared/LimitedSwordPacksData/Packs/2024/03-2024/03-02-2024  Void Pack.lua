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
		FFlagStartTime = "VoidBladeStartTime",
		FFlagEndTime = "VoidBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Void Blade",
				Image = v2.Icons:GetSwordIcon("Dual Void Blades"),
				ShowRoom = "VoidBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Void Blade",
						Item = v.createListReward({ v.createSwordReward("Void Blade") }),
						ProductId = 1766541144
					},
					{
						GiftName = "Dual Void Blades",
						Item = v.createListReward({
							v.createSwordReward("Dual Void Blades"),
							v.createExplosionReward("Void Blast")
						}),
						ProductId = 1766542226
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "VoidScytheStartTime",
		FFlagEndTime = "VoidScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Void Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Void Scythes"),
				ShowRoom = "VoidScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Void Scythe",
						Item = v.createListReward({
							v.createSwordReward("Void Scythe"),
							v.createExplosionReward("Void Blast"),
							v.createEmoteReward("Emote161")
						}),
						ProductId = 1766541525
					},
					{
						GiftName = "Dual Void Scythes",
						Item = v.createListReward({
							v.createSwordReward("Dual Void Scythes"),
							v.createExplosionReward("Void Blast"),
							v.createEmoteReward("Emote162")
						}),
						ProductId = 1766547594
					}
				}
			}
		}
	},
	{
		FFlagStartTime = "VoidPackStartTime",
		FFlagEndTime = "VoidPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Void Pack",
				Image = "rbxassetid://16580666541",
				ShowRoom = "VoidPackShowRoom",
				Rewards = {
					{
						GiftName = "Void Pack",
						Item = v.createListReward({
							v.createSwordReward("Void Scythe"),
							v.createSwordReward("Void Blade"),
							v.createExplosionReward("Void Blast"),
							v.createEmoteReward("Emote161")
						}),
						ProductId = 1766542744,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Void Pack",
						Item = v.createListReward({
							v.createSwordReward("Dual Void Scythes"),
							v.createSwordReward("Dual Void Blades"),
							v.createExplosionReward("Void Blast"),
							v.createEmoteReward("Emote162")
						}),
						ProductId = 1766542850,
						DiscountedFrom = 3800
					}
				}
			}
		}
	}
}