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
		RootFFlagStartTime = "BadLuckStartTime",
		RootFFlagEndTime = "BadLuckEndTime",
		FFlagStartTime = "HazyKatanaStartTime",
		FFlagEndTime = "HazyKatanaEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hazy Katana",
				Image = v2.Icons:GetSwordIcon("Dual Hazy Katana"),
				ShowRoom = "HazyKatanaShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hazy Katana",
						GiftId = 3591855861,
						Item = v.createListReward({ v.createSwordReward("Hazy Katana") }),
						ProductId = 3591855871
					},
					{
						GiftName = "Dual Hazy Katana",
						GiftId = 3591855883,
						Item = v.createListReward({
							v.createSwordReward("Dual Hazy Katana"),
							v.createExplosionReward("Hazy Smile Explosion"),
							v.createEmoteReward("Emote1214")
						}),
						ProductId = 3591855873
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BadLuckStartTime",
		RootFFlagEndTime = "BadLuckEndTime",
		FFlagStartTime = "HazyScytheStartTime",
		FFlagEndTime = "HazyScytheEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hazy Scythe",
				Image = v2.Icons:GetSwordIcon("Hazy Scythe"),
				ShowRoom = "HazyScytheShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Hazy Scythe",
						GiftId = 3591855872,
						Item = v.createListReward({
							v.createSwordReward("Hazy Scythe"),
							v.createExplosionReward("Bad Luck Explosion"),
							v.createEmoteReward("Emote1215")
						}),
						ProductId = 3591855865
					},
					{
						GiftName = "Dual Hazy Scythe",
						GiftId = 3591855903,
						Item = v.createListReward({
							v.createSwordReward("Dual Hazy Scythe"),
							v.createExplosionReward("Bad Luck Explosion"),
							v.createEmoteReward("Emote1216")
						}),
						ProductId = 3591855904
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "BadLuckStartTime",
		RootFFlagEndTime = "BadLuckEndTime",
		FFlagStartTime = "BadLuckPackStartTime",
		FFlagEndTime = "BadLuckPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Bad Luck Pack",
				Image = "rbxassetid://91119572410057",
				ShowRoom = "BadLuckPackShowRoom",
				Rewards = {
					{
						GiftName = "Bad Luck Pack",
						GiftId = 3591855905,
						Item = v.createListReward({
							v.createSwordReward("Hazy Katana"),
							v.createSwordReward("Hazy Scythe"),
							v.createExplosionReward("Hazy Smile Explosion"),
							v.createEmoteReward("Emote1215")
						}),
						ProductId = 3591856578,
						DiscountedFrom = 2499
					},
					{
						GiftName = "Dual Bad Luck Pack",
						GiftId = 3591855882,
						Item = v.createListReward({
							v.createSwordReward("Dual Hazy Katana"),
							v.createSwordReward("Dual Hazy Scythe"),
							v.createExplosionReward("Bad Luck Explosion"),
							v.createEmoteReward("Emote1214"),
							v.createEmoteReward("Emote1216")
						}),
						ProductId = 3591855881,
						DiscountedFrom = 3599
					}
				}
			}
		}
	}
}