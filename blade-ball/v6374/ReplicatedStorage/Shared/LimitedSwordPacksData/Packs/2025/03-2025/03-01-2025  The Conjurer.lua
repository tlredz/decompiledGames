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
		RootFFlagStartTime = "TheConjurerShowRoomRootStartTime",
		RootFFlagEndTime = "TheConjurerShowRoomRootEndTime",
		FFlagStartTime = "TheConjurerShowRoomStartTime",
		FFlagEndTime = "TheConjurerShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "The Conjurer",
				Image = "rbxassetid://122321559498540",
				ShowRoom = "TheConjurerShowRoom",
				TemplateType = "Bundle",
				Stock = "The Conjurer",
				Rewards = {
					{
						GiftName = "The Conjurer",
						GiftId = 3228241755,
						Item = v.createListReward({
							v.createSwordReward("The Conjurer"),
							v.createExplosionReward("Soulforge Explosion"),
							v.createEmoteReward("Emote810")
						}),
						ProductId = 3228241754
					}
				}
			}
		}
	}
}