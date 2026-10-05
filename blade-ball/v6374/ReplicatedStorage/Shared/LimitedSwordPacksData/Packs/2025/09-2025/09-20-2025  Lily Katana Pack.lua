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
		RootFFlagStartTime = "LilyKatanaRootStartTime",
		RootFFlagEndTime = "LilyKatanaRootEndTime",
		FFlagStartTime = "LilyKatanaShowRoomStartTime",
		FFlagEndTime = "LilyKatanaShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Lily Katana",
				Image = "rbxassetid://79762748890320",
				ShowRoom = "LilyKatanaShowRoom",
				TemplateType = "Bundle",
				Stock = "Lily Katana",
				Rewards = {
					{
						GiftName = "Lily Katana",
						GiftId = 3409252098,
						Item = v.createListReward({
							v.createSwordReward("Lily Katana"),
							v.createExplosionReward("Lily Strike"),
							v.createEmoteReward("Emote1048")
						}),
						ProductId = 3409252096
					}
				}
			}
		}
	}
}