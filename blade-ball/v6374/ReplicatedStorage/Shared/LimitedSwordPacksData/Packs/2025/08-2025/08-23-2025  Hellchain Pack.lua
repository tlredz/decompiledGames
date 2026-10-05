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
		RootFFlagStartTime = "HellchainPackRootStartTime",
		RootFFlagEndTime = "HellchainPackRootEndTime",
		FFlagStartTime = "HellchainBladeStartTime",
		FFlagEndTime = "HellchainBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hellchain Blade",
				Image = v2.Icons:GetSwordIcon("Dual Hellchain Blade"),
				ShowRoom = "HellchainBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hellchain Blade",
						GiftId = 3381372119,
						Item = v.createListReward({ v.createSwordReward("Hellchain Blade") }),
						ProductId = 3381372109
					},
					{
						GiftName = "Dual Hellchain Blade",
						GiftId = 3381372112,
						Item = v.createListReward({
							v.createSwordReward("Dual Hellchain Blade"),
							v.createExplosionReward("Hellchain Curse"),
							v.createEmoteReward("Emote1022")
						}),
						ProductId = 3381372120
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HellchainPackRootStartTime",
		RootFFlagEndTime = "HellchainPackRootEndTime",
		FFlagStartTime = "HellchainScytheStartTime",
		FFlagEndTime = "HellchainScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hellchain Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Hellchain Scythe"),
				ShowRoom = "HellchainScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hellchain Scythe",
						GiftId = 3381372116,
						Item = v.createListReward({
							v.createSwordReward("Hellchain Scythe"),
							v.createExplosionReward("Hellchain Marker"),
							v.createEmoteReward("Emote1023")
						}),
						ProductId = 3381372122
					},
					{
						GiftName = "Dual Hellchain Scythe",
						GiftId = 3381372117,
						Item = v.createListReward({
							v.createSwordReward("Dual Hellchain Scythe"),
							v.createExplosionReward("Hellchain Marker"),
							v.createEmoteReward("Emote1024")
						}),
						ProductId = 3381372115
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "HellchainPackRootStartTime",
		RootFFlagEndTime = "HellchainPackRootEndTime",
		FFlagStartTime = "HellchainPackStartTime",
		FFlagEndTime = "HellchainPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hellchain Pack",
				Image = "rbxassetid://94350266944019",
				ShowRoom = "HellchainPackShowRoom",
				Rewards = {
					{
						GiftName = "Hellchain Pack",
						GiftId = 3381372114,
						Item = v.createListReward({
							v.createSwordReward("Hellchain Blade"),
							v.createSwordReward("Hellchain Scythe"),
							v.createExplosionReward("Hellchain Curse"),
							v.createEmoteReward("Emote1023")
						}),
						ProductId = 3381372113,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Hellchain Pack",
						GiftId = 3381372110,
						Item = v.createListReward({
							v.createSwordReward("Dual Hellchain Blade"),
							v.createSwordReward("Dual Hellchain Scythe"),
							v.createExplosionReward("Hellchain Marker"),
							v.createEmoteReward("Emote1022"),
							v.createEmoteReward("Emote1024")
						}),
						ProductId = 3381372118,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}