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
		RootFFlagStartTime = "OrnamentCrushersRootStartTime",
		RootFFlagEndTime = "OrnamentCrushersRootEndTime",
		FFlagStartTime = "OrnamentCrushersStartTime",
		FFlagEndTime = "OrnamentCrushersEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ornament Crushers",
				Image = "rbxassetid://135309952024048",
				ShowRoom = "OrnamentCrushersShowRoom",
				Rewards = {
					{
						GiftName = "Ornament Crushers",
						GiftId = 2680479851,
						Item = v.createListReward({
							v.createSwordReward("Ornament Crushers"),
							v.createExplosionReward("Ornamental Strike"),
							v.createEmoteReward("Ornament Crushers Emote")
						}),
						ProductId = 2680479863
					}
				}
			}
		}
	}
}