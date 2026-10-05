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
		RootFFlagStartTime = "TheCurseShowRoomRootStartTime",
		RootFFlagEndTime = "TheCurseShowRoomRootEndTime",
		FFlagStartTime = "TheCurseShowRoomStartTime",
		FFlagEndTime = "TheCurseShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "The Curse",
				Image = "rbxassetid://106499786074994",
				ShowRoom = "TheCurseShowRoom",
				TemplateType = "Bundle",
				Stock = "The Curse",
				Rewards = {
					{
						GiftName = "The Curse",
						GiftId = 3251942819,
						Item = v.createListReward({
							v.createSwordReward("The Curse"),
							v.createExplosionReward("The Curse Explosion"),
							v.createEmoteReward("Emote852")
						}),
						ProductId = 3251942815
					}
				}
			}
		}
	}
}