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
		RootFFlagStartTime = "SkeletonBrideRootStartTime",
		RootFFlagEndTime = "SkeletonBrideRootEndTime",
		FFlagStartTime = "SkeletonBrideShowRoomStartTime",
		FFlagEndTime = "SkeletonBrideShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Skeleton Bride",
				Image = "rbxassetid://86455298138384",
				ShowRoom = "SkeletonBrideShowRoom",
				TemplateType = "Bundle",
				Stock = "Skeleton Bride",
				Rewards = {
					{
						GiftName = "Skeleton Bride",
						GiftId = 3440156699,
						Item = v.createListReward({
							v.createSwordReward("Skeleton Bride"),
							v.createExplosionReward("Bridal Revival"),
							v.createEmoteReward("Emote1062")
						}),
						ProductId = 3440156696
					}
				}
			}
		}
	}
}