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
		RootFFlagStartTime = "StarfishStartTime",
		RootFFlagEndTime = "StarfishEndTime",
		FFlagStartTime = "StarfishBladeStartTime",
		FFlagEndTime = "StarfishBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starfish Blade",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Starfish Blade"),
				Color = Color3.new(1, 1, 0.6),
				ShowRoom = "StarfishBladeShowRoom",
				Rewards = {
					{
						GiftName = "Starfish Blade",
						GiftId = 3712470921,
						Item = v.createListReward({ v.createSwordReward("Starfish Blade") }),
						ProductId = 3712470925
					},
					{
						GiftName = "Dual Starfish Blade",
						GiftId = 3712470930,
						Item = v.createListReward({
							v.createSwordReward("Dual Starfish Blade"),
							v.createExplosionReward("Starfish Arise Explosion"),
							v.createEmoteReward("Emote1276")
						}),
						ProductId = 3712470931
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarfishStartTime",
		RootFFlagEndTime = "StarfishEndTime",
		FFlagStartTime = "StarfishScytheStartTime",
		FFlagEndTime = "StarfishScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starfish Scythe",
				TemplateType = "Sword",
				Image = v2.Icons:GetSwordIcon("Dual Starfish Scythe"),
				Color = Color3.new(1, 1, 0.6),
				ShowRoom = "StarfishScytheShowRoom",
				Rewards = {
					{
						GiftName = "Starfish Scythe",
						GiftId = 3712470940,
						Item = v.createListReward({
							v.createSwordReward("Starfish Scythe"),
							v.createExplosionReward("Flashing Starfish Explosion"),
							v.createEmoteReward("Emote1277")
						}),
						ProductId = 3712470945
					},
					{
						GiftName = "Dual Starfish Scythe",
						GiftId = 3712470949,
						Item = v.createListReward({
							v.createSwordReward("Dual Starfish Scythe"),
							v.createExplosionReward("Flashing Starfish Explosion"),
							v.createEmoteReward("Emote1278")
						}),
						ProductId = 3712470953
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "StarfishStartTime",
		RootFFlagEndTime = "StarfishEndTime",
		FFlagStartTime = "StarfishPackStartTime",
		FFlagEndTime = "StarfishPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Starfish Pack",
				Image = "rbxassetid://108976954155845",
				Color = Color3.new(1, 1, 0.6),
				ShowRoom = "StarfishPackShowRoom",
				Rewards = {
					{
						GiftName = "Starfish Pack",
						GiftId = 3712470958,
						Item = v.createListReward({
							v.createSwordReward("Starfish Blade"),
							v.createSwordReward("Starfish Scythe"),
							v.createExplosionReward("Flashing Starfish Explosion"),
							v.createEmoteReward("Emote1277")
						}),
						ProductId = 3712470964
					},
					{
						GiftName = "Dual Starfish Pack",
						GiftId = 3712470968,
						Item = v.createListReward({
							v.createSwordReward("Dual Starfish Blade"),
							v.createSwordReward("Dual Starfish Scythe"),
							v.createExplosionReward("Flashing Starfish Explosion"),
							v.createEmoteReward("Emote1276"),
							v.createEmoteReward("Emote1278")
						}),
						ProductId = 3712470972
					}
				}
			}
		}
	}
}