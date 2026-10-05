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
		RootFFlagStartTime = "CoffinRootStartTime",
		RootFFlagEndTime = "CoffinRootEndTime",
		FFlagStartTime = "CoffinShowRoomStartTime",
		FFlagEndTime = "CoffinShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Coffin",
				Image = "rbxassetid://94396461807260",
				ShowRoom = "CoffinShowRoom",
				TemplateType = "Bundle",
				Stock = "Coffin",
				Rewards = {
					{
						GiftName = "Coffin",
						GiftId = 2319193592,
						Item = v.createListReward({
							v.createSwordReward("Coffin"),
							v.createExplosionReward("Coffin Explosion"),
							v.createEmoteReward("Emote594")
						}),
						ProductId = 2319193591
					}
				}
			}
		}
	}
}