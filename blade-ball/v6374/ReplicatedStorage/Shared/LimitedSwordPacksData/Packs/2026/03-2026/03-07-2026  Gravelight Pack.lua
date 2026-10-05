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
		RootFFlagStartTime = "GravelightRootStartTime",
		RootFFlagEndTime = "GravelightRootEndTime",
		FFlagStartTime = "GravelightStartTime",
		FFlagEndTime = "GravelightEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Gravelight",
				Image = "rbxassetid://101905731508555",
				ShowRoom = "GravelightShowRoom",
				TemplateType = "Bundle",
				Stock = "Gravelight",
				Rewards = {
					{
						GiftName = "Gravelight",
						GiftId = 3551336798,
						Item = v.createListReward({
							v.createSwordReward("Gravelight"),
							v.createExplosionReward("Cross Admiration"),
							v.createEmoteReward("Emote1180")
						}),
						ProductId = 3551336792
					}
				}
			}
		}
	}
}