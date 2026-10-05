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
		RootFFlagStartTime = "InfernoPackRootStartTime",
		RootFFlagEndTime = "InfernoPackRootEndTime",
		FFlagStartTime = "InfernoKatanaStartTime",
		FFlagEndTime = "InfernoKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Inferno Katana",
				Image = v2.Icons:GetSwordIcon("Dual Inferno Katana"),
				ShowRoom = "InfernoKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Inferno Katana",
						GiftId = 3234152378,
						Item = v.createListReward({ v.createSwordReward("Inferno Katana") }),
						ProductId = 3234152377
					},
					{
						GiftName = "Dual Inferno Katana",
						GiftId = 3234152384,
						Item = v.createListReward({
							v.createSwordReward("Dual Inferno Katana"),
							v.createExplosionReward("Solar Planets"),
							v.createEmoteReward("Emote823")
						}),
						ProductId = 3234152381
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "InfernoPackRootStartTime",
		RootFFlagEndTime = "InfernoPackRootEndTime",
		FFlagStartTime = "InfernoLanceStartTime",
		FFlagEndTime = "InfernoLanceEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Inferno Lance",
				Image = v2.Icons:GetSwordIcon("Inferno Lance"),
				ShowRoom = "InfernoLanceShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Inferno Lance",
						GiftId = 3234152383,
						Item = v.createListReward({
							v.createSwordReward("Inferno Lance"),
							v.createExplosionReward("Inferno"),
							v.createEmoteReward("Emote824")
						}),
						ProductId = 3234152376
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "InfernoPackRootStartTime",
		RootFFlagEndTime = "InfernoPackRootEndTime",
		FFlagStartTime = "InfernoPackStartTime",
		FFlagEndTime = "InfernoPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Inferno Pack",
				Image = "rbxassetid://83861842858961",
				ShowRoom = "InfernoPackShowRoom",
				Rewards = {
					{
						GiftName = "Inferno Pack",
						GiftId = 3234152380,
						Item = v.createListReward({
							v.createSwordReward("Inferno Katana"),
							v.createSwordReward("Inferno Lance"),
							v.createExplosionReward("Solar Planets"),
							v.createEmoteReward("Emote824")
						}),
						ProductId = 3234152382,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Inferno Pack",
						GiftId = 3234152379,
						Item = v.createListReward({
							v.createSwordReward("Dual Inferno Katana"),
							v.createSwordReward("Inferno Lance"),
							v.createExplosionReward("Inferno"),
							v.createEmoteReward("Emote824"),
							v.createEmoteReward("Emote823")
						}),
						ProductId = 3234152375,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}