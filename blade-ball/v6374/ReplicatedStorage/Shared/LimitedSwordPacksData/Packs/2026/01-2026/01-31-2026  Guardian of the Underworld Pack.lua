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
		RootFFlagStartTime = "GuardianUnderworldRootStartTime",
		RootFFlagEndTime = "GuardianUnderworldRootEndTime",
		FFlagStartTime = "GuardianUnderworldStartTime",
		FFlagEndTime = "GuardianUnderworldEndTime",
		Rewards = {
			{
				Type = "Bundle",
				Name = "Guardian of the Underworld",
				Image = "rbxassetid://109641390745266",
				ShowRoom = "GuardianUnderworldShowRoom",
				TemplateType = "Bundle",
				Stock = "Guardian of the Underworld",
				Rewards = {
					{
						GiftName = "Guardian of the Underworld",
						GiftId = 3527425407,
						Item = v.createListReward({
							v.createSwordReward("Guardian of the Underworld"),
							v.createExplosionReward("Guardian of the Underworld Explosion"),
							v.createEmoteReward("Emote1134")
						}),
						ProductId = 3527425404
					}
				}
			}
		}
	}
}