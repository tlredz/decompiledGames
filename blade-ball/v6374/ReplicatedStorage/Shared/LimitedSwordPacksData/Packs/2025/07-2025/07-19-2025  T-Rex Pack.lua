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
		RootFFlagStartTime = "T-RexRootStartTime",
		RootFFlagEndTime = "T-RexRootEndTime",
		FFlagStartTime = "T-RexShowRoomStartTime",
		FFlagEndTime = "T-RexShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "T-Rex",
				Image = "rbxassetid://130939351540619",
				ShowRoom = "T-RexShowRoom",
				TemplateType = "Bundle",
				Stock = "T Rex",
				Rewards = {
					{
						GiftName = "T-Rex",
						GiftId = 3339890318,
						Item = v.createListReward({
							v.createSwordReward("T-Rex"),
							v.createExplosionReward("T-Rex Explosion"),
							v.createEmoteReward("Emote991")
						}),
						ProductId = 3339890321
					}
				}
			}
		}
	}
}