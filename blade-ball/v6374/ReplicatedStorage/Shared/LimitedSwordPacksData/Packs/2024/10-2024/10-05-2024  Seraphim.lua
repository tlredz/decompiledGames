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
		RootFFlagStartTime = "SeraphimPackRootStartTime",
		RootFFlagEndTime = "SeraphimPackRootEndTime",
		FFlagStartTime = "SeraphimShowRoomStartTime",
		FFlagEndTime = "SeraphimShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Seraphim",
				Image = "rbxassetid://86293339630900",
				ShowRoom = "SeraphimShowRoom",
				TemplateType = "Bundle",
				Stock = "Seraphim",
				Rewards = {
					{
						GiftName = "Seraphim",
						GiftId = 2147610236,
						Item = v.createListReward({
							v.createSwordReward("Seraphim"),
							v.createExplosionReward("Seraphim Gate"),
							v.createEmoteReward("Emote555")
						}),
						ProductId = 2147610237
					}
				}
			}
		}
	}
}