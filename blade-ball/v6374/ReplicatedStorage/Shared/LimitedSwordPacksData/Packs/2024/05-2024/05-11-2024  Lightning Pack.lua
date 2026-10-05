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
		RootFFlagStartTime = "LightningPackRootStartTime",
		RootFFlagEndTime = "LightningPackRootEndTime",
		FFlagStartTime = "LightningDaggerStartTime",
		FFlagEndTime = "LightningDaggerEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lightning Dagger",
				Image = v2.Icons:GetSwordIcon("Dual Lightning Dagger"),
				ShowRoom = "LightningDaggerShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lightning Dagger",
						GiftId = 1826188807,
						Item = v.createListReward({ v.createSwordReward("Lightning Dagger") }),
						ProductId = 1826188805
					},
					{
						GiftName = "Dual Lightning Dagger",
						GiftId = 1826188812,
						Item = v.createListReward({
							v.createSwordReward("Dual Lightning Dagger"),
							v.createExplosionReward("Zeus' Punishment"),
							v.createEmoteReward("Emote313")
						}),
						ProductId = 1826188814
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LightningPackRootStartTime",
		RootFFlagEndTime = "LightningPackRootEndTime",
		FFlagStartTime = "LightningSickleStartTime",
		FFlagEndTime = "LightningSickleEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lightning Sickle",
				Image = v2.Icons:GetSwordIcon("Dual Lightning Sickle"),
				ShowRoom = "LightningSickleShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Lightning Sickle",
						GiftId = 1826188811,
						Item = v.createListReward({
							v.createSwordReward("Lightning Sickle"),
							v.createExplosionReward("Cosmic Storm"),
							v.createEmoteReward("Emote311")
						}),
						ProductId = 1826188804
					},
					{
						GiftName = "Dual Lightning Sickle",
						GiftId = 1826188810,
						Item = v.createListReward({
							v.createSwordReward("Dual Lightning Sickle"),
							v.createExplosionReward("Cosmic Storm"),
							v.createEmoteReward("Emote312")
						}),
						ProductId = 1826188809
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "LightningPackRootStartTime",
		RootFFlagEndTime = "LightningPackRootEndTime",
		FFlagStartTime = "LightningPackStartTime",
		FFlagEndTime = "LightningPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lightning Pack",
				Image = "rbxassetid://17443780840",
				ShowRoom = "LightningPackShowRoom",
				Rewards = {
					{
						GiftName = "Lightning Pack",
						GiftId = 1826188808,
						Item = v.createListReward({
							v.createSwordReward("Lightning Dagger"),
							v.createSwordReward("Lightning Sickle"),
							v.createExplosionReward("Zeus' Punishment"),
							v.createEmoteReward("Emote311")
						}),
						ProductId = 1826188813,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Lightning Pack",
						GiftId = 1826188806,
						Item = v.createListReward({
							v.createSwordReward("Dual Lightning Dagger"),
							v.createSwordReward("Dual Lightning Sickle"),
							v.createExplosionReward("Cosmic Storm"),
							v.createEmoteReward("Emote313"),
							v.createEmoteReward("Emote312")
						}),
						ProductId = 1826188815,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}