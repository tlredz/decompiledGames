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
		RootFFlagStartTime = "SantasGreatswordRootStartTime",
		RootFFlagEndTime = "SantasGreatswordRootEndTime",
		FFlagStartTime = "SantasGreatswordStartTime",
		FFlagEndTime = "SantasGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Santa's Greatsword",
				Image = "rbxassetid://106440439760583",
				ShowRoom = "SantasGreatswordShowRoom",
				TemplateType = "Bundle",
				Stock = "Santa's Greatsword",
				Rewards = {
					{
						GiftName = "Santa's Greatsword",
						GiftId = 2680479859,
						Item = v.createListReward({
							v.createSwordReward("Santa's Greatsword"),
							v.createExplosionReward("Santa's Greatplosion"),
							v.createEmoteReward("Santa's Greatsword Emote")
						}),
						ProductId = 2680479855
					}
				}
			}
		}
	}
}