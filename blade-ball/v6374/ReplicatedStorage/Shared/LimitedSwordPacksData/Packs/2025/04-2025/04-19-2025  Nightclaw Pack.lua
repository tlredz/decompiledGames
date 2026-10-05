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
		RootFFlagStartTime = "NightclawPackRootStartTime",
		RootFFlagEndTime = "NightclawPackRootEndTime",
		FFlagStartTime = "NightclawBladeStartTime",
		FFlagEndTime = "NightclawBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nightclaw Blade",
				Image = v2.Icons:GetSwordIcon("Dual Nightclaw Blade"),
				ShowRoom = "NightclawBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nightclaw Blade",
						GiftId = 3268694991,
						Item = v.createListReward({ v.createSwordReward("Nightclaw Blade") }),
						ProductId = 3268694994
					},
					{
						GiftName = "Dual Nightclaw Blade",
						GiftId = 3268694986,
						Item = v.createListReward({
							v.createSwordReward("Dual Nightclaw Blade"),
							v.createExplosionReward("Nightclaw Portal"),
							v.createEmoteReward("Emote878")
						}),
						ProductId = 3268694997
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NightclawPackRootStartTime",
		RootFFlagEndTime = "NightclawPackRootEndTime",
		FFlagStartTime = "NightclawScytheStartTime",
		FFlagEndTime = "NightclawScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nightclaw Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Nightclaw Scythe"),
				ShowRoom = "NightclawScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nightclaw Scythe",
						GiftId = 3268694988,
						Item = v.createListReward({
							v.createSwordReward("Nightclaw Scythe"),
							v.createExplosionReward("Nightclaw Hole"),
							v.createEmoteReward("Emote879")
						}),
						ProductId = 3268694989
					},
					{
						GiftName = "Dual Nightclaw Scythe",
						GiftId = 3268694992,
						Item = v.createListReward({
							v.createSwordReward("Dual Nightclaw Scythe"),
							v.createExplosionReward("Nightclaw Hole"),
							v.createEmoteReward("Emote880")
						}),
						ProductId = 3268694996
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NightclawPackRootStartTime",
		RootFFlagEndTime = "NightclawPackRootEndTime",
		FFlagStartTime = "NightclawPackStartTime",
		FFlagEndTime = "NightclawPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nightclaw Pack",
				Image = "rbxassetid://123261449061409",
				ShowRoom = "NightclawPackShowRoom",
				Rewards = {
					{
						GiftName = "Nightclaw Pack",
						GiftId = 3268694990,
						Item = v.createListReward({
							v.createSwordReward("Nightclaw Blade"),
							v.createSwordReward("Nightclaw Scythe"),
							v.createExplosionReward("Nightclaw Portal"),
							v.createEmoteReward("Emote879")
						}),
						ProductId = 3268694987,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Nightclaw Pack",
						GiftId = 3268694993,
						Item = v.createListReward({
							v.createSwordReward("Dual Nightclaw Blade"),
							v.createSwordReward("Dual Nightclaw Scythe"),
							v.createExplosionReward("Nightclaw Hole"),
							v.createEmoteReward("Emote878"),
							v.createEmoteReward("Emote880")
						}),
						ProductId = 3268694995,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}