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
		RootFFlagStartTime = "ShatterflightBirdShowRoomRootStartTime",
		RootFFlagEndTime = "ShatterflightBirdShowRoomRootEndTime",
		FFlagStartTime = "ShatterflightBirdShowRoomStartTime",
		FFlagEndTime = "ShatterflightBirdShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shatterflight Bird",
				Image = "rbxassetid://132649393837956",
				ShowRoom = "ShatterflightBirdShowRoom",
				TemplateType = "Bundle",
				Stock = "Shatterflight Bird",
				Rewards = {
					{
						GiftName = "Shatterflight Bird",
						GiftId = 3283235432,
						Item = v.createListReward({
							v.createSwordReward("Shatterflight Bird"),
							v.createExplosionReward("Shatterflight Bird Explosion"),
							v.createEmoteReward("Emote911")
						}),
						ProductId = 3283235431
					}
				}
			}
		}
	}
}