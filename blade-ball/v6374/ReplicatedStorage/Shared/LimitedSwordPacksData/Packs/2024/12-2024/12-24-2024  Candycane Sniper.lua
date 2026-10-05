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
		RootFFlagStartTime = "CandycaneSniperRootStartTime",
		RootFFlagEndTime = "CandycaneSniperRootEndTime",
		FFlagStartTime = "WonderwispGreatswordStartTime",
		FFlagEndTime = "WonderwispGreatswordEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Candycane Sniper",
				Image = "rbxassetid://79675410095488",
				ShowRoom = "CandycaneSniperShowRoom",
				TemplateType = "Bundle",
				Stock = "Candycane Sniper",
				Rewards = {
					{
						GiftName = "Candycane Sniper",
						GiftId = 2680479857,
						Item = v.createListReward({
							v.createSwordReward("Candycane Sniper"),
							v.createExplosionReward("Sweet Headshot"),
							v.createEmoteReward("Candycane Sniper Emote")
						}),
						ProductId = 2680479860
					}
				}
			}
		}
	}
}