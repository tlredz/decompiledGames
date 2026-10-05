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
		RootFFlagStartTime = "DarkLotusPackRootStartTime",
		RootFFlagEndTime = "DarkLotusPackRootEndTime",
		FFlagStartTime = "DarkLotusBladeStartTime",
		FFlagEndTime = "DarkLotusBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dark Lotus Blade",
				Image = v2.Icons:GetSwordIcon("Dual Dark Lotus Blade"),
				ShowRoom = "DarkLotusBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Dark Lotus Blade",
						GiftId = 3526763476,
						Item = v.createListReward({ v.createSwordReward("Dark Lotus Blade") }),
						ProductId = 3526763473
					},
					{
						GiftName = "Dual Dark Lotus Blade",
						GiftId = 3526763469,
						Item = v.createListReward({
							v.createSwordReward("Dual Dark Lotus Blade"),
							v.createExplosionReward("Lotus Energy"),
							v.createEmoteReward("Emote1130")
						}),
						ProductId = 3526763474
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DarkLotusPackRootStartTime",
		RootFFlagEndTime = "DarkLotusPackRootEndTime",
		FFlagStartTime = "DarkLotusScytheStartTime",
		FFlagEndTime = "DarkLotusScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dark Lotus Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Dark Lotus Scythe"),
				ShowRoom = "DarkLotusScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Dark Lotus Scythe",
						GiftId = 3526763479,
						Item = v.createListReward({
							v.createSwordReward("Dark Lotus Scythe"),
							v.createExplosionReward("Lotus Bloom"),
							v.createEmoteReward("Emote1131")
						}),
						ProductId = 3526763478
					},
					{
						GiftName = "Dual Dark Lotus Scythe",
						GiftId = 3526763472,
						Item = v.createListReward({
							v.createSwordReward("Dual Dark Lotus Scythe"),
							v.createExplosionReward("Lotus Bloom"),
							v.createEmoteReward("Emote1132")
						}),
						ProductId = 3526763475
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DarkLotusPackRootStartTime",
		RootFFlagEndTime = "DarkLotusPackRootEndTime",
		FFlagStartTime = "DarkLotusPackStartTime",
		FFlagEndTime = "DarkLotusPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Dark Lotus Pack",
				Image = "rbxassetid://138369639557707",
				ShowRoom = "DarkLotusPackShowRoom",
				Rewards = {
					{
						GiftName = "Dark Lotus Pack",
						GiftId = 3526763471,
						Item = v.createListReward({
							v.createSwordReward("Dark Lotus Blade"),
							v.createSwordReward("Dark Lotus Scythe"),
							v.createExplosionReward("Lotus Energy"),
							v.createEmoteReward("Emote1131")
						}),
						ProductId = 3526763477,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Dark Lotus Pack",
						GiftId = 3526763470,
						Item = v.createListReward({
							v.createSwordReward("Dual Dark Lotus Blade"),
							v.createSwordReward("Dual Dark Lotus Scythe"),
							v.createExplosionReward("Lotus Bloom"),
							v.createEmoteReward("Emote1130"),
							v.createEmoteReward("Emote1132")
						}),
						ProductId = 3526763468,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}