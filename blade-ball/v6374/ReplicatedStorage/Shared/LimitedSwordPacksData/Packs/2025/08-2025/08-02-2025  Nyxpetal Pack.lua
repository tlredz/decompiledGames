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
		RootFFlagStartTime = "NyxpetalPackRootStartTime",
		RootFFlagEndTime = "NyxpetalPackRootEndTime",
		FFlagStartTime = "NyxpetalBladeStartTime",
		FFlagEndTime = "NyxpetalBladeEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nyxpetal Blade",
				Image = v2.Icons:GetSwordIcon("Dual Nyxpetal Blade"),
				ShowRoom = "NyxpetalBladeShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nyxpetal Blade",
						GiftId = 3355902972,
						Item = v.createListReward({ v.createSwordReward("Nyxpetal Blade") }),
						ProductId = 3355902971
					},
					{
						GiftName = "Dual Nyxpetal Blade",
						GiftId = 3355902977,
						Item = v.createListReward({
							v.createSwordReward("Dual Nyxpetal Blade"),
							v.createExplosionReward("Nyxpetalplosion"),
							v.createEmoteReward("Emote999")
						}),
						ProductId = 3355902983
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NyxpetalPackRootStartTime",
		RootFFlagEndTime = "NyxpetalPackRootEndTime",
		FFlagStartTime = "NyxpetalFanStartTime",
		FFlagEndTime = "NyxpetalFanEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nyxpetal Fan",
				Image = v2.Icons:GetSwordIcon("Dual Nyxpetal Fan"),
				ShowRoom = "NyxpetalFanShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Nyxpetal Fan",
						GiftId = 3355902980,
						Item = v.createListReward({
							v.createSwordReward("Nyxpetal Fan"),
							v.createExplosionReward("Nyxpetal Bloom"),
							v.createEmoteReward("Emote1000")
						}),
						ProductId = 3355902976
					},
					{
						GiftName = "Dual Nyxpetal Fan",
						GiftId = 3355902975,
						Item = v.createListReward({
							v.createSwordReward("Dual Nyxpetal Fan"),
							v.createExplosionReward("Nyxpetal Bloom"),
							v.createEmoteReward("Emote1001")
						}),
						ProductId = 3355902974
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "NyxpetalPackRootStartTime",
		RootFFlagEndTime = "NyxpetalPackRootEndTime",
		FFlagStartTime = "NyxpetalPackStartTime",
		FFlagEndTime = "NyxpetalPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Nyxpetal Pack",
				Image = "rbxassetid://74058221964880",
				ShowRoom = "NyxpetalPackShowRoom",
				Rewards = {
					{
						GiftName = "Nyxpetal Pack",
						GiftId = 3355902982,
						Item = v.createListReward({
							v.createSwordReward("Nyxpetal Blade"),
							v.createSwordReward("Nyxpetal Fan"),
							v.createExplosionReward("Nyxpetalplosion"),
							v.createEmoteReward("Emote1000")
						}),
						ProductId = 3355902979,
						DiscountedFrom = 2799
					},
					{
						GiftName = "Dual Nyxpetal Pack",
						GiftId = 3355902973,
						Item = v.createListReward({
							v.createSwordReward("Dual Nyxpetal Blade"),
							v.createSwordReward("Dual Nyxpetal Fan"),
							v.createExplosionReward("Nyxpetal Bloom"),
							v.createEmoteReward("Emote999"),
							v.createEmoteReward("Emote1001")
						}),
						ProductId = 3355902984,
						DiscountedFrom = 3799
					}
				}
			}
		}
	}
}