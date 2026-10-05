local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
require3(script:FindFirstAncestor("Packs").Parent.Types)
return {
	{
		RootFFlagStartTime = "CherubStartTime",
		RootFFlagEndTime = "CherubEndTime",
		FFlagStartTime = "CherubStartTime",
		FFlagEndTime = "CherubEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cherub",
				Image = "rbxassetid://96974093259527",
				ShowRoom = "CherubShowRoom",
				TemplateType = "Bundle",
				Stock = "Cherub",
				Rewards = {
					{
						GiftName = "Cherub",
						GiftId = 3716289604,
						Item = v.createListReward({
							v.createSwordReward("Cherub"),
							v.createExplosionReward("Kitty's Big Hug"),
							v.createEmoteReward("Emote1287")
						}),
						ProductId = 3716289608
					}
				}
			}
		}
	}
}