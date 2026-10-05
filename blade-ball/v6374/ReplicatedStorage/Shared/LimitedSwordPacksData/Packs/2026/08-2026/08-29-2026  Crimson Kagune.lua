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
		RootFFlagStartTime = "CrimsonKaguneStartTime",
		RootFFlagEndTime = "CrimsonKaguneEndTime",
		FFlagStartTime = "CrimsonKaguneStartTime",
		FFlagEndTime = "CrimsonKaguneEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Crimson Kagune",
				Image = "rbxassetid://131850030662682",
				ShowRoom = "CrimsonKaguneShowRoom",
				TemplateType = "Bundle",
				Stock = "Crimson Kagune",
				Rewards = {
					{
						GiftName = "Crimson Kagune",
						GiftId = 3710423801,
						Item = v.createListReward({
							v.createSwordReward("Crimson Kagune"),
							v.createExplosionReward("Crimson Kagune Explosion"),
							v.createEmoteReward("Emote1268")
						}),
						ProductId = 3710423803
					}
				}
			}
		}
	}
}