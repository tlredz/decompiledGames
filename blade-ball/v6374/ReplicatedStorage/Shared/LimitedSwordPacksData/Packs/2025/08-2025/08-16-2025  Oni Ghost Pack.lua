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
		RootFFlagStartTime = "OniGhostRootStartTime",
		RootFFlagEndTime = "OniGhostRootEndTime",
		FFlagStartTime = "OniGhostShowRoomStartTime",
		FFlagEndTime = "OniGhostShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Oni Ghost",
				Image = "rbxassetid://78051921640169",
				ShowRoom = "OniGhostShowRoom",
				TemplateType = "Bundle",
				Stock = "Oni Ghost",
				Rewards = {
					{
						GiftName = "Oni Ghost",
						GiftId = 3373381424,
						Item = v.createListReward({
							v.createSwordReward("Oni Ghost"),
							v.createExplosionReward("Oni Ghost Explosion"),
							v.createEmoteReward("Emote1018")
						}),
						ProductId = 3373381414
					}
				}
			}
		}
	}
}