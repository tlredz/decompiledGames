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
		RootFFlagStartTime = "WolfGreatswordRootStartTime",
		RootFFlagEndTime = "WolfGreatswordRootEndTime",
		FFlagStartTime = "WolfGreatswordStartTime",
		FFlagEndTime = "WolfGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wolf Greatsword",
				Image = "rbxassetid://100547367558637",
				ShowRoom = "WolfGreatswordShowRoom",
				TemplateType = "Bundle",
				Stock = "Wolf Greatsword",
				Rewards = {
					{
						GiftName = "Wolf Greatsword",
						GiftId = 3569908912,
						Item = v.createListReward({
							v.createSwordReward("Wolf Greatsword"),
							v.createExplosionReward("Wolf Greatsword Explosion"),
							v.createEmoteReward("Emote1198")
						}),
						ProductId = 3569908917
					}
				}
			}
		}
	}
}