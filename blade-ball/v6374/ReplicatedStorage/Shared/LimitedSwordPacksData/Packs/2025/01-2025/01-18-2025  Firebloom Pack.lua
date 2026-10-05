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
		RootFFlagStartTime = "FirebloomPackRootStartTime",
		RootFFlagEndTime = "FirebloomPackRootEndTime",
		FFlagStartTime = "FirebloomBladeStartTime",
		FFlagEndTime = "FirebloomBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Firebloom Blade",
				Image = v2.Icons:GetSwordIcon("Dual Firebloom Blade"),
				ShowRoom = "FirebloomBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Firebloom Blade",
						GiftId = 2702010523,
						Item = v.createListReward({ v.createSwordReward("Firebloom Blade") }),
						ProductId = 2702010522
					},
					{
						GiftName = "Dual Firebloom Blade",
						GiftId = 2702010529,
						Item = v.createListReward({
							v.createSwordReward("Dual Firebloom Blade"),
							v.createExplosionReward("Firebloom Garden"),
							v.createEmoteReward("Emote745")
						}),
						ProductId = 2702010528
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FirebloomPackRootStartTime",
		RootFFlagEndTime = "FirebloomPackRootEndTime",
		FFlagStartTime = "FirebloomScytheStartTime",
		FFlagEndTime = "FirebloomScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Firebloom Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Firebloom Scythe"),
				ShowRoom = "FirebloomScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Firebloom Scythe",
						GiftId = 2702010526,
						Item = v.createListReward({
							v.createSwordReward("Firebloom Scythe"),
							v.createExplosionReward("Firebloom Rift"),
							v.createEmoteReward("Emote746")
						}),
						ProductId = 2702010531
					},
					{
						GiftName = "Dual Firebloom Scythe",
						GiftId = 2702010534,
						Item = v.createListReward({
							v.createSwordReward("Dual Firebloom Scythe"),
							v.createExplosionReward("Firebloom Rift"),
							v.createEmoteReward("Emote747")
						}),
						ProductId = 2702010533
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "FirebloomPackRootStartTime",
		RootFFlagEndTime = "FirebloomPackRootEndTime",
		FFlagStartTime = "FirebloomPackStartTime",
		FFlagEndTime = "FirebloomPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Firebloom Pack",
				Image = "rbxassetid://90047821974203",
				ShowRoom = "FirebloomPackShowRoom",
				Rewards = {
					{
						GiftName = "Firebloom Pack",
						GiftId = 2702010538,
						Item = v.createListReward({
							v.createSwordReward("Firebloom Blade"),
							v.createSwordReward("Firebloom Scythe"),
							v.createExplosionReward("Firebloom Garden"),
							v.createEmoteReward("Emote746")
						}),
						ProductId = 2702010525,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Firebloom Pack",
						GiftId = 2702010527,
						Item = v.createListReward({
							v.createSwordReward("Dual Firebloom Blade"),
							v.createSwordReward("Dual Firebloom Scythe"),
							v.createExplosionReward("Firebloom Rift"),
							v.createEmoteReward("Emote745"),
							v.createEmoteReward("Emote747")
						}),
						ProductId = 2702010530,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}