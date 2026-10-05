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
		RootFFlagStartTime = "CloudRootStartTime",
		RootFFlagEndTime = "CloudRootEndTime",
		FFlagStartTime = "CloudStartTime",
		FFlagEndTime = "CloudEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cloud",
				Image = "rbxassetid://87411649822768",
				ShowRoom = "CloudShowRoom",
				TemplateType = "Bundle",
				Stock = "Cloud",
				Rewards = {
					{
						GiftName = "Cloud",
						GiftId = 3585199334,
						Item = v.createListReward({
							v.createSwordReward("Cloud"),
							v.createExplosionReward("Prismatic Cloud Rain"),
							v.createEmoteReward("Emote1209")
						}),
						ProductId = 3585199335
					}
				}
			}
		}
	}
}