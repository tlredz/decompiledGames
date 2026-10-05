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
		RootFFlagStartTime = "SerpentRootStartTime",
		RootFFlagEndTime = "SerpentRootEndTime",
		FFlagStartTime = "SerpentShowRoomStartTime",
		FFlagEndTime = "SerpentShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Serpent",
				Image = "rbxassetid://70436140195220",
				ShowRoom = "SerpentShowRoom",
				TemplateType = "Bundle",
				Stock = "Serpent",
				Rewards = {
					{
						GiftName = "Serpent",
						GiftId = 2708243461,
						Item = v.createListReward({
							v.createSwordReward("Serpent"),
							v.createExplosionReward("Year of the Serpent"),
							v.createEmoteReward("Emote755")
						}),
						ProductId = 2708243460
					}
				}
			}
		}
	}
}