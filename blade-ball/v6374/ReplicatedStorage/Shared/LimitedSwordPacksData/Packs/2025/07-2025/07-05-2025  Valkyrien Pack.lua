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
		RootFFlagStartTime = "ValkyrienPackRootStartTime",
		RootFFlagEndTime = "ValkyrienPackRootEndTime",
		FFlagStartTime = "ValkyrienBladeStartTime",
		FFlagEndTime = "ValkyrienBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Valkyrien Blade",
				Image = v2.Icons:GetSwordIcon("Dual Valkyrien Blade"),
				ShowRoom = "ValkyrienBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Valkyrien Blade",
						GiftId = 3325285122,
						Item = v.createListReward({ v.createSwordReward("Valkyrien Blade") }),
						ProductId = 3325285132
					},
					{
						GiftName = "Dual Valkyrien Blade",
						GiftId = 3325285120,
						Item = v.createListReward({
							v.createSwordReward("Dual Valkyrien Blade"),
							v.createExplosionReward("Valkyrien Eyes"),
							v.createEmoteReward("Emote972")
						}),
						ProductId = 3325285126
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ValkyrienPackRootStartTime",
		RootFFlagEndTime = "ValkyrienPackRootEndTime",
		FFlagStartTime = "ValkyrienScytheStartTime",
		FFlagEndTime = "ValkyrienScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Valkyrien Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Valkyrien Scythe"),
				ShowRoom = "ValkyrienScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Valkyrien Scythe",
						GiftId = 3325285129,
						Item = v.createListReward({
							v.createSwordReward("Valkyrien Scythe"),
							v.createExplosionReward("Valkyrien Light"),
							v.createEmoteReward("Emote973")
						}),
						ProductId = 3325285127
					},
					{
						GiftName = "Dual Valkyrien Scythe",
						GiftId = 3325285133,
						Item = v.createListReward({
							v.createSwordReward("Dual Valkyrien Scythe"),
							v.createExplosionReward("Valkyrien Light"),
							v.createEmoteReward("Emote974")
						}),
						ProductId = 3325285128
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "ValkyrienPackRootStartTime",
		RootFFlagEndTime = "ValkyrienPackRootEndTime",
		FFlagStartTime = "ValkyrienPackStartTime",
		FFlagEndTime = "ValkyrienPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Valkyrien Pack",
				Image = "rbxassetid://134000040816155",
				ShowRoom = "ValkyrienPackShowRoom",
				Rewards = {
					{
						GiftName = "Valkyrien Pack",
						GiftId = 3325285121,
						Item = v.createListReward({
							v.createSwordReward("Valkyrien Blade"),
							v.createSwordReward("Valkyrien Scythe"),
							v.createExplosionReward("Valkyrien Eyes"),
							v.createEmoteReward("Emote973")
						}),
						ProductId = 3325285124,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Valkyrien Pack",
						GiftId = 3325285123,
						Item = v.createListReward({
							v.createSwordReward("Dual Valkyrien Blade"),
							v.createSwordReward("Dual Valkyrien Scythe"),
							v.createExplosionReward("Valkyrien Light"),
							v.createEmoteReward("Emote974"),
							v.createEmoteReward("Emote972")
						}),
						ProductId = 3325285125,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}