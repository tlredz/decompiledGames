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
		RootFFlagStartTime = "PrismaticOdachiRootStartTime",
		RootFFlagEndTime = "PrismaticOdachiRootEndTime",
		FFlagStartTime = "PrismaticOdachiShowRoomStartTime",
		FFlagEndTime = "PrismaticOdachiShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Prismatic Odachi",
				Image = "rbxassetid://102993462051886",
				ShowRoom = "PrismaticOdachiShowRoom",
				TemplateType = "Bundle",
				Stock = "Prismatic Odachi",
				Rewards = {
					{
						GiftName = "Prismatic Odachi",
						GiftId = 3302235588,
						Item = v.createListReward({
							v.createSwordReward("Prismatic Odachi"),
							v.createExplosionReward("Prismatic Odachi Explosion"),
							v.createEmoteReward("Emote953")
						}),
						ProductId = 3302235591
					}
				}
			}
		}
	}
}