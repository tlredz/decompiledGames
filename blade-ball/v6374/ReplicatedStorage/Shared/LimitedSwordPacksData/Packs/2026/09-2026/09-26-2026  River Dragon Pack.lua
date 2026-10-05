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
		RootFFlagStartTime = "RiverDragonStartTime",
		RootFFlagEndTime = "RiverDragonEndTime",
		FFlagStartTime = "RiverDragonBladeStartTime",
		FFlagEndTime = "RiverDragonBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "River Dragon Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual River Dragon Blade"),
				Color = Color3.new(0.15, 0.3, 1),
				ShowRoom = "RiverDragonBladeShowRoom",
				Rewards = {
					{
						GiftName = "River Dragon Blade",
						GiftId = 3714170138,
						Item = v.createListReward({ v.createSwordReward("River Dragon Blade") }),
						ProductId = 3714170147
					},
					{
						GiftName = "Dual River Dragon Blade",
						GiftId = 3714170157,
						Item = v.createListReward({
							v.createSwordReward("Dual River Dragon Blade"),
							v.createExplosionReward("River Dragon Summon"),
							v.createEmoteReward("Dual River Dragon Blade Emote")
						}),
						ProductId = 3714170184
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RiverDragonStartTime",
		RootFFlagEndTime = "RiverDragonEndTime",
		FFlagStartTime = "RiverDragonScytheStartTime",
		FFlagEndTime = "RiverDragonScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "River Dragon Scythe",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual River Dragon Scythe"),
				Color = Color3.new(0.15, 0.3, 1),
				ShowRoom = "RiverDragonScytheShowRoom",
				Rewards = {
					{
						GiftName = "River Dragon Scythe",
						GiftId = 3714170204,
						Item = v.createListReward({
							v.createSwordReward("River Dragon Scythe"),
							v.createExplosionReward("River Dragon Splash"),
							v.createEmoteReward("River Dragon Scythe Emote")
						}),
						ProductId = 3714170215
					},
					{
						GiftName = "Dual River Dragon Scythe",
						GiftId = 3714170225,
						Item = v.createListReward({
							v.createSwordReward("Dual River Dragon Scythe"),
							v.createExplosionReward("River Dragon Splash"),
							v.createEmoteReward("Dual River Dragon Scythe Emote")
						}),
						ProductId = 3714170240
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "RiverDragonStartTime",
		RootFFlagEndTime = "RiverDragonEndTime",
		FFlagStartTime = "RiverDragonPackStartTime",
		FFlagEndTime = "RiverDragonPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "River Dragon Pack",
				Image = "rbxassetid://89826596266495",
				Color = Color3.new(0.15, 0.3, 1),
				ShowRoom = "RiverDragonPackShowRoom",
				Rewards = {
					{
						GiftName = "River Dragon Pack",
						GiftId = 3714170252,
						Item = v.createListReward({
							v.createSwordReward("River Dragon Blade"),
							v.createSwordReward("River Dragon Scythe"),
							v.createExplosionReward("River Dragon Splash"),
							v.createEmoteReward("River Dragon Scythe Emote")
						}),
						ProductId = 3714170265
					},
					{
						GiftName = "Dual River Dragon Pack",
						GiftId = 3714170280,
						Item = v.createListReward({
							v.createSwordReward("Dual River Dragon Blade"),
							v.createSwordReward("Dual River Dragon Scythe"),
							v.createExplosionReward("River Dragon Splash"),
							v.createEmoteReward("Dual River Dragon Blade Emote"),
							v.createEmoteReward("Dual River Dragon Scythe Emote")
						}),
						ProductId = 3714170286
					}
				}
			}
		}
	}
}