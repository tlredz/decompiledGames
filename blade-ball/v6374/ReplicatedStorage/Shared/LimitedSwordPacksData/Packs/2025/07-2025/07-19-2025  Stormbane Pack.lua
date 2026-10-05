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
		RootFFlagStartTime = "StormbaneRootStartTime",
		RootFFlagEndTime = "StormbaneRootEndTime",
		FFlagStartTime = "StormbaneShowRoomStartTime",
		FFlagEndTime = "StormbaneShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Stormbane",
				Image = "rbxassetid://78168344603074",
				ShowRoom = "StormbaneShowRoom",
				TemplateType = "Bundle",
				Stock = "Stormbane",
				Rewards = {
					{
						GiftName = "Stormbane",
						GiftId = 3339890316,
						Item = v.createListReward({
							v.createSwordReward("Stormbane"),
							v.createExplosionReward("Stormbane Explosion"),
							v.createEmoteReward("Emote990")
						}),
						ProductId = 3339890319
					}
				}
			}
		}
	}
}