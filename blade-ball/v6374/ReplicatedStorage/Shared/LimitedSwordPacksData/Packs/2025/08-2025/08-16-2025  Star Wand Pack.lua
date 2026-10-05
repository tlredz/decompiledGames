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
		RootFFlagStartTime = "StarWandRootStartTime",
		RootFFlagEndTime = "StarWandRootEndTime",
		FFlagStartTime = "StarWandShowRoomStartTime",
		FFlagEndTime = "StarWandShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Star Wand",
				Image = "rbxassetid://97470878362927",
				ShowRoom = "StarWandShowRoom",
				TemplateType = "Bundle",
				Stock = "Star Wand",
				Rewards = {
					{
						GiftName = "Star Wand",
						GiftId = 3373381418,
						Item = v.createListReward({
							v.createSwordReward("Star Wand"),
							v.createExplosionReward("Star Wand Explosion"),
							v.createEmoteReward("Emote1019")
						}),
						ProductId = 3373381419
					}
				}
			}
		}
	}
}