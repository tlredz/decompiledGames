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
		RootFFlagStartTime = "WickedCrowRootStartTime",
		RootFFlagEndTime = "WickedCrowRootEndTime",
		FFlagStartTime = "WickedCrowShowRoomStartTime",
		FFlagEndTime = "WickedCrowShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Wicked Crow",
				Image = "rbxassetid://90837551839731",
				ShowRoom = "WickedCrowShowRoom",
				TemplateType = "Bundle",
				Stock = "Wicked Crow",
				Rewards = {
					{
						GiftName = "Wicked Crow",
						GiftId = 3462326322,
						Item = v.createListReward({
							v.createSwordReward("Wicked Crow"),
							v.createExplosionReward("Wicked Crow Explosion"),
							v.createEmoteReward("Emote1086")
						}),
						ProductId = 3462326324
					}
				}
			}
		}
	}
}