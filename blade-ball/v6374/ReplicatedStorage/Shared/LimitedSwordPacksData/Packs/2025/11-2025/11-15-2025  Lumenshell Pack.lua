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
		RootFFlagStartTime = "LumenshellPackRootStartTime",
		RootFFlagEndTime = "LumenshellPackRootEndTime",
		FFlagStartTime = "LumenshellBladeStartTime",
		FFlagEndTime = "LumenshellBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenshell Blade",
				Image = v2.Icons:GetSwordIcon("Dual Lumenshell Blade"),
				ShowRoom = "LumenshellBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumenshell Blade",
						GiftId = 3456623895,
						Item = v.createListReward({ v.createSwordReward("Lumenshell Blade") }),
						ProductId = 3456623889
					},
					{
						GiftName = "Dual Lumenshell Blade",
						GiftId = 3456623900,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumenshell Blade"),
							v.createExplosionReward("Lumenshell Splash"),
							v.createEmoteReward("Emote1082")
						}),
						ProductId = 3456623893
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LumenshellPackRootStartTime",
		RootFFlagEndTime = "LumenshellPackRootEndTime",
		FFlagStartTime = "LumenshellScytheStartTime",
		FFlagEndTime = "LumenshellScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenshell Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Lumenshell Scythe"),
				ShowRoom = "LumenshellScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lumenshell Scythe",
						GiftId = 3456623894,
						Item = v.createListReward({
							v.createSwordReward("Lumenshell Scythe"),
							v.createExplosionReward("Shellplosion"),
							v.createEmoteReward("Emote1083")
						}),
						ProductId = 3456623891
					},
					{
						GiftName = "Dual Lumenshell Scythe",
						GiftId = 3456623899,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumenshell Scythe"),
							v.createExplosionReward("Shellplosion"),
							v.createEmoteReward("Emote1084")
						}),
						ProductId = 3456623892
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LumenshellPackRootStartTime",
		RootFFlagEndTime = "LumenshellPackRootEndTime",
		FFlagStartTime = "LumenshellPackStartTime",
		FFlagEndTime = "LumenshellPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lumenshell Pack",
				Image = "rbxassetid://118188633462848",
				ShowRoom = "LumenshellPackShowRoom",
				Rewards = {
					{
						GiftName = "Lumenshell Pack",
						GiftId = 3456623898,
						Item = v.createListReward({
							v.createSwordReward("Lumenshell Blade"),
							v.createSwordReward("Lumenshell Scythe"),
							v.createExplosionReward("Lumenshell Splash"),
							v.createEmoteReward("Emote1083")
						}),
						ProductId = 3456623896,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Lumenshell Pack",
						GiftId = 3456623890,
						Item = v.createListReward({
							v.createSwordReward("Dual Lumenshell Blade"),
							v.createSwordReward("Dual Lumenshell Scythe"),
							v.createExplosionReward("Shellplosion"),
							v.createEmoteReward("Emote1082"),
							v.createEmoteReward("Emote1084")
						}),
						ProductId = 3456623897,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}