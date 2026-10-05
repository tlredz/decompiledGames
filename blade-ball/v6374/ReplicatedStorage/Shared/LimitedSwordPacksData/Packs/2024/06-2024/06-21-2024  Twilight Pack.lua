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
		RootFFlagStartTime = "TwilightPackRootStartTime",
		RootFFlagEndTime = "TwilightPackRootEndTime",
		FFlagStartTime = "TwilightBladeStartTime",
		FFlagEndTime = "TwilightBladeEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Twilight Blade",
				Image = v2.Icons:GetSwordIcon("Dual Twilight Blade"),
				ShowRoom = "TwilightBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Twilight Blade",
						GiftId = 1855083673,
						Item = v.createListReward({ v.createSwordReward("Twilight Blade") }),
						ProductId = 1855083682
					},
					{
						GiftName = "Dual Twilight Blade",
						GiftId = 1855083680,
						Item = v.createListReward({
							v.createSwordReward("Dual Twilight Blade"),
							v.createExplosionReward("Destination Beacon"),
							v.createEmoteReward("Emote388")
						}),
						ProductId = 1855083672
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "TwilightPackRootStartTime",
		RootFFlagEndTime = "TwilightPackRootEndTime",
		FFlagStartTime = "TwilightScytheStartTime",
		FFlagEndTime = "TwilightScytheEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Twilight Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Twilight Scythe"),
				ShowRoom = "TwilightScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Twilight Scythe",
						GiftId = 1855083676,
						Item = v.createListReward({
							v.createSwordReward("Twilight Scythe"),
							v.createExplosionReward("Final Arrival"),
							v.createEmoteReward("Emote389")
						}),
						ProductId = 1855083681
					},
					{
						GiftName = "Dual Twilight Scythe",
						GiftId = 1855083678,
						Item = v.createListReward({
							v.createSwordReward("Dual Twilight Scythe"),
							v.createExplosionReward("Final Arrival"),
							v.createEmoteReward("Emote390")
						}),
						ProductId = 1855083679
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "TwilightPackRootStartTime",
		RootFFlagEndTime = "TwilightPackRootEndTime",
		FFlagStartTime = "TwilightPackStartTime",
		FFlagEndTime = "TwilightPackEndTime",
		Reconcile = true,
		Rewards = {
			{
				Type = "Bundle",
				Name = "Twilight Pack",
				Image = "rbxassetid://18151914549",
				ShowRoom = "TwilightPackShowRoom",
				Rewards = {
					{
						GiftName = "Twilight Pack",
						GiftId = 1855083685,
						Item = v.createListReward({
							v.createSwordReward("Twilight Blade"),
							v.createSwordReward("Twilight Scythe"),
							v.createExplosionReward("Destination Beacon"),
							v.createEmoteReward("Emote389")
						}),
						ProductId = 1855083674,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Twilight Pack",
						GiftId = 1855083683,
						Item = v.createListReward({
							v.createSwordReward("Dual Twilight Blade"),
							v.createSwordReward("Dual Twilight Scythe"),
							v.createExplosionReward("Final Arrival"),
							v.createEmoteReward("Emote388"),
							v.createEmoteReward("Emote390")
						}),
						ProductId = 1855083675,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}