local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(ReplicatedStorage2.Common.Utils)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "FestivePack1RootStartTime",
		RootFFlagEndTime = "FestivePack1RootEndTime",
		FFlagStartTime = "FestiveBowStartTime",
		FFlagEndTime = "FestiveBowEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Festive Bow",
				Image = "rbxassetid://106015739624524",
				ShowRoom = "FestiveBowShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						GiftName = "Festive Bow",
						GiftId = 2680479854,
						Item = v.createListReward({
							v.createSwordReward("Festive Bow"),
							v.createExplosionReward("Peppermint Candy"),
							v.createEmoteReward("Festive Bow Emote")
						}),
						ProductId = 2680479850
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Festive Chakram",
				Image = "rbxassetid://128839888414806",
				ShowRoom = "FestiveChakramShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						GiftName = "Festive Chakram",
						GiftId = 2680479853,
						Item = v.createListReward({
							v.createSwordReward("Festive Chakram"),
							v.createExplosionReward("Peppermint Swirl"),
							v.createEmoteReward("Festive Chakram Emote")
						}),
						ProductId = 2680479852
					}
				}
			},
			{
				Type = "Bundle",
				Name = "Festive Pack",
				Image = "rbxassetid://106412842189208",
				ShowRoom = "FestivePackShowRoom",
				TemplateType = "Bundle",
				Rewards = {
					{
						GiftName = "Festive Pack",
						GiftId = 2680480872,
						Item = v.createListReward({
							v.createSwordReward("Festive Bow"),
							v.createSwordReward("Festive Chakram"),
							v.createExplosionReward("Peppermint Candy"),
							v.createExplosionReward("Peppermint Swirl"),
							v.createEmoteReward("Festive Bow Emote"),
							v.createEmoteReward("Festive Chakram Emote")
						}),
						ProductId = 2680480871,
						DiscountedFrom = 4000
					}
				}
			}
		}
	}
}