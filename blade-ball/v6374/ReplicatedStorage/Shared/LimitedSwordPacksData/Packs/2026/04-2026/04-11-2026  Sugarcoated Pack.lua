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
		RootFFlagStartTime = "SugarcoatedStartTime",
		RootFFlagEndTime = "SugarcoatedEndTime",
		FFlagStartTime = "SugarcoatedSaberStartTime",
		FFlagEndTime = "SugarcoatedSaberEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sugarcoated Saber",
				Image = v2.Icons:GetSwordIcon("Dual Sugarcoated Saber"),
				ShowRoom = "SugarcoatedSaberShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sugarcoated Saber",
						GiftId = 3572477704,
						Item = v.createListReward({ v.createSwordReward("Sugarcoated Saber") }),
						ProductId = 3572477708
					},
					{
						GiftName = "Dual Sugarcoated Saber",
						GiftId = 3572477711,
						Item = v.createListReward({
							v.createSwordReward("Dual Sugarcoated Saber"),
							v.createExplosionReward("Coated Candy"),
							v.createEmoteReward("Emote1199")
						}),
						ProductId = 3572477710
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SugarcoatedStartTime",
		RootFFlagEndTime = "SugarcoatedEndTime",
		FFlagStartTime = "SugarcoatedBowStartTime",
		FFlagEndTime = "SugarcoatedBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sugarcoated Bow",
				Image = v2.Icons:GetSwordIcon("Sugarcoated Bow"),
				ShowRoom = "SugarcoatedBowShowRoom",
				TemplateType = "Sword",
				Rewards = {
					{
						GiftName = "Sugarcoated Bow",
						GiftId = 3572477705,
						Item = v.createListReward({
							v.createSwordReward("Sugarcoated Bow"),
							v.createExplosionReward("Sugar Rush Hour"),
							v.createEmoteReward("Emote1200")
						}),
						ProductId = 3572477712
					}
				}
			}
		}
	},
	{
		RootFFlagStartTime = "SugarcoatedStartTime",
		RootFFlagEndTime = "SugarcoatedEndTime",
		FFlagStartTime = "SugarcoatedPackStartTime",
		FFlagEndTime = "SugarcoatedPackEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Sugarcoated Pack",
				Image = "rbxassetid://113885359567816",
				ShowRoom = "SugarcoatedPackShowRoom",
				Rewards = {
					{
						GiftName = "Sugarcoated Pack",
						GiftId = 3572477706,
						Item = v.createListReward({
							v.createSwordReward("Sugarcoated Saber"),
							v.createSwordReward("Sugarcoated Bow"),
							v.createExplosionReward("Coated Candy"),
							v.createEmoteReward("Emote1200")
						}),
						ProductId = 3572477707,
						DiscountedFrom = 1999
					},
					{
						GiftName = "Dual Sugarcoated Pack",
						GiftId = 3572477703,
						Item = v.createListReward({
							v.createSwordReward("Dual Sugarcoated Saber"),
							v.createSwordReward("Sugarcoated Bow"),
							v.createExplosionReward("Sugar Rush Hour"),
							v.createEmoteReward("Emote1199"),
							v.createEmoteReward("Emote1200")
						}),
						ProductId = 3572477709,
						DiscountedFrom = 3299
					}
				}
			}
		}
	}
}