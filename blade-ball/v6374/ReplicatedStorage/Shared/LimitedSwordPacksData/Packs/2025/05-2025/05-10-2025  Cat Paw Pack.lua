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
		RootFFlagStartTime = "CatPawShowRoomRootStartTime",
		RootFFlagEndTime = "CatPawShowRoomRootEndTime",
		FFlagStartTime = "CatPawShowRoomStartTime",
		FFlagEndTime = "CatPawShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Cat Paw",
				Image = "rbxassetid://99666855219805",
				ShowRoom = "CatPawShowRoom",
				TemplateType = "Bundle",
				Stock = "Cat Paw",
				Rewards = {
					{
						GiftName = "Cat Paw",
						GiftId = 3283087787,
						Item = v.createListReward({
							v.createSwordReward("Cat Paw"),
							v.createExplosionReward("Paw Punch"),
							v.createEmoteReward("Emote909")
						}),
						ProductId = 3283087784
					}
				}
			}
		}
	}
}