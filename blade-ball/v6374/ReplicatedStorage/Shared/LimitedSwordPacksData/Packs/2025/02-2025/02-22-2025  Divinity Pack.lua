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
		RootFFlagStartTime = "DivinityPackRootStartTime",
		RootFFlagEndTime = "DivinityPackRootEndTime",
		FFlagStartTime = "DivinityBladeStartTime",
		FFlagEndTime = "DivinityBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divinity Blade",
				Image = v2.Icons:GetSwordIcon("Dual Divinity Blade"),
				ShowRoom = "DivinityBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divinity Blade",
						GiftId = 3220224732,
						Item = v.createListReward({ v.createSwordReward("Divinity Blade") }),
						ProductId = 3220224733
					},
					{
						GiftName = "Dual Divinity Blade",
						GiftId = 3221392826,
						Item = v.createListReward({
							v.createSwordReward("Dual Divinity Blade"),
							v.createExplosionReward("Divinity Shards"),
							v.createEmoteReward("Emote797")
						}),
						ProductId = 3221392822
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivinityPackRootStartTime",
		RootFFlagEndTime = "DivinityPackRootEndTime",
		FFlagStartTime = "DivinityScytheStartTime",
		FFlagEndTime = "DivinityScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divinity Scythe",
				Image = v2.Icons:GetSwordIcon("Dual Divinity Scythe"),
				ShowRoom = "DivinityScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Divinity Scythe",
						GiftId = 3221392823,
						Item = v.createListReward({
							v.createSwordReward("Divinity Scythe"),
							v.createExplosionReward("Divinity Diamond"),
							v.createEmoteReward("Emote798")
						}),
						ProductId = 3221392827
					},
					{
						GiftName = "Dual Divinity Scythe",
						GiftId = 3221392825,
						Item = v.createListReward({
							v.createSwordReward("Dual Divinity Scythe"),
							v.createExplosionReward("Divinity Diamond"),
							v.createEmoteReward("Emote799")
						}),
						ProductId = 3221392824
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "DivinityPackRootStartTime",
		RootFFlagEndTime = "DivinityPackRootEndTime",
		FFlagStartTime = "DivinityPackStartTime",
		FFlagEndTime = "DivinityPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Divinity Pack",
				Image = "rbxassetid://106093614091760",
				ShowRoom = "DivinityPackShowRoom",
				Rewards = {
					{
						GiftName = "Divinity Pack",
						GiftId = 3220224735,
						Item = v.createListReward({
							v.createSwordReward("Divinity Blade"),
							v.createSwordReward("Divinity Scythe"),
							v.createExplosionReward("Divinity Shards"),
							v.createEmoteReward("Emote798")
						}),
						ProductId = 3220224741,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Divinity Pack",
						GiftId = 3220224737,
						Item = v.createListReward({
							v.createSwordReward("Dual Divinity Blade"),
							v.createSwordReward("Dual Divinity Scythe"),
							v.createExplosionReward("Divinity Diamond"),
							v.createEmoteReward("Emote797"),
							v.createEmoteReward("Emote799")
						}),
						ProductId = 3220224736,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}