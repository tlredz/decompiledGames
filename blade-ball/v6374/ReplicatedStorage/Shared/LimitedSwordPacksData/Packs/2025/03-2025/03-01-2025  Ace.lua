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
		RootFFlagStartTime = "AceShowRoomRootStartTime",
		RootFFlagEndTime = "AceShowRoomRootEndTime",
		FFlagStartTime = "AceShowRoomStartTime",
		FFlagEndTime = "AceShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Ace",
				Image = "rbxassetid://140459556444901",
				ShowRoom = "AceShowRoom",
				TemplateType = "Bundle",
				Stock = "Ace",
				Rewards = {
					{
						GiftName = "Ace",
						GiftId = 3228233103,
						Item = v.createListReward({
							v.createSwordReward("Ace"),
							v.createExplosionReward("Playcards Shuffler"),
							v.createEmoteReward("Emote811")
						}),
						ProductId = 3228233105
					}
				}
			}
		}
	}
}