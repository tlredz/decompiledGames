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
		RootFFlagStartTime = "PoisonedBunnyRootStartTime",
		RootFFlagEndTime = "PoisonedBunnyRootEndTime",
		FFlagStartTime = "PoisonedBunnyShowRoomStartTime",
		FFlagEndTime = "PoisonedBunnyShowRoomEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Poisoned Bunny",
				Image = "rbxassetid://132196488490321",
				ShowRoom = "PoisonedBunnyShowRoom",
				TemplateType = "Bundle",
				Stock = "Poisoned Bunny",
				Rewards = {
					{
						GiftName = "Poisoned Bunny",
						GiftId = 3488864863,
						Item = v.createListReward({
							v.createSwordReward("Poisoned Bunny"),
							v.createExplosionReward("Poisoned Bunny Explosion"),
							v.createEmoteReward("Emote1118")
						}),
						ProductId = 3488864860
					}
				}
			}
		}
	}
}