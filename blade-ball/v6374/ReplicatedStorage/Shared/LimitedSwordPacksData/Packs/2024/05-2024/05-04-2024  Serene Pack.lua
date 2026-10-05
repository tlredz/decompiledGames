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
		RootFFlagStartTime = "SerenePackRootStartTime",
		RootFFlagEndTime = "SerenePackRootEndTime",
		FFlagStartTime = "SereneBladeStartTime",
		FFlagEndTime = "SereneBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Serene Blade",
				Image = v2.Icons:GetSwordIcon("Dual Serene Blade"),
				ShowRoom = "SereneBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Serene Blade",
						GiftId = 1820637007,
						Item = v.createListReward({ v.createSwordReward("Serene Blade") }),
						ProductId = 1820637009
					},
					{
						GiftName = "Dual Serene Blade",
						GiftId = 1820637006,
						Item = v.createListReward({
							v.createSwordReward("Dual Serene Blade"),
							v.createExplosionReward("Serene Zone"),
							v.createEmoteReward("Emote305")
						}),
						ProductId = 1820637004
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SerenePackRootStartTime",
		RootFFlagEndTime = "SerenePackRootEndTime",
		FFlagStartTime = "SereneScytheStartTime",
		FFlagEndTime = "SereneScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Serene Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Serene Scythe"),
				ShowRoom = "SereneScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Serene Scythe",
						GiftId = 1820637014,
						Item = v.createListReward({
							v.createSwordReward("Serene Scythe"),
							v.createExplosionReward("Serene Spectrum"),
							v.createEmoteReward("Emote303")
						}),
						ProductId = 1820637011
					},
					{
						GiftName = "Dual Serene Scythe",
						GiftId = 1820637015,
						Item = v.createListReward({
							v.createSwordReward("Dual Serene Scythe"),
							v.createExplosionReward("Serene Spectrum"),
							v.createEmoteReward("Emote304")
						}),
						ProductId = 1820637012
					}
				}
			}
		}
	},
	{
		Reconcile = true,
		RootFFlagStartTime = "SerenePackRootStartTime",
		RootFFlagEndTime = "SerenePackRootEndTime",
		FFlagStartTime = "SerenePackStartTime",
		FFlagEndTime = "SerenePackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Serene Pack",
				Image = "rbxassetid://17376208161",
				ShowRoom = "SerenePackShowRoom",
				Rewards = {
					{
						GiftName = "Serene Pack",
						GiftId = 1820637005,
						Item = v.createListReward({
							v.createSwordReward("Serene Blade"),
							v.createSwordReward("Serene Scythe"),
							v.createExplosionReward("Serene Zone"),
							v.createEmoteReward("Emote303")
						}),
						ProductId = 1820637013,
						DiscountedFrom = 2000
					},
					{
						GiftName = "Dual Serene Pack",
						GiftId = 1820637010,
						Item = v.createListReward({
							v.createSwordReward("Dual Serene Blade"),
							v.createSwordReward("Dual Serene Scythe"),
							v.createExplosionReward("Serene Spectrum"),
							v.createEmoteReward("Emote305"),
							v.createEmoteReward("Emote304")
						}),
						ProductId = 1820637008,
						DiscountedFrom = 3000
					}
				}
			}
		}
	}
}