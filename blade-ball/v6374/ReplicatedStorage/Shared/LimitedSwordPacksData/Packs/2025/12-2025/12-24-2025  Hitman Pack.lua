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
		RootFFlagStartTime = "HitmanRootStartTime",
		RootFFlagEndTime = "HitmanRootEndTime",
		FFlagStartTime = "HitmanShowRoomStartTime",
		FFlagEndTime = "HitmanShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Hitman",
				Image = "rbxassetid://73208703834118",
				ShowRoom = "HitmanShowRoom",
				TemplateType = "Bundle",
				Stock = "Hitman",
				Rewards = {
					{
						GiftName = "Hitman",
						GiftId = 3488864858,
						Item = v.createListReward({
							v.createSwordReward("Hitman"),
							v.createExplosionReward("Bounty Claimed"),
							v.createEmoteReward("Emote1115")
						}),
						ProductId = 3488864861
					}
				}
			}
		}
	}
}