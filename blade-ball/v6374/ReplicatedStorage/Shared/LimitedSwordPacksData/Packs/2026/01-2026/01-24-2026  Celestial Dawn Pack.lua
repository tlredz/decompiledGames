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
		RootFFlagStartTime = "CelestialDawnPackRootStartTime",
		RootFFlagEndTime = "CelestialDawnPackRootEndTime",
		FFlagStartTime = "CelestialDawnBladeStartTime",
		FFlagEndTime = "CelestialDawnBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Celestial Dawn Blade",
				Image = v2.Icons:GetSwordIcon("Dual Celestial Dawn Blade"),
				ShowRoom = "CelestialDawnBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Celestial Dawn Blade",
						GiftId = 3517551976,
						Item = v.createListReward({ v.createSwordReward("Celestial Dawn Blade") }),
						ProductId = 3517551972
					},
					{
						GiftName = "Dual Celestial Dawn Blade",
						GiftId = 3517551968,
						Item = v.createListReward({
							v.createSwordReward("Dual Celestial Dawn Blade"),
							v.createExplosionReward("Celestial Dawn"),
							v.createEmoteReward("Emote1127")
						}),
						ProductId = 3517551978
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CelestialDawnPackRootStartTime",
		RootFFlagEndTime = "CelestialDawnPackRootEndTime",
		FFlagStartTime = "CelestialDawnScytheStartTime",
		FFlagEndTime = "CelestialDawnScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Celestial Dawn Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Celestial Dawn Scythe"),
				ShowRoom = "CelestialDawnScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Celestial Dawn Scythe",
						GiftId = 3517551974,
						Item = v.createListReward({
							v.createSwordReward("Celestial Dawn Scythe"),
							v.createExplosionReward("Dawn Crescent"),
							v.createEmoteReward("Emote1128")
						}),
						ProductId = 3517551970
					},
					{
						GiftName = "Dual Celestial Dawn Scythe",
						GiftId = 3517551967,
						Item = v.createListReward({
							v.createSwordReward("Dual Celestial Dawn Scythe"),
							v.createExplosionReward("Dawn Crescent"),
							v.createEmoteReward("Emote1129")
						}),
						ProductId = 3517551973
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "CelestialDawnPackRootStartTime",
		RootFFlagEndTime = "CelestialDawnPackRootEndTime",
		FFlagStartTime = "CelestialDawnPackStartTime",
		FFlagEndTime = "CelestialDawnPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Celestial Dawn Pack",
				Image = "rbxassetid://133968627888107",
				ShowRoom = "CelestialDawnPackShowRoom",
				Rewards = {
					{
						GiftName = "Celestial Dawn Pack",
						GiftId = 3517551977,
						Item = v.createListReward({
							v.createSwordReward("Celestial Dawn Blade"),
							v.createSwordReward("Celestial Dawn Scythe"),
							v.createExplosionReward("Celestial Dawn"),
							v.createEmoteReward("Emote1128")
						}),
						ProductId = 3517551969,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Celestial Dawn Pack",
						GiftId = 3517551975,
						Item = v.createListReward({
							v.createSwordReward("Dual Celestial Dawn Blade"),
							v.createSwordReward("Dual Celestial Dawn Scythe"),
							v.createExplosionReward("Dawn Crescent"),
							v.createEmoteReward("Emote1127"),
							v.createEmoteReward("Emote1129")
						}),
						ProductId = 3517551971,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}