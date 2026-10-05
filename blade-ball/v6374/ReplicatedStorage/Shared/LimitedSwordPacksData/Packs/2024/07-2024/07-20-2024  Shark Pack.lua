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
		RootFFlagStartTime = "SharkPackRootStartTime",
		RootFFlagEndTime = "SharkPackRootEndTime",
		FFlagStartTime = "SharkPackShowRoomStartTime",
		FFlagEndTime = "SharkPackShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Shark Pack",
				Image = "rbxassetid://18577991650",
				ShowRoom = "SharkPackShowRoom",
				TemplateType = "Bundle",
				Stock = "Shark",
				Rewards = {
					{
						GiftName = "Shark Pack",
						GiftId = 1882022287,
						Item = v.createListReward({
							v.createSwordReward("Shark"),
							v.createExplosionReward("Shark Feast"),
							v.createEmoteReward("Emote438")
						}),
						ProductId = 1882022286
					}
				}
			}
		}
	}
}